# PowerShareScan

PowerShareScan is an interactive PowerShell tool to scan Windows/SMB network shares on a File Server or NetApp SVM and review NTFS permissions, inheritance settings, file metadata, and targeted file-copy operations.

> **Attention**
> Most permission-analysis functions scan **folders/directories only**, not files. File-specific operations are limited to the CSV export and copy functions described below.

## Features

- Enumerate shares from a target file server or SVM.
- Search for permissions assigned to `Everyone`.
- Search for permissions assigned to generic user groups matching `Users`.
- Dump all users/groups found in ACLs.
- Dump and count all permission assignments.
- Search permissions for a target user or group.
- Export file `LastModifiedDate` and file size to CSV.
- Find folders where inheritance is disabled.
- Copy a list of files from a CSV to a new destination while recreating the folder structure.
- Remove explicit permissions for a target domain user/group.
- Search for a target user/group with a specific permission in a target share.
- Optional console error suppression.
- Optional transcript logging to a file.

## Requirements

- Windows with PowerShell.
- Network access to the target File Server or SVM.
- Permissions to enumerate the target shares and read NTFS ACLs.
- For option `15`, write permissions on the target ACLs are required because the script modifies permissions.
- The target server/SVM must be reachable using UNC syntax, for example:

```powershell
\\SVM\
```

The script uses `net view` to enumerate shares and parses both English and Italian output markers (`Disk` / `Disco`, and command-completed messages).

## Usage

Run the script from PowerShell:

```powershell
PS C:\Temp> .\PowerShareScan.ps1
```

The script shows an interactive menu and asks for additional input depending on the selected function.

## Menu Options

| # | Function | Scope | Main output / action |
|---|----------|-------|----------------------|
| 1 | Find permissions given to `Everyone` | All shares | Folder paths and matching ACL entries |
| 2 | Find permissions given to `Everyone` | Target share | Folder paths and matching ACL entries |
| 3 | Find permissions given to generic user groups matching `Users` | All shares | Folder paths and matching ACL entries |
| 4 | Find permissions given to generic user groups matching `Users` | Target share | Folder paths and matching ACL entries |
| 5 | Dump all users/groups present in ACLs | All shares | Unique identity references |
| 6 | Dump all users/groups present in ACLs | Target share | Unique identity references |
| 7 | Dump all permissions assigned | All shares | Permission + identity combinations with occurrence counts |
| 8 | Dump all permissions assigned | Target share | Permission + identity combinations with occurrence counts |
| 9 | Search target user/group permissions | All shares | Folder paths and matching ACL entries |
| 10 | Search target user/group permissions | Target share | Folder paths and matching ACL entries |
| 11 | Dump file metadata to CSV | All shares | CSV with file path, last modified date, and size |
| 12 | Dump file metadata to CSV | Target share | CSV with full path, last modified date, and size |
| 13 | Check where inheritance is disabled | Target share | Folder paths with protected ACL inheritance |
| 14 | Copy targeted file list to a new location | CSV input | Copies files and recreates folder hierarchy |
| 15 | Remove all explicit permissions of a target user/group | Target share | Modifies ACLs recursively |
| 16 | Find target user/group with a target permission | Target share | Folder paths and matching ACL entries |

## Common Prompts

### Suppress Errors

```text
--- Want to suppress errors? ---
yes / no:
```

Enter `yes` to set `$ErrorActionPreference` to `SilentlyContinue` and suppress many console errors. Any other value leaves error handling as `Continue`.

### Output Logging

```text
--- Output Logging ---
Leave blank to not produce logs
If you want to log output into a file specify a file name
e.g. logfile.txt
```

Leave the prompt blank to avoid logging. Provide a filename to start a PowerShell transcript with `Start-Transcript -Append`. At the end of the script, the transcript is stopped automatically if it was started.

### Target File Server / SVM

```text
--- Specify target SVM/SERVER ---
Pay attention to syntax
e.g. \\SVM\
```

Provide the root UNC path of the server or SVM. The script enumerates shares using `net view` and then displays the detected shares.

### Target Share

```text
--- Which share do you want to scan ? ---
```

For target-share functions, enter the share name exactly as listed by the script. The final path is built by concatenating the root path and the share name.

Example:

```text
Root path:   \\SVM\
Share name:  Share1
Full path:   \\SVM\Share1
```

### Scan Depth

```text
--- Scan Depth ---
Leave blank to scan recursively all folders
Or specify the depth of the scan numerically
e.g. 1, 2, 3
```

Leave blank to recurse through all child items. Enter a number to limit recursion depth. User input is internally reduced by `1` before being passed to `Get-ChildItem -Depth`; for example, entering `1` scans only the first visible level for that operation.

### Target Username

```text
--- Target Username ---
Specify the target username to look for
```

Used by options `9`, `10`, `15`, and `16`. The value cannot be empty.

Depending on the function, the script uses either regex-like matching (`-match`) or exact matching (`-eq`) against `IdentityReference`:

- Options `9` and `16` use `-match`.
- Option `10` uses `-eq`.
- Option `15` builds `DOMAIN\username` and uses `-eq`.

## Detailed Function Notes

### Options 1 and 2: Find `Everyone` Permissions

Scans folders and returns paths where an ACL entry has an `IdentityReference` matching `Everyone`. For each matching folder, the script prints:

