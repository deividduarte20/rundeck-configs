# Configuração do Rundeck com Active Directory

Este guia descreve como configurar a autenticação do Rundeck com Active Directory (AD) e como implementar autenticação múltipla. Siga as etapas abaixo para configurar o ambiente.

## 1. Configuração do Active Directory no Rundeck

### 1.1. Criar o arquivo de configuração JAAS
Crie o arquivo `/etc/rundeck/jaas-active-directory.conf` com o seguinte conteúdo:

```plaintext
activedirectory {
    com.dtolabs.rundeck.jetty.jaas.JettyCachingLdapLoginModule required
    debug="true"
    contextFactory="com.sun.jndi.ldap.LdapCtxFactory"
    providerUrl="ldap://ip_ad:389"
    bindDn="CN=svc-rundeck,CN=Users,DC=dtech,DC=local"
    bindPassword="insira_senha_usuario_ad"
    authenticationMethod="simple"
    forceBindingLogin="true"
    userBaseDn="CN=Users,DC=dtech,DC=local"
    userRdnAttribute="sAMAccountName"
    userIdAttribute="sAMAccountName"
    userPasswordAttribute="unicodePwd"
    userObjectClass="user"
    roleBaseDn="DC=dtech,DC=local"
    roleNameAttribute="cn"
    roleMemberAttribute="member"
    roleObjectClass="group"
    cacheDurationMillis="300000"
    reportStatistics="true"
    userLastNameAttribute="sn"
    userFirstNameAttribute="givenName"
    userEmailAttribute="mail";
};
```

### 1.2. Ajustar permissões do arquivo
Defina o proprietário e as permissões do arquivo para garantir segurança:

```bash
sudo chown rundeck:rundeck /etc/rundeck/jaas-active-directory.conf
sudo chmod 640 /etc/rundeck/jaas-active-directory.conf
```

### 1.3. Configurar o arquivo `rundeck-config.properties`
Adicione a seguinte linha ao arquivo `/etc/rundeck/rundeck-config.properties`:

```plaintext
rundeck.security.syncLdapUser=true
```

### 1.4. Fazer backup e editar o arquivo de profile
1. Crie um backup do arquivo `/etc/rundeck/profile`:

```bash
sudo cp /etc/rundeck/profile /etc/rundeck/profile.bkp
```

2. Edite o arquivo `/etc/rundeck/profile` e adicione ou modifique as seguintes linhas:

```plaintext
-Djava.security.auth.login.config=/etc/rundeck/jaas-active-directory.conf
-Dloginmodule.name=activedirectory
```

### 1.5. Estrutura no Active Directory
No Active Directory, crie a seguinte estrutura de Organizational Units (OUs) e grupos:

```
OU=groups
  └── OU=RUNDECK
        ├── CN=GGU_RUNDECK_ADMIN
        └── CN=GGU_RUNDECK_OPS
```

### 1.6. Configurar ACLs no Rundeck
Acesse a interface web do Rundeck e crie as seguintes ACLs:

#### ACL para `GGU_RUNDECK_ADMIN`
```yaml
description: "Permissões administrativas para membros do grupo GGU_RUNDECK_ADMIN"
context:
  project: '.*'  # Aplica para todos os projetos
for:
  project:
    - match:
        name: '.*'
      allow: [read, create, update, delete, import, export, configure]
  node:
    - match:
        name: '.*'
      allow: [read, create, update, delete, run]
  job:
    - match:
        name: '.*'
      allow: [read, run, create, update, delete, kill]
  adhoc:
    - allow: [read, run]
  event:
    - allow: [read]
  resource:
    - allow: [read]
by:
  group: GGU_RUNDECK_ADMIN
```

#### ACL para `GGU_RUNDECK_OPS`
```yaml
description: "Permissões operacionais para membros do grupo GGU_RUNDECK_OPS"
context:
  project: '.*'
for:
  project:
    - allow: [read]
  node:
    - allow: [read, run]
  job:
    - allow: [read, run]
  adhoc:
    - allow: [run]
  event:
    - allow: [read]
  resource:
    - allow: [read]
by:
  group: GGU_RUNDECK_OPS
```

### 1.7. Reiniciar o serviço do Rundeck
Reinicie o serviço para aplicar as configurações:

```bash
sudo systemctl restart rundeckd
```

## 2. Configuração de Autenticação Múltipla

### 2.1. Criar o arquivo JAAS para autenticação múltipla
Crie o arquivo `/etc/rundeck/jaas-multiauth.conf` com o seguinte conteúdo:

```plaintext
multiauth {
    com.dtolabs.rundeck.jetty.jaas.JettyCachingLdapLoginModule sufficient
    debug="true"
    contextFactory="com.sun.jndi.ldap.LdapCtxFactory"
    providerUrl="ldap://ip_ad:389"
    bindDn="CN=svc-rundeck,CN=Users,DC=dtech,DC=local"
    bindPassword="insira_senha_usuario_ad"
    authenticationMethod="simple"
    forceBindingLogin="true"
    userBaseDn="CN=Users,DC=dtech,DC=local"
    userRdnAttribute="sAMAccountName"
    userIdAttribute="sAMAccountName"
    userPasswordAttribute="unicodePwd"
    userObjectClass="user"
    roleBaseDn="DC=dtech,DC=local"
    roleNameAttribute="cn"
    roleMemberAttribute="member"
    roleObjectClass="group"
    cacheDurationMillis="300000"
    reportStatistics="true"
    userLastNameAttribute="sn"
    userFirstNameAttribute="givenName"
    userEmailAttribute="mail";

    org.eclipse.jetty.jaas.spi.PropertyFileLoginModule required
    debug="true"
    file="/etc/rundeck/realm.properties";
};
```

### 2.2. Ajustar permissões do arquivo
Defina o proprietário e as permissões do arquivo:

```bash
sudo chown rundeck:rundeck /etc/rundeck/jaas-multiauth.conf
sudo chmod 640 /etc/rundeck/jaas-multiauth.conf
```

### 2.3. Fazer backup e editar o arquivo de profile
1. Crie um backup do arquivo `/etc/rundeck/profile`:

```bash
sudo cp /etc/rundeck/profile /etc/rundeck/old_profile
```

2. Edite o arquivo `/etc/rundeck/profile` e substitua as linhas:

De:
```plaintext
-Djava.security.auth.login.config=/etc/rundeck/jaas-activedirectory.conf
-Dloginmodule.name=activedirectory
```

Para:
```plaintext
-Djava.security.auth.login.config=/etc/rundeck/jaas-multiauth.conf
-Dloginmodule.name=multiauth
```

### 2.4. Reiniciar o serviço do Rundeck
Reinicie o serviço para aplicar as mudanças:

```bash
sudo systemctl restart rundeckd
```

### 2.5. Monitorar o serviço
Acompanhe os logs para verificar o status do serviço:

```bash
tail -f /var/log/rundeck/service.log
```

## Notas Adicionais
- Certifique-se de que o servidor Active Directory está acessível na URL especificada (`ldap://192.168.100.151:389`).
- A senha (`bindPassword`) deve ser mantida segura e atualizada conforme necessário.
- As ACLs devem ser testadas para garantir que as permissões estão corretas para os grupos `GGU_RUNDECK_ADMIN` e `GGU_RUNDECK_OPS`.