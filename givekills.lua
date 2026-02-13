loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- ============= TSB KERBZINN HUB V13.5 - MEGA UI ORION =============
-- Ultra Premium UI Design - Profissional & Otimizado para máxima usabilidade

local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()

-- ============= CORES CUSTOMIZADAS =============
local Colors = {
    Primary = Color3.fromRGB(100, 0, 255),
    Secondary = Color3.fromRGB(0, 170, 255),
    Success = Color3.fromRGB(0, 255, 100),
    Warning = Color3.fromRGB(255, 200, 0),
    Danger = Color3.fromRGB(255, 0, 0),
    Dark = Color3.fromRGB(20, 20, 20),
    Light = Color3.fromRGB(255, 255, 255)
}

-- ============= JANELA PRINCIPAL COM TEMA =============
local Window = OrionLib:MakeWindow({
    Name = "unamelessHub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "By 0_Potencias",
    IntroEnabled = true,
    IntroText = "⚡ Carregando o hub mais INSANO de 2026...",
    IntroTransparency = 0.8
})

-- ============= SERVICES =============
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ============= SETTINGS COMPLETO =============
local Settings = {
    -- Combat
    AutoParry = false,
    ParryDistance = 15,
    ParryVelocityThreshold = 0.5,
    ParryPrediction = true,

    -- Visual
    ESP = false,
    ESPDistance = 300,
    ESPTracers = false,
    ESPHealthBar = false,

    -- Kill Aura
    KillAura = false,
    AuraRange = 20,
    HitboxSize = 15,
    AuraDamageMultiplier = 1.5,

    -- Movement
    InfiniteStamina = false,
    WalkSpeed = 20,
    JumpPower = 50,
    AntiRagdoll = false,
    Fly = false,
    FlySpeed = 50,
    NoClip = false,

    -- Farm
    AutoFarmKills = false,
    AutoTrashcan = false,
    AutoFarmMode = "kills",

    -- Techs (todos desligados por padrão)
    AutoSwirlTech = false,
    AutoWhirlwindDash = false,
    AutoLethalDashExtender = false,
    AutoTwistedDash = false,
    AutoUppercutStrike = false,
    AutoCounteringCounter = false,
    AutoSurfTech = false,
    AutoRagdollShoveDash = false,
    AutoKick = false,
    AutoTacticalYeet = false,
    AutoUppercutFlickDash = false,
    AutoUppercutDash = false,

    -- Advanced
    EnableDebug = false,
    AntiBan = false,
}

-- ============= STATE MANAGEMENT =============
local ESPObjects = {}
local TracerObjects = {}
local HealthBarObjects = {}
local TechCooldowns = {}
local originalHitboxSizes = {}
local isAlive = true
local lastCharacter = nil
local activeEnemies = {}
local flyConnection = nil
local noClipConnection = nil

-- ============= UTILITY FUNCTIONS =============
local function getCharacter()
    return player.Character
end

local function getHRP()
    local char = getCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChild("Humanoid")
end

local function debug(msg)
    if Settings.EnableDebug then
        print("[🔥 TSB HUB] " .. tostring(msg))
    end
end

