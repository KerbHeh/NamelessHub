--[[
    NamelessHub | TSB Edition - Improved Version
    Author: Just a DOOM
    Version: 2.1
    
    Melhorias:
    - Modularização do código
    - Performance otimizada
    - Melhor gerenciamento de estado
    - Tratamento de erros aprimorado
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

-- ========================================
-- MODULES & UTILITIES
-- ========================================

local Utilities = {}

function Utilities.notify(fluent, title, content, duration)
    fluent:Notify({
        Title = title,
        Content = content,
        Duration = duration or 3
    })
end

function Utilities.getCharacter(player)
    if not player then return nil end

    local character = player.Character
    if not character then return nil end

    local hrp = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not humanoid or humanoid.Health <= 0 then 
        return nil 
    end

    return character, hrp, humanoid
end

function Utilities.getRootPosition(player)
    local _, root = Utilities.getCharacter(player)
    return root and root.Position or nil
end

function Utilities.getDistanceToLocal(player, localPlayer)
    if player == localPlayer then return math.huge end

    local localPos = Utilities.getRootPosition(localPlayer)
    local targetPos = Utilities.getRootPosition(player)
    
    if not localPos or not targetPos then return math.huge end

    return (localPos - targetPos).Magnitude
end

function Utilities.getPlayerHealth(player)
    local _, _, humanoid = Utilities.getCharacter(player)
    return humanoid and humanoid.Health or math.huge
end

-- ========================================
-- TARGET SYSTEM
-- ========================================

local TargetSystem = {}
TargetSystem.__index = TargetSystem

function TargetSystem.new(localPlayer)
    local self = setmetatable({}, TargetSystem)
    self.localPlayer = localPlayer
    self.selectedTarget = nil
    self.highlight = nil
    return self
end

function TargetSystem:findTarget(mode)
    local candidates = {}
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= self.localPlayer and Utilities.getCharacter(player) then
            table.insert(candidates, player)
        end
    end

    if #candidates == 0 then return nil end

    table.sort(candidates, function(a, b)
        if mode == "Vida Mais Baixa" then
            local aHealth = Utilities.getPlayerHealth(a)
            local bHealth = Utilities.getPlayerHealth(b)
            if aHealth == bHealth then
                return Utilities.getDistanceToLocal(a, self.localPlayer) < 
                       Utilities.getDistanceToLocal(b, self.localPlayer)
            end
            return aHealth < bHealth
        end

        return Utilities.getDistanceToLocal(a, self.localPlayer) < 
               Utilities.getDistanceToLocal(b, self.localPlayer)
    end)

    return candidates[1]
end

function TargetSystem:setTarget(player)
    self.selectedTarget = player

    if self.highlight then
        self.highlight:Destroy()
        self.highlight = nil
    end

    if player then
        local targetCharacter = Utilities.getCharacter(player)
        if targetCharacter then
            local highlight = Instance.new("Highlight")
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.FillColor = Color3.fromRGB(255, 170, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.Parent = targetCharacter
            self.highlight = highlight
        end
    end
end

function TargetSystem:getTarget()
    return self.selectedTarget
end

function TargetSystem:clearTarget()
    self:setTarget(nil)
end

-- ========================================
-- COMBAT SYSTEM
-- ========================================

local CombatSystem = {}
CombatSystem.__index = CombatSystem

function CombatSystem.new(localPlayer)
    local self = setmetatable({}, CombatSystem)
    self.localPlayer = localPlayer
    return self
end

function CombatSystem:teleportNear(player, offset)
    local localCharacter, localRoot = Utilities.getCharacter(self.localPlayer)
    local _, targetRoot = Utilities.getCharacter(player)
    
    if not localCharacter or not localRoot or not targetRoot then 
        return false 
    end

    localRoot.CFrame = targetRoot.CFrame * CFrame.new(offset or Vector3.new(0, 0, -3))
    return true
end

function CombatSystem:clickAttack()
    local character = self.localPlayer.Character
    local tool = character and character:FindFirstChildOfClass("Tool")
    
    if tool and tool:FindFirstChild("Handle") then
        tool:Activate()
        return true
    end

    -- Fallback to virtual input
    local success = pcall(function()
        local virtualInput = game:GetService("VirtualInputManager")
        virtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(0.05)
        virtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
    
    return success
end

function CombatSystem:sideDashTo(player)
    local _, targetRoot = Utilities.getCharacter(player)
    local localCharacter, localRoot = Utilities.getCharacter(self.localPlayer)
    
    if not targetRoot or not localRoot or not localCharacter then
        return false
    end

    local rightSide = targetRoot.CFrame.RightVector * 4
    localRoot.CFrame = CFrame.new(targetRoot.Position + rightSide, targetRoot.Position)
    self:clickAttack()
    return true
end

-- ========================================
-- LOOP MANAGER
-- ========================================

local LoopManager = {}
LoopManager.__index = LoopManager

function LoopManager.new()
    local self = setmetatable({}, LoopManager)
    self.loops = {}
    return self
end

function LoopManager:stop(name)
    if self.loops[name] then
        self.loops[name] = false
    end
end

function LoopManager:start(name, callback, delay)
    self:stop(name)
    self.loops[name] = true

    task.spawn(function()
        while self.loops[name] do
            local success, err = pcall(callback)
            if not success then
                warn(string.format("[%s] Error: %s", name, tostring(err)))
            end
            task.wait(delay or 0.1)
        end
    end)
end

function LoopManager:isRunning(name)
    return self.loops[name] == true
end

function LoopManager:stopAll()
    for name in pairs(self.loops) do
        self:stop(name)
    end
end

-- ========================================
-- ESP SYSTEM
-- ========================================

local ESPSystem = {}
ESPSystem.__index = ESPSystem

function ESPSystem.new(localPlayer)
    local self = setmetatable({}, ESPSystem)
    self.localPlayer = localPlayer
    self.espData = {}
    self.options = {
        playerESP = false,
        healthESP = false,
        tracerESP = false
    }
    return self
end

function ESPSystem:createBillboard(name, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = name
    billboard.Size = UDim2.new(0, 150, 0, 35)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true

    local text = Instance.new("TextLabel")
    text.BackgroundTransparency = 1
    text.Size = UDim2.fromScale(1, 1)
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.TextColor3 = color
    text.TextStrokeTransparency = 0
    text.Parent = billboard

    return billboard, text
end

function ESPSystem:clearForPlayer(player)
    local data = self.espData[player]
    if not data then return end

    for _, object in pairs(data) do
        if typeof(object) == "Instance" and object.Parent then
            object:Destroy()
        end
    end

    self.espData[player] = nil
end

function ESPSystem:updateForPlayer(player)
    local character, root, humanoid = Utilities.getCharacter(player)
    
    if not character or not root or not humanoid then
        self:clearForPlayer(player)
        return
    end

    self.espData[player] = self.espData[player] or {}
    local data = self.espData[player]

    -- Player Name + Distance ESP
    if self.options.playerESP then
        if not data.playerLabel then
            local bb, text = self:createBillboard("TSB_PlayerESP", Color3.fromRGB(255, 255, 255))
            bb.Parent = root
            data.playerLabel = bb
            data.playerLabelText = text
        end

        local distance = Utilities.getDistanceToLocal(player, self.localPlayer)
        data.playerLabelText.Text = string.format("%s | %dm", player.Name, math.floor(distance))
    elseif data.playerLabel then
        data.playerLabel:Destroy()
        data.playerLabel = nil
        data.playerLabelText = nil
    end

    -- Health ESP
    if self.options.healthESP then
        if not data.healthLabel then
            local bb, text = self:createBillboard("TSB_HealthESP", Color3.fromRGB(0, 255, 127))
            bb.StudsOffset = Vector3.new(0, 2.4, 0)
            bb.Parent = root
            data.healthLabel = bb
            data.healthLabelText = text
        end

        data.healthLabelText.Text = string.format("HP: %d", math.floor(humanoid.Health))
    elseif data.healthLabel then
        data.healthLabel:Destroy()
        data.healthLabel = nil
        data.healthLabelText = nil
    end

    -- Tracer ESP
    if self.options.tracerESP then
        if not data.tracer then
            local tracer = Instance.new("Beam")
            local localAttachment = Instance.new("Attachment")
            local targetAttachment = Instance.new("Attachment")

            local localCharacter, localHrp = Utilities.getCharacter(self.localPlayer)
            if localHrp then
                localAttachment.Parent = localHrp
                targetAttachment.Parent = root
                tracer.Attachment0 = localAttachment
                tracer.Attachment1 = targetAttachment
                tracer.Width0 = 0.08
                tracer.Width1 = 0.08
                tracer.FaceCamera = true
                tracer.Color = ColorSequence.new(Color3.fromRGB(255, 65, 65))
                tracer.Parent = localHrp
                data.tracer = tracer
                data.tracerA0 = localAttachment
                data.tracerA1 = targetAttachment
            end
        end
    elseif data.tracer then
        data.tracer:Destroy()
        data.tracerA0:Destroy()
        data.tracerA1:Destroy()
        data.tracer = nil
        data.tracerA0 = nil
        data.tracerA1 = nil
    end
end

function ESPSystem:setOption(option, value)
    if self.options[option] ~= nil then
        self.options[option] = value
    end
end

function ESPSystem:refresh()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= self.localPlayer then
            self:updateForPlayer(player)
        end
    end

    -- Clean up disconnected players
    for player in pairs(self.espData) do
        if not player.Parent then
            self:clearForPlayer(player)
        end
    end
end

-- ========================================
-- MAIN SCRIPT
-- ========================================

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Initialize Systems
local targetSystem = TargetSystem.new(LocalPlayer)
local combatSystem = CombatSystem.new(LocalPlayer)
local loopManager = LoopManager.new()
local espSystem = ESPSystem.new(LocalPlayer)

-- Create Window
local Window = Fluent:CreateWindow({
    Title = "NamelessHub | TSB Edition v2.1",
    SubTitle = "by Just a DOOM - Improved",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    About = Window:AddTab({ Title = "About", Icon = "info" }),
    Farm = Window:AddTab({ Title = "Farm", Icon = "tractor" }),
    Techs = Window:AddTab({ Title = "Techs", Icon = "zap" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Troll = Window:AddTab({ Title = "Troll", Icon = "laugh" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ========================================
-- ABOUT TAB
-- ========================================

Tabs.About:AddParagraph({
    Title = "TSB Script - Improved Version",
    Content = "Versão: 2.1\n" ..
              "Melhorias: Código modular, performance otimizada\n" ..
              "Adaptado para The Strongest Battlegrounds\n" ..
              "Foco em farm, techs e ESP"
})

Tabs.About:AddButton({
    Title = "Discord Community",
    Description = "Junte-se ao nosso servidor",
    Callback = function()
        Utilities.notify(Fluent, "Discord", "Link: discord.gg/seu_server_aqui", 8)
    end
})

-- ========================================
-- FARM TAB
-- ========================================

Tabs.Farm:AddSection("Configurações de Visibilidade")

Tabs.Farm:AddToggle("TrashInvisible", { 
    Title = "Invisível no Trash Farm", 
    Default = false 
}):OnChanged(function(value)
    local character = LocalPlayer.Character
    if not character then return end

    for _, obj in ipairs(character:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
            obj.LocalTransparencyModifier = value and 0.6 or 0
        end
    end
end)

Tabs.Farm:AddSection("Trash Farm")

Tabs.Farm:AddDropdown("TrashTarget", {
    Title = "Modo de Alvo",
    Values = { "Mais Próximo", "Vida Mais Baixa" },
    Default = "Mais Próximo",
    Multi = false
})

Tabs.Farm:AddToggle("TrashFarm", { 
    Title = "Auto Trash Can Farm", 
    Description = "Farm automático com teleporte rápido",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("TrashFarm", function()
            local target = targetSystem:findTarget(Options.TrashTarget.Value)
            if target and combatSystem:teleportNear(target, Vector3.new(0, 0, -2)) then
                combatSystem:clickAttack()
            end
        end, 0.12)
    else
        loopManager:stop("TrashFarm")
    end
end)

Tabs.Farm:AddSection("Farm Padrão")

Tabs.Farm:AddDropdown("StandardTarget", {
    Title = "Modo de Alvo",
    Values = { "Mais Próximo", "Vida Mais Baixa" },
    Default = "Mais Próximo",
    Multi = false
})

Tabs.Farm:AddToggle("StandardFarm", { 
    Title = "Auto Farm Padrão",
    Description = "Farm mais seguro e estável", 
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("StandardFarm", function()
            local target = targetSystem:findTarget(Options.StandardTarget.Value)
            if target and combatSystem:teleportNear(target, Vector3.new(0, 0, -3.5)) then
                combatSystem:clickAttack()
            end
        end, 0.15)
    else
        loopManager:stop("StandardFarm")
    end
end)

-- ========================================
-- TECHS TAB
-- ========================================

Tabs.Techs:AddParagraph({
    Title = "Sistema de Seleção de Alvo",
    Content = "Use as keybinds para selecionar alvos e executar techs manualmente"
})

Tabs.Techs:AddKeybind("SelectKey", {
    Title = "Selecionar Alvo Mais Próximo",
    Mode = "Hold",
    Default = "R",
    Callback = function(value)
        if value then
            local target = targetSystem:findTarget("Mais Próximo")
            targetSystem:setTarget(target)
            if target then
                Utilities.notify(Fluent, "Techs", "Alvo: " .. target.Name, 2)
            else
                Utilities.notify(Fluent, "Techs", "Nenhum alvo disponível", 2)
            end
        end
    end
})

Tabs.Techs:AddKeybind("SideDashKey", {
    Title = "Side Dash no Alvo",
    Mode = "Hold",
    Default = "E",
    Callback = function(value)
        if value then
            local target = targetSystem:getTarget()
            if target then
                if combatSystem:sideDashTo(target) then
                    Utilities.notify(Fluent, "Techs", "Side Dash executado!", 2)
                else
                    Utilities.notify(Fluent, "Techs", "Alvo inválido", 2)
                end
            else
                Utilities.notify(Fluent, "Techs", "Nenhum alvo selecionado", 2)
            end
        end
    end
})

Tabs.Techs:AddButton({
    Title = "Limpar Seleção de Alvo",
    Description = "Remove o highlight do alvo atual",
    Callback = function()
        targetSystem:clearTarget()
        Utilities.notify(Fluent, "Techs", "Alvo desmarcado", 2)
    end
})

Tabs.Techs:AddSection("Combos Automáticos")

-- Kyoto Combo
Tabs.Techs:AddToggle("AutoKyoto", { 
    Title = "Auto Kyoto Combo",
    Description = "Combo duplo rápido",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("AutoKyoto", function()
            local target = targetSystem:findTarget("Mais Próximo")
            if target and combatSystem:teleportNear(target, Vector3.new(0, 0, -2.5)) then
                combatSystem:clickAttack()
                task.wait(0.2)
                combatSystem:clickAttack()
            end
        end, 0.35)
    else
        loopManager:stop("AutoKyoto")
    end
end)

-- Uppercut Dash
Tabs.Techs:AddToggle("AutoUppercutDash", { 
    Title = "Auto Uppercut → Dash",
    Description = "Uppercut com dash aéreo",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("AutoUppercutDash", function()
            local target = targetSystem:findTarget("Mais Próximo")
            if target and combatSystem:teleportNear(target, Vector3.new(0, 2, -1.2)) then
                combatSystem:clickAttack()
            end
        end, 0.28)
    else
        loopManager:stop("AutoUppercutDash")
    end
end)

-- Mini Uppercut
Tabs.Techs:AddToggle("AutoMiniUppercut", { 
    Title = "Auto Mini Uppercut",
    Description = "Uppercut curto e rápido",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("AutoMiniUppercut", function()
            local target = targetSystem:findTarget("Mais Próximo")
            if target and combatSystem:teleportNear(target, Vector3.new(0, 1.2, -1)) then
                combatSystem:clickAttack()
            end
        end, 0.24)
    else
        loopManager:stop("AutoMiniUppercut")
    end
end)

-- Consecutive Punches
Tabs.Techs:AddToggle("AutoConsecutive", { 
    Title = "Auto Consecutive Punches",
    Description = "Sequência rápida de socos",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("AutoConsecutive", function()
            local target = targetSystem:findTarget("Mais Próximo")
            if target and combatSystem:teleportNear(target, Vector3.new(0, 0, -2)) then
                combatSystem:clickAttack()
                task.wait(0.06)
                combatSystem:clickAttack()
            end
        end, 0.25)
    else
        loopManager:stop("AutoConsecutive")
    end
end)

-- Death Counter
Tabs.Techs:AddToggle("AutoDeathCounter", { 
    Title = "Auto Death Counter",
    Description = "Counter automático quando vida baixa",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("AutoDeathCounter", function()
            local _, _, humanoid = Utilities.getCharacter(LocalPlayer)
            if humanoid and humanoid.Health < humanoid.MaxHealth * 0.3 then
                combatSystem:clickAttack()
            end
        end, 0.2)
    else
        loopManager:stop("AutoDeathCounter")
    end
end)

-- Death Blow
Tabs.Techs:AddToggle("AutoDeathBlow", { 
    Title = "Auto Death Blow",
    Description = "Foca no alvo com menos vida",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("AutoDeathBlow", function()
            local target = targetSystem:findTarget("Vida Mais Baixa")
            if target and combatSystem:teleportNear(target, Vector3.new(0, 0, -1.8)) then
                combatSystem:clickAttack()
                task.wait(0.1)
                combatSystem:clickAttack()
            end
        end, 0.35)
    else
        loopManager:stop("AutoDeathBlow")
    end
end)

-- Table Flip
Tabs.Techs:AddToggle("AutoTableFlip", { 
    Title = "Auto Table Flip",
    Description = "Tech de baixo ângulo",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("AutoTableFlip", function()
            local target = targetSystem:findTarget("Mais Próximo")
            if target and combatSystem:teleportNear(target, Vector3.new(0, -1.5, -1)) then
                combatSystem:clickAttack()
            end
        end, 0.45)
    else
        loopManager:stop("AutoTableFlip")
    end
end)

-- Hunter's Grasp
Tabs.Techs:AddToggle("AutoHuntersGrasp", { 
    Title = "Auto Hunter's Grasp",
    Description = "Grab tech próximo",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("AutoHuntersGrasp", function()
            local target = targetSystem:findTarget("Mais Próximo")
            if target and combatSystem:teleportNear(target, Vector3.new(0, 0, -0.8)) then
                combatSystem:clickAttack()
            end
        end, 0.32)
    else
        loopManager:stop("AutoHuntersGrasp")
    end
end)

-- Evade Tech
Tabs.Techs:AddToggle("AutoEvadeTech", { 
    Title = "Auto Evade + Counter",
    Description = "Counter durante movimento",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("AutoEvadeTech", function()
            local _, _, humanoid = Utilities.getCharacter(LocalPlayer)
            if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
                combatSystem:clickAttack()
            end
        end, 0.22)
    else
        loopManager:stop("AutoEvadeTech")
    end
end)

-- Grand Slam
Tabs.Techs:AddToggle("AutoGrandSlam", { 
    Title = "Auto Grand Slam",
    Description = "Ataque aéreo poderoso",
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("AutoGrandSlam", function()
            local target = targetSystem:findTarget("Mais Próximo")
            if target and combatSystem:teleportNear(target, Vector3.new(0, 3, -1.5)) then
                combatSystem:clickAttack()
            end
        end, 0.4)
    else
        loopManager:stop("AutoGrandSlam")
    end
end)

-- ========================================
-- ESP TAB
-- ========================================

Tabs.ESP:AddSection("Configurações de ESP")

Tabs.ESP:AddToggle("PlayerESP", { 
    Title = "Player ESP",
    Description = "Mostra nome e distância", 
    Default = false 
}):OnChanged(function(value)
    espSystem:setOption("playerESP", value)
end)

Tabs.ESP:AddToggle("HealthESP", { 
    Title = "Health ESP",
    Description = "Mostra HP dos jogadores", 
    Default = false 
}):OnChanged(function(value)
    espSystem:setOption("healthESP", value)
end)

Tabs.ESP:AddToggle("TracerESP", { 
    Title = "Tracers",
    Description = "Linhas até os jogadores", 
    Default = false 
}):OnChanged(function(value)
    espSystem:setOption("tracerESP", value)
end)

Tabs.ESP:AddButton({
    Title = "Limpar Todo ESP",
    Description = "Remove todos os elementos de ESP",
    Callback = function()
        for _, player in ipairs(Players:GetPlayers()) do
            espSystem:clearForPlayer(player)
        end
        Utilities.notify(Fluent, "ESP", "ESP limpo", 2)
    end
})

-- ESP Update Loop
RunService.RenderStepped:Connect(function()
    espSystem:refresh()
end)

-- ========================================
-- TROLL TAB
-- ========================================

Tabs.Troll:AddSection("Features de Troll")

local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
chatRemote = chatRemote and chatRemote:FindFirstChild("SayMessageRequest") or nil

Tabs.Troll:AddToggle("ServerLag", { 
    Title = "Efeito Visual de Lag",
    Description = "Cria partículas visuais (apenas local)", 
    Default = false 
}):OnChanged(function(value)
    if value then
        loopManager:start("ServerLag", function()
            local folder = workspace:FindFirstChild("TSB_LocalFx") or Instance.new("Folder", workspace)
            folder.Name = "TSB_LocalFx"
            
            for i = 1, 8 do
                local part = Instance.new("Part")
                part.Size = Vector3.new(0.4, 0.4, 0.4)
                part.Anchored = true
                part.CanCollide = false
                part.Material = Enum.Material.Neon
                part.Color = Color3.fromRGB(255, 0, 0)
                
                local localPos = Utilities.getRootPosition(LocalPlayer) or Vector3.zero
                part.Position = localPos + Vector3.new(
                    math.random(-4, 4), 
                    math.random(1, 5), 
                    math.random(-4, 4)
                )
                part.Parent = folder
                game:GetService("Debris"):AddItem(part, 1)
            end
        end, 0.5)
    else
        loopManager:stop("ServerLag")
    end
end)

Tabs.Troll:AddInput("CounterMsg", {
    Title = "Mensagem de Counter",
    Default = "Countered kkk",
    Placeholder = "Sua mensagem aqui",
    Description = "Mensagem enviada ao ver counter"
})

Tabs.Troll:AddToggle("AutoSayCounter", { 
    Title = "Auto Chat no Counter",
    Description = "Envia mensagem quando alguém fica próximo", 
    Default = false 
}):OnChanged(function(value)
    if value then
        if not chatRemote then
            Utilities.notify(Fluent, "Erro", "Remote de chat não encontrado", 3)
            Options.AutoSayCounter:SetValue(false)
            return
        end

        loopManager:start("AutoSayCounter", function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and Utilities.getDistanceToLocal(player, LocalPlayer) < 10 then
                    chatRemote:FireServer(Options.CounterMsg.Value or "Countered kkk", "All")
                    break
                end
            end
        end, 2.2)
    else
        loopManager:stop("AutoSayCounter")
    end
end)

Tabs.Troll:AddButton({
    Title = "Spam Chat",
    Description = "Envia 20 mensagens no chat",
    Callback = function()
        if not chatRemote then
            Utilities.notify(Fluent, "Erro", "Remote de chat não encontrado", 3)
            return
        end

        task.spawn(function()
            for i = 1, 20 do
                chatRemote:FireServer("TSB Script on top!", "All")
                task.wait(0.5)
            end
        end)
        
        Utilities.notify(Fluent, "Chat", "Spam iniciado", 2)
    end
})

-- ========================================
-- CLEANUP & EVENTS
-- ========================================

Players.PlayerRemoving:Connect(function(player)
    espSystem:clearForPlayer(player)
    if targetSystem:getTarget() == player then
        targetSystem:clearTarget()
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Options.TrashInvisible and Options.TrashInvisible.Value then
        for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
                obj.LocalTransparencyModifier = 0.6
            end
        end
    end
end)

-- ========================================
-- SAVE SYSTEM
-- ========================================

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

InterfaceManager:SetFolder("NamelessHub")
SaveManager:SetFolder("NamelessHub/TSB")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

-- ========================================
-- INITIALIZATION
-- ========================================

Utilities.notify(Fluent, "NamelessHub", "Script v2.1 carregado com sucesso!", 5)
print("[TSB Script] Versão 2.1 inicializada")
print("[TSB Script] Sistemas: TargetSystem, CombatSystem, LoopManager, ESPSystem")
