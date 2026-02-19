-- Brookhaven Admin HD - Fluent UI (Tamanho, Velocidade, Pulo)
-- Cole direto no executor

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Brookhaven Admin HD",
    SubTitle = "Tamanho • Velocidade • Pulo",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,          -- Blur (pode ser detectável em alguns jogos, mude pra false se precisar)
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Principal", Icon = "rocket" }),
    Settings = Window:AddTab({ Title = "Configurações", Icon = "settings" })
}

local Options = Fluent.Options

-- =============================================
--          FUNÇÕES DE APLICAÇÃO
-- =============================================

local function applyCharacterChanges()
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("Humanoid") then return end
    
    local hum = char.Humanoid
    
    -- Velocidade
    local speed = Options.WalkSpeed.Value
    hum.WalkSpeed = speed
    
    -- Pulo
    local jump = Options.JumpPower.Value
    hum.JumpPower = jump
    
    -- Tamanho (escala FE)
    local scale = Options.SizeScale.Value
    
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.Size = v.Size * scale  -- multiplica tamanho atual
        elseif v:IsA("Accessory") then
            local handle = v:FindFirstChild("Handle")
            if handle then handle.Size = handle.Size * scale end
        end
    end
    
    -- Ajusta Humanoid scales (mais natural)
    local scales = {"BodyHeightScale", "BodyDepthScale", "BodyWidthScale", "HeadScale"}
    for _, name in ipairs(scales) do
        local s = hum:FindFirstChild(name)
        if s then s.Value = scale end
    end
    
    Fluent:Notify({
        Title = "Aplicado!",
        Content = "Vel: " .. speed .. " | Jump: " .. jump .. " | Size: x" .. scale,
        Duration = 4
    })
end

local function resetToDefault()
    Options.WalkSpeed:SetValue(16)
    Options.JumpPower:SetValue(50)
    Options.SizeScale:SetValue(1)
    applyCharacterChanges()
end

-- =============================================
--               INTERFACE
-- =============================================

Tabs.Main:AddParagraph({
    Title = "Brookhaven Admin HD",
    Content = "Controle seu tamanho, velocidade e pulo.\nClique em 'Aplicar' ou use os atalhos."
})

Tabs.Main:AddSlider("WalkSpeed", {
    Title = "Velocidade (WalkSpeed)",
    Description = "Padrão: 16 | Máx recomendado: 200–500",
    Default = 16,
    Min = 0,
    Max = 500,
    Rounding = 0,
    Callback = function(v)
        -- Aplica em tempo real se quiser (opcional)
        -- local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        -- if hum then hum.WalkSpeed = v end
    end
})

Tabs.Main:AddSlider("JumpPower", {
    Title = "Pulo (JumpPower)",
    Description = "Padrão: 50 | Valores altos = pulos insanos",
    Default = 50,
    Min = 0,
    Max = 1000,
    Rounding = 0
})

Tabs.Main:AddSlider("SizeScale", {
    Title = "Tamanho (Scale)",
    Description = "1 = normal | <1 pequeno | >1 gigante",
    Default = 1,
    Min = 0.1,
    Max = 10,
    Rounding = 2
})

Tabs.Main:AddButton({
    Title = "Aplicar Mudanças",
    Description = "Aplica velocidade, pulo e tamanho",
    Callback = applyCharacterChanges
})

Tabs.Main:AddButton({
    Title = "Resetar Tudo",
    Description = "Volta para valores padrão",
    Callback = resetToDefault
})

-- Hotkeys rápidos
local toggleGui = Tabs.Main:AddKeybind("ToggleGUI", {
    Title = "Toggle Interface",
    Mode = "Toggle",
    Default = "F"
})

toggleGui:OnClick(function()
    Window:Minimize()  -- ou Window:Toggle() dependendo da versão
end)

-- Auto-aplicar quando respawn (útil)
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1.5)
    applyCharacterChanges()
end)

-- =============================================
--             SAVE / INTERFACE MANAGER
-- =============================================

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:SetFolder("FluentHub")
SaveManager:SetFolder("FluentHub/Brookhaven")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Brookhaven Admin HD",
    Content = "Carregado! Use os sliders e clique Aplicar.\nF = toggle janela",
    Duration = 6
})

SaveManager:LoadAutoloadConfig()
