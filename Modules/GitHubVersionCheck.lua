---@class GitHubVersionCheck
local GitHubVersionCheck = {}

-- Current version from TOC
GitHubVersionCheck.CURRENT_VERSION = "9.5.1-ascension-v1.0.1-beta"
GitHubVersionCheck.GITHUB_REPO = "vem882/Questie-335-ascension"
GitHubVersionCheck.CHECK_INTERVAL = 3600 -- Check once per hour (in seconds)
GitHubVersionCheck.lastCheck = 0
GitHubVersionCheck.latestVersion = nil
GitHubVersionCheck.updateAvailable = false

-- Parse version string to comparable number
local function ParseVersion(versionStr)
    if not versionStr then return 0 end
    
    -- Remove 'v' prefix if exists
    versionStr = versionStr:gsub("^v", "")
    
    -- Split by dots
    local major, minor, patch = versionStr:match("^(%d+)%.(%d+)%.(%d+)")
    if not major then return 0 end
    
    return tonumber(major) * 10000 + tonumber(minor) * 100 + tonumber(patch)
end

-- Compare two versions
local function IsNewerVersion(current, latest)
    local currentNum = ParseVersion(current)
    local latestNum = ParseVersion(latest)
    return latestNum > currentNum
end

-- HTTP request callback
local function OnVersionCheckComplete(response, statusCode)
    if statusCode ~= 200 or not response then
        --print("[Questie] Failed to check for updates (HTTP " .. tostring(statusCode) .. ")")
        return
    end
    
    -- Parse JSON response (simple tag_name extraction)
    local version = response:match('"tag_name"%s*:%s*"([^"]+)"')
    if not version then
        --print("[Questie] Failed to parse GitHub API response")
        return
    end
    
    GitHubVersionCheck.latestVersion = version
    
    if IsNewerVersion(GitHubVersionCheck.CURRENT_VERSION, version) then
        GitHubVersionCheck.updateAvailable = true
        print("|cFF00FF00[Questie]|r |cFFFFFF00New version available!|r")
        print("|cFF00FF00[Questie]|r Current: " .. GitHubVersionCheck.CURRENT_VERSION .. " | Latest: " .. version)
        print("|cFF00FF00[Questie]|r Download from: https://github.com/" .. GitHubVersionCheck.GITHUB_REPO .. "/releases")
        
        -- Show update notification popup
        StaticPopupDialogs["QUESTIE_UPDATE_AVAILABLE"] = {
            text = "|cFF00FF00Questie Update Available!|r\n\nCurrent version: " .. GitHubVersionCheck.CURRENT_VERSION .. "\nLatest version: " .. version .. "\n\nWould you like to visit the download page?",
            button1 = "Yes",
            button2 = "No",
            OnAccept = function()
                -- Copy URL to chat for easy access
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Questie]|r Download: https://github.com/" .. GitHubVersionCheck.GITHUB_REPO .. "/releases/latest")
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
        }
        
        -- Show popup after 5 seconds delay (so it doesn't interfere with login)
        C_Timer.After(5, function()
            StaticPopup_Show("QUESTIE_UPDATE_AVAILABLE")
        end)
    else
        print("|cFF00FF00[Questie]|r You are running the latest version (" .. GitHubVersionCheck.CURRENT_VERSION .. ")")
    end
end

-- Perform version check
function GitHubVersionCheck:Check(forceCheck)
    local currentTime = time()
    
    -- Don't check too frequently unless forced
    if not forceCheck and (currentTime - self.lastCheck) < self.CHECK_INTERVAL then
        return
    end
    
    self.lastCheck = currentTime
    
    -- Use GitHub API to get latest release
    local url = "https://api.github.com/repos/" .. self.GITHUB_REPO .. "/releases/latest"
    
    print("|cFF00FF00[Questie]|r Checking for updates...")
    
    -- WoW 3.3.5a doesn't have built-in HTTP, so we'll use a workaround
    -- We'll check if the user has manually created a file with version info
    self:CheckManualVersionFile()
end

-- Fallback: Check for manually created version file
function GitHubVersionCheck:CheckManualVersionFile()
    -- Since WoW 3.3.5a can't make HTTP requests, we provide a manual method
    -- Users can download a version.txt file from GitHub and place it in the addon folder
    
    -- For now, we'll just inform users about the GitHub page
    print("|cFF00FF00[Questie]|r Check for updates at: https://github.com/" .. self.GITHUB_REPO .. "/releases")
end

-- Manual version check command
function GitHubVersionCheck:ManualCheck()
    print("|cFF00FF00[Questie]|r =================================")
    print("|cFF00FF00[Questie]|r Current Version: " .. self.CURRENT_VERSION)
    print("|cFF00FF00[Questie]|r Repository: https://github.com/" .. self.GITHUB_REPO)
    print("|cFF00FF00[Questie]|r Latest Release: https://github.com/" .. self.GITHUB_REPO .. "/releases/latest")
    print("|cFF00FF00[Questie]|r =================================")
    
    -- Open URL in default browser (if possible)
    -- Note: This requires macro or external help in WoW 3.3.5a
    print("|cFF00FF00[Questie]|r Copy this URL to check for updates:")
    print("https://github.com/" .. self.GITHUB_REPO .. "/releases/latest")
end

-- Initialize on addon load
function GitHubVersionCheck:Initialize()
    -- Register slash command
    SLASH_QUESTIEVERSION1 = "/questieversion"
    SLASH_QUESTIEVERSION2 = "/qversion"
    SlashCmdList["QUESTIEVERSION"] = function()
        self:ManualCheck()
    end
    
    -- Show version info on load
    C_Timer.After(3, function()
        print("|cFF00FF00[Questie]|r Version " .. self.CURRENT_VERSION .. " loaded")
        print("|cFF00FF00[Questie]|r Use /questieversion to check for updates")
    end)
end

_G.GitHubVersionCheck = GitHubVersionCheck
