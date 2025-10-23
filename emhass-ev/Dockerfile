# EMHASS EV Extension Add-on
# Uses the original EMHASS image with EV enhancements

FROM ghcr.io/davidusb-geek/emhass:latest

# Set EV-specific configuration
ENV EMHASS_PORT="5003"
ENV EMHASS_CONFIG_PATH="/share/emhass-ev"
ENV EMHASS_DATA_PATH="/share/emhass-ev"

# Create the EV data directory
RUN mkdir -p /share/emhass-ev

# Copy custom run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# Use our custom run script that tries to find the original EMHASS startup
ENTRYPOINT ["/run.sh"]