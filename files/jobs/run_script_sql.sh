#!/bin/bash

export password=seu_password_mysql

if mysql -u root -h @option.ip_server_banco@ -p$password < @file.arquivo_sql@; then
  echo "Query executada com sucesso"
else
  echo "Erro ao executar SQL"
fi
