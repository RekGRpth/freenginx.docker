FROM ghcr.io/rekgrpth/freenginx.docker:latest
ADD bin /usr/local/bin
ADD NimbusSans-Regular.ttf /usr/local/share/fonts/
CMD [ "nginx" ]
ENV GROUP=nginx \
    HOME=/var/cache/nginx \
    USER=nginx
STOPSIGNAL SIGQUIT
WORKDIR "$HOME"
RUN set -eux; \
    chmod +x /usr/local/bin/*.sh; \
    apk update --no-cache; \
    apk upgrade --no-cache; \
    apk add --no-cache --virtual .build \
        curl \
        git \
        libbsd-dev \
        perl-lwp-protocol-https \
        perl-test-nginx \
        perl-utils \
        postgresql \
        valgrind \
    ; \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing --virtual .edge \
        perl-test-file \
    ; \
    mkdir -p "$HOME/src"; \
    cd "$HOME/src"; \
    git clone -b default https://github.com/RekGRpth/freenginx.git; \
    mkdir -p "$HOME/src/freenginx/modules"; \
    cd "$HOME/src/freenginx/modules"; \
    git clone -b main https://github.com/RekGRpth/nginx-ejwt-module.git; \
    git clone -b main https://github.com/RekGRpth/ngx_http_error_page_inherit_module.git; \
    git clone -b main https://github.com/RekGRpth/ngx_http_include_server_module.git; \
    git clone -b main https://github.com/RekGRpth/ngx_http_json_var_module.git; \
    git clone -b main https://github.com/RekGRpth/ngx_pq_module.git; \
    git clone -b master https://github.com/RekGRpth/echo-nginx-module.git; \
    git clone -b master https://github.com/RekGRpth/encrypted-session-nginx-module.git; \
    git clone -b master https://github.com/RekGRpth/form-input-nginx-module.git; \
    git clone -b master https://github.com/RekGRpth/headers-more-nginx-module.git; \
    git clone -b master https://github.com/RekGRpth/iconv-nginx-module.git; \
    git clone -b master https://github.com/RekGRpth/nginx_csrf_prevent.git; \
    git clone -b master https://github.com/RekGRpth/nginx-push-stream-module.git; \
#    git clone -b master https://github.com/RekGRpth/nginx-upload-module.git; \
    git clone -b master https://github.com/RekGRpth/nginx-upstream-fair.git; \
    git clone -b master https://github.com/RekGRpth/nginx-uuid4-module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_brotli.git; \
    git clone -b master https://github.com/RekGRpth/ngx_devel_kit.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_auth_basic_ldap_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_auth_pam_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_captcha_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_evaluate_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_headers_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_htmldoc_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_json_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_mustach_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_remote_passwd.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_response_body_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_sign_module.git; \
#    git clone -b master https://github.com/RekGRpth/ngx_http_substitutions_filter_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_time_var_module.git; \
    git clone -b master https://github.com/RekGRpth/ngx_http_zip_var_module.git; \
    git clone -b master https://github.com/RekGRpth/set-misc-nginx-module.git; \
    install -d -m 1775 -o postgres -g postgres /run/postgresql /var/log/postgresql; \
    gosu postgres initdb --auth=trust --encoding=UTF8 --pgdata=/var/lib/postgresql/data; \
    gosu postgres pg_ctl -w start --pgdata=/var/lib/postgresql/data; \
    cd "$HOME"; \
    find "$HOME/src/freenginx/modules" -type d -name "t" | grep -v "\.git" | sort | while read -r NAME; do cd "$(dirname "$NAME")" && prove; done; \
    gosu postgres pg_ctl -m fast -w stop --pgdata=/var/lib/postgresql/data; \
    cd /; \
    apk add --no-cache --virtual .nginx \
        apache2-utils \
        $(scanelf --needed --nobanner --format '%n#p' --recursive /usr/local | tr ',' '\n' | grep -v "^$" | sort -u | while read -r lib; do test -z "$(find /usr/local/lib -name "$lib")" && echo "so:$lib"; done) \
    ; \
    find /usr/local/bin -type f -exec strip '{}' \;; \
    find /usr/local/lib -type f -name "*.so" -exec strip '{}' \;; \
    apk del --no-cache .build; \
    apk del --no-cache .edge; \
    rm -rf "$HOME" /usr/share/doc /usr/share/man /usr/local/share/doc /usr/local/share/man; \
    find /usr -type f -name "*.la" -delete; \
    mkdir -p "$HOME"; \
    chown -R "$USER":"$GROUP" "$HOME"; \
    install -d -m 0700 -o "$USER" -g "$GROUP" /var/tmp/nginx; \
    echo done
