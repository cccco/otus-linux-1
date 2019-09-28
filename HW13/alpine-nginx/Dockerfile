FROM alpine:3.10

RUN apk add nginx

# create pid directory
RUN mkdir -p /run/nginx && chown nginx:nginx /run/nginx 

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# change default index.html
COPY index.html /var/lib/nginx/html/

# default nginx return 404 only
COPY default.conf /etc/nginx/conf.d/

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]

