---@class SubzoneMarkers
local SubzoneMarkers = QuestieLoader:CreateModule("SubzoneMarkers")
SubzoneMarkers.private = SubzoneMarkers.private or {}
local _SubzoneMarkers = SubzoneMarkers.private

---@type ZoneDB
local ZoneDB = QuestieLoader:ImportModule("ZoneDB")
---@type QuestieMap
local QuestieMap = QuestieLoader:ImportModule("QuestieMap")
---@type QuestieFramePool
local QuestieFramePool = QuestieLoader:ImportModule("QuestieFramePool")

--- COMPATIBILITY ---
local C_Timer = QuestieCompat.C_Timer
local C_Map = QuestieCompat.C_Map

local LibStub = rawget(_G, "LibStub")

local HBDPins = QuestieCompat.HBDPins or (LibStub and LibStub("HereBeDragonsQuestie-Pins-2.0"))
local HBD = QuestieCompat.HBD or (LibStub and LibStub("HereBeDragonsQuestie-2.0"))
local WorldMapFrame = QuestieCompat.WorldMapFrame

local tinsert = table.insert
local pairs = pairs
local tonumber = tonumber
local pcall = pcall

local TYPE_WORLD = "subzone_world"
local TYPE_MINI = "subzone_mini"

-- Use a known-good built-in texture (MinimapPing is not a file path in some clients)
local ICON_TEXTURE = "Interface\\WorldMap\\WorldMapPartyIcon"

local function _shouldBeEnabled()
    return Questie
        and Questie.db
        and Questie.db.profile
        and Questie.db.profile.enabled
        and Questie.db.profile.showSubzoneMarkers
end

local function _getAreaIdFromUiMapId(uiMapId)
    if not uiMapId then
        return nil
    end

    if ZoneDB and ZoneDB.GetAreaIdByUiMapId then
        local ok, areaId = pcall(ZoneDB.GetAreaIdByUiMapId, ZoneDB, uiMapId)
        if ok and areaId then
            return areaId
        end
    end

    return uiMapId
end

local function _getAreaName(areaId)
    if ZoneDB and ZoneDB.private and ZoneDB.private.zoneNames then
        local name = ZoneDB.private.zoneNames[areaId] or ZoneDB.private.zoneNames[tonumber(areaId)]
        if type(name) == "string" and name ~= "" then
            return name
        end
    end

    if C_Map and C_Map.GetAreaInfo then
        local name = C_Map.GetAreaInfo(areaId)
        if type(name) == "string" and name ~= "" then
            return name
        end
    end

    return "Area " .. tostring(areaId)
end

function _SubzoneMarkers:BuildIndexIfNeeded()
    if self._indexed then
        return
    end

    self._subzonesByParent = {}
    self._subzoneCount = 0
    self._parentCount = 0

    local subZoneCoordinates = ZoneDB.private and ZoneDB.private.subZoneCoordinates
    if type(subZoneCoordinates) ~= "table" then
        self._indexed = true
        return
    end

    for subZoneId, entry in pairs(subZoneCoordinates) do
        if type(entry) == "table" then
            local parentAreaId = tonumber(entry[1])
            if parentAreaId then
                if not self._subzonesByParent[parentAreaId] then
                    self._subzonesByParent[parentAreaId] = {}
                    self._parentCount = self._parentCount + 1
                end
                tinsert(self._subzonesByParent[parentAreaId], { subZoneId = subZoneId, w = entry[2], h = entry[3], x = entry[4], y = entry[5] })
                self._subzoneCount = self._subzoneCount + 1
            end
        end
    end

    self._indexed = true
end

function _SubzoneMarkers:UnloadType(typ)
    if QuestieMap and QuestieMap.ResetManualFrames then
        if QuestieMap.manualFrames and QuestieMap.manualFrames[typ] then
            QuestieMap:ResetManualFrames(typ)
        end
    end
end

local function _createMarkerData(subZoneId, parentAreaId)
    local subZoneName = _getAreaName(subZoneId)

    local data = {}
    data.id = subZoneId
    data.Id = subZoneId
    data.Type = "subzone"
    data.spawnType = "subzone"
    data.Name = subZoneName

    data.Icon = ICON_TEXTURE
    data.GetIconScale = function()
        return 1
    end

    data.ManualTooltipData = {
        Title = subZoneName,
        Body = {},
        disableShiftToRemove = true,
    }

    return data
