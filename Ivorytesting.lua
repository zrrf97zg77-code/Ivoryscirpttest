-- ============================================================
-- IVORY AIMBOT v7.0 | 180° FOV + DISTANCE SLIDER + TARGET LINE
-- ============================================================
-- • 180° Field of View: only targets enemies in front of you.
-- • Targets the enemy closest to the center of your screen.
-- • RED LINE from screen center to target (requires Drawing).
-- • Distance slider: adjust max targeting distance (500-5000).
-- • Toggle Players/NPCs individually.
-- • F5 to toggle aimbot on/off.
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
local hasDrawing = pcall(function() 
    local c = Drawing.new("Circle") 
    c:Remove()
    return true 
end)

-- Configuration
local aimbotEnabled = false
local maxDistance = 3000  -- default
local targetPartName = "HumanoidRootPart"
local teamCheck = true
local showLine = true
local targetPlayers = true
local targetNPCs = true
local showFOV = false  -- FOV circle visual, optional

-- Visuals
local FOVCircle = nil
local TargetLine = nil
local fovCircleRadius = 180  -- only visual

if hasDrawing then
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Visible = false
    FOVCircle.Color = Color3.fromRGB(255, 255, 0)
    FOVCircle.Radius = fovCircleRadius
    FOVCircle.Thickness = 2
    FOVCircle.Filled = false
    FOVCircle.Transparency = 0.5

    TargetLine = Drawing.new("Line")
    TargetLine.Visible = false
    TargetLine.Color = Color3.fromRGB(255, 0, 0)  -- RED
    TargetLine.Thickness = 2
    TargetLine.Transparency = 0.6
else
    warn("Drawing library not available. Target line will not show.")
end

-- Target variable
local currentTarget = nil

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "IvoryAimbotGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame", screenGui)
mainFrame.Size = UDim2.new(0, 260, 0, 220)
mainFrame.Position = UDim2.new(0.5, -130, 0.15, 0)
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
title.Text = "IVORY AIMBOT v7"
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
toggleBtn.Position = UDim2.new(0.05, 0, 0.38, 0)
toggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
toggleBtn.Text = "OFF"
toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 4)

-- Toggle Players
local playerToggleBtn = Instance.new("TextButton", mainFrame)
playerToggleBtn.Size = UDim2.new(0.3, -5, 0, 20)
playerToggleBtn.Position = UDim2.new(0.4, 0, 0.38, 0)
playerToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
playerToggleBtn.Text = "PLAYERS"
playerToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
playerToggleBtn.Font = Enum.Font.GothamBold
playerToggleBtn.TextSize = 9
Instance.new("UICorner", playerToggleBtn).CornerRadius = UDim.new(0, 4)

-- Toggle NPCs
local npcToggleBtn = Instance.new("TextButton", mainFrame)
npcToggleBtn.Size = UDim2.new(0.3, -5, 0, 20)
npcToggleBtn.Position = UDim2.new(0.72, 0, 0.38, 0)
npcToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
npcToggleBtn.Text = "NPCS"
npcToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
npcToggleBtn.Font = Enum.Font.GothamBold
npcToggleBtn.TextSize = 9
Instance.new("UICorner", npcToggleBtn).CornerRadius = UDim.new(0, 4)

-- Distance Label
local distLabel = Instance.new("TextLabel", mainFrame)
distLabel.Size = UDim2.new(0.4, 0, 0, 18)
distLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
distLabel.BackgroundTransparency = 1
distLabel.Text = "Dist: " .. maxDistance
distLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
distLabel.Font = Enum.Font.GothamBold
distLabel.TextSize = 10
distLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Distance Slider Frame
local distSliderFrame = Instance.new("Frame", mainFrame)
distSliderFrame.Size = UDim2.new(0.45, 0, 0, 20)
distSliderFrame.Position = UDim2.new(0.55, 0, 0.6, 0)
distSliderFrame.BackgroundTransparency = 1

local distMinus = Instance.new("TextButton", distSliderFrame)
distMinus.Size = UDim2.new(0.25, 0, 1, 0)
distMinus.Position = UDim2.new(0, 0, 0, 0)
distMinus.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
distMinus.Text = "-"
distMinus.TextColor3 = Color3.fromRGB(255, 255, 255)
distMinus.Font = Enum.Font.GothamBold
distMinus.TextSize = 14
Instance.new("UICorner", distMinus).CornerRadius = UDim.new(0, 4)

local distValLabel = Instance.new("TextLabel", distSliderFrame)
distValLabel.Size = UDim2.new(0.5, 0, 1, 0)
distValLabel.Position = UDim2.new(0.25, 0, 0, 0)
distValLabel.BackgroundTransparency = 1
distValLabel.Text = tostring(maxDistance)
distValLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
distValLabel.Font = Enum.Font.GothamBold
distValLabel.TextSize = 11
distValLabel.TextXAlignment = Enum.TextXAlignment.Center

local distPlus = Instance.new("TextButton", distSliderFrame)
distPlus.Size = UDim2.new(0.25, 0, 1, 0)
distPlus.Position = UDim2.new(0.75, 0, 0, 0)
distPlus.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
distPlus.Text = "+"
distPlus.TextColor3 = Color3.fromRGB(255, 255, 255)
distPlus.Font = Enum.Font.GothamBold
distPlus.TextSize = 14
Instance.new("UICorner", distPlus).CornerRadius = UDim.new(0, 4)

