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
$GetChildParamFiles = @{
	File = $true
	Recurse = $true
}
$TranscribeActive = 'no'



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



### MENU ###
# Text Menu
Write-Host "`n`n--- MENU ---" -ForegroundColor green
Write-Host "`n1 - Find permissions given to " -NoNewLine
Write-Host "EVERYONE" -NoNewLine -ForegroundColor cyan
Write-Host " in ALL SHARES"
Write-Host "2 - Find permissions given to " -NoNewLine
Write-Host "EVERYONE" -NoNewLine -ForegroundColor cyan
Write-Host " in a TARGET SHARE"
Write-Host "3 - Find permissions given to " -NoNewLine
Write-Host "GENERIC USER GROUPS" -NoNewLine -ForegroundColor cyan
Write-Host " in ALL SHARES"
Write-Host "4 - Find permissions given to " -NoNewLine
Write-Host "GENERIC USER GROUPS" -NoNewLine -ForegroundColor cyan
Write-Host " in a TARGET SHARE"
Write-Host "5 - Dump " -NoNewLine
Write-Host "ALL USERS/GROUPS" -NoNewLine -ForegroundColor cyan
Write-Host " present in ALL SHARES"
Write-Host "6 - Dump " -NoNewLine
Write-Host "ALL USERS/GROUPS" -NoNewLine -ForegroundColor cyan
Write-Host " present in a TARGET SHARE"
Write-Host "7 - Dump " -NoNewLine
Write-Host "ALL PERMISSIONS" -NoNewLine -ForegroundColor cyan
Write-Host " assigned in ALL SHARES"
Write-Host "8 - Dump " -NoNewLine
Write-Host "ALL PERMISSIONS" -NoNewLine -ForegroundColor cyan
Write-Host " assigned in a TARGET SHARE"
Write-Host "9 - Search " -NoNewLine
Write-Host "TARGET USER" -NoNewLine -ForegroundColor cyan
Write-Host " Permissions in ALL SHARES"
Write-Host "10 - Search " -NoNewLine
Write-Host "TARGET USER" -NoNewLine -ForegroundColor cyan
Write-Host " Permissions in a TARGET SHARE"
Write-Host "11 - Dump " -NoNewLine
Write-Host "LastModifiedDate and Size" -NoNewLine -ForegroundColor cyan
Write-Host " of FILES from ALL SHARES into a CSV"
Write-Host "12 - Dump " -NoNewLine
Write-Host "LastModifiedDate and Size" -NoNewLine -ForegroundColor cyan
Write-Host " of FILES from a TARGET SHARE into a CSV"
Write-Host "13 - Check where " -NoNewLine
Write-Host "INHERITANCE" -NoNewLine -ForegroundColor cyan
Write-Host " is DISABLED in a TARGET share"
Write-Host "14 - " -NoNewLine
Write-Host "Copy Targeted File List" -NoNewLine -ForegroundColor cyan
Write-Host " to the a new Location"
Write-Host "15 - " -NoNewline
Write-Host "Remove all explicit permissions" -NoNewLine -ForegroundColor cyan
Write-Host " of a target user"
# Choise loop
do {
	$choise = Read-Host -Prompt "`nSpecify function number"
	if ($choise -match '^\d+$') {
		break
	} else {
		Write-Host "Invalid input, please try again" -ForegroundColor yellow
	}
} while ($true)



### GENERAL FUNCTION & GLOBAL CHOISES ###
# Suppress error choise
Write-Host "`n--- Want to suppress errors? ---`n" -ForegroundColor green
$SuppressErrorChoise = Read-Host -Prompt "yes / no"
If ($SuppressErrorChoise -eq 'yes') {
	$ErrorActionPreference = 'silentlycontinue'
}

# Start Logging Function
Write-Host "`n--- Output Logging ---`n" -ForegroundColor green
Write-Host "Leave blank to not produce logs" -ForegroundColor yellow
Write-Host "If you want to log output into a file specify a file name" -ForegroundColor yellow
Write-Host "e.g. logfile.txt`n" -ForegroundColor red
$loggingOutputChoise = Read-Host
if ($loggingOutputChoise -ne '') {
	Start-Transcript -Path "$loggingOutputChoise" -Append
	$TranscribeActive = 'yes'
}

