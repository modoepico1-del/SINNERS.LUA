-- ========================================
--         DEMONTIME - Roblox Script
--       Script de habilidades demoníacas
-- ========================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera

-- ========================================
--            CONFIGURACIÓN
-- ========================================

local CONFIG = {
    -- Modo Demonio
    DEMON_SPEED       = 28,       -- Velocidad en modo demonio
    NORMAL_SPEED      = 16,       -- Velocidad normal
    DEMON_JUMP        = 70,       -- Poder de salto en modo demonio
    NORMAL_JUMP       = 50,       -- Salto normal
    DEMON_DURATION    = 15,       -- Duración en segundos del modo demonio
    DEMON_COOLDOWN    = 30,       -- Cooldown en segundos

    -- Dash / Embestida
    DASH_POWER        = 120,      -- Fuerza del dash
    DASH_COOLDOWN     = 3,        -- Cooldown del dash (segundos)

    -- Aura de fuego
    AURA_ENABLED      = true,
    AURA_COLOR        = Color3.fromRGB(180, 0, 255),   -- Morado demoníaco
    AURA_FIRE_COLOR   = Color3.fromRGB(255, 50, 0),    -- Naranja/rojo

    -- Teclas
    KEY_DEMON_MODE    = Enum.KeyCode.E,
    KEY_DASH          = Enum.KeyCode.Q,
    KEY_SHOCKWAVE     = Enum.KeyCode.F,

    -- Shockwave
    SHOCKWAVE_RADIUS  = 20,
    SHOCKWAVE_FORCE   = 80,
    SHOCKWAVE_COOLDOWN = 8,
}

-- ========================================
--              ESTADO
-- ========================================

local State = {
    isDemonMode   = false,
    demonTimer    = 0,
    demonCooldown = 0,
    dashCooldown  = 0,
    shockwaveCooldown = 0,
    auraParticles = {},
}

-- ========================================
--           FUNCIONES DE UI
-- ========================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DemonTimeUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player.PlayerGui

-- Panel principal
local panel = Instance.new("Frame")
panel.Size = UDim2.new(0, 220, 0, 130)
panel.Position = UDim2.new(0, 20, 0.5, -65)
panel.BackgroundColor3 = Color3.fromRGB(15, 5, 25)
panel.BackgroundTransparency = 0.3
panel.BorderSizePixel = 0
panel.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local stroke = Instance.new("UIStroke")
stroke.Color = CONFIG.AURA_COLOR
stroke.Thickness = 2
stroke.Parent = panel

-- Título
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "👿 DEMON TIME"
title.TextColor3 = CONFIG.AURA_COLOR
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = panel

-- Barra de modo demonio
local demonLabel = Instance.new("TextLabel")
demonLabel.Size = UDim2.new(1, -20, 0, 18)
demonLabel.Position = UDim2.new(0, 10, 0, 35)
demonLabel.BackgroundTransparency = 1
demonLabel.Text = "[E] Modo Demonio: LISTO"
demonLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
demonLabel.TextScaled = true
demonLabel.Font = Enum.Font.Gotham
demonLabel.TextXAlignment = Enum.TextXAlignment.Left
demonLabel.Parent = panel

local demonBar = Instance.new("Frame")
demonBar.Size = UDim2.new(0.95, 0, 0, 8)
demonBar.Position = UDim2.new(0.025, 0, 0, 56)
demonBar.BackgroundColor3 = CONFIG.AURA_COLOR
demonBar.BorderSizePixel = 0
demonBar.Parent = panel
Instance.new("UICorner").Parent = demonBar

-- Barra de dash
local dashLabel = Instance.new("TextLabel")
dashLabel.Size = UDim2.new(1, -20, 0, 18)
dashLabel.Position = UDim2.new(0, 10, 0, 68)
dashLabel.BackgroundTransparency = 1
dashLabel.Text = "[Q] Dash: LISTO"
dashLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
dashLabel.TextScaled = true
dashLabel.Font = Enum.Font.Gotham
dashLabel.TextXAlignment = Enum.TextXAlignment.Left
dashLabel.Parent = panel

