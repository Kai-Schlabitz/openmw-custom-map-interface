#!/usr/bin/env bash 
set -e

rm -rf .build
mkdir .build

maps=(0 vvardenfell solstheim mournhold)
sizes=(0 3531x4096 1526x1750 1317x1558)

for ext in No DDS TGA; do
  name=CustomMapInterface${ext}Textures
  folder=.build/$name
  rsync -a --exclude='.*' ./ $folder

  if [[ $ext != No ]]; then  
    cp textures/.${ext,,}/* $folder/textures/
  
    subs=""
    for i in 1 2 3; do
      map=${maps[i]}
      size=${sizes[i]}

      before="makePathSetting\($i, '[^']*'\)"
      after="makePathSetting($i, '${map}MapWagner.${ext,,}')"
      subs+="s|$before|$after|g;"
      
      before="makeTextureSizeSetting\($i, '[^']*'\)"
      after="makeTextureSizeSetting($i, '$size')"
      subs+="s|$before|$after|g;"

      ((i++))
    done

    sed -i -E -e "$subs" $folder/scripts/custom-map-interface.lua
  fi

  cd $folder && zip -r ../$name.zip . && cd ../..
done