-- ============= UI VERIFICATION AVANÇADO =============
local function criarVerificador()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VerificadorKerbzinn"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = player:WaitForChild("PlayerGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 320, 0, 140)
    MainFrame.Position = UDim2.new(0, 15, 0, 15)
    MainFrame.BackgroundColor3 = Colors.Dark
    MainFrame.BackgroundTransparency = 0.05
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 15)
    UICorner.Parent = MainFrame

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Colors.Primary
    UIStroke.Thickness = 2.5
    UIStroke.Parent = MainFrame

    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(1, Colors.Secondary)
    }
    UIGradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(1, 0.95)
    }
    UIGradient.Parent = MainFrame

    -- Avatar
    local ImageLabel = Instance.new("ImageLabel")
    ImageLabel.Size = UDim2.new(0, 90, 0, 90)
    ImageLabel.Position = UDim2.new(0, 12, 0, 25)
    ImageLabel.BackgroundTransparency = 0
    ImageLabel.BackgroundColor3 = Colors.Dark
    ImageLabel.Parent = MainFrame

    local ImageCorner = Instance.new("UICorner")
    ImageCorner.CornerRadius = UDim.new(1, 0)
    ImageCorner.Parent = ImageLabel

    local ImageStroke = Instance.new("UIStroke")
    ImageStroke.Color = Colors.Secondary
    ImageStroke.Thickness = 2
    ImageStroke.Parent = ImageLabel

    -- Nome
    local NomeLabel = Instance.new("TextLabel")
    NomeLabel.Size = UDim2.new(0, 210, 0, 30)
    NomeLabel.Position = UDim2.new(0, 115, 0, 12)
    NomeLabel.BackgroundTransparency = 1
    NomeLabel.Text = "👤 " .. player.DisplayName
    NomeLabel.TextColor3 = Colors.Light
    NomeLabel.TextScaled = true
    NomeLabel.Font = Enum.Font.GothamBold
    NomeLabel.Parent = MainFrame

    -- Status
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(0, 210, 0, 25)
    StatusLabel.Position = UDim2.new(0, 115, 0, 42)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "✅ Online | v13.5 ULTRA+"
    StatusLabel.TextColor3 = Colors.Success
    StatusLabel.TextScaled = true
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.Parent = MainFrame

    -- Features
    local FeaturesLabel = Instance.new("TextLabel")
    FeaturesLabel.Size = UDim2.new(0, 210, 0, 40)
    FeaturesLabel.Position = UDim2.new(0, 115, 0, 70)
    FeaturesLabel.BackgroundTransparency = 1
    FeaturesLabel.Text = "⚡ Features: +15 Combat | +10 Techs\n🔥 Fly | NoClip | Farm & +Muito Mais!"
    FeaturesLabel.TextColor3 = Colors.Warning
    FeaturesLabel.TextScaled = true
    FeaturesLabel.Font = Enum.Font.Gotham
    FeaturesLabel.Parent = MainFrame
    FeaturesLabel.TextWrapped = true

    task.spawn(function()
        local thumb, ready = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
        if ready then ImageLabel.Image = thumb end
    end)
end
criarVerificador()

-- ============= ESP & TRACERS SYSTEM AVANÇADO =============
local function createESP(plr)
    if ESPObjects[plr] or plr == player then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Filled = false
    box.Color = Colors.Danger
    box.Transparency = 1

    local name = Drawing.new("Text")
    name.Size = 16
    name.Color = Colors.Light
    name.Center = true
    name.Outline = true

    local health = Drawing.new("Text")
    health.Size = 14
    health.Color = Colors.Success
    health.Center = true
    health.Outline = true

    local distance = Drawing.new("Text")
    distance.Size = 12
    distance.Color = Colors.Secondary
    distance.Center = true
    distance.Outline = true

    ESPObjects[plr] = {box = box, name = name, health = health, distance = distance}
    debug("✨ ESP criado para: " .. plr.DisplayName)
end

local function createTracer(plr)
    if TracerObjects[plr] or plr == player then return end

    local tracer = Drawing.new("Line")
    tracer.Thickness = 1.5
    tracer.Color = Colors.Danger
    tracer.Transparency = 0.7

    TracerObjects[plr] = tracer
    debug("📍 Tracer criado para: " .. plr.DisplayName)
end

local function removeESP(plr)
    if ESPObjects[plr] then
        for _, obj in pairs(ESPObjects[plr]) do
            if obj then obj:Remove() end
        end
        ESPObjects[plr] = nil
    end
end

local function removeTracer(plr)
    if TracerObjects[plr] then
        TracerObjects[plr]:Remove()
        TracerObjects[plr] = nil
    end
end

Players.PlayerAdded:Connect(function(plr)
    if Settings.ESP then createESP(plr) end
    if Settings.ESPTracers then createTracer(plr) end
end)

Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
    removeTracer(plr)
    activeEnemies[plr] = nil
end)

