-- TSB One Hit Death + Loop Goto - Rayfield Official
-- Executor only
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- ================= GLOBAL VARS =================
getgenv().OneHitDeathEnabled = getgenv().OneHitDeathEnabled or false
getgenv().LoopGotoEnabled = getgenv().LoopGotoEnabled or false
getgenv().TargetName = getgenv().TargetName or ""
getgenv().TeleportOffset = getgenv().TeleportOffset or Vector3.new(0, 0, -2)  -- Agora é um Vector3 para mais customização (X, Y, Z)
getgenv().OneHitConnection = getgenv().OneHitConnection or nil
getgenv().LoopGotoConnection = getgenv().LoopGotoConnection or nil
getgenv().TeleportFrequency = getgenv().TeleportFrequency or 1  -- Frequência de teleporte (1 = todo frame, 2 = a cada 2 frames, etc.)
getgenv().frameCounter = 0  -- Contador para controle de frequência

-- ================= ONE HIT FUNCTION =================
local function hookCharacter(character)
    local humanoid = character:WaitForChild("Humanoid", 5)
    local hrp = character:WaitForChild("HumanoidRootPart", 5)
    if not humanoid or not hrp then return end
    
    local lastHealth = humanoid.Health
    if getgenv().OneHitConnection then
        getgenv().OneHitConnection:Disconnect()
    end
    getgenv().OneHitConnection = humanoid.HealthChanged:Connect(function(currentHealth)
        if getgenv().OneHitDeathEnabled and currentHealth < lastHealth then
            humanoid.Health = 0
        end
        lastHealth = currentHealth
    end)
end

if player.Character then
    hookCharacter(player.Character)
end
player.CharacterAdded:Connect(hookCharacter)

-- ================= PLAYER FINDER =================
local function findPlayerByPartialName(name)
    name = name:lower()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player and (plr.Name:lower():find(name, 1, true) or plr.DisplayName:lower():find(name, 1, true)) then
            return plr
        end
    end
    return nil
end

-- ================= LOOP GOTO =================
local function startLoopGoto()
    if getgenv().LoopGotoConnection then
        getgenv().LoopGotoConnection:Disconnect()
    end
    getgenv().LoopGotoConnection = RunService.Heartbeat:Connect(function()
        getgenv().frameCounter = getgenv().frameCounter + 1
        if getgenv().frameCounter % getgenv().TeleportFrequency ~= 0 then return end
        
        if not getgenv().LoopGotoEnabled then return end
        if getgenv().TargetName == "" then return end
        local target = findPlayerByPartialName(getgenv().TargetName)
        if not target then return end
        local char = player.Character
        local tchar = target.Character
        if not char or not tchar then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local thrp = tchar:FindFirstChild("HumanoidRootPart")
        if not hrp or not thrp then return end
        -- Teleporta com offset customizável (agora Vector3)
        hrp.CFrame = thrp.CFrame * CFrame.new(getgenv().TeleportOffset)
    end)
end
startLoopGoto()

-- ================= RAYFIELD GUI =================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
    Name = "TSB Exploit Hub",
    Icon = "skull", -- Lucide icon
    LoadingTitle = "TSB Script Loading",
    LoadingSubtitle = "by TSB Community",
    ShowText = "TSB Hub",
    Theme = "DarkBlue", -- Tema escuro e moderno
    ToggleUIKeybind = "K",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "TSB_Config"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "TSB Hub",
        Subtitle = "Key System",
        Note = "No key required",
        FileName = "TSBKey",
        SaveKey = false,
        GrabKeyFromSite = false,
        Key = {""}
    }
})

-- ================= TAB: COMBAT =================
local CombatTab = Window:CreateTab("⚔️ Combat", "sword")
local CombatSection = CombatTab:CreateSection("Combat Features")
local OneHitToggle = CombatTab:CreateToggle({
    Name = "One Hit Death",
    CurrentValue = getgenv().OneHitDeathEnabled,
    Flag = "OneHitDeath",
    Callback = function(Value)
        getgenv().OneHitDeathEnabled = Value
        if Value then
            Rayfield:Notify({
                Title = "One Hit Death",
                Content = "Ativado! Você morrerá em um hit.",
                Duration = 3,
                Image = "skull"
            })
        else
            Rayfield:Notify({
                Title = "One Hit Death",
                Content = "Desativado.",
                Duration = 3,
                Image = "shield"
            })
        end
    end,
})
CombatTab:CreateDivider()
local InfoLabel = CombatTab:CreateLabel("⚠️ One Hit Death mata você instantaneamente quando toma dano")

