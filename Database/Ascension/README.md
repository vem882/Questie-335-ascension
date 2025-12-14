# Questie-335 Ascension Support

## Overview
Questie-335 now includes built-in support for Ascension WoW servers. When playing on Ascension realms, Questie will automatically detect the server and load Ascension-specific database enhancements.

## Features
- **Automatic Detection**: Questie automatically detects Ascension WoW realms by server name
- **Ascension Database**: Includes Ascension-specific NPCs, quests, objects, and items
- **Coordinate Fixes**: Automatically applies coordinate corrections for custom Ascension maps (e.g., Stormwind map ID 1519)
- **Seamless Integration**: Works transparently with all existing Questie features

## Supported Realms
The following realm names are automatically detected as Ascension servers:
- Realms containing "Ascension" in the name
- Laughing Skull
- Sargeras
- Andorhal

## Manual Override
If you're on an Ascension server that isn't automatically detected, you can manually enable Ascension support:
1. Edit your `SavedVariables\QuestieConfig.lua` file
2. Add or modify: `QuestieCompat.IsAscension = true`
3. Reload the game

## Database Population
Currently, the Ascension database files are placeholders ready to be populated with data from pfQuest-ascension. The infrastructure is in place to:
- Load Ascension-specific NPC spawns
- Add custom quests
- Include custom objects and items
- Apply coordinate transformations

To populate the databases, convert data from pfQuest-ascension format to Questie format in:
- `Database\Ascension\ascensionNpcDB.lua`
- `Database\Ascension\ascensionQuestDB.lua`
- `Database\Ascension\ascensionObjectDB.lua`
- `Database\Ascension\ascensionItemDB.lua`

## Technical Details

### Files Modified
- `Modules\QuestieCompat.lua` - Added `IsAscension` flag
- `Compat\Compat.lua` - Added Ascension realm detection in PLAYER_LOGIN
- `Modules\QuestieInit.lua` - Added AscensionLoader initialization
- `Questie-335.toc` - Added Ascension database and module files

### New Files
- `Modules\AscensionLoader.lua` - Main Ascension support module
- `Database\Ascension\ascensionNpcDB.lua` - Ascension NPC data
- `Database\Ascension\ascensionQuestDB.lua` - Ascension quest data
- `Database\Ascension\ascensionObjectDB.lua` - Ascension object data
- `Database\Ascension\ascensionItemDB.lua` - Ascension item data
- `Database\Ascension\README.md` - This file

### Architecture
The Ascension support follows pfQuest-ascension's patchtable approach:
1. Base WotLK data is loaded first
2. On Ascension realms, AscensionLoader is initialized
3. Ascension-specific data is merged/patched into base database
4. Coordinate fixes are applied for custom maps
5. All Questie features work normally with enhanced data

## Contributing
To add Ascension-specific data:
1. Convert pfQuest-ascension data format to Questie format
2. Add entries to appropriate database files in `Database\Ascension\`
3. Test on Ascension realm
4. Submit pull request

## Credits
- Ascension WoW adaptation: Bananaroot (vem882)
- Ascension detection and infrastructure: Questie-335 team
- Original pfQuest-ascension data: Bennylavaa and contributors
- Questie-335 core: widxwer
- Original Questie: Questie team
- QuestHelper analysis and techniques: QuestHelper team
