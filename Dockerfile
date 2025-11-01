# Using Debian 13 (Trixie Backports)
FROM debian:trixie-backports

# Metadata
LABEL maintainer="avidei"
LABEL version="1.0"
LABEL description="Debian + SSH + Ansible container"

# Install core packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    nano \
    python3 \
    python3-venv \
    python3-pip \
    ansible \
    sshpass \
    openssh-server \
    openssh-client \
    rsyslog \
    wget \
    build-essential \
    binutils

# Make python and pip point to python3
RUN ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip 

# --- CVE-2025-43859: Update h11 ---
RUN /usr/bin/python3 -m pip install --no-cache-dir --upgrade "h11>=0.16.0" --break-system-packages

# --- CVE-2025-59375: Update libexpat ---
RUN apt-get remove -y libexpat1 libexpat1-dev || true && \
    wget https://github.com/libexpat/libexpat/releases/download/R_2_7_2/expat-2.7.2.tar.gz && \
    tar -xzf expat-2.7.2.tar.gz && \
    cd expat-2.7.2 && \
    ./configure --prefix=/usr && \
    make -j"$(nproc)" && make install && \
    ldconfig && \
    cd .. && rm -rf expat-2.7.2 expat-2.7.2.tar.gz && \
    strings /usr/lib/x86_64-linux-gnu/libexpat.so.1 2>/dev/null || strings /usr/local/lib/libexpat.so.1 | grep "expat_2.7.2" || echo "expat not updated!"

# Disable AcceptEnv in SSH (locale fix)
RUN sed -i 's/^AcceptEnv/#AcceptEnv/' /etc/ssh/sshd_config

# Redirect rsyslog to stdout
RUN sed -i '/imklog/s/^/#/' /etc/rsyslog.conf && \
    echo '*.* /dev/stdout' > /etc/rsyslog.d/50-default.conf

# Fix permissions for SSH
RUN chmod 700 /var/run/sshd

# Create user with home directory
RUN useradd -m -s /bin/bash avidei && \
    echo "avidei:avidei" | chpasswd && \
    usermod -aG sudo avidei

# Enable password login for SSH
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Remove build tools to reduce size
RUN apt-get remove -y build-essential binutils wget && \
    apt-get autoremove -y && apt-get clean

# Expose SSH port
EXPOSE 22/tcp

# Run rsyslog + sshd
CMD ["/bin/bash", "-c", "rsyslogd && /usr/sbin/sshd -D"]
