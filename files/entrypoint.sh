#!/bin/sh
set -fue

case "$1" in
  shell)
    exec /bin/sh
    ;;
  *)
    run-parts --exit-on-error /entrypoint.d/
    su-exec "$NEXUS_USER" "$NEXUS_APPDIR"/bin/nexus run
    ;;
esac