- Folder path
- `FileSystemRights`
- `IdentityReference`

Option `1` scans all detected shares. Option `2` scans one selected share.

### Options 3 and 4: Find Generic User Group Permissions

Scans folders and returns paths where an ACL entry has an `IdentityReference` matching `Users`. This is useful for identifying permissions granted to broad/generic user groups.

Option `3` scans all detected shares. Option `4` scans one selected share.

### Options 5 and 6: Dump All Users/Groups

Scans ACLs and extracts all unique `IdentityReference` values found on folders.

The script temporarily writes intermediate results to a file named `temp_list` in the current working directory, then removes it at the end of the operation.

Option `5` scans all detected shares. Option `6` scans one selected share.

### Options 7 and 8: Dump All Assigned Permissions

Scans ACLs and extracts `FileSystemRights` and `IdentityReference` pairs, groups identical entries, and prints the occurrence count.

The script temporarily writes intermediate results to a file named `temp_list` in the current working directory, then removes it at the end of the operation.

Option `7` scans all detected shares. Option `8` scans one selected share.

### Options 9 and 10: Search Target User/Group Permissions

Searches folders where a target user/group appears in ACLs and prints the matching permission entries.

Option `9` scans all detected shares and uses `-match`, so partial matches may return results. Option `10` scans one selected share and uses exact `IdentityReference` matching with `-eq`.

Examples of target username input:

```text
DOMAIN\username
username
GroupName
```

For exact matching functions, provide the identity in the same format used in the ACL.

### Options 11 and 12: Export File Metadata to CSV

These options scan files, not folders, and export metadata sorted by `LastModifiedDate` from oldest to newest.

Option `11` scans all detected shares and exports these columns:

```text
FilePath, LastModifiedDate, Size in bytes
```

Option `12` scans one selected share and exports these columns:

```text
FullPath, LastModifiedDate, Size in bytes
```

> **Important for option 14**
> Option `14` expects a CSV column named `FullPath`. The CSV produced by option `12` is directly compatible. If you want to use the CSV produced by option `11`, rename the `FilePath` column to `FullPath` before using it as input for option `14`.

### Option 13: Find Disabled Inheritance

Scans folders in a target share and prints folders where ACL inheritance is disabled. Internally, the script checks whether `AreAccessRulesProtected` is set on the folder ACL.

### Option 14: Copy Targeted File List

Copies files listed in a CSV to a new destination root.

The input CSV must contain a column named:

```text
FullPath
```

Prompt sequence:

```text
--- CSV in input with files list ---
The CSV file need to contain a column named 'FullPath' which contains target files fullpath

--- Destination root path ---
e.g. Z:\
```

For each row, the script:

1. Reads the source path from `FullPath`.
2. Builds a destination path under the selected destination root.
3. Recreates the required directory hierarchy.
4. Copies the file with `Copy-Item`.
5. Verifies whether the destination file exists.
6. Shows copy progress using `Write-Progress`.

The path reconstruction replaces UNC and drive-root separators so that the source hierarchy is preserved under the destination root.

### Option 15: Remove All Explicit Permissions of a Target User/Group

> **Warning: destructive operation**
> This option modifies ACLs. Review the target path, target identity, and scope carefully before running it. Make sure you have a backup or an approved rollback plan.

This option removes explicit ACL entries for a target domain user/group from folders in a selected share.

Prompt sequence:

```text
--- Which share do you want to scan ? ---
--- Target Username ---
--- Specify User Domain ---
--- Scan Depth ---
--- Are you sure to delete permissions of DOMAIN\username ? ---
Click to start
```

The script combines the domain and username as:

```text
DOMAIN\username
```

Then it recursively scans folders according to the selected depth and removes ACL rules whose `IdentityReference` exactly equals that value.

### Option 16: Find Target User/Group with Target Permission

Searches a selected share for folders where both conditions match:

- `IdentityReference` matches the target user/group.
- `FileSystemRights` matches the target permission string.

Prompt sequence:

```text
--- Which share do you want to scan ? ---
--- Target Username ---
--- Which specific permission are you looking for ? ---
e.g. FullControl, Modify, Read, Execute
--- Scan Depth ---
```

The permission input is matched against `FileSystemRights`, so values such as `FullControl`, `Modify`, `Read`, or `Execute` can be used depending on how permissions are represented in the ACL output.

## CSV Examples

### CSV compatible with option 14

```csv
FullPath,LastModifiedDate,Size in bytes
\\SVM\Share1\Folder\file1.txt,2024-01-01 10:00:00,12345
\\SVM\Share1\Folder\file2.docx,2024-01-02 11:30:00,67890
```

### Rename `FilePath` to `FullPath`

If you exported files with option `11`, update the first column name before using the CSV with option `14`:

```csv
FullPath,LastModifiedDate,Size in bytes
```

## Operational Notes

- Permission-analysis functions use directory recursion by default.
- File metadata export functions use file recursion by default.
- Output-heavy functions can generate many terminal lines on large shares.
- Options `5`, `6`, `7`, and `8` use a temporary file named `temp_list` in the current directory.
- Logging uses PowerShell transcript mode and appends to the chosen log file.
- The script is interactive and does not expose command-line parameters.

## License

This project is released under the GNU General Public License v3.0. See `LICENSE` for details.
