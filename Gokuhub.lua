-- GOKU BLACK
-- Aimbot + FOV + Speed + Jump
-- LocalScript → StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local AimbotEnabled = false
local FOVEnabled = true
local FOVPercent = 50

local SpeedEnabled = false
local SpeedPercent = 50

local JumpEnabled = false
local JumpPercent = 50

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "GokuBlack"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- MENÚ
local menu = Instance.new("Frame")
menu.Size = UDim2.fromOffset(320, 430)
menu.Position = UDim2.new(0.5, -160, 0.5, -215)
menu.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
menu.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -45, 0, 45)
title.BackgroundTransparency = 1
title.Text = "⚡ GOKU BLACK"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.Parent = menu

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(40, 40)
close.Position = UDim2.new(1, -42, 0, 3)
close.Text = "X"
close.TextSize = 18
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundTransparency = 1
close.Parent = menu

local function makeButton(text, y)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -30, 0, 42)
	b.Position = UDim2.fromOffset(15, y)
	b.Text = text
	b.TextSize = 17
	b.Font = Enum.Font.GothamBold
	b.TextColor3 = Color3.new(1, 1, 1)
	b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
	b.Parent = menu

	return b
end

-- AIMBOT
local aimButton = makeButton("Aimbot: OFF", 55)

-- FOV
local fovButton = makeButton("FOV: ON", 105)

local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(1, -30, 0, 25)
fovLabel.Position = UDim2.fromOffset(15, 150)
fovLabel.BackgroundTransparency = 1
fovLabel.TextColor3 = Color3.new(1, 1, 1)
fovLabel.TextSize = 16
fovLabel.Font = Enum.Font.Gotham
fovLabel.Parent = menu

local fovSlider = Instance.new("TextButton")
fovSlider.Size = UDim2.new(1, -30, 0, 12)
fovSlider.Position = UDim2.fromOffset(15, 180)
fovSlider.Text = ""
fovSlider.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
fovSlider.Parent = menu

-- SPEED
local speedButton = makeButton("Speed: OFF", 210)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -30, 0, 25)
speedLabel.Position = UDim2.fromOffset(15, 255)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.Gotham
speedLabel.Parent = menu

local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(1, -30, 0, 12)
speedSlider.Position = UDim2.fromOffset(15, 285)
speedSlider.Text = ""
speedSlider.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
speedSlider.Parent = menu

-- JUMP
local jumpButton = makeButton("Jump: OFF", 315)

local jumpLabel = Instance.new("TextLabel")
jumpLabel.Size = UDim2.new(1, -30, 0, 25)
jumpLabel.Position = UDim2.fromOffset(15, 360)
jumpLabel.BackgroundTransparency = 1
jumpLabel.TextColor3 = Color3.new(1, 1, 1)
jumpLabel.TextSize = 16
jumpLabel.Font = Enum.Font.Gotham
jumpLabel.Parent = menu

local jumpSlider = Instance.new("TextButton")
jumpSlider.Size = UDim2.new(1, -30, 0, 12)
jumpSlider.Position = UDim2.fromOffset(15, 390)
jumpSlider.Text = ""
jumpSlider.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
jumpSlider.Parent = menu

-- FOV CIRCLE
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Position = UDim2.fromScale(0.5, 0.5)
fovCircle.BackgroundTransparency = 1
fovCircle.Parent = gui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 2
fovStroke.Color = Color3.new(1, 1, 1)
fovStroke.Parent = fovCircle

local function updateFOV()
	local size = 100 + FOVPercent * 4

	fovCircle.Size = UDim2.fromOffset(size, size)
	fovCircle.Visible = FOVEnabled

	fovLabel.Text = "FOV: " .. math.floor(FOVPercent) .. "%"
end

-- BUSCAR JUGADOR
local function getTarget()
	local center = Vector2.new(
		camera.ViewportSize.X / 2,
		camera.ViewportSize.Y / 2
	)

	local radius = 50 + FOVPercent * 2

	local closestHead = nil
	local closestDistance = math.huge

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		if targetPlayer ~= player then

			local character = targetPlayer.Character

			if character then
				local humanoid =
					character:FindFirstChildOfClass("Humanoid")

				local head =
					character:FindFirstChild("Head")

				if humanoid and head and humanoid.Health > 0 then

					local screenPos, visible =
						camera:WorldToViewportPoint(head.Position)

					if visible and screenPos.Z > 0 then

						local pos = Vector2.new(
							screenPos.X,
							screenPos.Y
						)

						local distance =
							(pos - center).Magnitude

						if distance <= radius
							and distance < closestDistance then

							closestDistance = distance
							closestHead = head
						end
					end
				end
			end
		end
	end

	return closestHead
