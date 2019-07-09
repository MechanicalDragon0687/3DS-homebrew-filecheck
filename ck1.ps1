# Updated for luma 10.0.1 and steelminer for 11.7-11.10
#b9stool v5.0.1 current as of 8 June 2019
$bootndsMD5 = "1876FC7BD0DDDB4D1DDE86D3850A5D08"
$bootndsURL = "https://api.github.com/repos/zoogie/b9sTool/releases/latest"

#new-hbmenu v2.0.1
$boot3dsxMD5 = "E90217FCE291717804B7522755AE20CA"
$boot3dsxURL = "https://api.github.com/repos/fincs/new-hbmenu/releases/latest"
#otherapp 11.10
$payloadNewUS = "349EB973101E32F5975B4D13682F4ED0"
$payloadNewEU = "41EDFA4A2EEDD5A7EEDF4B937CC7D267"
$payloadNewJP = "415B6C2F2709F4931B51D199CF3CBE1E"
$payloadOldUS = "90206185C514C9A31CAB9A17B33BB83E"
$payloadOldEU = "1848440DED1AC8F01D91FC33D4D5EC25"
$payloadOldJP = "F6830F00218DAF599F1F607ED39CA9B4"

#luma3ds v10.0.1
$bootfirmMD5 = "3961A676E8017808B31D37136766C36D"
$bootfirmURL = "https://api.github.com/repos/AuroraWright/Luma3DS/releases/latest"
#steelhax
$codebinMD5 = "75956D94937AD596921D165BB5044F1A"
$ropbinMD5 = "1674E05F3179FF50138C0C862BF88EB1"
$steelhaxURL = "https://github.com/VegaRoXas/vegaroxas.github.io/raw/master/files/steelhax-installer.rar"
$USsteeldiver="000d7d00"
$EUsteeldiver="000d7e00"
$JPsteeldiver="000d7c00"
#frogcert - Current as of 22 Apr 2019
$frogcertMD5="39A1B894B9F85C9B1998D172EF4DCC3A"
#Frogtool 2.2
$frogtoolMD5="2511BC883FA69C2F79424784344737E8"
$frogtoolURL = "https://api.github.com/repos/zoogie/Frogtool/releases/latest"
#Flipnote Save
$flipnoteMD5="61C6A702D6616F057D52197294DB11FD"
$flipnoteURL="https://github.com/zoogie/Frogminer/raw/master/private/ds/app/4B47554A/001/T00031_1038C2A757B77_000.ppm"

 #[regex]::Match((curl -uri https://api.github.com/repos/zoogie/b9sTool/releases/latest).content, '\"browser_download_url\":\"([^\"]*)"').Groups[1].Value

$checkFormat = $true;
$checkFiles = $true;
$checkSteelhax = $false;
$checkB9sTool = $false;
$checkFrogtool = $false;
$checkFredtool = $false;
$checkLuma = $false;
$drive = $null;
$download = $false;
$choice = "";
$ErrorActionPreference = 'silentlycontinue'
#$script:drive;

function DownloadFile() {
    param([String]$url, [String]$file,[String]$Path,[bool]$unzip=$false,[bool]$githubAPI=$false)
    if ($githubAPI) {
        $content = (Invoke-WebRequest -uri "$($url)").content
        $url = [regex]::Match($content, '\"browser_download_url\":\"([^\"]*)"').Groups[1].Value
    }
    write-Host "Downloading $($url)"
    $downloadName="$($Path)/$($file)"
    if ($unzip) {
        $downloadName += ".zip"
    }else{
        $downloadName += ".temp"
    }
    (new-object System.Net.WebClient).DownloadFile( $url, "$($downloadName)");
    if ($unzip) {
        if ($url -match ".zip$") {
            expand-archive -literalPath "$($downloadName)" -DestinationPath "$($Path)/$($file).temp.dir/"
            $item = get-childitem -Recurse -Path "$($Path)/$($file).temp.dir/" -Filter "$($file)"
            Move-Item -Destination "$($Path)/$($file)" -Path $item.fullname
            Remove-Item -Recurse -Path "$($Path)/$($file).temp.dir"
            Remove-Item -Recurse -Path $downloadName
        }
    }else{
            Move-Item -Destination "$($Path)/$($file)" -Path "$($Path)/$($file).temp"
    }
}
function isEnabled() {
    param([bool]$check = $false)
    if ( $check -eq $true ) {
        return "X";
    }else{
        return " ";
    }
    return " ";
}

