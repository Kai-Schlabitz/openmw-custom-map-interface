#!/usr/bin/env bash 
set -e

rm -rf .build
mkdir .build

sizes=([vvardenfell]="3531x4096" [solstheim]="1526x1750" [mournhold]="1317x1558")

for ext in No DDS TGA; do
  folder=.build/CustomMapInterface${ext}Textures
  rsync -a --exclude='.*' ./ $folder

  if [[ $ext != No ]]; then  
    cp textures/.${ext,,}/* $folder/textures/
  
    subs=""
    for map in ${!sizes[@]}; do
      size=${sizes[$key]}

      before="makePathSetting\($i, '[^']*'\)"
      after="makePathSetting($i, '${map}MapWagner.${ext,,}')"
      subs+="s|$before|$after|g;"
      
      before="makeTextureSizeSetting\($i, '[^']*'\)"
      after="makeTextureSizeSetting($i, '$size')"
      subs+="s|$before|$after|g;"
    done

    sed -i -E -e "$subs" $folder/scripts/custom-map-interface.lua
  fi

  zip -r $folder $folder
done
