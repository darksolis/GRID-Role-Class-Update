GRID ROLE, CLASS & POWER INTEGRATION
Version 1.0.0 by Darksolis

This build integrates directly into the supplied Grid 1.30300.1308 package.
It does not require a separate companion addon.

FEATURES
- Independent Tank, Healer, and DPS role-icon toggles.
- CoA custom class-icon support using Ascension/custom client icon tables.
- Standard WoW class-icon fallback.
- Power bars on every Grid player frame.
- Mana, rage, energy, focus, runic-power, rune, and happiness colors.
- Clean bordered icons, adjustable size, position, inset, and opacity.
- Adjustable power-bar height, inset, background opacity, and empty-bar behavior.
- Manual role override command for clients without reliable role assignment.

SETTINGS
Open /grid and select "Role, Class & Power".

MANUAL ROLE COMMAND
/gridrole PlayerName tank
/gridrole PlayerName healer
/gridrole PlayerName dps
/gridrole PlayerName auto

COA ICON RESOLUTION
The module checks the client-provided tables below in order:
- COA_CLASS_ICON_TCOORDS
- ASCENSION_CLASS_ICON_TCOORDS
- CUSTOM_CLASS_ICON_TCOORDS
- CLASS_ICON_TCOORDS

It recognizes all 21 current CoA class names and falls back to individual
Interface\\Icons\\ClassIcon_<CLASS> textures when a custom atlas table is not
published by that client build. Standard WoW classes retain normal icons.

INSTALL
Replace the existing Grid folder with this Grid folder while WoW is closed.
Do not nest it inside another Grid folder.
Correct path: Interface\\AddOns\\Grid\\Grid.toc


VERSION 1.1.0 - MANUAL ROLE FALLBACK
- Alt + Right-Click any Grid player frame to assign Tank, Healer, DPS,
  Melee DPS, Ranged DPS, Support, or return the player to Auto Detect.
- Manual roles are saved by character name in the active Grid profile.
- A settings toggle can change the shortcut to plain Right-Click.
- Alt + Right-Click is the default because plain Right-Click may already
  be used by Clique or another click-casting setup.
- Auto detection still has priority unless a manual role is assigned.
- Unknown auto-detected roles can either show the DPS icon or no icon.

VERSION 1.1.1 - ACE2/DEWDROP SETTINGS FIX
- Added required description strings to every generated toggle and slider.
- Added descriptions to role-position and class-position selectors.
- Prevents Dewdrop from rejecting the options table when opening Grid settings.

VERSION 1.1.2 - SUPPORT ICON AND RIGHT-CLICK POLISH
- Replaced the support icon with a new custom design.
- Removed separate melee and ranged DPS assignment options. DPS is now a single role.
- Manual role assignment now opens with plain right-click by default.
- Removed the plain-right-click toggle to keep settings cleaner.
- Legacy melee/ranged manual assignments are automatically migrated to DPS.

VERSION 1.1.3 - SUPPORT TEXTURE AND AUTO-FALLBACK FIX
- Automatic role detection now hides the role icon when no valid role is found.
- Existing profiles are migrated once from the old DPS fallback to Hidden.
- Added a completely new support icon using a new texture filename to avoid client caching.
- Role textures are explicitly cleared before replacement to prevent stale DPS artwork.

VERSION 1.1.4 - BLACK SUPPORT ICON FIX
- Rebuilt the Support artwork as a raw uncompressed 32-bit TGA.
- Changed the WoW texture reference to an extensionless path, matching the working role icons.
- Removed the broken v2 texture from the package.
- Kept automatic detection failure set to Hide Role Icon.