function PauseExit {
    Write-Host "`nPress any Key to exit...`n"
    [void][System.Console]::ReadKey($FALSE)
    exit;
}
function Pause {
    Write-Host "`nPress any Key to continue...`n"
    [void][System.Console]::ReadKey($FALSE)
}
function fail() {

}
function getMD5($filepath) {
    $md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    return ([System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($filepath))).replace("-",""));
}

function ShowMenu() {
    Clear-Host;
    Write-Host "`n`n   3DS Homebrew/CFW installation Check Tool`n`tBy MechDragon`n`n"
    write-host "  1.`t[$(isEnabled $checkFormat)] Check SD Format";
    write-host "  2.`t[$(isEnabled $checkFiles)] Check SD File Placement";
    write-host "  3.`t[$(isEnabled $checkSteelhax)] Check Steelhax Files";
    write-host "  4.`t[$(isEnabled $checkB9sTool)] Check B9sTool (miner)";
    write-host "  5.`t[$(isEnabled $checkFrogtool)] Check Frogtool Files";
    write-host "  6.`t[$(isEnabled $checkFredtool)] Check Fredtool Files";
    write-host "  7.`t[$(isEnabled $checkLuma)] Check Luma Files";
    write-host "`n  [R]un Check(s)";
    write-host   "  [Q]uit`n";
    $choice=read-host "Pick an option: ";
    return $choice.Replace('r','R').replace('q','Q');
}
function GetDrive() {
    Clear-Host;
    Write-Host "`n`n   3DS Homebrew/CFW installation Check Tool`n`tBy MechDragon`n`n"
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
    return $drive
}

######### Check format type of SD card
function CheckSDFormat() {
    if ($drive.FileSystem -eq "FAT32" ) {
        write-host "Drive is Formatted FAT32"  -ForegroundColor White -BackgroundColor DarkGreen
        return $true;
    }elseif($drive.FileSystem -eq "FAT") {
        write-host "Drive is Formatted FAT - This may be ok"  -ForegroundColor Black -BackgroundColor Yellow
        return $true;
    }else{
        write-host "Drive is formatted $($drive.FileSystem) and not FAT32.`nReformat drive with guiformat."  -ForegroundColor White -BackgroundColor DarkRed
        Pause;
        return $false;
    }
    Pause;
    return $false;
}

function Exists() {
    param([String]$dir,
          [String[]]$file )
          return ($null -ne $(Get-ChildItem -Path "$($dir)" -Filter "$($file)"));
}

