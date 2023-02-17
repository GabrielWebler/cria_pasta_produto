<#
===================================================================================================================
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
===================================================================================================================
#>
function menu{
Write-Host  -foregroundcolor red "==========================================================================="
Write-Host
Write-Host "   1) SHARE 1 (\\STORAGE-1.DOMINIO.LOCAL\SHARE)"
Write-Host
Write-Host "   2) SHARE 2 (\\STORAGE-2.DOMINIO.LOCAL\SHARE-2)"
Write-Host
Write-Host "   3) SHARE PRODUTO 2 (\\STORAGE-PRODUTO-2.DOMINIO.LOCAL\produto-2)"
Write-Host
Write-Host "   4) SHARE PRODUTO 3 (\\STORAGE-PRODUTO-3.DOMINIO.LOCAL\produto-3)"
Write-Host
Write-Host "   5) SHARE PRODUTO 4 (\\STORAGE-PRODUTO-4.DOMINIO.LOCAL\produto-4)"
Write-Host
Write-Host  -foregroundcolor red "==========================================================================="
Write-Host
Write-Host
$resp_menu_prd_esc = Read-Host "Escolha um storage para ser veriricado"

switch ($resp_menu_prd_esc) {
    1 { 
        $share = "\\STORAGE-1.DOMINIO.LOCAL\SHARE"
		$contingencia = "\\storage-bkp.dominio.local\share\CONTINGENCIA"
    }
    2 {
        $share = "\\STORAGE-2.DOMINIO.LOCAL\STORAGE-2"
		$contingencia= "\\storage-bkp.dominio.local\share\CONTINGENCIA"
     }
    3 {
        $share = "\\STORAGE-PRODUTO-2.DOMINIO.LOCAL\produto-2"
		$contingencia = "\\STORAGE-PRODUTO-3.DOMINIO.LOCAL\produto-3\CONTINGENCIA"
     }
    4 {
        $share = "\\STORAGE-PRODUTO-3.DOMINIO.LOCAL\produto-3"
		$contingencia = "\\STORAGE-PRODUTO-4.DOMINIO.LOCAL\produto-4\CONTINGENCIA"
     }
    5 {
        $share = "\\STORAGE-PRODUTO-4.DOMINIO.LOCAL\produto-4"
		$contingencia = "\\STORAGE-PRODUTO-2.DOMINIO.LOCAL\produto-2\CONTINGENCIA"
     }
}
Write-Host
Write-Host
Get-ChildItem $share | Sort-Object Name
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host
Write-Host "A CONTINGENCIA DO SHARE É $contingencia"
Write-Host
$verif_share = Read-Host "O SHARE ESCOLHIDO FOI <$share>. ESTA CORRETO? (s/n)"
$verif_share = $verif_share.ToUpper()
Write-Host
Write-Host
if ( $verif_share -eq "S"){
        nome_prd
    } 

menu
}

<#
===================================================================================================================
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
===================================================================================================================
#>
function Remove-StringDiacritic {
    param
    (
        [ValidateNotNullOrEmpty()]
        [Alias('Text')]
        [System.String]$String,
        [System.Text.NormalizationForm]$NormalizationForm = "FormD"
    )
    BEGIN
    {
        $Normalized = $String.Normalize($NormalizationForm)
        $NewString = New-Object -TypeName System.Text.StringBuilder
        
    }
    PROCESS
    {
        $normalized.ToCharArray() | ForEach-Object -Process {
            if ([Globalization.CharUnicodeInfo]::GetUnicodeCategory($psitem) -ne [Globalization.UnicodeCategory]::NonSpacingMark)
            {
                [void]$NewString.Append($psitem)
            }
        }
    }
    END
    {
        Write-Output $($NewString -as [string])
    }
}

