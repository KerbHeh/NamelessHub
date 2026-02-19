-- ╔═══════════════════════════════════════════════════════╗
-- ║     Escape Tsunami For Brainrots! — Hub Script        ║
-- ║     UI: Fluent Library by dawid-scripts               ║
-- ╚═══════════════════════════════════════════════════════╝

local Fluent         = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager    = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- ╔══════════════════════════════════════╗
-- ║         SERVICES & VARIABLES         ║
-- ╚══════════════════════════════════════╝

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace         = game:GetService("Workspace")
local TeleportService   = game:GetService("TeleportService")
local Lighting          = game:GetService("Lighting")

local LocalPlayer  = Players.LocalPlayer
local Camera       = Workspace.CurrentCamera
local Options      = Fluent.Options
local Connections  = {}

-- ╔══════════════════════════════════════╗
-- ║           STATE VARIABLES            ║
-- ╚══════════════════════════════════════╝

local State = {
    -- Farm
    AutoFarm        = false,
    FarmRarity      = "All",
    AutoCoins       = false,
    AutoGems        = false,
    AutoEvent       = false,

    -- Rebirth / Upgrade
    AutoRebirth     = false,
    AutoUpgradeSpeed    = false,
    AutoUpgradeCarry    = false,
    AutoUpgradeHouse    = false,
    AutoUpgradeAll      = false,

    -- Teleport
    AutoGapTsunami  = false,
    SafeZoneTP      = false,

    -- Movement
    Flying          = false,
    FlySpeed        = 80,
    WalkSpeed       = 16,
    GodMode         = false,
    Noclip          = false,

    -- Collect / Money
    AutoCollect     = false,
    AutoSell        = false,
    RemoveTsunami   = false,
    InfiniteMoney   = false,
    AutoWheel       = false,
    AutoObby        = false,

    -- Misc
    NoTsunamiDamage = false,
    Fullbright      = false,
    AntiVoid        = false,
    InfiniteJump    = false,
    ServerHopping   = false,
}

-- ╔══════════════════════════════════════╗
-- ║            WINDOW / TABS             ║
-- ╚══════════════════════════════════════╝