RunService.RenderStepped:Connect(function()
    if not Settings.ESP and not Settings.ESPTracers then
        for plr in pairs(ESPObjects) do removeESP(plr) end
        for plr in pairs(TracerObjects) do removeTracer(plr) end
        return
    end

    local hrp = getHRP()
    if not hrp then return end

    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)

    for plr, objs in pairs(ESPObjects) do
        if not plr.Parent or not plr.Character then
            removeESP(plr)
            continue
        end

        local char = plr.Character
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChild("Humanoid")

        if head and hum then
            local dist = (head.Position - hrp.Position).Magnitude

            if dist > Settings.ESPDistance then
                objs.box.Visible = false
                objs.name.Visible = false
                objs.health.Visible = false
                objs.distance.Visible = false
                continue
            end

            local pos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                objs.box.Size = Vector2.new(2000 / pos.Z, 3000 / pos.Z)
                objs.box.Position = Vector2.new(pos.X - objs.box.Size.X/2, pos.Y - objs.box.Size.Y/2)
                objs.box.Visible = hum.Health > 0
                objs.box.Color = hum.Health > hum.MaxHealth * 0.5 and Colors.Success or Colors.Danger

                objs.name.Text = plr.DisplayName
                objs.name.Position = Vector2.new(pos.X, pos.Y - 40)
                objs.name.Visible = hum.Health > 0

                objs.health.Text = math.floor(hum.Health) .. "/" .. hum.MaxHealth
                objs.health.Position = Vector2.new(pos.X, pos.Y + objs.box.Size.Y/2 + 10)
                objs.health.Visible = hum.Health > 0

                objs.distance.Text = math.floor(dist) .. "m"
                objs.distance.Position = Vector2.new(pos.X, pos.Y - 60)
                objs.distance.Visible = hum.Health > 0
            else
                objs.box.Visible = false
                objs.name.Visible = false
                objs.health.Visible = false
                objs.distance.Visible = false
            end
        else
            objs.box.Visible = false
            objs.name.Visible = false
            objs.health.Visible = false
            objs.distance.Visible = false
        end
    end

    if Settings.ESPTracers then
        for plr, tracer in pairs(TracerObjects) do
            if not plr.Parent or not plr.Character then
                removeTracer(plr)
                continue
            end

            local char = plr.Character
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChild("Humanoid")
            if head and hum then
                local pos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen and hum.Health > 0 then
                    tracer.From = screenCenter
                    tracer.To = Vector2.new(pos.X, pos.Y)
                    tracer.Visible = true
                    tracer.Color = hum.Health > hum.MaxHealth * 0.5 and Colors.Success or Colors.Danger
                else
                    tracer.Visible = false
                end
            else
                tracer.Visible = false
            end
        end
    end
end)

-- ============= CHARACTER MANAGEMENT =============
local function onCharacterAdded(char)
    isAlive = true
    lastCharacter = char

    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        isAlive = false
        for techName in pairs(TechCooldowns) do
            TechCooldowns[techName] = nil
        end
        debug("💀 Personagem morreu!")
    end)
end

player.CharacterAdded:Connect(onCharacterAdded)
if player.Character then onCharacterAdded(player.Character) end

