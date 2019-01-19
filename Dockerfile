FROM openjdk:8-alpine

ARG NEXUS_VERSION=3.15.1-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz
ARG NEXUS_DOWNLOAD_SHA256_HASH=5ddf03e35f92b4b90eb290f48ada15bb8b15ba5b76e7f190a24ede0d8982ffcf

ENV \
  NEXUS_APPDIR=/opt/nexus3 \
  NEXUS_DATA=/nexus-data \
  NEXUS_UID=1000 \
  NEXUS_GID=1000 \
  NEXUS_USER=nexusruntime \
  NEXUS_GROUP=nexusruntime

RUN set -ex \
      && apk add --no-cache wget su-exec
RUN set -ex \
      && wget -O /tmp/nexus3.tgz "${NEXUS_DOWNLOAD_URL}"
RUN set -ex \
      && test "$(sha256sum /tmp/nexus3.tgz | awk '{print $1}')" == "${NEXUS_DOWNLOAD_SHA256_HASH}"
RUN set -ex \
      && mkdir -p "$(dirname $NEXUS_APPDIR)" \
      && tar -xvf /tmp/nexus3.tgz -C"$(dirname $NEXUS_APPDIR)"/ \
      && ln -snf "/opt/nexus-${NEXUS_VERSION}" "${NEXUS_APPDIR}"
RUN set -ex \
      && addgroup -g "${NEXUS_GID}" "${NEXUS_GROUP}" \
      && adduser -h "${NEXUS_DATA}" -u "${NEXUS_UID}" -s /bin/sh -D -H -G "${NEXUS_GROUP}" "${NEXUS_USER}"

COPY files/ /
ENV \
  NEXUS_WEB_PORT=8080 \
  NEXUS_WEB_PORT_SSL=8443 \
  NEXUS_WEB_CONTEXT=/ \
  JVM_HEAP_MEM=1200M \
  JVM_DIR_MEM=2G

RUN set -ex \
      && /build-out.sh

ENTRYPOINT ["/entrypoint.sh"]
