###############################
### PowerShareScan.ps1
###
### Powershell script ensemble
### to performe various network
### shares scan.
###
### By Nik aka Futurisiko
###############################



### VARIABLES ####
# Default Variable Setup
$ErrorActionPreference = 'continue'
$SuppressErrorChoise = 'no'
$GetChildParam = @{
	Directory = $true
	Recurse = $true
}



### BANNER ###
Write-Host @"


    dMMMMb  .aMMMb  dMP dMP dMP dMMMMMP dMMMMb 
   dMP.dMP dMP dMP dMP dMP dMP dMP     dMP.dMP 
  dMMMMP  dMP dMP dMP dMP dMP dMMMP   dMMMMK  
 dMP     dMP.aMP dMP.dMP.dMP dMP     dMP AMF   
dMP      VMMMP   VMMMPVMMP  dMMMMMP dMP dMP    
                                               
   .dMMMb  dMP dMP .aMMMb  dMMMMb  dMMMMMP     
  dMP  VP dMP dMP dMP dMP dMP.dMP dMP          
  VMMMb  dMMMMMP dMMMMMP dMMMMK  dMMMP         
dP .dMP dMP dMP dMP dMP dMP AMF dMP            
VMMMP  dMP dMP dMP dMP dMP dMP dMMMMMP         
                                               
   .dMMMb  .aMMMb  .aMMMb  dMMMMb              
  dMP  VP dMP VMP dMP dMP dMP dMP              
  VMMMb  dMP     dMMMMMP dMP dMP               
dP .dMP dMP.aMP dMP dMP dMP dMP                
VMMMP   VMMMP  dMP dMP dMP dMP  By Futurisiko
"@ -ForegroundColor magenta



### TARGET IDENTIFICATION & MENU ###
# Specify target
Write-Host "`n`n--- Specify target SVM/SERVER ---" -ForegroundColor green
Write-Host "`nPay attention to sintax." -ForegroundColor yellow
Write-Host "e.g. \\SVM\`n" -ForegroundColor red
$rootPath = Read-Host

# Run the net view command, capture its output and filter DISK word
$output = net view $rootPath | 
ForEach-Object { ($_ -split 'Disk')[0] } | 
ForEach-Object { ($_ -split 'Disco')[0] }

# Filter the output to capture lines after the dashes until "The command completed successfully."
$shares = $output |
Select-String -Pattern "----" -Context 0, 1000 | # Use Select-String to find the dash line and capture the following lines
ForEach-Object { $_.Context.PostContext } | # Get the lines following the dash line
Where-Object { $_ -notmatch "The command completed successfully" } | # Exclude the final line
Where-Object { $_ -notmatch "Esecuzione comando riuscita" } |
Where-Object { $_ -match "\S" } | # Filter lines that contain non-whitespace characters
ForEach-Object { $_.Trim() } # Trim whitespace from each line

# Print Shares found
Write-Host "`n--- SHARES on " -NoNewline -ForegroundColor green
Write-Host "$rootPath" -NoNewLine -ForegroundColor yellow
Write-Host " --- `n" -ForegroundColor green
$shares

# Text Menu
Write-Host "`n--- MENU ---" -ForegroundColor green
Write-Host "`n1 - Find permissions given to EVERYONE in ALL SHARES"
Write-Host "2 - Find permissions given to EVERYONE in a TARGET SHARE"
Write-Host "3 - Find permissions given to GENERIC USER GROUPS in ALL SHARES"
Write-Host "4 - Find permissions given to GENERIC USER GROUPS in a TARGET SHARE"
Write-Host "5 - Dump ALL USERS/GROUPS present in ALL SHARES"
Write-Host "6 - Dump ALL USERS/GROUPS present in a TARGET SHARE"
Write-Host "7 - Dump ALL PERMISSIONS assigned in ALL SHARES"
Write-Host "8 - Dump ALL PERMISSIONS assigned in a TARGET SHARE"
Write-Host "9 - Search TARGET USER Permissions in ALL SHARES"
Write-Host "10 - Search TARGET USER Permissions in a TARGET SHARE"
$choise = Read-Host -Prompt "`nSpecify function number"



