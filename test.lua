--[[
    SCRIPT HUB UNIVERSAL - "SE A MINHA VIDA ALTERAR EU MORRO"
    Feito com WindUI (v1.6+)
    Funciona em QUALQUER jogo do Roblox
    Autor: Grok (para Kerbzinn)
    Como usar: Cole tudo no seu executor (Synapse, Fluxus, Wave, etc.)
]]

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "SE A MINHA VIDA ALTERAR EU MORRO",
    Author = "Universal Hub • Kerbzinn",
    Folder = "VidaAlterarHub",
    Icon = "skull",
    Theme = "Dark",
    Size = UDim2.fromOffset(720, 520),
    MinSize = Vector2.new(600, 400),
    ToggleKey = Enum.KeyCode.RightShift,
    Resizable = true,
    AutoScale = true,
    NewElements = true,
    HideSearchBar = false,
    
    OpenButton = {
        Title = "ABRIR HUB",
        Enabled = true,
        Draggable = true,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromHex("#FF0000")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#8B0000"))
        }
    },
    
    Topbar = {
        Height = 48,
        ButtonsType = "Mac",
    },
})

-- Tag de versão
Window:Tag({
    Title = "v1.0 • UNIVERSAL",
    Icon = "zap",
    Color = Color3.fromHex("#FF0000"),
    Border = true,
})

-- =============================================
-- TAB UNIVERSAL (scripts que funcionam em TODO jogo)
-- =============================================
local UniversalTab = Window:Tab({
    Title = "Universal",
    Icon = "globe",
    Desc = "Scripts que funcionam em QUALQUER jogo"
})

local UniversalSection = UniversalTab:Section({
    Title = "Ferramentas Universais",
})

UniversalSection:Button({
    Title = "Infinite Yield (Admin Commands)",
    Desc = "O famoso IY - comandos poderosos",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        WindUI:Notify({
            Title = "Infinite Yield carregado!",
            Content = "Pressione F9 ou digite ; para abrir",
            Duration = 4,
        })
    end
})

UniversalSection:Button({
    Title = "Dex Explorer (Explorador)",
    Desc = "Veja e edite tudo no jogo",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBX_Scripts/main/Dex%20Explorer.lua"))()
    end
})

UniversalSection:Button({
    Title = "Fly (Voar)",
    Desc = "Ativa/desativa voo simples",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyScript/main/Fly"))()
    end
})

UniversalSection:Button({
    Title = "Speed + Jump Hack",
    Desc = "Aumenta velocidade e pulo",
    Callback = function()
        local plr = game.Players.LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local hum = char:WaitForChild("Humanoid")
        hum.WalkSpeed = 100
        hum.JumpPower = 200
        WindUI:Notify({Title = "Speed ativado!", Content = "WalkSpeed 100 | JumpPower 200", Duration = 3})
    end
})

-- =============================================
-- TAB "SE A MINHA VIDA ALTERAR EU MORRO" (o que você pediu)
-- =============================================
local VidaTab = Window:Tab({
    Title = "Vida Alterar = Morrer",
    Icon = "skull",
    Desc = "Se sua vida mudar... você morre instantaneamente"
})

local VidaSection = VidaTab:Section({
    Title = "Anti-Vida Alterada",
})

local vidaToggle = false
local connection

VidaSection:Toggle({
    Title = "ATIVAR: Se a minha vida alterar eu morro",
    Desc = "Monitora sua vida. Qualquer mudança = morte instantânea",
    Default = false,
    Callback = function(state)
        vidaToggle = state
        local plr = game.Players.LocalPlayer
        
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        if state then
            WindUI:Notify({
                Title = "MODO ATIVADO",
                Content = "Se sua vida alterar... você morre!",
                Duration = 5,
                Type = "Warning"
            })
            
            local lastHealth = 100
            
            connection = game:GetService("RunService").Heartbeat:Connect(function()
                if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                    local hum = plr.Character.Humanoid
                    if hum.Health ~= lastHealth and hum.Health > 0 then
                        -- Vida alterou!
                        hum.Health = 0
                        WindUI:Notify({
                            Title = "VOCÊ MORREU",
                            Content = "Sua vida foi alterada... RIP",
                            Duration = 4,
                            Type = "Error"
                        })
                        connection:Disconnect()
                    end
                    lastHealth = hum.Health
                end
            end)
        end
    end
})

VidaSection:Button({
    Title = "Morrer AGORA (teste)",
    Desc = "Teste o sistema",
    Callback = function()
        local plr = game.Players.LocalPlayer
        if plr.Character and plr.Character:FindFirstChild("Humanoid") then
            plr.Character.Humanoid.Health = 0
        end
    end
})

-- =============================================
-- TAB EXTRA (mais opções)
-- =============================================
local ExtraTab = Window:Tab({
    Title = "Mais Opções",
    Icon = "settings",
})

ExtraTab:Section({Title = "Outros Scripts Universais"}):Button({
    Title = "Noclip",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() -- IY já tem noclip
        print("Noclip disponível no IY")
    end
})

ExtraTab:Section({Title = "Creditos"}):Paragraph({
    Title = "Script Hub Universal",
    Content = "WindUI by Footagesus\nCriado especialmente para você com o tema:\n'Se a minha vida alterar eu morro'\n\nDivirta-se e não deixe ninguém alterar sua vida 🔥"
})

-- Notificação inicial
WindUI:Notify({
    Title = "Hub carregado com sucesso!",
    Content = "Se a minha vida alterar... eu morro.\nPressione RightShift para abrir.",
    Duration = 6,
    Type = "Success"
})

print("✅ Script Hub Universal - Se a Minha Vida Alterar Eu Morro carregado!")
