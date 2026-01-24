---@class AscensionLoader
-- Ascension WoW support module for Questie-335
-- Provides automatic detection and data collection for Ascension servers
--
-- Credits:
--   Ascension WoW adaptation: Bananaroot (vem882)
--   Based on pfQuest-ascension by Bennylavaa
--   Inspired by QuestHelper data collection techniques
local AscensionLoader = QuestieLoader:CreateModule("AscensionLoader")

---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Cache for dynamically discovered data
AscensionLoader.discoveredNPCs = {}
AscensionLoader.discoveredObjects = {}
AscensionLoader.discoveredQuests = {}

-- Initialize Ascension support
function AscensionLoader:Initialize()
    if not QuestieCompat.IsAscension then
        return
    end

    Questie:Debug(Questie.DEBUG_INFO, "[AscensionLoader] Initializing Ascension WoW support")

    -- Apply any Ascension-specific fixes
    self:ApplyAscensionFixes()

    -- Setup dynamic data collection
    self:SetupDynamicDataCollection()

    Questie:Debug(Questie.DEBUG_INFO, "[AscensionLoader] Ascension WoW support initialized")
end

-- Apply Ascension-specific fixes and patches
function AscensionLoader:ApplyAscensionFixes()
    -- Fix map coordinates for custom Ascension maps
    -- Example: Stormwind map ID 1519 needs coordinate adjustments
    self:FixMapCoordinates()

    -- Any other Ascension-specific adjustments
end

-- Fix coordinate offsets for Ascension custom maps
function AscensionLoader:FixMapCoordinates()
    -- Ascension's Stormwind (map 1519) has coordinate offsets
    -- This matches the pfQuest-ascension patchtable.lua logic
    local mapFixes = {
        [1519] = { x = 6.8, y = 10.1 } -- Stormwind offset
    }

    -- Apply fixes to NPC coords
    -- Check if npcData is a table (not a string) before iterating
    if QuestieDB.npcData and type(QuestieDB.npcData) == "table" then
        for npcId, npcData in pairs(QuestieDB.npcData) do
            if type(npcData) == "table" and npcData.spawns then
                for zoneId, spawns in pairs(npcData.spawns) do
                    if mapFixes[zoneId] then
                        local fix = mapFixes[zoneId]
                        for _, spawn in pairs(spawns) do
                            if spawn[1] and spawn[2] then
                                spawn[1] = spawn[1] + fix.x
                                spawn[2] = spawn[2] + fix.y
                            end
                        end
                    end
                end
            end
        end
    end

    -- Apply fixes to Object coords
    if QuestieDB.objectData and type(QuestieDB.objectData) == "table" then
        for objectId, objectData in pairs(QuestieDB.objectData) do
            if type(objectData) == "table" and objectData.spawns then
                for zoneId, spawns in pairs(objectData.spawns) do
                    if mapFixes[zoneId] then
                        local fix = mapFixes[zoneId]
                        for _, spawn in pairs(spawns) do
                            if spawn[1] and spawn[2] then
                                spawn[1] = spawn[1] + fix.x
                                spawn[2] = spawn[2] + fix.y
                            end
                        end
                    end
                end
            end
        end
    end

    Questie:Debug(Questie.DEBUG_INFO, "[AscensionLoader] Map coordinate fixes applied")
end

-- Setup dynamic data collection from game world
function AscensionLoader:SetupDynamicDataCollection()
    -- Register UPDATE_MOUSEOVER_UNIT for NPC detection (more reliable than tooltip hooks)
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

    -- Hook GameTooltip for object detection
    GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
        AscensionLoader:OnTooltipUnit(tooltip)
    end)

    GameTooltip:HookScript("OnShow", function(tooltip)
        AscensionLoader:OnTooltipShow(tooltip)
    end)

    -- Hook quest log updates
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:RegisterEvent("UNIT_QUEST_LOG_CHANGED")

    Questie:Debug(Questie.DEBUG_INFO, "[AscensionLoader] Dynamic data collection enabled")
end

