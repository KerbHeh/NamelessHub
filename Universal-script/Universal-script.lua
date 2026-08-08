-- ================================================================
-- NAMELESS HUB 🌌
-- Universal Game Detector
-- Improved detection: GameId -> API -> PlaceId
-- ================================================================

local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")

local localPlayer = Players.LocalPlayer
local placeId = game.PlaceId

-- game.GameId is Roblox's UniverseId for the current experience.
-- It is preferred because it avoids depending on an external HTTP request.
local gameId = game.GameId

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)

    print(("[" .. tostring(title) .. "] " .. tostring(text)))
end

local function safeHttpGet(url)
    local ok, result = pcall(function()
        return game:HttpGet(url, true)
    end)

    if ok and type(result) == "string" and #result > 0 then
        return result
    end

    return nil
end

local function safeLoad(url)
    local source = safeHttpGet(url)

    if not source then
        return false, "HTTP request failed"
    end

    local loader = loadstring
    if type(loader) ~= "function" then
        return false, "loadstring is unavailable"
    end

    local ok, chunkOrError = pcall(loader, source)
    if not ok or type(chunkOrError) ~= "function" then
        return false, "loadstring failed: " .. tostring(chunkOrError)
    end

    local executed, runtimeError = pcall(chunkOrError)
    if not executed then
        return false, "script error: " .. tostring(runtimeError)
    end

    return true
end

-- ================================================================
-- GAME MAP
--
-- IMPORTANT:
-- game.GameId = UniverseId.
-- Keep PlaceIds as a secondary fallback for games where an
-- executor/environment reports an unexpected GameId.
-- ================================================================

local GAMES = {
    -- 99 Nights in the Forest
    -- Current Roblox experience: UniverseId 7326934954
    [7326934954] = {
        name = "99 Nights in the Forest",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/99N",
    },

    -- Old ID kept as compatibility fallback.
    [6379173737] = {
        name = "99 Nights in the Forest (legacy ID)",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/99N",
    },

    -- Brookhaven
    [1693731884] = {
        name = "Brookhaven",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Brook",
    },

    -- Rivals
    [5285888076] = {
        name = "Rivals",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/FPS(rivals)",
    },

    -- Fish It
    [6517738770] = {
        name = "Fish It",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Fish-It",
    },

    -- Steal a Brainrot
    [6390670243] = {
        name = "Steal a Brainrot",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/SAB",
    },

    -- The Strongest Battlegrounds
    [2788229376] = {
        name = "The Strongest Battlegrounds",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsb-Script",
    },

    -- Tsunami
    [7380488627] = {
        name = "Tsunami",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsunami",
    },

    -- Shenanigans
    [1477417799] = {
        name = "Shenanigans",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/shenanigans",
    },
}

local PLACE_FALLBACK = {
    [79546208627805] = {
        name = "99 Nights in the Forest",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/99N",
    },

    [4924922222] = {
        name = "Brookhaven",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Brook",
    },

    [17625359962] = {
        name = "Rivals",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/FPS(rivals)",
    },

    [121864768012064] = {
        name = "Fish It",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Fish-It",
    },

    [109983668079237] = {
        name = "Steal a Brainrot",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/SAB",
    },

    [10449761463] = {
        name = "The Strongest Battlegrounds",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsb-Script",
    },

    [131623223084840] = {
        name = "Tsunami",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsunami",
    },

    [9391468976] = {
        name = "Shenanigans",
        url = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/shenanigans",
    },
}

-- ================================================================
-- OPTIONAL API FALLBACK
--
-- Some environments may expose a bad/zero GameId. In that case,
-- try the place -> universe endpoint used by the original script.
-- ================================================================

local apiUniverseId

if not gameId or gameId == 0 then
    pcall(function()
        local body = safeHttpGet(
            "https://apis.roblox.com/universes/v1/places/"
                .. tostring(placeId)
                .. "/universe"
        )

        if body then
            local data = HttpService:JSONDecode(body)
            if data and tonumber(data.universeId) then
                apiUniverseId = tonumber(data.universeId)
            end
        end
    end)
end

local detectionId = tonumber(gameId) or apiUniverseId

print("================================================")
print("[NamelessHub] PlaceId: " .. tostring(placeId))
print("[NamelessHub] GameId/UniverseId: " .. tostring(gameId))
print("[NamelessHub] API UniverseId: " .. tostring(apiUniverseId))
print("================================================")

-- ================================================================
-- GAME NAME
-- ================================================================

local gameName = "Unknown"

pcall(function()
    local info = MarketplaceService:GetProductInfo(placeId)
    if info and info.Name then
        gameName = info.Name
    end
end)

-- ================================================================
-- DETECTION
-- Priority:
-- 1. game.GameId
-- 2. API UniverseId
-- 3. PlaceId
-- ================================================================

local gameData =
    (detectionId and GAMES[detectionId])
    or GAMES[apiUniverseId]
    or PLACE_FALLBACK[placeId]

notify("NamelessHub", "Checking current game...", 4)

local loaded = false

if gameData then
    notify("NamelessHub", "Game detected!", 4)
    notify(
        "NamelessHub",
        "Detected: " .. tostring(gameData.name or gameName),
        5
    )

    task.wait(0.8)

    local ok, err = safeLoad(gameData.url)

    if ok then
        loaded = true
        notify("NamelessHub", "Game script loaded!", 4)
    else
        warn("[NamelessHub] Failed to load game script:", err)
        notify("NamelessHub", "Game detected, but its script failed to load.", 6)
    end
end

-- ================================================================
-- UNIVERSAL FALLBACK
-- ================================================================

if not loaded then
    notify("NamelessHub", "Game not detected.", 4)
    task.wait(0.5)
    notify("NamelessHub", "Loading Universal script...", 5)

    local universalUrl =
        "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/universal"

    local ok, err = safeLoad(universalUrl)

    if not ok then
        warn("[NamelessHub] Universal script failed:", err)
        notify("NamelessHub", "Universal script failed to load.", 6)
    end
end

print("[NamelessHub] Detector finished.")

-- ================================================================
-- LOCAL PLAYER LEAVE
-- ================================================================

Players.PlayerRemoving:Connect(function(player)
    if player == localPlayer then
        notify(
            "NamelessHub",
            "Awww, leaving already? Stay a little longer :(",
            8
        )
    end
end)
