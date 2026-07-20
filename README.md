[README.txt](https://github.com/user-attachments/files/30179837/README.txt)
# Grid Role, Class & Power for Conquest of Azeroth

A customized version of the classic **Grid** raid-frame addon for **Ascension: Conquest of Azeroth**.

This build adds role icons, CoA class icons, and player power bars directly into Grid's existing raid frames while preserving Grid's original layout, status, and click-casting functionality.

## Features

- Tank, Healer, DPS, and Support role icons
- Conquest of Azeroth class icons
- Standard WoW class-icon fallback
- Player power bars for mana, rage, energy, runic power, and other supported resources
- Adjustable role-icon size and position
- Adjustable class-icon size and position
- Adjustable power-bar height, spacing, and opacity
- Clean settings integrated into Grid's normal configuration menu
- Persistent manual role assignments
- Plain right-click role assignment directly from Grid frames
- Unknown roles hidden by default instead of incorrectly showing DPS
- Automatic Main Tank detection through the standard raid-assignment system

## Important CoA Role Detection Limitation

Conquest of Azeroth does not reliably expose every player's active specialization or combat role to standard World of Warcraft addon APIs.

The server does reliably expose players assigned as **Main Tank**, so Grid can automatically display the Tank icon for those players.

Healer, DPS, and Support roles are not automatically available through the standard raid-role system. Those roles must usually be assigned manually.

The addon intentionally does not guess a player's role based only on their CoA class. Many CoA classes can play multiple roles, so class-based guessing would often be inaccurate.

When automatic detection fails, the role icon is hidden by default.

## Manual Role Assignment

Right-click any player's Grid frame while out of combat.

The role menu includes:

- Auto Detect
- Tank
- Healer
- DPS
- Support

Manual assignments are saved by character name and remain after `/reload`, relogging, or restarting the game.

Choose **Auto Detect** to remove a manual override.

## Installation

1. Download the latest release.
2. Fully close World of Warcraft.
3. Remove or back up your existing `Grid` folder.
4. Extract the included `Grid` folder into:

```text
World of Warcraft/Interface/AddOns/
```

5. Confirm the final folder path is:

```text
World of Warcraft/Interface/AddOns/Grid/Grid.toc
```

6. Start the game.
7. Enable Grid from the AddOns menu.
8. Enable **Load out of date AddOns** if your client requires it.

A full game restart is recommended after replacing textures. `/reload` may not clear WoW's cached texture data.

## Configuration

Open Grid's configuration with:

```text
/grid
```

Then navigate to:

```text
Grid > Role, Class & Power
```

Available settings include:

- Enable Frame Decorations
- Show Tank Icons
- Show Healer Icons
- Show DPS Icons
- Show Support Icons
- Role Icon Size
- Role Icon Position
- Enable Right-Click Role Menu
- Auto-Detection Failure Behavior
- Show Class Icons
- Use CoA Class Icons
- Use Standard Class Fallback
- Class Icon Size
- Class Icon Position
- Show Power Bars
- Hide Empty Power Bars
- Power Bar Height
- Power Bar Inset
- Power Bar Background Opacity
- Icon Edge Inset
- Icon and Bar Opacity
- Reset Decoration Settings

## Slash Commands

Manual roles can also be assigned through chat commands.

```text
/gridrole PlayerName tank
/gridrole PlayerName healer
/gridrole PlayerName dps
/gridrole PlayerName support
/gridrole PlayerName auto
```

Examples:

```text
/gridrole Darksolis healer
/gridrole Desoxyn support
/gridrole Bloodmong tank
/gridrole Darksolis auto
```

## Automatic Tank Detection

Grid checks the standard raid Main Tank assignment.

Raid leaders and assistants can assign a player as Main Tank through the raid interface. Once assigned, the Tank icon should update automatically.

This is currently the only role that CoA reliably exposes to Grid through the normal raid-assignment system.

## Power Bars

Each Grid frame can display the player's active power resource along the bottom edge.

Supported resources include:

- Mana
- Rage
- Energy
- Runic Power
- Focus
- Other resource types exposed by the client

The power-bar color automatically changes based on the player's resource type.

## CoA Class Icons

The addon attempts to use Conquest of Azeroth class icons when the client exposes a compatible icon table or texture.

If a CoA icon cannot be resolved, the addon can fall back to standard World of Warcraft class icons.

Supported CoA classes include:

- Barbarian
- Bloodmage
- Chronomancer
- Cultist
- Felsworn
- Guardian
- Knight of Xoroth
- Necromancer
- Primalist
- Pyromancer
- Ranger
- Reaper
- Runemaster
- Starcaller
- Stormbringer
- Sun Cleric
- Templar
- Tinker
- Venomancer
- Witch Doctor
- Witch Hunter

## Compatibility

Designed for:

- World of Warcraft 3.3.5a
- Ascension: Conquest of Azeroth
- Ace2-era Grid
- Vol'jin and similar CoA realms

This is a modified Grid package rather than a separate plug-in. Back up your existing Grid folder before installation.

## Known Limitations

- CoA only reliably auto-detects Main Tank assignments through the standard raid UI.
- Healer, DPS, and Support roles must usually be assigned manually.
- Manual role selection is unavailable during combat.
- Plain right-click is used for the role menu and may conflict with right-click click-casting setups.
- CoA class-icon availability may vary between Ascension client builds.
- Texture changes may require a full game restart before appearing correctly.

## Troubleshooting

### Support icon appears black

Fully close the game and restart it. WoW may cache a failed texture until the client exits.

Also confirm this file exists:

```text
Interface/AddOns/Grid/Decorations/Role_Support_v3.tga
```

### Role menu does not open

- Make sure you are out of combat.
- Confirm **Enable Right-Click Role Menu** is enabled.
- Right-click directly on the player's Grid frame.

### Everyone has no role icon

This is expected when CoA does not expose a role.

Assign roles manually with right-click or `/gridrole`.

### Tank icon does not appear automatically

Confirm the player has been assigned as **Main Tank** through the raid interface.

### Settings window throws an Ace2 or Dewdrop error

Make sure you are using the latest release and that the entire `Grid` folder was replaced instead of merging only selected files.

## Updating

When installing a new version:

1. Close the game.
2. Back up or delete the current `Grid` folder.
3. Extract the new `Grid` folder.
4. Restart the game.

Avoid merging different versions together because outdated Lua files or textures may remain behind.

## Credits

- Original Grid addon and contributors
- Ascension and the Conquest of Azeroth development team
- CoA Build Hub for community specialization and role-reference information
- Modified and maintained by **Darksolis**

## Disclaimer

This is a community modification and is not an official Ascension or Conquest of Azeroth addon.

World of Warcraft, Warcraft, and related assets are trademarks of Blizzard Entertainment. Ascension and Conquest of Azeroth are owned by their respective creators.
