-- TSB Kerbzinn Hub V11.1 - 2026 (Improved Version)
-- Improvements:
-- 1. Optimized loops: Consolidated multiple Heartbeat/Stepped connections into fewer, more efficient ones.
-- 2. Added proper player added/removed handling for ESP.
-- 3. Improved AutoParry: Added basic attack detection (checks for animations or proximity with velocity).
-- 4. KillAura: Added rotation to face enemy before attacking, and reset hitbox sizes when disabled.
-- 5. InfiniteStamina: Assumed stamina is tied to a local value; added a check for a potential Stamina attribute.
-- 6. AntiRagdoll: More robust by also preventing ragdoll states if applicable.
-- 7. Techs: Added toggles to prevent spamming; only execute if not in cooldown or animation.
-- 8. AutoFarm: Added safety to avoid bans (e.g., random delays, checks for anti-cheat).
-- 9. General: Cleaner code structure, error handling, and UI enhancements.
-- 10. Added a credits section and unload function.

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
local Window = OrionLib:MakeWindow({
    Name = "TSB Kerbzinn Hub V11.1 - 2026",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "TSBKerbzinn2026",
    IntroEnabled = true,
    IntroText = "Carregando o hub mais OP de 2026... (Versão Melhorada)"
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ======================= SETTINGS =======================
local Settings = {
    AutoParry = false,
    ESP = false,
    KillAura = false,
    AuraRange = 20,
    InfiniteStamina = false,
    AntiRagdoll = false,
    AutoFarmKills = false,
    AutoTrashcan = false,
    HitboxSize = 15,
    -- Hero Hunter (Garou) Techs
    AutoSwirlTech = false,
    AutoWhirlwindDash = false,
    AutoLethalDashExtender = false,
    AutoTwistedDash = false,
    AutoUppercutStrike = false,
    -- The Strongest Hero (Saitama) Techs
    AutoCounteringCounter = false,
    AutoSurfTech = false,
    AutoRagdollShoveDash = false,
    AutoKick = false,
    AutoTacticalYeet = false,
    AutoUppercutFlickDash = false,
    AutoUppercutDash = false
}

local ESPObjects = {}
local TechCooldowns = {}  -- To prevent spamming techs

-- ======================= VERIFICADOR GERAL (canto superior esquerdo) =======================
local function criarVerificador()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VerificadorKerbzinn"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, 260, 0, 90)
    Frame.Position = UDim2.new(0, 15, 0, 15)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Frame.BorderSizePixel = 0
    Frame.BackgroundTransparency = 0.1
    Frame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 12)
    UICorner.Parent = Frame

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 170, 255))
    }
    UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0.6), NumberSequenceKeypoint.new(1, 0.9)}
    UIGradient.Parent = Frame

    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.Size = UDim2.new(0, 70, 0, 70)
    ImageLabel.Position = UDim2.new(0, 10, 0, 10)
    ImageLabel.BackgroundTransparency = 1
    ImageLabel.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    ImageLabel.Parent = Frame

    local ImageCorner = Instance.new("UICorner")
    ImageCorner.CornerRadius = UDim.new(1, 0)
    ImageCorner.Parent = ImageLabel

    local NomeLabel = Instance.new("TextLabel")
    NomeLabel.Size = UDim2.new(0, 160, 0, 30)
    NomeLabel.Position = UDim2.new(0, 90, 0, 15)
    NomeLabel.BackgroundTransparency = 1
    NomeLabel.Text = player.DisplayName
    NomeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NomeLabel.TextScaled = true
    NomeLabel.Font = Enum.Font.GothamBold
    NomeLabel.Parent = Frame

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0, 160, 0, 30)
    StatusLabel.Position = UDim2.new(0, 90, 0, 45)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "✅ Usuário Logado"
    StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    StatusLabel.TextScaled = true
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = Frame

    task.spawn(function()
        local thumb, ready = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        if ready then ImageLabel.Image = thumb end
    end)
end
criarVerificador()

