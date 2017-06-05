FROM debian:jessie

RUN apt-get update

RUN apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev unzip

RUN apt-get install -y curl wget

ENV BUILD_DIR=/tmp/nginx-pagespeed

ENV NPS_VERSION=1.11.33.3

RUN mkdir -p ${BUILD_DIR} && \
  cd ${BUILD_DIR} && \
  curl --silent -L https://github.com/pagespeed/ngx_pagespeed/archive/v${NPS_VERSION}-beta.tar.gz | tar -xvzf - && \
  cd ${BUILD_DIR}/ngx_pagespeed-* && \
  PSOL_URL=https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
  curl --silent -L ${PSOL_URL} | tar -xvzf -

RUN cat /etc/apt/sources.list

RUN \
  echo "deb-src  http://deb.debian.org/debian jessie main" >> /etc/apt/sources.list && \
  echo "deb-src  http://deb.debian.org/debian jessie-updates main" >> /etc/apt/sources.list && \
  echo "deb-src http://security.debian.org/ jessie/updates main" >> /etc/apt/sources.list && \
  apt-get update

ENV NGINX_VERSION=1.6.2

RUN mkdir -p ${BUILD_DIR}/nginx && cd ${BUILD_DIR}/nginx && \
  apt-get -y build-dep nginx && \
  apt-get -y source nginx && \
  ln -s ${BUILD_DIR}/ngx_pagespeed-${NPS_VERSION}-beta nginx-${NGINX_VERSION}/debian/modules/ngx_pagespeed

COPY debian/rules ${BUILD_DIR}/nginx/nginx-${NGINX_VERSION}/debian/

RUN cd ${BUILD_DIR}/nginx/nginx-${NGINX_VERSION} && \
 dpkg-buildpackage -b

RUN cd ${BUILD_DIR}/nginx && \
  apt-get install -y init-system-helpers && \
  dpkg -i nginx-common_${NGINX_VERSION}-*_all.deb nginx-light_${NGINX_VERSION}-*_amd64.deb
