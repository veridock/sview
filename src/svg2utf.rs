use anyhow::{Context, Result};
use image::{imageops::FilterType, DynamicImage, GenericImageView, RgbaImage};
use resvg::usvg::FitTo;
use std::cmp;
use std::fs;
use std::path::Path;
use std::process::Command;

// Characters ordered by "density" from light to dark
const DENSITY: &str = " .,:;+*?%S#@";
const WIDTH: u32 = 40;
const HEIGHT: u32 = 20;

// Target size for mini icon rendering (16x16 pixels)
const MINI_ICON_SIZE: u32 = 16;

/// Renders an SVG to ASCII art using resvg and image processing
fn render_svg_to_ascii(svg_path: &Path, width: u32, height: u32) -> Result<String> {
    // Read the SVG file
    let svg_data = std::fs::read(svg_path)
        .with_context(|| format!("Failed to read SVG file: {}", svg_path.display()))?;

    // Parse the SVG
    let opt = usvg::Options::default();
    let rtree = usvg::Tree::from_data(&svg_data, &opt)
        .with_context(|| format!("Failed to parse SVG: {}", svg_path.display()))?;

    // Calculate target size while maintaining aspect ratio
    let svg_size = rtree.size;
    let width_f64 = width as f64;
    let height_f64 = height as f64;
    let svg_width = svg_size.width();
    let svg_height = svg_size.height();

    // Determine the best fit while maintaining aspect ratio
    let scale = (width_f64 / svg_width).min(height_f64 / svg_height);
    let target_width = (svg_width * scale).round() as u32;
    let target_height = (svg_height * scale).round() as u32;

    // Create a pixmap to render into
    let mut pixmap = tiny_skia::Pixmap::new(target_width.max(1), target_height.max(1))
        .ok_or_else(|| anyhow::anyhow!("Failed to create pixmap"))?;

    // Render the SVG with the specified dimensions
    resvg::render(
        &rtree,
        FitTo::Size(target_width, target_height),
        tiny_skia::Transform::default(),
        pixmap.as_mut(),
    );

    // Convert to DynamicImage for processing
    let img = RgbaImage::from_raw(pixmap.width(), pixmap.height(), pixmap.data().to_vec())
        .ok_or_else(|| anyhow::anyhow!("Failed to create image from pixmap"))?;

    // Convert to grayscale and resize for terminal display
    let img = DynamicImage::ImageRgba8(img).grayscale();
    let img = img.resize_exact(
        cmp::min(target_width, WIDTH * 2), // Double width for terminal aspect ratio
        cmp::min(target_height, HEIGHT),
        FilterType::Lanczos3,
    );

    // Convert to ASCII art
    let ascii = image_to_ascii(&img);
    Ok(ascii)
}

/// Converts an image to ASCII art
fn image_to_ascii(img: &DynamicImage) -> String {
    let (width, height) = img.dimensions();
    let img = img.to_luma8();
    let mut result = String::with_capacity((width * height) as usize);

    for y in 0..height {
        for x in 0..width {
            let pixel = img.get_pixel(x, y);
            let brightness = pixel.0[0] as f32 / 255.0;
            let index = (brightness * (DENSITY.len() - 1) as f32).round() as usize;
            result.push(DENSITY.chars().nth(index).unwrap_or(' '));
        }
        if y < height - 1 {
            result.push('\n');
        }
    }

    result
}

/// Renders an SVG to terminal with visual representation
pub fn render_svg_terminal(svg_path: &Path) -> Result<()> {
    // Try to use chafa first if available
    if let Ok(output) = Command::new("chafa").arg("--version").output() {
        if output.status.success() {
            // Use chafa for better SVG rendering
            let status = Command::new("chafa")
                .arg("--size=40x20") // Larger size for better detail
                .arg("--symbols=block")
                .arg("--colors=full")
                .arg("--color-space=rgb")
                .arg(svg_path)
                .status()
                .with_context(|| format!("Failed to execute chafa on {}", svg_path.display()))?;

            if status.success() {
                return Ok(());
            }
        }
    }

    // Fallback to our Rust-based renderer
    if let Ok(ascii) = render_svg_to_ascii(svg_path, WIDTH, HEIGHT) {
        println!("\n{}", ascii);
        return Ok(());
    }

    // If all else fails, use a simple icon
    let icon = get_simple_icon(svg_path).unwrap_or("🖼️ ");
    println!("\n{}", icon);
    Ok(())
}

