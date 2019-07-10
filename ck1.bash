#!/bin/bash

OFS=$IFS
IFS=$'\n'
shopt -s nocasematch
shopt -s globstar
shopt -s extglob

# Updated for luma 9.1 and steelminer for 11.7-11.9
# b9stool 5.0.1 May 2019
bootndsMD5="175093C2784777190A83374CB1AC9E16"

boot3dsxMD5="0DE027B0447B4470CB796AFB94B4CDF2"
payloadNewUS="349EB973101E32F5975B4D13682F4ED0"
payloadNewEU="CFE01ED181F84FE46A59610D6F14B8D2"
payloadNewJP="415B6C2F2709F4931B51D199CF3CBE1E"
payloadOldUS="90206185C514C9A31CAB9A17B33BB83E"
payloadOldEU="11CA69DAE3FE3B850A7DA14A2AF3B60B"
payloadOldJP="F6830F00218DAF599F1F607ED39CA9B4"
bootfirmMD5="F7C0D04AB092E3707A4020154F49B4D5"
codebinMD5="75956D94937AD596921D165BB5044F1A"
ropbinMD5="1674E05F3179FF50138C0C862BF88EB1"
USsteeldiver="000d7d00"
EUsteeldiver="000d7e00"
JPsteeldiver="000d7c00"

frogcertMD5="39A1B894B9F85C9B1998D172EF4DCC3A"
frogtoolMD5="2511BC883FA69C2F79424784344737E8"



$checkFormat=1;
$checkFiles=1;
$checkSteelhax=0;
$checkB9sTool=0;
$checkFrogtool=0;
$checkFredtool=0;
$checkLuma=0;

############# BASH escapes
console_bold="\e[1m"
console_underlined="\e[4m"
console_reset="\e[0m"
console_green="\e[32m"
console_yellow="\e[93m"
console_red="\e[91m"
console_default="\e[40;97m"
echo -e "$console_default"


isEnabled() {
    if [[ $1 < 1 ]]; then
        echo " ";
    else
        echo "X";
    fi
}

ShowMenu() {
    clear;
    echo "`n`n   3DS Homebrew/CFW installation Check Tool`n`tBy MechDragon`n`n"
    echo "  1.\t[$(isEnabled $checkFormat)] Check SD Format";
    echo "  2.\t[$(isEnabled $checkFiles)] Check SD File Placement";
    echo "  3.\t[$(isEnabled $checkSteelhax)] Check Steelhax Files";
    echo "  4.\t[$(isEnabled $checkB9sTool)] Check B9sTool (miner)";
    echo "  5.\t[$(isEnabled $checkFrogtool)] Check Frogtool Files";
    echo "  6.\t[$(isEnabled $checkFredtool)] Check Fredtool Files";
    echo "  7.\t[$(isEnabled $checkLuma)] Check Luma Files";
    echo "`n  [R]un Check(s)";
    echo   "  [Q]uit`n";
}

CheckSDFormat() {

driveformat=`df -t  | grep -c $1 | cut -f2`
if [[$driveformat = "vfat" -o $driveformat = "msdos"]]; then
	echo -e "$($console_green)SD is formatted $driveformat$($console_default)"
    $ret=1
else
	echo -e "$($console_red)SD is formatted $driveformat instead of FAT32/VFAT/FAT$($console_default)"
	$ret=0
fi

}

