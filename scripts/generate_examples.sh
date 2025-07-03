#!/bin/bash
# Script to generate example files for SView

set -e

# Source common functions and variables
source "$(dirname "$0")/common.sh"

# Ensure examples directory exists
EXAMPLES_DIR="${PROJECT_ROOT}/examples"

# Function to create an SVG file
create_svg() {
    local filepath="$1"
    local content="$2"
    
    # Create directory if it doesn't exist
    mkdir -p "$(dirname "${filepath}")"
    
    # Write content to file
    echo "${content}" > "${filepath}"
    log_success "Created ${filepath}"
}

generate_examples() {
    log_info "📁 Generating example files in ${EXAMPLES_DIR}..."
    
    # Simple Chart Example
    create_svg "${EXAMPLES_DIR}/simple-chart.svg" '
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="300" viewBox="0 0 400 300">
  <rect width="100%" height="100%" fill="#f8f9fa"/>
  <g transform="translate(40, 30)">
    <!-- X axis -->
    <line x1="0" y1="200" x2="320" y2="200" stroke="#6c757d" stroke-width="2"/>
    <!-- Y axis -->
    <line x1="0" y1="0" x2="0" y2="200" stroke="#6c757d" stroke-width="2"/>
    
    <!-- Data points -->
    <rect x="20" y="150" width="40" height="50" fill="#4e73df" rx="2">
      <animate attributeName="height" from="0" to="50" dur="0.5s" fill="freeze"/>
      <animate attributeName="y" from="200" to="150" dur="0.5s" fill="freeze"/>
    </rect>
    <rect x="80" y="100" width="40" height="100" fill="#1cc88a" rx="2">
      <animate attributeName="height" from="0" to="100" dur="0.5s" fill="freeze" begin="0.1s"/>
      <animate attributeName="y" from="200" to="100" dur="0.5s" fill="freeze" begin="0.1s"/>
    </rect>
    <rect x="140" y="50" width="40" height="150" fill="#36b9cc" rx="2">
      <animate attributeName="height" from="0" to="150" dur="0.5s" fill="freeze" begin="0.2s"/>
      <animate attributeName="y" from="200" to="50" dur="0.5s" fill="freeze" begin="0.2s"/>
    </rect>
    
    <!-- Labels -->
    <text x="40" y="220" text-anchor="middle" font-family="sans-serif" font-size="12" fill="#495057">Q1</text>
    <text x="100" y="220" text-anchor="middle" font-family="sans-serif" font-size="12" fill="#495057">Q2</text>
    <text x="160" y="220" text-anchor="middle" font-family="sans-serif" font-size="12" fill="#495057">Q3</text>
    
    <text x="-20" y="30" text-anchor="end" font-family="sans-serif" font-size="12" fill="#495057">$150</text>
    <text x="-20" y="100" text-anchor="end" font-family="sans-serif" font-size="12" fill="#495057">$100</text>
    <text x="-20" y="170" text-anchor="end" font-family="sans-serif" font-size="12" fill="#495057">$50</text>
    
    <text x="160" y="260" text-anchor="middle" font-family="sans-serif" font-size="14" font-weight="bold" fill="#343a40">Quarterly Sales Report</text>
  </g>
</svg>'

    # Dashboard Example
    create_svg "${EXAMPLES_DIR}/dashboard.svg" '
<svg xmlns="http://www.w3.org/2000/svg" width="800" height="600" viewBox="0 0 800 600">
  <style>
    .card { filter: drop-shadow(0 2px 4px rgba(0,0,0,0.1)); }
    .metric-value { font-family: Arial, sans-serif; font-size: 24px; font-weight: bold; fill: #2c3e50; }
    .metric-label { font-family: Arial, sans-serif; font-size: 14px; fill: #7f8c8d; }
  </style>
  
  <!-- Background -->
  <rect width="100%" height="100%" fill="#f5f7fa"/>
  
  <!-- Header -->
  <rect x="0" y="0" width="100%" height="60" fill="#3498db"/>
  <text x="20" y="35" font-family="Arial" font-size="20" font-weight="bold" fill="white">Analytics Dashboard</text>
  
  <!-- Cards -->
  <g transform="translate(40, 100)">
    <!-- Card 1 -->
    <g class="card" transform="translate(0, 0)">
      <rect width="220" height="120" rx="8" fill="white"/>
      <text x="20" y="40" class="metric-value">1,234</text>
      <text x="20" y="70" class="metric-label">Total Users</text>
      <line x1="20" y1="90" x2="200" y2="90" stroke="#ecf0f1" stroke-width="1"/>
      <text x="20" y="110" class="metric-label" font-size="12">+12% from last month</text>
    </g>
    
    <!-- Card 2 -->
    <g class="card" transform="translate(240, 0)">
      <rect width="220" height="120" rx="8" fill="white"/>
      <text x="20" y="40" class="metric-value">$8,950</text>
      <text x="20" y="70" class="metric-label">Revenue</text>
      <line x1="20" y1="90" x2="200" y2="90" stroke="#ecf0f1" stroke-width="1"/>
      <text x="20" y="110" class="metric-label" font-size="12">+5% from last month</text>
    </g>
    
    <!-- Card 3 -->
    <g class="card" transform="translate(480, 0)">
      <rect width="220" height="120" rx="8" fill="white"/>
      <text x="20" y="40" class="metric-value">87%</text>
      <text x="20" y="70" class="metric-label">Engagement</text>
      <line x1="20" y1="90" x2="200" y2="90" stroke="#ecf0f1" stroke-width="1"/>
      <text x="20" y="110" class="metric-label" font-size="12">+2% from last month</text>
    </g>
    
    <!-- Chart -->
    <g class="card" transform="translate(0, 140)">
      <rect width="700" height="300" rx="8" fill="white"/>
      <text x="20" y="30" font-family="Arial" font-size="16" font-weight="bold" fill="#2c3e50">Monthly Performance</text>
      <!-- Simplified chart content would go here -->
      <text x="350" y="200" text-anchor="middle" font-family="Arial" font-size="14" fill="#95a5a6">Performance chart would be rendered here</text>
    </g>
  </g>
</svg>'

    # Minimal Memory Example
    create_svg "${EXAMPLES_DIR}/minimal-memory.svg" '
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:sview="http://sview.veridock.com/schema/v1"
     sview:enhanced="true" width="400" height="200" viewBox="0 0 400 200">
  <metadata>
    <sview:memory>
      <sview:factual>
        <sview:fact key="created">2023-06-15T10:30:00Z</sview:fact>
        <sview:fact key="author">System</sview:fact>
      </sview:factual>
      <sview:episodic>
        <sview:event type="created" timestamp="2023-06-15T10:30:00Z">Document created</sview:event>
      </sview:episodic>
    </sview:memory>
  </metadata>
  <rect width="100%" height="100%" fill="#f8f9fa"/>
  <text x="50%" y="50%" text-anchor="middle" font-family="Arial" font-size="16" fill="#495057">Minimal Memory Example</text>
</svg>'

    # Pong Game
    create_svg "${EXAMPLES_DIR}/pong-game.svg" '
<svg xmlns="http://www.w3.org/2000/svg"
     xmlns:sview="http://sview.veridock.com/schema/v1"
     sview:enhanced="true" width="600" height="400" viewBox="0 0 600 400">
  <rect width="100%" height="100%" fill="#000"/>
  <line x1="300" y1="0" x2="300" y2="400" stroke="#333" stroke-width="2" stroke-dasharray="10,10"/>
  <rect id="leftPaddle" x="20" y="150" width="10" height="100" fill="#fff"/>
  <rect id="rightPaddle" x="570" y="150" width="10" height="100" fill="#fff"/>
  <circle id="ball" cx="300" cy="200" r="8" fill="#fff"/>
  <text x="300" y="30" font-family="Arial" font-size="18" fill="#fff" text-anchor="middle">Pong Game - Click to Start</text>
</svg>'

    log_success "✅ Example files generated in ${EXAMPLES_DIR}"
}
# Main execution
generate_examples

echo -e "${GREEN}✅ Example files created successfully${NC}"
