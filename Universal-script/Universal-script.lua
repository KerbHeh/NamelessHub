-- ================================================================
--  NAMELESS HUB 🌌
--  by O_P0ttencias
-- ================================================================
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local MarketplaceService = game:GetService("MarketplaceService")

local placeId = game.PlaceId
local localPlayer = Players.LocalPlayer

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
    print("[" .. title .. "] " .. text)
end

-- Início
notify("NamelessHub", "Thank you for using NamelessHub!", 5)
task.wait(1)
notify("NamelessHub", "One moment... checking which game you are playing..", 5)
task.wait(1.8)

-- Nome real do jogo
local gameName = "Desconhecido"
pcall(function()
    local info = MarketplaceService:GetProductInfo(placeId)
    gameName = info.Name
end)

-- DETECÇÃO
if placeId == 79546208627805 then
    notify("NamelessHub", "Game has been detected!", 4)
    notify("NamelessHub", "Game Name: " .. gameName, 5)
    notify("NamelessHub", "Welcome!", 4)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/99N", true))()

elseif placeId == 4924922222 then
    notify("NamelessHub", "Game has been detected!", 4)
    notify("NamelessHub", "Game Name: " .. gameName, 5)
    task.wait(2)
    notify("NamelessHub", "Welcome!", 4)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Brook", true))()

elseif placeId == 17625359962 then
     notify("NamelessHub", "Game has been detected!", 4)
    notify("NamelessHub", "Game Name: " .. gameName, 5)
    task.wait(2)
    notify("NamelessHub", "Welcome!", 4)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/FPS(rivals)", true))()

elseif placeId == 121864768012064 then
     notify("NamelessHub", "Game has been detected!", 4)
    notify("NamelessHub", "Game Name: " .. gameName, 5)
    task.wait(2)
    notify("NamelessHub", "Welcome!", 4)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Fish-It", true))()

elseif placeId == 109983668079237 then
     notify("NamelessHub", "Game has been detected!", 4)
    notify("NamelessHub", "Game Name: " .. gameName, 5)
    task.wait(2)
    notify("NamelessHub", "Welcome!", 4)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/SAB", true))()

elseif placeId == 10449761463 then
   notify("NamelessHub", "Game has been detected!", 4)
    notify("NamelessHub", "Game Name: " .. gameName, 5)
    task.wait(2)
    notify("NamelessHub", "Welcome!", 4)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsb-Script", true))()

elseif placeId == 131623223084840 then
     notify("NamelessHub", "Game has been detected!", 4)
    notify("NamelessHub", "Game Name: " .. gameName, 5)
    task.wait(2)
    notify("NamelessHub", "Welcome!", 4)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsunami", true))()

elseif placeId == 9391468976 then
  notify("NamelessHub", "Game has been detected!", 4)
    notify("NamelessHub", "Game Name: " .. gameName, 5)
    task.wait(2)
    notify("NamelessHub", "Welcome!", 4)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/shenanigans", true))()

else
    -- Não detectado
    task.wait(1.2)
    notify("NamelessHub", "Undetected game", 4)
    task.wait(2.5)
    notify("NamelessHub", "Using the Universal script", 6)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/universal", true))()
end

-- Despedida fofinha quando sair
Players.PlayerRemoving:Connect(function(plr)
    if plr == localPlayer then
        notify("NamelessHub", "Awww, leaving already? Stay a little longer :(", 8)
    end
end)

notify("NamelessHub", "Thank you for using NamelessHub!", 4)
print("🚀 NamelessHub carregado com sucesso!")
