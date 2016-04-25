FROM alpine:3.3
MAINTAINER Nicolas Degory <ndegory@axway.com>

RUN apk --no-cache add python py-pip python-dev curl && \
    curl https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python && \
    pip install envtpl && \
    apk del py-pip python-dev curl openssl ca-certificates libssh2 libbz2 expat libffi gdbm

ENV INFLUXDB_VERSION 0.12.2

RUN export GOPATH=/go && \
    apk --no-cache add go git gcc musl-dev make && \
    go get github.com/influxdata/influxdb && \
    cd $GOPATH/src/github.com/influxdata/influxdb && \
    
    git checkout -q --detach "v${INFLUXDB_VERSION}" && \
    go get -u -f -t ./... && \
    #go clean ./... && \
    go install -v ./... && \
    chmod +x $GOPATH/bin/* && \
    mv $GOPATH/bin/* /bin/ && \
    apk del go git gcc musl-dev make binutils-libs binutils libatomic libgcc openssl libssh2 libstdc++ mpc1 isl gmp ca-certificates pkgconf pkgconfig mpfr3 && \
    rm -rf /var/cache/apk/* $GOPATH && \
    mkdir -p /etc/influxdb /data/influxdb /data/influxdb/meta /data/influxdb/data /var/tmp/influxdb/wal /var/log/influxdb

ADD types.db /usr/share/collectd/types.db
ADD config.toml /config/config.toml.tpl
ADD run.sh /run.sh
RUN chmod +x /*.sh

ENV PRE_CREATE_DB **None**
ENV SSL_SUPPORT **False**
ENV SSL_CERT **None**

# Admin server WebUI
EXPOSE 8083

# HTTP API
EXPOSE 8086

# Raft port (for clustering, don't expose publicly!)
#EXPOSE 8090

# Protobuf port (for clustering, don't expose publicly!)
#EXPOSE 8099

VOLUME ["/data"]

CMD ["/run.sh"]