local dashBar = Instance.new("Frame")
dashBar.Size = UDim2.new(0.95, 0, 0, 8)
dashBar.Position = UDim2.new(0.025, 0, 0, 89)
dashBar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
dashBar.BorderSizePixel = 0
dashBar.Parent = panel
Instance.new("UICorner").Parent = dashBar

-- Shockwave label
local shockLabel = Instance.new("TextLabel")
shockLabel.Size = UDim2.new(1, -20, 0, 18)
shockLabel.Position = UDim2.new(0, 10, 0, 103)
shockLabel.BackgroundTransparency = 1
shockLabel.Text = "[F] Shockwave: LISTO"
shockLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
shockLabel.TextScaled = true
shockLabel.Font = Enum.Font.Gotham
shockLabel.TextXAlignment = Enum.TextXAlignment.Left
shockLabel.Parent = panel

-- ========================================
--        EFECTOS VISUALES
-- ========================================

local function createAura(part)
    -- Fuego demoníaco
    local fire = Instance.new("Fire")
    fire.Color = CONFIG.AURA_FIRE_COLOR
    fire.SecondaryColor = CONFIG.AURA_COLOR
    fire.Size = 3
    fire.Heat = 8
    fire.Parent = part
    table.insert(State.auraParticles, fire)

    -- Partículas adicionales
    local attachment = Instance.new("Attachment")
    attachment.Parent = part

    local sparkles = Instance.new("Sparkles")
    sparkles.SparkleColor = CONFIG.AURA_COLOR
    sparkles.Parent = part
    table.insert(State.auraParticles, sparkles)

    return fire, sparkles
end

local function removeAura()
    for _, effect in ipairs(State.auraParticles) do
        if effect and effect.Parent then
            effect:Destroy()
        end
    end
    State.auraParticles = {}
end

local function flashScreen(color, duration)
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = color
    flash.BackgroundTransparency = 0.4
    flash.BorderSizePixel = 0
    flash.ZIndex = 10
    flash.Parent = screenGui

    TweenService:Create(flash, TweenInfo.new(duration), {
        BackgroundTransparency = 1
    }):Play()

    game:GetService("Debris"):AddItem(flash, duration + 0.1)
end

local function changeAtmosphere(isDemon)
    if isDemon then
        TweenService:Create(Lighting, TweenInfo.new(1), {
            Ambient = Color3.fromRGB(80, 0, 80),
            OutdoorAmbient = Color3.fromRGB(100, 20, 20),
            Brightness = 0.5,
        }):Play()
    else
        TweenService:Create(Lighting, TweenInfo.new(1.5), {
            Ambient = Color3.fromRGB(70, 70, 70),
            OutdoorAmbient = Color3.fromRGB(127, 127, 127),
            Brightness = 2,
        }):Play()
    end
end

-- ========================================
--          MODO DEMONIO
-- ========================================

local function activateDemonMode()
    if State.isDemonMode or State.demonCooldown > 0 then return end

    State.isDemonMode = true
    State.demonTimer = CONFIG.DEMON_DURATION

    -- Estadísticas
    humanoid.WalkSpeed = CONFIG.DEMON_SPEED
    humanoid.JumpPower = CONFIG.DEMON_JUMP

    -- Efectos
    createAura(rootPart)
    flashScreen(CONFIG.AURA_COLOR, 0.5)
    changeAtmosphere(true)

    -- Color del personaje
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            TweenService:Create(part, TweenInfo.new(0.5), {
                Color = Color3.fromRGB(60, 0, 80)
            }):Play()
        end
    end

    title.Text = "😈 DEMON TIME ACTIVO"
    title.TextColor3 = CONFIG.AURA_FIRE_COLOR
    stroke.Color = CONFIG.AURA_FIRE_COLOR

    print("[DemonTime] ¡MODO DEMONIO ACTIVADO!")
