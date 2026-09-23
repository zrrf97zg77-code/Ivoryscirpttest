-- =============================================
-- IVORY GUN DEBUG — STANDALONE (no hub needed)
-- =============================================
print("========================================")
print("   IVORY GUN DEBUG — START")
print("========================================")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [1] Mobile check
print("[1] Touch:", UIS.TouchEnabled, "| Keyboard:", UIS.KeyboardEnabled, "| Mouse:", UIS.MouseEnabled)

-- [2] Gun detection
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

-- [3] NPC detection
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

local function GetNearestTarget()
    local char = player.Character
    if not char then return nil, nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end

    local best, bestPart, bestDist = nil, nil, math.huge
    for _, name in ipairs(NPC_FOLDERS) do
        local folder = workspace:FindFirstChild(name)
        if folder then
            for _, npc in pairs(folder:GetChildren()) do
                if npc:IsA("Model") then
                    local hum = npc:FindFirstChildOfClass("Humanoid")
                    local hrp = npc:FindFirstChild("HumanoidRootPart")
                    if hum and hrp and hum.Health > 0 and isCombatNPC(npc, hum, hrp) then
                        local dist = (hrp.Position - root.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            best = hrp
                            bestPart = getHitboxPart(npc)
                        end
                    end
                end
            end
        end
    end
    return best, bestPart
end

-- [4] Current tool
local char = player.Character
local tool = char and char:FindFirstChildOfClass("Tool")
print("[2] Held tool:", tool and tool.Name or "NONE")
print("[3] IsHoldingGun():", IsHoldingGun())

-- [5] NPC folder scan
print("[4] Scanning workspace for NPC folders...")
for _, name in ipairs(NPC_FOLDERS) do
    local f = workspace:FindFirstChild(name)
    if f then
        print("    Found:", name, "(" .. #f:GetChildren() .. " children)")
    end
end

-- [6] Tool contents
if tool then
    print("[5] Contents of tool '" .. tool.Name .. "':")
    for _, d in ipairs(tool:GetDescendants()) do
        if d:IsA("RemoteEvent") or d:IsA("RemoteFunction") or d:IsA("LocalScript") then
            print("    " .. d.ClassName .. ": " .. d:GetFullName())
        end
    end
end

-- [7] Hook camera rays + remote fires
print("[6] Hooking... waiting for you to shoot")
local mt = getrawmetatable(game)
local oldNC = mt.__namecall
setreadonly(mt, false)

local rayCount = 0
local fireCount = 0

mt.__namecall = function(self, ...)
    local m = getnamecallmethod()
    local args = {...}

    if self == Camera and (m == "ScreenPointToRay" or m == "ViewportPointToRay") then
        rayCount = rayCount + 1
        print("[GAME] " .. m .. "(" .. tostring(args[1]) .. ", " .. tostring(args[2]) .. ")")
    end

    if m == "FireServer" or m == "InvokeServer" then
        local nm = string.lower(tostring(self.Name or "?"))
        if string.find(nm, "shoot") or string.find(nm, "fire")
           or string.find(nm, "gun") or string.find(nm, "hit")
           or string.find(nm, "attack") then
            fireCount = fireCount + 1
            local s = ""
            for i, v in ipairs(args) do
                s = s .. "[" .. i .. "]=" .. typeof(v) .. " "
            end
            print("[REMOTE] " .. tostring(self.Name) .. " -> " .. s)
        end
    end

    return oldNC(self, ...)
end
setreadonly(mt, true)

-- [8] Live status every 2s
print("========================================")
print("NOW: equip gun, stand near mob, tap M1")
print("========================================")

task.spawn(function()
    while true do
        task.wait(2)
        local c = player.Character
        local t = c and c:FindFirstChildOfClass("Tool")
        local hrp, part = GetNearestTarget()
        print("[LIVE] Tool:" .. (t and t.Name or "none")
            .. " | IsGun:" .. tostring(IsHoldingGun())
            .. " | Rays:" .. rayCount
            .. " | Fires:" .. fireCount
            .. " | Target:" .. (part and part.Name or "nil"))
    end
end)