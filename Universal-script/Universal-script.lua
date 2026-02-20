-- ================================================================
--  NAMELESS HUB 🌌
--  by O_P0ttencias
--  FIXED: usa UniverseId para detectar jogos com sub-lugares
-- ================================================================
local Players            = game:GetService("Players")
local StarterGui         = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService        = game:GetService("HttpService")

local placeId       = game.PlaceId
local localPlayer   = Players.LocalPlayer

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = title,
            Text     = text,
            Duration = duration or 5
        })
    end)
    print("[" .. title .. "] " .. text)
end

-- ================================================================
-- Pega o UniverseId a partir do PlaceId via API Roblox
-- Isso resolve o problema de sub-lugares: todos os lugares de um
-- mesmo jogo compartilham o MESMO UniverseId, mesmo com PlaceIds
-- diferentes.
-- ================================================================
local universeId = nil
pcall(function()
    local data = HttpService:JSONDecode(
        game:HttpGet("https://apis.roblox.com/universes/v1/places/" .. placeId .. "/universe")
    )
    universeId = data and data.universeId
end)

-- Fallback: se a API falhar, usa o PlaceId mesmo
local detectionId = universeId or placeId

print("[NamelessHub] PlaceId: "    .. tostring(placeId))
print("[NamelessHub] UniverseId: " .. tostring(universeId))

-- ================================================================
-- Mapeamento: UniverseId (ou PlaceId como fallback) → script
-- COMO ENCONTRAR O UniverseId DE UM JOGO:
--   1. Abra o jogo no navegador (roblox.com/games/PLACEID)
--   2. A URL mostra o PlaceId.  Abra:
--      https://apis.roblox.com/universes/v1/places/PLACEID/universe
--   3. O campo "universeId" é o que você precisa.
--
-- IDs ABAIXO = UniverseId de cada jogo
-- ================================================================
local GAMES = {
    -- 99 Noites na Floresta  (universeId cobre todos os sub-lugares)
    [6379173737]   = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/99N",

    -- Brookhaven
    [1693731884]   = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Brook",

    -- Rivals (FPS)
    [5285888076]   = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/FPS(rivals)",

    -- Fish-It
    [6517738770]   = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Fish-It",

    -- SAB
    [6390670243]   = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/SAB",

    -- The Strongest Battlegrounds
    [2788229376]   = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsb-Script",

    -- Tsunami
    [7380488627]   = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsunami",

    -- Shenanigans
    [1477417799]   = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/shenanigans",
}

-- ================================================================
-- FALLBACK: PlaceIds originais (caso a API de universo falhe)
-- ================================================================
local PLACE_FALLBACK = {
    [79546208627805]  = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/99N",
    [4924922222]      = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Brook",
    [17625359962]     = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/FPS(rivals)",
    [121864768012064] = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Fish-It",
    [109983668079237] = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/SAB",
    [10449761463]     = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsb-Script",
    [131623223084840] = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsunami",
    [9391468976]      = "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/shenanigans",
}

-- ================================================================
-- INÍCIO
-- ================================================================
notify("NamelessHub", "Thank you for using NamelessHub!", 5)
task.wait(1)
notify("NamelessHub", "One moment... checking which game you are playing..", 5)
task.wait(1.8)

local gameName = "Unknown"
pcall(function()
    local info = MarketplaceService:GetProductInfo(placeId)
    gameName = info.Name
end)

-- Tenta detectar pelo UniverseId primeiro, depois pelo PlaceId
local scriptUrl = GAMES[detectionId] or PLACE_FALLBACK[placeId]

if scriptUrl then
    notify("NamelessHub", "Game has been detected!", 4)
    notify("NamelessHub", "Game Name: " .. gameName, 5)
    task.wait(2)
    notify("NamelessHub", "Welcome!", 4)
    loadstring(game:HttpGet(scriptUrl, true))()
else
    task.wait(1.2)
    notify("NamelessHub", "Undetected game", 4)
    task.wait(2.5)
    notify("NamelessHub", "Using the Universal script", 6)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/universal", true))()
end

-- ================================================================
-- Mensagem de saída
-- ================================================================
Players.PlayerRemoving:Connect(function(plr)
    if plr == localPlayer then
        notify("NamelessHub", "Awww, leaving already? Stay a little longer :(", 8)
    end
end)

notify("NamelessHub", "Thank you for using NamelessHub!", 4)
print("🚀 NamelessHub carregado com sucesso!")
