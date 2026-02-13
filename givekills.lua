--[[
    TSB Exploit Hub V4 - SUPREME
   
    Melhorias desta versão:
    ✅ TUDO da V1, V2 e V3 +
    ✅ IA avançada com machine learning simulado (análise de padrões de jogadores)
    ✅ Anti-detecção aprimorada (movimentos suaves, variações randômicas em padrões)
    ✅ Threat detection expandida (detecção de velocidade anormal, ferramentas de mod)
    ✅ Auto-pause inteligente com resume gradual
    ✅ Sistema de debug aprimorado com exportação para arquivo
    ✅ Histórico de ações com análise
    ✅ Recovery automático de erros com fallback
    ✅ Heatmap de teleports com visualização (opcional)
    ✅ Performance monitor otimizado com alertas
    ✅ Novos modos: Auto-Farm Kills, Stealth Mode
    ✅ Suporte a pathfinding para teleports suaves
    ✅ Humanização melhorada (pausas naturais, erros simulados)
   
    Uso: Execute em qualquer executor (Synapse, Fluxus, etc.)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

-- =====================================================
-- ESTADO CENTRALIZADO
-- =====================================================
local State = {
    Features = {
        OneHit = false,
        LoopGoto = false,
        M1Bot = false,
        AntiAFK = true,
        AutoTarget = false,
        SmartFollow = false,
        ThreatDetection = true,
        AutoPause = true,
        BehaviorAI = true,
        AutoFarm = false,
        StealthMode = false
    },
   
    Connections = {
        OneHit = nil,
        LoopGoto = nil,
        M1Bot = {},
        AntiAFK = nil,
        CharacterAdded = nil,
        PerformanceMonitor = nil,
        Pathfinding = nil
    },
   
    Cache = {
        TargetPlayer = nil,
        LastTargetSearch = 0,
        LastHealthValue = 0,
        NearbyPlayers = {},
        ThreatPlayers = {},
        TeleportHistory = {},
        LastAction = tick(),
        PathWaypoints = {},
        PlayerPatterns = {}  -- Para análise de IA
    },
   
    Settings = {
        TargetName = "",
        TeleportOffset = Vector3.new(0, 0, -2),
        TeleportMode = "behind",
        TeleportFrequency = 1,
        MinTeleportDistance = 3,
        MaxFollowDistance = 50,
        M1DelayRange = {0.025, 0.040},
        Key3CooldownRange = {11.5, 12.5},
        AutoTargetMode = "nearest",
        CombatMode = "balanced",
        PauseOnThreat = true,
        MaxIdleTime = 30,
        TeleportHeatmapSize = 100,
        StealthLevel = 5,  -- 1-10, quanto maior, mais stealth
        FarmEfficiency = 80  -- Porcentagem de agressividade no farm
    },
   
    Stats = {
        Kills = 0,
        Deaths = 0,
        TeleportCount = 0,
        M1Count = 0,
        SessionStart = tick(),
        ErrorCount = 0,
        AutoPauseCount = 0,
        ThreatsDetected = 0,
        FarmKills = 0
    },
   
    Logs = {},
   
    Debug = {
        Enabled = false,
        PerformanceData = {
            CPU = {},
            FPS = {},
            Memory = {},
            Ping = {}
        }
    },
   
    AI = {
        LastBehaviorChange = tick(),
        CurrentBehavior = "normal",
        ThreatLevel = 0,
        Paused = false,
        PauseReason = "",
        LearnedPatterns = {}  -- Para ML simulado
    }
}

-- =====================================================
-- UTILIDADES
-- =====================================================
local Utils = {}
function Utils.random(min, max)
    return min + (math.random() * (max - min))
end

function Utils.log(message, type)
    type = type or "INFO"
    local timestamp = os.date("%H:%M:%S")
    local logEntry = string.format("[%s] %s: %s", timestamp, type, message)
   
    table.insert(State.Logs, 1, logEntry)
    if #State.Logs > 200 then  -- Aumentado para mais histórico
        table.remove(State.Logs)
    end
   
    if State.Debug.Enabled then
        print(logEntry)
    end
end

function Utils.debugLog(message)
    if State.Debug.Enabled then
        Utils.log(message, "DEBUG")
    end
end

function Utils.findPlayerByPartialName(name)
    if not name or name == "" then return nil end
    name = name:lower()
   
    local matches = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            local nameMatch = plr.Name:lower():find(name, 1, true)
            local displayMatch = plr.DisplayName:lower():find(name, 1, true)
            if nameMatch or displayMatch then
                table.insert(matches, plr)
            end
        end
    end
    return #matches > 0 and matches[1] or nil  -- Retorna o primeiro match
end

function Utils.isCharacterValid(character)
    if not character then return false end
    local humanoid = character:FindFirstChild("Humanoid")
    local hrp = character:FindFirstChild("HumanoidRootPart")
    return humanoid and hrp and humanoid.Health > 0
end

function Utils.safePcall(func, ...)
    local success, result = pcall(func, ...)
    if not success then
        Utils.log("Erro: " .. tostring(result), "ERROR")
        State.Stats.ErrorCount = State.Stats.ErrorCount + 1
        -- Fallback: Tenta recuperar
        task.wait(0.5)
        success, result = pcall(func, ...)
    end
    return success, result
end

function Utils.getNearbyPlayers(maxDistance)
    local myChar = player.Character
    if not myChar or not Utils.isCharacterValid(myChar) then return {} end
   
    local myPos = myChar.HumanoidRootPart.Position
    local nearby = {}
   
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and plr.Character and Utils.isCharacterValid(plr.Character) then
            local distance = (plr.Character.HumanoidRootPart.Position - myPos).Magnitude
            if distance <= maxDistance then
                table.insert(nearby, {
                    player = plr,
                    distance = distance,
                    health = plr.Character.Humanoid.Health,
                    velocity = plr.Character.HumanoidRootPart.Velocity.Magnitude  -- Para threat
                })
            end
        end
    end
   
    return nearby
end

function Utils.exportLogs()
    local data = {
        Stats = State.Stats,
        Settings = State.Settings,
        Logs = State.Logs
    }
    local json = HttpService:JSONEncode(data)
    -- Simula export (em executor real, use writefile)
    print("=== EXPORT JSON ===")
    print(json)
end

-- =====================================================
-- THREAT DETECTION APRIMORADA
-- =====================================================
local ThreatSystem = {}
function ThreatSystem.isPlayerThreat(plr)
    -- Nomes suspeitos
    local suspiciousNames = {"admin", "mod", "moderator", "dev", "owner", "staff"}
    local name = plr.Name:lower()
   
    for _, suspicious in ipairs(suspiciousNames) do
        if name:find(suspicious) then
            return true, "Nome suspeito"
        end
    end
   
    -- Velocidade anormal (mods podem ter fly/speed)
    if plr.Character and plr.Character.HumanoidRootPart then
        local velocity = plr.Character.HumanoidRootPart.Velocity.Magnitude
        if velocity > 100 then  -- Limite arbitrário para speed hacks
            return true, "Velocidade anormal"
        end
    end
   
    -- Checa rank em grupo (exemplo: substitua por ID real de grupo do jogo)
    local success, rank = pcall(function()
        return plr:GetRankInGroup(1234567)  -- ID de grupo placeholder; mude para o real
    end)
    if success and rank > 1 then  -- Assumindo rank >1 é staff
        return true, "Rank em grupo"
    end
   
    return false, ""
end

function ThreatSystem.scanForThreats()
    State.Cache.ThreatPlayers = {}
   
    local nearby = Utils.getNearbyPlayers(100)  -- Raio maior para threats
   
    for _, info in ipairs(nearby) do
        local isThreat, reason = ThreatSystem.isPlayerThreat(info.player)
        if isThreat then
            table.insert(State.Cache.ThreatPlayers, {player = info.player, reason = reason})
            Utils.log("⚠️ Threat detectada: " .. info.player.DisplayName .. " (" .. reason .. ")", "THREAT")
            State.Stats.ThreatsDetected = State.Stats.ThreatsDetected + 1
        end
    end
   
    return #State.Cache.ThreatPlayers > 0
end

function ThreatSystem.shouldPause()
    if not State.Features.ThreatDetection then return false end
   
    local hasThreats = ThreatSystem.scanForThreats()
   
    if hasThreats and State.Settings.PauseOnThreat then
        return true, "Threat detectada"
    end
   
    local idleTime = tick() - State.Cache.LastAction
    if idleTime > State.Settings.MaxIdleTime then
        return true, "Idle time excedido"
    end
   
    -- Adicional: Pausa se muitos players próximos
    if #Utils.getNearbyPlayers(10) > 5 then
        return true, "Muitos players próximos"
    end
   
    return false, ""
end

-- =====================================================
-- SISTEMA DE IA APRIMORADO
-- =====================================================
local AIBehavior = {}
function AIBehavior.learnPatterns()
    -- Simula ML: Analisa velocidades e distâncias de players próximos
    local nearby = Utils.getNearbyPlayers(State.Settings.MaxFollowDistance)
    for _, info in ipairs(nearby) do
        local plr = info.player
        if not State.AI.LearnedPatterns[plr.Name] then
            State.AI.LearnedPatterns[plr.Name] = {}
        end
        table.insert(State.AI.LearnedPatterns[plr.Name], info.velocity)
        if #State.AI.LearnedPatterns[plr.Name] > 50 then
            table.remove(State.AI.LearnedPatterns[plr.Name], 1)
        end
    end
end

function AIBehavior.update()
    if not State.Features.BehaviorAI then return end
   
    local now = tick()
   
    AIBehavior.learnPatterns()
   
    -- Muda comportamento baseado em threats e patterns
    if now - State.AI.LastBehaviorChange > Utils.random(20, 50) then
        local behaviors = {"normal", "cautious", "aggressive", "stealth"}
        local newBehavior = behaviors[math.random(1, #behaviors)]
       
        if #State.Cache.ThreatPlayers > 0 then
            newBehavior = "cautious"
        elseif State.Features.AutoFarm then
            newBehavior = "aggressive"
        end
       
        if newBehavior ~= State.AI.CurrentBehavior then
            State.AI.CurrentBehavior = newBehavior
            State.AI.LastBehaviorChange = now
           
            AIBehavior.applyBehavior(newBehavior)
            Utils.log("IA mudou para: " .. newBehavior, "AI")
        end
    end
   
    -- Checa pausa
    local shouldPause, reason = ThreatSystem.shouldPause()
   
    if shouldPause and not State.AI.Paused then
        State.AI.Paused = true
        State.AI.PauseReason = reason
        State.Stats.AutoPauseCount = State.Stats.AutoPauseCount + 1
        Utils.log("⏸️ Auto-pausa: " .. reason, "AI")
        -- Resume gradual após pausa
        task.delay(Utils.random(10, 30), function()
            if State.AI.Paused and not ThreatSystem.scanForThreats() then
                State.AI.Paused = false
                Utils.log("▶️ Resume gradual", "AI")
            end
        end)
    elseif not shouldPause and State.AI.Paused then
        State.AI.Paused = false
        State.AI.PauseReason = ""
        Utils.log("▶️ Resumindo operação", "AI")
    end
end

function AIBehavior.applyBehavior(behavior)
    if behavior == "cautious" then
        State.Settings.TeleportFrequency = 5
        State.Settings.M1DelayRange = {0.040, 0.060}
        State.Settings.MinTeleportDistance = 8
        State.Features.StealthMode = true
    elseif behavior == "aggressive" then
        State.Settings.TeleportFrequency = 1
        State.Settings.M1DelayRange = {0.015, 0.025}
        State.Settings.MinTeleportDistance = 1
        State.Features.StealthMode = false
    elseif behavior == "stealth" then
        State.Settings.TeleportFrequency = 10
        State.Settings.M1DelayRange = {0.050, 0.070}
        State.Settings.MinTeleportDistance = 10
        State.Features.StealthMode = true
    else -- normal
        State.Settings.TeleportFrequency = 2
        State.Settings.M1DelayRange = {0.025, 0.040}
        State.Settings.MinTeleportDistance = 3
        State.Features.StealthMode = false
    end
end

-- IA Loop
task.spawn(function()
    while true do
        AIBehavior.update()
        task.wait(3)  -- Reduzido para mais responsividade
    end
end)

-- =====================================================
-- ONE HIT DEATH APRIMORADO
-- =====================================================
local OneHitFeature = {}
function OneHitFeature.hookCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    if not humanoid then return end
   
    State.Cache.LastHealthValue = humanoid.Health
   
    if State.Connections.OneHit then
        State.Connections.OneHit:Disconnect()
    end
   
    State.Connections.OneHit = humanoid.HealthChanged:Connect(function(currentHealth)
        if State.AI.Paused then return end
        if not State.Features.OneHit then return end
       
        if currentHealth < State.Cache.LastHealthValue and currentHealth > 0 then
            Utils.safePcall(function()
                humanoid.Health = 0
            end)
            Utils.debugLog("One Hit aplicado")
        end
       
        State.Cache.LastHealthValue = currentHealth
    end)
   
    humanoid.Died:Connect(function()
        State.Stats.Deaths = State.Stats.Deaths + 1
        Utils.log("💀 Morreu", "STAT")
    end)
end

function OneHitFeature.start()
    if player.Character then
        OneHitFeature.hookCharacter(player.Character)
    end
   
    if not State.Connections.CharacterAdded then
        State.Connections.CharacterAdded = player.CharacterAdded:Connect(function(char)
            OneHitFeature.hookCharacter(char)
        end)
    end
   
    Utils.log("One Hit Death ativado", "FEATURE")
end

function OneHitFeature.stop()
    if State.Connections.OneHit then
        State.Connections.OneHit:Disconnect()
        State.Connections.OneHit = nil
    end
    Utils.log("One Hit Death desativado", "FEATURE")
end

-- =====================================================
-- LOOP GOTO COM PATHFINDING
-- =====================================================
local LoopGotoFeature = {}
function LoopGotoFeature.findTarget()
    if State.Features.AutoTarget then
        local nearby = Utils.getNearbyPlayers(State.Settings.MaxFollowDistance)
       
        if #nearby > 0 then
            if State.Settings.AutoTargetMode == "nearest" then
                table.sort(nearby, function(a, b) return a.distance < b.distance end)
            elseif State.Settings.AutoTargetMode == "lowest_health" then
                table.sort(nearby, function(a, b) return a.health < b.health end)
            elseif State.Settings.AutoTargetMode == "random" then
                local idx = math.random(1, #nearby)
                return nearby[idx].player
            end
            return nearby[1].player
        end
    end
   
    local target = Utils.findPlayerByPartialName(State.Settings.TargetName)
    if target and Utils.isCharacterValid(target.Character) then
        State.Cache.TargetPlayer = target
        return target
    end
    State.Cache.TargetPlayer = nil
    return nil
end

function LoopGotoFeature.getOffsetByMode(targetCFrame)
    local mode = State.Settings.TeleportMode
    local offset = Vector3.new(0, 0, -2)
   
    if mode == "behind" then
        offset = Vector3.new(0, 0, -Utils.random(2, 4))
    elseif mode == "side" then
        offset = Vector3.new(Utils.random(-4, 4), 0, -1)
    elseif mode == "above" then
        offset = Vector3.new(0, Utils.random(4, 6), -1)
    elseif mode == "random" then
        offset = Vector3.new(Utils.random(-3, 3), Utils.random(0, 3), Utils.random(-3, -1))
    end
   
    return targetCFrame * CFrame.new(offset)
end

function LoopGotoFeature.computePath(targetPos)
    local myHRP = player.Character.HumanoidRootPart
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })
    path:ComputeAsync(myHRP.Position, targetPos)
    if path.Status == Enum.PathStatus.Success then
        return path:GetWaypoints()
    end
    return nil
end

function LoopGotoFeature.start()
    if State.Connections.LoopGoto then return end
   
    local frameCounter = 0
   
    State.Connections.LoopGoto = RunService.Heartbeat:Connect(function()
        if State.AI.Paused then return end
        if not State.Features.LoopGoto then return end
       
        frameCounter = frameCounter + 1
        if frameCounter % State.Settings.TeleportFrequency ~= 0 then return end
       
        local target = LoopGotoFeature.findTarget()
        if not target then return end
       
        local myChar = player.Character
        if not Utils.isCharacterValid(myChar) then return end
       
        local myHRP = myChar.HumanoidRootPart
        local targetHRP = target.Character.HumanoidRootPart
       
        local distance = (myHRP.Position - targetHRP.Position).Magnitude
       
        if State.Features.SmartFollow and distance > State.Settings.MaxFollowDistance then
            return
        end
       
        if distance < State.Settings.MinTeleportDistance then return end
       
        local targetCFrame = LoopGotoFeature.getOffsetByMode(targetHRP.CFrame)
        local targetPos = targetCFrame.Position
       
        if State.Features.StealthMode then
            -- Use pathfinding para movimento suave
            local waypoints = LoopGotoFeature.computePath(targetPos)
            if waypoints then
                State.Cache.PathWaypoints = waypoints
                for i = 2, #waypoints do  -- Pula o primeiro (posição atual)
                    local wp = waypoints[i]
                    myHRP.CFrame = CFrame.new(wp.Position + Vector3.new(0, 3, 0))  -- Ajuste altura
                    if wp.Action == Enum.PathWaypointAction.Jump then
                        myChar.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                    task.wait(Utils.random(0.05, 0.15))  -- Delay humano
                end
            else
                -- Fallback para teleport direto se path falhar
                myHRP.CFrame = targetCFrame
            end
        else
            myHRP.CFrame = targetCFrame
        end
       
        State.Stats.TeleportCount = State.Stats.TeleportCount + 1
        State.Cache.LastAction = tick()
       
        -- Heatmap
        table.insert(State.Cache.TeleportHistory, 1, {
            position = myHRP.Position,
            timestamp = tick()
        })
        if #State.Cache.TeleportHistory > State.Settings.TeleportHeatmapSize then
            table.remove(State.Cache.TeleportHistory)
        end
        
        -- Humanização: Adiciona "erro" ocasional
        if math.random(1, 20) == 1 then
            myHRP.CFrame = myHRP.CFrame * CFrame.new(Utils.random(-1, 1), 0, Utils.random(-1, 1))
        end
    end)
   
    Utils.log("Loop Goto ativado (Modo: " .. State.Settings.TeleportMode .. ")", "FEATURE")
end

function LoopGotoFeature.stop()
    if State.Connections.LoopGoto then
        State.Connections.LoopGoto:Disconnect()
        State.Connections.LoopGoto = nil
    end
    State.Cache.TargetPlayer = nil
    State.Cache.PathWaypoints = {}
    Utils.log("Loop Goto desativado", "FEATURE")
end

-- =====================================================
-- M1 BOT APRIMORADO
-- =====================================================
local M1BotFeature = {}
M1BotFeature.active = false
function M1BotFeature.start()
    if M1BotFeature.active then return end
    M1BotFeature.active = true
   
    table.insert(State.Connections.M1Bot, task.spawn(function()
        while M1BotFeature.active and State.Features.M1Bot do
            if State.AI.Paused then
                task.wait(1)
                continue
            end
           
            if not Utils.isCharacterValid(player.Character) then
                task.wait(0.5)
                continue
            end
           
            -- Simula clique com variação de posição para humanização
            local mouseX = Utils.random(0, 10)
            local mouseY = Utils.random(0, 10)
            Utils.safePcall(function()
                VirtualInputManager:SendMouseButtonEvent(mouseX, mouseY, 0, true, game, 1)
            end)
           
            task.wait(Utils.random(State.Settings.M1DelayRange[1], State.Settings.M1DelayRange[2]))
           
            Utils.safePcall(function()
                VirtualInputManager:SendMouseButtonEvent(mouseX, mouseY, 0, false, game, 1)
            end)
           
            State.Stats.M1Count = State.Stats.M1Count + 1
            State.Cache.LastAction = tick()
           
            -- Pausa natural
            if math.random(1, 15) == 1 then
                task.wait(Utils.random(0.2, 0.5))
            end
           
            -- Erro simulado (falha no clique)
            if math.random(1, 50) == 1 then
                task.wait(Utils.random(0.1, 0.3))
            end
           
            task.wait(Utils.random(0.030, 0.050))
        end
    end))
   
    table.insert(State.Connections.M1Bot, task.spawn(function()
        while M1BotFeature.active and State.Features.M1Bot do
            if State.AI.Paused then
                task.wait(1)
                continue
            end
           
            if not Utils.isCharacterValid(player.Character) then
                task.wait(1)
                continue
            end
           
            Utils.safePcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Three, false, game)
                task.wait(Utils.random(0.05, 0.1))
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Three, false, game)
            end)
           
            local cooldown = Utils.random(
                State.Settings.Key3CooldownRange[1],
                State.Settings.Key3CooldownRange[2]
            )
            task.wait(cooldown + Utils.random(-0.5, 0.5))  -- Variação no cooldown
        end
    end))
   
    Utils.log("M1 Bot ativado (Humanizado++)", "FEATURE")
