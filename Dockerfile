FROM tutum/curl:trusty
MAINTAINER Feng Honglin <hfeng@tutum.co>

# Install InfluxDB
ENV INFLUXDB_VERSION 0.8.8
ENV AGENT_PORT 8080

RUN apt-get update && \
  apt-get install -y git && \
  apt-get install -y wget && \
  curl -s -o /tmp/influxdb_latest_amd64.deb https://s3.amazonaws.com/influxdb/influxdb_${INFLUXDB_VERSION}_amd64.deb && \
  dpkg -i /tmp/influxdb_latest_amd64.deb && \
  rm /tmp/influxdb_latest_amd64.deb && \
  rm -rf /var/lib/apt/lists/* && \
  wget https://storage.googleapis.com/golang/go1.3.3.linux-amd64.tar.gz && \
  tar -C /usr/local -xzf go1.3.3.linux-amd64.tar.gz && \
  rm go1.3.3.linux-amd64.tar.gz

ADD image_agent /root/image_agent

RUN export PATH=$PATH:/usr/local/go/bin && \
  export GOPATH=/root/image_agent && \
  cd /root/image_agent/src/image_agent && \
  go get && \
  go build && \
  rm -rf /usr/local/go && \
  mv /root/image_agent/src/image_agent/image_agent /image_agent

ADD config.toml /config/config.toml
ADD run.sh /run.sh
RUN chmod +x /*.sh

ENV PRE_CREATE_DB **None**
ENV SSL_SUPPORT **False**
ENV SSL_CERT **None**

# Make agent can read config file
ENV CONFIG_FILE /config/config.toml
# InfluxDB pid file
ENV PID_FILE /root/influxdb.pid
# Volume path
ENV VOLUME_PATH /data



# Agent server
EXPOSE 8080

# Admin server
EXPOSE 8083

# HTTP API
EXPOSE 8086

# HTTPS API
EXPOSE 8084

# Raft port (for clustering, don't expose publicly!)
#EXPOSE 8090

# Protobuf port (for clustering, don't expose publicly!)
#EXPOSE 8099

VOLUME ["/data"]

CMD ["/run.sh"]
