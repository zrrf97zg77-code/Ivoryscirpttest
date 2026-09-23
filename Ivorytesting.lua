-- =============================================
-- IVORY HUB + GUN DEBUG (COMBINED)
-- For Delta executor — single paste
-- =============================================

-- Paste your ENTIRE Ivory Hub v11.1 script here, then the debug below.
-- Since Delta replaces scripts, we run everything as ONE file.

-- [1] --- IVORY HUB CORE (minimal — just enough for debug) ---
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- Features (matching hub v11.1)
local Features = {
    SilentAim = true,          -- FORCED ON for debug
    SilentAimTarget = "Both",
    SilentAimMode = "360",
    SilentAimDistance = 500,
    SilentAimGuns = true,      -- FORCED ON for debug
    SilentAimMelee = true,
}

local TargetPos = nil
local TargetPart = nil

-- =============================================
-- DEBUG OUTPUT
-- =============================================
print("========================================")
print("   IVORY GUN DEBUG — START")
print("========================================")
print("[1] TouchEnabled:", UserInputService.TouchEnabled)
print("[1] KeyboardEnabled:", UserInputService.KeyboardEnabled)
print("[1] MouseEnabled:", UserInputService.MouseEnabled)

local GUN_WORDS = {"flintlock","musket","slingshot","cannon","bazooka","rifle","bow",
    "kabucha","serpent","dragonstorm","guitar","pistol","gun","acidum","skull",
    "dual","revolver","smoke","grenade","spike","bomb"}

local function IsHoldingGun()
    local char = player.Character
    if not char then return false end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return false end
    local n = string.lower(tool.Name)
    for _, w in ipairs(GUN_WORDS) do
        if string.find(n, w, 1, true) then return true end
    end
    if tool:FindFirstChild("Shoot") or tool:FindFirstChild("Fire") then return true end
    return false
end

local function isCombatNPC(model, hum, root)
    if not model or not hum or not root then return false end
    if hum.Health <= 0 then return false end
    local n = string.lower(model.Name)
    local block = {"shop","seller","dealer","quest","trainer","teacher","merchant",
        "gacha","title","dialog","manager","vendor","guide","helper","boat","customer",
        "spawn","luxury","bartender","captain","toribro","indra","nami","ability",
        "sword dealer","weapon","blox fruit","crew","quest giver","town","citizen"}
    for _, w in ipairs(block) do
        if string.find(n, w, 1, true) then return false end
    end
    if model:FindFirstChildWhichIsA("ProximityPrompt", true) then return false end
    if model:FindFirstChildWhichIsA("ClickDetector", true) then return false end
    if hum.MaxHealth < 20 then return false end
    return true
end

local function getHitboxPart(model)
    local names = {"Head","UpperTorso","Torso","HumanoidRootPart","Root","Hitbox","Chest"}
    for _, n in ipairs(names) do
        local p = model:FindFirstChild(n, true)
        if p and p:IsA("BasePart") then return p end
    end
    for _, p in ipairs(model:GetDescendants()) do
        if p:IsA("BasePart") then return p end
    end
    return nil
end

local NPC_FOLDERS = {"Enemies","Enemy","Monsters","Monster","Mobs","Mob","Bosses","Boss","NPCs","Npcs"}

local function GetNearestTarget(targetType, mode, maxDist)
    local char = player.Character
    if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end

    local best, bestPart, bestDist = nil, nil, math.huge
    local maxRange = maxDist or 1000

    if targetType == "Players" or targetType == "Both" then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= player and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    local dist = (hrp.Position - root.Position).Magnitude
                    if dist <= maxRange and dist < bestDist then
                        bestDist = dist
                        best = hrp
                        bestPart = plr.Character:FindFirstChild("Head") or hrp
                    end
                end
            end
        end
    end

    if targetType == "NPCs" or targetType == "Both" then
        for _, name in ipairs(NPC_FOLDERS) do
            local folder = workspace:FindFirstChild(name)
            if folder then
                for _, npc in pairs(folder:GetChildren()) do
                    if npc:IsA("Model") then
                        local hum = npc:FindFirstChildOfClass("Humanoid")
                        local hrp = npc:FindFirstChild("HumanoidRootPart")
                        if hum and hrp and hum.Health > 0 and isCombatNPC(npc, hum, hrp) then
                            local dist = (hrp.Position - root.Position).Magnitude
                            if dist <= maxRange and dist < bestDist then
                                bestDist = dist
                                best = hrp
                                bestPart = getHitboxPart(npc)
                            end
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

-- Update target every frame
RunService.RenderStepped:Connect(function()
    local hrp, part = GetNearestTarget(Features.SilentAimTarget, Features.SilentAimMode, Features.SilentAimDistance)
    if hrp and part then
        TargetPart = part
        TargetPos = part.Position
    else
        TargetPos = nil
        TargetPart = nil
    end
end)

-- =============================================
-- HOOKS: Watch what the game calls
-- =============================================
print("[7] Hooking camera + remote functions...")
local mt = getrawmetatable(game)
local oldNC = mt.__namecall
setreadonly(mt, false)

local rayCallCount = 0
local fireCallCount = 0

mt.__namecall = function(self, ...)
    local m = getnamecallmethod()
    local args = {...}

    -- Watch camera rays
    if self == Camera and (m == "ScreenPointToRay" or m == "ViewportPointToRay") then
        ray

CallCount = rayCallCount + 1---


        print("[GAME## CALLED] " .. m .. "(" .. to Whatstring(args[1]) .. ", " .. I tostring(args[2]) .. ")")
    end

    -- Watch remote fires
    if m == "FireServer" or m == "InvokeServer" then
        local nm = string.lower(tostring(self.Name or "?"))
        if string.find(nm, "shoot") or string.find(nm, "fire")
           or string.find(nm, "gun") or string.find(nm, "hit")
           or string.find(nm, "attack") then
            fireCallCount = fireCallCount + 1
            local summary = ""
            for i, v in ipairs(args) do
                summary = summary .. "[" .. i .. "]=" .. typeof(v) .. " "
            end
            print("[REMOTE] " .. tostring(self.Name) .. " args: " .. summary)
        end
    end

    return oldNC(self, ...)
end
setreadonly(mt, true)

-- =============================================
-- LIVE STATUS
-- =============================================
print("========================================")
print("NOW:")
print("  1. Equip a GUN")
print("  2. Stand near a mob")
print("  3. Tap M1 to shoot")
print("  4. Copy ALL output, paste back")
print("========================================")

task.spawn(function()
    while true do
        task.wait(2)
        local c = player.Character
        local t = c and c:FindFirstChildOfClass("Tool")
        print("[LIVE] Tool:" .. (t and t.Name or "none")
            .. " | IsGun:" .. tostring(IsHoldingGun())
            .. " | Rays:" .. rayCallCount
            .. " | Fires:" .. fireCallCount
            .. " | TargetPart:" .. (TargetPart and TargetPart.Name or "nil"))
    end
end)