/// Converts an SVG to a single-character mini icon by rendering to a 16x16 bitmap first
pub(crate) fn svg_to_mini_icon(svg_path: &Path) -> Result<char> {
    // Try to render a detailed mini icon first
    if let Ok(icon) = render_svg_to_mini_icon(svg_path) {
        return Ok(icon);
    }

    // Fallback to simple icon if detailed rendering fails
    get_simple_icon(svg_path).map(|s| s.chars().next().unwrap_or('▦'))
}

/// Renders an SVG to a single character by first rendering to a 16x16 bitmap
fn render_svg_to_mini_icon(svg_path: &Path) -> Result<char> {
    // Read the SVG file
    let svg_data = fs::read(svg_path)
        .with_context(|| format!("Failed to read SVG file: {}", svg_path.display()))?;

    // Parse the SVG
    let opt = usvg::Options::default();
    let rtree = usvg::Tree::from_data(&svg_data, &opt)
        .with_context(|| format!("Failed to parse SVG: {}", svg_path.display()))?;

    // Create a larger pixmap for better quality rendering
    let scale_factor = 4; // Render at 4x resolution for better quality
    let render_size = MINI_ICON_SIZE * scale_factor;

    let mut pixmap = tiny_skia::Pixmap::new(render_size, render_size)
        .ok_or_else(|| anyhow::anyhow!("Failed to create pixmap"))?;

    // Clear to transparent
    pixmap.fill(tiny_skia::Color::TRANSPARENT);

    // Calculate scaling to fit the SVG in the pixmap with padding
    let svg_width = rtree.size.width() as f32;
    let svg_height = rtree.size.height() as f32;
    let render_size_f32 = render_size as f32;
    let scale = ((render_size_f32 - 2.0) / svg_width.max(svg_height)).min(1.0);

    // Center the SVG in the pixmap
    let dx = (render_size_f32 - svg_width * scale) / 2.0;
    let dy = (render_size_f32 - svg_height * scale) / 2.0;

    let transform = tiny_skia::Transform::from_scale(scale, scale).post_translate(dx, dy);

    // Render the SVG
    resvg::render(&rtree, FitTo::Original, transform, pixmap.as_mut());

    // Downscale the image to 16x16 using high-quality filtering
    let img = image::RgbaImage::from_raw(render_size, render_size, pixmap.data().to_vec())
        .ok_or_else(|| anyhow::anyhow!("Failed to create image from pixmap"))?;

    let img = image::DynamicImage::ImageRgba8(img);
    let img = img.resize_exact(
        MINI_ICON_SIZE,
        MINI_ICON_SIZE,
        image::imageops::FilterType::Lanczos3,
    );

    // Convert to 2x2 character blocks
    let (width, height) = img.dimensions();
    let luma_img = img.to_luma8();

    // Calculate average brightness for each 2x2 block
    let mut blocks = Vec::with_capacity((width * height / 4) as usize);

    for y in (0..height).step_by(2) {
        for x in (0..width).step_by(2) {
            let mut total = 0.0;
            let mut count = 0;

            // Sample 2x2 block
            for dy in 0..2 {
                for dx in 0..2 {
                    if x + dx < width && y + dy < height {
                        let pixel = luma_img.get_pixel(x + dx, y + dy);
                        total += pixel.0[0] as f32 / 255.0;
                        count += 1;
                    }
                }
            }

            let avg = if count > 0 { total / count as f32 } else { 0.0 };
            blocks.push(avg);
        }
    }

    // If we have no blocks, return a space
    if blocks.is_empty() {
        return Ok(' ');
    }

    // Calculate average brightness of the entire image
    let avg_brightness: f32 = blocks.iter().sum::<f32>() / blocks.len() as f32;

    // Calculate contrast (standard deviation of brightness)
    let variance = blocks
        .iter()
        .map(|&b| (b - avg_brightness).powi(2))
        .sum::<f32>()
        / blocks.len() as f32;
    let contrast = variance.sqrt();

    // Select character set based on contrast
    let char_set = if contrast > 0.3 {
        // High contrast - use detailed blocks
        [' ', '░', '▒', '▓', '█', '▄', '▀', '▌', '▐']
    } else if contrast > 0.15 {
        // Medium contrast - use simpler blocks
        [' ', '░', '▒', '▓', '█', '▄', '▀', '▌', '▐']
    } else {
        // Low contrast - use minimal blocks
        [' ', '░', '▒', '▓', '█', '▄', '▀', '▌', '▐']
    };

    // Map average brightness to character
    let index = (avg_brightness * (char_set.len() - 1) as f32).round() as usize;
    let selected_char = char_set.get(index).copied().unwrap_or('▦');

    // Special case for very bright or dark images
    if avg_brightness < 0.1 {
        return Ok(' '); // Very dark
    } else if avg_brightness > 0.9 {
        return Ok('█'); // Very bright
    }

    Ok(selected_char)
}

