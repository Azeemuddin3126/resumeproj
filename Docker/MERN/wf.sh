sudo apt update
sudo apt install certbot python3-certbot-nginx


sudo certbot --nginx -d example.com -d www.example.com

cp /etc/letsencrypt/live/example.com/fullchain.pem nginx/certs/server.crt
cp /etc/letsencrypt/live/example.com/privkey.pem nginx/certs/server.key

# server {
#     listen 443 ssl;
#     server_name example.com;

#     ssl_certificate /path/to/nginx/certs/server.crt;
#     ssl_certificate_key /path/to/nginx/certs/server.key;

#     # Other configuration options
# }