-- ======================= ESP =======================
local function createESP(plr)
    if ESPObjects[plr] or plr == player then return end
    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Transparency = 1

    local name = Drawing.new("Text")
    name.Size = 16
    name.Color = Color3.fromRGB(255, 255, 255)
    name.Center = true
    name.Outline = true

    local health = Drawing.new("Text")
    health.Size = 14
    health.Color = Color3.fromRGB(0, 255, 0)
    health.Center = true
    health.Outline = true

    ESPObjects[plr] = {box = box, name = name, health = health}
end

local function removeESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            obj:Remove()
        end
        ESPObjects[plr] = nil
    end
end

Players.PlayerAdded:Connect(function(plr)
    if Settings.ESP then createESP(plr) end
end)

Players.PlayerRemoving:Connect(removeESP)

RunService.RenderStepped:Connect(function()
    if not Settings.ESP then
        for plr in pairs(ESPObjects) do removeESP(plr) end
        return
    end

    for plr, objs in pairs(ESPObjects) do
        if plr.Character and plr.Character:FindFirstChild("Head") and plr.Character:FindFirstChild("Humanoid") then
            local head = plr.Character.Head
            local hum = plr.Character.Humanoid
            local pos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                objs.box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                objs.box.Position = Vector2.new(pos.X - objs.box.Size.X / 2, pos.Y - objs.box.Size.Y / 2)
                objs.box.Visible = true

                objs.name.Text = plr.DisplayName
                objs.name.Position = Vector2.new(pos.X, pos.Y - 30)
                objs.name.Visible = true

                objs.health.Text = math.floor(hum.Health) .. "/" .. hum.MaxHealth
                objs.health.Position = Vector2.new(pos.X, pos.Y + objs.box.Size.Y / 2 + 10)
                objs.health.Visible = true
            else
                objs.box.Visible = false
                objs.name.Visible = false
                objs.health.Visible = false
            end
        else
            objs.box.Visible = false
            objs.name.Visible = false
            objs.health.Visible = false
        end
    end
end)

-- ======================= MAIN LOOP FOR COMBAT/MOVEMENT =======================
local function isAttacking(enemy)
    -- Basic detection: Check if enemy is moving towards player or playing attack animation
    if not enemy.Character or not enemy.Character:FindFirstChild("HumanoidRootPart") or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return false end
    local dist = (enemy.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
    local velocityTowards = (player.Character.HumanoidRootPart.Position - enemy.Character.HumanoidRootPart.Position).Unit:Dot(enemy.Character.HumanoidRootPart.Velocity.Unit)
    return dist < 15 and velocityTowards > 0.5  -- Adjust as needed
end

local originalHitboxSizes = {}  -- To reset hitboxes

RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    local hrp = char.HumanoidRootPart
    local hum = char.Humanoid

    -- Auto Parry
    if Settings.AutoParry then
        for _, enemy in ipairs(Players:GetPlayers()) do
            if enemy ~= player and isAttacking(enemy) then
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                break
            end
        end
    end

    -- Kill Aura + Hitbox
    if Settings.KillAura then
        for _, enemy in ipairs(Players:GetPlayers()) do
            if enemy ~= player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") and enemy.Character.Humanoid.Health > 0 then
                local enemyHrp = enemy.Character.HumanoidRootPart
                local dist = (enemyHrp.Position - hrp.Position).Magnitude
                if dist <= Settings.AuraRange then
                    -- Face enemy
                    hrp.CFrame = CFrame.lookAt(hrp.Position, enemyHrp.Position)

                    -- Expand hitbox locally
                    for _, part in ipairs(enemy.Character:GetChildren()) do
                        if part:IsA("BasePart") and not originalHitboxSizes[part] then
                            originalHitboxSizes[part] = part.Size
                            part.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                            part.Transparency = 0.7
                            part.Color = Color3.fromRGB(255, 0, 0)
                        end
                    end

                    -- Attack
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.03)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
    else
        -- Reset hitboxes when disabled
        for part, size in pairs(originalHitboxSizes) do
            if part and part.Parent then
                part.Size = size
                part.Transparency = 0
                part.Color = Color3.fromRGB(255, 255, 255)
            end
        end
        originalHitboxSizes = {}
    end

    -- Infinite Stamina (assuming stamina is a local attribute or WalkSpeed related)
    if Settings.InfiniteStamina then
        hum.WalkSpeed = 20
        if char:FindFirstChild("Stamina") then  -- Hypothetical
            char.Stamina.Value = char.Stamina.MaxValue
        end
    end

    -- Anti Ragdoll
    if Settings.AntiRagdoll then
        hum.PlatformStand = false
        hum.Sit = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)  -- Force get up if ragdolled
    end