<#
===================================================================================================================
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
===================================================================================================================
#>
function nome_prd{
$prd_semtrat = Read-Host "Informe o nome do produto"
$produto_string = Remove-StringDiacritic -String $prd_semtrat
$produto = ($produto_string.ToUpper()).Replace(" ","_")
Write-Host
Write-Host
Write-Host "O NOME DO PRODUTO SERÁ $produto"
$verif_prd = Read-Host "ESTÁ CORRETO? (S/N)"
$verif_prd = $verif_prd.ToUpper()
Write-Host
Write-Host
if ( $verif_share -eq "S"){
    $folder_verif = $share + "\" + $produto
    $folder_existe = Test-Path $folder_verif 
    If ($folder_existe -eq $True) {
		
		Write-Host -foregroundcolor Red -BackgroundColor Yellow "                                                              "
		Write-Host -foregroundcolor Red -BackgroundColor Yellow "                      A PASTA EXISTE!                         "
		Write-Host -foregroundcolor Red -BackgroundColor Yellow "                                                              "
		$folder = $share + "\" + $produto
		Get-Item $folder
		Get-ChildItem $folder | Sort-Object Name
		Write-Host
		Write-Host
		Write-Host -ForegroundColor Black -BackgroundColor Red "                                                              "
		Write-Host -ForegroundColor Black -BackgroundColor Red "   VERIFIQUE O NOME DO PRODUTO E EXECUTE NOVAMENTE O SCRIPT   "
		Write-Host -ForegroundColor Black -BackgroundColor Red "                                                              "
		Write-Host
		Read-Host
		EXIT
    } Else {
        $folder = $share + "\" + $produto
        cria_prd
    }
} 
nome_prd
}


<#
===================================================================================================================
\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
===================================================================================================================
#>

