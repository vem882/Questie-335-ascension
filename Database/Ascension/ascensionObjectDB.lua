---@type QuestieDB
local QuestieDB = QuestieLoader:ImportModule("QuestieDB")

-- Ascension WoW Object Database
-- This file contains Ascension-specific object (game objects) data
-- Data is merged with the base Wotlk database when Ascension is detected

QuestieDB.AscensionObjectDB = {
    -- Data structure follows Questie object database format
    -- Will be populated and merged on demand
}

-- Function to merge Ascension Object data into main database
function QuestieDB:LoadAscensionObjectData()
    if not QuestieCompat.IsAscension then
        return
    end
    
    -- Ascension-specific objects will be added here
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ffccQuestie-335:|r |cFFFFFF00Ascension Object database loaded.|r")
end