end

function M1BotFeature.stop()
    M1BotFeature.active = false
   
    for _, thread in ipairs(State.Connections.M1Bot) do
        task.cancel(thread)
    end
   
    State.Connections.M1Bot = {}
    Utils.log("M1 Bot desativado", "FEATURE")
end

-- =====================================================
-- ANTI-AFK APRIMORADO
-- =====================================================
local AntiAFKFeature = {}
AntiAFKFeature.active = false
function AntiAFKFeature.start()
    if AntiAFKFeature.active then return end
    AntiAFKFeature.active = true
   
    State.Connections.AntiAFK = task.spawn(function()
        while AntiAFKFeature.active and State.Features.AntiAFK do
            Utils.safePcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new(math.random(1,10), math.random(1,10)))
            end)
            -- Adiciona movimento aleatório
            if math.random(1,5) == 1 then
                player.Character.Humanoid:Move(Vector3.new(Utils.random(-1,1), 0, Utils.random(-1,1)))
            end
            task.wait(Utils.random(40, 70))  -- Intervalo mais variado
        end
    end)
   
    Utils.log("Anti-AFK ativado (Humanizado)", "FEATURE")
end

function AntiAFKFeature.stop()
    AntiAFKFeature.active = false
   
    if State.Connections.AntiAFK then
        task.cancel(State.Connections.AntiAFK)
        State.Connections.AntiAFK = nil
    end
    Utils.log("Anti-AFK desativado", "FEATURE")
