FROM alpine:3.3
MAINTAINER Nicolas Degory <ndegory@axway.com>

#Need to keep curl and bash after installation for containerPilot
RUN apk update && \
    apk --no-cache add python ca-certificates curl bash && \
    apk --virtual envtpl-deps add --update py-pip python-dev && \
    curl https://bootstrap.pypa.io/ez_setup.py | python && \
    pip install envtpl && \
    apk del envtpl-deps && rm -rf /var/cache/apk/*

ENV INFLUXDB_VERSION 0.13.0

RUN echo "http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    echo "http://nl.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && apk upgrade && \
    apk --virtual build-deps add go>1.6 curl git gcc musl-dev make && \
    export GOPATH=/go && \
    go get -v github.com/influxdata/influxdb && \
    cd $GOPATH/src/github.com/influxdata/influxdb && \
    git checkout -q --detach "v${INFLUXDB_VERSION}" && \
    go get -v ./... && \
    go install -v ./... && \
    chmod +x $GOPATH/bin/* && \
    mv $GOPATH/bin/* /bin/ && \
    mkdir -p /etc/influxdb /data/influxdb /data/influxdb/meta /data/influxdb/data /var/tmp/influxdb/wal /var/log/influxdb && \
    apk del build-deps && cd / && rm -rf $GOPATH/ /var/cache/apk/*

RUN apk --no-cache add curl

ENV ADMIN_USER root
ENV INFLUXDB_INIT_PWD root

ADD types.db /usr/share/collectd/types.db
ADD config.toml /config/config.toml.tpl
ADD run.sh /run.sh
RUN chmod +x /*.sh

ENV PRE_CREATE_DB **None**
ENV SSL_SUPPORT **False**
ENV SSL_CERT **None**


# Add ContainerPilot
RUN curl -Lo /tmp/cb.tar.gz https://github.com/joyent/containerpilot/releases/download/2.1.0/containerpilot-2.1.0.tar.gz \
&& tar -xz -f /tmp/cb.tar.gz \
&& mv ./containerpilot /bin/
COPY containerpilot.json /etc/containerpilot.json
COPY start.sh /start.sh
RUN chmod +x /start.sh

ENV CONSUL=consul:8500
ENV CONTAINERPILOT=file:///etc/containerpilot.json

# Admin server WebUI
EXPOSE 8083

# HTTP API
EXPOSE 8086

# Raft port (for clustering, don't expose publicly!)
#EXPOSE 8090

# Protobuf port (for clustering, don't expose publicly!)
#EXPOSE 8099

VOLUME ["/data"]

CMD ["sh", "-c", "/start.sh"]

LABEL axway_image="influxdb"
# will be updated whenever there's a new commit
LABEL commit=${GIT_COMMIT}
LABEL branch=${GIT_BRANCH}
