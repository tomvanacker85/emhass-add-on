# EMHASS EV Extension Add-on
# Uses the original EMHASS image with EV enhancements

FROM ghcr.io/davidusb-geek/emhass:latest

# Set EV-specific environment variables
ENV EMHASS_PORT="5003"
ENV EMHASS_CONFIG_PATH="/share/emhass-ev"
ENV EMHASS_DATA_PATH="/share/emhass-ev"

# Create EV data directory
RUN mkdir -p /share/emhass-ev

# Copy EV-specific configuration files
COPY config_defaults_ev.json /app/config_defaults_ev.json
COPY ev_config_extension.js /app/ev_config_extension.js
COPY ev_config_simple.js /app/ev_config_simple.js
COPY ev_configuration.html /app/ev_configuration.html
COPY setup_ev_enhanced.sh /app/setup_ev_enhanced.sh
COPY fix_dst_issues.py /app/fix_dst_issues.py
COPY fix_dst_issues.sh /app/fix_dst_issues.sh

# Copy custom startup script
COPY run.sh /run.sh
RUN chmod +x /run.sh
RUN chmod +x /app/setup_ev_enhanced.sh
RUN chmod +x /app/fix_dst_issues.sh

ENTRYPOINT ["/run.sh"]