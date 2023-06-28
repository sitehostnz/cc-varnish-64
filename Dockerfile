FROM ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Pacific/Auckland

RUN apt-get update \
    && apt-get install -y curl apt-transport-https debian-archive-keyring nano supervisor openssh-client rsync gnupg \
    && apt-get install -y make automake autotools-dev libedit-dev libjemalloc-dev libncurses-dev libpcre3-dev libtool pkg-config python3-docutils python3-sphinx cpio autoconf-archive  \
    && cd /tmp \
    && curl -sL https://varnish-cache.org/_downloads/varnish-6.4.0.tgz | tar zxvf - \
    && cd varnish-6.4.0 \
    && ./configure \
    && make \
    && make install \
    && cd /tmp \
    && curl -sL https://github.com/varnish/varnish-modules/releases/download/0.16.0/varnish-modules-0.16.0.tar.gz | tar zxvf - \
    && cd varnish-modules-0.16.0 \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/varnish-6.4.0 \
    && rm -rf /tmp/varnish-modules-0.16.0 \
    && rm -rf /var/lib/apt/lists/* \
    ### SiteHost standards
    && mkdir -p /container/config \
    && mkdir /container/logs \
    && userdel www-data \
    && groupadd -g 33 varnish \
    && useradd -s /bin/false -M -u 33 -g varnish varnish \
    && rm -rf /etc/varnish \
    && rm -rf /etc/supervisor \
    && mkdir -p /etc/supervisor/conf.d \
    && ln -s /container/config/supervisord.conf /etc/supervisor/supervisord.conf \
    && ln -s /etc/varnish /container/config/varnish \
    && chown -R 33:33 /usr/local/lib/varnish \
    && ln -s /usr/local/var/varnish /container/varnish \
    && chown -R 33:33 /usr/local/var/varnish \
    && ln -s /usr/local/sbin/varnishd /usr/sbin/varnishd \
    && ln -s /usr/local/bin/varnishncsa /usr/bin/varnishncsa \
    && ldconfig

EXPOSE 80

ENTRYPOINT ["/usr/bin/supervisord", "-c", "/container/config/supervisor/supervisord.conf"]
