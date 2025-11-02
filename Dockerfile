# Using Debian 13 (Unstable)
FROM debian:unstable

# Metadata
LABEL maintainer="avidei"
LABEL version="1.0"
LABEL description="Debian + SSH + Ansible container patched for CVE-2025-59375 & CVE-2025-43859"

# Install core packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    tree \
    python3 \
    python3-venv \
    python3-pip \
    ansible \
    sshpass \
    openssh-server \
    openssh-client \
    rsyslog 

# Redirect rsyslog to stdout
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf && \
    echo '*.* /dev/stdout' > /etc/rsyslog.d/50-default.conf
    
# --- CVE-2025-43859: Update h11 ---
RUN /usr/bin/python3 -m pip install --no-cache-dir --upgrade "h11>=0.16.0" --break-system-packages

# Make python and pip point to python3
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip 

# Create user with home directory
RUN useradd -m -s /bin/bash avidei && \
    echo "avidei:avidei" | chpasswd && \
    usermod -aG sudo avidei

# Enable password login for SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Disable AcceptEnv in SSH (locale fix)
RUN sed -i 's/^AcceptEnv/#AcceptEnv/' /etc/ssh/sshd_config

# Fix permissions for SSH
RUN chmod 700 /var/run/sshd

# Expose SSH port
EXPOSE 22/tcp

# Run rsyslog + sshd
CMD ["/bin/bash", "-c", "rsyslogd && /usr/sbin/sshd -D"]
