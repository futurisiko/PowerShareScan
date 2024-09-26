# PowerShareScan

Powershell Script/Tool to perform various scans to dump Security permission of FileServer and/or SVM.<br>
***ATTENTION > Keep in mind that it will consider just folders, not files.*** <br>
For the tool purpose it's inhalf to check folders and also make the job of iterating easier. <br>

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


--- Specify target SVM/SERVER ---

Pay attention to sintax.
e.g. \\SVM\

\\TARGETFILESERVER\

--- SHARES on \\TARGETFILESERVER\ ---

Share1
Share2
Share3

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

Specify function number:
```

Possible options do exaclty what they say.
After you choise the scan type some additional info will be required. <br>

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
If the function dump output to a csv file it asks to specify csv filename too use.


