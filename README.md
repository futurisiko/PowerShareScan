# PowerShareScan

Powershell Script/Tool to perform various scans to dump Security permission of FileServer and/or SVM.<br>
***ATTENTION > Keep in mind that most of permission analysis will consider just folders, not files.*** <br>
<br>

```
PS C:\Temp> .\PowerShareScan.ps1


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


--- MENU ---

1 - Find permissions given to EVERYONE in ALL SHARES
2 - Find permissions given to EVERYONE in a TARGET SHARE
3 - Find permissions given to GENERIC USER GROUPS in ALL SHARES
4 - Find permissions given to GENERIC USER GROUPS in a TARGET SHARE
5 - Dump ALL USERS/GROUPS present in ALL SHARES
6 - Dump ALL USERS/GROUPS present in a TARGET SHARE
7 - Dump ALL PERMISSIONS assigned in ALL SHARES
8 - Dump ALL PERMISSIONS assigned in a TARGET SHARE
9 - Search TARGET USER Permissions in ALL SHARES
10 - Search TARGET USER Permissions in a TARGET SHARE
11 - Dump LastModifiedDate and Size of FILES from ALL SHARES into a CSV
12 - Dump LastModifiedDate and Size of FILES from a TARGET SHARE into a CSV
13 - Check where INHERITANCE is DISABLED in a TARGET share
14 - Copy Targeted File List to the a new Location

Specify function number:
```

Options do exaclty what they say.
After you choise the scan type some additional info can be be required depending of the fucntion chosen. <br>

```
--- Want to suppress errors? ---

yes / no:
```
Specify ```yes``` if you want to suppress annoying errors in the terminal <br>
```
--- Output Logging ---

Leave blank to not produce logs
If you want to log output into a file specify a file name
e.g logfile.txt
```
Specify a filename if you want to save/log all scan's output into a file <br>
```
--- Specify target SVM/SERVER ---

Pay attention to sintax
e.g. \\SVM\
```
Specify the target FileServer or SVM. <br>
```
--- SHARES on \\TARGETFILESERVER\ ---

Share1
Share2

--- Which share do you want to scan ? ---
```
If you choose a scan that target a specific share you will have to specify it. <br>

```
--- Scan Depth ---

Leave blank to scan recursevely all folders
Or specify the depth of the scan numerically
e.g. 1, 2, 3
```
Specify the depth level of the scan. 1 will check just root folders present in the share. Leave it blank to recursevely check everything. <br>

```
--- CSV Filename ---

Specify the CSV Filename to use to save the dump
e.g. filesInfo.csv
```
If the function dump output to a csv file it asks to specify csv filename too use.<br>
```
--- CSV in input with files list ---
The CSV file need to contain a column named 'FullPath' which contains target files fullpath
```
The copy function will require a csv file as input.
```
--- Destionation root path ---
e.g. Z:\
```
The copy function will require also a target path to copy to.

