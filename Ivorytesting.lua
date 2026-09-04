-- ============================================================
-- IVORY AIMBOT v4.1 | TARGET MODE SELECTOR (Players/NPCs/Both)
-- ============================================================
-- Features:
-- • Silent aim for all abilities (Z/X/C/V/F/M1)
-- • FOV circle & target line (Drawing library, toggleable)
-- • Target mode selector: Players only / NPCs only / Both
-- • Works on mobile (Delta, Hydrogen, etc.)
-- • GUI with FOV slider, toggles, and mode buttons
-- • Hotkey: F5 to toggle aimbot
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
local targetPartName = "HumanoidRootPart"
local teamCheck = true
local showLine = true
local showFOV = true

-- Target mode: "Players", "NPCs", "Both"
local targetMode = "Both"

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
    FOVCircle.Transparency = 0.8

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
mainFrame.Size = UDim2.new(0, 260, 0, 200)
mainFrame.Position = UDim2.new(0.5, -130, 0.1, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BackgroundTransparency = 0.1
mainFrame.Active = true
mainFrame.Draggable = true
Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", mainFrame)
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Thickness = 1.5

-- Title
local title = Instance.new("TextLabel", mainFrame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "IVORY AIMBOT v4.1"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15

-- Target status
local targetLabel = Instance.new("TextLabel", mainFrame)
targetLabel.Size = UDim2.new(1, -10, 0, 16)
targetLabel.Position = UDim2.new(0, 5, 0, 32)
targetLabel.BackgroundTransparency = 1
targetLabel.Text = "Target: None"
targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
targetLabel.Font = Enum.Font.Gotham
targetLabel.TextSize = 10
targetLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Toggle Button
local toggleBtn = Instance.new("TextButton", mainFrame)
toggleBtn.Size = UDim2.new(0.3, -5, 0, 28)
toggleBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

-- FOV Label
local fovLabel = Instance.new("TextLabel", mainFrame)
fovLabel.Size = UDim2.new(0.35, 0, 0, 20)
fovLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV: " .. fovRadius
fovLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
fovLabel.Font = Enum.Font.GothamBold
fovLabel.TextSize = 10
fovLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Slider Frame
local sliderFrame = Instance.new("Frame", mainFrame)
sliderFrame.Size = UDim2.new(0.45, 0, 0, 20)
sliderFrame.Position = UDim2.new(0.38, 0, 0.6, 0)
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

-- Target Mode Buttons
local modeLabel = Instance.new("TextLabel", mainFrame)
modeLabel.Size = UDim2.new(0.3, 0, 0, 16)
modeLabel.Position = UDim2.new(0.05, 0, 0.78, 0)
modeLabel.BackgroundTransparency = 1
modeLabel.Text = "Target:"
modeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
modeLabel.Font = Enum.Font.GothamBold
modeLabel.TextSize = 10
modeLabel.TextXAlignment = Enum.TextXAlignment.Left

local modeButtons = {}
local modes = {"Players", "NPCs", "Both"}
local modeColors = {Color3.fromRGB(0, 150, 255), Color3.fromRGB(255, 150, 0), Color3.fromRGB(0, 200, 100)}

for i, mode in ipairs(modes) do
    local btn = Instance.new("TextButton", mainFrame)
    btn.Size = UDim2.new(0.2, 0, 0, 18)
    btn.Position = UDim2.new(0.35 + (i-1) * 0.22, 0, 0.78, 0)
    btn.BackgroundColor3 = (targetMode == mode) and modeColors[i] or Color3.fromRGB(50, 50, 60)
    btn.Text = mode
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 9
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    btn.MouseButton1Click:Connect(function()
        targetMode = mode
        for j, b in ipairs(modeButtons) do
            b.BackgroundColor3 = (targetMode == modes[j]) and modeColors[j] or Color3.fromRGB(50, 50, 60)
        end
    end)
    modeButtons[i] = btn
end

-- Line and FOV toggles (repositioned)
local lineToggleBtn = Instance.new("TextButton", mainFrame)
lineToggleBtn.Size = UDim2.new(0.3, 0, 0, 18)
lineToggleBtn.Position = UDim2.new(0.05, 0, 0.92, 0)
lineToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
lineToggleBtn.Text = "LINE: ON"
lineToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lineToggleBtn.Font = Enum.Font.GothamBold
lineToggleBtn.TextSize = 9
Instance.new("UICorner", lineToggleBtn).CornerRadius = UDim.new(0, 4)

local fovToggleBtn = Instance.new("TextButton", mainFrame)
fovToggleBtn.Size = UDim2.new(0.3, 0, 0, 18)
fovToggleBtn.Position = UDim2.new(0.4, 0, 0.92, 0)
fovToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
fovToggleBtn.Text = "FOV: ON"
fovToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
fovToggleBtn.Font = Enum.Font.GothamBold
fovToggleBtn.TextSize = 9
Instance.new("UICorner", fovToggleBtn).CornerRadius = UDim.new(0, 4)

-- Button callbacks
toggleBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    toggleBtn.Text = aimbotEnabled and "ON" or "OFF"
    toggleBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 60, 70)
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
    lineToggleBtn.BackgroundColor3 = showLine and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 60, 70)
    if TargetLine then TargetLine.Visible = (aimbotEnabled and showLine) end