end

local function deactivateDemonMode()
    State.isDemonMode = false
    State.demonCooldown = CONFIG.DEMON_COOLDOWN

    -- Estadísticas normales
    humanoid.WalkSpeed = CONFIG.NORMAL_SPEED
    humanoid.JumpPower = CONFIG.NORMAL_JUMP

    -- Quitar efectos
    removeAura()
    changeAtmosphere(false)

    -- Restaurar color
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            TweenService:Create(part, TweenInfo.new(0.5), {
                Color = Color3.fromRGB(163, 162, 165)
            }):Play()
        end
    end

    title.Text = "👿 DEMON TIME"
    title.TextColor3 = CONFIG.AURA_COLOR
    stroke.Color = CONFIG.AURA_COLOR

    print("[DemonTime] Modo demonio desactivado. Cooldown: " .. CONFIG.DEMON_COOLDOWN .. "s")
end

-- ========================================
--              DASH
-- ========================================

local function performDash()
    if State.dashCooldown > 0 then return end

    State.dashCooldown = CONFIG.DASH_COOLDOWN

    local direction = humanoid.MoveDirection
    if direction.Magnitude == 0 then
        direction = rootPart.CFrame.LookVector
    end

    -- Aplicar fuerza
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = direction * CONFIG.DASH_POWER
    bodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)
    bodyVelocity.Parent = rootPart

    -- Efecto visual de dash
    local dashTrail = Instance.new("SelectionBox")
    dashTrail.Adornee = rootPart
    dashTrail.Color3 = CONFIG.AURA_COLOR
    dashTrail.SurfaceTransparency = 0.8
    dashTrail.Parent = workspace

    flashScreen(Color3.fromRGB(150, 0, 255), 0.2)

    -- Limpiar
    game:GetService("Debris"):AddItem(bodyVelocity, 0.15)
    game:GetService("Debris"):AddItem(dashTrail, 0.3)

    print("[DemonTime] ¡DASH!")
end

-- ========================================
--            SHOCKWAVE
-- ========================================

local function performShockwave()
    if State.shockwaveCooldown > 0 then return end
    if not State.isDemonMode then
        print("[DemonTime] Necesitas el modo demonio para usar Shockwave")
        return
    end

    State.shockwaveCooldown = CONFIG.SHOCKWAVE_COOLDOWN

    local origin = rootPart.Position

    -- Onda visual expansiva
    local wave = Instance.new("Part")
    wave.Shape = Enum.PartType.Cylinder
    wave.Size = Vector3.new(1, CONFIG.SHOCKWAVE_RADIUS * 2, CONFIG.SHOCKWAVE_RADIUS * 2)
    wave.CFrame = CFrame.new(origin) * CFrame.Angles(0, 0, math.pi / 2)
    wave.Anchored = true
    wave.CanCollide = false
    wave.Material = Enum.Material.Neon
    wave.Color = CONFIG.AURA_COLOR
    wave.Transparency = 0.3
    wave.Parent = workspace

    TweenService:Create(wave, TweenInfo.new(0.6), {
        Size = Vector3.new(1, CONFIG.SHOCKWAVE_RADIUS * 2, CONFIG.SHOCKWAVE_RADIUS * 2),
        Transparency = 1,
        Color = CONFIG.AURA_FIRE_COLOR,
    }):Play()

    game:GetService("Debris"):AddItem(wave, 0.7)

    -- Empujar jugadores cercanos
    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherRoot then
                local dist = (otherRoot.Position - origin).Magnitude
                if dist <= CONFIG.SHOCKWAVE_RADIUS then
                    local direction = (otherRoot.Position - origin).Unit
                    local bv = Instance.new("BodyVelocity")
                    bv.Velocity = direction * CONFIG.SHOCKWAVE_FORCE
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bv.Parent = otherRoot
                    game:GetService("Debris"):AddItem(bv, 0.3)
                end
            end
        end
    end

    flashScreen(CONFIG.AURA_FIRE_COLOR, 0.3)
    print("[DemonTime] ¡SHOCKWAVE lanzado!")
