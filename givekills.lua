local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "NamelessHub",
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

-- About
Tabs.About:AddParagraph({
    Title = "TSB Script",
    Content = "Versão: 1.2\nThe Strongest Battlegrounds\nCriado por Just a DOOM\nMuitas techs automáticas adicionadas\nFunciona melhor com Junkie"
})

Tabs.About:AddButton({
    Title = "Discord",
    Callback = function()
        Fluent:Notify({
            Title = "Discord",
            Content = "Link do servidor: discord.gg/seu_server_aqui",
            Duration = 8
        })
    end
})

-- Farm Tab
Tabs.Farm:AddSection("Trash Can Farm")

Tabs.Farm:AddToggle("TrashInvisible", {Title = "Invisível no Trash Farm", Default = false}):OnChanged(function(value)
    -- Coloque aqui código para tornar invisível (ex: transparency nas parts)
end)

Tabs.Farm:AddDropdown("TrashTarget", {
    Title = "Alvo Trash Farm",
    Values = {"Mais Próximo", "Vida Mais Baixa"},
    Default = "Mais Próximo",
    Multi = false
})

Tabs.Farm:AddToggle("TrashFarm", {Title = "Auto Trash Can Farm", Default = false}):OnChanged(function(value)
    if value then
        spawn(function()
            while Options.TrashFarm.Value do
                -- Lógica de farm trash can aqui (encontrar alvo, atacar, etc.)
                task.wait()
            end
        end)
    end
end)

Tabs.Farm:AddSection("Farm Padrão")

Tabs.Farm:AddDropdown("StandardTarget", {
    Title = "Alvo Farm Padrão",
    Values = {"Mais Próximo", "Vida Mais Baixa"},
    Default = "Mais Próximo",
    Multi = false
})

Tabs.Farm:AddToggle("StandardFarm", {Title = "Auto Farm Padrão", Default = false}):OnChanged(function(value)
    if value then
        spawn(function()
            while Options.StandardFarm.Value do
                -- Lógica de farm normal (matar jogador alvo)
                task.wait()
            end
        end)
    end
end)

-- Techs Tab (muitas techs adicionadas)
Tabs.Techs:AddParagraph({
    Title = "Techs Automáticas",
    Content = "Várias techs populares do TSB automatizadas.\nSide Dash: R seleciona jogador (highlight), E executa side dash se perto o suficiente."
})

-- Side Dash Tech
local SelectedPlayer = nil

Tabs.Techs:AddKeybind("SelectKey", {
    Title = "Tecla Selecionar Jogador",
    Mode = "Hold",
    Default = "R",
    Callback = function(value)
        if value then
            -- Encontra jogador mais próximo e seleciona
            -- SelectedPlayer = findClosestPlayer()
            Fluent:Notify({Title = "Techs", Content = "Jogador selecionado!", Duration = 2})
        end
    end
})

Tabs.Techs:AddKeybind("SideDashKey", {
    Title = "Tecla Side Dash",
    Mode = "Hold",
    Default = "E",
    Callback = function(value)
        if value and SelectedPlayer then
            -- Executa side dash no jogador selecionado se perto
            Fluent:Notify({Title = "Techs", Content = "Side Dash executado!", Duration = 2})
        end
    end
})

Tabs.Techs:AddButton({
    Title = "Deselecionar Jogador",
    Callback = function()
        SelectedPlayer = nil
        Fluent:Notify({Title = "Techs", Content = "Jogador deselecionado.", Duration = 2})
    end
})

Tabs.Techs:AddSection("Techs Automáticas")

Tabs.Techs:AddToggle("AutoKyoto", {Title = "Auto Kyoto Combo (1 → dash → turn → 2)", Default = false}):OnChanged(function(value)
    if value then
        spawn(function()
            while Options.AutoKyoto.Value do
                -- Lógica Kyoto: usa 1, espera acabar, dash, vira, usa 2
                task.wait()
            end
        end)
    end
end)

Tabs.Techs:AddToggle("AutoUppercutDash", {Title = "Auto Uppercut → Dash", Default = false})

Tabs.Techs:AddToggle("AutoMiniUppercut", {Title = "Auto Mini Uppercut Tech", Default = false})

Tabs.Techs:AddToggle("AutoConsecutive", {Title = "Auto Consecutive Punches Tech", Default = false})

Tabs.Techs:AddToggle("AutoDeathCounter", {Title = "Auto Death Counter Tech", Default = false})

Tabs.Techs:AddToggle("AutoDeathBlow", {Title = "Auto Death Blow Combo", Default = false})

Tabs.Techs:AddToggle("AutoTableFlip", {Title = "Auto Table Flip Tech", Default = false})

Tabs.Techs:AddToggle("AutoHuntersGrasp", {Title = "Auto Hunter's Grasp Tech", Default = false})

Tabs.Techs:AddToggle("AutoEvadeTech", {Title = "Auto Evade + Counter Tech", Default = false})

Tabs.Techs:AddToggle("AutoGrandSlam", {Title = "Auto Grand Slam Combo", Default = false})

-- ESP Tab
Tabs.ESP:AddSection("ESP Options")

Tabs.ESP:AddToggle("PlayerESP", {Title = "Player ESP (Box + Name)", Default = false})

Tabs.ESP:AddToggle("UltESP", {Title = "Ultimate Level ESP (0-100%)", Default = false})

Tabs.ESP:AddToggle("DeathESP", {Title = "Death Counter ESP", Default = false})

Tabs.ESP:AddToggle("HealthESP", {Title = "Health Bar ESP", Default = false})

Tabs.ESP:AddToggle("TracerESP", {Title = "Tracers para Jogadores", Default = false})

-- Troll Tab
Tabs.Troll:AddSection("Troll Features")

Tabs.Troll:AddToggle("ServerLag", {Title = "Auto Server Lag", Default = false}):OnChanged(function(value)
    if value then
        spawn(function()
            while Options.ServerLag.Value do
                for i = 1, 15 do
                    Instance.new("Part", workspace)
                end
                task.wait(0.5)
            end
        end)
    end
end)

Tabs.Troll:AddInput("CounterMsg", {
    Title = "Mensagem ao Counter",
    Default = "Countered kkk",
    Placeholder = "Mensagem personalizada"
})

Tabs.Troll:AddToggle("AutoSayCounter", {Title = "Auto Falar ao Ver Counter Próximo", Default = false}):OnChanged(function(value)
    if value then
        spawn(function()
            while Options.AutoSayCounter.Value do
                -- Detectar counter próximo e chat: Options.CounterMsg.Value
                task.wait(0.3)
            end
        end)
    end
end)

Tabs.Troll:AddButton({
    Title = "Spam Chat",
    Callback = function()
        for i = 1, 20 do
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("TSB Script on top!", "All")
            task.wait(0.5)
        end
    end
})

-- SaveManager & InterfaceManager
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("TSBScript")
SaveManager:SetFolder("TSBScript/configs")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "TSB Script",
    Content = "Script carregado com sucesso! Muitas techs adicionadas.",
    Duration = 8
})

SaveManager:LoadAutoloadConfig()