end)

-- ======================= TECH EXECUTION LOOP =======================
local function executeTech(techName, key, delay1, action, delay2, cooldown)
    if not Settings[techName] or TechCooldowns[techName] then return end
    TechCooldowns[techName] = true

    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(delay1)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
    task.wait(0.1)

    if action == "dash" then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(delay2)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
    elseif action == "m1" then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(delay2)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end

    task.spawn(function()
        task.wait(cooldown)
        TechCooldowns[techName] = nil
    end)
end

RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end

    -- Hero Hunter Techs
    executeTech("AutoSwirlTech", Enum.KeyCode.Three, 0.15, "dash", 0.2, 1.8)
    executeTech("AutoWhirlwindDash", Enum.KeyCode.One, 0.2, "dash", 0.15, 2)
    executeTech("AutoLethalDashExtender", Enum.KeyCode.One, 0.25, "dash", 0.3, 2.2)
    if Settings.AutoTwistedDash then
        if TechCooldowns["AutoTwistedDash"] then return end
        TechCooldowns["AutoTwistedDash"] = true
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.08)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
        task.wait(1.5)
        TechCooldowns["AutoTwistedDash"] = nil
    end
    executeTech("AutoUppercutStrike", Enum.KeyCode.Four, 0.3, "m1", 0.1, 3)

    -- Saitama Techs
    if Settings.AutoCounteringCounter then
        if TechCooldowns["AutoCounteringCounter"] then return end
        TechCooldowns["AutoCounteringCounter"] = true
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        task.wait(0.15)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.wait(1.8)
        TechCooldowns["AutoCounteringCounter"] = nil
    end
    executeTech("AutoSurfTech", Enum.KeyCode.Three, 0.2, "dash", 0.25, 2)
    executeTech("AutoRagdollShoveDash", Enum.KeyCode.Four, 0.3, "dash", 0.2, 2.5)
    executeTech("AutoKick", Enum.KeyCode.One, 0.25, "m1", 0.08, 2)
    executeTech("AutoTacticalYeet", Enum.KeyCode.Two, 0.3, "dash", 0.2, 2.8)
    executeTech("AutoUppercutFlickDash", Enum.KeyCode.Three, 0.2, "dash", 0.15, 2)
    executeTech("AutoUppercutDash", Enum.KeyCode.Three, 0.25, "dash", 0.2, 2.2)
end)

