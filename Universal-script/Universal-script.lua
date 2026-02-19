-- ================================================================
--  NAMELESS HUB 🌌
--  by O_P0ttencias
-- ================================================================

local Fluent          = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager     = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager= loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ================================================================
-- // SERVICES
-- ================================================================
local Players = game:GetService("Players")
local lp      = Players.LocalPlayer

-- ================================================================
-- // PLACE IDs POR JOGO
-- ================================================================
local PlaceIDs = {
    N99         = { 79546208627805 },
    Brook       = { 4924922222 },
    FPS         = { 17625359962, 286090429, 292439477, 6872265 }, -- Rivals, Arsenal, Phantom Forces, Counter Blox
    Fish        = { 121864768012064 },
    SAB         = { 109983668079237 },
    TSB         = { 10449761463 },
    Tsunami     = { 131623223084840 },
    Shenanigans = { 9391468976 },
}

local currentPlace = game.PlaceId

-- ================================================================
-- // HELPERS
-- ================================================================
local function notify(title, msg, dur)
    Fluent:Notify({ Title = title, Content = msg or "", Duration = dur or 4 })
end

local function isInGame(ids)
    for _, id in pairs(ids) do
        if currentPlace == id then return true end
    end
    return false
end

local function getStatusLabel(ids)
    if isInGame(ids) then
        return "✅ Você está neste jogo! Pode carregar."
    else
        return "❌ Jogo incorreto.\nPlace ID atual: " .. tostring(currentPlace)
    end
end

local function loadScript(url, name, ids)
    if not isInGame(ids) then
        notify(
            "⚠️ Jogo Errado!",
            "Este script é só para '" .. name .. "'!\nEntre no jogo correto primeiro.",
            6
        )
        return
    end
    notify("⏳ Carregando", name .. "...", 3)
    local ok, err = pcall(function()
        loadstring(game:HttpGet(url))()
    end)
    if ok then
        notify("✅ Carregado!", name .. " executado com sucesso!", 4)
    else
        notify("❌ Erro", tostring(err), 6)
    end
end