end

function _SubzoneMarkers:DrawWorldMarker(parentAreaId, subZoneId, x, y)
    local uiMapId = ZoneDB:GetUiMapIdByAreaId(parentAreaId)
    if not uiMapId then
        return
    end

    local data = _createMarkerData(subZoneId, parentAreaId)

    if not QuestieMap.manualFrames[TYPE_WORLD] then
        QuestieMap.manualFrames[TYPE_WORLD] = {}
    end
    if not QuestieMap.manualFrames[TYPE_WORLD][subZoneId] then
        QuestieMap.manualFrames[TYPE_WORLD][subZoneId] = {}
    end

    ---@type any
    local icon = QuestieFramePool:GetFrame()
    icon.data = data
    icon.x = x
    icon.y = y
    icon.AreaID = parentAreaId
    icon.UiMapID = uiMapId
    icon.miniMapIcon = false
    icon.texture:SetTexture(data.Icon)
    icon:SetWidth(16 * (data:GetIconScale() or 0.7))
    icon:SetHeight(16 * (data:GetIconScale() or 0.7))

    QuestieMap:QueueDraw(QuestieMap.ICON_MAP_TYPE, Questie, icon, uiMapId, x / 100, y / 100, 3)
    tinsert(QuestieMap.manualFrames[TYPE_WORLD][subZoneId], icon:GetName())

    if (not Questie.db.profile.enabled) or (not Questie.db.profile.enableMapIcons) then
        icon:FakeHide()
    end

    QuestieMap.utils:RescaleIcon(icon)
end

function _SubzoneMarkers:DrawMinimapMarker(parentAreaId, subZoneId, x, y)
    local uiMapId = ZoneDB:GetUiMapIdByAreaId(parentAreaId)
    if not uiMapId then
        return
    end

    local data = _createMarkerData(subZoneId, parentAreaId)

    if not QuestieMap.manualFrames[TYPE_MINI] then
        QuestieMap.manualFrames[TYPE_MINI] = {}
    end
    if not QuestieMap.manualFrames[TYPE_MINI][subZoneId] then
        QuestieMap.manualFrames[TYPE_MINI][subZoneId] = {}
    end

    ---@type any
    local icon = QuestieFramePool:GetFrame()
    icon.data = data
    icon.x = x
    icon.y = y
    icon.AreaID = parentAreaId
    icon.UiMapID = uiMapId
    icon.miniMapIcon = true
    icon.texture:SetTexture(data.Icon)
    icon:SetWidth(16 * ((data:GetIconScale() or 1) * (Questie.db.profile.globalMiniMapScale or 0.7)))
    icon:SetHeight(16 * ((data:GetIconScale() or 1) * (Questie.db.profile.globalMiniMapScale or 0.7)))

    QuestieMap:QueueDraw(QuestieMap.ICON_MINIMAP_TYPE, Questie, icon, uiMapId, x / 100, y / 100, true, true)
    tinsert(QuestieMap.manualFrames[TYPE_MINI][subZoneId], icon:GetName())

    if (not Questie.db.profile.enabled) or (not Questie.db.profile.enableMiniMapIcons) then
        icon:FakeHide()
    end

    QuestieMap.utils:RescaleIcon(icon)
end

function _SubzoneMarkers:LoadForParentAreaId(parentAreaId, typ)
    self:BuildIndexIfNeeded()

    if not self._subzonesByParent then
        return
    end

    local list = self._subzonesByParent[parentAreaId]
    if not list then
        return
    end

    local uiMapId = ZoneDB and ZoneDB.GetUiMapIdByAreaId and ZoneDB:GetUiMapIdByAreaId(parentAreaId)
    local canCheckExplored = uiMapId and QuestieMap and QuestieMap.utils and QuestieMap.utils.IsExplored

    for _, entry in pairs(list) do
        local x = tonumber(entry.x)
        local y = tonumber(entry.y)

        -- `subZoneCoordinates` appears to store the subzone center point.
        -- width/height are not needed for icon placement.
        if x and y then
            if canCheckExplored and QuestieMap.utils:IsExplored(uiMapId, x, y) then
            elseif typ == TYPE_WORLD then
                self:DrawWorldMarker(parentAreaId, entry.subZoneId, x, y)
            else
                self:DrawMinimapMarker(parentAreaId, entry.subZoneId, x, y)
            end
        end
    end