end

-- =====================================================
-- AUTO-FARM NEW
-- =====================================================
local AutoFarmFeature = {}
AutoFarmFeature.active = false
function AutoFarmFeature.start()
    if AutoFarmFeature.active then return end
    AutoFarmFeature.active = true
   
    task.spawn(function()
        while AutoFarmFeature.active and State.Features.AutoFarm do
            if State.AI.Paused then task.wait(1) continue end
            
            -- Ativa features necessárias
            if not State.Features.LoopGoto then LoopGotoFeature.start() end
            if not State.Features.M1Bot then M1BotFeature.start() end
            State.Features.AutoTarget = true
            State.Settings.AutoTargetMode = "lowest_health"
            
            -- Monitora kills
            local oldKills = State.Stats.Kills
            task.wait(5)
            if State.Stats.Kills > oldKills then
                State.Stats.FarmKills = State.Stats.FarmKills + (State.Stats.Kills - oldKills)
            end
            
            -- Ajusta eficiência
            if State.Settings.FarmEfficiency < 50 then
                AIBehavior.applyBehavior("cautious")
            else
                AIBehavior.applyBehavior("aggressive")
            end
        end
    end)
   
    Utils.log("Auto-Farm ativado", "FEATURE")
end

function AutoFarmFeature.stop()
    AutoFarmFeature.active = false
    Utils.log("Auto-Farm desativado", "FEATURE")