-- Info label (180°)
local infoLabel = Instance.new("TextLabel", mainFrame)
infoLabel.Size = UDim2.new(1, 0, 0, 16)
infoLabel.Position = UDim2.new(0, 5, 0, 0.78)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "180° FOV (only targets in front of you)"
infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextSize = 9
infoLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Line toggle
local lineToggleBtn = Instance.new("TextButton", mainFrame)
lineToggleBtn.Size = UDim2.new(0.45, -5, 0, 18)
lineToggleBtn.Position = UDim2.new(0.05, 0, 0.88, 0)
lineToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
lineToggleBtn.Text = "LINE: ON"
lineToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
lineToggleBtn.Font = Enum.Font.GothamBold
lineToggleBtn.TextSize = 9
Instance.new("UICorner", lineToggleBtn).CornerRadius = UDim.new(0, 4)

-- FOV circle toggle
local fovToggleBtn = Instance.new("TextButton", mainFrame)
fovToggleBtn.Size = UDim2.new(0.45, -5, 0, 18)
fovToggleBtn.Position = UDim2.new(0.55, 0, 0.88, 0)
fovToggleBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
fovToggleBtn.Text = "FOV: OFF"
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

playerToggleBtn.MouseButton1Click:Connect(function()
    targetPlayers = not targetPlayers
    playerToggleBtn.BackgroundColor3 = targetPlayers and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 60, 70)
end)

npcToggleBtn.MouseButton1Click:Connect(function()
    targetNPCs = not targetNPCs
    npcToggleBtn.BackgroundColor3 = targetNPCs and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(60, 60, 70)
end)

distMinus.MouseButton1Click:Connect(function()
    maxDistance = math.max(500, maxDistance - 100)
    distValLabel.Text = tostring(maxDistance)
    distLabel.Text = "Dist: " .. maxDistance
end)

distPlus.MouseButton1Click:Connect(function()
    maxDistance = math.min(5000, maxDistance + 100)
    distValLabel.Text = tostring(maxDistance)
    distLabel.Text = "Dist: " .. maxDistance
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

    -- Update FOV circle (if enabled)
    if FOVCircle then
        if aimbotEnabled and showFOV then
            FOVCircle.Visible = true
            local viewport = camera.ViewportSize
            FOVCircle.Position = Vector2.new(viewport.X/2, viewport.Y/2)
        else
            FOVCircle.Visible = false
        end
    end

    -- Update target line
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

    -- Update target label
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

-- Helper: Check if a position is within 180° in front of player
function isIn180FOV(position)
    if not position or not camera then return false end
    -- Get the player's facing direction from camera
    local lookVector = camera.CFrame.LookVector
    -- Get direction from player to target
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    local dirToTarget = (position - root.Position).Unit
    -- Dot product: if > 0, target is in front (within 90°); for 180° we need > -0? Actually 180° means all directions, but we want half sphere: 180° is ±90° from forward, so dot product >= 0 means in front half sphere.
    local dot = lookVector:Dot(dirToTarget)
    return dot >= 0
end

-- Get screen center distance (for tie-breaking)
function getScreenCenterDistance(position)
    if not position or not camera then return math.huge end
    local screenPos, onScreen = camera:WorldToViewportPoint(position)
    if not onScreen then return math.huge end
    local center = camera.ViewportSize / 2
    return (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
end

-- Get closest enemy based on: must be in front (180°), within max distance, and closest to screen center
function getClosestEnemy()
    local char = player.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local myPos = root.Position

    local best = nil
    local bestScore = math.huge  -- lower is better (center distance + distance weight)

    -- Check players
    if targetPlayers then
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
                    if dist <= maxDistance and isIn180FOV(pos) then
                        local centerDist = getScreenCenterDistance(pos)
                        local score = centerDist + dist * 0.001  -- slight weight for distance
                        if score < bestScore then
                            bestScore = score
                            best = part
                        end
                    end
                end
            end
        end
    end

    -- Check NPCs
    if targetNPCs then
        local enemies = workspace:FindFirstChild("Enemies")
        if enemies then
            for _, npc in pairs(enemies:GetChildren()) do
                if npc:IsA("Model") then
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    local part = npc:FindFirstChild(targetPartName) or npc:FindFirstChild("HumanoidRootPart")
                    if hum and hum.Health > 0 and part then
                        local pos = part.Position
                        local dist = (pos - myPos).Magnitude
                        if dist <= maxDistance and isIn180FOV(pos) then
                            local centerDist = getScreenCenterDistance(pos)
                            local score = centerDist + dist * 0.001
                            if score < bestScore then
                                bestScore = score
                                best = part
                            end
                        end
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
-- SILENT AIM HOOKS
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

-- Fallback __namecall hook
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

print("✅ Ivory Aimbot v7.0 loaded!")
print("📌 180° FOV - only targets enemies in front of you.")
print("📌 Distance slider adjusts max targeting range.")
print("🔴 RED LINE shows current target (if Drawing is available).")
print("📌 Press F5 to toggle aimbot on/off.")