-- ================= TAB: TELEPORT =================
local TeleportTab = Window:CreateTab("🎯 Teleport", "navigation")
local TeleportSection = TeleportTab:CreateSection("Teleport Features")
local LoopGotoToggle = TeleportTab:CreateToggle({
    Name = "Loop Goto Target",
    CurrentValue = getgenv().LoopGotoEnabled,
    Flag = "LoopGoto",
    Callback = function(Value)
        getgenv().LoopGotoEnabled = Value
        if Value then
            if getgenv().TargetName == "" then
                Rayfield:Notify({
                    Title = "Loop Goto",
                    Content = "Defina um alvo primeiro!",
                    Duration = 3,
                    Image = "alert-triangle"
                })
            else
                Rayfield:Notify({
                    Title = "Loop Goto",
                    Content = "Teleportando para " .. getgenv().TargetName,
                    Duration = 3,
                    Image = "zap"
                })
            end
        else
            Rayfield:Notify({
                Title = "Loop Goto",
                Content = "Desativado.",
                Duration = 3,
                Image = "x"
            })
        end
    end,
})
local TargetInput = TeleportTab:CreateInput({
    Name = "Nome do Alvo (Username ou DisplayName)",
    CurrentValue = getgenv().TargetName,
    PlaceholderText = "Digite o nome (ex: kaleb)",
    RemoveTextAfterFocusLost = false,
    Flag = "TargetName",
    Callback = function(Text)
        getgenv().TargetName = Text
        Rayfield:Notify({
            Title = "Alvo Definido",
            Content = "Alvo: " .. Text,
            Duration = 2,
            Image = "target"
        })
    end,
})
TeleportTab:CreateDivider()
local OffsetXSlider = TeleportTab:CreateSlider({
    Name = "Offset X (studs)",
    Range = {-10, 10},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = getgenv().TeleportOffset.X,
    Flag = "OffsetX",
    Callback = function(Value)
        getgenv().TeleportOffset = Vector3.new(Value, getgenv().TeleportOffset.Y, getgenv().TeleportOffset.Z)
    end,
})
local OffsetYSlider = TeleportTab:CreateSlider({
    Name = "Offset Y (studs)",
    Range = {-10, 10},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = getgenv().TeleportOffset.Y,
    Flag = "OffsetY",
    Callback = function(Value)
        getgenv().TeleportOffset = Vector3.new(getgenv().TeleportOffset.X, Value, getgenv().TeleportOffset.Z)
    end,
})
local OffsetZSlider = TeleportTab:CreateSlider({
    Name = "Offset Z (studs)",
    Range = {-10, 10},
    Increment = 1,
    Suffix = " studs",
    CurrentValue = getgenv().TeleportOffset.Z,
    Flag = "OffsetZ",
    Callback = function(Value)
        getgenv().TeleportOffset = Vector3.new(getgenv().TeleportOffset.X, getgenv().TeleportOffset.Y, Value)
    end,
})
local FrequencySlider = TeleportTab:CreateSlider({
    Name = "Frequência de Teleporte",
    Range = {1, 10},
    Increment = 1,
    Suffix = " frames",
    CurrentValue = getgenv().TeleportFrequency,
    Flag = "TeleportFrequency",
    Callback = function(Value)
        getgenv().TeleportFrequency = Value
    end,
})
local InfoLabel2 = TeleportTab:CreateLabel("💡 Offset controla a posição relativa ao alvo (X/Y/Z)")
local InfoLabel3 = TeleportTab:CreateLabel("💡 Frequência: 1 = todo frame (mais suave), >1 = menos lag")

-- ================= TAB: PLAYERS =================
local PlayersTab = Window:CreateTab("👥 Players", "users")
local PlayersSection = PlayersTab:CreateSection("Players Online")
local function refreshPlayerList()
    local playerList = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= player then
            table.insert(playerList, plr.DisplayName .. " (@" .. plr.Name .. ")")
        end
    end
    return playerList
