# Using a Debian 13 image
FROM debian:trixie-backports

# Metadata
LABEL maintainer="avidei"
LABEL version="1.0"
LABEL description="Debian + SSH + Ansible container"

# Install the necessary packages

RUN apt-get update && apt-get install -y \
    curl \
    git \
    nano \
    python3\
    ansible\
    openssh-server\
    openssh-client\
    rsyslog

# Redirecting rsyslog to stdout
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf && \
    echo '*.* /dev/stdout' > /etc/rsyslog.d/50-default.conf

# Setting access rights for SSH service directory

RUN chmod 700 /var/run/sshd


# Create a group and user (with explicit UID/GID)
RUN groupadd -r avidei && useradd --no-log-init -r -g avidei avidei


# Set password for user 
RUN echo 'avidei:avidei' | chpasswd

# Allow login with a password
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Opened port 22 for SSH (FYI)
EXPOSE 22/tcp

# Start rsyslog daemon for collecting and storing logs
# and SSH server when the container launches (in the background)

CMD ["/bin/bash", "-c", "rsyslogd && /usr/sbin/sshd -D"]

