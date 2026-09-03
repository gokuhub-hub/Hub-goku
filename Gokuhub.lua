--// GOKU BLACK
--// MENÚ COMPACTO + AIM ASSIST
--// Para tu propio proyecto de Roblox Studio
--// LocalScript → StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--==================================================
-- VARIABLES
--==================================================

local AimbotEnabled = false
local AimSilentEnabled = false

local FOVEnabled = true
local FOVPercent = 50

local AimSilentFOV = 50
local AimSmoothness = 0.25
local AimMaxDistance = 500

-- Objetivo bloqueado.
-- Mientras siga siendo válido, el aimbot no cambia de cabeza.
local LockedTarget = nil

local SpeedEnabled = false
local SpeedPercent = 50

local JumpEnabled = false
local JumpPercent = 50

local InfiniteJumpEnabled = false
local NoclipEnabled = false

--==================================================
-- GUI PRINCIPAL
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "GokuBlackUI"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(500, 350)
main.Position = UDim2.new(0.5, -250, 0.5, -175)
main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = main

--==================================================
-- TÍTULO
--==================================================

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -55, 0, 42)
title.Position = UDim2.fromOffset(12, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ GOKU BLACK"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 19
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

--==================================================
-- BOTÓN X
--==================================================

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.fromOffset(36, 36)
closeButton.Position = UDim2.new(1, -42, 0, 3)
closeButton.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.TextSize = 17
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = main

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

--==================================================
-- SIDEBAR
--==================================================

local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.fromOffset(125, 285)
sidebar.Position = UDim2.fromOffset(10, 50)
sidebar.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sideCorner = Instance.new("UICorner")
sideCorner.CornerRadius = UDim.new(0, 6)
sideCorner.Parent = sidebar

local content = Instance.new("Frame")
content.Size = UDim2.new(1, -150, 1, -60)
content.Position = UDim2.fromOffset(140, 50)
content.BackgroundTransparency = 1
content.Parent = main

local tabs = {}
local pages = {}

--==================================================
-- CREAR PESTAÑA
--==================================================

local function createTab(name, order, locked)

local button = Instance.new("TextButton")  
button.Size = UDim2.new(1, -10, 0, 38)  
button.Position = UDim2.fromOffset(  
	5,  
	5 + ((order - 1) * 43)  
)  

button.BackgroundColor3 = Color3.fromRGB(35, 35, 42)  

button.Text = locked  
	and name .. " 🔒"  
	or name  

button.TextColor3 = locked  
	and Color3.fromRGB(120, 120, 125)  
	or Color3.fromRGB(225, 225, 225)  

button.TextSize = 14  
button.Font = Enum.Font.GothamBold  
button.BorderSizePixel = 0  
button.Parent = sidebar  

local bc = Instance.new("UICorner")  
bc.CornerRadius = UDim.new(0, 5)  
bc.Parent = button  

local page = Instance.new("ScrollingFrame")  
page.Size = UDim2.new(1, 0, 1, 0)  
page.BackgroundTransparency = 1  
page.BorderSizePixel = 0  
page.ScrollBarThickness = 3  
page.Visible = false  
page.CanvasSize = UDim2.new(0, 0, 0, 0)  
page.Parent = content  

local layout = Instance.new("UIListLayout")  
layout.Padding = UDim.new(0, 7)  
layout.Parent = page  

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()  
	page.CanvasSize = UDim2.fromOffset(  
		0,  
		layout.AbsoluteContentSize.Y + 10  
	)  
end)  

tabs[name] = button  
pages[name] = page  

if not locked then  

	button.MouseButton1Click:Connect(function()  

		for _, p in pairs(pages) do  
			p.Visible = false  
		end  

		for _, b in pairs(tabs) do  
			b.BackgroundColor3 =  
				Color3.fromRGB(35, 35, 42)  
		end  

		page.Visible = true  

		button.BackgroundColor3 =  
			Color3.fromRGB(120, 45, 110)  

	end)  

end  

return page

end

--==================================================
-- PESTAÑAS
--==================================================

local GeneralTab =
createTab("General", 1, false)

local CombatTab =
createTab("Combat", 2, false)

local SettingsTab =
createTab("Settings", 3, false)

createTab("Próximamente", 4, true)

--==================================================
-- FUNCIONES GUI
--==================================================

local function createSection(parent, text)

local section = Instance.new("TextLabel")  
section.Size = UDim2.new(1, -5, 0, 25)  
section.BackgroundTransparency = 1  
section.Text = text  
section.TextColor3 = Color3.fromRGB(220, 120, 210)  
section.TextSize = 15  
section.Font = Enum.Font.GothamBold  
section.TextXAlignment = Enum.TextXAlignment.Left  
section.Parent = parent

end

local function createToggle(parent, text, default, callback)

