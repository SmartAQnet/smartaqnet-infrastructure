FROM nginx:alpine
COPY dashboard/content /var/www/html
COPY default.conf /etc/nginx/conf.d/default.conf
ADD https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/options-ssl-nginx.conf /etc/nginx/options-ssl-nginx.conf 
ADD https://raw.githubusercontent.com/certbot/certbot/master/certbot/ssl-dhparams.pem /etc/nginx/ssl-dhparams.pem
CMD ["nginx", "-g", "daemon off;"]
