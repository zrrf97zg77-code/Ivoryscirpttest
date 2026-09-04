-- ============================================================
-- IVORY AIMBOT v2.0 | RELIABLE SILENT AIM FOR BLOX FRUITS
-- ============================================================
-- Features:
-- • Silent aim for all abilities (Z/X/C/V/F) and M1
-- • FOV slider with on-screen circle (if Drawing supported)
-- • Target line from screen center to target (if Drawing supported)
-- • Team check, distance limit, FOV limit
-- • Toggle with F5 key
-- ============================================================

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Check Drawing support
local hasDrawing = pcall(function() return Drawing.new("Circle") end)

-- Configuration
local aimbotEnabled = false
local fovRadius = 150
local maxDistance = 3500
local targetPartName = "HumanoidRootPart"  -- can be "Head" or "HumanoidRootPart"
local teamCheck = true
local showLine = true
local showFOV = true

-- Target and visuals
local currentTarget = nil
local FOVCircle = nil
local TargetLine = nil

-- Create drawing objects if available
if hasDrawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.fromRGB(255, 50, 50)
    FOVCircle.Radius = fovRadius
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1

    TargetLine = Drawing.new("Line")
    TargetLine.Visible = false
    TargetLine.Color = Color3.fromRGB(0, 255, 100)
    TargetLine.Thickness = 1.5
    TargetLine.Transparency = 0.7
end

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IvoryAimbotGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 220, 0, 150)
mainFrame.Position = UDim2.new(0.5, -110, 0.2, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "IVORY AIMBOT v2"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 14

-- Toggle
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0.45, -5, 0, 25)
toggleBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

-- FOV Slider label
local fovLabel = Instance.new("TextLabel", mainFrame)
fovLabel.Size = UDim2.new(0.45, 0, 0, 20)
fovLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: " .. fovRadius
fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fovLabel.Font = Enum.Font.GothamBold
fovLabel.TextSize = 10
fovLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Slider controls
local sliderFrame = Instance.new("Frame", mainFrame)
sliderFrame.Size = UDim2.new(0.45, 0, 0, 20)
sliderFrame.Position = UDim2.new(0.55, 0, 0.6, 0)
sliderFrame.BackgroundTransparency = 1

local minusBtn = Instance.new("TextButton", sliderFrame)
minusBtn.Size = UDim2.new(0.25, 0, 1, 0)
minusBtn.Position = UDim2.new(0, 0, 0, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
minusBtn.Text = "-"
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 14
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 4)

local valLabel = Instance.new("TextLabel", sliderFrame)
valLabel.Size = UDim2.new(0.5, 0, 1, 0)
valLabel.Position = UDim2.new(0.25, 0, 0, 0)
valLabel.BackgroundTransparency = 1
valLabel.Text = tostring(fovRadius)
valLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
valLabel.Font = Enum.Font.GothamBold
valLabel.TextSize = 12
valLabel.TextXAlignment = Enum.TextXAlignment.Center

local plusBtn = Instance.new("TextButton", sliderFrame)
plusBtn.Size = UDim2.new(0.25, 0, 1, 0)
plusBtn.Position = UDim2.new(0.75, 0, 0, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 14
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 4)

-- Toggle line
local lineToggleBtn = Instance.new("TextButton", mainFrame)
lineToggleBtn.Size = UDim2.new(0.45, -5, 0, 20)
lineToggleBtn.Position = UDim2.new(0.05, 0, 0.85, 0)
lineToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
lineToggleBtn.Text = "LINE: ON"
lineToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lineToggleBtn.Font = Enum.Font.GothamBold
lineToggleBtn.TextSize = 10
Instance.new("UICorner", lineToggleBtn).CornerRadius = UDim.new(0, 4)

