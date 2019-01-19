#!/bin/sh

cd "$NEXUS_APPDIR/bin"
echo "Patching default JVM runtime options"
sed \
  -E \
  -e "s/(-XX:MaxRAM=).*/\1${JVM_MAX_MEM}/" \
  -e "s/-Xms.*/-Xms${JVM_HEAP_MEM}/" \
  -e "s/-Xmx.*/-Xmx${JVM_HEAP_MEM}/" \
  -e "s/(-XX:MaxDirectMemorySize=).*/\1${JVM_DIR_MEM}/" \
  -e "s;(-XX:LogFile=).*;\1${NEXUS_DATA}/log/jvm.log;" \
  -e "s;(-Dkaraf.data=).*;\1${NEXUS_DATA};" \
  -e "s;(-Djava.io.tmpdir=).*;\1${NEXUS_DATA}/tmp;" \
  -ibak \
  nexus.vmoptions

cd /
echo "Checking Nexus data directory"
mkdir -p "$NEXUS_DATA"

echo "Checking Nexus SSL Keystore directory"
mkdir -p "$NEXUS_DATA/etc/ssl"
cd "$NEXUS_DATA/etc/ssl"
if [ ! -f 'keystore.jks' ];
then
  keytool \
    -genkeypair \
    -keystore keystore.jks \
    -storepass password \
    -alias nexus.repo \
    -sigalg SHA256withRSA \
    -keyalg RSA \
    -keysize 2048 \
    -validity 5000 \
    -keypass password \
    -storetype pkcs12 \
    -dname 'CN=nexus.repo, OU=Sonatype, O=Sonatype, L=Unspecified, ST=Unspecified, C=US' \
    -ext 'SAN=IP:127.0.0.1,DNS:localhost'
fi

cd "$NEXUS_DATA/etc"
echo "Patching Nexus runtime options"
if [ ! -f "$NEXUS_DATA/etc/nexus.properties" ];
then
  mv "$NEXUS_APPDIR/etc/nexus.properties" "$NEXUS_DATA/etc/nexus.properties"
fi
sed \
  -E \
  -e "s;(application-port=).*;\1${NEXUS_WEB_PORT};" \
  -e "s;(application-port-ssl=).*;\1${NEXUS_WEB_PORT_SSL};" \
  -e "s;(nexus-context-path=).*;\1${NEXUS_WEB_CONTEXT};" \
  -ibak \
  nexus.properties




cd /
chown -R "$NEXUS_UID:$NEXUS_GID" "$NEXUS_DATA"

case "$1" in
  shell)
    exec /bin/sh
    ;;
  *)
    su-exec "$NEXUS_USER" "$NEXUS_APPDIR"/bin/nexus run
    ;;
esac