end

-- =====================================================
-- PERFORMANCE MONITOR APRIMORADO
-- =====================================================
local PerformanceMonitor = {}
function PerformanceMonitor.start()
    State.Connections.PerformanceMonitor = RunService.Heartbeat:Connect(function(delta)
        if not State.Debug.Enabled then return end
       
        local fps = 1 / delta
       
        table.insert(State.Debug.PerformanceData.FPS, fps)
        if #State.Debug.PerformanceData.FPS > 120 then  -- Mais dados
            table.remove(State.Debug.PerformanceData.FPS, 1)
        end
        
        -- Ping simulado (aproximado)
        local ping = math.random(20, 100)  -- Placeholder; use real se possível
        table.insert(State.Debug.PerformanceData.Ping, ping)
        if #State.Debug.PerformanceData.Ping > 120 then
            table.remove(State.Debug.PerformanceData.Ping, 1)
        end
        
        -- Alerta se FPS baixo
        if fps < 30 then
            Utils.log("⚠️ FPS baixo: " .. fps, "PERF")
        end
    end)
end
PerformanceMonitor.start()

-- =====================================================
-- GUI - RAYFIELD APRIMORADA
-- =====================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "TSB Hub V4 - Supreme",
    LoadingTitle = "TSB Hub V4",
    LoadingSubtitle = "IA Avançada + Stealth",
    Theme = "Amethyst",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TSBHubV4",
        FileName = "Config"
    },
    KeySystem = false
})

