# Changelog

## [0.3.0-alpha] - Red Tomato

### Added
- Crafting of the basic CCTV camera (available by default)
- Added the magazine "Nachumba zero .inc - CCTV instruction", currently it contains crafting instructions (recipe) and in the future there will be recipes for other base camera versions or camera modules.
- Added modules to improve\simplify development

### Fixed
- Syntax in item configs
- Loot distribution and spawn system (WIP)


## [0.2.0-alpha] - Tomato

!Alpha!

### Fixed
- Character being ignored by other entities (we use the character as the camera)
- Optimization of the camera switching request
- Removed errors when enabling the mod
- Fixed the ability to hang a bunch of cameras in one place (minimum radius is 5 tiles)

### Changed
- Changed the maximum accessibility range of cameras from 30 to 10
- Removed the ability to rotate the camera (it might return later, possibly as an option for another camera)
- Cameras can now only be mounted on fences or walls

### Added
- Now added a chance for cameras and repeaters to spawn in tool crates, houses, and construction materials
- Added the company "Nachumbnas computers .inc", moving forward mods and items in this mod will be branded by this company (mod lore)


## [0.1.0-alpha] - Zucchini

Alpha release - CCTV Base for Project Zomboid (Build 42).

### Added
- **CCTV Items**:
  - `CameraItem` — CCTV video camera (Electronics category).
  - `RepeaterItem` — CCTV signal repeater (Electronics category).
- **Equipment Installation**: ability to install a camera or repeater from the inventory onto the player's current tile (inventory context menu option). Upon installation, the item is removed from the inventory.
- **Camera Manager (`CCTV_Manager`)**:
  - Registration of cameras and repeaters with coordinates.
  - Calculation of distance and base signal reception radius without a repeater (`MAX_DEFAULT_DIRECT_RANGE = 30`).
  - Checking for a repeater within radius to extend communication range.
  - Retrieving a list of available cameras for a specific TV with a simulated signal level calculation.
- **Connecting to CCTV via TV**: "Connect to CCTV" context menu option appears when interacting with a television (`IsoTelevision`) if there are accessible cameras nearby.
- **Camera View Interface (`CCTV_UI`)**:
  - Fullscreen UI with switching between cameras ("Prev." / "Next" buttons).
  - Display of camera name, simulated signal level, and the sequence number of the current camera.
  - Disconnect button from CCTV to return the player's camera to normal mode.
  - "No signal" message if no cameras are found.
- **Localization (`CCTV_i18n`)**: basic interface strings (partly in Russian, partly in English).

### Known Limitations
- Localization is not split into game language files (`Translate`), strings are hardcoded in `CCTV_i18n.lua`.
- Missing power/durability checks for cameras and repeaters.
- Signal range calculation is simplified (without taking walls/floors into account).

#### PS: Afterword
I will be naming different versions with names. <br/>
The first Alpha will be "Zucchini" because right now my mod is just a zucchini and nothing more, we'll see further.
