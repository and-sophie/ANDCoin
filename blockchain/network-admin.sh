# Learning project, based on the IBM Hyperledger Fabric 'Your First Network' example. Intended for personal use only as part of training, not intended for commercial release.

export PATH=${PWD}/../bin:${PWD}:$PATH
# export FABRIC_CFG_PATH=${PWD}

# Default settings
# The duration the CLI should wait for a response from
# another container before giving up
CLI_TIMEOUT=10000
# The default channel name
CHANNEL_NAME="andcoin"
# The default docker-compose yaml definition
COMPOSE_FILE=docker-compose-cli.yaml

# Print the usage message
function printHelp () {
  echo
  echo "Hello, I will help you set up a blockchain network for the ANDCoin platform!"
  echo
  echo "To use: "
  echo "  sh network-admin.sh "
  echo "    -h <help> - print this message"
  echo
  echo "    -m <mode> - one of 'generate', 'up', 'down' or 'restart'"
  echo "      - 'generate' - generate required certificates and genesis block"
  echo "      - 'up'       - bring up the network with docker-compose up"
  echo "      - 'down'     - clear the network with docker-compose"
  echo
  echo "    -c <channel name> - channel name to use (defaults to \"andcoin\")"
  echo
  echo "    -t <timeout> - CLI timeout duration in microseconds (defaults to 10000)"
  echo
  echo "To spin up a new ANDCoin network, you will need to generate certificates and "
  echo "the genesis block, then bring up the network."
  echo
  echo "For example: "
  echo "  sh network-admin.sh -m generate"
  echo "  sh network-admin.sh -m up"
  echo "  sh network-admin.sh -m down"
}

# Parse commandline args
while getopts "h?m:c:t:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    m)  MODE=$OPTARG
    ;;
    c)  CHANNEL_NAME=$OPTARG
    ;;
    t)  CLI_TIMEOUT=$OPTARG
  esac
done

if [ "$MODE" == "generate" ]; then
  EXPMODE="Generating certs and genesis blocks for"
else
  printHelp
  exit 1
fi

echo "${EXPMODE} with channel '${CHANNEL_NAME}' and CLI timeout of '${CLI_TIMEOUT}'"
