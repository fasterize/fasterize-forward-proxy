FROM        ubuntu:18.04
MAINTAINER  Anthony BARRE <a@fasterize.com>

WORKDIR /app

ADD sources.list /etc/apt/sources.list

RUN apt-get update; \
    apt-get install -y libfontconfig1; \
    apt-get install -y libpcre3; \
    apt-get install -y libpcre3-dev; \
    apt-get install -y git; \
    apt-get install -y dpkg-dev; \
    apt-get install -y libpng-dev; \
    apt-get autoclean && apt-get autoremove;

RUN cd /app && apt-get source nginx; \
    cd /app/ && git clone https://github.com/chobits/ngx_http_proxy_connect_module; \
    cd /app/nginx-* && patch -p1 < ../ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_1014.patch; \
    cd /app/nginx-* && ./configure --with-debug --add-module=/app/ngx_http_proxy_connect_module && make && make install;


ADD nginx.conf /usr/local/nginx/conf/nginx.conf

# forward request and error logs to docker log collector
RUN ln --symbolic --force /dev/stdout /var/log/nginx_access.log
RUN ln --symbolic --force /dev/stderr /var/log/nginx_error.log

EXPOSE 8888

CMD /usr/local/nginx/sbin/nginx
