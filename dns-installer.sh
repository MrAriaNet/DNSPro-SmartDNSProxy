#!/bin/bash

# DNSPro - Smart DNS Proxy
# write by : @MrAriaNet

if [ ! -f /etc/dnsmasq.d/sniproxy.conf ]; then
	echo -e "- Installation started ...\n";
	sleep 2;

	# EPEL Install
	echo "EPEL installation started.";
	yum -y install epel-release > /dev/null 2>&1;
	echo -e "EPEL were installed.\n";
	sleep 2;

	# Prerequisites Install
	echo "Installation of pre-requisites started.";
	yum -y install autoconf automake curl gettext gettext-devel libev libev-devel pcre pcre-devel perl pkgconfig rpm-build udns udns-devel devscripts zsh git > /dev/null 2>&1;
	echo -e "Prerequisites were installed.\n";
	sleep 2;

	# Development Tools Install
	echo "Development-Tools installation started.";
	yum -y groupinstall "Development Tools" > /dev/null 2>&1;
	echo -e "Development-Tools were installed.\n";
	sleep 2;

	# git clone sniproxy
	echo "SNIProxy installation started.";
	git clone http://github.com/dlundquist/sniproxy.git > /dev/null 2>&1;
	echo -e "SNIProxy were installed.\n";
	sleep 2;

	# make sniproxy
	echo "SNIProxy is generate installer started.";
	cd sniproxy && ./autogen.sh && ./configure && make dist > /dev/null 2>&1;
	echo -e "SNIProxy is generate and completed successfully.\n";
	sleep 2;

	# rpmbuild sniproxy
	rpmbuild --define "_sourcedir `pwd`" -ba redhat/sniproxy.spec > /dev/null 2>&1;
	echo -e "RPM Build completed successfully.\n";
	sleep 2;

	# sniproxy install
	yum -y install /root/rpmbuild/RPMS/x86_64/sniproxy-*.el7.x86_64.rpm > /dev/null 2>&1;
	echo "SNIProxy were installed.";
	sleep 2;

	# create config file sniproxy
	touch /etc/sniproxy.conf > /dev/null 2>&1;
	cat << EOF > /etc/sniproxy.conf
	user daemon

pidfile /var/run/sniproxy.pid

resolver {
        nameserver 1.1.1.1
        nameserver 8.8.8.8
        mode ipv4_only
}

#listener 80 {
#       proto http
#}

listener 443 {
        proto tls
}

table {
        .* *
}
EOF
	echo "Generate SNIProxy config file successfully.";
	sleep 2;

	# create service file sniproxy
	touch /usr/lib/systemd/system/sniproxy.service > /dev/null 2>&1;
	cat << EOF > /usr/lib/systemd/system/sniproxy.service
	[Unit]
Description=SNI Proxy Service
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/sniproxy -c /etc/sniproxy.conf

[Install]
WantedBy=multi-user.target
EOF
	echo -e "Generate SNIProxy Service file successfully.\n";
	sleep 2;

	# dnsmasq install
	yum -y install dnsmasq > /dev/null 2>&1;
	echo "DNSMasq is installed.";
	sleep 2;

	# create config file dnsmasq
	echo "" > /etc/dnsmasq.conf > /dev/null 2>&1;
	cat << EOF > /etc/dnsmasq.conf
	conf-dir=/etc/dnsmasq.d/,*.conf
cache-size=100000
no-resolv
server=1.1.1.1
server=8.8.8.8
interface=eth0
interface=lo
EOF
	echo "Generate DNSMasq config file successfully.\n";
	sleep 2;

	# NGINX Install
	echo "NGINX installation started.";
	yum -y install nginx > /dev/null 2>&1;
	echo -e "NGINX were installed.\n";
	sleep 2;

	systemctl enable sniproxy && systemctl enable dnsmasq && systemctl enable nginx > /dev/null 2>&1;
	systemctl start sniproxy && systemctl start dnsmasq && systemctl start nginx > /dev/null 2>&1;

	echo "- Installation completed successfully ...";
else
	echo -e "- Smart DNS is installed on the server.\n";
	echo "Update server is started.";
	yum -y update > /dev/null 2>&1;
	echo "Update completed successfully.";
	sleep 2;
fi