local button = Instance.new("TextButton")  

button.Size = UDim2.new(1, -5, 0, 38)  
button.BackgroundColor3 = Color3.fromRGB(40, 40, 48)  
button.TextColor3 = Color3.new(1, 1, 1)  
button.TextSize = 14  
button.Font = Enum.Font.Gotham  
button.BorderSizePixel = 0  
button.Parent = parent  

local enabled = default  

local function refresh()  

	button.Text =  
		text .. ": " ..  
		(enabled and "ON" or "OFF")  

	if enabled then  
		button.BackgroundColor3 =  
			Color3.fromRGB(100, 45, 95)  
	else  
		button.BackgroundColor3 =  
			Color3.fromRGB(40, 40, 48)  
	end  

end  

button.MouseButton1Click:Connect(function()  

	enabled = not enabled  

	refresh()  

	callback(enabled)  

end)  

refresh()  

return button

end

local function createSlider(parent, text, default, callback)

local container = Instance.new("Frame")  

container.Size =  
	UDim2.new(1, -5, 0, 48)  

container.BackgroundTransparency = 1  
container.Parent = parent  

local label = Instance.new("TextLabel")  

label.Size =  
	UDim2.new(1, 0, 0, 20)  

label.BackgroundTransparency = 1  

label.Text =  
	text .. ": " ..  
	math.floor(default) .. "%"  

label.TextColor3 = Color3.new(1, 1, 1)  
label.TextSize = 13  
label.Font = Enum.Font.Gotham  
label.TextXAlignment = Enum.TextXAlignment.Left  
label.Parent = container  

local slider = Instance.new("TextButton")  

slider.Size =  
	UDim2.new(1, 0, 0, 10)  

slider.Position =  
	UDim2.fromOffset(0, 28)  

slider.Text = ""  

slider.BackgroundColor3 =  
	Color3.fromRGB(65, 65, 75)  

slider.BorderSizePixel = 0  
slider.Parent = container  

local sc = Instance.new("UICorner")  
sc.CornerRadius = UDim.new(1, 0)  
sc.Parent = slider  

local fill = Instance.new("Frame")  

fill.Size =  
	UDim2.new(default / 100, 0, 1, 0)  

fill.BackgroundColor3 =  
	Color3.fromRGB(170, 70, 150)  

fill.BorderSizePixel = 0  
fill.Parent = slider  

local fc = Instance.new("UICorner")  
fc.CornerRadius = UDim.new(1, 0)  
fc.Parent = fill  

local active = false  

local function setValue(x)  

	local percent = math.clamp(  
		(  
			x - slider.AbsolutePosition.X  
		) / slider.AbsoluteSize.X * 100,  
		0,  
		100  
	)  

	fill.Size =  
		UDim2.new(percent / 100, 0, 1, 0)  

	label.Text =  
		text .. ": " ..  
		math.floor(percent) .. "%"  

	callback(percent)  

end  

slider.InputBegan:Connect(function(input)  

	if input.UserInputType ==  
		Enum.UserInputType.MouseButton1  
		or input.UserInputType ==  
		Enum.UserInputType.Touch then  

		active = true  

		setValue(input.Position.X)  

	end  

end)  

UIS.InputChanged:Connect(function(input)  

	if not active then  
		return  
	end  

	if input.UserInputType ==  
		Enum.UserInputType.MouseMovement  
		or input.UserInputType ==  
		Enum.UserInputType.Touch then  

		setValue(input.Position.X)  

	end  

end)  

UIS.InputEnded:Connect(function(input)  

	if input.UserInputType ==  
		Enum.UserInputType.MouseButton1  
		or input.UserInputType ==  
		Enum.UserInputType.Touch then  

		active = false  

	end  

end)

end

--==================================================
-- GENERAL
--==================================================

createSection(GeneralTab, "Movement")

createToggle(
GeneralTab,
"Speed",
false,
function(value)

SpeedEnabled = value  

	local character = player.Character  

	if character then  

		local humanoid =  
			character:FindFirstChildOfClass("Humanoid")  

		if humanoid then  

			humanoid.WalkSpeed =  
				value  
				and 16 + (SpeedPercent / 100) * 84  
				or 16  

		end  
	end  
end

)

createSlider(
GeneralTab,
"Speed",
50,
function(value)

SpeedPercent = value  

	if SpeedEnabled then  

		local character = player.Character  

		if character then  

			local humanoid =  
				character:FindFirstChildOfClass("Humanoid")  

			if humanoid then  

				humanoid.WalkSpeed =  
					16 + (value / 100) * 84  

			end  
		end  
	end  
end

)

createToggle(
GeneralTab,
"Jump",
false,
function(value)

JumpEnabled = value  

	local character = player.Character  

	if character then  

		local humanoid =  
			character:FindFirstChildOfClass("Humanoid")  

		if humanoid then  

			humanoid.JumpPower =  
				value  
				and 50 + (JumpPercent / 100) * 100  
				or 50  

		end  
	end  
end

)

