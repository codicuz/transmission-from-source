FROM centos:latest as base

RUN yum -y update \
  && yum -y install libevent iproute \
  && yum clean all \
  && rm -rfv /var/cache/yum

FROM base as builder

ARG TRANS_ARCH="transmission-2.94.tar.xz"
ARG TRANS_URL="https://github.com/transmission/transmission-releases/raw/master/$TRANS_ARCH"
ARG TRANS_ARCH_PATH="/opt/transmission.tar.xz"

RUN yum -y install gcc libcurl-devel libevent-devel zlib-devel openssl-devel intltool gcc-c++ make \
  && curl -L $TRANS_URL -o $TRANS_ARCH_PATH \
  && tar -C /opt -xvJf $TRANS_ARCH_PATH

WORKDIR /opt/transmission-2.94

RUN ./configure --prefix=/opt/transmission \
  && make \
  && make install \
  && tar -C /opt -cvzf /opt/transmission.tar.gz transmission

FROM base

LABEL description="Transmission-daemon"
LABEL maintainer="Codicus"

ADD scripts /opt/transmission
COPY --from=builder /opt/transmission.tar.gz /opt/transmission.tar.gz

RUN tar -C /opt -xvzf /opt/transmission.tar.gz

EXPOSE 3371

HEALTHCHECK --interval=60s --timeout=15s \
 CMD ss -lntp | grep 9091 > /dev/null; if [ 0 != $? ]; then exit 1; fi;

ENTRYPOINT ["/opt/transmission/start.sh"]