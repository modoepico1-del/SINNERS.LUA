-- ╔══════════════════════════════════════╗
-- ║    DEMONTIME - ILUMINACION VIVIDA    ║
-- ╚══════════════════════════════════════╝

local Lighting = game:GetService("Lighting")
local Players  = game:GetService("Players")
local TweenService = game:GetService("TweenService")

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
--  ILUMINACION BASE
-- ══════════════════════════════════════

Lighting.Ambient              = Color3.fromRGB(140, 140, 160)  -- ambiente claro neutro
Lighting.OutdoorAmbient       = Color3.fromRGB(160, 160, 180)  -- exterior muy iluminado
Lighting.Brightness           = 3.0                             -- brillo alto = dia despejado
Lighting.ClockTime            = 13.0                            -- mediodia, sol fuerte
Lighting.GeographicLatitude   = 41.7
Lighting.GlobalShadows        = true
Lighting.ShadowSoftness       = 0.2                            -- sombras nitidas
Lighting.FogEnd               = 2000                           -- sin niebla visible
Lighting.FogStart             = 1500
Lighting.FogColor             = Color3.fromRGB(180, 210, 255)  -- niebla azul cielo
Lighting.ExposureCompensation = 0.6                            -- muy expuesto y claro

-- ══════════════════════════════════════
--  COLOR CORRECTION (colores cartoon)
-- ══════════════════════════════════════

local CC = Instance.new("ColorCorrectionEffect")
CC.Brightness   =  0.06     -- ligeramente mas brillante
CC.Contrast     =  0.45     -- contraste medio-alto para que los colores salten
CC.Saturation   =  1.2      -- MUY saturado = colores vividos como en la foto
CC.TintColor    = Color3.fromRGB(255, 252, 245)  -- tinte casi blanco calido
CC.Parent       = Lighting

-- ══════════════════════════════════════
--  BLOOM (brillo en bordes de objetos)
-- ══════════════════════════════════════

local Bloom = Instance.new("BloomEffect")
Bloom.Intensity = 0.4
Bloom.Size      = 14
Bloom.Threshold = 0.95
Bloom.Parent    = Lighting

-- ══════════════════════════════════════
--  ATMOSFERA (cielo azul claro)
-- ══════════════════════════════════════

local Atmo = Instance.new("Atmosphere")
Atmo.Density = 0.15          -- muy poca densidad = aire limpio
Atmo.Offset  = 0.06
Atmo.Color   = Color3.fromRGB(120, 180, 255)   -- azul cielo vivo
Atmo.Decay   = Color3.fromRGB(80, 140, 220)    -- decay azul
Atmo.Glare   = 0.35                            -- un poco de brillo solar
Atmo.Haze    = 0.3                             -- minima neblina
Atmo.Parent  = Lighting

-- ══════════════════════════════════════
--  CIELO AZUL DE DIA
-- ══════════════════════════════════════

local Sky = Instance.new("Sky")
Sky.StarCount            = 0     -- sin estrellas de dia
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
lbl.Text             = "DEMONTIME | Iluminacion activada"
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

TweenService:Create(lbl,
    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 2.5),
    { TextTransparency = 1, BackgroundTransparency = 1 }
):Play()

task.delay(3.2, function() sg:Destroy() end)

print("DEMONTIME | Iluminacion vivida cargada")
