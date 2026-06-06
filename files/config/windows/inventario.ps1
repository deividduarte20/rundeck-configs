# ==========================================
# INVENTARIO AUTOMATICO WINDOWS
# Autor: Deivid + ChatGPT
# ==========================================

$DataHora = Get-Date -Format "yyyyMMdd-HHmmss"

# Cria diretorio caso nao exista
if (!(Test-Path "C:\Temp")) {
    New-Item -ItemType Directory -Path "C:\Temp" | Out-Null
}

$Relatorio = "C:\Temp\Inventario-$DataHora.html"

# Coleta informacoes

$SO = Get-CimInstance Win32_OperatingSystem
$CPU = Get-CimInstance Win32_Processor
$MEM = Get-CimInstance Win32_ComputerSystem
$BIOS = Get-CimInstance Win32_BIOS

$IP = (
    Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object {
        $_.IPAddress -notlike "127.*" -and
        $_.IPAddress -notlike "169.254*"
    } |
    Select-Object -First 1 -ExpandProperty IPAddress
)

$DISCOS = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"

# Monta tabela de discos

$DiscosHtml = ""

foreach ($Disco in $DISCOS) {

    $LivreGB = [math]::Round($Disco.FreeSpace / 1GB, 2)
    $TotalGB = [math]::Round($Disco.Size / 1GB, 2)

    $DiscosHtml += @"
<tr>
<td>$($Disco.DeviceID)</td>
<td>$LivreGB GB</td>
<td>$TotalGB GB</td>
</tr>
"@
}

# Monta HTML

$HTML = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">

<title>Inventario Windows</title>

<style>

body {
    font-family: Arial, Helvetica, sans-serif;
    margin: 30px;
}

h1 {
    color: #1f4e79;
}

h2 {
    color: #2f75b5;
}

table {
    border-collapse: collapse;
    width: 100%;
    margin-bottom: 20px;
}

th {
    background-color: #d9eaf7;
}

th, td {
    border: 1px solid #cccccc;
    padding: 8px;
    text-align: left;
}

.footer {
    margin-top: 20px;
    font-size: 12px;
    color: gray;
}

</style>
</head>

<body>

<h1>Inventario Automatico Windows</h1>

<h2>Informacoes Gerais</h2>

<table>

<tr>
<th>Item</th>
<th>Valor</th>
</tr>

<tr>
<td>Hostname</td>
<td>$env:COMPUTERNAME</td>
</tr>

<tr>
<td>Usuario</td>
<td>$env:USERNAME</td>
</tr>

<tr>
<td>Endereco IP</td>
<td>$IP</td>
</tr>

<tr>
<td>Sistema Operacional</td>
<td>$($SO.Caption)</td>
</tr>

<tr>
<td>Versao</td>
<td>$($SO.Version)</td>
</tr>

<tr>
<td>Fabricante BIOS</td>
<td>$($BIOS.Manufacturer)</td>
</tr>

<tr>
<td>Serial BIOS</td>
<td>$($BIOS.SerialNumber)</td>
</tr>

<tr>
<td>Processador</td>
<td>$($CPU.Name)</td>
</tr>

<tr>
<td>Memoria Total</td>
<td>$([math]::Round($MEM.TotalPhysicalMemory / 1GB,2)) GB</td>
</tr>

<tr>
<td>Data da Coleta</td>
<td>$(Get-Date)</td>
</tr>

</table>

<h2>Discos</h2>

<table>

<tr>
<th>Drive</th>
<th>Espaco Livre</th>
<th>Tamanho Total</th>
</tr>

$DiscosHtml

</table>

<div class="footer">
Gerado automaticamente via PowerShell
</div>

</body>
</html>
"@

# Salva HTML

$HTML | Out-File -FilePath $Relatorio -Encoding UTF8

# Saida para Rundeck

Write-Host ""
Write-Host "========================================="
Write-Host "RELATORIO GERADO COM SUCESSO"
Write-Host "========================================="
Write-Host ""
Write-Host "Arquivo:"
Write-Host $Relatorio
Write-Host ""
Write-Host "Hostname:"
Write-Host $env:COMPUTERNAME
Write-Host ""
Write-Host "IP:"
Write-Host $IP
Write-Host ""
Write-Host "Data:"
Write-Host (Get-Date)
Write-Host ""
Write-Host "========================================="