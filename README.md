# Custom Map Interface v4
## Compatibility 
This mod was created for OpenMW 0.49.0.
It might work with other versions, but there are no guarantees.

## Description
It adds a map interface that can use up to 9 custom map textures.

## Controls and Settings
You can open the map interface by default by pressing M. This can be changed in
the settings page for the mod. The map can be moved by dragging it or with the
standard movement controls. Zooming in and out can be done with the standard
zoom controls. You can adjust the speed of zooming and moving the map in the
settings page for the mod. Press the quick key that corresponds to the map
number whose path you set in the settings page. For example, quick key 1 opens
map 1. Make sure that the path and size for each map is set in the settings.

## Installation
- Extract the zip folder for the mod.
- Add the path to the mod folder to your Content List under Data Directories in
  the OpenMW Launcher.
- Activate custom-map-interface.omwscripts under Content Files.
- In the settings page for the mod, add the paths to any map textures that you
  want. Use paths that are relative to the textures folder of the mod like
  yourmap.dds or tamriel.tga. If you install the TGA version or the DDS version,
  the Wagner maps from https://www.nexusmods.com/morrowind/mods/48455 are
  included with the paths already set up.
- Set the intrinsic sizes of the textures in the settings page for the mod.
  Texture files should have square sizes that are powers of 2. Like 1024x1024
  or 4096x4096. However, not all maps are actually those sizes. The actual size
  of the map is the intrinsic size. Map assets whose intrinsic dimensions are 
  not a power of two will have some transparent space on the bottom right. If
  you do not set this intrinsic size for your custom assets in the settings
  page, the mod will still work, but the transparent space will be counted
  toward the total texture size, and the map won't start out centered and at
  a good size proportional to your screen size. You can also interact with the
  transparent space even though you shouldn't be able to. The intrinsic sizes
  are already set up in the settings if you install the TGA or DDS version.

## File credits
Default map assets from Map and Compass by JaceyS.
https://www.nexusmods.com/morrowind/mods/48455 Quoted from that page: "Images in
the Wagner pack were originally made by Mike Wagner for Bethesda Softworks for
distribution as paper maps with Morrowind and expansions. Copyright information
from these images has been removed for the purpose of immersion, not to obscure
ownership. Consider the general copyright on the game to cover these images.
vvardenfellMapWagner and mournholdMapWagner are digitizations of two of those
maps by Raptormeat, and hosted on imperial-library.info. solstheimMapWagner is
a composite by JaceyS of a map prepared by reddit user u/graemecloutman (which
itself appears to be a composite of a high-res scan of Solstheim from the GOTY
version of the paper map and a lower-resolution Bloodmoon map), with water and
peripheral elements from the high res Vvardenfell map above."

## License
This mod is licensed under 0BSD. Feel free to modify and redistribute it however
you like.

## Support
If you want me to implement a feature for you, I won't. I'm sorry I can't help,
but you'll need to do it yourself or get someone else to do it for you.