function cria_prd{
<#
////////////// CADASTRA AS VARIAVEIS DE ARRAY \\\\\\\\\\\\\
#>
$ENG_SUPORTE = New-Object System.Collections.ArrayList
$somente_leitura = New-Object System.Collections.ArrayList
$modificar = New-Object System.Collections.ArrayList
$cada_grupo = New-Object System.Collections.ArrayList

<#
////////////// CONFIGURA AS PERMISSÕES DOS STORAGES NAS VARIAVEIS \\\\\\\\\\\\\
#>
$acl_rx = Get-Acl "$share\modelo\nas_rx"
$acl_rw = Get-Acl "$share\modelo\nas_rw"

<#
////////////// CRIA A PASTA RAIZ E CONFIGURA \\\\\\\\\\\\\
#>
Write-Host  -foregroundcolor red "========================================"
Write-Host  -foregroundcolor red "          CRIANDO PASTA RAIZ"
Write-Host  -foregroundcolor red "========================================"
New-Item -ItemType directory -Path $folder | Out-Null
$acl_folder = Get-ACL $folder

Set-Acl $folder $acl_rx
Write-Host "CONFIGURANDO CONTROLE TOTAL NA PASTA $share\$produto"
<#
////////////// CONFIGURA A PERMISSÃO FULL CONTROL NA PASTA \\\\\\\\\\\\\
#>
foreach ($usuarios_suporte in $ENG_SUPORTE){
	$permissoespasta = get-acl $folder
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($usuarios_suporte)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	set-acl $folder $permissoespasta
}
$duser = $null
$accessrule = $null
$permissoespasta = $null

<#
////////////// CADASTRA OS GRUPOS DE CONTROLE TOTAL E SOMENTE LEITURA \\\\\\\\\\\\\
#>

$ENG_SUPORTE.Clear()
$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null
$ENG_SUPORTE.Add("DOMINIO_FILHO\Domain Admins") > $null

$somente_leitura.Clear()
$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR1") > $null
$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR2") > $null
$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR3") > $null
$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR4") > $null
$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR5") > $null
$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR6") > $null
#$somente_leitura.Add("DOMINIO_EXT\" + $produto + "_SETOR6") > $null
$somente_leitura.Add("DOMINIO_FILHO\" + $produto + "_SETOR7") > $null
$somente_leitura.Add("DOMINIO\_SETOR8") > $null
$somente_leitura.Add("DOMINIO\_SETOR9") > $null
$somente_leitura.Add("DOMINIO\usuario_especifico") > $null
$somente_leitura.Add("DOMINIO\SETOR10") > $null
$somente_leitura.Add("DOMINIO\SETOR11") > $null
$somente_leitura.Add("DOMINIO\SETOR12") > $null
$somente_leitura.Add("DOMINIO\SETOR13") > $null
$somente_leitura.Add("DOMINIO\SETOR14") > $null

<#
////////////// CONFIGURA A PERMISSÃO SOMENTE LEITURA NA PASTA \\\\\\\\\\\\\
#>
Write-Host "CONFIGURANDO SOMENTE LEITURA NA PASTA $share\$produto"

foreach ($grupo_rx in $somente_leitura){
	$permissoespasta = get-acl $folder
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($grupo_rx)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	set-acl $folder $permissoespasta
}
$duser = $null
$accessrule = $null
$permissoespasta = $null

<#
////////////// CONFIGURA A PERMISSÃO SOMENTE LEITURA NA PASTA \\\\\\\\\\\\\
#>
Write-Host
Write-Host
Write-Host  -foregroundcolor red "========================================"
                      Write-Host "          CRIANDO SUBPASTAS"
Write-Host  -foregroundcolor red "========================================"
# ESCRITA
$raiz_escreve = New-Object System.Collections.ArrayList
$raiz_escreve.Clear()
$raiz_escreve.Add("SETOR1") > $null
$raiz_escreve.Add("SETOR3") > $null
$raiz_escreve.Add("SETOR4") > $null
$raiz_escreve.Add("_SETOR8") > $null
$raiz_escreve.Add("SETOR15") > $null
$raiz_escreve.Add("SETOR10") > $null
$raiz_escreve.Add("_SETOR9") > $null
$raiz_escreve.Add("SETOR6") > $null
$raiz_escreve.Add("SETOR7") > $null

#LEITURA
$raiz_leitura = New-Object System.Collections.ArrayList
$raiz_leitura.Clear()
$raiz_leitura.Add("SETOR1") > $null
$raiz_leitura.Add("SETOR3") > $null
$raiz_leitura.Add("SETOR4") > $null
$raiz_leitura.Add("_SETOR8") > $null
$raiz_leitura.Add("SETOR15") > $null
$raiz_leitura.Add("SETOR10") > $null
$raiz_leitura.Add("_SETOR9") > $null
$raiz_leitura.Add("SETOR6") > $null
$raiz_leitura.Add("SETOR7") > $null


foreach ($raiz_rw in $raiz_escreve){
	foreach ($raiz_rx in $raiz_leitura){
		
		if ($raiz_rw -ne $raiz_rx){
			$caminho = $folder + "\" + $raiz_rw + "_" + $raiz_rx
			New-Item -ItemType directory -Path "$caminho" | Out-Null
			Write-Host "Criando $caminho"
		} else {
			continue
		}
	}
}
Write-Host
Write-Host  -foregroundcolor red "========================================"
                      Write-Host "           PASTAS FORA DO LOOP"
Write-Host  -foregroundcolor red "========================================"
Write-Host
New-Item -ItemType directory -Path "$folder\SETOR16_SETOR10" | Out-Null
Write-Host "Criando $folder\SETOR16_SETOR10"
New-Item -ItemType directory -Path "$folder\SETOR17" | Out-Null
Write-Host "Criando $folder\SETOR17"
New-Item -ItemType directory -Path "$folder\SETOR18" | Out-Null
Write-Host "Criando $folder\SETOR18"
New-Item -ItemType directory -Path "$folder\Relatorio" | Out-Null
Write-Host "Criando $folder\Relatorio"
New-Item -ItemType directory -Path "$folder\Relatorio\RELATORIO_SETOR1" | Out-Null
Write-Host "Criando $folder\Relatorio\RELATORIO_SETOR1"
New-Item -ItemType directory -Path "$folder\Relatorio\RELATORIO_SETOR2" | Out-Null
Write-Host "Criando $folder\Relatorio\RELATORIO_SETOR2"
New-Item -ItemType directory -Path "$folder\SETOR19_SETOR6" | Out-Null
Write-Host "Criando $folder\SETOR19_SETOR6"
New-Item -ItemType directory -Path "$folder\SETOR6_SETOR5" | Out-Null
Write-Host "Criando $folder\SETOR6_SETOR5"
New-Item -ItemType directory -Path "$folder\SETOR7_SETOR5" | Out-Null
Write-Host "Criando $folder\SETOR7_SETOR5"
Write-Host
Write-Host
Write-Host "CONFIGURANDO ACESSO SOMENTE LEITURA PARA LINUX EM TODAS AS PASTAS"
Get-ChildItem "$folder" -Recurse | Set-Acl -aclobject $acl_rx
Write-Host "CONFIGURANDO ACESSO ESCRITA PARA LINUX NAS PASTAS COLORGRADE"
Get-ChildItem "$folder\SETOR1*" | Set-Acl -aclobject $acl_rw
Write-Host "CONFIGURANDO ACESSO ESCRITA PARA LINUX NAS PASTAS SETOR7"
Get-ChildItem "$folder\SETOR7*" | Set-Acl -aclobject $acl_rw
Write-Host
Write-Host
Write-Host "=============================###########============================="
Write-Host
Write-Host

<#
##########################
##########################
##########################

DONO DA PASTA

##########################
##########################
##########################
#>

$folder_filhos = Get-Item "$folder\*" | select -ExpandProperty FullName

$dono = New-Object System.Security.Principal.NTAccount("DOMINIO\SUPORTE")
$profilefolder = Get-Item $folder
$acl1 = $profilefolder.GetAccessControl()
$acl1.SetOwner($dono)
Write-Host "CONFIGURANDO SUPORTE COMO DONO DAS PASTAS"
set-acl $folder $acl1

	foreach ($child_folder in $folder_filhos){
    $dono = New-Object System.Security.Principal.NTAccount("DOMINIO\SUPORTE")
    $profilefolder = Get-Item $child_folder
    $acl1 = $profilefolder.GetAccessControl()
    $acl1.SetOwner($dono)
	set-acl $child_folder $acl1
	}

Write-Host
Write-Host
Write-Host "=============================###########============================="
Write-Host
Write-Host
<#
##########################
##########################
##########################

		SETOR16

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================

	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\SETOR11") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\SETOR10") > $null
	
	$folder_tmp = "$folder\SETOR16_SETOR10"

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}