end)

fovToggleBtn.MouseButton1Click:Connect(function()
    showFOV = not showFOV
    fovToggleBtn.Text = showFOV and "FOV: ON" or "FOV: OFF"
    fovToggleBtn.BackgroundColor3 = showFOV and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 60, 70)
    if FOVCircle then FOVCircle.Visible = (aimbotEnabled and showFOV) end
end)

-- Update visuals each frame
RunService.RenderStepped:Connect(function()
    if not camera then return end

    if FOVCircle then
        if aimbotEnabled and showFOV then
            FOVCircle.Visible = true
            local viewport = camera.ViewportSize
            FOVCircle.Position = Vector2.new(viewport.X/2, viewport.Y/2)
        else
            FOVCircle.Visible = false
        end
    end

    if TargetLine then
        if aimbotEnabled and showLine and currentTarget then
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
        else
            TargetLine.Visible = false
        end
    end

    if aimbotEnabled and currentTarget then
        local targetName = "Unknown"
        local parent = currentTarget.Parent
        if parent then
            local p = Players:GetPlayerFromCharacter(parent)
            if p then targetName = p.Name else targetName = parent.Name end
        end
        targetLabel.Text = "Target: " .. targetName
        targetLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    else
        targetLabel.Text = "Target: None"
        targetLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
end)

-- Helper functions
function isInFOV(position)
    if not position or not camera then return false end
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

    -- Check players if mode is "Players" or "Both"
    if targetMode == "Players" or targetMode == "Both" then
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
    end

    -- Check NPCs if mode is "NPCs" or "Both"
    if targetMode == "NPCs" or targetMode == "Both" then
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
        -- Also check other models with Humanoid (some NPCs might be elsewhere)
        for _, obj in pairs(workspace:GetChildren()) do
            if obj:IsA("Model") and obj ~= char and not Players:GetPlayerFromCharacter(obj) then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local part = obj:FindFirstChild(targetPartName) or obj:FindFirstChild("HumanoidRootPart")
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

-- Update target every heartbeat
RunService.Heartbeat:Connect(function()
    if aimbotEnabled then
        currentTarget = getClosestEnemy()
    else
        currentTarget = nil
    end
end)

-- ============================================================
-- SILENT AIM HOOKS (Robust and mobile-friendly)
-- ============================================================

-- Hook mouse.Hit and mouse.Target
if mouse then
    local mt = getrawmetatable(game)
    if mt then
        local oldIndex = mt.__index
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
end

-- Override FireServer/InvokeServer for all remotes
local function overrideRemote(remote)
    if remote:IsA("RemoteEvent") then
        local oldFire = remote.FireServer
        remote.FireServer = function(self, ...)
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
                local name = self.Name
                if name == "RE/RegisterHit" or name == "RegisterHit" then
                    local targetChar = currentTarget.Parent
                    if targetChar then
                        args[1] = currentTarget
                        args[2] = { { targetChar, currentTarget } }
                    end
                elseif name == "RE/RegisterAttack" or name == "RegisterAttack" then
                    local targetChar = currentTarget.Parent
                    if targetChar then
                        args[2] = { { targetChar, currentTarget } }
                    end
                elseif name == "RE/ShootGunEvent" or name == "ShootGunEvent" then
                    args[1] = targetPos
                    if currentTarget.Parent then
                        args[2] = { currentTarget.Parent }
                    end
                end
                return oldFire(self, unpack(args))
            end
            return oldFire(self, ...)
        end
    elseif remote:IsA("RemoteFunction") then
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

-- Apply overrides to all existing remotes and future ones
task.spawn(function()
    for _, remote in ipairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            overrideRemote(remote)
        end
    end
    ReplicatedStorage.DescendantAdded:Connect(overrideRemote)
end)

-- __namecall fallback
local oldNamecall = nil
local mt = getrawmetatable(game)
if mt then
    oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if not checkcaller() and (method == "FireServer" or method == "InvokeServer") then
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
                return oldNamecall(self, unpack(args))
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- Hotkey: F5 to toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        aimbotEnabled = not aimbotEnabled
        toggleBtn.Text = aimbotEnabled and "ON" or "OFF"
        toggleBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 60, 70)
        if FOVCircle then FOVCircle.Visible = (aimbotEnabled and showFOV) end
        if TargetLine then TargetLine.Visible = (aimbotEnabled and showLine) end
    end
end)

print("✅ Ivory Aimbot v4.1 loaded! Press F5 to toggle.")
print("✅ Target mode buttons: Players / NPCs / Both.")
print("✅ FOV circle and line can be toggled from GUI.")
