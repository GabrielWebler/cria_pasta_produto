$user = Read-Host 'Usuario'
Add-Computer -DomainName "ENG.CPP" -Credential DOMINIO.LOCAL\$user -Passthru -OUPath ("OU=servidores,OU=Setor,DC=dominio,DC=local")
Write-Host "Leia a mensagem acima e feche esta janela"