-- Toggle FOV circle
local fovToggleBtn = Instance.new("TextButton", mainFrame)
fovToggleBtn.Size = UDim2.new(0.45, -5, 0, 20)
fovToggleBtn.Position = UDim2.new(0.55, 0, 0.85, 0)
fovToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
fovToggleBtn.Text = "FOV: ON"
fovToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fovToggleBtn.Font = Enum.Font.GothamBold
fovToggleBtn.TextSize = 10
Instance.new("UICorner", fovToggleBtn).CornerRadius = UDim.new(0, 4)

-- Button functions
toggleBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    toggleBtn.Text = aimbotEnabled and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 50, 60)
    if FOVCircle then FOVCircle.Visible = (aimbotEnabled and showFOV) end
    if TargetLine then TargetLine.Visible = (aimbotEnabled and showLine) end
end)

minusBtn.MouseButton1Click:Connect(function()
    fovRadius = math.max(20, fovRadius - 5)
    valLabel.Text = tostring(fovRadius)
    if FOVCircle then FOVCircle.Radius = fovRadius end
    fovLabel.Text = "FOV: " .. fovRadius
end)

plusBtn.MouseButton1Click:Connect(function()
    fovRadius = math.min(400, fovRadius + 5)
    valLabel.Text = tostring(fovRadius)
    if FOVCircle then FOVCircle.Radius = fovRadius end
    fovLabel.Text = "FOV: " .. fovRadius
end)

lineToggleBtn.MouseButton1Click:Connect(function()
    showLine = not showLine
    lineToggleBtn.Text = showLine and "LINE: ON" or "LINE: OFF"
    lineToggleBtn.BackgroundColor3 = showLine and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 50, 60)
    if TargetLine then TargetLine.Visible = (aimbotEnabled and showLine) end
end)

fovToggleBtn.MouseButton1Click:Connect(function()
    showFOV = not showFOV
    fovToggleBtn.Text = showFOV and "FOV: ON" or "FOV: OFF"
    fovToggleBtn.BackgroundColor3 = showFOV and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 50, 60)
    if FOVCircle then FOVCircle.Visible = (aimbotEnabled and showFOV) end
end)

-- Update visuals each frame
RunService.RenderStepped:Connect(function()
    if not camera then return end
    if hasDrawing then
        -- FOV circle
        if FOVCircle and aimbotEnabled and showFOV then
            FOVCircle.Visible = true
            local viewport = camera.ViewportSize
            FOVCircle.Position = Vector2.new(viewport.X/2, viewport.Y/2)
        elseif FOVCircle then
            FOVCircle.Visible = false
        end

        -- Target line
        if TargetLine and aimbotEnabled and showLine and currentTarget then
            local screenPos, onScreen = camera:WorldToViewportPoint(currentTarget.Position)
            if onScreen then
                local viewport = camera.ViewportSize
                local center = Vector2.new(viewport.X/2, viewport.Y/2)
                TargetLine.From = center
                TargetLine.To = Vector2.new(screenPos.X, screenPos.Y)
                TargetLine.Visible = true
            else
                TargetLine.Visible = false
            end
        elseif TargetLine then
            TargetLine.Visible = false
        end
    end
end)

-- Helper functions
function isInFOV(position)
    if not position then return false end
    if not camera then return false end
    local screenPos, onScreen = camera:WorldToViewportPoint(position)
    if not onScreen then return false end
    local center = camera.ViewportSize / 2
    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
    return dist <= fovRadius
end

function getClosestEnemy()
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local myPos = root.Position

    local best = nil
    local bestDist = math.huge

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local part = p.Character:FindFirstChild(targetPartName) or p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and part then
                if teamCheck then
                    if player.Team and p.Team and player.Team == p.Team then
                        continue
                    end
                end
                local pos = part.Position
                local dist = (pos - myPos).Magnitude
                if dist <= maxDistance and isInFOV(pos) and dist < bestDist then
                    bestDist = dist
                    best = part
                end
            end
        end
    end

    -- Check NPCs
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, npc in pairs(enemies:GetChildren()) do
            if npc:IsA("Model") then
                local hum = npc:FindFirstChildOfClass("Humanoid")
                local part = npc:FindFirstChild(targetPartName) or npc:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and part then
                    local pos = part.Position
                    local dist = (pos - myPos).Magnitude
                    if dist <= maxDistance and isInFOV(pos) and dist < bestDist then
                        bestDist = dist
                        best = part
                    end
                end
            end
        end
    end

    return best