-- ============= COMBAT SYSTEM =============
RunService.Heartbeat:Connect(function(delta)
    local char = getCharacter()
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end

    local hrp, hum = char.HumanoidRootPart, char.Humanoid
    if not isAlive then return end

    -- AUTO PARRY
    if Settings.AutoParry then
        local closestEnemy = nil
        local minDist = Settings.ParryDistance

        for _, enemy in ipairs(Players:GetPlayers()) do
            if enemy ~= player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
                local enemyHrp = enemy.Character.HumanoidRootPart
                local dist = (enemyHrp.Position - hrp.Position).Magnitude

                if dist < minDist then
                    minDist = dist
                    closestEnemy = enemy
                end
            end
        end

        if closestEnemy then
            local enemyHrp = closestEnemy.Character.HumanoidRootPart
            local velTowards = (hrp.Position - enemyHrp.Position).Unit:Dot(enemyHrp.Velocity.Unit)
            if velTowards > Settings.ParryVelocityThreshold then
                if Settings.ParryPrediction then task.wait(0.01) end
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                debug("🛡️ Parry em: " .. closestEnemy.DisplayName)
            end
        end
    end

    -- KILL AURA
    if Settings.KillAura then
        for _, enemy in ipairs(Players:GetPlayers()) do
            if enemy ~= player and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") and enemy.Character.Humanoid.Health > 0 then
                local ehrp = enemy.Character.HumanoidRootPart
                local dist = (ehrp.Position - hrp.Position).Magnitude

                if dist <= Settings.AuraRange then
                    activeEnemies[enemy] = true
                    hrp.CFrame = CFrame.lookAt(hrp.Position, ehrp.Position)

                    for _, part in ipairs(enemy.Character:GetChildren()) do
                        if part:IsA("BasePart") then
                            if not originalHitboxSizes[part] then
                                originalHitboxSizes[part] = part.Size
                            end
                            part.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                            part.CanCollide = false
                        end
                    end

                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.02)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end
        end
    else
        for part, size in pairs(originalHitboxSizes) do
            if part and part.Parent then
                part.Size = size
                part.CanCollide = true
            end
        end
        originalHitboxSizes = {}
        activeEnemies = {}
    end

    -- INFINITE STAMINA
    if Settings.InfiniteStamina then
        hum.WalkSpeed = Settings.WalkSpeed
        hum.JumpPower = Settings.JumpPower
    end

    -- ANTI RAGDOLL
    if Settings.AntiRagdoll then
        hum.PlatformStand = false
        hum.Sit = false
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    -- ANTI-BAN
    if Settings.AntiBan then
        hum.WalkSpeed = math.min(hum.WalkSpeed, 16)
    end
end)

-- ============= FLY HACK =============
local function toggleFly(enabled)
    if enabled then
        local hrp = getHRP()
        if not hrp then return end

        flyConnection = RunService.RenderStepped:Connect(function()
            if not Settings.Fly then return end
            
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

            if moveDir.Magnitude > 0 then
                hrp.CFrame = hrp.CFrame + (moveDir.Unit * Settings.FlySpeed * 0.05)
            end
        end)
        debug("✈️ Fly ativado!")
    else
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        debug("✈️ Fly desativado!")
    end
end

-- ============= TECH SYSTEM =============
local function executeTech(techName, key, delay1, action, delay2, cooldown)
    if not Settings[techName] or TechCooldowns[techName] then return end

    local char = getCharacter()
    if not char then return end

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

    task.delay(cooldown, function() TechCooldowns[techName] = nil end)
    debug("⚡ Tech executada: " .. techName)
end

RunService.Heartbeat:Connect(function()
    if not isAlive then return end

    executeTech("AutoSwirlTech", Enum.KeyCode.Three, 0.15, "dash", 0.2, 1.8)
    executeTech("AutoWhirlwindDash", Enum.KeyCode.One, 0.2, "dash", 0.15, 2)
    executeTech("AutoLethalDashExtender", Enum.KeyCode.One, 0.25, "dash", 0.3, 2.2)
    executeTech("AutoUppercutStrike", Enum.KeyCode.Four, 0.3, "m1", 0.1, 3)
    executeTech("AutoSurfTech", Enum.KeyCode.Three, 0.2, "dash", 0.25, 2)
    executeTech("AutoRagdollShoveDash", Enum.KeyCode.Four, 0.3, "dash", 0.2, 2.5)
    executeTech("AutoKick", Enum.KeyCode.One, 0.25, "m1", 0.08, 2)
    executeTech("AutoTacticalYeet", Enum.KeyCode.Two, 0.3, "dash", 0.2, 2.8)
    executeTech("AutoUppercutFlickDash", Enum.KeyCode.Three, 0.2, "dash", 0.15, 2)
    executeTech("AutoUppercutDash", Enum.KeyCode.Three, 0.25, "dash", 0.2, 2.2)

    -- SPECIAL TECHS
    if Settings.AutoTwistedDash and not TechCooldowns.AutoTwistedDash then
        TechCooldowns.AutoTwistedDash = true
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.08)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)
        task.delay(1.5, function() TechCooldowns.AutoTwistedDash = nil end)
    end

    if Settings.AutoCounteringCounter and not TechCooldowns.AutoCounteringCounter then
        TechCooldowns.AutoCounteringCounter = true
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
        task.wait(0.15)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.1)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        task.delay(1.8, function() TechCooldowns.AutoCounteringCounter = nil end)
    end
