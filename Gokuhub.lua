-- CONFIGURACIÓN CENTRAL
local TEXTO_FALSO = "TOMHUBONTOP"
local VELOCIDAD_RGB = 3 -- Entre más alto el número, más rápido cambia de color

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- 1. Forzar nombre en la tabla de clasificación (Leaderboard)
LocalPlayer.DisplayName = TEXTO_FALSO

-- 2. Función para crear el nombre Arcoíris sobre la cabeza
local function aplicarEfectoArcoiris(character)
    if not character then return end
    
    -- Esperar a que carguen las partes esenciales
    local humanoid = character:WaitForChild("Humanoid", 5)
    local head = character:WaitForChild("Head", 5)
    if not humanoid or not head then return end
    
    -- Ocultar el nombre real que Roblox pone por defecto
    humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
    
    -- Eliminar etiqueta falsa anterior si existía (por si reapareces)
    local viejaEtiqueta = head:FindFirstChild("TagArcoirisTomHub")
    if viejaEtiqueta then viejaEtiqueta:Destroy() end
    
    -- Crear la nueva interfaz flotante sobre la cabeza
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TagArcoirisTomHub"
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0) -- Altura sobre la cabeza
    billboard.AlwaysOnTop = true -- Para que se vea siempre perfecto en el clip
    billboard.Parent = head
    
    -- Crear el texto
    local texto = Instance.new("TextLabel")
    texto.Size = UDim2.new(1, 0, 1, 0)
    texto.BackgroundTransparency = 1 -- Fondo invisible
    texto.Text = TEXTO_FALSO
    texto.Font = Enum.Font.GothamBold -- Letra gruesa de estilo moderno
    texto.TextSize = 24
    texto.TextStrokeTransparency = 0 -- Borde negro para que resalte
    texto.TextStrokeColor3 = Color3.new(0, 0, 0)
    texto.Parent = billboard
    
    -- Bucle para el efecto RGB (Arcoíris) continuo
    local deconn
    deconn = RunService.RenderStepped:Connect(function()
        -- Si el personaje es destruido, apagamos este bucle para no causar lag
        if not character or not character:Parent() or not texto then
            deconn:Disconnect()
            return
        end
        -- Cálculo matemático del color basado en el tiempo actual
        local tiempo = tick() * VELOCIDAD_RGB
        texto.TextColor3 = Color3.fromHSV(tiempo % 1, 1, 1)
    end)
end

-- Ejecutar al encender el script
aplicarEfectoArcoiris(LocalPlayer.Character)

-- Asegurar que se vuelva a poner cada vez que mueras o revivas en la partida
LocalPlayer.CharacterAdded:Connect(aplicarEfectoArcoiris)

print("¡Protección visual TOMHUBONTOP activada!")
