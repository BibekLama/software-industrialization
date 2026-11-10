FROM jenkins/jenkins:lts

# Switch to root to install system packages
USER root

# Install Docker CLI (for building images) AND libatomic1 (required by modern Node.js)
RUN apt-get update && \
    apt-get install -y docker.io libatomic1 && \
    rm -rf /var/lib/apt/lists/*

# Switch back to the jenkins user for security
USER jenkins