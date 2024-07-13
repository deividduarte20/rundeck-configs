## Requisitos mínimos:
```
8GB RAM (4GB JVM Heap)
2 CPUs por instância
Equivalente a m4.large na AWS EC2
```

## Rundeck (Ubuntu)

## Instale o Java
```bash
sudo apt update && sudo apt-get install openjdk-11-jre-headless -y
```

## Verifique se o java foi instalado
```bash
java --version
```

## Instalação no repositório de pacotes
```bash
curl https://raw.githubusercontent.com/rundeck/packaging/main/scripts/deb-setup.sh 2> /dev/null | sudo bash -s rundeck
```

## Instala o rundeck
```bash
sudo apt-get update && sudo apt-get install rundeck -y
```

## Inicializar rundeck
```bash
sudo systemctl daemon-reload
sudo service rundeckd start
```

## Instalar my-sql client
```bash
sudo apt install mysql-client-core-8.0 -y
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

## Remoção de linhas de configurção de banco:
```bash
sudo sed -i '/dataSource.dbCreate/d' /etc/rundeck/rundeck-config.properties
sudo sed -i '/dataSource.url/d' /etc/rundeck/rundeck-config.properties 
```

## Insira as linhas abaixo no final do arquivo /etc/rundeck/rundeck-config.properties
**Substitua endpoint-db pelo seu endpoint do RDS**
**Substitura senhadb pela senha do usuário rundeckuser do banco**
### DATABASE
```
dataSource.driverClassName = org.mariadb.jdbc.Driver 
dataSource.url = jdbc:mysql://endpoint-db/rundeck? autoReconnect=true&useSSL=false 
dataSource.username = rundeckuser 
dataSource.password = senhadb
```

# Reinicie o serviço
```bash
sudo service rundeckd restart
```

# Habilitando o serviço do rundeck para inicializar junto com o sistema
```bash
sudo systemctl enable rundeckd
```