######## Check SD Card for misplaced files
function checkSDFiles() {
    write-host "Checking SD root for misnamed files" -BackgroundColor Gray -ForegroundColor Black
    $misnamed = gci "$($drive.DriveLetter):\" -Recurse -Depth 1 |where-object { $_.Name -match "(boot|payload|movable)\s\(\d+\).*"} # find all items named "boot (#)*" then rename all the boot (#).firm/nds/etc to remove the " (#)"
    foreach ($toRN in $misnamed) {
        write-host "Found $($toRN.Name). Attempting to fix the name." -ForegroundColor Black -BackgroundColor Yellow;
        rename-item -NewName $($toRN.Name -replace " \([0-9]+\)",'') -literalPath $toRN.Fullname
    }
    $misnamed = gci "$($drive.DriveLetter):\" |where-object { $_.Name -match "(boot|payload|movable)_\d+.*"} # find all items named "boot_#*" then rename all the boot_#.firm/nds/etc to remove the "_#"
    foreach ($toRN in $misnamed) {
        write-host "Found $($toRN.Name). Attempting to fix the name." -ForegroundColor Black -BackgroundColor Yellow;
        rename-item -NewName $($toRN.Name -replace "_[0-9]+",'') -literalPath $toRN.Fullname
    }
    write-host "Checking Nintendo 3ds folder for incorrect file placement`n" -BackgroundColor Gray -ForegroundColor Black
    $id0folders=gci "$($drive.DriveLetter):\Nintendo 3ds\" |where-object { $_.Name -like "????????????????????????????????"}
    if ($id0folders.length > 1) {
        write-host "Found more than 1 ID0 folder" -ForegroundColor Black -BackgroundColor Yellow;
    }
    $dirpath_list = $("$($drive.DriveLetter):\Nintendo 3ds\","$($drive.DriveLetter):\DCIM\")
    foreach ($dirpath in $dirpath_list) {
        write-host "Checking $($dirpath)";
        if (Exists -dir "$($dirpath)" -file 'boot.3dsx') {
            Move-Item -Path "$($dirpath)/boot.3dsx" -Destination "$($drive.DriveLetter):/";
            write-host "Found boot.3dsx in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/" -ForegroundColor Black -BackgroundColor Yellow;
        }
        if (Exists -dir "$($dirpath)" -file 'boot.firm') {
            Move-Item -Path "$($dirpath)/boot.firm" -Destination "$($drive.DriveLetter):/";
            write-host "Found boot.firm in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/" -ForegroundColor Black -BackgroundColor Yellow;
        }
        if (Exists -dir "$($dirpath)" -file 'boot.nds') {
            Move-Item -Path "$($dirpath)/boot.nds" -Destination "$($drive.DriveLetter):/";
            write-host "Found boot.nds in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/" -ForegroundColor Black -BackgroundColor Yellow;
        }
        if (Exists -dir "$($dirpath)" -file 'frogcert.bin') {
            Move-Item -Path "$($dirpath)/frogcert.bin" -Destination "$($drive.DriveLetter):/";
            write-host "Found frogcert.bin in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/" -ForegroundColor Black -BackgroundColor Yellow;
        }
        if (Exists -dir "$($dirpath)" -file 'movable.sed') {
            Move-Item -Path "$($dirpath)/movable.sed" -Destination "$($drive.DriveLetter):/";
            write-host "Found movable.sed in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/" -ForegroundColor Black -BackgroundColor Yellow;
        }
        if (Exists -dir "$($dirpath)" -file 'steelhax') {
            Move-Item -Path "$($dirpath)/steelhax" -Destination "$($drive.DriveLetter):/";
            write-host "Found steelhax in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/" -ForegroundColor Black -BackgroundColor Yellow;
        }
        if (Exists -dir "$($dirpath)" -file '*.3dsx') {
            new-Item -Name "3ds" -ItemType "directory" -Path "$($drive.DriveLetter):/";
            Move-Item -Path "$($dirpath)/*.3dsx" -Destination "$($drive.DriveLetter):/3ds/";
            write-host "Found .3dsx files in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/3ds/" -ForegroundColor Black -BackgroundColor Yellow;
        }
        if (Exists -dir "$($dirpath)" -file '*.firm') {
            new-Item -Name "luma" -ItemType "directory" -Path "$($drive.DriveLetter):/";
            new-Item -Name "payloads" -ItemType "directory" -Path "$($drive.DriveLetter):/luma/";
            Move-Item -Path "$($dirpath)/*.firm" -Destination "$($drive.DriveLetter):/luma/payloads/";
            write-host "Found .firm files in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/luma/payloads/" -ForegroundColor Black -BackgroundColor Yellow;
        }
        if (Exists -dir "$($dirpath)" -file '*.cia') {
            new-Item -Name "cias" -ItemType "directory" -Path "$($drive.DriveLetter):/";
            Move-Item -Path "$($dirpath)/*.cia" -Destination "$($drive.DriveLetter):/cias/";
            write-host "Found .cia files in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/cias/" -ForegroundColor Black -BackgroundColor Yellow;
        }
        if (Exists -dir "$($dirpath)" -file 'payload*') {
            new-Item -Name "steelhax" -ItemType "directory" -Path "$($drive.DriveLetter):/";
            Move-Item -Path "$($dirpath)/payload*" -Destination "$($drive.DriveLetter):/steelhax/payload.bin";
            write-host "Found payload file in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/steelhax/" -ForegroundColor Black -BackgroundColor Yellow;
        }
        if (Exists -dir "$($dirpath)/private/ds/app/4B47554A/001/" -file 'T00031_1038C2A757B77_000.ppm') {
            new-Item -Name "private" -ItemType "directory" -Path "$($drive.DriveLetter):/";
            Move-Item -Path "$($dirpath)/private/ds" -Destination "$($drive.DriveLetter):/private/";
            write-host "Found DSiWare private folder in the $($dirpath) folder. Attempting to move to $($drive.DriveLetter):/" -ForegroundColor Black -BackgroundColor Yellow;
        }
    }
}
########################################################## 

######## Check SD Card for Steelhax Files

function checkSteelhaxFiles() {
    Write-Host "`nChecking for Steelhax files`n" -BackgroundColor Gray -ForegroundColor Black
    $gamedir="FFFFFFFF";
    if (Test-Path -Path "$($drive.DriveLetter):/steelhax/payload.bin.bin" ) 
    {
        write-host "payload.bin was named incorrectly. This is likely due to having file extensions hidden.`nAttempting to rename it for you.`n" -ForegroundColor Black -BackgroundColor Yellow;
        Rename-Item -Path "$($drive.DriveLetter):/steelhax/payload.bin.bin" -newname "payload.bin";
    }
    if ($(Test-Path -Path "$($drive.DriveLetter):/steelhax/payload.bin") -eq $false) 
    {
        write-host "payload.bin is missing from $($drive.DriveLetter):/steelhax/"  -ForegroundColor White -BackgroundColor DarkRed
        Pause;
        return $false;
    }
    $file=(getMD5("$($drive.DriveLetter):/steelhax/payload.bin"));
    #if (Test-Path -Path "$($drive.DriveLetter):/boot.nds" ) {
    if ($file)    {
        if ($file -eq $payloadNewUS) {
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "NEW" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " console payload. Assuming your system is "
            write-host "n3ds, n3dsXL, or n2dsXL" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "USA" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " region payload, assuming version "
            write-host -NoNewLine "11.10.0-43U" -ForegroundColor Black -BackgroundColor DarkGray
            write-host " in settings";
            $gamedir=$USsteeldiver;
        }elseif ($file -eq $payloadNewEU) {
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "NEW" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " console payload. Assuming your system is "
            write-host "n3ds, n3dsXL, or n2dsXL" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "EUR" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " region payload, assuming version "
            write-host -NoNewLine "11.10.0-43E" -ForegroundColor Black -BackgroundColor DarkGray
            write-host " in settings";
            $gamedir=$EUsteeldiver;
        }elseif ($file -eq $payloadNewJP) {
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "NEW" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " console payload. Assuming your system is "
            write-host "n3ds, n3dsXL, or n2dsXL" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "JPN" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " region payload, assuming version "
            write-host -NoNewLine "11.10.0-43J" -ForegroundColor Black -BackgroundColor DarkGray
            write-host " in settings";
            $gamedir=$JPsteeldiver;
        }elseif ($file -eq $payloadOldUS) {
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "OLD" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " console payload. Assuming your system is "
            write-host "o3ds, o3dsXL, or o2ds (not foldable)" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "USA" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " region payload, assuming version "
            write-host -NoNewLine "11.10.0-43U" -ForegroundColor Black -BackgroundColor DarkGray
            write-host " in settings";
            $gamedir=$USsteeldiver;
        }elseif ($file -eq $payloadOldEU) {
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "OLD" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " console payload. Assuming your system is "
            write-host "o3ds, o3dsXL, or o2ds (not foldable)" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "EUR" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " region payload, assuming version "
            write-host -NoNewLine "11.10.0-43E" -ForegroundColor Black -BackgroundColor DarkGray
            write-host " in settings";
            $gamedir=$EUsteeldiver;
        }elseif ($file -eq $payloadOldJP) {
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "OLD" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " console payload. Assuming your system is "
            write-host "o3ds, o3dsXL, or o2ds (not foldable)" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine "You seem to have the "
            write-host -NoNewLine "JPN" -ForegroundColor Black -BackgroundColor DarkGray
            write-host -NoNewLine " region payload, assuming version "
            write-host -NoNewLine "11.10.0-43J" -ForegroundColor Black -BackgroundColor DarkGray
            write-host " in settings";
            $gamedir=$JPsteeldiver;
        }else{
            Write-Host "payload.bin is incorrect. `nMD5 is        $file`n. This can be caused by incorrect number choices when downloading otherapp, or corruption during copying to SD.`n" -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else{
            write-host "payload.bin does not exist.`n" -ForegroundColor White -BackgroundColor DarkRed
            PauseExit;
    }
    #Write-Host "`n`n"
    write-host "Checking for any steel diver updates and checking for save file size`n" -BackgroundColor Gray -ForegroundColor Black
    $n3dsfolder = Get-ChildItem -Path "$($drive.DriveLetter):/\Nintendo 3ds\" | Where-Object { $_.PSIsContainer  -and  $_.Name -like "????????????????????????????????"}
    foreach ($id0 in $n3dsfolder)
    {
        $id1folders = Get-ChildItem -Path "$($id0.fullname)" |  Where-Object { $_.PSIsContainer -and  $_.Name -like "????????????????????????????????"} 
        foreach ($id1 in $id1folders){
            if (Test-Path -Path "$($id1.fullname)\title\0004000e\$($gamedir)" ) {
                write-host "You have the steel diver update installed. Be sure to delete it from settings->data management->3ds->downloadable content (or addons)" -ForegroundColor Black -BackgroundColor Yellow;;
                write-host "update was found in: $($id1.fullname)`n";

            }
            foreach ($sav in Get-ChildItem "$($id1.fullname)\title\00040000\$($gamedir)\data\" -ErrorVariable errsav -ErrorAction SilentlyContinue) {
                if (-not $sav.length -eq 524288) {
                    Write-Host "Extra or incorrect files in data directory: $($sav.fullname)`n" -ForegroundColor White -BackgroundColor DarkRed
                }else{
                    Write-Host "save file is the correct size in data directory: $($id1.fullname)\title\00040000\$($gamedir)\data\`n"
                    $found=1; 
                }
            }
        }

    }
    if ($errsav -and -not $found) {
        write-Host "Steel Diver save file does not exist or you have the wrong region payload. Verify the region listed above.`n" -ForegroundColor White -BackgroundColor DarkRed;
        $errsav = "";
        Pause;
        return $false;
    }

    $file=(getMD5("$($drive.DriveLetter):/boot.3dsx"));
    if ($file) {
        if ($file -eq $boot3dsxMD5) {
            write-host "boot.3dsx is valid" -ForegroundColor White -BackgroundColor DarkGreen
        }else{
            write-host "boot.3dsx is wrong.`nMD5 is        $file`nMD5 should be $boot3dsxMD5`nRedownload Homebrew Launcher. Put boot.3dsx on the SD at $($drive.DriveLetter):\boot.3dsx" -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else {
        write-host "boot.3dsx does not exist.`nRedownload Homebrew Launcher. Put boot.3dsx on the SD at $($drive.DriveLetter):\boot.3dsx" -ForegroundColor White -BackgroundColor DarkRed
        if ($download) {
            write-Host "Attempting to download boot.3dsx";
            DownloadFile -url "$($boot3dsxURL)" -file "boot.3dsx" -Path "$($drive.DriveLetter):/" -githubAPI $true
        }
        Pause;
        return $false;
    }
    $file=(getMD5("$($drive.DriveLetter):/steelhax/code.bin"));
    if ($file) {
        if ($file -eq $codebinMD5) {
            write-host "code.bin is valid" -ForegroundColor White -BackgroundColor DarkGreen
        }else{
            write-host "code.bin is wrong.`nMD5 is        $file`nMD5 should be $codebinMD5`nRedownload steelhax and extract the steelhax folder." -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else {
        write-host "code.bin does not exist.`nRedownload steelhax and extract the steelhax folder." -ForegroundColor White -BackgroundColor DarkRed
        Pause;
        return $false;
    }
    $file=(getMD5("$($drive.DriveLetter):/steelhax/rop.bin"));
    if ($file) {
        if ($file -eq $ropbinMD5) {
            write-host "rop.bin is valid" -ForegroundColor White -BackgroundColor DarkGreen
        }else{
            write-host "rop.bin is wrong.`nMD5 is        $file`nMD5 should be $ropbinMD5`nRedownload steelhax and extract the steelhax folder." -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else {
        write-host "rop.bin does not exist.`nRedownload steelhax and extract the steelhax folder." -ForegroundColor White -BackgroundColor DarkRed
        Pause;
        return $false;
    }


    return $true;
}


############# Check B9sTool
function checkB9sFiles() {
    Write-Host "`nChecking B9STool`n" -BackgroundColor Gray -ForegroundColor Black
    $file=(getMD5("$($drive.DriveLetter):/boot.nds"));
    #if (Test-Path -Path "$($drive.DriveLetter):/boot.nds" ) {
    if ($file)    {
        if ($file -eq $bootndsMD5) {
            write-host "boot.nds is valid"  -ForegroundColor White -BackgroundColor DarkGreen;
        }else{
            Write-Host "boot.nds is wrong. `nMD5 is        $file`nMD5 should be $bootndsMD5`nRedownload b9stool and put the file on the SD root at $($drive.DriveLetter):\boot.nds"  -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else {
        write-host "boot.nds does not exist." -ForegroundColor White -BackgroundColor DarkRed
        if ($download) {
            write-Host "Attempting to download boot.nds";
            DownloadFile -url "$($bootndsURL)" -file "boot.nds" -Path "$($drive.DriveLetter):/" -githubAPI $true -unzip $true
        }
        Pause;
        return $false;
    }
    return $true;
}

############# Check Frogtool Files
function checkFrogtoolFiles() {
    Write-Host "`nChecking Frogtool files`n" -BackgroundColor Gray -ForegroundColor Black
    $file=(get-item -path "$($drive.DriveLetter):/movable.sed" -ErrorAction SilentlyContinue)
    #$file=(getMD5("$($drive.DriveLetter):/boot.firm"));
    if ($file) {
        if ($file.length -eq 320) {
            write-host "movable.sed is valid" -ForegroundColor White -BackgroundColor DarkGreen;
        }else{
            write-host "movable.sed is wrong.`nfile should be 320 bytes.`n" -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else {
        write-host "movable.sed does not exist.`nRedownload your movable.sed and put it in SD root." -ForegroundColor White -BackgroundColor DarkRed
        Pause;
        return $false;
    }
    $file=(getMD5("$($drive.DriveLetter):/frogcert.bin"));
    if ($file) {
        if ($file -eq $frogcertMD5) {
            write-host "frogcert.bin is valid" -ForegroundColor White -BackgroundColor DarkGreen;
        }else{
            write-host "frogcert.bin is wrong.`nMD5 is        $file`nMD5 should be $frogcertMD5`nRedownload frogcert with a Torrent client. Put frogcert.bin on the SD at $($drive.DriveLetter):\frogcert.bin" -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else {
        write-host "frogcert.bin does not exist.`nRedownload frogcert with a Torrent client. Put frogcert.bin on the SD at $($drive.DriveLetter):\frogcert.bin" -ForegroundColor White -BackgroundColor DarkRed
        Pause;
        return $false;
    }
    $file=(getMD5("$($drive.DriveLetter):/3ds/frogtool.3dsx"));
    if ($file) {
        if ($file -eq $frogtoolMD5) {
            write-host "frogtool.3dsx is valid" -ForegroundColor White -BackgroundColor DarkGreen;
        }else{
            write-host "frogtool.3dsx is wrong.`nMD5 is        $file`nMD5 should be $frogtoolMD5`nRedownload frogtool and put it on the SD at $($drive.DriveLetter):\3ds\frogtool.3dsx" -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else {
        write-host "frogtool.3dsx does not exist.`nRedownload frogtool and put it on the SD at $($drive.DriveLetter):\3ds\frogtool.3dsx" -ForegroundColor White -BackgroundColor DarkRed
        if ($download) {
            write-Host "Attempting to download frogtool.3dsx";
            DownloadFile -url "$($frogtoolURL)" -file "frogtool.3dsx" -Path "$($drive.DriveLetter):/3ds/" -githubAPI $true -unzip $true
        }
        Pause;
        return $false;
    }
    if ($(checkB9sFiles) -ne $true) {
        Pause;
        return $false;
    }
    return $true;
}
############# Check Fredtool Files
function checkFredtoolFiles() {
    Write-Host "`nChecking Fredtool files`n" -BackgroundColor Gray -ForegroundColor Black
    if ($( checkLumaFiles ) -ne $true) {
        Write-host "luma files false"
        pause;
        return $false;
    }
    if ($( checkB9sFiles ) -ne $true) {
        return $false;
    }
    
    $file=(getMD5("$($drive.DriveLetter):/private/ds/app/4B47554A/001/T00031_1038C2A757B77_000.ppm"));
    if ($file) {
        if ($file -eq $flipnoteMD5) {
            write-host "Flipnote Save is valid" -ForegroundColor White -BackgroundColor DarkGreen;
        }else{
            write-host "Flipnote Save is wrong.`nMD5 is        $file`nMD5 should be $flipnoteMD5`nRedownload Frogminer save and copy the private folder to sd root." -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else {
        write-host "Flipnote Save does not exist.`nRedownload Frogminer save and copy the private folder to sd root." -ForegroundColor White -BackgroundColor DarkRed
        if ($download) {
            write-Host "Attempting to download Flipnote save";
            #new-Item -Name "private" -ItemType "directory" -Path "$($drive.DriveLetter):/";
            #new-Item -Name "ds" -ItemType "directory" -Path "$($drive.DriveLetter):/private/";
            #new-Item -Name "app" -ItemType "directory" -Path "$($drive.DriveLetter):/private/ds/";
            #new-Item -Name "4B47554A" -ItemType "directory" -Path "$($drive.DriveLetter):/private/ds/app/";
            new-Item -Name "001" -Force -ItemType "directory" -Path "$($drive.DriveLetter):/private/ds/app/4B47554A/";
            DownloadFile -url "$($flipnoteURL)" -file "T00031_1038C2A757B77_000.ppm" -Path "$($drive.DriveLetter):/private/ds/app/4B47554A/001/" -githubAPI $false -unzip $false
        }
        Pause;
        return $false;
    }
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
            if (Test-Path -Path "$($id1.fullname)\Nintendo DSiWare\42383841.bin" ) {
                write-host "Fredtool DSiWare exists" -ForegroundColor White -BackgroundColor DarkGreen;
                $found=1
            }
        }
    }
    if ($found -ne 1) {
        write-host "Fredtool DSiWare does not exist.`nRedownload it from the fredtool website and extract the correct dsiware to the dsiware folder at $($id1.fullname)\Nintendo DSiWare\42383841.bin" -ForegroundColor White -BackgroundColor DarkRed
        Pause;
        return $false;
    }
    return $true;
}
############# Check Luma Files
function checkLumaFiles() {

    Write-Host "`nChecking Luma3ds Files`n" -BackgroundColor Gray -ForegroundColor Black
    $file=(getMD5("$($drive.DriveLetter):/boot.firm"));
    if ($file) {
        if ($file -eq $bootfirmMD5) {
            write-host "boot.firm is valid" -ForegroundColor White -BackgroundColor DarkGreen;
        }else{
            write-host "boot.firm is wrong.`nMD5 is        $file`nMD5 should be $bootfirmMD5`nRedownload Luma3ds. Make sure to use 7-zip to extract it to get the boot.firm" -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else {
        write-host "boot.firm does not exist.`nRedownload Luma3ds. Make sure to extract it to get the boot.firm" -ForegroundColor White -BackgroundColor DarkRed
        if ($download) {
            write-Host "Attempting to download boot.firm";
            DownloadFile -url "$($bootfirmURL)" -file "boot.firm" -Path "$($drive.DriveLetter):/" -githubAPI $true -unzip $true
        }
        Pause;
        return $false;
    }
    $file=(getMD5("$($drive.DriveLetter):/boot.3dsx"));
    if ($file) {
        if ($file -eq $boot3dsxMD5) {
            write-host "boot.3dsx is valid" -ForegroundColor White -BackgroundColor DarkGreen;
        }else{
            write-host "boot.3dsx is wrong.`nMD5 is        $file`nMD5 should be $boot3dsxMD5`nRedownload Homebrew Launcher. Put boot.3dsx on the SD at $($drive.DriveLetter):\boot.3dsx" -ForegroundColor White -BackgroundColor DarkRed
            Pause;
            return $false;
        }
    }else {
        write-host "boot.3dsx does not exist.`nRedownload Homebrew Launcher. Put boot.3dsx on the SD at $($drive.DriveLetter):\boot.3dsx" -ForegroundColor White -BackgroundColor DarkRed
        if ($download) {
            write-Host "Attempting to download boot.3dsx";
            DownloadFile -url "$($boot3dsxURL)" -file "boot.3dsx" -Path "$($drive.DriveLetter):/" -githubAPI $true
        }
        Pause;
        return $false;
    }
    return $true;
}


$drive = GetDrive
:nextMenu while ($($choice=ShowMenu) -ne "Q") {
    
    switch($choice) {
        1 {
            $checkFormat = !$checkFormat
        }
        2 {
            $checkFiles = !$checkFiles
        }
        3 {
            $checkSteelhax = !$checkSteelhax
        }
        4 {
            $checkB9sTool = !$checkB9sTool
        }
        5 {
            $checkFrogtool = !$checkFrogtool
        }
        6 {
            $checkFredtool = !$checkFredtool
        }
        7 {
            $checkLuma = !$checkLuma
        }
        R {
            write-host "`n`n"
            if ($checkFormat) {
                if ($(CheckSDFormat) -ne $true) {
                    continue nextMenu;
                }
            }
            if ($checkFiles) {
                checkSDFiles
            }
            if ($checkSteelhax) {
                if ($(checkSteelhaxFiles) -ne $true) {
                    continue nextMenu;
                }
            }
            if ($checkB9sTool) {
                if ($(checkB9sFiles) -ne $true) {
                }
            }
            if ($checkFrogtool) {
                if ($(checkFrogtoolFiles) -ne $true) {
                    continue nextMenu;
                }
            }
            if ($checkFredtool) {
                if ($(checkFredtoolFiles) -ne $true) {
                    continue nextMenu;
                }
            }
            if ($checkLuma) {
                if ($(checkLumaFiles) -ne $true) {
                    continue nextMenu;
                }
            }

            Write-Host "All checks have been run, please see above for any errors or warnings`n" -ForegroundColor White -BackgroundColor Black
            Pause;
        }
        Q {
            write-host "Good Byte!"
            exit;
        }
    }
}