-- Show Ascension data collection statistics
function AscensionLoader:ShowStats(command)
    command = string.lower(command or "stats")

    if command == "stats" then
        -- Show statistics
        local npcCount = 0
        for _ in pairs(self.discoveredNPCs) do npcCount = npcCount + 1 end
        local questCount = 0
        for _ in pairs(self.discoveredQuests) do questCount = questCount + 1 end
        local objectCount = 0
        for _ in pairs(self.discoveredObjects) do objectCount = objectCount + 1 end

        DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccQuestie Ascension Data Collection:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Discovered NPCs: " .. npcCount .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Discovered Quests: " .. questCount .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Discovered Objects: " .. objectCount .. "|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFFCommands:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF  /questie ascension stats - Show statistics|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF  /questie ascension npcs - Show discovered NPCs|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF  /questie ascension quests - Show discovered quests|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF  /questie ascension export - Show export instructions|r")

    elseif command == "npcs" then
        -- Show recent NPCs
        local count = 0
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccRecently discovered NPCs:|r")
        for npcId, _ in pairs(self.discoveredNPCs) do
            if count < 10 then
                local npc = QuestieDB.npcData[npcId]
                if npc then
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF00FF00[%d] %s (Level %d)|r", npcId, npc[1], npc[4]))
                end
                count = count + 1
            end
        end
        if count == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000No NPCs discovered yet. Target or mouseover NPCs to collect data.|r")
        end

    elseif command == "quests" then
        -- Show recent quests
        local count = 0
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccDiscovered custom quests:|r")
        for questId, questData in pairs(self.discoveredQuests) do
            if count < 10 then
                DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF00FF00[%d] %s (Level %d)|r", questId, questData.title, questData.level or 0))
                if questData.objectives and #questData.objectives > 0 then
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("  |cFFCCCCCC%d objectives|r", #questData.objectives))
                end
                count = count + 1
            end
        end
        if count == 0 then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000No custom quests discovered yet. Accept quests to collect data.|r")
        end

    elseif command == "export" then
        -- Show export instructions
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccQuestie Ascension Export:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00To export discovered data:|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF1. Open WTF/Account/<YourAccount>/SavedVariables/|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF2. Look for Questie-335.lua file|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF3. Discovered data will be saved automatically on logout|r")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFFFF4. Share the file with Questie developers on GitHub/Discord|r")

        -- Print sample data to chat for manual copy
        local npcCount = 0
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccSample NPC data:|r")
        for npcId, _ in pairs(self.discoveredNPCs) do
            if npcCount < 5 then
                local npc = QuestieDB.npcData[npcId]
                if npc then
                    DEFAULT_CHAT_FRAME:AddMessage(string.format("|cFF00FF00NPC %d: %s (Level %d)|r", npcId, npc[1], npc[4]))
                end
                npcCount = npcCount + 1
            end
        end

    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccQuestie Ascension:|r Unknown command. Use /questie ascension stats")
    end
end

-- Collect NPC data from mouseover (more reliable than tooltip)
function AscensionLoader:UPDATE_MOUSEOVER_UNIT()
    if not UnitExists("mouseover") then return end
    if not UnitIsVisible("mouseover") then return end
    if UnitIsPlayer("mouseover") then return end
    if UnitPlayerControlled("mouseover") then return end

    -- Get creature ID from GUID
    local guid = UnitGUID("mouseover")
    if not guid then return end

    local type, _, _, _, _, npcId = strsplit("-", guid)
    if type ~= "Creature" and type ~= "Vehicle" then return end

    npcId = tonumber(npcId)
    if not npcId then return end

    -- Skip if already in database with real name
    if QuestieDB.npcData[npcId] and QuestieDB.npcData[npcId][1] ~= "Ascension NPC " .. npcId then
        return
    end

    -- Collect NPC information
    local npcName = UnitName("mouseover") or "Unknown NPC"
    local level = UnitLevel("mouseover")
    if level and level < 0 then level = 999 end -- Boss level
    level = level or 1

    local classification = UnitClassification("mouseover")
    local rank = 0

    if classification == "elite" then
        rank = 1
    elseif classification == "rareelite" then
        rank = 2
    elseif classification == "worldboss" then
        rank = 3
    elseif classification == "rare" then
        rank = 4
    end

    -- Get faction
    local reaction = UnitReaction("mouseover", "player")
    local faction = nil
    if reaction then
        if reaction >= 5 then
            -- Friendly
            faction = UnitFactionGroup("player") == "Alliance" and "A" or "H"
        elseif reaction <= 3 then
            -- Hostile
            faction = UnitFactionGroup("player") == "Alliance" and "H" or "A"
        end
    end

    -- Get current zone for spawn location
    local _, _, zoneId = QuestieCompat:GetCurrentPlayerPosition()

    -- Create NPC entry (Questie format)
    local npcEntry = {
        npcName,          -- [1] name
        100,              -- [2] minHealth (placeholder)
        100,              -- [3] maxHealth (placeholder)
        level,            -- [4] minLevel
        level,            -- [5] maxLevel
        rank,             -- [6] rank
        nil,              -- [7] spawns (will be filled below)
        nil,              -- [8] waypoints
        zoneId or 0,      -- [9] zoneID
        nil,              -- [10] questStarts
        nil,              -- [11] questEnds
        35,               -- [12] factionID (neutral default)
        faction,          -- [13] friendlyToFaction
        "",               -- [14] subName
        0                 -- [15] npcFlags
    }

    -- Add spawn location if we have position
    if zoneId then
        local x, y = QuestieCompat:GetCurrentPlayerPosition()
        if x and y then
            npcEntry[7] = {[zoneId] = {{x, y}}}
        end
    end

    -- Store in database
    -- Make sure npcData is initialized as a table
    if type(QuestieDB.npcData) ~= "table" then
        Questie:Debug(Questie.DEBUG_CRITICAL, "[AscensionLoader] WARNING: npcData is not a table, skipping NPC storage")
        return
    end

    if not self.discoveredNPCs[npcId] then
        self.discoveredNPCs[npcId] = true
        QuestieDB.npcData[npcId] = npcEntry
        Questie:Debug(Questie.DEBUG_DEVELOP, "[AscensionLoader] Discovered NPC:", npcId, npcName, "Level:", level, "at", x, y)
    end
