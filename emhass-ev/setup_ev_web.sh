#!/bin/bash

# EV Configuration Web Extension Setup Script
# This script modifies the EMHASS web interface to include EV configuration

set -e

echo "🔧 Setting up EV Configuration Web Extension..."

# Find the EMHASS application directory
APP_DIR="/app"
if [ ! -d "$APP_DIR" ]; then
    echo "❌ EMHASS app directory not found"
    exit 1
fi

# Find the static directory (prioritize EMHASS static over others)
STATIC_DIR=$(find $APP_DIR -path "*/emhass/static" -type d 2>/dev/null | head -1)
if [ -z "$STATIC_DIR" ]; then
    STATIC_DIR=$(find $APP_DIR -name "static" -type d 2>/dev/null | grep -v plotly | head -1)
fi
if [ -z "$STATIC_DIR" ]; then
    # Create a static directory in the EMHASS package
    EMHASS_PKG=$(find $APP_DIR -name "emhass" -type d | grep -E "(site-packages|dist-packages)" | head -1)
    if [ -n "$EMHASS_PKG" ]; then
        STATIC_DIR="$EMHASS_PKG/static"
        mkdir -p "$STATIC_DIR"
        echo "📁 Created static directory: $STATIC_DIR"
    fi
fi
if [ -z "$STATIC_DIR" ]; then
    echo "❌ Static directory not found"
    exit 1
fi

echo "📁 Found static directory: $STATIC_DIR"

# Copy EV configuration extension to static directory
if [ -f "/app/ev_config_extension.js" ]; then
    cp /app/ev_config_extension.js "$STATIC_DIR/"
    echo "✅ EV configuration extension copied to static directory"
fi

# Copy the simpler EV configuration interface
if [ -f "/app/ev_config_simple.js" ]; then
    cp /app/ev_config_simple.js "$STATIC_DIR/"
    echo "✅ EV simple configuration interface copied to static directory"
fi

# Find the templates directory (prioritize EMHASS templates)
TEMPLATES_DIR=$(find $APP_DIR -path "*/emhass/templates" -type d 2>/dev/null | head -1)
if [ -z "$TEMPLATES_DIR" ]; then
    TEMPLATES_DIR=$(find $APP_DIR -name "templates" -type d 2>/dev/null | grep -v plotly | head -1)
fi
if [ -n "$TEMPLATES_DIR" ]; then
    echo "📁 Found templates directory: $TEMPLATES_DIR"
    
    # Check if configuration.html exists
    if [ -f "$TEMPLATES_DIR/configuration.html" ]; then
        echo "🔧 Modifying configuration.html to include EV extension..."
        
        # Create a backup
        cp "$TEMPLATES_DIR/configuration.html" "$TEMPLATES_DIR/configuration.html.backup"
        
        # Add EV extension script to the configuration page
        sed -i '/<\/body>/i \
<!-- EV Configuration Extension -->\
<script src="{{ url_for('\''static'\'', filename='\''ev_config_extension.js'\'') }}"></script>' "$TEMPLATES_DIR/configuration.html"
        
        echo "✅ Configuration page modified to include EV extension"
        
        # Also copy the standalone EV configuration page
        if [ -f "/app/ev_configuration.html" ]; then
            cp /app/ev_configuration.html "$TEMPLATES_DIR/"
            echo "✅ Standalone EV configuration page added"
        fi
    else
        echo "⚠️  Configuration template not found, EV extension will be loaded via other means"
    fi
else
    echo "⚠️  Templates directory not found"
fi

# Create a custom index extension that loads the EV config
cat > "$STATIC_DIR/ev_loader.js" << 'EOF'
// EV Configuration Loader
// This script ensures the EV configuration extension is loaded on all pages

(function() {
    'use strict';
    
    // Load EV configuration interface (using the simpler approach)
    function loadEVInterface() {
        if (!document.querySelector('#ev-config-panel')) {
            const script = document.createElement('script');
            script.src = '/static/ev_config_simple.js';
            script.onload = function() {
                console.log('EV Configuration Interface loaded successfully');
            };
            script.onerror = function() {
                console.error('Failed to load EV Configuration Interface, trying fallback...');
                // Try the original extension as fallback
                const fallbackScript = document.createElement('script');
                fallbackScript.src = '/static/ev_config_extension.js';
                document.head.appendChild(fallbackScript);
            };
            document.head.appendChild(script);
        }
    }
    
    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', function() {
            setTimeout(loadEVInterface, 1000);
        });
    } else {
        setTimeout(loadEVInterface, 1000);
    }
    
    // Also try on page navigation (for SPAs)
    window.addEventListener('popstate', function() {
        setTimeout(loadEVInterface, 500);
    });
    
})();
EOF

echo "✅ EV loader script created"

# Modify any existing HTML files to include the EV loader
for html_file in $(find $TEMPLATES_DIR -name "*.html" 2>/dev/null || true); do
    if [ -f "$html_file" ] && ! grep -q "ev_loader.js" "$html_file"; then
        # Add EV loader to the head section
        sed -i '/<head>/a \
<!-- EV Configuration Loader -->\
<script src="{{ url_for('\''static'\'', filename='\''ev_loader.js'\'') }}"></script>' "$html_file"
        echo "✅ Added EV loader to $(basename $html_file)"
    fi
done

echo "🎉 EV Configuration Web Extension setup complete!"