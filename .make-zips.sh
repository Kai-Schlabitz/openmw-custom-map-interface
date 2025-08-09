#!/usr/bin/env bash 
set -e

rm -rf .build
mkdir .build

maps=(0 vvardenfell solstheim mournhold)
echo $maps

for ext in No DDS TGA; do
  echo $ext
  folder=.build/CustomMapInterface${ext}Textures
  echo $folder
  rsync -a --exclude='.*' ./ $folder

  if [[ $ext != No ]]; then  
    cp textures/.${ext,,}/* $folder/textures/
  
    subs=""
    for i in 1 2 3; do
      before="makePathSetting\($i, '[^']*'\)"
      after="makePathSetting($i, 'textures/${maps[$i]}MapWagner.${ext,,}')"
      subs+="s|$before|$after|g;"
    done

    echo $subs
    sed -i -E -e "$subs" $folder/scripts/custom-map-interface.lua
  fi

  zip -r $folder $folder
done