end

-- Collect NPC data from tooltip (backup method)
function AscensionLoader:OnTooltipUnit(tooltip)
    local name, unitId = tooltip:GetUnit()
    if not unitId or not UnitExists(unitId) then
        return
    end

    -- Get creature ID from GUID
    local guid = UnitGUID(unitId)
    if not guid then return end

    local type, _, _, _, _, npcId = strsplit("-", guid)
    if type ~= "Creature" and type ~= "Vehicle" then
        return
    end

    npcId = tonumber(npcId)
    if not npcId then return end

    -- Skip if already in database
    if QuestieDB.npcData[npcId] and QuestieDB.npcData[npcId][1] ~= "Ascension NPC " .. npcId then
        return
    end

    -- Collect NPC information
    local npcName = UnitName(unitId) or "Unknown NPC"
    local level = UnitLevel(unitId) or 1
    local classification = UnitClassification(unitId)
    local rank = 0

    if classification == "elite" then
        rank = 1
    elseif classification == "rareelite" then
        rank = 2
    elseif classification == "worldboss" then
        rank = 3
    elseif classification == "rare" then
        rank = 4
    end

    -- Get faction
    local reaction = UnitReaction(unitId, "player")
    local faction = nil
    if reaction then
        if reaction >= 5 then
            faction = UnitFactionGroup("player") == "Alliance" and "A" or "H"
        elseif reaction <= 3 then
            faction = UnitFactionGroup("player") == "Alliance" and "H" or "A"
        end
    end

    -- Create NPC entry (Questie format)
    local npcEntry = {
        npcName,          -- [1] name
        100,              -- [2] minHealth (placeholder)
        100,              -- [3] maxHealth (placeholder)
        level,            -- [4] minLevel
        level,            -- [5] maxLevel
        rank,             -- [6] rank
        nil,              -- [7] spawns (will be filled as we see them)
        nil,              -- [8] waypoints
        0,                -- [9] zoneID (will be filled)
        nil,              -- [10] questStarts
        nil,              -- [11] questEnds
        35,               -- [12] factionID (neutral default)
        faction,          -- [13] friendlyToFaction
        "",               -- [14] subName
        0                 -- [15] npcFlags
    }

    -- Store in database
    if not self.discoveredNPCs[npcId] then
        self.discoveredNPCs[npcId] = true
        QuestieDB.npcData[npcId] = npcEntry
        Questie:Debug(Questie.DEBUG_DEVELOP, "[AscensionLoader] Discovered NPC:", npcId, npcName, "Level:", level)
    end
end