end

-- ========================================
--         INPUT (TECLAS)
-- ========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == CONFIG.KEY_DEMON_MODE then
        if not State.isDemonMode then
            activateDemonMode()
        end

    elseif input.KeyCode == CONFIG.KEY_DASH then
        performDash()

    elseif input.KeyCode == CONFIG.KEY_SHOCKWAVE then
        performShockwave()
    end
end)

-- ========================================
--           LOOP PRINCIPAL
-- ========================================

RunService.Heartbeat:Connect(function(dt)
    -- Timer del modo demonio
    if State.isDemonMode then
        State.demonTimer = State.demonTimer - dt
        local progress = math.clamp(State.demonTimer / CONFIG.DEMON_DURATION, 0, 1)
        demonBar.Size = UDim2.new(0.95 * progress, 0, 0, 8)
        demonLabel.Text = string.format("[E] Demonio: %.1fs", State.demonTimer)

        if State.demonTimer <= 0 then
            deactivateDemonMode()
        end
    else
        -- Cooldown del modo demonio
        if State.demonCooldown > 0 then
            State.demonCooldown = State.demonCooldown - dt
            local progress = math.clamp(1 - (State.demonCooldown / CONFIG.DEMON_COOLDOWN), 0, 1)
            demonBar.Size = UDim2.new(0.95 * progress, 0, 0, 8)
            demonBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            demonLabel.Text = string.format("[E] Cooldown: %.1fs", math.max(0, State.demonCooldown))
        else
            demonBar.Size = UDim2.new(0.95, 0, 0, 8)
            demonBar.BackgroundColor3 = CONFIG.AURA_COLOR
            demonLabel.Text = "[E] Modo Demonio: LISTO"
        end
    end

    -- Cooldown del dash
    if State.dashCooldown > 0 then
        State.dashCooldown = State.dashCooldown - dt
        local progress = math.clamp(1 - (State.dashCooldown / CONFIG.DASH_COOLDOWN), 0, 1)
        dashBar.Size = UDim2.new(0.95 * progress, 0, 0, 8)
        dashBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        dashLabel.Text = string.format("[Q] Dash: %.1fs", math.max(0, State.dashCooldown))
    else
        dashBar.Size = UDim2.new(0.95, 0, 0, 8)
        dashBar.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        dashLabel.Text = "[Q] Dash: LISTO"
    end

    -- Cooldown del shockwave
    if State.shockwaveCooldown > 0 then
        State.shockwaveCooldown = State.shockwaveCooldown - dt
        shockLabel.Text = string.format("[F] Shockwave: %.1fs", math.max(0, State.shockwaveCooldown))
        shockLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
    else
        shockLabel.Text = "[F] Shockwave: LISTO"
        shockLabel.TextColor3 = State.isDemonMode 
            and Color3.fromRGB(255, 100, 0) 
            or Color3.fromRGB(130, 130, 130)
    end
end)

-- ========================================
--        RESET AL MORIR
-- ========================================

humanoid.Died:Connect(function()
    removeAura()
    State.isDemonMode = false
    State.demonCooldown = 0
    changeAtmosphere(false)
end)

player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    State.isDemonMode = false
    State.demonCooldown = 0
    State.dashCooldown = 0
    State.shockwaveCooldown = 0
    State.auraParticles = {}
    print("[DemonTime] Personaje respawneado.")
end)

-- ========================================
print("========================================")
print("   DEMONTIME cargado correctamente")
print("   [E] Activar Modo Demonio")
print("   [Q] Dash")
print("   [F] Shockwave (requiere modo demonio)")
print("========================================")
