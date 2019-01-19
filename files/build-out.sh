#!/bin/sh

JVM_FIX_OPS="
-XX:+UnlockExperimentalVMOptions
-XX:+UseCGroupMemoryLimitForHeap
"

cd "$NEXUS_APPDIR"

# fix some java 8 docker memory constraint detection options
set +e
for _jvmfix in "$JVM_FIX_OPS"; do
  if [ -n "$_jvmfix" ]; then
    grep "$_jvmfix" "$NEXUS_APPDIR/bin/nexus.vmoptions" || (echo "$_jvmfix" | tee -a "$NEXUS_APPDIR/bin/nexus.vmoptions")
  fi
done
set -e

# get the intial nexus.properties in place
#cp etc/nexus-default.properties etc/nexus.properties
touch etc/nexus.properties
echo '
## Nexus customizations
application-port=
application-port-ssl=
application-host=0.0.0.0
nexus-context-path=/
nexus-args=${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-requestlog.xml,${jetty.etc}/jetty-https.xml
ssl.etc=${karaf.data}/etc/ssl
' | tee -a etc/nexus.properties

cd /

chown -R "${NEXUS_USER}:${NEXUS_GROUP}" "${NEXUS_APPDIR}"/*
rm -f /tmp/nexus3.tgz
rm -f "$0"