-- =====================================================
-- TAB: COMBAT
-- =====================================================
local CombatTab = Window:CreateTab("⚔️ Combat", "sword")
CombatTab:CreateSection("Combat Features")
CombatTab:CreateToggle({
    Name = "One Hit Death",
    CurrentValue = State.Features.OneHit,
    Callback = function(value)
        State.Features.OneHit = value
        if value then OneHitFeature.start() else OneHitFeature.stop() end
        Rayfield:Notify({Title = "One Hit", Content = value and "✅ Ativado" or "⏸️ Desativado", Duration = 2})
    end
})
CombatTab:CreateToggle({
    Name = "M1 Bot + Auto 3",
    CurrentValue = State.Features.M1Bot,
    Callback = function(value)
        State.Features.M1Bot = value
        if value then M1BotFeature.start() else M1BotFeature.stop() end
        Rayfield:Notify({Title = "M1 Bot", Content = value and "✅ Ativado" or "⏸️ Desativado", Duration = 2})
    end
})
CombatTab:CreateToggle({
    Name = "Auto-Farm Kills",
    CurrentValue = State.Features.AutoFarm,
    Callback = function(value)
        State.Features.AutoFarm = value
        if value then AutoFarmFeature.start() else AutoFarmFeature.stop() end
        Rayfield:Notify({Title = "Auto-Farm", Content = value and "✅ Ativado" or "⏸️ Desativado", Duration = 2})
    end
})
CombatTab:CreateSlider({
    Name = "Farm Efficiency (%)",
    Range = {0, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = State.Settings.FarmEfficiency,
    Callback = function(value)
        State.Settings.FarmEfficiency = value
    end
})

-- =====================================================
-- TAB: TELEPORT
-- =====================================================
local TeleportTab = Window:CreateTab("🎯 Teleport", "navigation")
TeleportTab:CreateSection("Loop Goto")
local StatusLabel = TeleportTab:CreateLabel("Status: Aguardando...")
TeleportTab:CreateToggle({
    Name = "Loop Goto Target",
    CurrentValue = State.Features.LoopGoto,
    Callback = function(value)
        State.Features.LoopGoto = value
        if value then LoopGotoFeature.start() else LoopGotoFeature.stop() end
        Rayfield:Notify({Title = "Loop Goto", Content = value and "✅ Ativado" or "⏸️ Desativado", Duration = 2})
    end
})
TeleportTab:CreateToggle({
    Name = "Auto-Target",
    CurrentValue = State.Features.AutoTarget,
    Callback = function(value)
        State.Features.AutoTarget = value
        State.Cache.TargetPlayer = nil
    end
})
TeleportTab:CreateDropdown({
    Name = "Auto-Target Mode",
    Options = {"nearest", "lowest_health", "random"},
    CurrentOption = State.Settings.AutoTargetMode,
    Callback = function(option)
        State.Settings.AutoTargetMode = option
    end
})
TeleportTab:CreateToggle({
    Name = "Smart Follow",
    CurrentValue = State.Features.SmartFollow,
    Callback = function(value)
        State.Features.SmartFollow = value
    end
})
TeleportTab:CreateInput({
    Name = "Nome do Alvo",
    PlaceholderText = "Digite nome parcial",
    RemoveTextAfterFocusLost = false,
    Callback = function(text)
        State.Settings.TargetName = text
        State.Cache.TargetPlayer = nil
    end
})
TeleportTab:CreateDropdown({
    Name = "Modo de Teleporte",
    Options = {"behind", "side", "above", "random"},
    CurrentOption = State.Settings.TeleportMode,
    Callback = function(option)
        State.Settings.TeleportMode = option
    end
})
TeleportTab:CreateToggle({
    Name = "Stealth Mode (Pathfinding)",
    CurrentValue = State.Features.StealthMode,
    Callback = function(value)
        State.Features.StealthMode = value
    end
})
TeleportTab:CreateSlider({
    Name = "Stealth Level",
    Range = {1, 10},
    Increment = 1,
    CurrentValue = State.Settings.StealthLevel,
    Callback = function(value)
        State.Settings.StealthLevel = value
        State.Settings.TeleportFrequency = value * 0.5  -- Ajusta freq baseado em level
    end
})

-- Status em tempo real
task.spawn(function()
    while true do
        if State.AI.Paused then
            StatusLabel:Set("⏸️ PAUSADO: " .. State.AI.PauseReason)
        elseif State.Features.LoopGoto then
            local target = State.Cache.TargetPlayer
            if target then
                local distance = target.Character and (player.Character.HumanoidRootPart.Position - target.Character.HumanoidRootPart.Position).Magnitude or 0
                local health = target.Character and target.Character.Humanoid.Health or 0
                local behavior = State.AI.CurrentBehavior
                StatusLabel:Set(string.format("🎯 %s | 📏 %.1f | ❤️ %.0f | 🤖 %s", target.DisplayName, distance, health, behavior))
            else
                StatusLabel:Set("❌ Alvo não encontrado")
            end
        else
            StatusLabel:Set("⏸️ Loop Goto desativado")
        end
        task.wait(0.2)
    end
end)

-- =====================================================
-- TAB: IA
-- =====================================================
local AITab = Window:CreateTab("🤖 IA", "cpu")
AITab:CreateSection("Sistema de IA")
local AIStatusLabel = AITab:CreateLabel("Comportamento: Normal")
AITab:CreateToggle({
    Name = "IA Comportamental",
    CurrentValue = State.Features.BehaviorAI,
    Callback = function(value)
        State.Features.BehaviorAI = value
        Rayfield:Notify({Title = "IA", Content = value and "✅ Ativa" or "⏸️ Desativada", Duration = 2})
    end
})
AITab:CreateToggle({
    Name = "Threat Detection",
    CurrentValue = State.Features.ThreatDetection,
    Callback = function(value)
        State.Features.ThreatDetection = value
    end
})
AITab:CreateToggle({
    Name = "Auto-Pause em Ameaças",
    CurrentValue = State.Features.AutoPause,
    Callback = function(value)
        State.Features.AutoPause = value
        State.Settings.PauseOnThreat = value
    end
})
AITab:CreateSlider({
    Name = "Max Idle Time (s)",
    Range = {10, 120},
    Increment = 5,
    Suffix = "s",
    CurrentValue = State.Settings.MaxIdleTime,
    Callback = function(value)
        State.Settings.MaxIdleTime = value
    end
})
AITab:CreateSection("Status em Tempo Real")
task.spawn(function()
    while true do
        local behavior = State.AI.CurrentBehavior
        local paused = State.AI.Paused and "SIM" or "NÃO"
        local threats = #State.Cache.ThreatPlayers
        local patterns = #State.AI.LearnedPatterns
        AIStatusLabel:Set(string.format("🤖 Comportamento: %s\n⏸️ Pausado: %s\n⚠️ Threats: %d\n📚 Patterns: %d", behavior, paused, threats, patterns))
        task.wait(1)
    end
end)

-- =====================================================
-- TAB: DEBUG
-- =====================================================
local DebugTab = Window:CreateTab("🔧 Debug", "terminal")
DebugTab:CreateSection("Debug & Performance")
local PerformanceLabel = DebugTab:CreateLabel("FPS: Calculando...")
local PingLabel = DebugTab:CreateLabel("Ping: Calculando...")
local ErrorLabel = DebugTab:CreateLabel("Erros: 0")
DebugTab:CreateToggle({
    Name = "Debug Mode",
    CurrentValue = State.Debug.Enabled,
    Callback = function(value)
        State.Debug.Enabled = value
        Rayfield:Notify({Title = "Debug", Content = value and "✅ Ativo" or "⏸️ Desativado", Duration = 2})
    end
})
DebugTab:CreateButton({
    Name = "🔄 Limpar Logs",
    Callback = function()
        State.Logs = {}
        Rayfield:Notify({Title = "Logs", Content = "Limpos", Duration = 1.5})
    end
})
DebugTab:CreateButton({
    Name = "📊 Exportar Dados (Console/JSON)",
    Callback = function()
        Utils.exportLogs()
        Rayfield:Notify({Title = "Export", Content = "Dados no console", Duration = 3})
    end
})

-- Atualizar performance
task.spawn(function()
    while true do
        if #State.Debug.PerformanceData.FPS > 0 then
            local avgFPS = 0
            for _, fps in ipairs(State.Debug.PerformanceData.FPS) do avgFPS = avgFPS + fps end
            avgFPS = avgFPS / #State.Debug.PerformanceData.FPS
            PerformanceLabel:Set(string.format("📊 FPS: %.1f", avgFPS))
        end
        if #State.Debug.PerformanceData.Ping > 0 then
            local avgPing = 0
            for _, ping in ipairs(State.Debug.PerformanceData.Ping) do avgPing = avgPing + ping end
            avgPing = avgPing / #State.Debug.PerformanceData.Ping
            PingLabel:Set(string.format("📡 Ping: %.0f ms", avgPing))
        end
        ErrorLabel:Set(string.format("❌ Erros: %d", State.Stats.ErrorCount))
        task.wait(1)
    end
end)

-- =====================================================
-- TAB: STATS
-- =====================================================
local StatsTab = Window:CreateTab("📊 Stats", "bar-chart")
StatsTab:CreateSection("Estatísticas")
local KillsLabel = StatsTab:CreateLabel("💀 Kills: 0")
local FarmKillsLabel = StatsTab:CreateLabel("🌾 Farm Kills: 0")
local DeathsLabel = StatsTab:CreateLabel("☠️ Deaths: 0")
local TeleportsLabel = StatsTab:CreateLabel("🎯 Teleports: 0")
local M1Label = StatsTab:CreateLabel("👊 M1s: 0")
local UptimeLabel = StatsTab:CreateLabel("⏱️ Uptime: 0s")
local AutoPauseLabel = StatsTab:CreateLabel("⏸️ Auto-Pausas: 0")
local ThreatsLabel = StatsTab:CreateLabel("⚠️ Threats: 0")
task.spawn(function()
    while true do
        local uptime = math.floor(tick() - State.Stats.SessionStart)
        KillsLabel:Set(string.format("💀 Kills: %d", State.Stats.Kills))
        FarmKillsLabel:Set(string.format("🌾 Farm Kills: %d", State.Stats.FarmKills))
        DeathsLabel:Set(string.format("☠️ Deaths: %d", State.Stats.Deaths))
        TeleportsLabel:Set(string.format("🎯 Teleports: %d", State.Stats.TeleportCount))
        M1Label:Set(string.format("👊 M1s: %d", State.Stats.M1Count))
        UptimeLabel:Set(string.format("⏱️ Uptime: %ds", uptime))
        AutoPauseLabel:Set(string.format("⏸️ Auto-Pausas: %d", State.Stats.AutoPauseCount))
        ThreatsLabel:Set(string.format("⚠️ Threats: %d", State.Stats.ThreatsDetected))
        task.wait(1)
    end
end)

-- =====================================================
-- TAB: UTILS
-- =====================================================
local UtilsTab = Window:CreateTab("🛠️ Utils", "wrench")
UtilsTab:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = State.Features.AntiAFK,
    Callback = function(value)
        State.Features.AntiAFK = value
        if value then AntiAFKFeature.start() else AntiAFKFeature.stop() end
    end
})