### GENERAL FUNCTION & GLOBAL CHOISES ###
# Suppress error choise
Write-Host "`n--- Want to suppress errors? ---`n" -ForegroundColor green
$SuppressErrorChoise = Read-Host -Prompt "yes / no"
If ($SuppressErrorChoise -eq 'yes') {
	$ErrorActionPreference = 'silentlycontinue'
}

# Function to choise depth
function SetDepth {
	Write-Host "`n--- Scan Depth ---`n" -ForegroundColor green
	Write-Host "Leave blank to scan recursevely all folders" -ForegroundColor yellow
	Write-Host "Or specify the depth of the scan numerically " -ForegroundColor yellow
	Write-Host "e.g. 1, 2, 3`n" -ForegroundColor red
	$depth = Read-Host
	if ($depth -ne '') {
		$depth -= 1
		$DepthParam = @{ 
			Depth = $depth
		}
	}
	return $DepthParam
}

# Function to choise target user
function SetTargetUser {
	$TargetUser = ""
	Write-Host "`n--- Target Username ---`n" -ForegroundColor green
	Write-Host "Specify the target username to look for`n" -ForegroundColor yellow
	while ($TargetUser -eq "") {
		$TargetUser = Read-Host  
		if ($TargetUser -eq "") {
			Write-Host "Username cannot be empty. Please try again`n" -ForegroundColor yellow
		}
	}
	return $TargetUser
}



