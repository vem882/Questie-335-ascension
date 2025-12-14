---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Ascension WoW Quest Database
-- This file contains Ascension-specific quest data
-- Data is merged with the base Wotlk database when Ascension is detected

QuestieDB.AscensionQuestDB = {
    -- Data structure follows Questie quest database format
    -- Will be populated and merged on demand
}

-- Function to merge Ascension Quest data into main database
function QuestieDB:LoadAscensionQuestData()
    if not QuestieCompat.IsAscension then
        return
    end
    
    -- Ascension-specific quests will be added here
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccQuestie-335:|r |cFFFFFF00Ascension Quest database loaded.|r")
end