/// Gets a simple character representation based on SVG content
///
/// # Errors
/// Returns an error if the file doesn't exist or can't be read
pub fn get_simple_icon(svg_path: &Path) -> Result<&'static str> {
    // First, check if file exists and is accessible
    if !svg_path.exists() {
        return Err(anyhow::anyhow!(
            "File does not exist: {}",
            svg_path.display()
        ));
    }

    // First, try to determine from filename
    if let Some(stem) = svg_path.file_stem() {
        let name = stem.to_string_lossy().to_lowercase();

        // Common SVG icon names
        if name.contains("logo") || name.contains("brand") {
            return Ok("🆒");
        } else if name.contains("icon") {
            return Ok("🛠️");
        } else if name.contains("diagram") || name.contains("chart") {
            return Ok("📊");
        } else if name.contains("graph") {
            return Ok("📈");
        } else if name.contains("user") || name.contains("profile") {
            return Ok("👤");
        } else if name.contains("home") {
            return Ok("🏠");
        } else if name.contains("folder") || name.contains("directory") {
            return Ok("📁");
        } else if name.contains("document") || name.contains("file") {
            return Ok("📄");
        } else if name.contains("image") || name.contains("picture") || name.contains("photo") {
            return Ok("🖼️");
        } else if name.contains("download") || name.contains("upload") {
            return Ok("📥");
        } else if name.contains("settings") || name.contains("preferences") {
            return Ok("⚙️");
        } else if name.contains("search") || name.contains("find") {
            return Ok("🔍");
        }
    }

    // If filename doesn't give enough info, check the content
    let content = std::fs::read_to_string(svg_path)
        .with_context(|| format!("Failed to read file: {}", svg_path.display()))?;

    // Convert to lowercase for case-insensitive matching
    let content_lower = content.to_lowercase();

    // Check for SVG content
    if !content_lower.contains("<svg") {
        return Ok("❓");
    }

    // Try to determine the type of SVG by its content
    if content_lower.contains("<circle") || content_lower.contains("<ellipse") {
        Ok("⭕")
    } else if content_lower.contains("<rect") || content_lower.contains("<polygon") {
        Ok("⬜")
    } else if content_lower.contains("<path") {
        Ok("🔷")
    } else if content_lower.contains("<text") || content_lower.contains("<tspan") {
        Ok("🔤")
    } else if content_lower.contains("<image") {
        Ok("🖼️ ")
    } else {
        // Default icon for other SVG content
        Ok("🖱️ ")
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::path::Path;

    #[test]
    fn test_get_simple_icon() {
        // Test with non-existent file (should return an error)
        let result = get_simple_icon(Path::new("/nonexistent/file.svg"));
        assert!(result.is_err());

        // Test with a test SVG file (mocked for the test)
        let test_svg = "<svg><rect/></svg>";
        let temp_file = tempfile::NamedTempFile::new().unwrap();
        std::fs::write(temp_file.path(), test_svg).unwrap();

        let result = get_simple_icon(temp_file.path()).unwrap();
        assert_eq!(result, "⬜");
    }
}
