---@class Expansions
local Expansions = QuestieLoader:CreateModule("Expansions")

-- Make sure these are available
-- Provided by blizzard
local expansionOrderLookup = {
    [2] = 1,
    [5] = 2,
    [11] = 3,
    [14] = 4,
    [19] = 5,
    -- [1] = 100000000, -- Retail is in the far future
}

-- Get interface version to determine expansion
local interfaceVersion = select(4, GetBuildInfo())

-- Debug info for custom clients (like Ascension)
if not WOW_PROJECT_ID or not expansionOrderLookup[WOW_PROJECT_ID] then
    print("|cFF4DDBFF[Questie]|r Detecting expansion via Interface version: " .. tostring(interfaceVersion))
end

-- Detect expansion based on available information
-- Note: Questie global may not be initialized yet, so check safely
local isTBC = Questie and Questie.IsTBC
if isTBC then
    Expansions.Current = expansionOrderLookup[5]
elseif WOW_PROJECT_ID and expansionOrderLookup[WOW_PROJECT_ID] then
    -- Standard WoW client with known project ID
    Expansions.Current = expansionOrderLookup[WOW_PROJECT_ID]
elseif interfaceVersion >= 30000 and interfaceVersion < 40000 then
    -- WotLK client (including Ascension and other custom servers)
    Expansions.Current = expansionOrderLookup[11] -- WotLK = 3
    print("|cFF4DDBFF[Questie]|r |cFF00FF00Detected WotLK client (Interface: " .. interfaceVersion .. ")|r")
else
    -- Default to Classic Era if unknown
    Expansions.Current = expansionOrderLookup[2]
    print("|cFF4DDBFF[Questie]|r |cFFFFAA00Defaulting to Classic Era (Interface: " .. tostring(interfaceVersion) .. ")|r")
end

-- Expansions.Retail = expansionOrderLookup[WOW_PROJECT_MAINLINE or 1]
Expansions.Era = expansionOrderLookup[WOW_PROJECT_CLASSIC or 2]
Expansions.Tbc = expansionOrderLookup[WOW_PROJECT_BURNING_CRUSADE_CLASSIC or 5]
Expansions.Wotlk = expansionOrderLookup[WOW_PROJECT_WRATH_CLASSIC or 11]
Expansions.Cata = expansionOrderLookup[WOW_PROJECT_CATACLYSM_CLASSIC or 14]
Expansions.MoP = expansionOrderLookup[WOW_PROJECT_MISTS_CLASSIC or 19]

return Expansions