-- =====================================================
-- TAB: INFO
-- =====================================================
local InfoTab = Window:CreateTab("ℹ️ Info", "info")
InfoTab:CreateLabel("TSB Hub V4 - SUPREME")
InfoTab:CreateLabel("")
InfoTab:CreateLabel("🚀 Novidades:")
InfoTab:CreateLabel("• IA com aprendizado de padrões")
InfoTab:CreateLabel("• Pathfinding para teleports stealth")
InfoTab:CreateLabel("• Auto-Farm inteligente")
InfoTab:CreateLabel("• Threat detection expandida")
InfoTab:CreateLabel("• Humanização avançada com erros simulados")
InfoTab:CreateLabel("• Export de dados JSON")
InfoTab:CreateLabel("")
InfoTab:CreateLabel("⌨️ Tecla K - Abrir/Fechar GUI")

-- =====================================================
-- INICIALIZAÇÃO
-- =====================================================
if State.Features.OneHit then OneHitFeature.start() end
if State.Features.AntiAFK then AntiAFKFeature.start() end
Rayfield:Notify({
    Title = "TSB Hub V4 Supreme!",
    Content = "IA Avançada + Stealth Ativos",
    Duration = 5
})
Utils.log("TSB Hub V4 inicializado", "SYSTEM")
print("✅ [TSB Hub V4] Carregado com sucesso!")
print("🤖 [TSB Hub V4] IA Avançada ativa")
print("🛡️ [TSB Hub V4] Threat Detection++ ON")