checkSDFiles() {
    echo "Checking SD root for misnamed files" -BackgroundColor Gray -ForegroundColor Black
    misnamed=`find $mntLoc -iname "boot (*).*" -or -iname "payload (*).*" -or -iname "movable (*).*" -exec mv {} ${{}%(*)};`
####
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

echo What is the mount point of your SD card? (example: /mnt/UserSD )
read -p "Mount Point: " mntLoc

if [[-z $mntLoc]]; then
 echo "Cannot find SD card"
 exit 1
fi




echo "Do you want to check steelhax files?"
read checkSteelhax
if [[ -z $checkSteelhax ]] || [[ $checkSteelhax == y* ]]; then
 gamedir="FFFFFFFF"
# Steelminer checks

 #check if steelhax folder is in the wrong place
 if [[ -d $mntLoc/Nintendo\ 3DS/steelhax ]]; then
    echo " "
    echo " "
    echo "**Your steelhax folder is in the wrong place, attempting to move it to SD root: $mntLoc/steelhax/";
    echo "-SD root means opening the location of the SD card, but not entering any of the folders inside the SD"
    mv $mntLoc/Nintendo\ 3DS/steelhax $mntLoc/
 fi
 if [[ -d $mntLoc/3ds/steelhax ]]; then
    echo " "
    echo " "
    echo "**Your steelhax folder is in the wrong place, attempting to move it to SD root: $mntLoc/steelhax/";
    echo "-SD root means opening the location of the SD card, but not entering any of the folders inside the SD"
    mv $mntLoc/3ds/steelhax $mntLoc/
 fi
 echo ""
 # find the region based on the steeldiver title id found
  echo "Checking for any steel diver updates and checking for save file size"
 gamedirs=`find "$mntLoc/Nintendo 3DS/" -iname "$USsteeldiver"`
 if [[ -z $gamedir ]]; then
  gamedirs=`find "$mntLoc/Nintendo 3DS/" -iname "$EUsteeldiver"`
  if [[ -z $gamedir ]]; then
   gamedirs=`find "$mntLoc/Nintendo 3DS/" -iname "$JPsteeldiver"`
  fi
 fi
 gamedir=""
 #echo $gamedirs
 for file in $gamedirs; do
    if [[ `echo "$file" | awk -F'/' '{print $(NF-1)}' ` == "0004000e" ]]; then
     echo " "
     echo "**You have the steel diver update installed. Be sure to delete it from settings->data management->3ds->downloadable content (or addons)"
    echo " "
    fi
    if [[ `echo "$file" | awk -F'/' '{print $(NF-1)}' ` == "00040000" ]]; then
        gamedir=$file
        #echo $file
    fi
 done

 if [[ -z $gamedir ]]; then
  echo " "
  echo " "
  echo "Steel Diver: Sub Wars is not installed"
  exit 1
 #else
  #echo "Steel Diver: Sub Wars was found in $gamedir"
 fi
 
 if [[ -d  $mntLoc/steelhax ]]; then
  echo "steelhax folder found in the correct place"
 else

  echo "steelhax folder not found at $mntLoc/steelhax/"
  exit 1
 fi
# shouldnt be needed on *nix systems
#  if [ -f $mntLoc/steelhax/payload.bin.bin ]; then
#   echo "payload.bin was named incorrectly. Attempting to fix name."
#   mv $mntLoc/steelhax/payload.bin.bin $mntLoc/steelhax/payload.bin
#  fi
  file=`md5sum $mntLoc/steelhax/payload.bin | cut -f1 -d' '`
  if [[ -z $file ]]; then
   echo "$mntLoc/steelhax/payload.bin not found"
   exit 1
  fi

  if [[ $gamedir == */$USsteeldiver ]] && [[ $file != $payloadNewUS ]] && [[ $file != $payloadOldUS ]]; then 
   echo "You downloaded the wrong otherapp payload."
   exit 1
  fi
  if [[ $gamedir == */$EUsteeldiver ]] && [[ $file != $payloadNewEU ]] && [[ $file != $payloadOldEU ]]; then 
   echo "You downloaded the wrong otherapp payload."
   exit 1
  fi
  if [[ $gamedir == */$JPsteeldiver ]] && [[ $file != $payloadNewJP ]] && [[ $file != $payloadOldJP ]]; then 
   echo "You downloaded the wrong otherapp payload."
   exit 1
  fi
  if [[ $file == $payloadOldJP ]] || [[ $file == $payloadOldUS ]] || [[ $file == $payloadOldEU ]]; then
   echo "+OLD model otherapp payload found. Assuming your system is o3ds, o3dsXL, or o2ds (not foldable)"
  else
   echo "+NEW model otherapp payload found. Assuming your system is n3ds, n3dsXL, or n2dsXL (foldable)"
  fi
  file=`md5sum $mntLoc/steelhax/rop.bin | cut -f1 -d' '`
  if [[ -z $file ]] || [[ $file != $ropbinMD5 ]]; then
   echo "$mntLoc/steelhax/rop.bin not found. Redownload the steelhax rar file and extract the contents to find the file."
   exit 1
  fi
  file=`md5sum $mntLoc/steelhax/code.bin | cut -f1 -d' '`
  if [[ -z $file ]] || [[ $file != $codebinMD5 ]]; then
   echo "$mntLoc/steelhax/code.bin not found. Redownload the steelhax rar file and extract the contents to find the file."
   exit 1
  fi
  for file in `find "$gamedir/data/" -type f `; do
   a=`echo "$file" | awk -F'/' '{print $NF}'`
   if [[ $a != "00000001.sav" ]]; then
    echo "Unexpected file found in data directory. Expected 00000001.sav, found $a"
    exit 1
   fi
  done
  fsize=`stat -c%s "$gamedir/data/00000001.sav"`
  if [[ $fsize < 512*1024 ]]; then
    echo "save file size is incorrect"
    exit 1
  fi
  
  file=`md5sum $mntLoc/boot.3dsx | cut -f1 -d' '`
  if [[ -z $file ]]; then
    echo "boot.3dsx is missing from SD root."
  elif [[ $file != $boot3dsxMD5 ]]; then
    echo "boot.3dsx is incorrect or corrupt."
  else
   echo "boot.3dsx is good"
  fi
  
echo " "
echo " "  
fi
