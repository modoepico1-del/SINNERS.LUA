-- ╔══════════════════════════════════════╗
-- ║       DEMONTIME - ILUMINACION        ║
-- ╚══════════════════════════════════════╝

local Lighting = game:GetService("Lighting")
local Players  = game:GetService("Players")

-- ══════════════════════════════════════
--  LIMPIAR EFECTOS ANTERIORES
-- ══════════════════════════════════════

for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("ColorCorrectionEffect")
    or v:IsA("BloomEffect")
    or v:IsA("BlurEffect")
    or v:IsA("SunRaysEffect")
    or v:IsA("DepthOfFieldEffect")
    or v:IsA("Atmosphere")
    or v:IsA("Sky") then
        v:Destroy()
    end
end

-- ══════════════════════════════════════
--  ILUMINACION BASE (mas clara)
-- ══════════════════════════════════════

Lighting.Ambient              = Color3.fromRGB(90, 70, 120)   -- ambiente morado claro visible
Lighting.OutdoorAmbient       = Color3.fromRGB(100, 80, 140)  -- exterior bien iluminado
Lighting.Brightness           = 2.2                            -- brillo alto para ver bien
Lighting.ClockTime            = 14.0                           -- tarde, buena luz natural
Lighting.GeographicLatitude   = 41.7
Lighting.GlobalShadows        = true
Lighting.ShadowSoftness       = 0.4
Lighting.FogEnd               = 1000                           -- niebla lejos para no tapar
Lighting.FogStart             = 500
Lighting.FogColor             = Color3.fromRGB(60, 40, 90)
Lighting.ExposureCompensation = 0.4                            -- mas exposicion = mas claro

-- ══════════════════════════════════════
--  COLOR CORRECTION
-- ══════════════════════════════════════

local CC = Instance.new("ColorCorrectionEffect")
CC.Brightness   =  0.12     -- mas claro general
CC.Contrast     =  0.35     -- contraste moderado
CC.Saturation   =  0.55     -- colores vividos sin pasarse
CC.TintColor    = Color3.fromRGB(220, 200, 255)  -- tinte morado suave
CC.Parent       = Lighting

-- ══════════════════════════════════════
--  BLOOM (neon suave sin cegar)
-- ══════════════════════════════════════

local Bloom = Instance.new("BloomEffect")
Bloom.Intensity = 0.6
Bloom.Size      = 18
Bloom.Threshold = 0.9
Bloom.Parent    = Lighting

-- ══════════════════════════════════════
--  ATMOSFERA (sin niebla densa)
-- ══════════════════════════════════════

local Atmo = Instance.new("Atmosphere")
Atmo.Density = 0.25          -- menos densa para ver mas lejos
Atmo.Offset  = 0.1
Atmo.Color   = Color3.fromRGB(80, 50, 120)   -- morado visible
Atmo.Decay   = Color3.fromRGB(40, 20, 70)
Atmo.Glare   = 0.1
Atmo.Haze    = 0.8           -- menos neblina
Atmo.Parent  = Lighting

-- ══════════════════════════════════════
--  CIELO (tarde con tono morado)
-- ══════════════════════════════════════

local Sky = Instance.new("Sky")
Sky.StarCount            = 1000
Sky.CelestialBodiesShown = true
Sky.Parent               = Lighting

-- ══════════════════════════════════════
--  MENSAJE CONFIRMACION
-- ══════════════════════════════════════

local lp = Players.LocalPlayer
local sg  = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent       = lp.PlayerGui

local lbl = Instance.new("TextLabel")
lbl.Text             = "DEMONTIME iluminacion actualizada"
lbl.Size             = UDim2.new(0, 300, 0, 32)
lbl.Position         = UDim2.new(0.5, -150, 0, 14)
lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
lbl.TextColor3       = Color3.fromRGB(255, 0, 0)
lbl.TextSize         = 13
lbl.Font             = Enum.Font.GothamBlack
lbl.BorderSizePixel  = 0
lbl.Parent           = sg

local lc = Instance.new("UICorner")
lc.CornerRadius = UDim.new(0, 6)
lc.Parent = lbl

local ls = Instance.new("UIStroke")
ls.Color     = Color3.fromRGB(255, 0, 0)
ls.Thickness = 1.2
ls.Parent    = lbl

game:GetService("TweenService"):Create(lbl,
    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 2.5),
    { TextTransparency = 1, BackgroundTransparency = 1 }
):Play()

task.delay(3.2, function() sg:Destroy() end)

print("DEMONTIME | Iluminacion arreglada")