end

-- ============================================================
-- SILENT AIM HOOKS - ROBUST METHOD
-- ============================================================

-- 1. Hook mouse.Hit and mouse.Target via __index
local oldIndex = nil
local mt = getrawmetatable(game)
if mt then
    oldIndex = mt.__index
    setreadonly(mt, false)
    mt.__index = newcclosure(function(self, key)
        if not checkcaller() and self == mouse and (key == "Hit" or key == "Target") then
            if aimbotEnabled and currentTarget then
                if key == "Hit" then
                    return CFrame.new(currentTarget.Position)
                elseif key == "Target" then
                    return currentTarget
                end
            end
        end
        return oldIndex(self, key)
    end)
    setreadonly(mt, true)
end

-- 2. Override specific remote events' FireServer/InvokeServer
local function overrideRemote(remote)
    if remote and remote:IsA("RemoteEvent") then
        local oldFire = remote.FireServer
        remote.FireServer = function(self, ...)
            if aimbotEnabled and currentTarget then
                local args = {...}
                local targetPos = currentTarget.Position
                -- Replace Vector3/CFrame arguments with target position
                for i, arg in ipairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = targetPos
                    elseif typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(targetPos)
                    end
                end
                -- Special handling for RegisterHit and RegisterAttack
                if self.Name == "RE/RegisterHit" or self.Name == "RegisterHit" then
                    local targetChar = currentTarget.Parent
                    if targetChar then
                        args[1] = currentTarget
                        args[2] = { { targetChar, currentTarget } }
                    end
                elseif self.Name == "RE/ShootGunEvent" or self.Name == "ShootGunEvent" then
                    args[1] = targetPos
                    if currentTarget.Parent then
                        args[2] = { currentTarget.Parent }
                    end
                end
                return oldFire(self, unpack(args))
            end
            return oldFire(self, ...)
        end
    elseif remote and remote:IsA("RemoteFunction") then
        local oldInvoke = remote.InvokeServer
        remote.InvokeServer = function(self, ...)
            if aimbotEnabled and currentTarget then
                local args = {...}
                local targetPos = currentTarget.Position
                for i, arg in ipairs(args) do
                    if typeof(arg) == "Vector3" then
                        args[i] = targetPos
                    elseif typeof(arg) == "CFrame" then
                        args[i] = CFrame.new(targetPos)
                    end
                end
                return oldInvoke(self, unpack(args))
            end
            return oldInvoke(self, ...)
        end
    end
end

-- Override all remote events/functions in ReplicatedStorage
task.spawn(function()
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            overrideRemote(remote)
        end
    end
    -- Also check for new remotes added later
    ReplicatedStorage.DescendantAdded:Connect(overrideRemote)
end)

-- 3. Override mouse button click for M1 (if needed, but it's usually handled by remote events)
-- We can also hook UserInputService for mouse button to redirect, but it's not necessary if remotes are handled.

-- Update target continuously
RunService.Heartbeat:Connect(function()
    if aimbotEnabled then
        currentTarget = getClosestEnemy()
    else
        currentTarget = nil
    end
end)

-- Hotkey toggle (F5)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        aimbotEnabled = not aimbotEnabled
        toggleBtn.Text = aimbotEnabled and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(50, 50, 60)
        if FOVCircle then FOVCircle.Visible = (aimbotEnabled and showFOV) end
        if TargetLine then TargetLine.Visible = (aimbotEnabled and showLine) end
    end
end)

-- Print success
print("✅ Ivory Aimbot v2.0 loaded. Press F5 to toggle.")
print("✅ If visuals don't appear, your executor may not support Drawing library.")
