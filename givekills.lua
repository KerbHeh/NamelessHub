 (cd "$(git rev-parse --show-toplevel)" && git apply --3way <<'EOF' 
diff --git a/givekills.lua b/givekills.lua
index 43f1fae928f3facb96ea458ed605a8260e200e3e..343f640ebef88fd91e4d839747e0e99bce05b18d 100644
--- a/givekills.lua
+++ b/givekills.lua
@@ -1,238 +1,692 @@
+local Players = game:GetService("Players")
+local RunService = game:GetService("RunService")
+local ReplicatedStorage = game:GetService("ReplicatedStorage")
+
+local LocalPlayer = Players.LocalPlayer
+
 local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
 local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
 local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
 
 local Window = Fluent:CreateWindow({
-    Title = "NamelessHub",
+    Title = "NamelessHub | TSB Edition",
     SubTitle = "by 0_Pottencias",
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
 
+local State = {
+    selectedPlayer = nil,
+    selectedHighlight = nil,
+    espData = {},
+    loops = {}
+}
+
+local function notify(title, content, duration)
+    Fluent:Notify({
+        Title = title,
+        Content = content,
+        Duration = duration or 3
+    })
+end
+
+local function getCharacter(player)
+    if not player then
+        return nil
+    end
+
+    local character = player.Character
+    if not character then
+        return nil
+    end
+
+    local hrp = character:FindFirstChild("HumanoidRootPart")
+    local humanoid = character:FindFirstChildOfClass("Humanoid")
+    if not hrp or not humanoid or humanoid.Health <= 0 then
+        return nil
+    end
+
+    return character, hrp, humanoid
+end
+
+local function getRootPosition(player)
+    local _, root = getCharacter(player)
+    return root and root.Position or nil
+end
+
+local function getDistanceToLocal(player)
+    if player == LocalPlayer then
+        return math.huge
+    end
+
+    local localPos = getRootPosition(LocalPlayer)
+    local targetPos = getRootPosition(player)
+    if not localPos or not targetPos then
+        return math.huge
+    end
+
+    return (localPos - targetPos).Magnitude
+end
+
+local function getPlayerHealth(player)
+    local _, _, humanoid = getCharacter(player)
+    return humanoid and humanoid.Health or math.huge
+end
+
+local function findTarget(mode)
+    local candidates = {}
+    for _, player in ipairs(Players:GetPlayers()) do
+        if player ~= LocalPlayer and getCharacter(player) then
+            table.insert(candidates, player)
+        end
+    end
+
+    if #candidates == 0 then
+        return nil
+    end
+
+    table.sort(candidates, function(a, b)
+        if mode == "Vida Mais Baixa" then
+            local aHealth = getPlayerHealth(a)
+            local bHealth = getPlayerHealth(b)
+            if aHealth == bHealth then
+                return getDistanceToLocal(a) < getDistanceToLocal(b)
+            end
+            return aHealth < bHealth
+        end
+
+        return getDistanceToLocal(a) < getDistanceToLocal(b)
+    end)
+
+    return candidates[1]
+end
+
+local function teleportNear(player, offset)
+    local localCharacter, localRoot = getCharacter(LocalPlayer)
+    local _, targetRoot = getCharacter(player)
+    if not localCharacter or not localRoot or not targetRoot then
+        return false
+    end
+
+    localRoot.CFrame = targetRoot.CFrame * CFrame.new(offset or Vector3.new(0, 0, -3))
+    return true
+end
+
+local function clickAttack()
+    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
+    if tool and tool:FindFirstChild("Handle") then
+        tool:Activate()
+        return true
+    end
+
+    pcall(function()
+        local virtualInput = game:GetService("VirtualInputManager")
+        virtualInput:SendMouseButtonEvent(0, 0, 0, true, game, 0)
+        virtualInput:SendMouseButtonEvent(0, 0, 0, false, game, 0)
+    end)
+    return false
+end
+
+local function setSelectedPlayer(player)
+    State.selectedPlayer = player
+
+    if State.selectedHighlight then
+        State.selectedHighlight:Destroy()
+        State.selectedHighlight = nil
+    end
+
+    local targetCharacter = player and getCharacter(player)
+    if targetCharacter then
+        local highlight = Instance.new("Highlight")
+        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
+        highlight.FillColor = Color3.fromRGB(255, 170, 0)
+        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
+        highlight.FillTransparency = 0.5
+        highlight.Parent = targetCharacter
+        State.selectedHighlight = highlight
+        notify("Techs", "Selecionado: " .. player.Name, 2)
+    else
+        notify("Techs", "Nenhum jogador selecionado.", 2)
+    end
+end
+
+local function sideDashToSelected()
+    local target = State.selectedPlayer
+    if not target then
+        notify("Techs", "Nenhum jogador selecionado.", 2)
+        return
+    end
+
+    local _, targetRoot = getCharacter(target)
+    local localCharacter, localRoot = getCharacter(LocalPlayer)
+    if not targetRoot or not localRoot or not localCharacter then
+        notify("Techs", "Alvo inválido.", 2)
+        return
+    end
+
+    local rightSide = targetRoot.CFrame.RightVector * 4
+    localRoot.CFrame = CFrame.new(targetRoot.Position + rightSide, targetRoot.Position)
+    clickAttack()
+    notify("Techs", "Side Dash executado.", 2)
+end
+
+local function stopLoop(name)
+    if State.loops[name] then
+        State.loops[name] = false
+    end
+end
+
+local function runLoop(name, callback, delay)
+    stopLoop(name)
+    State.loops[name] = true
+
+    task.spawn(function()
+        while State.loops[name] do
+            local ok, err = pcall(callback)
+            if not ok then
+                warn("[" .. name .. "] erro: " .. tostring(err))
+            end
+            task.wait(delay or 0.1)
+        end
+    end)
+end
+
+local function createBillboard(name, color)
+    local billboard = Instance.new("BillboardGui")
+    billboard.Name = name
+    billboard.Size = UDim2.new(0, 150, 0, 35)
+    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
+    billboard.AlwaysOnTop = true
+
+    local text = Instance.new("TextLabel")
+    text.BackgroundTransparency = 1
+    text.Size = UDim2.fromScale(1, 1)
+    text.Font = Enum.Font.GothamBold
+    text.TextScaled = true
+    text.TextColor3 = color
+    text.TextStrokeTransparency = 0
+    text.Parent = billboard
+
+    return billboard, text
+end
+
+local function clearESPForPlayer(player)
+    local data = State.espData[player]
+    if not data then
+        return
+    end
+
+    for _, object in pairs(data) do
+        if typeof(object) == "Instance" and object.Parent then
+            object:Destroy()
+        end
+    end
+
+    State.espData[player] = nil
+end
+
+local function updateESPForPlayer(player)
+    local character, root, humanoid = getCharacter(player)
+    if not character or not root or not humanoid then
+        clearESPForPlayer(player)
+        return
+    end
+
+    State.espData[player] = State.espData[player] or {}
+    local data = State.espData[player]
+
+    if Options.PlayerESP.Value then
+        if not data.playerLabel then
+            local bb, text = createBillboard("TSB_PlayerESP", Color3.fromRGB(255, 255, 255))
+            bb.Parent = root
+            data.playerLabel = bb
+            data.playerLabelText = text
+        end
+
+        data.playerLabelText.Text = string.format("%s | %dm", player.Name, math.floor(getDistanceToLocal(player)))
+    elseif data.playerLabel then
+        data.playerLabel:Destroy()
+        data.playerLabel = nil
+        data.playerLabelText = nil
+    end
+
+    if Options.HealthESP.Value then
+        if not data.healthLabel then
+            local bb, text = createBillboard("TSB_HealthESP", Color3.fromRGB(0, 255, 127))
+            bb.StudsOffset = Vector3.new(0, 2.4, 0)
+            bb.Parent = root
+            data.healthLabel = bb
+            data.healthLabelText = text
+        end
+
+        data.healthLabelText.Text = string.format("HP: %d", math.floor(humanoid.Health))
+    elseif data.healthLabel then
+        data.healthLabel:Destroy()
+        data.healthLabel = nil
+        data.healthLabelText = nil
+    end
+
+    if Options.TracerESP.Value then
+        if not data.tracer then
+            local tracer = Instance.new("Beam")
+            local localAttachment = Instance.new("Attachment")
+            local targetAttachment = Instance.new("Attachment")
+
+            local localRoot = getCharacter(LocalPlayer)
+            local localHrp = localRoot and select(2, getCharacter(LocalPlayer))
+            if localHrp then
+                localAttachment.Parent = localHrp
+                targetAttachment.Parent = root
+                tracer.Attachment0 = localAttachment
+                tracer.Attachment1 = targetAttachment
+                tracer.Width0 = 0.08
+                tracer.Width1 = 0.08
+                tracer.FaceCamera = true
+                tracer.Color = ColorSequence.new(Color3.fromRGB(255, 65, 65))
+                tracer.Parent = localHrp
+                data.tracer = tracer
+                data.tracerA0 = localAttachment
+                data.tracerA1 = targetAttachment
+            end
+        end
+    elseif data.tracer then
+        data.tracer:Destroy()
+        data.tracerA0:Destroy()
+        data.tracerA1:Destroy()
+        data.tracer = nil
+        data.tracerA0 = nil
+        data.tracerA1 = nil
+    end
+end
+
+local function refreshESP()
+    for _, player in ipairs(Players:GetPlayers()) do
+        if player ~= LocalPlayer then
+            updateESPForPlayer(player)
+        end
+    end
+
+    for player in pairs(State.espData) do
+        if not player.Parent then
+            clearESPForPlayer(player)
+        end
+    end
+end
+
+local chatRemote = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
+chatRemote = chatRemote and chatRemote:FindFirstChild("SayMessageRequest") or nil
+
 -- About
 Tabs.About:AddParagraph({
     Title = "TSB Script",
-    Content = "Versão: 1.2\nThe Strongest Battlegrounds\nCriado por Just a DOOM\nMuitas techs automáticas adicionadas\nFunciona melhor com Junkie"
+    Content = "Versão: 2.0\nAdaptado para The Strongest Battlegrounds\nFoco em farm de alvo, techs práticas e ESP leve"
 })
 
 Tabs.About:AddButton({
     Title = "Discord",
     Callback = function()
-        Fluent:Notify({
-            Title = "Discord",
-            Content = "Link do servidor: discord.gg/seu_server_aqui",
-            Duration = 8
-        })
+        notify("Discord", "Link do servidor: discord.gg/seu_server_aqui", 8)
     end
 })
 
 -- Farm Tab
-Tabs.Farm:AddSection("Trash Can Farm")
+Tabs.Farm:AddSection("Farm TSB")
 
-Tabs.Farm:AddToggle("TrashInvisible", {Title = "Invisível no Trash Farm", Default = false}):OnChanged(function(value)
-    -- Coloque aqui código para tornar invisível (ex: transparency nas parts)
+Tabs.Farm:AddToggle("TrashInvisible", { Title = "Invisível no Trash Farm", Default = false }):OnChanged(function(value)
+    local character = LocalPlayer.Character
+    if not character then
+        return
+    end
+
+    for _, obj in ipairs(character:GetDescendants()) do
+        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
+            obj.LocalTransparencyModifier = value and 0.6 or 0
+        end
+    end
 end)
 
 Tabs.Farm:AddDropdown("TrashTarget", {
     Title = "Alvo Trash Farm",
-    Values = {"Mais Próximo", "Vida Mais Baixa"},
+    Values = { "Mais Próximo", "Vida Mais Baixa" },
     Default = "Mais Próximo",
     Multi = false
 })
 
-Tabs.Farm:AddToggle("TrashFarm", {Title = "Auto Trash Can Farm", Default = false}):OnChanged(function(value)
+Tabs.Farm:AddToggle("TrashFarm", { Title = "Auto Trash Can Farm", Default = false }):OnChanged(function(value)
     if value then
-        spawn(function()
-            while Options.TrashFarm.Value do
-                -- Lógica de farm trash can aqui (encontrar alvo, atacar, etc.)
-                task.wait()
+        runLoop("TrashFarm", function()
+            local target = findTarget(Options.TrashTarget.Value)
+            if target and teleportNear(target, Vector3.new(0, 0, -2)) then
+                clickAttack()
             end
-        end)
+        end, 0.12)
+    else
+        stopLoop("TrashFarm")
     end
 end)
 
 Tabs.Farm:AddSection("Farm Padrão")
 
 Tabs.Farm:AddDropdown("StandardTarget", {
     Title = "Alvo Farm Padrão",
-    Values = {"Mais Próximo", "Vida Mais Baixa"},
+    Values = { "Mais Próximo", "Vida Mais Baixa" },
     Default = "Mais Próximo",
     Multi = false
 })
 
-Tabs.Farm:AddToggle("StandardFarm", {Title = "Auto Farm Padrão", Default = false}):OnChanged(function(value)
+Tabs.Farm:AddToggle("StandardFarm", { Title = "Auto Farm Padrão", Default = false }):OnChanged(function(value)
     if value then
-        spawn(function()
-            while Options.StandardFarm.Value do
-                -- Lógica de farm normal (matar jogador alvo)
-                task.wait()
+        runLoop("StandardFarm", function()
+            local target = findTarget(Options.StandardTarget.Value)
+            if target and teleportNear(target, Vector3.new(0, 0, -3.5)) then
+                clickAttack()
             end
-        end)
+        end, 0.15)
+    else
+        stopLoop("StandardFarm")
     end
 end)
 
--- Techs Tab (muitas techs adicionadas)
+-- Techs Tab
 Tabs.Techs:AddParagraph({
     Title = "Techs Automáticas",
-    Content = "Várias techs populares do TSB automatizadas.\nSide Dash: R seleciona jogador (highlight), E executa side dash se perto o suficiente."
+    Content = "R seleciona o alvo mais próximo. E aplica Side Dash no alvo selecionado."
 })
 
--- Side Dash Tech
-local SelectedPlayer = nil
-
 Tabs.Techs:AddKeybind("SelectKey", {
     Title = "Tecla Selecionar Jogador",
     Mode = "Hold",
     Default = "R",
     Callback = function(value)
         if value then
-            -- Encontra jogador mais próximo e seleciona
-            -- SelectedPlayer = findClosestPlayer()
-            Fluent:Notify({Title = "Techs", Content = "Jogador selecionado!", Duration = 2})
+            setSelectedPlayer(findTarget("Mais Próximo"))
         end
     end
 })
 
 Tabs.Techs:AddKeybind("SideDashKey", {
     Title = "Tecla Side Dash",
     Mode = "Hold",
     Default = "E",
     Callback = function(value)
-        if value and SelectedPlayer then
-            -- Executa side dash no jogador selecionado se perto
-            Fluent:Notify({Title = "Techs", Content = "Side Dash executado!", Duration = 2})
+        if value then
+            sideDashToSelected()
         end
     end
 })
 
 Tabs.Techs:AddButton({
     Title = "Deselecionar Jogador",
     Callback = function()
-        SelectedPlayer = nil
-        Fluent:Notify({Title = "Techs", Content = "Jogador deselecionado.", Duration = 2})
+        setSelectedPlayer(nil)
     end
 })
 
 Tabs.Techs:AddSection("Techs Automáticas")
 
-Tabs.Techs:AddToggle("AutoKyoto", {Title = "Auto Kyoto Combo (1 → dash → turn → 2)", Default = false}):OnChanged(function(value)
+Tabs.Techs:AddToggle("AutoKyoto", { Title = "Auto Kyoto Combo", Default = false }):OnChanged(function(value)
     if value then
-        spawn(function()
-            while Options.AutoKyoto.Value do
-                -- Lógica Kyoto: usa 1, espera acabar, dash, vira, usa 2
-                task.wait()
+        runLoop("AutoKyoto", function()
+            local target = findTarget("Mais Próximo")
+            if target and teleportNear(target, Vector3.new(0, 0, -2.5)) then
+                clickAttack()
+                task.wait(0.2)
+                clickAttack()
             end
-        end)
+        end, 0.35)
+    else
+        stopLoop("AutoKyoto")
     end
 end)
 
-Tabs.Techs:AddToggle("AutoUppercutDash", {Title = "Auto Uppercut → Dash", Default = false})
+Tabs.Techs:AddToggle("AutoUppercutDash", { Title = "Auto Uppercut → Dash", Default = false }):OnChanged(function(value)
+    if value then
+        runLoop("AutoUppercutDash", function()
+            local target = findTarget("Mais Próximo")
+            if target then
+                teleportNear(target, Vector3.new(0, 2, -1.2))
+                clickAttack()
+            end
+        end, 0.28)
+    else
+        stopLoop("AutoUppercutDash")
+    end
+end)
 
-Tabs.Techs:AddToggle("AutoMiniUppercut", {Title = "Auto Mini Uppercut Tech", Default = false})
+Tabs.Techs:AddToggle("AutoMiniUppercut", { Title = "Auto Mini Uppercut Tech", Default = false }):OnChanged(function(value)
+    if value then
+        runLoop("AutoMiniUppercut", function()
+            local target = findTarget("Mais Próximo")
+            if target then
+                teleportNear(target, Vector3.new(0, 1.2, -1))
+                clickAttack()
+            end
+        end, 0.24)
+    else
+        stopLoop("AutoMiniUppercut")
+    end
+end)
 
-Tabs.Techs:AddToggle("AutoConsecutive", {Title = "Auto Consecutive Punches Tech", Default = false})
+Tabs.Techs:AddToggle("AutoConsecutive", { Title = "Auto Consecutive Punches Tech", Default = false }):OnChanged(function(value)
+    if value then
+        runLoop("AutoConsecutive", function()
+            local target = findTarget("Mais Próximo")
+            if target then
+                teleportNear(target, Vector3.new(0, 0, -2))
+                clickAttack()
+                task.wait(0.06)
+                clickAttack()
+            end
+        end, 0.25)
+    else
+        stopLoop("AutoConsecutive")
+    end
+end)
 
-Tabs.Techs:AddToggle("AutoDeathCounter", {Title = "Auto Death Counter Tech", Default = false})
+Tabs.Techs:AddToggle("AutoDeathCounter", { Title = "Auto Death Counter Tech", Default = false }):OnChanged(function(value)
+    if value then
+        runLoop("AutoDeathCounter", function()
+            local _, _, humanoid = getCharacter(LocalPlayer)
+            if humanoid and humanoid.Health < humanoid.MaxHealth * 0.3 then
+                clickAttack()
+            end
+        end, 0.2)
+    else
+        stopLoop("AutoDeathCounter")
+    end
+end)
 
-Tabs.Techs:AddToggle("AutoDeathBlow", {Title = "Auto Death Blow Combo", Default = false})
+Tabs.Techs:AddToggle("AutoDeathBlow", { Title = "Auto Death Blow Combo", Default = false }):OnChanged(function(value)
+    if value then
+        runLoop("AutoDeathBlow", function()
+            local target = findTarget("Vida Mais Baixa")
+            if target then
+                teleportNear(target, Vector3.new(0, 0, -1.8))
+                clickAttack()
+                task.wait(0.1)
+                clickAttack()
+            end
+        end, 0.35)
+    else
+        stopLoop("AutoDeathBlow")
+    end
+end)
 
-Tabs.Techs:AddToggle("AutoTableFlip", {Title = "Auto Table Flip Tech", Default = false})
+Tabs.Techs:AddToggle("AutoTableFlip", { Title = "Auto Table Flip Tech", Default = false }):OnChanged(function(value)
+    if value then
+        runLoop("AutoTableFlip", function()
+            local target = findTarget("Mais Próximo")
+            if target then
+                teleportNear(target, Vector3.new(0, -1.5, -1))
+                clickAttack()
+            end
+        end, 0.45)
+    else
+        stopLoop("AutoTableFlip")
+    end
+end)
 
-Tabs.Techs:AddToggle("AutoHuntersGrasp", {Title = "Auto Hunter's Grasp Tech", Default = false})
+Tabs.Techs:AddToggle("AutoHuntersGrasp", { Title = "Auto Hunter's Grasp Tech", Default = false }):OnChanged(function(value)
+    if value then
+        runLoop("AutoHuntersGrasp", function()
+            local target = findTarget("Mais Próximo")
+            if target then
+                teleportNear(target, Vector3.new(0, 0, -0.8))
+                clickAttack()
+            end
+        end, 0.32)
+    else
+        stopLoop("AutoHuntersGrasp")
+    end
+end)
 
-Tabs.Techs:AddToggle("AutoEvadeTech", {Title = "Auto Evade + Counter Tech", Default = false})
+Tabs.Techs:AddToggle("AutoEvadeTech", { Title = "Auto Evade + Counter Tech", Default = false }):OnChanged(function(value)
+    if value then
+        runLoop("AutoEvadeTech", function()
+            local _, _, humanoid = getCharacter(LocalPlayer)
+            if humanoid and humanoid.MoveDirection.Magnitude > 0.1 then
+                clickAttack()
+            end
+        end, 0.22)
+    else
+        stopLoop("AutoEvadeTech")
+    end
+end)
 
-Tabs.Techs:AddToggle("AutoGrandSlam", {Title = "Auto Grand Slam Combo", Default = false})
+Tabs.Techs:AddToggle("AutoGrandSlam", { Title = "Auto Grand Slam Combo", Default = false }):OnChanged(function(value)
+    if value then
+        runLoop("AutoGrandSlam", function()
+            local target = findTarget("Mais Próximo")
+            if target then
+                teleportNear(target, Vector3.new(0, 3, -1.5))
+                clickAttack()
+            end
+        end, 0.4)
+    else
+        stopLoop("AutoGrandSlam")
+    end
+end)
 
 -- ESP Tab
 Tabs.ESP:AddSection("ESP Options")
 
-Tabs.ESP:AddToggle("PlayerESP", {Title = "Player ESP (Box + Name)", Default = false})
+Tabs.ESP:AddToggle("PlayerESP", { Title = "Player ESP (Nome + Distância)", Default = false })
+Tabs.ESP:AddToggle("UltESP", { Title = "Ultimate Level ESP (placeholder)", Default = false })
+Tabs.ESP:AddToggle("DeathESP", { Title = "Death Counter ESP (placeholder)", Default = false })
+Tabs.ESP:AddToggle("HealthESP", { Title = "Health Bar ESP", Default = false })
+Tabs.ESP:AddToggle("TracerESP", { Title = "Tracers para Jogadores", Default = false })
 
-Tabs.ESP:AddToggle("UltESP", {Title = "Ultimate Level ESP (0-100%)", Default = false})
-
-Tabs.ESP:AddToggle("DeathESP", {Title = "Death Counter ESP", Default = false})
-
-Tabs.ESP:AddToggle("HealthESP", {Title = "Health Bar ESP", Default = false})
-
-Tabs.ESP:AddToggle("TracerESP", {Title = "Tracers para Jogadores", Default = false})
+RunService.RenderStepped:Connect(function()
+    refreshESP()
+end)
 
 -- Troll Tab
 Tabs.Troll:AddSection("Troll Features")
 
-Tabs.Troll:AddToggle("ServerLag", {Title = "Auto Server Lag", Default = false}):OnChanged(function(value)
+Tabs.Troll:AddToggle("ServerLag", { Title = "Auto Server Lag (visual local)", Default = false }):OnChanged(function(value)
     if value then
-        spawn(function()
-            while Options.ServerLag.Value do
-                for i = 1, 15 do
-                    Instance.new("Part", workspace)
-                end
-                task.wait(0.5)
+        runLoop("ServerLag", function()
+            local folder = workspace:FindFirstChild("TSB_LocalFx") or Instance.new("Folder", workspace)
+            folder.Name = "TSB_LocalFx"
+            for i = 1, 8 do
+                local part = Instance.new("Part")
+                part.Size = Vector3.new(0.4, 0.4, 0.4)
+                part.Anchored = true
+                part.CanCollide = false
+                part.Material = Enum.Material.Neon
+                part.Color = Color3.fromRGB(255, 0, 0)
+                part.Position = (getRootPosition(LocalPlayer) or Vector3.zero) + Vector3.new(math.random(-4, 4), math.random(1, 5), math.random(-4, 4))
+                part.Parent = folder
+                game:GetService("Debris"):AddItem(part, 1)
             end
-        end)
+        end, 0.5)
+    else
+        stopLoop("ServerLag")
     end
 end)
 
 Tabs.Troll:AddInput("CounterMsg", {
     Title = "Mensagem ao Counter",
     Default = "Countered kkk",
     Placeholder = "Mensagem personalizada"
 })
 
-Tabs.Troll:AddToggle("AutoSayCounter", {Title = "Auto Falar ao Ver Counter Próximo", Default = false}):OnChanged(function(value)
+Tabs.Troll:AddToggle("AutoSayCounter", { Title = "Auto Falar ao Ver Counter Próximo", Default = false }):OnChanged(function(value)
     if value then
-        spawn(function()
-            while Options.AutoSayCounter.Value do
-                -- Detectar counter próximo e chat: Options.CounterMsg.Value
-                task.wait(0.3)
+        runLoop("AutoSayCounter", function()
+            if not chatRemote then
+                return
             end
-        end)
+
+            for _, player in ipairs(Players:GetPlayers()) do
+                if player ~= LocalPlayer and getDistanceToLocal(player) < 10 then
+                    chatRemote:FireServer(Options.CounterMsg.Value, "All")
+                    break
+                end
+            end
+        end, 2.2)
+    else
+        stopLoop("AutoSayCounter")
     end
 end)
 
 Tabs.Troll:AddButton({
     Title = "Spam Chat",
     Callback = function()
-        for i = 1, 20 do
-            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("TSB Script on top!", "All")
-            task.wait(0.5)
+        if not chatRemote then
+            notify("Chat", "Remote de chat não encontrado.", 3)
+            return
         end
+
+        task.spawn(function()
+            for i = 1, 20 do
+                chatRemote:FireServer("TSB Script on top!", "All")
+                task.wait(0.5)
+            end
+        end)
     end
 })
 
 -- SaveManager & InterfaceManager
 SaveManager:SetLibrary(Fluent)
 InterfaceManager:SetLibrary(Fluent)
 
-SaveManager:IgnoreThemeSettings()
-SaveManager:SetIgnoreIndexes({})
-
-InterfaceManager:SetFolder("TSBScript")
-SaveManager:SetFolder("TSBScript/configs")
-
+InterfaceManager:SetFolder("NamelessHub")
+SaveManager:SetFolder("NamelessHub/TSB")
 InterfaceManager:BuildInterfaceSection(Tabs.Settings)
 SaveManager:BuildConfigSection(Tabs.Settings)
+SaveManager:LoadAutoloadConfig()
 
-Window:SelectTab(1)
+Players.PlayerRemoving:Connect(function(player)
+    clearESPForPlayer(player)
+    if State.selectedPlayer == player then
+        setSelectedPlayer(nil)
+    end
+end)
 
-Fluent:Notify({
-    Title = "TSB Script",
-    Content = "Script carregado com sucesso! Muitas techs adicionadas.",
-    Duration = 8
-})
+LocalPlayer.CharacterAdded:Connect(function()
+    task.wait(1)
+    if Options.TrashInvisible and Options.TrashInvisible.Value then
+        for _, obj in ipairs(LocalPlayer.Character:GetDescendants()) do
+            if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
+                obj.LocalTransparencyModifier = 0.6
+            end
+        end
+    end
+end)
 
-SaveManager:LoadAutoloadConfig()
+notify("NamelessHub", "Script TSB carregado com sucesso.", 5)
 
EOF
)
