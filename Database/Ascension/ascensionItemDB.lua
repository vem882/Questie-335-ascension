---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Ascension WoW Item Database
-- This file contains Ascension-specific item data
-- Data is merged with the base Wotlk database when Ascension is detected

QuestieDB.AscensionItemDB = {
    -- Data structure follows Questie item database format
    -- Will be populated and merged on demand
}

-- Function to merge Ascension Item data into main database
function QuestieDB:LoadAscensionItemData()
    if not QuestieCompat.IsAscension then
        return
    end
    
    -- Ascension-specific items will be added here
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccQuestie-335:|r |cFFFFFF00Ascension Item database loaded.|r")
end