Write-Host
Write-Host

<#
##########################
##########################
##########################

SETOR1

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================
	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\" + $produto + "_SETOR1") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR1") > $null
	
	$folder_dep = Get-Item "$folder\SETOR1*" | select -ExpandProperty FullName
    $folder_dep_rx = Get-Item "$folder\*SETOR1" | select -ExpandProperty FullName

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	foreach ($child_folder in $folder_dep_rx){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}

Write-Host
Write-Host

<#
##########################
##########################
##########################

SETOR17

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================

	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\SETOR10") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR2") > $null
	
	$folder_tmp = "$folder\SETOR17"

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	#foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	#}

Write-Host
Write-Host
<#
##########################
##########################
##########################

SETOR3

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================
	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\" + $produto + "_SETOR3") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR3") > $null
	
	$folder_dep = Get-Item "$folder\SETOR3*" | select -ExpandProperty FullName
	$folder_dep_rx = Get-Item "$folder\*SETOR3" | select -ExpandProperty FullName

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host
	
#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	foreach ($child_folder in $folder_dep_rx){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}

Write-Host
Write-Host
<#
##########################
##########################
##########################

SETOR4

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================
	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\" + $produto + "_SETOR4") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR4") > $null
	
	$folder_dep = Get-Item "$folder\SETOR4*" | select -ExpandProperty FullName
    $folder_dep_rx = Get-Item "$folder\*SETOR4" | select -ExpandProperty FullName

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	foreach ($child_folder in $folder_dep_rx){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}

Write-Host
Write-Host
<#
##########################
##########################
##########################

SETOR8

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================
	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\_SETOR8") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\_SETOR8") > $null
	
	$folder_dep = Get-Item "$folder\SETOR8*" | select -ExpandProperty FullName
    $folder_dep_rx = Get-Item "$folder\*SETOR8" | select -ExpandProperty FullName

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	foreach ($child_folder in $folder_dep_rx){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}

Write-Host
Write-Host
<#
##########################
##########################
##########################

SETOR18

##########################
##########################
##########################
#>

	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\SETOR10") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR2") > $null
	
	$folder_tmp = "$folder\SETOR18"

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	#foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	#}

Write-Host
Write-Host
<#
##########################
##########################
##########################

SETOR15

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================
	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\" + $produto + "_SETOR4") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR4") > $null
	
	$folder_dep = Get-Item "$folder\SETOR15*" | select -ExpandProperty FullName
    $folder_dep_rx = Get-Item "$folder\*SETOR15" | select -ExpandProperty FullName

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	foreach ($child_folder in $folder_dep_rx){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}

Write-Host
Write-Host
<#
##########################
##########################
##########################

SETOR10

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================
	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\SETOR10") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\SETOR10") > $null
	
	$folder_dep = Get-Item "$folder\SETOR10*" | select -ExpandProperty FullName
    $folder_dep_rx = Get-Item "$folder\*SETOR10" | select -ExpandProperty FullName

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	foreach ($child_folder in $folder_dep_rx){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}

Write-Host
Write-Host
<#
##########################
##########################
##########################

SETOR9

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================
	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\_SETOR9") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\_SETOR9") > $null
	
	$folder_dep = Get-Item "$folder\SETOR9*" | select -ExpandProperty FullName
	$folder_dep_rx = Get-Item "$folder\*SETOR9" | select -ExpandProperty FullName

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	foreach ($child_folder in $folder_dep_rx){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}

Write-Host
Write-Host
<#
##########################
##########################
##########################