createSlider(
GeneralTab,
"Jump",
50,
function(value)

JumpPercent = value  

	if JumpEnabled then  

		local character = player.Character  

		if character then  

			local humanoid =  
				character:FindFirstChildOfClass("Humanoid")  

			if humanoid then  

				humanoid.JumpPower =  
					50 + (value / 100) * 100  

			end  
		end  
	end  
end

)

--==================================================
-- COMBAT
--==================================================

createSection(CombatTab, "Combat")

-- AIMBOT

createToggle(
CombatTab,
"Aimbot",
false,
function(value)

AimbotEnabled = value  

	-- Al apagarlo, liberamos el objetivo.  
	if not value then  
		LockedTarget = nil  
	end  

end

)

-- FOV

createToggle(
CombatTab,
"FOV",
true,
function(value)

FOVEnabled = value  

end

)

-- FOV %

createSlider(
CombatTab,
"FOV",
50,
function(value)

FOVPercent = value  

end

)

-- AIM SILENT
-- En este proyecto funciona como asistencia de selección
-- de objetivo, sin modificar remotamente disparos.

createToggle(
CombatTab,
"Aim Silent",
false,
function(value)

AimSilentEnabled = value  

	if not value and not AimbotEnabled then  
		LockedTarget = nil  
	end  

end

)

--==================================================
-- SETTINGS
--==================================================

createSection(SettingsTab, "Settings")

createToggle(
SettingsTab,
"Infinite Jump",
false,
function(value)

InfiniteJumpEnabled = value  

end

)

createToggle(
SettingsTab,
"Noclip",
false,
function(value)

NoclipEnabled = value  

end

)

--==================================================
-- CÍRCULO FOV
--==================================================

local fovCircle = Instance.new("Frame")

fovCircle.AnchorPoint =
Vector2.new(0.5, 0.5)

fovCircle.Position =
UDim2.fromScale(0.5, 0.5)

fovCircle.BackgroundTransparency = 1
fovCircle.Parent = gui

local fovCorner = Instance.new("UICorner")

fovCorner.CornerRadius =
UDim.new(1, 0)

fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")

fovStroke.Thickness = 2
fovStroke.Color = Color3.new(1, 1, 1)
fovStroke.Parent = fovCircle

local function updateFOV()

local size =  
	100 + FOVPercent * 4  

fovCircle.Size =  
	UDim2.fromOffset(size, size)  

fovCircle.Visible =  
	FOVEnabled

end

--==================================================
-- LÍNEA DE VISIÓN
--==================================================

local function hasLineOfSight(targetPart)

local origin =  
	camera.CFrame.Position  

local direction =  
	targetPart.Position - origin  

local params =  
	RaycastParams.new()  

params.FilterType =  
	Enum.RaycastFilterType.Exclude  

params.FilterDescendantsInstances = {  
	player.Character  
}  

params.IgnoreWater = true  

local result =  
	workspace:Raycast(  
		origin,  
		direction,  
		params  
	)  

if not result then  
	return true  
end  

return result.Instance:IsDescendantOf(  
	targetPart.Parent  
)

end

--==================================================
-- COMPROBAR SI EL OBJETIVO SIGUE SIENDO VÁLIDO
--==================================================

local function isTargetValid(target)

if not target then  
	return false  
end  

if not target.Parent then  
	return false  
end  

local character =  
	target.Parent  

local humanoid =  
	character:FindFirstChildOfClass("Humanoid")  

if not humanoid then  
	return false  
end  

if humanoid.Health <= 0 then  
	return false  
end  

local distance =  
	(  
		target.Position -  
		camera.CFrame.Position  
	).Magnitude  

if distance > AimMaxDistance then  
	return false  
end  

if not hasLineOfSight(target) then  
	return false  
end  

return true

end

--==================================================
-- BUSCAR NUEVO OBJETIVO
--==================================================

local function findNewTarget()

local center =  
	Vector2.new(  
		camera.ViewportSize.X / 2,  
		camera.ViewportSize.Y / 2  
	)  

local radius =  
	50 + AimSilentFOV * 2  

local closest = nil  
local closestDistance = math.huge  

