#!/bin/bash

# Usage: execute.sh [WildFly mode] [configuration file]
#
# The default mode is 'standalone' and default configuration is based on the
# mode. It can be 'standalone.xml' or 'domain.xml'.

JBOSS_HOME=/opt/wildfly
JBOSS_CLI=$JBOSS_HOME/bin/jboss-cli.sh
JBOSS_MODE=${1:-"standalone"}
JBOSS_CONFIG=${2:-"$JBOSS_MODE.xml"}

function wait_for_server() {
  until `$JBOSS_CLI -c "ls /deployment" &> /dev/null`; do
    sleep 1
  done
}

echo "=> Iniciando Servidor Wildfly"
$JBOSS_HOME/bin/$JBOSS_MODE.sh -c $JBOSS_CONFIG > /dev/null &

echo "=> Aguardando Servidor Iniciar para Executar comando no jboss-cli"
wait_for_server

echo "=> Configurando Standalone com drivers e datasources"
$JBOSS_CLI -c --file=`dirname "$0"`/ConfigStandalone.cli

echo "=> Finalizando Servidor WildFly"
if [ "$JBOSS_MODE" = "standalone" ]; then
  $JBOSS_CLI -c ":shutdown"
else
  $JBOSS_CLI -c "/host=*:shutdown"
fi

