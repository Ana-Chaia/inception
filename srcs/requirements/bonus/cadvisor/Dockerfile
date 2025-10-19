FROM debian:bullseye

# Update packages and install wget
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y wget && rm -rf /var/lib/apt/lists/*

# Download cAdvisor version v0.49.1 from GitHub releases, that works with Debian Buster
RUN wget -O /usr/bin/cadvisor https://github.com/google/cadvisor/releases/download/v0.49.1/cadvisor-v0.49.1-linux-amd64

# Make the downloaded file executable
RUN chmod +x /usr/bin/cadvisor

# Expose port 8080
EXPOSE 8080

# Set the default command to start cAdvisor
CMD ["/usr/bin/cadvisor"]