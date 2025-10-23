# EMHASS EV Extension Add-on
# Uses the original EMHASS image with EV enhancements

FROM ghcr.io/davidusb-geek/emhass:latest

# Set EV-specific configuration
ENV EMHASS_PORT="5003"
ENV EMHASS_CONFIG_PATH="/share/emhass-ev"
ENV EMHASS_DATA_PATH="/share/emhass-ev"

# Copy custom run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# EV functionality will be provided via configuration and API
# This maintains compatibility while adding EV capabilities

ENTRYPOINT ["/run.sh"]