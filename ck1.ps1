# Updated for luma 9.1 and steelminer for 11.7-11.9
$bootndsMD5 = "7374B600F947CF16E31D6967B0CE647C"
$boot3dsxMD5 = "0DE027B0447B4470CB796AFB94B4CDF2"
$payloadNewUS = "349EB973101E32F5975B4D13682F4ED0"
$payloadNewEU = "CFE01ED181F84FE46A59610D6F14B8D2"
$payloadNewJP = "415B6C2F2709F4931B51D199CF3CBE1E"
$payloadOldUS = "90206185C514C9A31CAB9A17B33BB83E"
$payloadOldEU = "11CA69DAE3FE3B850A7DA14A2AF3B60B"
$payloadOldJP = "F6830F00218DAF599F1F607ED39CA9B4"
$bootfirmMD5 = "F7C0D04AB092E3707A4020154F49B4D5"
$codebinMD5 = "75956D94937AD596921D165BB5044F1A"
$ropbinMD5 = "1674E05F3179FF50138C0C862BF88EB1"
$USsteeldiver="000d7d00"
$EUsteeldiver="000d7e00"
$JPsteeldiver="000d7c00"

$frogcertMD5="39A1B894B9F85C9B1998D172EF4DCC3A"
$frogtoolMD5="2511BC883FA69C2F79424784344737E8"
$mode = 0
function PauseExit {
    cmd.exe /c pause
    exit;
}
function fail() {

}
function getMD5($filepath) {
    $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    return ([System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($filepath))).replace("-",""));
}
Clear-Host;
$drive = $null
$drv = Read-Host "What drive letter is your SD at?"
$drv = $drv.replace(':','').replace('\','');
Get-WMIObject -Query "SELECT * FROM Win32_DiskPartition" | Foreach-Object {
    $part=$_
    Get-WmiObject -Query "Associators of {Win32_DiskPartition.DeviceID='$($_.DeviceID)'} where AssocClass=Win32_LogicalDiskToPartition" | ForEach-Object {
        $dsk=$_
        Get-WmiObject -Query "SELECT * from Win32_Volume WHERE DriveLetter='$($_.DeviceID)'" | ForEach-Object {
            $vol = $_
            New-Object -Type PSCustomObject -Property @{
                PartitionStyle=$part.Type
                DriveLetter=$dsk.DeviceID.Substring(0,1)
                FileSystem=$vol.FileSystem
            }
        }
    }
} | ForEach-Object {if ($_.DriveLetter -eq $drv) {$drive=$_;} }

if (-not $drive.DriveLetter -eq $drv -or $drv -eq "") {
    write-host "Cannot find drive $drv";
    PauseExit;
}
if ($drive.FileSystem -eq "FAT32" ) {
    write-host "Drive is Formatted FAT32 - Good"
}elseif($drive.FileSystem -eq "FAT") {
    write-host "Drive is Formatted FAT - This may be ok"
}else{
    write-host "Drive is formatted $($drive.FileSystem) and not FAT32 - BAD.`nReformat drive with guiformat"
    PauseExit;
}


#*****************************************************************************************************
write-host "Checking Nintendo 3ds folder for incorrect file placement"
$n3dsfiles =  Get-ChildItem -Path "$($drive.DriveLetter):/\Nintendo 3ds\" | Where-Object { -not $_.PSIsContainer }
foreach ($fn in $n3dsfiles) {
        if ($fn.name -match 'boot.3dsx') {
           write-host "Found boot.3dsx file in the Nintendo 3ds folder, this is the incorrect folder for boot.3dsx file.`nAttempting to move.";
           Move-Item -Path "$($drive.DriveLetter):/Nintendo 3ds/boot.3dsx" -Destination "$($drive.DriveLetter):/";
        }
        if ($fn.name -match '.3dsx$') {
            write-host "Found .3dsx file in the Nintendo 3ds folder, this is the incorrect folder for .3dsx files";
        }
        if ($fn.name -match '.nds$') {
            write-host "Found .nds file in the Nintendo 3ds folder, this is the incorrect folder for .nds files";
        }
        if ($fn.name -match '.firm$') {
            write-host "Found .firm file in the Nintendo 3ds folder, this is the incorrect folder for .firm files";
        }
}


#*****************************************************************************************************

$mode = Read-Host "`ndo you want to check steelminer installation files?"
$mode=$mode.substring(0,1);
if ($mode.toupper() -eq "Y") {

    Write-Host "`n**CHECKING STEELMINER FILES**`n"
    $gamedir="FFFFFFFF";
    if (Test-Path -Path "$($drive.DriveLetter):/Nintendo 3ds/steelhax/" ) {
        write-host "Your steelhax folder is in the wrong place, attempting to move it to SD root: $($drive.DriveLetter):/steelhax/`n";
        Move-Item -Path "$($drive.DriveLetter):/Nintendo 3ds/steelhax/" -Destination "$($drive.DriveLetter):/";
    }
    $file=(getMD5("$($drive.DriveLetter):/steelhax/payload.bin"));
    #if (Test-Path -Path "$($drive.DriveLetter):/boot.nds" ) {
    if ($file)    {
        if ($file -eq $payloadNewUS) {
            write-host "You seem to have the NEW console payload. Assuming your system is n3ds, n3dsXL, or n2dsXL";
            write-host "You seem to have the USA region payload, assuming version 11.9.0-42U in settings";
            $gamedir=$USsteeldiver;
        }elseif ($file -eq $payloadNewEU) {
            write-host "You seem to have the NEW console payload. Assuming your system is n3ds, n3dsXL, or n2dsXL";
            write-host "You seem to have the EUR region payload, assuming version 11.9.0-42E in settings";
            $gamedir=$EUsteeldiver;
        }elseif ($file -eq $payloadNewJP) {
            write-host "You seem to have the NEW console payload. Assuming your system is n3ds, n3dsXL, or n2dsXL";
            write-host "You seem to have the JPN region payload, assuming version 11.9.0-42J in settings";
            $gamedir=$JPsteeldiver;
        }elseif ($file -eq $payloadOldUS) {
            write-host "You seem to have the OLD console payload. Assuming your system is o3ds, o3dsXL, or o2ds (not foldable)";
            write-host "You seem to have the USA region payload, assuming version 11.9.0-42U in settings";
            $gamedir=$USsteeldiver;
        }elseif ($file -eq $payloadOldEU) {
            write-host "You seem to have the OLD console payload. Assuming your system is o3ds, o3dsXL, or o2ds (not foldable)";
            write-host "You seem to have the EUR region payload, assuming version 11.9.0-42E in settings";
            $gamedir=$EUsteeldiver;
        }elseif ($file -eq $payloadOldJP) {
            write-host "You seem to have the OLD console payload. Assuming your system is o3ds, o3dsXL, or o2ds (not foldable)";
            write-host "You seem to have the JAP region payload, assuming version 11.9.0-42J in settings";
            $gamedir=$JPsteeldiver;
        }else{
            Write-Host "payload.bin is incorrect. This can be caused by incorrect number choices when downloading otherapp, or corruption during copying to SD.`n"
            PauseExit;
        }
    }else {
        if (Test-Path -Path "$($drive.DriveLetter):/steelhax/payload.bin.bin" ) {
            write-host "payload.bin was named incorrectly. This is likely due to having file extensions hidden.`nAttempting to rename it for you.`n";
            Rename-Item -Path "$($drive.DriveLetter):/steelhax/payload.bin.bin" -newname "payload.bin";
            if (-not (Test-Path -Path "$($drive.DriveLetter):/steelhax/payload.bin" )) {
                write-host "Failed to rename. Please remove the .bin from the end of your payload file and run this tool again.`n";
                PauseExit;
            }else{
                write-host "File renamed successfully. Please turn on file extensions to avoid future complications.`n";
            }
        }else{
            write-host "payload.bin does not exist.`n";
            PauseExit;
        }
    }
    #Write-Host "`n`n"
    write-host "Checking for any steel diver updates and checking for save file size`n"
    $n3dsfolder = Get-ChildItem -Path "$($drive.DriveLetter):/\Nintendo 3ds\" | Where-Object { $_.PSIsContainer }
    foreach ($id0 in $n3dsfolder)
    {
        if (-not ($id0.name.length -eq 32)) {
            continue
        }
        $id1folders = Get-ChildItem -Path "$($id0.fullname)" |  Where-Object { $_.PSIsContainer } 
        foreach ($id1 in $id1folders){
            if (-not $id1.name.length -eq 32) { 
                continue
            }
             #if (Test-Path -Path "$($drive.DriveLetter):/boot.nds" ) {
            if (Test-Path -Path "$($id1.fullname)\title\0004000e\$($gamedir)" ) {
                write-host "You have the steel diver update installed. Be sure to delete it from settings->data management->3ds->downloadable content (or addons)";
                write-host "update was found in: $($id1.fullname)`n";

            }
            foreach ($sav in Get-ChildItem "$($id1.fullname)\title\00040000\$($gamedir)\data\" -ErrorVariable errsav -ErrorAction SilentlyContinue) {
                if (-not $sav.length -eq 524288) {
                    Write-Host "Extra or incorrect files in data directory: $($sav.fullname)`n"
                }else{
                    Write-Host "save file is the correct size in data directory: $($id1.fullname)\title\00040000\$($gamedir)\data\`n"
                    $found=1; 
                }
            }
        }

    }
    if ($errsav -and -not $found) {
        write-Host "Steel Diver save file does not exist or you have the wrong region payload. Verify the region listed above.`n";
        $errsav = "";
        PauseExit;
    }

    $file=(getMD5("$($drive.DriveLetter):/boot.3dsx"));
    if ($file) {
        if ($file -eq $boot3dsxMD5) {
            write-host "boot.3dsx exists - Good"
        }else{
            write-host "boot.3dsx is wrong.`nMD5 is        $file`nMD5 should be $boot3dsxMD5`nRedownload Homebrew Launcher. Put boot.3dsx on the SD at $($drive.DriveLetter):\boot.3dsx"
            PauseExit;
        }
    }else {
        write-host "boot.3dsx does not exist.`nRedownload Homebrew Launcher. Put boot.3dsx on the SD at $($drive.DriveLetter):\boot.3dsx"
        PauseExit;
    }
    $file=(getMD5("$($drive.DriveLetter):/steelhax/code.bin"));
    if ($file) {
        if ($file -eq $codebinMD5) {
            write-host "code.bin exists - Good"
        }else{
            write-host "code.bin is wrong.`nMD5 is        $file`nMD5 should be $codebinMD5`nRedownload steelhax and extract the steelhax folder."
            PauseExit;
        }
    }else {
        write-host "code.bin does not exist.`nRedownload steelhax and extract the steelhax folder."
        PauseExit;
    }
    $file=(getMD5("$($drive.DriveLetter):/steelhax/rop.bin"));
    if ($file) {
        if ($file -eq $ropbinMD5) {
            write-host "rop.bin exists - Good"
        }else{
            write-host "rop.bin is wrong.`nMD5 is        $file`nMD5 should be $ropbinMD5`nRedownload steelhax and extract the steelhax folder."
            PauseExit;
        }
    }else {
        write-host "rop.bin does not exist.`nRedownload steelhax and extract the steelhax folder."
        PauseExit;
    }

}

$mode = Read-Host "`ndo you want to check b9stool (dsiware exploit installation. eg. frogminer, fredminer, seedminer)?"
$mode=$mode.substring(0,1);
if ($mode.toupper() -eq "Y") {

    Write-Host "`n**CHECKING *MINER FILES**`n"
    $file=(getMD5("$($drive.DriveLetter):/boot.nds"));
    #if (Test-Path -Path "$($drive.DriveLetter):/boot.nds" ) {
    if ($file)    {
        if ($file -eq $bootndsMD5) {
            write-host "boot.nds exists - Good";
        }else{
            Write-Host "boot.nds is wrong. `nMD5 is        $file`nMD5 should be $bootndsMD5`nRedownload b9stool and put the file on the SD root at $($drive.DriveLetter):\boot.nds"
            PauseExit;
        }
    }else {
        write-host "boot.nds does not exist."
        PauseExit;
    }
}

$mode = Read-Host "`ndo you want to check frogminer files?"
$mode=$mode.substring(0,1);
if ($mode.toupper() -eq "Y") {
    Write-Host "`n**CHECKING FROGMINER FILES**`n"
    $file=(get-item -path "$($drive.DriveLetter):/movable.sed" -ErrorAction SilentlyContinue)
    #$file=(getMD5("$($drive.DriveLetter):/boot.firm"));
    if ($file) {
        if ($file.length -eq 320) {
            write-host "movable.sed exists - Good"
        }else{
            write-host "movable.sed is wrong.`nfile should be 320 bytes.`n"
            PauseExit;
        }
    }else {
        write-host "movable.sed does not exist.`nRedownload your movable.sed and put it in SD root."
        PauseExit;
    }
    $file=(getMD5("$($drive.DriveLetter):/frogcert.bin"));
    if ($file) {
        if ($file -eq $frogcertMD5) {
            write-host "frogcert.bin exists - Good"
        }else{
            write-host "frogcert.bin is wrong.`nMD5 is        $file`nMD5 should be $frogcertMD5`nRedownload frogcert with a Torrent client. Put frogcert.bin on the SD at $($drive.DriveLetter):\frogcert.bin"
            PauseExit;
        }
    }else {
        write-host "frogcert.bin does not exist.`nRedownload frogcert with a Torrent client. Put frogcert.bin on the SD at $($drive.DriveLetter):\frogcert.bin"
        PauseExit;
    }
    $file=(getMD5("$($drive.DriveLetter):/3ds/frogtool.3dsx"));
    if ($file) {
        if ($file -eq $frogtoolMD5) {
            write-host "frogtool.3dsx exists - Good"
        }else{
            write-host "frogtool.3dsx is wrong.`nMD5 is        $file`nMD5 should be $frogtoolMD5`nRedownload frogtool and put it on the SD at $($drive.DriveLetter):\3ds\frogtool.3dsx"
            PauseExit;
        }
    }else {
        write-host "frogtool.3dsx does not exist.`nRedownload frogtool and put it on the SD at $($drive.DriveLetter):\3ds\frogtool.3dsx"
        PauseExit;
    }
}

#*****************************************************************************************************

$mode = Read-Host "`ndo you want to check luma3ds boot files?"
$mode=$mode.substring(0,1);
if ($mode.toupper() -eq "Y") {

    Write-Host "`n**CHECKING LUMA FILES**`n"
    $file=(getMD5("$($drive.DriveLetter):/boot.firm"));
    if ($file) {
        if ($file -eq $bootfirmMD5) {
            write-host "boot.firm exists - Good"
        }else{
            write-host "boot.firm is wrong.`nMD5 is        $file`nMD5 should be $bootfirmMD5`nRedownload Luma3ds. Make sure to use 7-zip to extract it to get the boot.firm"
            PauseExit;
        }
    }else {
        write-host "boot.firm does not exist.`nRedownload Luma3ds. Make sure to use 7-zip to extract it to get the boot.firm"
        PauseExit;
    }
    $file=(getMD5("$($drive.DriveLetter):/boot.3dsx"));
    if ($file) {
        if ($file -eq $boot3dsxMD5) {
            write-host "boot.3dsx exists - Good"
        }else{
            write-host "boot.3dsx is wrong.`nMD5 is        $file`nMD5 should be $boot3dsxMD5`nRedownload Homebrew Launcher. Put boot.3dsx on the SD at $($drive.DriveLetter):\boot.3dsx"
            PauseExit;
        }
    }else {
        write-host "boot.3dsx does not exist.`nRedownload Homebrew Launcher. Put boot.3dsx on the SD at $($drive.DriveLetter):\boot.3dsx"
        PauseExit;
    }
}

Write-Host "`n`nEverything seems to be in order. if you are having issues, let us know on the Nintendo Homebrew discord`n"
PauseExit