end

function _SubzoneMarkers:GetCurrentWorldMapAreaId()
    local uiMapId

    if HBDPins and HBDPins.worldmapProvider and HBDPins.worldmapProvider.GetMap then
        local map = HBDPins.worldmapProvider:GetMap()
        if map and map.GetMapID then
            uiMapId = map:GetMapID()
        end
    end

    if not uiMapId and WorldMapFrame and WorldMapFrame.GetMapID then
        uiMapId = WorldMapFrame:GetMapID()
    end

    if not uiMapId then
    end

    return _getAreaIdFromUiMapId(uiMapId)
end

function _SubzoneMarkers:GetPlayerAreaId()
    local uiMapId

    if HBD and HBD.GetPlayerZone then
        uiMapId = HBD:GetPlayerZone()
    end

    if not uiMapId then
    end

    return _getAreaIdFromUiMapId(uiMapId)
end

function SubzoneMarkers:Refresh(force)
    if not _shouldBeEnabled() then
        self:Disable()
        return
    end

    local worldAreaId = _SubzoneMarkers:GetCurrentWorldMapAreaId()
    if force or (worldAreaId and worldAreaId ~= _SubzoneMarkers._activeWorldAreaId) then
        _SubzoneMarkers:UnloadType(TYPE_WORLD)
        _SubzoneMarkers._activeWorldAreaId = worldAreaId
        if worldAreaId then
            _SubzoneMarkers:LoadForParentAreaId(worldAreaId, TYPE_WORLD)
        end
    end

    local playerAreaId = _SubzoneMarkers:GetPlayerAreaId()
    if force or (playerAreaId and playerAreaId ~= _SubzoneMarkers._activePlayerAreaId) then
        _SubzoneMarkers:UnloadType(TYPE_MINI)
        _SubzoneMarkers._activePlayerAreaId = playerAreaId
        if playerAreaId then
            _SubzoneMarkers:LoadForParentAreaId(playerAreaId, TYPE_MINI)
        end
    end
end

function SubzoneMarkers:Enable()
    if _SubzoneMarkers._ticker then
        return
    end

    if not QuestieMap or not QuestieMap.manualFrames then
        return
    end

    if not C_Timer or not C_Timer.NewTicker then
        return
    end

    if Questie and Questie.RegisterEvent and not _SubzoneMarkers._mapExplorationEventRegistered then
        _SubzoneMarkers._mapExplorationEventRegistered = true
        Questie:RegisterEvent("MAP_EXPLORATION_UPDATED", function()
            if _SubzoneMarkers._ticker then
                SubzoneMarkers:Refresh(true)
            end
        end)
    end

    -- Ensure our manual frame buckets exist so QuestieMap:RescaleIcons doesn't error
    QuestieMap.manualFrames[TYPE_WORLD] = QuestieMap.manualFrames[TYPE_WORLD] or {}
    QuestieMap.manualFrames[TYPE_MINI] = QuestieMap.manualFrames[TYPE_MINI] or {}

    self:Refresh(true)

    _SubzoneMarkers._ticker = C_Timer.NewTicker(0.75, function()
        if not _shouldBeEnabled() then
            SubzoneMarkers:Disable()
            return
        end
        SubzoneMarkers:Refresh(false)
    end)

end

function SubzoneMarkers:Disable()
    if _SubzoneMarkers._ticker then
        _SubzoneMarkers._ticker:Cancel()
        _SubzoneMarkers._ticker = nil
    end

    _SubzoneMarkers._activeWorldAreaId = nil
    _SubzoneMarkers._activePlayerAreaId = nil

    _SubzoneMarkers:UnloadType(TYPE_WORLD)
    _SubzoneMarkers:UnloadType(TYPE_MINI)
end

function SubzoneMarkers:Toggle(enabled)
    if not Questie or not Questie.db or not Questie.db.profile then
        return
    end

    Questie.db.profile.showSubzoneMarkers = enabled and true or false

    if Questie.db.profile.showSubzoneMarkers then
        self:Enable()
    else
        self:Disable()
    end
end

function SubzoneMarkers:Init()
    if _shouldBeEnabled() then
        self:Enable()
    end
end
