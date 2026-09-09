--// SORU / FLASHSTEP TARGET ASSIST
--// Target modes: Players / NPCs / Both
--// Roblox Studio LocalScript - StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

--// SETTINGS
local MAX_RANGE = 45
local TELEPORT_DISTANCE = 3
local COOLDOWN = 1.2

--// TARGET MODE
local TargetMode = "Players"
-- "Players", "NPCs", or "Both"

local Character
local Root
local OnCooldown = false

local function updateCharacter()
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Root = Character:WaitForChild("HumanoidRootPart")
end

updateCharacter()

LocalPlayer.CharacterAdded:Connect(function()
	task.wait()
	updateCharacter()
end)

--------------------------------------------------
-- TARGET CHECK
--------------------------------------------------

local function isPlayerCharacter(model)
	return Players:GetPlayerFromCharacter(model) ~= nil
end

local function isValidTarget(model)
	if not model:IsA("Model") or model == Character then
		return false
	end

	local humanoid = model:FindFirstChildOfClass("Humanoid")
	local targetRoot = model:FindFirstChild("HumanoidRootPart")

	if not humanoid or not targetRoot or humanoid.Health <= 0 then
		return false
	end

	local playerCharacter = isPlayerCharacter(model)

	if TargetMode == "Players" then
		return playerCharacter
	elseif TargetMode == "NPCs" then
		return not playerCharacter
	elseif TargetMode == "Both" then
		return true
	end

	return false
end

--------------------------------------------------
-- FIND CLOSEST TARGET
--------------------------------------------------

local function getClosestTarget()
	if not Root then
		return nil
	end

	local closestTarget = nil
	local closestDistance = MAX_RANGE

	for _, model in ipairs(workspace:GetDescendants()) do
		if isValidTarget(model) then

			local targetRoot = model:FindFirstChild("HumanoidRootPart")

			if targetRoot then
				local distance =
					(targetRoot.Position - Root.Position).Magnitude

				if distance < closestDistance then
					closestDistance = distance
					closestTarget = targetRoot
				end
			end
		end
	end

	return closestTarget
end

--------------------------------------------------
-- SORU
--------------------------------------------------

local function Soru()
	if OnCooldown or not Root then
		return
	end

	local target = getClosestTarget()

	if not target then
		return
	end

	OnCooldown = true

	--// Save transparency
	local oldTransparency = {}

	for _, object in ipairs(Character:GetDescendants()) do
		if object:IsA("BasePart") then
			oldTransparency[object] = object.Transparency
			object.Transparency =
				math.clamp(object.Transparency + 0.6, 0, 1)
		end
	end

	--// Teleport slightly behind target
	local destination =
		target.Position - target.CFrame.LookVector * TELEPORT_DISTANCE

	Root.CFrame = CFrame.lookAt(
		destination,
		target.Position
	)

	--// Restore character
	task.delay(0.08, function()
		for part, transparency in pairs(oldTransparency) do
			if part and part.Parent then
				part.Transparency = transparency
			end
		end
	end)

	task.delay(COOLDOWN, function()
		OnCooldown = false
	end)
end

--------------------------------------------------
-- MOBILE UI
--------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "SoruMobileUI"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

--// Soru button
local soruButton = Instance.new("TextButton")
soruButton.Name = "SoruButton"
soruButton.Size = UDim2.fromOffset(85, 85)
soruButton.Position = UDim2.new(1, -115, 1, -180)
soruButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
soruButton.TextColor3 = Color3.fromRGB(255, 255, 255)
soruButton.Text = "SORU"
soruButton.TextSize = 20
soruButton.Font = Enum.Font.GothamBold
soruButton.Parent = gui

local soruCorner = Instance.new("UICorner")
soruCorner.CornerRadius = UDim.new(1, 0)
soruCorner.Parent = soruButton

local soruStroke = Instance.new("UIStroke")
soruStroke.Color = Color3.fromRGB(255, 255, 255)
soruStroke.Thickness = 2
soruStroke.Parent = soruButton

soruButton.Activated:Connect(function()
	Soru()
end)

--------------------------------------------------
-- TARGET MODE BUTTON
--------------------------------------------------

local modeButton = Instance.new("TextButton")
modeButton.Name = "TargetMode"
modeButton.Size = UDim2.fromOffset(130, 42)
modeButton.Position = UDim2.new(1, -160, 1, -235)
modeButton.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
modeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
modeButton.Text = "TARGET: PLAYERS"
modeButton.TextSize = 14
modeButton.Font = Enum.Font.GothamBold
modeButton.Parent = gui

local modeCorner = Instance.new("UICorner")
modeCorner.CornerRadius = UDim.new(0, 10)
modeCorner.Parent = modeButton

local modeStroke = Instance.new("UIStroke")
modeStroke.Color = Color3.fromRGB(255, 255, 255)
modeStroke.Thickness = 1.5
modeStroke.Parent = modeButton

--------------------------------------------------
-- CYCLE TARGET MODE
--------------------------------------------------

modeButton.Activated:Connect(function()

	if TargetMode == "Players" then

		TargetMode = "NPCs"
		modeButton.Text = "TARGET: NPCS"

	elseif TargetMode == "NPCs" then

		TargetMode = "Both"
		modeButton.Text = "TARGET: BOTH"

	else

		TargetMode = "Players"
		modeButton.Text = "TARGET: PLAYERS"

	end

end)

--------------------------------------------------
-- PC TEST KEY
--------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)

	if processed then
		return
	end

	if input.KeyCode == Enum.KeyCode.Q then
		Soru()
	end

end)