-- ================================================================
-- // WINDOW
-- ================================================================
local Window = Fluent:CreateWindow({
    Title       = "NAMELESS HUB 🌌",
    SubTitle    = "by KerbHeh",
    TabWidth    = 170,
    Size        = UDim2.fromOffset(660, 520),
    Acrylic     = true,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- ================================================================
-- // TABS
-- ================================================================
local Tabs = {
    Universal   = Window:AddTab({ Title = "Universal",            Icon = "globe"     }),
    N99         = Window:AddTab({ Title = "99 Noites",            Icon = "moon"      }),
    Brook       = Window:AddTab({ Title = "Brookhaven",           Icon = "home"      }),
    FPS         = Window:AddTab({ Title = "FPS Games",            Icon = "crosshair" }),
    Fish        = Window:AddTab({ Title = "Fish It!",             Icon = "anchor"    }),
    SAB         = Window:AddTab({ Title = "Steal a Brainrot",     Icon = "zap"       }),
    TSB         = Window:AddTab({ Title = "Strongest BG",         Icon = "sword"     }),
    Tsunami     = Window:AddTab({ Title = "Tsunami Brainrots",    Icon = "waves"     }),
    Shenanigans = Window:AddTab({ Title = "JJK Shenanigans",      Icon = "star"      }),
    Settings    = Window:AddTab({ Title = "Settings",             Icon = "settings"  }),
}

-- ================================================================
-- 🌐 UNIVERSAL (sem verificação de Place ID)
-- ================================================================
Tabs.Universal:AddSection("🌐 Universal Script")
Tabs.Universal:AddParagraph("desc_universal", "Funciona na maioria dos jogos do Roblox.\nNão requer jogo específico.")

Tabs.Universal:AddButton({
    Title       = "▶️ Carregar Universal",
    Description = "Executa o script universal em qualquer jogo",
    Callback    = function()
        notify("⏳ Carregando", "Universal...", 3)
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/universal"))()
        end)
        if ok then
            notify("✅ Carregado!", "Universal executado com sucesso!", 4)
        else
            notify("❌ Erro", tostring(err), 6)
        end
    end
})

-- ================================================================
-- 🌙 99 NOITES — PlaceId: 79546208627805
-- ================================================================
Tabs.N99:AddSection("🌙 99 Noites na Floresta")
Tabs.N99:AddParagraph("status_99n", getStatusLabel(PlaceIDs.N99))
Tabs.N99:AddParagraph("info_99n", "Place ID: 79546208627805")

Tabs.N99:AddButton({
    Title       = "▶️ Carregar Script",
    Description = isInGame(PlaceIDs.N99) and "✅ Pronto para executar!" or "❌ Entre no jogo 99 Noites primeiro",
    Callback    = function()
        loadScript(
            "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/99N",
            "99 Noites",
            PlaceIDs.N99
        )
    end
})

-- ================================================================
-- 🏠 BROOKHAVEN — PlaceId: 4924922222
-- ================================================================
Tabs.Brook:AddSection("🏠 Brookhaven RP")
Tabs.Brook:AddParagraph("status_brook", getStatusLabel(PlaceIDs.Brook))
Tabs.Brook:AddParagraph("info_brook", "Place ID: 4924922222")

Tabs.Brook:AddButton({
    Title       = "▶️ Carregar Script",
    Description = isInGame(PlaceIDs.Brook) and "✅ Pronto para executar!" or "❌ Entre no Brookhaven primeiro",
    Callback    = function()
        loadScript(
            "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Brook",
            "Brookhaven",
            PlaceIDs.Brook
        )
    end
})

-- ================================================================
-- 🎯 FPS GAMES — Rivals (17625359962) + outros FPS
-- ================================================================
Tabs.FPS:AddSection("🎯 FPS Games")
Tabs.FPS:AddParagraph("status_fps", getStatusLabel(PlaceIDs.FPS))
Tabs.FPS:AddParagraph("info_fps",
    "Jogos compatíveis:\n• Rivals — 17625359962\n• Arsenal — 286090429\n• Phantom Forces — 292439477\n• Counter Blox — 6872265"
)

Tabs.FPS:AddButton({
    Title       = "▶️ Carregar Script",
    Description = isInGame(PlaceIDs.FPS) and "✅ FPS compatível detectado!" or "❌ Entre em um FPS compatível",
    Callback    = function()
        loadScript(
            "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/FPS(rivals)",
            "FPS Script",
            PlaceIDs.FPS
        )
    end
})

-- ================================================================
-- 🎣 FISH IT! — PlaceId: 121864768012064
-- ================================================================
Tabs.Fish:AddSection("🎣 Fish It!")
Tabs.Fish:AddParagraph("status_fish", getStatusLabel(PlaceIDs.Fish))
Tabs.Fish:AddParagraph("info_fish", "Place ID: 121864768012064")

Tabs.Fish:AddButton({
    Title       = "▶️ Carregar Script",
    Description = isInGame(PlaceIDs.Fish) and "✅ Pronto para executar!" or "❌ Entre no Fish It! primeiro",
    Callback    = function()
        loadScript(
            "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Fish-It",
            "Fish It!",
            PlaceIDs.Fish
        )
    end
})

-- ================================================================
-- ⚡ STEAL A BRAINROT — PlaceId: 109983668079237
-- ================================================================
Tabs.SAB:AddSection("⚡ Steal a Brainrot")
Tabs.SAB:AddParagraph("status_sab", getStatusLabel(PlaceIDs.SAB))
Tabs.SAB:AddParagraph("info_sab", "Place ID: 109983668079237")

Tabs.SAB:AddButton({
    Title       = "▶️ Carregar Script",
    Description = isInGame(PlaceIDs.SAB) and "✅ Pronto para executar!" or "❌ Entre no Steal a Brainrot primeiro",
    Callback    = function()
        loadScript(
            "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/SAB",
            "Steal a Brainrot",
            PlaceIDs.SAB
        )
    end
})

-- ================================================================
-- ⚔️ THE STRONGEST BATTLEGROUNDS — PlaceId: 10449761463
-- ================================================================
Tabs.TSB:AddSection("⚔️ The Strongest Battlegrounds")
Tabs.TSB:AddParagraph("status_tsb", getStatusLabel(PlaceIDs.TSB))
Tabs.TSB:AddParagraph("info_tsb", "Place ID: 10449761463")

Tabs.TSB:AddButton({
    Title       = "▶️ Carregar Script",
    Description = isInGame(PlaceIDs.TSB) and "✅ Pronto para executar!" or "❌ Entre no TSB primeiro",
    Callback    = function()
        loadScript(
            "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsb-Script",
            "The Strongest Battlegrounds",
            PlaceIDs.TSB
        )
    end
})

-- ================================================================
-- 🌊 ESCAPE TSUNAMI FOR BRAINROTS — PlaceId: 131623223084840
-- ================================================================
Tabs.Tsunami:AddSection("🌊 Escape Tsunami for Brainrots")
Tabs.Tsunami:AddParagraph("status_tsunami", getStatusLabel(PlaceIDs.Tsunami))
Tabs.Tsunami:AddParagraph("info_tsunami", "Place ID: 131623223084840")

Tabs.Tsunami:AddButton({
    Title       = "▶️ Carregar Script",
    Description = isInGame(PlaceIDs.Tsunami) and "✅ Pronto para executar!" or "❌ Entre no Escape Tsunami primeiro",
    Callback    = function()
        loadScript(
            "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/Tsunami",
            "Tsunami vs Brainrots",
            PlaceIDs.Tsunami
        )
    end
})

-- ================================================================
-- ✨ JUJUTSU SHENANIGANS — PlaceId: 9391468976
-- ================================================================
Tabs.Shenanigans:AddSection("✨ Jujutsu Shenanigans")
Tabs.Shenanigans:AddParagraph("status_jjk", getStatusLabel(PlaceIDs.Shenanigans))
Tabs.Shenanigans:AddParagraph("info_jjk", "Place ID: 9391468976")

Tabs.Shenanigans:AddButton({
    Title       = "▶️ Carregar Script",
    Description = isInGame(PlaceIDs.Shenanigans) and "✅ Pronto para executar!" or "❌ Entre no JJK Shenanigans primeiro",
    Callback    = function()
        loadScript(
            "https://raw.githubusercontent.com/KerbHeh/NamelessHub/refs/heads/main/Universal-script/shenanigans",
            "Jujutsu Shenanigans",
            PlaceIDs.Shenanigans
        )
    end
})

-- ================================================================
-- ⚙️ SETTINGS
-- ================================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
InterfaceManager:SetFolder("NamelessHub")
SaveManager:SetFolder("NamelessHub/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- ================================================================
-- // INIT — detectar jogo atual e selecionar aba correta
-- ================================================================
local gameNames = {
    N99         = "99 Noites",
    Brook       = "Brookhaven",
    FPS         = "FPS Game (Rivals/Arsenal...)",
    Fish        = "Fish It!",
    SAB         = "Steal a Brainrot",
    TSB         = "The Strongest Battlegrounds",
    Tsunami     = "Escape Tsunami for Brainrots",
    Shenanigans = "Jujutsu Shenanigans",
}

local tabIndexMap = {
    Universal   = 1,
    N99         = 2,
    Brook       = 3,
    FPS         = 4,
    Fish        = 5,
    SAB         = 6,
    TSB         = 7,
    Tsunami     = 8,
    Shenanigans = 9,
}

local detectedGame = nil
local detectedTab  = 1

for key, ids in pairs(PlaceIDs) do
    if isInGame(ids) then
        detectedGame = gameNames[key]
        detectedTab  = tabIndexMap[key] or 1
        break
    end
end

-- Navegar automaticamente para a aba do jogo detectado
Window:SelectTab(detectedTab)

if detectedGame then
    notify(
        "🎮 Jogo Detectado!",
        detectedGame .. " encontrado!\nAba selecionada automaticamente.",
        6
    )
else
    notify(
        "🌌 NAMELESS HUB",
        "Nenhum jogo específico detectado.\nUse a aba Universal ou entre em um jogo suportado!",
        7
    )
end