end
local PlayerDropdown = PlayersTab:CreateDropdown({
    Name = "Selecionar Alvo",
    Options = refreshPlayerList(),
    CurrentOption = {},
    MultipleOptions = false,
    Flag = "PlayerDropdown",
    Callback = function(Option)
        -- Extrai o username do formato "DisplayName (@username)"
        local username = Option[1]:match("%((.+)%)") or Option[1]
        getgenv().TargetName = username:gsub("@", "")
        Rayfield:Notify({
            Title = "Alvo Selecionado",
            Content = getgenv().TargetName,
            Duration = 2,
            Image = "user-check"
        })
    end,
})
local RefreshButton = PlayersTab:CreateButton({
    Name = "🔄 Atualizar Lista",
    Callback = function()
        PlayerDropdown:Refresh(refreshPlayerList(), true)
        Rayfield:Notify({
            Title = "Lista Atualizada",
            Content = "Players online atualizados!",
            Duration = 2,
            Image = "refresh-cw"
        })
    end,
})
PlayersTab:CreateDivider()
local TeleportToButton = PlayersTab:CreateButton({
    Name = "⚡ Teleportar Uma Vez",
    Callback = function()
        if getgenv().TargetName == "" then
            Rayfield:Notify({
                Title = "Erro",
                Content = "Selecione um alvo primeiro!",
                Duration = 3,
                Image = "alert-circle"
            })
            return
        end
        local target = findPlayerByPartialName(getgenv().TargetName)
        if not target then
            Rayfield:Notify({
                Title = "Erro",
                Content = "Player não encontrado!",
                Duration = 3,
                Image = "user-x"
            })
            return
        end
        local char = player.Character
        local tchar = target.Character
        if not char or not tchar then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local thrp = tchar:FindFirstChild("HumanoidRootPart")
        if not hrp or not thrp then return end
        hrp.CFrame = thrp.CFrame * CFrame.new(getgenv().TeleportOffset)
        Rayfield:Notify({
            Title = "Teleportado!",
            Content = "Você foi teleportado para " .. target.Name,
            Duration = 2,
            Image = "zap"
        })
    end,
})

-- ================= TAB: SETTINGS =================
local SettingsTab = Window:CreateTab("⚙️ Configurações", "settings")
local SettingsSection = SettingsTab:CreateSection("Interface")
local ThemeDropdown = SettingsTab:CreateDropdown({
    Name = "Tema do GUI",
    Options = {"Default", "AmberGlow", "Amethyst", "Bloom", "DarkBlue", "Green", "Light", "Ocean", "Serenity"},
    CurrentOption = {"DarkBlue"},
    MultipleOptions = false,
    Flag = "Theme",
    Callback = function(Option)
        Rayfield:Notify({
            Title = "Tema",
            Content = "Recarregue o script para aplicar: " .. Option[1],
            Duration = 3,
            Image = "palette"
        })
    end,
})
SettingsTab:CreateDivider()
local ToggleUIButton = SettingsTab:CreateButton({
    Name = "👁️ Esconder/Mostrar UI",
    Callback = function()
        local currentVisibility = Rayfield:IsVisible()
        Rayfield:SetVisibility(not currentVisibility)
    end,
})
local KeybindLabel = SettingsTab:CreateLabel("🔑 Tecla para abrir/fechar: K")
SettingsTab:CreateDivider()
local DestroyButton = SettingsTab:CreateButton({
    Name = "🗑️ Destruir GUI",
    Callback = function()
        Rayfield:Notify({
            Title = "Até logo!",
            Content = "GUI será destruída em 2 segundos...",
            Duration = 2,
            Image = "trash-2"
        })
        task.wait(2)
        Rayfield:Destroy()
    end,
})

-- ================= TAB: INFO =================
local InfoTab = Window:CreateTab("ℹ️ Info", "info")
local InfoSection = InfoTab:CreateSection("Sobre o Script")
InfoTab:CreateLabel("📌 TSB Exploit Hub v1.3")  -- Atualizei a versão
InfoTab:CreateLabel("👤 Criado pela TSB Community")
InfoTab:CreateLabel("")
InfoTab:CreateLabel("Funcionalidades:")
InfoTab:CreateLabel("• One Hit Death - Morra em 1 hit")
InfoTab:CreateLabel("• Loop Goto - Teleporte contínuo")
InfoTab:CreateLabel("• Lista de Players - Seleção fácil com DisplayName")
InfoTab:CreateLabel("• Offset Customizável - Controle X/Y/Z")
InfoTab:CreateLabel("• Frequência de Teleporte - Menos lag")
InfoTab:CreateDivider()
local CreditsSection = InfoTab:CreateSection("Créditos")
InfoTab:CreateLabel("🎨 GUI: Rayfield by Sirius")
InfoTab:CreateLabel("💻 Script: TSB Community (Melhorado por IA)")
InfoTab:CreateLabel("⭐ Obrigado por usar!")
InfoTab:CreateDivider()
local DiscordButton = InfoTab:CreateButton({
    Name = "📱 Copiar Discord",
    Callback = function()
        setclipboard("discord.gg/exemplo") -- Mude para seu discord
        Rayfield:Notify({
            Title = "Discord Copiado!",
            Content = "Cole em seu navegador",
            Duration = 3,
            Image = "clipboard"
        })
    end,
})

-- ================= NOTIFICAÇÃO INICIAL =================
Rayfield:Notify({
    Title = "TSB Hub Carregado!",
    Content = "Bem-vindo ao TSB Exploit Hub v1.3 - Melhorado!",
    Duration = 5,
    Image = "check-circle"
})
print("TSB Script carregado com sucesso usando Rayfield!")