end

-- AIMBOT
local function aimAtTarget()
	if not AimbotEnabled then
		return
	end

	local target = getTarget()

	if target then
		local targetCFrame =
			CFrame.lookAt(
				camera.CFrame.Position,
				target.Position
			)

		camera.CFrame =
			camera.CFrame:Lerp(
				targetCFrame,
				0.25
			)
	end
end

-- SPEED
local function updateSpeed()
	local character = player.Character
	if not character then return end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then return end

	if SpeedEnabled then
		humanoid.WalkSpeed =
			16 + (SpeedPercent / 100) * 84
	else
		humanoid.WalkSpeed = 16
	end
end

-- JUMP
local function updateJump()
	local character = player.Character
	if not character then return end

	local humanoid =
		character:FindFirstChildOfClass("Humanoid")

	if not humanoid then return end

	if JumpEnabled then
		humanoid.JumpPower =
			50 + (JumpPercent / 100) * 100
	else
		humanoid.JumpPower = 50
	end
end

-- BOTONES

aimButton.MouseButton1Click:Connect(function()
	AimbotEnabled = not AimbotEnabled
	aimButton.Text =
		"Aimbot: " ..
		(AimbotEnabled and "ON" or "OFF")
end)

fovButton.MouseButton1Click:Connect(function()
	FOVEnabled = not FOVEnabled

	fovButton.Text =
		"FOV: " ..
		(FOVEnabled and "ON" or "OFF")

	updateFOV()
end)

speedButton.MouseButton1Click:Connect(function()
	SpeedEnabled = not SpeedEnabled

	speedButton.Text =
		"Speed: " ..
		(SpeedEnabled and "ON" or "OFF")

	updateSpeed()
end)

jumpButton.MouseButton1Click:Connect(function()
	JumpEnabled = not JumpEnabled

	jumpButton.Text =
		"Jump: " ..
		(JumpEnabled and "ON" or "OFF")

	updateJump()
end)

-- SLIDERS
local activeSlider = nil

local function setupSlider(slider, callback)
	slider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			activeSlider = slider
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then

			activeSlider = nil
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if activeSlider ~= slider then
			return
		end

		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then

			local x = math.clamp(
				input.Position.X - slider.AbsolutePosition.X,
				0,
				slider.AbsoluteSize.X
			)

			local percent =
				(x / slider.AbsoluteSize.X) * 100

			callback(percent)
		end
	end)
end

setupSlider(fovSlider, function(percent)
	FOVPercent = percent
	updateFOV()
end)

setupSlider(speedSlider, function(percent)
	SpeedPercent = percent
	speedLabel.Text =
		"Speed: " .. math.floor(percent) .. "%"

	updateSpeed()
end)

setupSlider(jumpSlider, function(percent)
	JumpPercent = percent
	jumpLabel.Text =
		"Jump: " .. math.floor(percent) .. "%"

	updateJump()
end)

-- CERRAR
close.MouseButton1Click:Connect(function()
	menu.Visible = false
end)

-- BOTÓN CIRCULAR
local openButton = Instance.new("TextButton")
openButton.Size = UDim2.fromOffset(65, 65)
openButton.Position = UDim2.new(0, 25, 0.5, -30)
openButton.Text = "G"
openButton.TextSize = 30
openButton.Font = Enum.Font.GothamBold
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
openButton.Parent = gui

local openCorner = Instance.new("UICorner")
openCorner.CornerRadius = UDim.new(1, 0)
openCorner.Parent = openButton

openButton.MouseButton1Click:Connect(function()
	menu.Visible = not menu.Visible
end)

-- ACTUALIZAR AL REVIVIR
player.CharacterAdded:Connect(function()
	task.wait(1)
	updateSpeed()
	updateJump()
end)

fovLabel.Text = "FOV: 50%"
speedLabel.Text = "Speed: 50%"
jumpLabel.Text = "Jump: 50%"

updateFOV()

RunService.RenderStepped:Connect(function()
	aimAtTarget()
end)
