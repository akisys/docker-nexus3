FROM openjdk:8-alpine

ARG NEXUS_VERSION=3.18.1-01
ARG NEXUS_DOWNLOAD_URL=https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz
ARG NEXUS_DOWNLOAD_SHA256_HASH=6d3e2c32b220a7eee0e1ff81a8dd15a48e5712fc3f379b6102717ba06058707c

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
      && wget -q -O /tmp/nexus3.tgz "${NEXUS_DOWNLOAD_URL}"

RUN set -ex \
      && echo "${NEXUS_DOWNLOAD_SHA256_HASH}  /tmp/nexus3.tgz" | sha256sum -c

RUN set -ex \
      && mkdir -p "$(dirname $NEXUS_APPDIR)" \
      && tar -xf /tmp/nexus3.tgz -C"$(dirname $NEXUS_APPDIR)"/ \
      && ln -snf "/opt/nexus-${NEXUS_VERSION}" "${NEXUS_APPDIR}"

RUN set -ex \
      && addgroup -g "${NEXUS_GID}" "${NEXUS_GROUP}" \
      && adduser -h "${NEXUS_DATA}" -u "${NEXUS_UID}" -s /bin/sh -D -H -G "${NEXUS_GROUP}" "${NEXUS_USER}"

COPY files/buildout/ /tmp/buildout/
COPY files/entrypoint.d/ /entrypoint.d/
COPY files/entrypoint.sh /

ENV \
  NEXUS_WEB_PORT=8080 \
  NEXUS_WEB_PORT_SSL=8443 \
  NEXUS_WEB_CONTEXT=/ \
  JVM_MAX_MEM=1G \
  JVM_HEAP_MEM=1200M \
  JVM_DIR_MEM=2G

# run final stages of build-out
RUN set -e \
      && chmod +x /tmp/buildout/* \
      && run-parts --exit-on-error /tmp/buildout \
      && rm -rf /tmp/buildout \
      && rm -f /tmp/nexus3.tgz

RUN set -ex \
      && chmod +x /entrypoint.d/* \
      && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]

