# EMHASS EV Extension Add-on
# Uses the original EMHASS image and adds EV functionality via configuration

# Start from the working original EMHASS image  
FROM ghcr.io/davidusb-geek/emhass:latest

# Set environment variables for EV extension
ENV EMHASS_PORT="5003"
ENV EMHASS_CONFIG_PATH="/share/emhass-ev"
ENV EMHASS_DATA_PATH="/share/emhass-ev"

# Copy our custom run script
COPY run.sh /run.sh
RUN chmod +x /run.sh

# The EV functionality will be handled via configuration and API calls
# This allows us to use the stable base image while adding EV capabilities

ENTRYPOINT ["/run.sh"]