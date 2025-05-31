# Configuração de Integração do Rundeck com Active Directory

Este guia descreve como configurar a integração do Rundeck com o Active Directory (AD) para autenticação e autorização, incluindo a configuração de ACLs, autenticação via LDAP e suporte a autenticação múltipla.

## Pré-requisitos
- Acesso administrativo ao Active Directory.
- Acesso root ou sudo no servidor Rundeck.
- Rundeck instalado e funcionando.
- Conexão de rede entre o Rundeck e o servidor AD.

---

## 1. Configuração no Active Directory

### 1.1. Criar usuário na Unidade Organizacionai (OU) Users
1. No Active Directory, crie um usuário chamado `svc-rundeck`.
2. Crie dois grupos:
   - `RUNDECK_ADMIN`
   - `RUNDECK_OPS`

**Estrutura resultante:**
```
OU=Users
   ├── CN=RUNDECK_ADMIN
   └── CN=RUNDECK_OPS
```

---

## 2. Configuração de ACLs no Rundeck

### 2.1. Criar ACL para o grupo RUNDECK_ADMIN
1. Acesse a interface web do Rundeck.
2. Crie uma nova ACL chamada `RUNDECK_ADMIN`.
3. Adicione o seguinte conteúdo à ACL:

```yaml
description: Admin, all access.
context:
  project: '.*' # all projects
for:
  resource:
    - allow: '*' # allow read/create all kinds
  adhoc:
    - allow: '*' # allow read/running/killing adhoc jobs
  job: 
    - allow: '*' # allow read/write/delete/run/kill of all jobs
  node:
    - allow: '*' # allow read/run for all nodes
by:
  group: RUNDECK_ADMIN

---

description: Admin, all access.
context:
  application: 'rundeck'
for:
  resource:
    - allow: '*' # allow create of projects
  project:
    - allow: '*' # allow view/admin of all projects
  project_acl:
    - allow: '*' # allow admin of all project-level ACL policies
  storage:
    - allow: '*' # allow read/create/update/delete for all /keys/* storage content
by:
  group: RUNDECK_ADMIN
```

### 2.2. Criar ACL para o grupo RUNDECK_OPS
1. Crie uma nova ACL chamada `RUNDECK_OPS`.
2. Adicione o seguinte conteúdo à ACL:

```yaml
---
description: Acesso para a equipe ops do Active Directory a todos os projetos
context:
  project: '.*'  # Aplica-se a todos os projetos
for:
  resource:
    - equals:
        kind: job
      allow: [create,read,update,delete] # Permite criar, ler, atualizar e excluir jobs
    - equals:
        kind: node
      allow: [read,create,update,refresh] # Permite ler, criar, atualizar e atualizar fontes de nós
    - equals:
        kind: event
      allow: [read,create] # Permite ler e criar eventos
  adhoc:
    - allow: [read,run,runAs,kill,killAs] # Permite ler, executar e matar jobs ad hoc
  job:
    - allow: [create,read,update,delete,run,runAs,kill,killAs] # Permite todas as ações sobre os jobs
  node:
    - allow: [read,run] # Permite ler e executar nos nós
by:
  group: RUNDECK_OPS

---
description: Acesso para a equipe ops do Active Directory a todos os projetos
context:
  application: 'rundeck'
for:
  resource:
    - equals:
        kind: project
      allow: [create] # Permite criar projetos
    - equals:
        kind: system
      allow: [read,enable_executions,disable_executions,admin] # Permite ler informações do sistema e habilitar/desabilitar execuções
    - equals:
        kind: system_acl
      allow: [read] # Permite ler as ACLs do sistema
    - equals:
        kind: user
      allow: [admin] # Permite modificar o perfil do usuário
  project:
    - match:
        name: '.*'
      allow: [read,import,export,configure,delete,promote,admin] # Permite acesso completo aos projetos
  project_acl:
    - match:
        name: '.*'
      allow: [read,create,update,delete,admin] # Permite modificar as ACLs dos projetos
  storage:
    - allow: [read,create,update,delete] # Permite ler e modificar o conteúdo do armazenamento de chaves
by:
  group: RUNDECK_OPS
```

