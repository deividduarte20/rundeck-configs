## Requisitos mínimos:
```
8GB RAM (4GB JVM Heap)
2 CPUs per instance
Equivalente a m4.large na AWS EC2
```

## Rundeck

## Instale o Java
```bash
sudo apt update && sudo apt-get install openjdk-11-jre-headless -y
```

## Instalação no repositório de pacotes
```bash
curl https://raw.githubusercontent.com/rundeck/packaging/main/scripts/deb-setup.sh 2> /dev/null | sudo bash -s rundeck
```

## Instala o rundeck
```bash
sudo apt-get update && sudo apt-get install rundeck
```

## Inicializar rundeck
```bash
sudo systemctl daemon-reload
sudo service rundeckd start
```

## Instalar my-sql client
```bash
sudo apt install mysql-client-core-8.0
```

## Acesse o banco de dados
```bash
mysql -u admin -h endpoint-db -p
```

## Crie a base de dados
```bash
create database rundeck;
```

## Crie usuário rundeckuser no banco (Insira a senha desejada no campo 'rundeckpassword')
```bash
CREATE USER 'rundeckuser'@'%' IDENTIFIED BY 'senharundeck';
```

## Atribua permissão ao usuário rundeckuser
```bash
GRANT ALL PRIVILEGES ON rundeck.* TO 'rundeckuser'@'%';
```

## Limpa cache
```bash
FLUSH PRIVILEGES;
```

## Sair do banco
```bash
exit
```

## Logue no banco com usuário rundeckuser para teste
```bash
mysql -u rundeckuser -h endpoint-db -p
```

## Configurando banco de dados no rundeck
## Remover as linhas:
```bash
sudo sed -i '/dataSource.dbCreate/d' /etc/rundeck/rundeck-config.properties
sudo sed -i '/dataSource.url/d' /etc/rundeck/rundeck-config.properties 
```

## Insira as linhas abaixo no final do arquivo /etc/rundeck/rundeck-config.properties
### DATABASE
```
dataSource.driverClassName = org.mariadb.jdbc.Driver </br>
dataSource.url = jdbc:mysql://endpoint-db/rundeck? autoReconnect=true&useSSL=false </br>
dataSource.username = rundeckuser </br>
dataSource.password = senhadb
```

# Reinicie o serviço
```bash
sudo service rundeckd restart
```
