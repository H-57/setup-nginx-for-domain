
# setup domain for your project in nginx

just copy cammand and run it can automatically install nginx and run setup nginx config

```bash
 sudo bash -c "$(curl -fsSL 'https://raw.githubusercontent.com/H-57/setup-nginx-for-domain/main/script.sh?'$(date +%s))"
```
than it ask for domain name just enter like "yourdomain.com"
and then your souce "http://localhost:port"

like this :-

Enter the domain name: bugslayer.in

Enter the source (proxy_pass, e.g., http://localhost:3000): http://localhost:3000