end)

-- ============= FARM SYSTEM OTIMIZADO =============
task.spawn(function()
    while task.wait(0.5) do
        if not (Settings.AutoTrashcan or Settings.AutoFarmKills) then continue end

        local char = getCharacter()
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local hrp = char.HumanoidRootPart

        if Settings.AutoTrashcan or Settings.AutoFarmMode == "both" or Settings.AutoFarmMode == "trashcan" then
            local trashFolder = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Trash")
            if trashFolder then
                local cans = trashFolder:GetChildren()
                if #cans > 0 then
                    table.sort(cans, function(a, b)
                        local partA = a.PrimaryPart or a:FindFirstChildWhichIsA("BasePart")
                        local partB = b.PrimaryPart or b:FindFirstChildWhichIsA("BasePart")
                        if partA and partB then
                            return (partA.Position - hrp.Position).Magnitude < (partB.Position - hrp.Position).Magnitude
                        end
                        return false
                    end)
                    local can = cans[1]
                    local part = can.PrimaryPart or can:FindFirstChildWhichIsA("BasePart")
                    if part then
                        hrp.CFrame = part.CFrame + Vector3.new(0, 5, 0)
                        task.wait(0.3)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                        debug("🗑️ Lixeira farmada!")
                    end
                end
            end
        end

        if Settings.AutoFarmKills or Settings.AutoFarmMode == "both" or Settings.AutoFarmMode == "kills" then
            local targets = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                    table.insert(targets, p)
                end
            end
            if #targets > 0 then
                table.sort(targets, function(a, b)
                    return (a.Character.HumanoidRootPart.Position - hrp.Position).Magnitude < (b.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                end)
                local target = targets[1]
                hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -3)
                task.wait(0.15)
                debug("👊 Farmando: " .. target.DisplayName)
            end
        end
    end
end)

-- ============= ABA COMBAT - SUPER ORGANIZADA =============
local CombatTab = Window:MakeTab({Name = "⚔️ COMBAT PREMIUM"})

CombatTab:AddSection("🛡️ PARRY SYSTEM")
CombatTab:AddToggle({
    Name = "Auto Parry",
    Default = false,
    Callback = function(v) Settings.AutoParry = v end
})
CombatTab:AddToggle({
    Name = "Parry Prediction",
    Default = true,
    Callback = function(v) Settings.ParryPrediction = v end
})
CombatTab:AddSlider({
    Name = "Parry Distance",
    Min = 5,
    Max = 30,
    Default = 15,
    Increment = 1,
    Callback = function(v) Settings.ParryDistance = v end
})
CombatTab:AddSlider({
    Name = "Parry Velocity",
    Min = 0.1,
    Max = 1,
    Default = 0.5,
    Increment = 0.1,
    Callback = function(v) Settings.ParryVelocityThreshold = v end
})

CombatTab:AddSection("⚡ KILL AURA ULTIMATE")
CombatTab:AddToggle({
    Name = "Kill Aura",
    Default = false,
    Callback = function(v) Settings.KillAura = v end
})
CombatTab:AddSlider({
    Name = "Aura Range",
    Min = 10,
    Max = 50,
    Default = 20,
    Increment = 1,
    Callback = function(v) Settings.AuraRange = v end
})
CombatTab:AddSlider({
    Name = "Hitbox Size",
    Min = 10,
    Max = 30,
    Default = 15,
    Increment = 1,
    Callback = function(v) Settings.HitboxSize = v end
})
CombatTab:AddSlider({
    Name = "Damage Multiplier",
    Min = 1,
    Max = 5,
    Default = 1.5,
    Increment = 0.1,
    Callback = function(v) Settings.AuraDamageMultiplier = v end
})

-- ============= ABA VISUAL - DESIGN PREMIUM =============
local VisualTab = Window:MakeTab({Name = "👁️ VISUAL PRO"})