# Function to dump FileServ/SVM SHARES
function dumpAllShares {
	Write-Host "`n--- Specify target SVM/SERVER ---" -ForegroundColor green
	Write-Host "`nPay attention to sintax" -ForegroundColor yellow
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
	ForEach ($share in $shares){ 
		Write-Host $share 
	}
	return @{
		P = $rootPath
		S = $shares
	}
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
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
	$shares = $shareDump.S
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
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
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
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
	$shares = $shareDump.S
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
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
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
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
	$shares = $shareDump.S
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
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
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
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
	$shares = $shareDump.S
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
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
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
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
	$shares = $shareDump.S
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
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
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

# 11 - Dump FILES LastModifiedDate and Size from ALL SHARES
If ($choise -eq '11') {
	$CSVFileName = ""
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
	$shares = $shareDump.S
	$DepthParam = SetDepth
	Write-Host "`n--- CSV Filename ---`n" -ForegroundColor green
	Write-Host "Specify the CSV Filename to use to save the dump" -ForegroundColor yellow
	Write-Host "e.g. filesInfo.csv`n" -ForegroundColor red
	while ($CSVFileName -eq "") {
		$CSVFileName = Read-Host  
		if ($CSVFileName -eq "") {
			Write-Host "Filename cannot be empty. Please try again`n" -ForegroundColor yellow
		}
	}
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n`n" -ForegroundColor green
	$fileInfoArray = @() # Array to store files info
	$shares | 
	ForEach-Object { $fullPath = $rootPath + $_ ; Get-ChildItem "$fullPath" @GetChildParamFiles @DepthParam | 
		ForEach-Object { $file = $_ ;
			$file.Fullname ; # Print status
			$fileInfo = New-Object PSObject ; 	# Create a new object with the file path and last modified date
			$fileInfo | Add-Member -MemberType NoteProperty -Name "FilePath" -Value $file.FullName ;
			$fileInfo | Add-Member -MemberType NoteProperty -Name "LastModifiedDate" -Value $file.LastWriteTime ;
			$fileInfo | Add-Member -MemberType NoteProperty -Name "Size in bytes" -Value $file.Length ;
			[array]$fileInfoArray += $fileInfo ; # Add the new object to the array
		} ; 
	} ;
	$fileInfoArray = $fileInfoArray | Sort-Object LastModifiedDate # Sort the array by last modified date (from older to newer)
	$fileInfoArray | Export-Csv -Path "$CSVFileName" -NoTypeInformation # Export the array to a CSV file
	Write-Host "`n--- Dump saved on " -NoNewline -ForegroundColor green
	Write-Host "$CSVFileName" -NoNewLine -ForegroundColor yellow
	Write-Host " ---`n" -ForegroundColor green
	Write-Host "---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green	
}

# 12 - Dump FILES LastModifiedDate and Size from a TARGET SHARE
If ($choise -eq '12') {
	$CSVFileName = ""
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
	Write-Host "`n--- Which share do you want to scan ? ---`n" -ForegroundColor green # Prompt for attribute to look for
	$targetShare = Read-Host
	$DepthParam = SetDepth
	Write-Host "`n--- CSV Filename ---`n" -ForegroundColor green
	Write-Host "Specify the CSV Filename to use to save the dump" -ForegroundColor yellow
	Write-Host "e.g. filesInfo.csv`n" -ForegroundColor red
	while ($CSVFileName -eq "") {
		$CSVFileName = Read-Host  
		if ($CSVFileName -eq "") {
			Write-Host "Filename cannot be empty. Please try again`n" -ForegroundColor yellow
		}
	}
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n`n" -ForegroundColor green
	$fileInfoArray = @() # Array to store files info
	$fullPath = $rootPath + $targetShare ; 
	Get-ChildItem "$fullPath" @GetChildParamFiles @DepthParam | 
		ForEach-Object { $file = $_ ;
			$file.Fullname ; #Print status
			$fileInfo = New-Object PSObject ; 	# Create a new object with the file path and last modified date
			$fileInfo | Add-Member -MemberType NoteProperty -Name "FullPath" -Value $file.FullName ;
			$fileInfo | Add-Member -MemberType NoteProperty -Name "LastModifiedDate" -Value $file.LastWriteTime ;
			$fileInfo | Add-Member -MemberType NoteProperty -Name "Size in bytes" -Value $file.Length ;
			[array]$fileInfoArray += $fileInfo ; # Add the new object to the array
		} ; 
		$fileInfoArray = $fileInfoArray | Sort-Object LastModifiedDate # Sort the array by last modified date (from older to newer)
		$fileInfoArray | Export-Csv -Path "$CSVFileName" -NoTypeInformation # Export the array to a CSV file
		Write-Host "`n--- Dump saved on " -NoNewline -ForegroundColor green
		Write-Host "$CSVFileName" -NoNewLine -ForegroundColor yellow
		Write-Host " ---`n" -ForegroundColor green	
	Write-Host "---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green	
}

# 13 - Check where INHERITANCE is DISABLED in a TARGET share
If ($choise -eq '13') {
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P
	Write-Host "`n--- Which share do you want to scan ? ---`n" -ForegroundColor green # Prompt for attribute to look for
	$targetShare = Read-Host
	$DepthParam = SetDepth
	$foldersWithInheritanceDisabled = @()
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n" -ForegroundColor green
	$fullPath = $rootPath + $targetShare # Define the full path
	Get-ChildItem "$fullPath" @GetChildParam @DepthParam | 
	
	ForEach-Object { $folder = $_ ;
		$acl = Get-Acl $folder.FullName ;
		if ($acl.AreAccessRulesProtected) {
        $foldersWithInheritanceDisabled += $folder.Fullname	# If inheritance is disabled, add the folder to the array
		}
	}
	Write-Host "`n--- Folder with inheritance Disabled ---`n" -ForegroundColor green
	$foldersWithInheritanceDisabled		# display results
	Write-Host "`n---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 14 - Copy Targeted Files to the new Path 
If ($choise -eq '14') {
	$csvFile = ""
	Write-Host "`n--- CSV in input with files list ---" -ForegroundColor green
	Write-Host "The CSV file need to contain a column named 'FullPath' which contains target files fullpath`n" -ForeGroundColor yellow
	while ($csvFile -eq "") {
		$csvFile = Read-Host  
		if ($csvFile -eq "") {
			Write-Host "CSV file name cannot be empty. Please try again`n" -ForegroundColor yellow
		}
	}
	$destinationRoot = ""
	Write-Host "`n--- Destionation root path ---" -ForegroundColor green
	Write-Host "e.g. Z:\ `n" -ForeGroundColor red
	while ($destinationRoot -eq "") {
		$destinationRoot = Read-Host  
		if ($destinationRoot -eq "") {
			Write-Host "Destination path cannot be empty. Please try again`n" -ForegroundColor yellow
		}
	}
	# Progress bar
	$progress = @{
		Activity = "Copying files..."
		Status = "Progress:"
		PercentComplete = 0
	}
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n" -ForegroundColor green
	$csvPath = Resolve-Path $csvFile
	$csvData = Import-Csv -Path $csvPath
	# Main cycle
	foreach ($row in $csvData) {
		$relativePathFirstClean = $row.FullPath -replace [regex]::Escape('\\'), '\'
		$relativePath = $relativePathFirstClean -replace [regex]::Escape(':\'), '\'
		### $relativePath = $row.FullPath -replace [regex]::Escape($sourceRoot), "" # Relative path if source path is to be removed
		$destinationPath = Join-Path -Path $destinationRoot -ChildPath $relativePath # Destination path
		$destinationDir = Split-Path -Path $destinationPath -Parent # Folder hierarchy creation
		if (!(Test-Path -Path $destinationDir)) {
			New-Item -ItemType Directory -Path $destinationDir | Out-Null
			if (!(Test-Path -Path $destinationDir)) { 
				Write-Host "X" -NoNewLine -ForeGroundColor red 
				Write-Host " - Failed created $destinationDir"
			} else {
				Write-Host "V" -NoNewLine -ForeGroundColor green 
				Write-Host " - Successfully created $destinationDir"
			}
		}
		Copy-Item -Path $row.FullPath -Destination $destinationPath # Copy target file
		if (Test-Path -Path $destinationPath) { # Copy Verification
			Write-Host "V" -NoNewLine -ForeGroundColor green 
			Write-Host " - Successfully copied $($row.FullPath)"
		} else {
			Write-Host "X" -NoNewLine -ForeGroundColor red 
			Write-Host " - Failed to copy $($row.FullPath)"
		}    
		$progress.PercentComplete = ($csvData.IndexOf($row) / $csvData.Count) * 100 # Update the progress bar
		Write-Progress @progress
	}
	# Progress bar complete
	$progress.PercentComplete = 100
	Write-Progress @progress
	Write-Host "`n---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}

# 15 - Delete explicit permissions about target user/group
If ($choise -eq '15') {
	$shareDump = dumpAllShares
	$rootPath = $shareDump.P 
	Write-Host "`n--- Which share do you want to scan ? ---`n" -ForegroundColor green # Prompt for attribute to look for
	$targetShare = Read-Host
	$TargetUserName = SetTargetUser
	Write-Host "`n--- Specify User Domain ---`n" -ForegroundColor green
	$userDomain = Read-Host
	$finalDomainUser = "$userDomain\$TargetUserName"
	$DepthParam = SetDepth
	Write-Host "`n--- Are you sure to delete permissions of $finalDomainUser ? ---" -ForegroundColor green
	Write-Host "Click to start" -ForegroundColor yellow
	$waitInput = Read-host
	Write-Host "`n---------------" -ForegroundColor green
	Write-Host "--- Started ---" -ForegroundColor green
	Write-Host "---------------`n`n" -ForegroundColor green
	$fullPath = $rootPath + $targetShare # Define the full path
	Get-ChildItem "$fullPath" @GetChildParam @DepthParam | 
	ForEach-Object { $TPath = $_ ;
		$acl = Get-Acl -Path $TPath.FullName ;
		$acl.Access | Where-Object {
			$_.IdentityReference -eq $finalDomainUser	
		} |
		ForEach-Object {
			$TFullPath = $TPath.FullName
			Write-Host "VVV Removing permissions from VVV" -ForegroundColor green
			Write-Host "$TFullPath"
			$acl.RemoveAccessRule($_)
			Set-Acl -Path $TPath.FullName -AclObject $acl ;
		} ;
	}
	Write-Host "'n---------------------" -ForegroundColor green
	Write-Host "--- Completed \m/ ---" -ForegroundColor green
	Write-Host "---------------------`n" -ForegroundColor green
}	
	
	

### Close task if opened ###
# Stop Logging Function 
if ($TranscribeActive -eq 'yes') {
	Stop-Transcript | Out-Null
	Write-Host "--- Logging Stopped ---`n" -ForegroundColor green
}

### END ###