########  ######## ##          ###    ########  #######  ########  ####  #######  
##     ## ##       ##         ## ##      ##    ##     ## ##     ##  ##  ##     ## 
##     ## ##       ##        ##   ##     ##    ##     ## ##     ##  ##  ##     ## 
########  ######   ##       ##     ##    ##    ##     ## ########   ##  ##     ## 
##   ##   ##       ##       #########    ##    ##     ## ##   ##    ##  ##     ## 
##    ##  ##       ##       ##     ##    ##    ##     ## ##    ##   ##  ##     ## 
##     ## ######## ######## ##     ##    ##     #######  ##     ## ####  #######  

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================

	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$somente_leitura.Clear()
	$somente_leitura.Add("Everyone") > $null
	
	$folder_tmp = "$folder\Relatorio"

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	#foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	#}

Write-Host
Write-Host
<#
##########################
##########################
##########################

RELATORIO_SETOR1

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================

	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\usuario_especifico") > $null
	$modificar.Add("DOMINIO\SETOR12") > $null
	$modificar.Add("DOMINIO\SETOR13") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null

	$somente_leitura.Clear()
	$somente_leitura.Add("Everyone") > $null
	
	$folder_tmp = "$folder\Relatorio\RELATORIO_SETOR1"

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	#foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	#}

Write-Host
Write-Host
<#
##########################
##########################
##########################

RELATORIO_SETOR2

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================

	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\_SETOR8") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null

	$somente_leitura.Clear()
	$somente_leitura.Add("Everyone") > $null
	
	$folder_tmp = "$folder\Relatorio\RELATORIO_SETOR2"

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	#foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	#}

Write-Host
Write-Host
<#
##########################
##########################
##########################

SETOR19

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================

	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\" + $produto + "_SETOR5") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null

	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR5") > $null
	
	$folder_dep = Get-Item "$folder\SETOR19*" | select -ExpandProperty FullName
    $folder_dep_rx = Get-Item "$folder\*SETOR19" | select -ExpandProperty FullName

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== L E I T U R A =================================================

	Write-Host "PERMISSÃO SOMENTE LEITURA"
	foreach ($child_folder in $folder_dep_rx){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}

Write-Host
Write-Host
<#
##########################
##########################
##########################

SETOR6

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================

	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO\" + $produto + "_SETOR6") > $null
	#$modificar.Add("DOMINIO_EXT\" + $produto + "_SETOR6") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO\" + $produto + "_SETOR6") > $null
    #$somente_leitura.Add("DOMINIO_EXT\" + $produto + "_SETOR6") > $null
	
	$folder_dep = Get-Item "$folder\SETOR6*" | select -ExpandProperty FullName
    $folder_dep_rx = Get-Item "$folder\*SETOR6" | select -ExpandProperty FullName

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== L E I T U R A =================================================
	
	foreach ($child_folder in $folder_dep_rx){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}

Write-Host
Write-Host
<#
##########################
##########################
##########################

SETOR7

##########################
##########################
##########################
#>