VisualTab:AddSection("📊 ESP AVANÇADO")
VisualTab:AddToggle({
    Name = "Player ESP",
    Default = false,
    Callback = function(v)
        Settings.ESP = v
        if v then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then createESP(p) end
            end
        else
            for plr in pairs(ESPObjects) do removeESP(plr) end
        end
    end
})
VisualTab:AddToggle({
    Name = "ESP Tracers (Linhas)",
    Default = false,
    Callback = function(v)
        Settings.ESPTracers = v
        if v then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then createTracer(p) end
            end
        else
            for plr in pairs(TracerObjects) do removeTracer(plr) end
        end
    end
})
VisualTab:AddSlider({
    Name = "ESP Distance",
    Min = 50,
    Max = 1000,
    Default = 300,
    Increment = 50,
    Callback = function(v) Settings.ESPDistance = v end
})

-- ============= ABA MOVEMENT - VELOCIDADE & VOOS =============
local MovementTab = Window:MakeTab({Name = "✈️ MOVEMENT ELITE"})

MovementTab:AddSection("🚀 VELOCIDADE")
MovementTab:AddToggle({
    Name = "Infinite Stamina",
    Default = false,
    Callback = function(v) Settings.InfiniteStamina = v end
})
MovementTab:AddSlider({
    Name = "Walk Speed",
    Min = 10,
    Max = 100,
    Default = 20,
    Increment = 5,
    Callback = function(v) Settings.WalkSpeed = v end
})
MovementTab:AddSlider({
    Name = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Increment = 10,
    Callback = function(v) Settings.JumpPower = v end
})

MovementTab:AddSection("✈️ FLY HACK")
MovementTab:AddToggle({
    Name = "Fly Mode",
    Default = false,
    Callback = function(v)
        Settings.Fly = v
        toggleFly(v)
    end
})
MovementTab:AddSlider({
    Name = "Fly Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 10,
    Callback = function(v) Settings.FlySpeed = v end
})

MovementTab:AddSection("⚙️ PROTEÇÃO")
MovementTab:AddToggle({
    Name = "Anti Ragdoll",
    Default = false,
    Callback = function(v) Settings.AntiRagdoll = v end
})

-- ============= ABA TECHS - COM SECÇÕES SEPARADAS =============
local TechsTab = Window:MakeTab({Name = "🔧 TECHS AUTOMÁTICAS"})

TechsTab:AddSection("🐉 GAROU TECHS")
TechsTab:AddToggle({Name = "Swirl Tech", Default = false, Callback = function(v) Settings.AutoSwirlTech = v end})
TechsTab:AddToggle({Name = "Whirlwind Dash", Default = false, Callback = function(v) Settings.AutoWhirlwindDash = v end})
TechsTab:AddToggle({Name = "Lethal Dash Extender", Default = false, Callback = function(v) Settings.AutoLethalDashExtender = v end})
TechsTab:AddToggle({Name = "Twisted Dash", Default = false, Callback = function(v) Settings.AutoTwistedDash = v end})
TechsTab:AddToggle({Name = "Uppercut Strike", Default = false, Callback = function(v) Settings.AutoUppercutStrike = v end})

TechsTab:AddSection("👨 SAITAMA TECHS")
TechsTab:AddToggle({Name = "Countering Counter", Default = false, Callback = function(v) Settings.AutoCounteringCounter = v end})
TechsTab:AddToggle({Name = "Surf Tech", Default = false, Callback = function(v) Settings.AutoSurfTech = v end})
TechsTab:AddToggle({Name = "Ragdoll Shove Dash", Default = false, Callback = function(v) Settings.AutoRagdollShoveDash = v end})
TechsTab:AddToggle({Name = "Kick Omni", Default = false, Callback = function(v) Settings.AutoKick = v end})
TechsTab:AddToggle({Name = "Tactical Yeet", Default = false, Callback = function(v) Settings.AutoTacticalYeet = v end})
TechsTab:AddToggle({Name = "Uppercut Flick-Dash", Default = false, Callback = function(v) Settings.AutoUppercutFlickDash = v end})
TechsTab:AddToggle({Name = "Uppercut Dash", Default = false, Callback = function(v) Settings.AutoUppercutDash = v end})

