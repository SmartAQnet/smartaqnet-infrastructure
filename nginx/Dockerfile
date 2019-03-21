FROM nginx:alpine
COPY dashboard/content /var/www/html
COPY default.conf /etc/nginx/conf.d/default.conf
CMD ["nginx", "-g", "daemon off;"]