#=========================== V A R I A V E I S =============================================
	$folder_tmp = $cada_grupo = $permissoespasta = $permissoes = $InheritanceFlag = $PropagationFlag = $objType = $duser = $accessrule = $permissoespasta = $null

	$ENG_SUPORTE.Clear()
	$ENG_SUPORTE.Add("DOMINIO\Domain Admins") > $null
	$ENG_SUPORTE.Add("DOMINIO\SUPORTE") > $null

	$modificar.Clear()
	$modificar.Add("DOMINIO_FILHO\" + $produto + "_SETOR7") > $null
	$modificar.Add("DOMINIO\SETOR14") > $null
	
	$somente_leitura.Clear()
	$somente_leitura.Add("DOMINIO_FILHO\" + $produto + "_SETOR7") > $null
	
	$folder_dep = Get-Item "$folder\SETOR7*" | select -ExpandProperty FullName
    $folder_dep_rx = Get-Item "$folder\*SETOR7" | select -ExpandProperty FullName

#=========================== C O N T R O L E  T O T A L ====================================

	Write-Host "PERMISSÃO CONTROLE TOTAL"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $ENG_SUPORTE){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::FullControl
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== M O D I F I C A R =============================================

	Write-Host "PERMISSÃO MODIFICAR"
	foreach ($child_folder in $folder_dep){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $modificar){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles,Write,ReadAndExecute,Synchronize"
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($cada_grupo)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}
Write-Host

#=========================== L E I T U R A =================================================
	
	foreach ($child_folder in $folder_dep_rx){
	$folder_tmp = $child_folder
	foreach ($cada_grupo in $somente_leitura){
	$permissoespasta = Get-Acl "$folder_tmp"
	$permissoespasta.SetAccessRuleProtection($True, $False)
	$permissoes = [System.Security.AccessControl.FileSystemRights]::ReadAndExecute
	$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None
	$objType = [System.Security.AccessControl.AccessControlType]::Allow
	$duser = New-Object System.Security.Principal.NTAccount($somente_leitura)
	$accessrule = New-Object System.Security.AccessControl.FileSystemAccessRule($duser, $permissoes, $InheritanceFlag, $PropagationFlag, $objType)
	$permissoespasta.AddAccessRule($accessrule)
	Write-Host "CONFIGURANDO A PASTA $folder_tmp"
	set-acl $folder_tmp $permissoespasta
	}
	}


Write-Host
Write-Host
<#
##########################
##########################
##########################

   ###    ##     ## ########  #### ########  #######  ########  ####    ###    
  ## ##   ##     ## ##     ##  ##     ##    ##     ## ##     ##  ##    ## ##   
 ##   ##  ##     ## ##     ##  ##     ##    ##     ## ##     ##  ##   ##   ##  
##     ## ##     ## ##     ##  ##     ##    ##     ## ########   ##  ##     ## 
######### ##     ## ##     ##  ##     ##    ##     ## ##   ##    ##  ######### 
##     ## ##     ## ##     ##  ##     ##    ##     ## ##    ##   ##  ##     ## 
##     ##  #######  ########  ####    ##     #######  ##     ## #### ##     ## 

##########################
##########################
##########################
#>

$TargetFolders = Get-Childitem $folder -Recurse | Where {$_.PsIsContainer} | Sort-Object FullName | Select-Object -ExpandProperty FullName
$AuditUser = "Everyone"
$AuditRules = "DeleteSubdirectoriesAndFiles, Delete, ChangePermissions"
$InheritType = "ContainerInherit,ObjectInherit"
$AuditType = "Success"
$AccessRule = New-Object System.Security.AccessControl.FileSystemAuditRule($AuditUser,$AuditRules,$InheritType,"None",$AuditType)

	$ACL = (Get-Item $folder).GetAccessControl('Access')
	$ACL.SetAuditRule($AccessRule)
	$acl.SetAuditRuleProtection($true,$false)
	Write-Host "Configurando >",$folder
	$ACL | Set-Acl $folder

FOREACH ($TargetFolder in $TargetFolders)
{
	$ACL = (Get-Item $TargetFolder).GetAccessControl('Access')
	$ACL.SetAuditRule($AccessRule)
	$acl.SetAuditRuleProtection($true,$false)
	Write-Host "Configurando >",$TargetFolder
	$ACL | Set-Acl $TargetFolder	

}

$TargetFolder = "$folder"
$AuditUser = "Everyone"
$AuditRules = "DeleteSubdirectoriesAndFiles, Delete, ChangePermissions"
$InheritType = "None"
$AuditType = "Success"
$AccessRule = New-Object System.Security.AccessControl.FileSystemAuditRule($AuditUser,$AuditRules,$InheritType,"None",$AuditType)
$ACL = (Get-Item $TargetFolder).GetAccessControl('Access')
$ACL.SetAuditRule($AccessRule)
Write-Host " "
Write-Host "Configurando >",$TargetFolder
$ACL | Set-Acl $TargetFolder
Write-Host "Auditoria aplicada com sucesso."


contigencia
}


function contigencia{

$contg = $contingencia + "\" + $produto

$contg_existe = Test-Path $contg 

If ($contg_existe -eq $True) {
    Write-Host
    Write-Host
    Write-Host
    Write-Host
    Write-Host
    Write-Host -ForegroundColor DarkGreen -BackgroundColor Yellow "                                                                     "
    Write-Host -ForegroundColor DarkGreen -BackgroundColor Yellow "  CRIAÇÃO DE PASTAS FINALIZADA! PRESSIONE QUALQUER TECLA PARA SAIR   "
    Write-Host -ForegroundColor DarkGreen -BackgroundColor Yellow "                                                                     "
    Read-Host
    EXIT

} Else {

    $folder = $contingencia + "\" + $produto
    Write-Host
    Write-Host
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Cyan "                              "
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Cyan "  CRIANDO PASTA CONTINGENCIA  "
    Write-Host -BackgroundColor DarkCyan -ForegroundColor Cyan "                              "
    Write-Host

    cria_prd

}

}




menu