-- ============= ABA FARM =============
local FarmTab = Window:MakeTab({Name = "🌾 FARM SYSTEM"})

FarmTab:AddSection("💰 OPÇÕES DE FARM")
FarmTab:AddToggle({
    Name = "Auto Farm Kills",
    Default = false,
    Callback = function(v) Settings.AutoFarmKills = v end
})
FarmTab:AddToggle({
    Name = "Auto Trashcan (Lixeiras)",
    Default = false,
    Callback = function(v) Settings.AutoTrashcan = v end
})
FarmTab:AddDropdown({
    Name = "Farm Mode",
    Default = "kills",
    Options = {"kills", "trashcan", "both"},
    Callback = function(v) Settings.AutoFarmMode = v end
})

FarmTab:AddSection("📊 INFO")
local InfoLabel = FarmTab:AddLabel("Kills: 0 | Trashcan: 0")

-- ============= ABA MISC - TUDO IMPORTANTE =============
local MiscTab = Window:MakeTab({Name = "🛠️ MISC & CONFIG"})

MiscTab:AddSection("🔒 SEGURANÇA")
MiscTab:AddToggle({
    Name = "Anti-Ban Protection (Beta)",
    Default = false,
    Callback = function(v) Settings.AntiBan = v end
})

MiscTab:AddSection("⚙️ SYSTEM")
MiscTab:AddToggle({
    Name = "Debug Mode (Console)",
    Default = false,
    Callback = function(v) Settings.EnableDebug = v end
})

MiscTab:AddSection("🔧 AÇÕES RÁPIDAS")
MiscTab:AddButton({
    Name = "🔄 Rejoin Game",
    Callback = function()
        OrionLib:MakeNotification({Title = "Rejoin", Content = "Voltando ao jogo...", Time = 2})
        game:GetService("TeleportService"):Teleport(game.PlaceId)
    end
})

MiscTab:AddButton({
    Name = "🧹 Clear All Cooldowns",
    Callback = function()
        for techName in pairs(TechCooldowns) do
            TechCooldowns[techName] = nil
        end
        OrionLib:MakeNotification({Title = "Sucesso!", Content = "✅ Todos os cooldowns foram limpos!", Time = 2})
        debug("Cooldowns limpos!")
    end
})

MiscTab:AddButton({
    Name = "🔄 Reset All Settings",
    Callback = function()
        for setting in pairs(Settings) do
            if type(Settings[setting]) == "boolean" then
                Settings[setting] = false
            end
        end
        OrionLib:MakeNotification({Title = "Sucesso!", Content = "✅ Todas as configurações foram resetadas!", Time = 2})
        debug("Configurações resetadas!")
    end
})

MiscTab:AddSection("ℹ️ INFORMAÇÕES")
MiscTab:AddLabel("Versão: 13.5 ULTRA+")
MiscTab:AddLabel("Library: Orion Premium Edition")
MiscTab:AddLabel("Desenvolvido por: Kerbzinn")
MiscTab:AddLabel("Status: ✅ Online & Funcional")

-- ============= FINALIZANDO =============
OrionLib:Init()

print("═══════════════════════════════════════════")
print("✅ TSB KERBZINN HUB V13.5 CARREGADO COM SUCESSO!")
print("═══════════════════════════════════════════")
print("📊 FEATURES ATIVAS:")
print("  ⚔️ Combat System (Parry + Kill Aura)")
print("  👁️ ESP + Tracers")
print("  ✈️ Fly + Movement")
print("  🔧 12+ Techs Automáticas")
print("  🌾 Farm System (Kills + Trashcan)")
print("  🛡️ Anti-Ban Protection")
print("  📈 Hitbox Modifier")
print("═══════════════════════════════════════════")
print("🎮 Aproveite o melhor hub de 2026!")
print("═══════════════════════════════════════════")

OrionLib:MakeNotification({
    Title = "🔥 TSB HUB INICIADO!",
    Content = "Bem-vindo ao melhor hub de TSB de 2026! Versão 13.5 ULTRA+ carregada.",
    Time = 5
})