for _, targetPlayer in  
	ipairs(Players:GetPlayers()) do  

	if targetPlayer == player then  
		continue  
	end  

	local character =  
		targetPlayer.Character  

	if not character then  
		continue  
	end  

	local humanoid =  
		character:FindFirstChildOfClass(  
			"Humanoid"  
		)  

	local head =  
		character:FindFirstChild("Head")  

	if not humanoid or not head then  
		continue  
	end  

	if humanoid.Health <= 0 then  
		continue  
	end  

	local distance3D =  
		(  
			head.Position -  
			camera.CFrame.Position  
		).Magnitude  

	if distance3D > AimMaxDistance then  
		continue  
	end  

	local screenPos, visible =  
		camera:WorldToViewportPoint(  
			head.Position  
		)  

	if not visible or screenPos.Z <= 0 then  
		continue  
	end  

	local screenPoint =  
		Vector2.new(  
			screenPos.X,  
			screenPos.Y  
		)  

	local distanceFromCrosshair =  
		(  
			screenPoint - center  
		).Magnitude  

	if distanceFromCrosshair <= radius then  

		if hasLineOfSight(head) then  

			if distanceFromCrosshair <  
				closestDistance then  

				closestDistance =  
					distanceFromCrosshair  

				closest = head  

			end  

		end  
	end  
end  

return closest

end

--==================================================
-- AIM ASSIST
--==================================================

local function aimAtTarget()

if not AimbotEnabled  
	and not AimSilentEnabled then  

	return  
end  

-- Si ya tenemos objetivo, NO buscamos otro.  
if LockedTarget then  

	if not isTargetValid(LockedTarget) then  
		LockedTarget = nil  
	end  

end  

-- Solamente buscamos uno nuevo cuando  
-- no existe un objetivo bloqueado.  
if not LockedTarget then  
	LockedTarget = findNewTarget()  
end  

if not LockedTarget then  
	return  
end  

-- Vector desde la cámara hasta la cabeza.  
local direction =  
	LockedTarget.Position -  
	camera.CFrame.Position  

-- Si el vector es demasiado pequeño,  
-- evitamos una orientación inválida.  
if direction.Magnitude < 0.001 then  
	return  
end  

local targetCFrame =  
	CFrame.lookAt(  
		camera.CFrame.Position,  
		LockedTarget.Position  
	)  

-- Interpolación:  
-- 0.02 = movimiento muy suave  
-- 1 = movimiento inmediato  
camera.CFrame =  
	camera.CFrame:Lerp(  
		targetCFrame,  
		math.clamp(  
			AimSmoothness,  
			0.02,  
			1  
		)  
	)

end

--==================================================
-- INFINITE JUMP
--==================================================

UIS.JumpRequest:Connect(function()

if not InfiniteJumpEnabled then  
	return  
end  

local character =  
	player.Character  

if character then  

	local humanoid =  
		character:FindFirstChildOfClass(  
			"Humanoid"  
		)  

	if humanoid then  

		humanoid:ChangeState(  
			Enum.HumanoidStateType.Jumping  
		)  

	end  
end

end)

--==================================================
-- NOCLIP
--==================================================

RunService.Stepped:Connect(function()

if not NoclipEnabled then  
	return  
end  

local character =  
	player.Character  

if character then  

	for _, part in  
		ipairs(character:GetDescendants()) do  

		if part:IsA("BasePart") then  
			part.CanCollide = false  
		end  

	end  
end

end)

--==================================================
-- BOTÓN CIRCULAR
--==================================================

local openButton =
Instance.new("TextButton")

openButton.Size =
UDim2.fromOffset(55, 55)

openButton.Position =
UDim2.new(0, 18, 0.5, -27)

openButton.Text = "G"
openButton.TextSize = 25
openButton.Font =
Enum.Font.GothamBold

openButton.TextColor3 =
Color3.new(1, 1, 1)

openButton.BackgroundColor3 =
Color3.fromRGB(100, 45, 95)

openButton.Parent = gui

local openCorner =
Instance.new("UICorner")

openCorner.CornerRadius =
UDim.new(1, 0)

openCorner.Parent =
openButton

openButton.MouseButton1Click:Connect(function()

main.Visible =  
	not main.Visible

end)

--==================================================
-- CERRAR
--==================================================

closeButton.MouseButton1Click:Connect(function()

main.Visible = false

end)

--==================================================
-- RESPAWN
--==================================================

player.CharacterAdded:Connect(function()

-- El objetivo anterior deja de ser válido.  
LockedTarget = nil  

task.wait(1)  

local character =  
	player.Character  

if not character then  
	return  
end  

local humanoid =  
	character:FindFirstChildOfClass(  
		"Humanoid"  
	)  

if humanoid then  

	if SpeedEnabled then  

		humanoid.WalkSpeed =  
			16 +  
			(SpeedPercent / 100) * 84  

	end  

	if JumpEnabled then  

		humanoid.JumpPower =  
			50 +  
			(JumpPercent / 100) * 100  

	end  

end

end)

--==================================================
-- INICIO
--==================================================

pages.General.Visible = true

tabs.General.BackgroundColor3 =
Color3.fromRGB(120, 45, 110)

updateFOV()

RunService.RenderStepped:Connect(function()

aimAtTarget()  
updateFOV()

end) 
