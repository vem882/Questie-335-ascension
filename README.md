# Questie-335 Ascension Edition

A specialized fork of Questie for WoW 3.3.5a (WotLK) with native support for Ascension WoW servers.

[![GitHub](https://img.shields.io/badge/GitHub-vem882%2FQuestie--335--ascension-blue)](https://github.com/vem882/Questie-335-ascension)
[![WoW Client](https://img.shields.io/badge/WoW-3.3.5a%20(12340)-orange)](https://github.com/vem882/Questie-335-ascension)
[![Ascension](https://img.shields.io/badge/Ascension-Supported-green)](https://project-ascension.com/)

## 🎯 What is this?

This is an enhanced version of Questie-335 specifically adapted for Ascension WoW servers. It includes:
- ✅ Full compatibility with Ascension's custom content
- ✅ Automatic server detection
- ✅ Pre-loaded database with 286 Ascension NPCs
- ✅ Dynamic data collection system
- ✅ Custom map coordinate fixes
- ✅ Support for custom quests (ID > 100000)

## 📥 Installation

### Standard Installation
1. Download the latest release from [GitHub](https://github.com/vem882/Questie-335-ascension/releases)
2. Extract the archive
3. Place the `Questie-335` folder in your `World of Warcraft/Interface/AddOns/` directory
4. Restart WoW client
5. That's it! The addon will automatically detect Ascension servers

### Manual Installation
If you prefer to clone the repository:
```bash
cd "World of Warcraft/Interface/AddOns/"
git clone https://github.com/vem882/Questie-335-ascension.git Questie-335
```

## 🌟 Features

### Automatic Ascension Detection
Questie automatically detects the following Ascension realms:
- Any realm with "Ascension" in the name
- Laughing Skull
- Sargeras
- Andorhal

When detected, the addon displays: `[Questie] Ascension WoW detected! Loading Ascension database...`

### Pre-loaded Content
- **286 NPCs** with spawn locations converted from pfQuest-ascension
- Optimized for Ascension's custom content
- No configuration required

### Dynamic Data Collection
The addon automatically collects data while you play:
- **NPCs**: Hover over any NPC to record it
- **Quests**: Accept quests to save quest data
- **Objects**: Interact with objects to track them
- **Coordinates**: Automatic location tracking

All collected data is saved for your session and can be exported for community sharing.

### Custom Map Support
- Automatic coordinate offset for Ascension's custom Stormwind (Map ID 1519)
- Offset: X+6.8, Y+10.1
- Works seamlessly with all Questie features

### Error Suppression
- No spam about missing custom quests (ID > 100000)
- Clean chat without unnecessary warnings
- Full compatibility with Ascension's custom content

## 🎮 Usage

### Basic Commands
```
/questie                    - Open configuration
/questie toggle             - Toggle quest markers
/questie minimap            - Toggle minimap button
/questie tracker            - Toggle quest tracker
/questie journey            - Open journey window
```

### Ascension-Specific Commands
```
/questie ascension stats    - Show collected data statistics
/questie ascension npcs     - List discovered NPCs
/questie ascension quests   - List discovered quests
/questie ascension export   - Export collected data for sharing
```

### Data Collection Tips
1. **Explore actively**: Move through different zones
2. **Mouseover NPCs**: Hover over NPCs to record them
3. **Accept quests**: Take quests to save quest data
4. **Check statistics**: Use `/questie ascension stats` to see your progress
5. **Export data**: Share your discoveries with `/questie ascension export`

## 🔧 Technical Details

### Compatibility
- **Client Version**: 3.3.5a (12340)
- **Interface Version**: 30300-30405
- **Expansion**: Wrath of the Lich King
- **Custom Servers**: Full support for Ascension WoW

### Architecture Changes
This fork includes the following enhancements from the original Questie-335:

1. **Modules/Expansions.lua** (NEW)
   - Automatic expansion detection via interface version
   - Fixes "game client not supported" errors on custom servers
   - Supports clients without standard WOW_PROJECT_ID

2. **Modules/AscensionLoader.lua** (NEW)
   - Main Ascension support coordinator
   - Database loading and merging
   - Dynamic data collection system
   - Event-based gathering (mouseover, tooltips, quest log)

3. **Modules/QuestieCompat.lua**
   - Added `IsAscension` flag for global detection
   - Enhanced compatibility layer

4. **Compat/Compat.lua**
   - Realm detection in PLAYER_LOGIN event
   - Nameplate crash prevention with nil checks

5. **Modules/QuestieInit.lua**
   - AscensionLoader initialization
   - Conditional loading based on IsAscension flag

6. **Modules/Quest/QuestieQuest.lua**
   - Custom quest error suppression (ID > 100000)
   - Modified GetAllQuestIds() and GetAllQuestIdsNoObjectives()

7. **Modules/QuestieSlash.lua**
   - Integrated `/questie ascension` commands
   - Stats, export, and listing functionality

8. **Database/Ascension/**
   - ascensionNpcDB.lua: 286 pre-loaded NPCs
   - ascensionQuestDB.lua: Custom quest data
   - ascensionObjectDB.lua: Custom object data
   - ascensionItemDB.lua: Custom item data

### Data Format
NPC data follows Questie's standard format:
```lua
[npcId] = {
    name,           -- NPC name
    minHP,          -- Minimum health
    maxHP,          -- Maximum health
    minLevel,       -- Minimum level
    maxLevel,       -- Maximum level
    rank,           -- 0=Normal, 1=Elite, 2=Rare Elite, 3=Boss, 4=Rare
    spawns,         -- {[zoneId]={{x,y},{x,y},...}}
    waypoints,      -- Patrol waypoints (if any)
    zoneID,         -- Primary zone
    questStarts,    -- Quests offered
    questEnds,      -- Quests completed
    factionID,      -- Faction ID
    friendlyFaction,-- "A"=Alliance, "H"=Horde, "AH"=Both
    subName,        -- NPC title
    npcFlags        -- NPC flags
}
```

## 🤝 Credits & Attribution

### Original Authors
This addon builds upon the incredible work of:
- **Questie Development Team**
  - Aero, Logon, Muehe, TheCrux (BreakBB)
  - Drejjmit, Dyaxler, Cheeq, TechnoHunter
  - Schaka, Zoey, and everyone else
  - [Original Questie Repository](https://github.com/Questie/Questie)

### WotLK 3.3.5a Port
- **widxwer** - Original Questie-335 fork and WotLK compatibility
  - [Questie-335 Repository](https://github.com/widxwer/Questie)

### Ascension Adaptation (2025)
- **Bananaroot (vem882)** - Ascension WoW integration and enhancements
  - Ascension detection system
  - Dynamic data collection
  - Custom map coordinate fixes
  - Database conversion and integration
  - [This Repository](https://github.com/vem882/Questie-335-ascension)

### Data Sources
- **pfQuest-ascension** by Bennylavaa and contributors
  - Source for Ascension NPC database
  - [pfQuest Repository](https://github.com/shagu/pfQuest)

### Inspiration
- **QuestHelper** addon
  - Data collection techniques and event handling patterns

### Special Thanks
- Ascension WoW community for testing and feedback
- Original Questie Discord community for support
- All contributors to the Classic WoW addon ecosystem

## 📜 License

This project inherits its license from the original Questie addon.

### GNU General Public License v3.0
- Original Questie: GPL-3.0 (Questie/Questie)
- Questie-335: GPL-3.0 (widxwer/Questie)
- This fork: GPL-3.0 (vem882/Questie-335-ascension)

See [LICENSE](LICENSE) for full text.

### Third-Party Libraries
This addon includes the following libraries with their respective licenses:
- **Ace3** - BSD License
- **LibStub** - Public Domain
- **HereBeDragons** - MIT License
- **LibDataBroker** - CC0
- **LibDBIcon** - BSD License

All original library licenses are preserved in their respective directories.

## 🐛 Bug Reports & Feature Requests

### For Ascension-Specific Issues
Please report issues related to Ascension WoW on this repository:
- [GitHub Issues](https://github.com/vem882/Questie-335-ascension/issues)
- Tag with `[Ascension]` for Ascension-specific problems

### For General Questie Issues
For issues not related to Ascension:
- Original Questie: [Questie/Questie Issues](https://github.com/Questie/Questie/issues)
- Questie-335: [widxwer/Questie Issues](https://github.com/widxwer/Questie/issues)

### Providing Good Bug Reports
Please include:
1. **Realm name** (e.g., "Laughing Skull - Warcraft Reborn")
2. **Client version** (type `/console gxApi` in-game)
3. **Exact error message** (enable with `/console scriptErrors 1`)
4. **Steps to reproduce** the issue
5. **Expected behavior** vs **actual behavior**

## 🔄 Version History

### v1.0.0 (December 2025) - Ascension Edition
- Initial release with full Ascension WoW support
- Added Expansions.lua for custom client detection
- Integrated AscensionLoader module
- Converted 286 NPCs from pfQuest-ascension
- Dynamic data collection system
- Custom map coordinate fixes (Map 1519)
- Error suppression for custom content
- Full command integration

### Base: Questie-335 v9.5.1
- WotLK 3.3.5a (12340) compatibility
- Interface version 30300
- Original Questie features preserved

## 🚀 Future Plans

- [ ] Expand Ascension NPC database with community contributions
- [ ] Add more custom quest data
- [ ] Implement persistent data storage (SavedVariables)
- [ ] Create automated data sharing system between players
- [ ] Add support for additional custom maps
- [ ] Integrate latest Questie improvements
- [ ] Community-driven database updates

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

### Data Contribution
1. Play on Ascension servers with this addon
2. Use `/questie ascension export` to export your collected data
3. Submit via GitHub Issues or Pull Requests
4. Data will be reviewed and integrated into the main database

### Code Contribution
1. Fork this repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Testing
- Test on different Ascension realms
- Report any compatibility issues
- Verify data accuracy
- Help with beta testing new features

## 📞 Contact & Community

- **GitHub**: [@vem882](https://github.com/vem882)
- **Repository**: [Questie-335-ascension](https://github.com/vem882/Questie-335-ascension)
- **Ascension Discord**: Join Ascension WoW Discord
- **Original Questie Discord**: [discord.gg/s33MAYKeZd](https://discord.gg/s33MAYKeZd)

## ❤️ Support the Project

If you enjoy this addon:
- ⭐ Star this repository on GitHub
- 🐛 Report bugs and issues
- 💾 Share your collected data
- 📣 Tell other Ascension players
- 🤝 Contribute code or data

## 📚 Additional Documentation

- **Database README**: [Database/Ascension/README.md](Database/Ascension/README.md)
- **Conversion Script**: [convert_pfquest_to_questie.py](../convert_pfquest_to_questie.py)
- **Original Questie Wiki**: [Questie Wiki](https://github.com/Questie/Questie/wiki)

---

**Made with ❤️ for the Ascension WoW community**

*Remember: This addon respects the work of all contributors. From the original Questie team, through the WotLK port by widxwer, to the Ascension adaptation. We stand on the shoulders of giants.*