local Window = Fluent:CreateWindow({
    Title    = "Brainrots Hub",
    SubTitle = "Escape Tsunami For Brainrots!",
    TabWidth = 160,
    Size     = UDim2.fromOffset(620, 500),
    Acrylic  = true,
    Theme    = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Farm     = Window:AddTab({ Title = "Farm",     Icon = "package"       }),
    Rebirth  = Window:AddTab({ Title = "Rebirth",  Icon = "arrow-up-circle"}),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map-pin"       }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "zap"           }),
    Collect  = Window:AddTab({ Title = "Collect",  Icon = "coins"         }),
    Misc     = Window:AddTab({ Title = "Misc",     Icon = "wrench"        }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings"      }),
}

-- ╔══════════════════════════════════════╗
-- ║          HELPER FUNCTIONS            ║
-- ╚══════════════════════════════════════╝

local function Notify(title, content, duration)
    Fluent:Notify({ Title = title, Content = content, Duration = duration or 4 })
end

local function GetChar()   return LocalPlayer.Character end
local function GetRoot()   local c = GetChar() return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum()    local c = GetChar() return c and c:FindFirstChildOfClass("Humanoid") end

local function SafeCall(fn)
    local ok, err = pcall(fn)
    if not ok then warn("[BrainrotsHub] " .. tostring(err)) end
end

-- Find a remote by searching common paths
local function FindRemote(name)
    local paths = {
        ReplicatedStorage,
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Events"),
        ReplicatedStorage:FindFirstChild("RemoteEvents"),
        ReplicatedStorage:FindFirstChild("RemoteFunctions"),
    }
    for _, folder in ipairs(paths) do
        if folder then
            local r = folder:FindFirstChild(name, true)
            if r then return r end
        end
    end
    return nil
end

-- Fire a remote safely
local function FireRemote(name, ...)
    local remote = FindRemote(name)
    if remote then
        if remote:IsA("RemoteEvent") then
            SafeCall(function() remote:FireServer(...) end)
        elseif remote:IsA("RemoteFunction") then
            SafeCall(function() remote:InvokeServer(...) end)
        end
        return true
    end
    return false
end

-- Find all brainrot collectibles in workspace
local function GetBrainrots(rarityFilter)
    local found = {}
    local rarities = {
        All    = {"Common", "Rare", "Mythic", "Brainrot", "Drop", "Collectible", "Item"},
        Common = {"Common"},
        Rare   = {"Rare"},
        Mythic = {"Mythic"},
    }
    local tags = rarities[rarityFilter] or rarities["All"]

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") or obj:IsA("Part") then
            for _, tag in ipairs(tags) do
                if obj.Name:lower():find(tag:lower())
                    or (obj:FindFirstChild("Rarity") and obj.Rarity.Value:lower():find(tag:lower()))
                then
                    table.insert(found, obj)
                    break
                end
            end
        end
    end
    return found
end

-- Find coins / gems dropped in workspace
local function GetDroppedPickups(kind)
    local found = {}
    local keywords = kind == "Coins" and {"coin", "cash", "money", "gold"}
                  or kind == "Gems"  and {"gem", "crystal", "diamond", "ruby"}
                  or {"coin", "cash", "gem", "crystal", "drop", "pickup"}
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local name = obj.Name:lower()
        for _, kw in ipairs(keywords) do
            if name:find(kw) then
                table.insert(found, obj)
                break
            end
        end
    end
    return found
end

-- Teleport character to a position
local function TeleportTo(cframe)
    local root = GetRoot()
    if root then
        root.CFrame = cframe
    end
end

-- Find a part in workspace by name keyword
local function FindInWorkspace(keyword)
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find(keyword:lower()) then
            return obj
        end
    end
    return nil
end

-- ╔══════════════════════════════════════╗
-- ║          FLY SYSTEM                  ║
-- ╚══════════════════════════════════════╝

local FlyBV, FlyBG

local function EnableFly()
    local root = GetRoot()
    local hum  = GetHum()
    if not root then return end

    FlyBG = Instance.new("BodyGyro", root)
    FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBG.CFrame    = root.CFrame

    FlyBV = Instance.new("BodyVelocity", root)
    FlyBV.MaxForce  = Vector3.new(9e9, 9e9, 9e9)
    FlyBV.Velocity  = Vector3.zero

    if hum then hum.PlatformStand = true end
    Notify("Movement", "Fly ON — WASD + E (up) / Q (down)")
end

local function DisableFly()
    if FlyBV then FlyBV:Destroy() FlyBV = nil end
    if FlyBG then FlyBG:Destroy() FlyBG = nil end
    local hum = GetHum()
    if hum then hum.PlatformStand = false end
end

-- ╔══════════════════════════════════════╗
-- ║         🌊  FARM TAB                 ║
-- ╚══════════════════════════════════════╝

Tabs.Farm:AddParagraph({
    Title   = "Auto Farm — Brainrots",
    Content = "Coleta automaticamente brainrots, coins e gems. Funciona em AFK total."
})

local DropdownFarmRarity = Tabs.Farm:AddDropdown("FarmRarity", {
    Title   = "Rarity Filter",
    Description = "Quais brainrots coletar",
    Values  = {"All", "Common", "Rare", "Mythic"},
    Multi   = false,
    Default = 1,
})
DropdownFarmRarity:OnChanged(function(v) State.FarmRarity = v end)

local ToggleAutoFarm = Tabs.Farm:AddToggle("AutoFarm", {
    Title       = "Auto Farm Brainrots",
    Description = "Teleporta e coleta todos os brainrots no mapa automaticamente",
    Default     = false,
})
ToggleAutoFarm:OnChanged(function()
    State.AutoFarm = Options.AutoFarm.Value
    Notify("Farm", State.AutoFarm and "Auto Farm Ativado ✅" or "Auto Farm Desativado ❌")
end)

local ToggleAutoCoins = Tabs.Farm:AddToggle("AutoCoins", {
    Title       = "Auto Collect Coins",
    Description = "Coleta automaticamente todas as coins no chão",
    Default     = false,
})
ToggleAutoCoins:OnChanged(function()
    State.AutoCoins = Options.AutoCoins.Value
    Notify("Farm", State.AutoCoins and "Auto Coins Ativado ✅" or "Auto Coins Desativado ❌")
end)

local ToggleAutoGems = Tabs.Farm:AddToggle("AutoGems", {
    Title       = "Auto Collect Gems",
    Description = "Coleta automaticamente todas as gems/crystals",
    Default     = false,
})
ToggleAutoGems:OnChanged(function()
    State.AutoGems = Options.AutoGems.Value
    Notify("Farm", State.AutoGems and "Auto Gems Ativado ✅" or "Auto Gems Desativado ❌")
end)

local ToggleAutoEvent = Tabs.Farm:AddToggle("AutoEvent", {
    Title       = "Auto Event Farm",
    Description = "Participa automaticamente de eventos especiais no mapa",
    Default     = false,
})
ToggleAutoEvent:OnChanged(function()
    State.AutoEvent = Options.AutoEvent.Value
    Notify("Farm", State.AutoEvent and "Auto Event Ativado ✅" or "Auto Event Desativado ❌")
end)

Tabs.Farm:AddButton({
    Title       = "Collect All Now",
    Description = "Coleta tudo no mapa instantaneamente (one-shot)",
    Callback    = function()
        local root = GetRoot()
        if not root then Notify("Farm", "Personagem não encontrado!") return end
        local items = GetBrainrots(State.FarmRarity)
        local count = 0
        for _, obj in ipairs(items) do
            local pos = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart"))
                     or obj
            if pos then
                root.CFrame = pos.CFrame + Vector3.new(0,3,0)
                task.wait(0.05)
                count = count + 1
            end
        end
        Notify("Farm", "Coletados: " .. count .. " brainrots!")
    end
})

-- ╔══════════════════════════════════════╗
-- ║       🔁  REBIRTH / UPGRADE TAB      ║
-- ╚══════════════════════════════════════╝

Tabs.Rebirth:AddParagraph({
    Title   = "Auto Rebirth & Upgrades",
    Content = "Rebirth automático e upgrades infinitos de stats. Maxa tudo instantâneo."
})

local ToggleAutoRebirth = Tabs.Rebirth:AddToggle("AutoRebirth", {
    Title       = "Auto Rebirth",
    Description = "Faz rebirth automaticamente sempre que disponível",
    Default     = false,
})
ToggleAutoRebirth:OnChanged(function()
    State.AutoRebirth = Options.AutoRebirth.Value
    Notify("Rebirth", State.AutoRebirth and "Auto Rebirth ON ✅" or "Auto Rebirth OFF ❌")
end)

local ToggleUpgradeAll = Tabs.Rebirth:AddToggle("AutoUpgradeAll", {
    Title       = "Auto Upgrade — TUDO",
    Description = "Maxa Speed, Carry Capacity, House e VIP automaticamente",
    Default     = false,
})
ToggleUpgradeAll:OnChanged(function()
    State.AutoUpgradeAll = Options.AutoUpgradeAll.Value
    Notify("Rebirth", State.AutoUpgradeAll and "Auto Upgrade All ON ✅" or "Auto Upgrade All OFF ❌")
end)

local ToggleUpgradeSpeed = Tabs.Rebirth:AddToggle("AutoUpgradeSpeed", {
    Title       = "Auto Upgrade Speed",
    Description = "Compra upgrades de speed continuamente",
    Default     = false,
})
ToggleUpgradeSpeed:OnChanged(function()
    State.AutoUpgradeSpeed = Options.AutoUpgradeSpeed.Value
end)

local ToggleUpgradeCarry = Tabs.Rebirth:AddToggle("AutoUpgradeCarry", {
    Title       = "Auto Upgrade Carry Capacity",
    Description = "Aumenta o carry limit automaticamente",
    Default     = false,
})
ToggleUpgradeCarry:OnChanged(function()
    State.AutoUpgradeCarry = Options.AutoUpgradeCarry.Value
end)

local ToggleUpgradeHouse = Tabs.Rebirth:AddToggle("AutoUpgradeHouse", {
    Title       = "Auto Upgrade House/Base",
    Description = "Faz upgrade da casa/base automaticamente",
    Default     = false,
})
ToggleUpgradeHouse:OnChanged(function()
    State.AutoUpgradeHouse = Options.AutoUpgradeHouse.Value
end)

Tabs.Rebirth:AddButton({
    Title       = "Max All Upgrades (Now)",
    Description = "Tenta comprar todos os upgrades de uma vez",
    Callback    = function()
        local upgradeNames = {
            "UpgradeSpeed", "BuySpeed", "SpeedUpgrade",
            "UpgradeCarry", "BuyCarry", "CarryUpgrade",
            "UpgradeHouse", "BuyHouse", "HouseUpgrade",
            "Upgrade", "BuyUpgrade", "PurchaseUpgrade",
            "Rebirth", "DoRebirth",
        }
        local fired = 0
        for _, name in ipairs(upgradeNames) do
            local ok = FireRemote(name)
            if ok then fired = fired + 1 end
        end
        -- Also try clicking upgrade GUI buttons
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, btn in ipairs(playerGui:GetDescendants()) do
                if btn:IsA("TextButton") or btn:IsA("ImageButton") then
                    local n = btn.Name:lower()
                    if n:find("upgrade") or n:find("buy") or n:find("rebirth") then
                        SafeCall(function() btn.MouseButton1Click:Fire() end)
                    end
                end
            end
        end
        Notify("Rebirth", "Max Upgrade disparado! Remotes: " .. fired)
    end
})

-- ╔══════════════════════════════════════╗
-- ║       📍  TELEPORT TAB              ║
-- ╚══════════════════════════════════════╝

Tabs.Teleport:AddParagraph({
    Title   = "Teleport / Gap TP",
    Content = "TP instantâneo para safe zones, spawn, evento ou fuga de tsunami."
})

-- Safe Zone TP
Tabs.Teleport:AddButton({
    Title       = "TP → Safe Zone",
    Description = "Teleporta para uma zona segura alta no mapa",
    Callback    = function()
        local safe = FindInWorkspace("SafeZone")
            or FindInWorkspace("Safe")
            or FindInWorkspace("Lobby")
        if safe then
            local pos = safe:IsA("Model") and (safe.PrimaryPart or safe:FindFirstChildOfClass("BasePart")) or safe
            if pos then TeleportTo(CFrame.new(pos.Position + Vector3.new(0, 10, 0))) end
        else
            TeleportTo(CFrame.new(0, 300, 0))
        end
        Notify("Teleport", "Teleportado para Safe Zone ✅")
    end
})

-- TP Spawn
Tabs.Teleport:AddButton({
    Title       = "TP → Spawn",
    Description = "Teleporta de volta ao spawn do mapa",
    Callback    = function()
        local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
        if spawn then
            TeleportTo(spawn.CFrame + Vector3.new(0, 5, 0))
        else
            TeleportTo(CFrame.new(0, 5, 0))
        end
        Notify("Teleport", "Teleportado ao Spawn ✅")
    end
})

-- TP End Area
Tabs.Teleport:AddButton({
    Title       = "TP → End Area / Finish",
    Description = "Teleporta para a área final/conclusão do mapa",
    Callback    = function()
        local endPart = FindInWorkspace("End")
            or FindInWorkspace("Finish")
            or FindInWorkspace("Goal")
            or FindInWorkspace("Exit")
        if endPart then
            local pos = endPart:IsA("Model") and (endPart.PrimaryPart or endPart:FindFirstChildOfClass("BasePart")) or endPart
            if pos then TeleportTo(CFrame.new(pos.Position + Vector3.new(0, 5, 0))) end
            Notify("Teleport", "Teleportado ao End Area ✅")
        else
            Notify("Teleport", "End Area não encontrado no mapa atual.")
        end
    end
})

-- TP to Event
Tabs.Teleport:AddButton({
    Title       = "TP → Event Area",
    Description = "Teleporta para a área de evento (Wheel, Obby, etc.)",
    Callback    = function()
        local event = FindInWorkspace("Event")
            or FindInWorkspace("Wheel")
            or FindInWorkspace("Obby")
            or FindInWorkspace("Bonus")
        if event then
            local pos = event:IsA("Model") and (event.PrimaryPart or event:FindFirstChildOfClass("BasePart")) or event
            if pos then TeleportTo(CFrame.new(pos.Position + Vector3.new(0, 5, 0))) end
            Notify("Teleport", "Teleportado ao Event Area ✅")
        else
            Notify("Teleport", "Event Area não encontrado.")
        end
    end
})

-- Auto Gap TP (fuga de tsunami)
local ToggleAutoGap = Tabs.Teleport:AddToggle("AutoGapTsunami", {
    Title       = "Auto Gap TP (Anti-Tsunami)",
    Description = "Detecta a onda e teleporta automaticamente para segurança",
    Default     = false,
})
ToggleAutoGap:OnChanged(function()
    State.AutoGapTsunami = Options.AutoGapTsunami.Value
    Notify("Teleport", State.AutoGapTsunami and "Auto Gap ON ✅ — Vai escapar automaticamente!" or "Auto Gap OFF ❌")
end)

-- TP to Player
local function GetPlayerList()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(list, p.Name) end
    end
    return #list > 0 and list or {"(Nenhum jogador)"}
end

local DropTPPlayer = Tabs.Teleport:AddDropdown("TPPlayer", {
    Title   = "Teleportar para Jogador",
    Values  = GetPlayerList(),
    Multi   = false,
    Default = 1,
})

Tabs.Teleport:AddButton({
    Title    = "TP → Jogador Selecionado",
    Callback = function()
        local name = Options.TPPlayer and Options.TPPlayer.Value
        if not name or name == "(Nenhum jogador)" then
            Notify("Teleport", "Selecione um jogador!") return
        end
        local target = Players:FindFirstChild(name)
        local tRoot  = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if tRoot then
            TeleportTo(tRoot.CFrame + Vector3.new(0, 3, 4))
            Notify("Teleport", "Teleportado para " .. name)
        else
            Notify("Teleport", "Jogador não encontrado!")
        end
    end
})

Tabs.Teleport:AddButton({
    Title    = "🔄 Atualizar Lista",
    Callback = function()
        DropTPPlayer:SetValues(GetPlayerList())
        Notify("Teleport", "Lista atualizada")
    end
})

-- ╔══════════════════════════════════════╗
-- ║       ⚡  MOVEMENT TAB              ║
-- ╚══════════════════════════════════════╝

Tabs.Movement:AddParagraph({
    Title   = "Movement & God Mode",
    Content = "Voa, corre mais rápido que o tsunami e fica invencível."
})

-- Fly
local ToggleFly = Tabs.Movement:AddToggle("Fly", {
    Title       = "Fly",
    Description = "Voa livremente sobre as ondas. WASD + E/Q",
    Default     = false,
})
ToggleFly:OnChanged(function()
    State.Flying = Options.Fly.Value
    if State.Flying then EnableFly() else DisableFly() end
end)

-- Fly Speed
Tabs.Movement:AddSlider("FlySpeed", {
    Title       = "Fly Speed",
    Description = "Velocidade do voo",
    Default     = 80,
    Min         = 10,
    Max         = 500,
    Rounding    = 1,
    Callback    = function(v) State.FlySpeed = v end,
})

-- WalkSpeed
Tabs.Movement:AddSlider("WalkSpeed", {
    Title       = "WalkSpeed",
    Description = "Velocidade de andar",
    Default     = 16,
    Min         = 0,
    Max         = 500,
    Rounding    = 1,
    Callback    = function(v)
        State.WalkSpeed = v
        local hum = GetHum()
        if hum then hum.WalkSpeed = v end
    end,
})

-- God Mode
local ToggleGod = Tabs.Movement:AddToggle("GodMode", {
    Title       = "God Mode",
    Description = "Invencível — nunca morre pela tsunami ou dano",
    Default     = false,
})
ToggleGod:OnChanged(function()
    State.GodMode = Options.GodMode.Value
    local hum = GetHum()
    if hum then
        if State.GodMode then
            hum.MaxHealth = math.huge
            hum.Health    = math.huge
        else
            hum.MaxHealth = 100
            hum.Health    = 100
        end
    end
    Notify("Movement", State.GodMode and "God Mode ON ✅ — Imortal!" or "God Mode OFF ❌")
end)

-- Noclip
local ToggleNoclip = Tabs.Movement:AddToggle("Noclip", {
    Title       = "Noclip",
    Description = "Atravessa paredes e obstáculos",
    Default     = false,
})
ToggleNoclip:OnChanged(function()
    State.Noclip = Options.Noclip.Value
    Notify("Movement", State.Noclip and "Noclip ON ✅" or "Noclip OFF ❌")
end)

-- Infinite Jump
local ToggleInfJump = Tabs.Movement:AddToggle("InfiniteJump", {
    Title       = "Infinite Jump",
    Description = "Pula infinitamente no ar",
    Default     = false,
})
ToggleInfJump:OnChanged(function()
    State.InfiniteJump = Options.InfiniteJump.Value
end)

-- Remove Tsunami (visual)
local ToggleRemoveTsunami = Tabs.Movement:AddToggle("RemoveTsunami", {
    Title       = "Remove Tsunami (Visual)",
    Description = "Remove visualmente a onda do tsunami (client-side)",
    Default     = false,
})
ToggleRemoveTsunami:OnChanged(function()
    State.RemoveTsunami = Options.RemoveTsunami.Value
    if State.RemoveTsunami then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if n:find("tsunami") or n:find("wave") or n:find("water") or n:find("flood") then
                if obj:IsA("BasePart") then
                    obj.Transparency = 1
                    obj.CanCollide   = false
                end
            end
        end
        Notify("Movement", "Tsunami removido visualmente ✅")
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if n:find("tsunami") or n:find("wave") or n:find("water") or n:find("flood") then
                if obj:IsA("BasePart") then
                    obj.Transparency = 0
                    obj.CanCollide   = true
                end
            end
        end
    end
end)

-- ╔══════════════════════════════════════╗
-- ║       💰  COLLECT / MONEY TAB       ║
-- ╚══════════════════════════════════════╝

Tabs.Collect:AddParagraph({
    Title   = "Auto Collect & Sell",
    Content = "Pega itens dropados, vende automaticamente e eventos de moeda."
})

local ToggleAutoCollect = Tabs.Collect:AddToggle("AutoCollect", {
    Title       = "Auto Collect Drops",
    Description = "Pega automaticamente todos os itens dropados no chão",
    Default     = false,
})
ToggleAutoCollect:OnChanged(function()
    State.AutoCollect = Options.AutoCollect.Value
    Notify("Collect", State.AutoCollect and "Auto Collect ON ✅" or "Auto Collect OFF ❌")
end)

local ToggleAutoSell = Tabs.Collect:AddToggle("AutoSell", {
    Title       = "Auto Sell",
    Description = "Vende o inventário automaticamente quando cheio",
    Default     = false,
})
ToggleAutoSell:OnChanged(function()
    State.AutoSell = Options.AutoSell.Value
    Notify("Collect", State.AutoSell and "Auto Sell ON ✅" or "Auto Sell OFF ❌")
end)

local ToggleInfMoney = Tabs.Collect:AddToggle("InfiniteMoney", {
    Title       = "Infinite Money / Dupe Cash",
    Description = "Tenta duplicar cash via remote (game-specific)",
    Default     = false,
})
ToggleInfMoney:OnChanged(function()
    State.InfiniteMoney = Options.InfiniteMoney.Value
    if State.InfiniteMoney then
        Notify("Collect", "Infinite Money ON ✅ — Disparando remotes de cash...")
    end
end)

local ToggleAutoWheel = Tabs.Collect:AddToggle("AutoWheel", {
    Title       = "Auto Spin Wheel",
    Description = "Gira a roda de prêmios automaticamente",
    Default     = false,
})
ToggleAutoWheel:OnChanged(function()
    State.AutoWheel = Options.AutoWheel.Value
    Notify("Collect", State.AutoWheel and "Auto Wheel ON ✅" or "Auto Wheel OFF ❌")
end)

local ToggleAutoObby = Tabs.Collect:AddToggle("AutoObby", {
    Title       = "Auto Complete Obby",
    Description = "Teleporta pelos checkpoints do obby automaticamente",
    Default     = false,
})
ToggleAutoObby:OnChanged(function()
    State.AutoObby = Options.AutoObby.Value
    Notify("Collect", State.AutoObby and "Auto Obby ON ✅" or "Auto Obby OFF ❌")
end)

Tabs.Collect:AddButton({
    Title       = "Sell Now",
    Description = "Vende o inventário inteiro agora mesmo",
    Callback    = function()
        local remoteNames = {"Sell", "SellAll", "SellItems", "SellInventory", "DoSell"}
        local done = false
        for _, name in ipairs(remoteNames) do
            if FireRemote(name) then done = true break end
        end
        -- Also try GUI sell button
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        if gui then
            for _, btn in ipairs(gui:GetDescendants()) do
                if (btn:IsA("TextButton") or btn:IsA("ImageButton")) then
                    if btn.Name:lower():find("sell") then
                        SafeCall(function() btn.MouseButton1Click:Fire() end)
                        done = true
                    end
                end
            end
        end
        Notify("Collect", done and "Venda realizada! ✅" or "Remote de venda não encontrado.")
    end
})

-- ╔══════════════════════════════════════╗
-- ║         🔧  MISC TAB                ║
-- ╚══════════════════════════════════════╝

Tabs.Misc:AddParagraph({
    Title   = "Miscellaneous",
    Content = "Anti-void, fullbright, server hop e outros."
})

-- Fullbright
local ToggleFullbright = Tabs.Misc:AddToggle("Fullbright", {
    Title       = "Fullbright / No Fog",
    Description = "Máxima iluminação, sem névoa",
    Default     = false,
})
ToggleFullbright:OnChanged(function()
    State.Fullbright = Options.Fullbright.Value
    if State.Fullbright then
        Lighting.Brightness = 10
        Lighting.ClockTime  = 14
        Lighting.FogEnd     = 100000
        Lighting.FogStart   = 99999
        Lighting.GlobalShadows = false
        Lighting.Ambient    = Color3.fromRGB(178,178,178)
    else
        Lighting.Brightness = 1
        Lighting.ClockTime  = 14
        Lighting.FogEnd     = 100000
        Lighting.FogStart   = 0
        Lighting.GlobalShadows = true
        Lighting.Ambient    = Color3.fromRGB(70,70,70)
    end
    Notify("Misc", State.Fullbright and "Fullbright ON ✅" or "Fullbright OFF ❌")
end)

-- Anti Void
local ToggleAntiVoid = Tabs.Misc:AddToggle("AntiVoid", {
    Title       = "Anti Void",
    Description = "Teleporta de volta se cair no void",
    Default     = false,
})
ToggleAntiVoid:OnChanged(function()
    State.AntiVoid = Options.AntiVoid.Value
    Notify("Misc", State.AntiVoid and "Anti Void ON ✅" or "Anti Void OFF ❌")
end)

-- No Tsunami Damage
local ToggleNoTsunami = Tabs.Misc:AddToggle("NoTsunamiDamage", {
    Title       = "No Tsunami Damage",
    Description = "Bloqueia o dano do tsunami ao personagem",
    Default     = false,
})
ToggleNoTsunami:OnChanged(function()
    State.NoTsunamiDamage = Options.NoTsunamiDamage.Value
    Notify("Misc", State.NoTsunamiDamage and "No Tsunami Dmg ON ✅" or "No Tsunami Dmg OFF ❌")
end)

-- Server Hop
Tabs.Misc:AddButton({
    Title       = "Server Hop",
    Description = "Entra num servidor diferente instantaneamente",
    Callback    = function()
        Notify("Misc", "Trocando de servidor...")
        task.wait(1)
        SafeCall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
    end
})

-- Anti AFK
Tabs.Misc:AddButton({
    Title       = "Anti AFK (Ativar uma vez)",
    Description = "Previne kick por AFK usando VirtualUser",
    Callback    = function()
        local VU = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end)
        Notify("Misc", "Anti AFK ativado ✅ — Não vai ser kickado!")
    end
})

-- ╔══════════════════════════════════════╗
-- ║         RUNTIME LOOP (heartbeat)     ║
-- ╚══════════════════════════════════════╝

local farmTick       = 0
local upgradeTick    = 0
local collectTick    = 0
local sellTick       = 0
local moneyTick      = 0
local rebirthTick    = 0
local wheelTick      = 0
local obbyTick       = 0
local eventTick      = 0

Connections.Heartbeat = RunService.Heartbeat:Connect(function(dt)
    local root = GetRoot()
    local hum  = GetHum()
    local char = GetChar()

    -- ── WalkSpeed lock ──────────────────────────────────────────────
    if hum and Options.WalkSpeed and hum.WalkSpeed ~= State.WalkSpeed then
        hum.WalkSpeed = State.WalkSpeed
    end

    -- ── Noclip ──────────────────────────────────────────────────────
    if State.Noclip and char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end

    -- ── God Mode health lock ─────────────────────────────────────────
    if State.GodMode and hum then
        hum.MaxHealth = math.huge
        if hum.Health < 1e10 then hum.Health = math.huge end
    end

    -- ── No Tsunami Damage ────────────────────────────────────────────
    if State.NoTsunamiDamage and hum then
        hum.HealthChanged:Connect(function(hp)
            if hp < hum.MaxHealth and not State.GodMode then
                hum.Health = hum.MaxHealth
            end
        end)
    end

    -- ── Anti Void ────────────────────────────────────────────────────
    if State.AntiVoid and root then
        if root.Position.Y < -80 then
            root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
        end
    end

    -- ── Auto Gap / Tsunami Escape ─────────────────────────────────────
    if State.AutoGapTsunami and root then
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local n = obj.Name:lower()
            if (n:find("tsunami") or n:find("wave") or n:find("flood")) and obj:IsA("BasePart") then
                local dist = (root.Position - obj.Position).Magnitude
                if dist < 80 then
                    root.CFrame = CFrame.new(root.Position.X, 400, root.Position.Z)
                    break
                end
            end
        end
    end

    -- ── Fly ──────────────────────────────────────────────────────────
    if State.Flying and FlyBV and FlyBG and root then
        local vel = Vector3.zero
        local cf  = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cf.LookVector  end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.E) then vel = vel + Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.Q) then vel = vel - Vector3.new(0,1,0) end
        FlyBV.Velocity = vel * State.FlySpeed
        FlyBG.CFrame   = cf
    end

    -- ── Auto Farm Brainrots (interval: 0.15s) ────────────────────────
    farmTick = farmTick + dt
    if farmTick >= 0.15 then
        farmTick = 0
        if State.AutoFarm and root then
            local items = GetBrainrots(State.FarmRarity)
            if #items > 0 then
                local target = items[1]
                local pos = target:IsA("Model") and (target.PrimaryPart or target:FindFirstChildOfClass("BasePart")) or target
                if pos then
                    root.CFrame = CFrame.new(pos.Position + Vector3.new(0, 2, 0))
                end
            end
            -- Also try remote collect
            FireRemote("CollectBrainrot")
            FireRemote("Collect")
            FireRemote("PickUp")
        end

        if State.AutoCoins and root then
            local coins = GetDroppedPickups("Coins")
            for _, obj in ipairs(coins) do
                local p = obj:IsA("Model") and obj.PrimaryPart or obj
                if p then root.CFrame = CFrame.new(p.Position + Vector3.new(0,2,0)) end
            end
            FireRemote("CollectCoin")
            FireRemote("GiveCoin")
        end

        if State.AutoGems and root then
            local gems = GetDroppedPickups("Gems")
            for _, obj in ipairs(gems) do
                local p = obj:IsA("Model") and obj.PrimaryPart or obj
                if p then root.CFrame = CFrame.new(p.Position + Vector3.new(0,2,0)) end
            end
            FireRemote("CollectGem")
        end
    end

    -- ── Auto Collect Drops (interval: 0.2s) ──────────────────────────
    collectTick = collectTick + dt
    if collectTick >= 0.2 then
        collectTick = 0
        if State.AutoCollect and root then
            for _, obj in ipairs(Workspace:GetDescendants()) do
                local n = obj.Name:lower()
                if (n:find("drop") or n:find("pickup") or n:find("item") or n:find("loot")) then
                    local p = obj:IsA("Model") and obj.PrimaryPart or (obj:IsA("BasePart") and obj)
                    if p then
                        local dist = (root.Position - p.Position).Magnitude
                        if dist < 200 then
                            root.CFrame = CFrame.new(p.Position + Vector3.new(0,2,0))
                        end
                    end
                end
            end
        end
    end

    -- ── Auto Sell (interval: 3s) ──────────────────────────────────────
    sellTick = sellTick + dt
    if sellTick >= 3 then
        sellTick = 0
        if State.AutoSell then
            local names = {"Sell", "SellAll", "SellItems", "SellInventory"}
            for _, name in ipairs(names) do FireRemote(name) end
            -- Try GUI sell button
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            if gui then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Name:lower():find("sell") then
                        SafeCall(function() btn.MouseButton1Click:Fire() end)
                    end
                end
            end
        end
    end

    -- ── Infinite Money (interval: 0.5s) ──────────────────────────────
    moneyTick = moneyTick + dt
    if moneyTick >= 0.5 then
        moneyTick = 0
        if State.InfiniteMoney then
            local cashRemotes = {"GiveCash", "GiveMoney", "AddMoney", "AddCash", "GiveCoin", "EarnMoney", "DupeCash"}
            for _, name in ipairs(cashRemotes) do FireRemote(name, 999999) end
            -- Try to set leaderstats values locally
            local ls = LocalPlayer:FindFirstChild("leaderstats")
            if ls then
                for _, val in ipairs(ls:GetChildren()) do
                    if val:IsA("IntValue") or val:IsA("NumberValue") then
                        SafeCall(function() val.Value = val.Value + 10000 end)
                    end
                end
            end
        end
    end

    -- ── Auto Rebirth (interval: 1s) ──────────────────────────────────
    rebirthTick = rebirthTick + dt
    if rebirthTick >= 1 then
        rebirthTick = 0
        if State.AutoRebirth then
            FireRemote("Rebirth")
            FireRemote("DoRebirth")
            FireRemote("PrestigeRebirth")
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            if gui then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Name:lower():find("rebirth") then
                        SafeCall(function() btn.MouseButton1Click:Fire() end)
                    end
                end
            end
        end

        -- ── Auto Upgrade (interval: 1s) ──────────────────────────────
        if State.AutoUpgradeAll or State.AutoUpgradeSpeed then
            FireRemote("UpgradeSpeed") FireRemote("BuySpeed") FireRemote("SpeedUpgrade")
        end
        if State.AutoUpgradeAll or State.AutoUpgradeCarry then
            FireRemote("UpgradeCarry") FireRemote("BuyCarry") FireRemote("CarryUpgrade")
        end
        if State.AutoUpgradeAll or State.AutoUpgradeHouse then
            FireRemote("UpgradeHouse") FireRemote("BuyHouse") FireRemote("HouseUpgrade")
        end
        if State.AutoUpgradeAll then
            FireRemote("Upgrade") FireRemote("BuyUpgrade") FireRemote("PurchaseUpgrade")
            -- Click any buy/upgrade button in GUI
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            if gui then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if (btn:IsA("TextButton") or btn:IsA("ImageButton")) then
                        local n = btn.Name:lower()
                        if n:find("upgrade") or n:find("buy") then
                            SafeCall(function() btn.MouseButton1Click:Fire() end)
                        end
                    end
                end
            end
        end
    end

    -- ── Auto Wheel (interval: 2s) ─────────────────────────────────────
    wheelTick = wheelTick + dt
    if wheelTick >= 2 then
        wheelTick = 0
        if State.AutoWheel then
            FireRemote("SpinWheel")
            FireRemote("Wheel")
            FireRemote("LuckyWheel")
            local gui = LocalPlayer:FindFirstChild("PlayerGui")
            if gui then
                for _, btn in ipairs(gui:GetDescendants()) do
                    if (btn:IsA("TextButton") or btn:IsA("ImageButton")) and btn.Name:lower():find("spin") then
                        SafeCall(function() btn.MouseButton1Click:Fire() end)
                    end
                end
            end
        end
    end

    -- ── Auto Obby (interval: 0.3s) ────────────────────────────────────
    obbyTick = obbyTick + dt
    if obbyTick >= 0.3 then
        obbyTick = 0
        if State.AutoObby and root then
            -- Teleport through checkpoints sequentially
            local checkpoints = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                local n = obj.Name:lower()
                if n:find("checkpoint") or n:find("stage") or n:find("obby") then
                    local p = obj:IsA("BasePart") and obj or (obj:IsA("Model") and obj.PrimaryPart)
                    if p then table.insert(checkpoints, p) end
                end
            end
            if #checkpoints > 0 then
                local target = checkpoints[math.random(1, #checkpoints)]
                root.CFrame = target.CFrame + Vector3.new(0, 5, 0)
            end
        end
    end

    -- ── Auto Event ────────────────────────────────────────────────────
    eventTick = eventTick + dt
    if eventTick >= 1 then
        eventTick = 0
        if State.AutoEvent then
            FireRemote("JoinEvent")
            FireRemote("StartEvent")
            FireRemote("ClaimEvent")
            FireRemote("EventReward")
        end
    end
end)

-- Infinite Jump
Connections.InfJump = UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local hum = GetHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Respawn recovery (re-enable features on respawn)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(1)
    local hum = newChar:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.WalkSpeed
        if State.GodMode then
            hum.MaxHealth = math.huge
            hum.Health    = math.huge
        end
    end
    if State.Flying then
        task.wait(0.5)
        EnableFly()
    end
end)

-- ╔══════════════════════════════════════╗
-- ║         SETTINGS / SAVE MANAGER      ║
-- ╚══════════════════════════════════════╝

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("BrainrotsHub")
SaveManager:SetFolder("BrainrotsHub/configs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()

Fluent:Notify({
    Title    = "🌊 Brainrots Hub",
    Content  = "Script carregado! RCtrl para minimizar a UI.",
    Duration = 7
})