-- Collect object data from tooltip
function AscensionLoader:OnTooltipShow(tooltip)
    -- Check if this is a game object (not unit, item, or spell)
    if tooltip:GetAnchorType() ~= "ANCHOR_NONE" then return end
    if tooltip:GetItem() or tooltip:GetUnit() or tooltip:GetSpell() then return end

    local lines = tooltip:NumLines()
    if lines < 2 then return end

    -- Check if it's a quest-related object
    local hasQuestIndicator = false
    for i = 2, lines do
        local line = _G["GameTooltipTextLeft" .. i]
        if line and line:IsShown() then
            local r, g, b = line:GetTextColor()
            -- Quest yellow color
            if math.abs(r - 1.0) < 0.1 and math.abs(g - 0.82) < 0.1 and math.abs(b - 0) < 0.1 then
                hasQuestIndicator = true
                break
            end
        end
    end

    if not hasQuestIndicator then return end

    -- Get object name
    local objectName = _G["GameTooltipTextLeft1"]:GetText()
    if not objectName then return end

    -- Skip corpses
    if string.find(objectName, "Corpse") then return end

    Questie:Debug(Questie.DEBUG_DEVELOP, "[AscensionLoader] Discovered Object:", objectName)

    if not self.discoveredObjects[objectName] then
        self.discoveredObjects[objectName] = {
            name = objectName,
            positions = {}
        }

        -- Try to get position
        local x, y, zoneId = QuestieCompat:GetCurrentPlayerPosition()
        if x and y and zoneId then
            table.insert(self.discoveredObjects[objectName].positions, {x = x, y = y, zone = zoneId})
        end
    end
end

-- Handle quest log events
function AscensionLoader:QUEST_LOG_UPDATE()
    -- Scan quest log for custom quests
    local numEntries = GetNumQuestLogEntries()
    for i = 1, numEntries do
        local title, level, tag, isHeader, _, isComplete, _, questId = GetQuestLogTitle(i)

        -- Only process actual quests (not headers)
        if not isHeader and questId then
            -- Check if this is a custom Ascension quest or missing from database
            if (questId > 100000 or not QuestieDB.QuestPointers[questId]) then
                if not self.discoveredQuests[questId] then
                    -- Get quest link for more info
                    local qlink = GetQuestLink(i)

                    -- Collect quest data
                    local questData = {
                        id = questId,
                        title = title,
                        level = level,
                        tag = tag,
                        isComplete = isComplete
                    }

                    -- Get objectives
                    local objectives = {}
                    local numObjectives = GetNumQuestLeaderBoards(i)
                    for objIndex = 1, numObjectives do
                        local desc, type, done = GetQuestLogLeaderBoard(objIndex, i)
                        if desc then
                            table.insert(objectives, {
                                description = desc,
                                type = type,
                                done = done
                            })
                        end
                    end
                    questData.objectives = objectives

                    -- Get quest items (rewards and choices)
                    SelectQuestLogEntry(i)

                    local rewards = {}
                    local numRewards = GetNumQuestLogRewards()
                    for rewIndex = 1, numRewards do
                        local name, texture, count = GetQuestLogRewardInfo(rewIndex)
                        if name then
                            table.insert(rewards, {name = name, texture = texture, count = count})
                        end
                    end
                    questData.rewards = rewards

                    local choices = {}
                    local numChoices = GetNumQuestLogChoices()
                    for choiceIndex = 1, numChoices do
                        local name, texture, count = GetQuestLogChoiceInfo(choiceIndex)
                        if name then
                            table.insert(choices, {name = name, texture = texture, count = count})
                        end
                    end
                    questData.choices = choices

                    self.discoveredQuests[questId] = questData
                    Questie:Debug(Questie.DEBUG_DEVELOP, "[AscensionLoader] Discovered quest:", questId, title, "Level:", level, "Objectives:", numObjectives)
                end
            end
        end
    end
end

function AscensionLoader:UNIT_QUEST_LOG_CHANGED(unit)
    if unit == "player" then
        self:QUEST_LOG_UPDATE()
    end
end

function AscensionLoader:RegisterEvent(event)
    if not self.frame then
        self.frame = CreateFrame("Frame")
        self.frame:SetScript("OnEvent", function(_, event, ...)
            if AscensionLoader[event] then
                AscensionLoader[event](AscensionLoader, ...)
            end
        end)
    end
    self.frame:RegisterEvent(event)
end

return AscensionLoader
