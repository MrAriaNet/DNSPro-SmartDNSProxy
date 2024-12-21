#!/bin/bash

# DNSPro - Smart DNS Proxy
# write by : @MrAriaNet

# Detect package manager
if command -v dnf > /dev/null; then
    PACKAGE_MANAGER="dnf"
elif command -v yum > /dev/null; then
    PACKAGE_MANAGER="yum"
elif command -v apt > /dev/null; then
    PACKAGE_MANAGER="apt"
else
    echo "Unsupported package manager. Exiting."
    exit 1
fi

# Install function
install_packages() {
    if [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        apt update > /dev/null 2>&1
        apt install -y "$@" > /dev/null 2>&1
    else
        $PACKAGE_MANAGER install -y "$@" > /dev/null 2>&1
    fi
}

# Group install for development tools
install_dev_tools() {
    if [[ "$PACKAGE_MANAGER" == "dnf" || "$PACKAGE_MANAGER" == "yum" ]]; then
        $PACKAGE_MANAGER groupinstall -y "Development Tools" > /dev/null 2>&1
    elif [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        apt update > /dev/null 2>&1
        apt install -y build-essential > /dev/null 2>&1
    fi
}

if [ ! -f /etc/dnsmasq.d/sniproxy.conf ]; then
    echo -e "- Installation started ...\n";
    sleep 2;

    # Install prerequisites
    echo "Installing prerequisites...";
    install_packages autoconf automake curl gettext libev-dev libpcre3-dev perl pkg-config zlib1g-dev udns-dev zsh git dnsmasq nginx
    echo -e "Prerequisites installed.\n";
    sleep 2;

    # Install development tools
    echo "Installing development tools...";
    install_dev_tools
    echo -e "Development tools installed.\n";
    sleep 2;

    # Clone and build sniproxy
    echo "Cloning and building sniproxy...";
    git clone http://github.com/dlundquist/sniproxy.git > /dev/null 2>&1
    cd sniproxy || exit
    ./autogen.sh > /dev/null 2>&1
    ./configure > /dev/null 2>&1
    make > /dev/null 2>&1
    make install > /dev/null 2>&1
    echo -e "sniproxy built and installed successfully.\n";
    cd .. || exit
    sleep 2;

    # Create config file for sniproxy
    echo "Creating sniproxy configuration file...";
    cat << EOF > /etc/sniproxy.conf
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
    echo "sniproxy configuration file created.";
    sleep 2;

    # Create systemd service file for sniproxy
    echo "Creating systemd service file for sniproxy...";
    cat << EOF > /etc/systemd/system/sniproxy.service
[Unit]
Description=SNI Proxy Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/sbin/sniproxy -c /etc/sniproxy.conf

[Install]
WantedBy=multi-user.target
EOF
    echo "Systemd service file for sniproxy created.";
    sleep 2;

    # Configure dnsmasq
    echo "Configuring dnsmasq...";
    cat << EOF > /etc/dnsmasq.conf
conf-dir=/etc/dnsmasq.d/,*.conf
cache-size=100000
no-resolv
server=1.1.1.1
server=8.8.8.8
interface=eth0
interface=lo
EOF
    echo "dnsmasq configuration file created.";
    sleep 2;

    # Enable and start services
    echo "Enabling and starting services...";
	systemctl daemon-reload > /dev/null 2>&1
    systemctl enable sniproxy dnsmasq nginx > /dev/null 2>&1
    systemctl start sniproxy dnsmasq nginx > /dev/null 2>&1
    echo "All services started successfully.";

    echo "- Installation completed successfully.";
else
    echo -e "- Smart DNS is already installed on the server.\n";
    echo "Updating server packages...";
    if [[ "$PACKAGE_MANAGER" == "apt" ]]; then
        apt update && apt upgrade -y > /dev/null 2>&1
    else
        $PACKAGE_MANAGER update -y > /dev/null 2>&1
    fi
    echo "Server packages updated successfully.";
    sleep 2;
fi
