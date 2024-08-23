#!/bin/bash

# Variaveis
PASS=toor
USER=root
DIR_DEST=${1}
FILE=${2}
FILE_NAME=${3}
IP=${4}

# Renomeia arquivo para nome e extensão de origem
mv "$FILE" "$FILE_NAME"

# Transfere arquivo através do protocolo ssh
sshpass -p "$PASS" scp -v -o StrictHostKeyChecking=no "$FILE_NAME" "$USER@$IP:$DIR_DEST"
