#!/bin/bash

# Variáveis
DIR_DEST="${1}"
FILE="${2}"
FILE_NAME="${3}"
IP="${4}"
USER="${5}"
PASS="${6}"

# Renomeia arquivo para nome e extensão de origem
mv "$FILE" "$FILE_NAME"

# Transfere arquivo através do protocolo ssh
if sshpass -p "$PASS" scp -o StrictHostKeyChecking=no "$FILE_NAME" "$USER@$IP:$DIR_DEST"; then
  echo "Arquivo copiado com sucesso: $FILE_NAME para $DIR_DEST em $IP"
  rm -rf $FILE_NAME
else
  echo "Erro ao copiar o arquivo: $FILE_NAME"
  exit 1
fi