### OPERATIONS ###
# 1 - EVERYONE Permission in ALL Shares function
If ($choise -eq '1') {
	$DepthParam = SetDepth
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n`n" -ForegroundColor green
	$shares | ForEach-Object { $fullPath = $rootPath + $_ ; Get-ChildItem "$fullPath" @GetChildParam @DepthParam | 
		Where-Object { Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access | 
		Where-Object { $_.IdentityReference -match "Everyone" } } } | 
	ForEach-Object { Write-Host $_.FullName -ForegroundColor green ; Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access |  
		Where-Object { $_.IdentityReference -match "Everyone" } |
		Select-Object FileSystemRights, IdentityReference }	| FL 2>$null
	Write-Host "---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 2 - EVERYONE Permission in a TARGET share
If ($choise -eq '2') {
	Write-Host "`n--- SHARES on " -NoNewline -ForegroundColor green
	Write-Host "$rootPath" -NoNewLine -ForegroundColor yellow
	Write-Host " --- `n" -ForegroundColor green
	$shares
	Write-Host "`n--- Which share do you want to scan ? ---`n" -ForegroundColor green # Prompt for attribute to look for
	$targetShare = Read-Host
	$DepthParam = SetDepth
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n`n" -ForegroundColor green
	$fullPath = $rootPath + $targetShare # Define the full path
	Get-ChildItem "$fullPath" @GetChildParam @DepthParam | 
	Where-Object { Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access | 
		Where-Object { $_.IdentityReference -match 'Everyone' } } | 
	ForEach-Object { Write-Host $_.FullName -ForegroundColor green ; Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access |  
		Where-Object { $_.IdentityReference -match 'Everyone' } |
		Select-Object FileSystemRights, IdentityReference }	| FL 2>$null
	Write-Host "---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 3 - GENERIC USER GROUPS Permission in ALL shares
If ($choise -eq '3') {
	$DepthParam = SetDepth
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n`n" -ForegroundColor green
	$shares | ForEach-Object { $fullPath = $rootPath + $_ ; Get-ChildItem "$fullPath" @GetChildParam @DepthParam | 
		Where-Object { Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access | 
		Where-Object { $_.IdentityReference -match 'Users' } } } | 
	ForEach-Object { Write-Host $_.FullName -ForegroundColor green; Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access | 
		Where-Object { $_.IdentityReference -match 'Users' } | 
		Select-Object FileSystemRights, IdentityReference} | FL 2>$null
	Write-Host "---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 4 - GENERIC USER GROUPS Permission in a TARGET share
If ($choise -eq '4') {
	Write-Host "`n--- SHARES on " -NoNewline -ForegroundColor green
	Write-Host "$rootPath" -NoNewLine -ForegroundColor yellow
	Write-Host " --- `n" -ForegroundColor green
	$shares
	Write-Host "`n--- Which share do you want to scan ? ---`n" -ForegroundColor green # Prompt for attribute to look for
	$targetShare = Read-Host
	$DepthParam = SetDepth
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n`n" -ForegroundColor green
	$fullPath = $rootPath + $targetShare # Define the full path
	Get-ChildItem "$fullPath" @GetChildParam @DepthParam | 
	Where-Object { Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access | 
		Where-Object { $_.IdentityReference -match 'Users' } } | 
	ForEach-Object { Write-Host $_.FullName -ForegroundColor green ; Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access |  
		Where-Object { $_.IdentityReference -match 'Users' } |
		Select-Object FileSystemRights, IdentityReference }	| FL 2>$null
	Write-Host "---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 5 - DUMP ALL USERS/GROUPS present in ALL shares
If ($choise -eq '5') {
	If (Test-Path "temp_list") {
		Remove-Item "temp_list"
	}
	$DepthParam = SetDepth
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n" -ForegroundColor green
	$shares | ForEach-Object { $fullPath = $rootPath + $_ ; Get-ChildItem "$fullPath" @GetChildParam @DepthParam |
		ForEach-Object {
		Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access | 
		Select-Object -ExpandProperty IdentityReference |
		Out-File "temp_list" -Width 4096 -Append
		}
	}
	Get-Content .\temp_list |
    Where-Object { $_ -match "\S" -and $_ -notmatch "Value" -and $_ -notmatch "IdentityReference" -and $_ -notmatch "-----" } |
	Where-Object { $_ -match "\S" } | # Filter lines that contain non-whitespace characters
	ForEach-Object { $_.Trim() } | # Trim whitespace from each line
    Sort-Object -Unique |
    Group-Object |
    Select-Object Name |
    ForEach-Object {
        Write-Host "$($_.Name)"
    }
	If (Test-Path "temp_list") {
		Remove-Item "temp_list"
	}	
	Write-Host "`n---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 6 - DUMP ALL USERS/GROUPS present in a TARGET share
If ($choise -eq '6') {
	If (Test-Path "temp_list") {
		Remove-Item "temp_list"
	}
	Write-Host "`n--- SHARES on " -NoNewline -ForegroundColor green
	Write-Host "$rootPath" -NoNewLine -ForegroundColor yellow
	Write-Host " --- `n" -ForegroundColor green
	$shares
	Write-Host "`n--- Which share do you want to scan ? ---`n" -ForegroundColor green # Prompt for attribute to look for
	$targetShare = Read-Host
	$DepthParam = SetDepth
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n" -ForegroundColor green
	$fullPath = $rootPath + $targetShare # Define the full path
	Get-ChildItem "$fullPath" @GetChildParam @DepthParam |
	ForEach-Object {
		Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access | 
		Select-Object -ExpandProperty IdentityReference |
		Out-File "temp_list" -Width 4096 -Append
	}
	Get-Content .\temp_list |
    Where-Object { $_ -match "\S" -and $_ -notmatch "Value" -and $_ -notmatch "IdentityReference" -and $_ -notmatch "-----" } |
	Where-Object { $_ -match "\S" } | # Filter lines that contain non-whitespace characters
	ForEach-Object { $_.Trim() } | # Trim whitespace from each line
    Sort-Object -Unique |
    Group-Object |
    Select-Object Name |
    ForEach-Object {
        Write-Host "$($_.Name)"
    }
	If (Test-Path "temp_list") {
		Remove-Item "temp_list"
	}	
	Write-Host "`n---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 7 - DUMP ALL PERMISSIONS assigned in ALL SHARES
If ($choise -eq '7') {
	If (Test-Path "temp_list") {
		Remove-Item "temp_list"
	}
	$DepthParam = SetDepth
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n" -ForegroundColor green
	$shares | ForEach-Object { $fullPath = $rootPath + $_ ; Get-ChildItem "$fullPath" @GetChildParam @DepthParam |
		ForEach-Object {
			Get-Acl $_.FullName |
			Select-Object -ExpandProperty Access |
			Select-Object FileSystemRights, IdentityReference |
			Out-File "temp_list" -Width 4096 -Append
		}
	}
	Get-Content .\temp_list |
    Where-Object { $_ -match "\S" -and $_ -notmatch "FileSystemRights" -and $_ -notmatch "----------------" -and $_ -notmatch "\\\\" } |
	ForEach-Object { $_.Trim() } |
	Sort-Object |
	Group-Object |
	Select-Object Name, Count |
	ForEach-Object {
		Write-Host "$($_.Name) : $($_.Count)"
	}
	If (Test-Path "temp_list") {
		Remove-Item "temp_list"
	}	
	Write-Host "`n---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 8 - DUMP ALL PERMISSIONS assigned in a TARGET share
If ($choise -eq '8') {
	If (Test-Path "temp_list") {
		Remove-Item "temp_list"
	}
	Write-Host "`n--- SHARES on " -NoNewline -ForegroundColor green
	Write-Host "$rootPath" -NoNewLine -ForegroundColor yellow
	Write-Host " --- `n" -ForegroundColor green
	$shares
	Write-Host "`n--- Which share do you want to scan ? ---`n" -ForegroundColor green # Prompt for attribute to look for
	$targetShare = Read-Host
	$DepthParam = SetDepth
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n" -ForegroundColor green
	$fullPath = $rootPath + $targetShare # Define the full path
	Get-ChildItem "$fullPath" @GetChildParam @DepthParam |
	ForEach-Object {
		Get-Acl $_.FullName |
		Select-Object -ExpandProperty Access |
		Select-Object FileSystemRights, IdentityReference |
		Out-File "temp_list" -Width 4096 -Append
	}
	Get-Content .\temp_list |
    Where-Object { $_ -match "\S" -and $_ -notmatch "FileSystemRights" -and $_ -notmatch "----------------" -and $_ -notmatch "\\\\" } |
	ForEach-Object { $_.Trim() } |
	Sort-Object |
	Group-Object |
	Select-Object Name, Count |
	ForEach-Object {
		Write-Host "$($_.Name) : $($_.Count)"
	}
	If (Test-Path "temp_list") {
		Remove-Item "temp_list"
	}	
	Write-Host "`n---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 9 - Search TARGET USER Permissions in ALL SHARES
If ($choise -eq '9') {
	$TargetUserName = SetTargetUser
	$DepthParam = SetDepth
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n`n" -ForegroundColor green
	$shares | ForEach-Object { $fullPath = $rootPath + $_ ; Get-ChildItem "$fullPath" @GetChildParam @DepthParam | 
		Where-Object { Get-Acl $_.FullName | 
			Select-Object -ExpandProperty Access | 
			Where-Object { $_.IdentityReference -match "$TargetUserName" } } | 
		ForEach-Object { Write-Host $_.FullName -ForegroundColor green ; Get-Acl $_.FullName | 
			Select-Object -ExpandProperty Access |  
			Where-Object { $_.IdentityReference -match "$TargetUserName" } |
			Select-Object FileSystemRights, IdentityReference }	| FL 2>$null
	}
	Write-Host "---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 10 - Search TARGET USER Permissions in a TARGET SHARE
If ($choise -eq '10') {
	Write-Host "`n--- SHARES on " -NoNewline -ForegroundColor green
	Write-Host "$rootPath" -NoNewLine -ForegroundColor yellow
	Write-Host " --- `n" -ForegroundColor green
	$shares
	Write-Host "`n--- Which share do you want to scan ? ---`n" -ForegroundColor green # Prompt for attribute to look for
	$targetShare = Read-Host
	$TargetUserName = SetTargetUser
	$DepthParam = SetDepth
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n`n" -ForegroundColor green
	$fullPath = $rootPath + $targetShare # Define the full path
	Get-ChildItem "$fullPath" @GetChildParam @DepthParam | 
	Where-Object { Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access | 
		Where-Object { $_.IdentityReference -match "$TargetUserName" } } | 
	ForEach-Object { Write-Host $_.FullName -ForegroundColor green ; Get-Acl $_.FullName | 
		Select-Object -ExpandProperty Access |  
		Where-Object { $_.IdentityReference -match "$TargetUserName" } |
		Select-Object FileSystemRights, IdentityReference }	| FL 2>$null
	Write-Host "---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

### END ###