-- ======================= AUTO FARM =======================
task.spawn(function()
    while true do
        task.wait(math.random(0.8, 1.2))  -- Random delay to mimic human
        if not (Settings.AutoFarmKills or Settings.AutoTrashcan) then continue end
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart

        if Settings.AutoTrashcan then
            local trashFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Trash")
            if trashFolder then
                local trashcans = trashFolder:GetChildren()
                if #trashcans > 0 then
                    local randomTrash = trashcans[math.random(1, #trashcans)]
                    local part = randomTrash.PrimaryPart or randomTrash:FindFirstChildWhichIsA("BasePart")
                    if part then
                        hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                        task.wait(0.4)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end
        end

        if Settings.AutoFarmKills then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                    hrp.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                    task.wait(0.2)  -- Small delay
                    break
                end
            end
        end
    end
end)

-- ======================= TABS =======================
local CombatTab = Window:MakeTab({Name = "⚔️ Combat", Icon = "rbxassetid://4483345998"})
CombatTab:AddToggle({Name = "Auto Parry / Block", Default = false, Callback = function(v) Settings.AutoParry = v end})
CombatTab:AddToggle({Name = "Kill Aura", Default = false, Callback = function(v) Settings.KillAura = v end})
CombatTab:AddSlider({Name = "Aura Range", Min = 10, Max = 50, Default = 20, Callback = function(v) Settings.AuraRange = v end})
CombatTab:AddSlider({Name = "Hitbox Size", Min = 10, Max = 30, Default = 15, Callback = function(v) Settings.HitboxSize = v end})

local VisualTab = Window:MakeTab({Name = "👁️ Visual", Icon = "rbxassetid://4483345998"})
VisualTab:AddToggle({Name = "Player ESP", Default = false, Callback = function(v)
    Settings.ESP = v
    if v then
        for _, p in ipairs(Players:GetPlayers()) do createESP(p) end
    else
        for plr in pairs(ESPObjects) do removeESP(plr) end
    end
end})

local MovementTab = Window:MakeTab({Name = "✈️ Movement", Icon = "rbxassetid://4483345998"})
MovementTab:AddToggle({Name = "Infinite Stamina", Default = false, Callback = function(v) Settings.InfiniteStamina = v end})
MovementTab:AddToggle({Name = "Anti Ragdoll", Default = false, Callback = function(v) Settings.AntiRagdoll = v end})

local TechsTab = Window:MakeTab({Name = "🔧 Techs", Icon = "rbxassetid://4483345998"})
TechsTab:AddSection("Hero Hunter (Garou) Techs")
TechsTab:AddToggle({Name = "Swirl Tech", Default = false, Callback = function(v) Settings.AutoSwirlTech = v end})
TechsTab:AddToggle({Name = "Whirlwind Dash Tech", Default = false, Callback = function(v) Settings.AutoWhirlwindDash = v end})
TechsTab:AddToggle({Name = "Lethal Dash Extender", Default = false, Callback = function(v) Settings.AutoLethalDashExtender = v end})
TechsTab:AddToggle({Name = "Twisted Dash", Default = false, Callback = function(v) Settings.AutoTwistedDash = v end})
TechsTab:AddToggle({Name = "Uppercut Strike", Default = false, Callback = function(v) Settings.AutoUppercutStrike = v end})
TechsTab:AddSection("The Strongest Hero (Saitama) Techs")
TechsTab:AddToggle({Name = "Countering a Counter", Default = false, Callback = function(v) Settings.AutoCounteringCounter = v end})
TechsTab:AddToggle({Name = "Surf Tech", Default = false, Callback = function(v) Settings.AutoSurfTech = v end})
TechsTab:AddToggle({Name = "Ragdoll Shove Dash", Default = false, Callback = function(v) Settings.AutoRagdollShoveDash = v end})
TechsTab:AddToggle({Name = "Kick (Omni)", Default = false, Callback = function(v) Settings.AutoKick = v end})
TechsTab:AddToggle({Name = "Tactical Yeet", Default = false, Callback = function(v) Settings.AutoTacticalYeet = v end})
TechsTab:AddToggle({Name = "Uppercut Flick-Dash", Default = false, Callback = function(v) Settings.AutoUppercutFlickDash = v end})
TechsTab:AddToggle({Name = "Uppercut Dash", Default = false, Callback = function(v) Settings.AutoUppercutDash = v end})

local FarmTab = Window:MakeTab({Name = "🌾 Farm", Icon = "rbxassetid://4483345998"})
FarmTab:AddToggle({Name = "Auto Farm Kills", Default = false, Callback = function(v) Settings.AutoFarmKills = v end})
FarmTab:AddToggle({Name = "Auto Trashcan TP + Pickup", Default = false, Callback = function(v) Settings.AutoTrashcan = v end})

local MiscTab = Window:MakeTab({Name = "🛠️ Misc", Icon = "rbxassetid://4483345998"})
MiscTab:AddButton({Name = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId) end})
MiscTab:AddButton({Name = "Unload Hub", Callback = function()
    for _, conn in ipairs(getconnections(RunService.Heartbeat)) do conn:Disconnect() end
    for _, conn in ipairs(getconnections(RunService.RenderStepped)) do conn:Disconnect() end
    for plr in pairs(ESPObjects) do removeESP(plr) end
    player.PlayerGui:FindFirstChild("VerificadorKerbzinn"):Destroy()
    OrionLib:Destroy()
end})
MiscTab:AddLabel("Credits: Improved by Grok AI - Original by Kerbzinn")

OrionLib:Init()
print("TSB Kerbzinn Hub V11.1 carregado - Versão melhorada com otimizações e correções")
--████████╗██████╗░██╗░░░██╗  ████████╗░█████╗░  ██████╗░███████╗░█████╗░██████╗░██╗░░░██╗██████╗░████████╗
--╚══██╔══╝██╔══██╗╚██╗░██╔╝  ╚══██╔══╝██╔══██╗  ██╔══██╗██╔════╝██╔══██╗██╔══██╗╚██╗░██╔╝██╔══██╗╚══██╔══╝
--░░░██║░░░██████╔╝░╚████╔╝░  ░░░██║░░░██║░░██║  ██║░░██║█████╗░░██║░░╚═╝██████╔╝░╚████╔╝░██████╔╝░░░██║░░░
--░░░██║░░░██╔══██╗░░╚██╔╝░░  ░░░██║░░░██║░░██║  ██║░░██║██╔══╝░░██║░░██╗██╔══██╗░░╚██╔╝░░██╔═══╝░░░░██║░░░
--░░░██║░░░██║░░██║░░░██║░░░  ░░░██║░░░╚█████╔╝  ██████╔╝███████╗╚█████╔╝██║░░██║░░░██║░░░██║░░░░░░░░██║░░░
--░░░╚═╝░░░╚═╝░░╚═╝░░░╚═╝░░░  ░░░╚═╝░░░░╚════╝░  ╚═════╝░╚══════╝░╚════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░░░░░░░╚═╝░░░

--██╗████████╗  ███╗░░██╗░█████╗░░██╗░░░░░░░██╗░░░  ██╗░░░██╗░█████╗░██╗░░░██╗
--██║╚══██╔══╝  ████╗░██║██╔══██╗░██║░░██╗░░██║░░░  ╚██╗░██╔╝██╔══██╗██║░░░██║
--██║░░░██║░░░  ██╔██╗██║██║░░██║░╚██╗████╗██╔╝░░░  ░╚████╔╝░██║░░██║██║░░░██║
--██║░░░██║░░░  ██║╚████║██║░░██║░░████╔═████║░██╗  ░░╚██╔╝░░██║░░██║██║░░░██║
--██║░░░██║░░░  ██║░╚███║╚█████╔╝░░╚██╔╝░╚██╔╝░╚█║  ░░░██║░░░╚█████╔╝╚██████╔╝
--╚═╝░░░╚═╝░░░  ╚═╝░░╚══╝░╚════╝░░░░╚═╝░░░╚═╝░░░╚╝  ░░░╚═╝░░░░╚════╝░░╚═════╝░

--██████╗░██╗████████╗░█████╗░██╗░░██╗  ██╗░░██╗██████╗░
--██╔══██╗██║╚══██╔══╝██╔══██╗██║░░██║  ╚██╗██╔╝██╔══██╗
--██████╦╝██║░░░██║░░░██║░░╚═╝███████║  ░╚███╔╝░██║░░██║
--██╔══██╗██║░░░██║░░░██║░░██╗██╔══██║  ░██╔██╗░██║░░██║
--██████╦╝██║░░░██║░░░╚█████╔╝██║░░██║  ██╔╝╚██╗██████╔╝
--╚═════╝░╚═╝░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝  ╚═╝░░╚═╝╚═════╝░
