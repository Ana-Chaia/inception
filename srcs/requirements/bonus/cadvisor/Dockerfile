FROM debian:oldstable

# Update packages and install wget
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/bin/cadvisor https://github.com/google/cadvisor/releases/download/v0.53.0/cadvisor-v0.53.0-linux-amd64

# Make the downloaded file executable
RUN chmod +x /usr/bin/cadvisor

# Expose port 8080
EXPOSE 8080

# Set the default command to start cAdvisor
CMD ["/usr/bin/cadvisor"]