#!/usr/bin/env bash
# DNSPro SmartDNSProxy Installer
# Compatible with: Ubuntu 20.04+/22.04+, AlmaLinux 8+/9+
# Author: AriaNet - https://github.com/MrAriaNet

set -euo pipefail

# Color output for clarity
green() { echo -e "\e[32m$1\e[0m"; }
red() { echo -e "\e[31m$1\e[0m"; }

# OS detection
detect_os() {
    source /etc/os-release
    OS=$ID
    VER=$VERSION_ID

    if [[ "$OS" =~ ^(ubuntu|debian)$ ]]; then
        PACKAGE_MANAGER="apt"
    elif [[ "$OS" =~ ^(almalinux|centos|rhel)$ ]]; then
        PACKAGE_MANAGER="dnf"
    else
        red "Unsupported OS: $OS"
        exit 1
    fi
}

# Install required packages
install_dependencies() {
    green "[*] Installing required packages..."
    if [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        apt update -y
        apt install -y curl git build-essential autoconf automake libtool pkg-config \
                       libev-dev libudns-dev zlib1g-dev libpcre3-dev nginx dnsmasq
    else
        dnf install -y epel-release
        dnf groupinstall -y "Development Tools"
        dnf install -y curl git autoconf automake libtool pkgconfig libev-devel udns-devel \
                       zlib-devel pcre-devel nginx dnsmasq
    fi
}

# Compile and install sniproxy
install_sniproxy() {
    green "[*] Cloning and installing sniproxy..."
    git clone https://github.com/dlundquist/sniproxy.git /tmp/sniproxy
    cd /tmp/sniproxy
    ./autogen.sh
    ./configure
    make -j"$(nproc)"
    make install
    cd -
    rm -rf /tmp/sniproxy
}

# Create sniproxy config
create_sniproxy_config() {
    green "[*] Creating sniproxy config..."
    cat <<EOF > /etc/sniproxy.conf
user daemon
pidfile /var/run/sniproxy.pid

resolver {
    nameserver 1.1.1.1
    nameserver 8.8.8.8
    mode ipv4_only
}

listener 443 {
    proto tls
}

table {
    .* *
}
EOF
}

# Create sniproxy systemd service
create_sniproxy_service() {
    green "[*] Creating systemd service for sniproxy..."
    cat <<EOF > /etc/systemd/system/sniproxy.service
[Unit]
Description=SNI Proxy Service
After=network.target

[Service]
ExecStart=/usr/local/sbin/sniproxy -c /etc/sniproxy.conf
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
}

# Configure DNSMasq
configure_dnsmasq() {
    green "[*] Configuring dnsmasq..."
    cat <<EOF > /etc/dnsmasq.conf
conf-dir=/etc/dnsmasq.d/,*.conf
cache-size=100000
no-resolv
server=1.1.1.1
server=8.8.8.8
interface=lo
EOF
}

# Download and apply nginx config
configure_nginx() {
    green "[*] Downloading nginx config..."
    curl -fsSL -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/MrAriaNet/DNSPro-SmartDNSProxy/main/nginx/nginx.conf
}

# Start and enable services
enable_services() {
    green "[*] Enabling and starting services..."
    systemctl daemon-reexec
    systemctl daemon-reload
    systemctl enable --now sniproxy dnsmasq nginx
    systemctl restart sniproxy dnsmasq nginx
}

main() {
    detect_os
    install_dependencies
    install_sniproxy
    create_sniproxy_config
    create_sniproxy_service
    configure_dnsmasq
    configure_nginx
    enable_services
    green "[✔] DNSPro SmartDNSProxy installation completed successfully!"
}

main "$@"
