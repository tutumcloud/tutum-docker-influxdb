FROM alpine:3.3
MAINTAINER Nicolas Degory <ndegory@axway.com>

RUN apk --no-cache add python && \
    apk --virtual envtpl-deps add --update py-pip python-dev curl && \
    curl https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py | python - --version=20.9.0 && \
    pip install envtpl && \
    apk del envtpl-deps

LABEL logType="influxdb"

ENV ADMIN_USER root
ENV INFLUXDB_INIT_PWD root
ENV INFLUXDB_VERSION 0.12.2

RUN apk --no-cache add go && \
    apk --virtual build-deps add curl git gcc musl-dev make && \
    export GOPATH=/go && \
    apk --no-cache add go git gcc musl-dev make && \
    go get github.com/influxdata/influxdb && \
    cd $GOPATH/src/github.com/influxdata/influxdb && \
    git checkout -q --detach "v${INFLUXDB_VERSION}" && \
    go get -u -f -t ./... && \
    go install -v ./... && \
    chmod +x $GOPATH/bin/* && \
    mv $GOPATH/bin/* /bin/ && \
    apk del go git gcc musl-dev make binutils-libs binutils libatomic libgcc openssl libssh2 libstdc++ mpc1 isl gmp ca-certificates pkgconf pkgconfig mpfr3 && \
    mkdir -p /etc/influxdb /data/influxdb /data/influxdb/meta /data/influxdb/data /var/tmp/influxdb/wal /var/log/influxdb && \
    apk del build-deps && cd / && rm -rf $GOPATH/ /var/cache/apk/*

RUN apk --no-cache add curl

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

# will be updated whenever there's a new commit
LABEL commit=${GIT_COMMIT}
LABEL branch=${GIT_BRANCH}