### 2.3. Reiniciar o serviço Rundeck
Execute o comando abaixo para aplicar as mudanças:
```bash
sudo systemctl restart rundeckd
```

---

## 3. Configuração de Autenticação LDAP no servidor do rundeck

### 3.1. Criar arquivo de configuração LDAP
1. Crie o arquivo `/etc/rundeck/jaas-active-directory.conf` com o seguinte conteúdo:

```text
activedirectory {
  com.dtolabs.rundeck.jetty.jaas.JettyCachingLdapLoginModule required
  debug="true"
  contextFactory="com.sun.jndi.ldap.LdapCtxFactory"
  providerUrl="ldap://192.168.100.151:389"
  bindDn="CN=svc-rundeck,CN=Users,DC=dtech,DC=local"
  bindPassword="Senha@2025"
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

2. Altere o proprietário e as permissões do arquivo:
```bash
sudo chown rundeck:rundeck /etc/rundeck/jaas-active-directory.conf
sudo chmod 640 /etc/rundeck/jaas-active-directory.conf
```

### 3.2. Configurar sincronização LDAP
1. Edite o arquivo `/etc/rundeck/rundeck-config.properties` e adicione:
```text
rundeck.security.syncLdapUser=true
```

### 3.3. Fazer backup do arquivo de profile
```bash
sudo cp /etc/rundeck/profile /etc/rundeck/profile.bkp
```

### 3.4. Editar o arquivo de profile
1. Abra o arquivo `/etc/rundeck/profile` com um editor (ex.: `vim`).
2. Modifique as linhas abaixo:
```text
-Djava.security.auth.login.config=/etc/rundeck/jaas-active-directory.conf
-Dloginmodule.name=activedirectory
```

3. Reinicie o serviço Rundeck:
```bash
sudo systemctl restart rundeckd
```

---

## 4. Configuração de Autenticação Múltipla

### 4.1. Criar arquivo de configuração multiauth
1. Crie o arquivo `/etc/rundeck/jaas-multiauth.conf` com o seguinte conteúdo:

```text
multiauth {
  com.dtolabs.rundeck.jetty.jaas.JettyCachingLdapLoginModule sufficient
  debug="true"
  contextFactory="com.sun.jndi.ldap.LdapCtxFactory"
  providerUrl="ldap://192.168.100.151:389"
  bindDn="CN=svc-rundeck,CN=Users,DC=dtech,DC=local"
  bindPassword="Senha@2025"
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

2. Altere o proprietário e as permissões do arquivo:
```bash
sudo chown rundeck:rundeck /etc/rundeck/jaas-multiauth.conf
sudo chmod 640 /etc/rundeck/jaas-multiauth.conf
```

### 4.2. Fazer backup do arquivo de profile
```bash
sudo cp /etc/rundeck/profile /etc/rundeck/old_profile
```

### 4.3. Editar o arquivo de profile
1. Abra o arquivo `/etc/rundeck/profile`.
2. Substitua as linhas:
```text
-Djava.security.auth.login.config=/etc/rundeck/jaas-activedirectory.conf
-Dloginmodule.name=activedirectory
```
Por:
```text
-Djava.security.auth.login.config=/etc/rundeck/jaas-multiauth.conf
-Dloginmodule.name=multiauth
```

### 4.4. Reiniciar o serviço Rundeck
```bash
sudo systemctl restart rundeckd
```

### 4.5. Monitorar o serviço
Acompanhe os logs para verificar se o serviço está funcionando corretamente:
```bash
tail -f /var/log/rundeck/service.log
```

---

## Notas Adicionais
- **Segurança**: Certifique-se de que a senha do `bindDn` (`Senha@2025`) seja armazenada de forma segura e alterada conforme as políticas de segurança da sua organização.
- **Testes**: Após cada reinicialização do serviço, teste o acesso com contas do Active Directory pertencentes aos grupos `RUNDECK_ADMIN` e `RUNDECK_OPS` para validar as permissões.
- **Logs**: Sempre verifique o log em `/var/log/rundeck/service.log` para diagnosticar possíveis erros de autenticação ou configuração.
