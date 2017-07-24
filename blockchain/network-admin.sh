# Learning project, based on the IBM Hyperledger Fabric 'Your First Network' example. Intended for personal use only as part of training, not intended for commercial release.

export PATH=${PWD}/../bin:${PWD}:$PATH
# export FABRIC_CFG_PATH=${PWD}

# Obtain the OS and Architecture string that will be used to select the correct
# native binaries for your platform
OS_ARCH=$(echo "$(uname -s|tr '[:upper:]' '[:lower:]'|sed 's/mingw64_nt.*/windows/')-$(uname -m | sed 's/x86_64/amd64/g')" | awk '{print tolower($0)}')

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

# Ask user for confirmation of request
function askProceed () {
  read -p "Continue (y/n)? " ans
  case "$ans" in
    y|Y )
      echo "proceeding..."
    ;;
    n|N )
      echo "exiting..."
      exit 1
    ;;
    * )
      echo "invalid response"
      askProceed
    ;;
  esac
}

function generateCerts () {
  which cryptogen
  if [ "$?" -ne 0 ]; then
    echo "cryptogen tool not found."
    echo "Please make sure you have downloaded the binaries into the bin folder"
    echo "Exiting..."
    exit 1
  fi
  echo
  echo "####################################################"
  echo "#### Generate certificates using cryptogen tool ####"
  echo "####################################################"

  cryptogen generate --config=./crypto-config.yaml
  if [ "$?" -ne 0 ]; then
    echo "Failed to generate certificates...."
    echo "Exiting..."
    exit 1
  fi
  echo
}

function generateChannelArtifacts () {
  which configtxgen
  if [ "$?" -ne 0 ]; then
    echo "configtxgen tool not found."
    echo "Please make sure you have downloaded the binaries into the bin folder"
    echo "Exiting..."
  fi

  echo "####################################################"
  echo "########## Generating Order Genesis block ##########"
  echo "####################################################"

  configtxgen -profile OrdererGenesis -outputBlock ./channel-artifacts/genesis.block

  if [ "$?" -ne 0 ]; then
    echo "Failed to generate orderer gensis block..."
    exit 1
  fi

  echo
  echo "###########################################################"
  echo "# Generating channel configuration transaction channel.tx #"
  echo "###########################################################"
  echo

  configtxgen -profile ANDCoinChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME

  if [ "$?" -ne 0 ]; then
    echo "Failed to generate channel configuration transaction..."
    exit 1
  fi

  echo
  echo "#####################################################"
  echo "##### Generating anchor peer update for ANDDigital1MSP #####"
  echo "#####################################################"
  echo

  configtxgen -profile ANDCoinChannel -outputAnchorPeersUpdate ./channel-artifacts/ANDDigital1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg ANDDigital1MSP

  if [ "$?" -ne 0 ]; then
    echo "Failed to generate anchor peer update for ANDDigital1..."
    exit 1
  fi

  echo
  echo "#####################################################"
  echo "##### Generating anchor peer update for ANDDigital2MSP #####"
  echo "#####################################################"
  echo

  configtxgen -profile ANDCoinChannel -outputAnchorPeersUpdate ./channel-artifacts/ANDDigital2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg ANDDigital2MSP

  if [ "$?" -ne 0 ]; then
    echo "Failed to generate anchor peer update for ANDDigital2..."
    exit 1
  fi

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

# Setting text to explain activity
if [ "$MODE" == "generate" ]; then
  EXPMODE="Generating certs and genesis blocks for"
else
  printHelp
  exit 1
fi

# Confirming action to user
echo "${EXPMODE} with channel '${CHANNEL_NAME}' and CLI timeout of '${CLI_TIMEOUT}'"

# Confirm that user wants to take this action
askProceed

# Completing steps to complete action
if [ "$MODE" == "generate" ]; then
  echo "Generating certificates..."
  generateCerts
  generateChannelArtifacts
  echo "Generating channel artifacts..."
  # generateChannelArtifacts
fi
