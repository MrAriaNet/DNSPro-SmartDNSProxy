## DNSPro - Smart DNS Proxy

This script is for bypassing some restrictions that reduce the need for VPN

## How to install script

```bash
wget -O dns-installer.sh https://raw.githubusercontent.com/MrAriaNet/DNSPro-SmartDNSProxy/main/dns-installer.sh
chmod +x dns-installer.sh
sh dns-installer.sh
```

## How to use script

After installing the script, you need to raw the configuration file of the NGINX web server and put the settings file in the following address.

```
https://raw.githubusercontent.com/MrAriaNet/DNSPro-SmartDNSProxy/main/nginx/nginx.conf
```

Then create an sniproxy.conf file in path /etc/dnsmasq.d/ and enter the desired site address with the IP server

```
address=/.google.com/ipserver
```

Save your changes and restart the required services for the changes to take effect.

```
systemctl restart sniproxy
systemctl restart dnsmasq
systemctl restart nginx
```

## Attention

Sometimes your server may not respond properly, You will need to restart the service to resolve this issue.

## Author

[Aria](https://github.com/MrAriaNet)
