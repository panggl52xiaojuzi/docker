FROM centos:centos7

LABEL maintainer="Michael <michael@foxmail.com>"

ENV NGINX_VERSION 1.15.2

RUN CONFIG="\

        --prefix=/usr/share/nginx \

        --sbin-path=/usr/sbin/nginx \

        --modules-path=/usr/lib64/nginx/modules \

        --conf-path=/etc/nginx/nginx.conf \

        --error-log-path=/var/log/nginx/error.log \

        --http-log-path=/var/log/nginx/access.log \

        --http-client-body-temp-path=/var/lib/nginx/tmp/client_body \

        --http-proxy-temp-path=/var/lib/nginx/tmp/proxy \

        --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi \

        --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi \

        --http-scgi-temp-path=/var/lib/nginx/tmp/scgi \

        --pid-path=/run/nginx.pid \

        --lock-path=/run/lock/subsys/nginx \

        --user=nginx \

        --group=nginx \

        --with-file-aio \

        --with-ipv6 \

        --with-http_auth_request_module \

        --with-http_ssl_module \

        --with-http_v2_module \

        --with-http_realip_module \

        --with-http_addition_module \

        --with-http_xslt_module=dynamic \

        --with-http_image_filter_module=dynamic \

        --with-http_geoip_module=dynamic \

        --with-http_sub_module \

        --with-http_dav_module \

        --with-http_flv_module \

        --with-http_mp4_module \

        --with-http_gunzip_module \

        --with-http_gzip_static_module \

        --with-http_random_index_module \

        --with-http_secure_link_module \

        --with-http_degradation_module \

        --with-http_slice_module \

        --with-http_stub_status_module \

        --with-http_perl_module=dynamic \

        --with-mail=dynamic \

        --with-mail_ssl_module \

        --with-pcre \

        --with-pcre-jit \

        --with-stream=dynamic \

        --with-stream_ssl_module \

        --with-google_perftools_module \

        --with-debug \

        --with-ld-opt='-Wl,-E' \

          " \

        && groupadd -g 2019 nginx  \

        && useradd -u 2019 -g 2019 -s /sbin/nologin nginx \

        && yum -y install \

                gcc \

                make \

                perl \

                openssl \

                openssl-devel \

                pcre-devel \

                gd-devel \

                zlib-devel \

                GeoIP-devel \

                libxslt-devel \

                perl-ExtUtils-Embed \

                gperftools \

                curl  \

        && curl -fSL https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \

        && mkdir -p /var/lib/nginx/tmp/{client_body,proxy,fastcgi,uwsgi,scgi} \

        && mkdir -p /usr/src \

        && tar -zxC /usr/src -f nginx.tar.gz \

        && rm -f nginx.tar.gz \

        && cd /usr/src/nginx-$NGINX_VERSION \

        && ./configure $CONFIG  \

        && make -j$(getconf _NPROCESSORS_ONLN) \

        && make install \

        && mkdir -p /etc/nginx/conf.d /usr/share/nginx/html \

        && rm -rf /usr/src/nginx-$NGINX_VERSION \

        && for rpm in make gcc openssl-devel pcre-devel gd-devel zlib-devel GeoIP-devel libxslt-devel curl; do rpm -e ${rpm} --nodeps; done \

        && rm -rf /var/cache/yum/* \

        # forward request and error logs to docker log collector

        && ln -sf /dev/stdout /var/log/nginx/access.log \

        && ln -sf /dev/stderr /var/log/nginx/error.log

STOPSIGNAL SIGTERM
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
