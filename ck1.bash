#!/bin/bash

OFS=$IFS
IFS=$'\n'
shopt -s nocasematch
shopt -s globstar
shopt -s extglob

# Updated for luma 9.1 and steelminer for 11.7-11.9
bootndsMD5 = "7374B600F947CF16E31D6967B0CE647C"
boot3dsxMD5 = "0DE027B0447B4470CB796AFB94B4CDF2"
payloadNewUS = "349EB973101E32F5975B4D13682F4ED0"
payloadNewEU = "CFE01ED181F84FE46A59610D6F14B8D2"
payloadNewJP = "415B6C2F2709F4931B51D199CF3CBE1E"
payloadOldUS = "90206185C514C9A31CAB9A17B33BB83E"
payloadOldEU = "11CA69DAE3FE3B850A7DA14A2AF3B60B"
payloadOldJP = "F6830F00218DAF599F1F607ED39CA9B4"
bootfirmMD5 = "F7C0D04AB092E3707A4020154F49B4D5"
codebinMD5 = "75956D94937AD596921D165BB5044F1A"
ropbinMD5 = "1674E05F3179FF50138C0C862BF88EB1"
USsteeldiver="000d7d00"
EUsteeldiver="000d7e00"
JPsteeldiver="000d7c00"

frogcertMD5="39A1B894B9F85C9B1998D172EF4DCC3A"
frogtoolMD5="2511BC883FA69C2F79424784344737E8"

echo What is the mount point of your SD card? (example: /mnt/UserSD )
read -p "Mount Point:" mntLoc

mountinfo=`df -t  | grep -c $mntLoc`
if [[-z $mntLoc]]; then
 echo "Cannot find SD card"
 exit 1
fi

driveformat = `echo $mountinfo | cut -f2`

if [[$driveformat -eq "vfat"]] || [[$driveformat -eq "msdos"]]; then
	echo "SD is formatted $driveformat - GOOD"
else
	echo "SD is formatted $driveformat instead of FAT32/VFAT/FAT"
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
