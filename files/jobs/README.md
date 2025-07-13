# 🛠️ Jobs de Exemplo

## 📁 Job: Cópia de arquivos para VM remota (Linux)

### 🎯 Descrição
Este job copia arquivos locais para uma VM Linux remota via SSH/SCP, utilizando usuário e senha informados pelo operador no momento da execução.

---

### ⚙️ Options

| Option Name   | Option Type | Required | Default Value      | Observações                         |
|---------------|-------------|----------|---------------------|------------------------------------|
| `usuario`     | Text        | ✅ Yes   | –                   | Usuário de acesso SSH na VM        |
| `senha`       | Text        | ✅ Yes   | –                   | Senha de acesso SSH na VM          |
| `file`        | Arquivo     | ✅ Yes   | –                   | Arquivo a ser enviado              |
| `dir_destino` | Text        | ✅ Yes   | –                   | Diretório destino na VM remota     |
| `ip_vm_dest`  | Text        | ✅ Yes   | -                   | IP da VM destino                   |

---

### 🔄 Workflow

Executa o script `copy.sh` passando os parâmetros definidos:

```bash
cd /var/rundeck/ops/; ./copy.sh ${option.dir_destino} ${file.file} ${file.file.fileName} ${option.ip_vm_dest} ${option.usuario} ${option.senha}
```

🗂️ Estrutura Relevante
- Local dos scripts no Rundeck: /var/rundeck/ops/
- Script de cópia utilizado: copy.sh
- Protocolos utilizados: ssh, scp
