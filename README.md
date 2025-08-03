# DNSPro - Smart DNS Proxy

DNSPro is a smart DNS-based proxy solution designed specifically to **bypass geographic restrictions and sanctions**, allowing access to geo-blocked content and services without the need for a full VPN. It transparently routes traffic of selected domains through your own server using `sniproxy`, `dnsmasq`, and `nginx`.

> ⚠️ **Note:** This service is intended to bypass **geo-blocking and sanctions** only. It is **not** designed for circumventing national censorship or filtering systems.

---

## 🚀 Installation

Run these commands on a fresh Ubuntu (20.04/22.04) or AlmaLinux (8/9) server with root privileges:

```bash
wget -O dns-installer.sh https://raw.githubusercontent.com/MrAriaNet/DNSPro-SmartDNSProxy/main/dns-installer.sh
chmod +x dns-installer.sh
./dns-installer.sh
````

The installer will:

* Detect your Linux distribution
* Install all necessary dependencies
* Compile and install `sniproxy`
* Configure `sniproxy`, `dnsmasq`, and `nginx`
* Enable and start all required services

---

## ⚙️ Configuration and Usage

### 1. Define domain redirection

To specify which domains should be proxied, create or edit a configuration file in `/etc/dnsmasq.d/`. For example:

```ini
address=/.example.com/your_server_ip
```

* Replace `example.com` with the domain(s) you want to proxy
* Replace `your_server_ip` with your server's public IP address

This tells `dnsmasq` to resolve those domains to your server IP, so traffic to those domains gets routed through your proxy.

---

### 2. Apply the custom NGINX configuration

Replace the default NGINX configuration with the project’s custom config to correctly handle HTTP and HTTPS traffic:

```bash
curl -fsSL -o /etc/nginx/nginx.conf https://raw.githubusercontent.com/MrAriaNet/DNSPro-SmartDNSProxy/main/nginx/nginx.conf
systemctl restart nginx
```

---

### 3. Restart proxy services

After making changes, restart the related services to apply new settings:

```bash
systemctl restart sniproxy
systemctl restart dnsmasq
```

---

## 🔧 Troubleshooting & Notes

* The proxy works only for TLS-enabled services that use **SNI (Server Name Indication)**, e.g., HTTPS websites.

* Ensure your firewall allows inbound traffic on ports **80** (HTTP) and **443** (HTTPS).

* If you experience connectivity issues, try restarting the services above.

* You can test your proxy with:

  ```bash
  curl -v https://example.com --resolve example.com:443:your_server_ip
  ```

* Logs for `sniproxy` are available at `/var/log/sniproxy.log` (depending on systemd setup).

* For complex domain setups, add multiple `address=/.domain.com/ip` lines in `/etc/dnsmasq.d/`.

---

## 👤 Author

Developed and maintained by [Aria Jahangiri Far](https://github.com/MrAriaNet)

---

## 📄 License

MIT License – Free to use, modify, and distribute.

---

## 📌 Disclaimer

This software is provided **as-is**. Use responsibly and in accordance with your local laws and regulations. The author is not responsible for any misuse or legal consequences.
