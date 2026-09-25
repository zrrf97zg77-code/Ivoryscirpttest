local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local function disableEffect(obj)
	if obj:IsA("PostEffect")
		or obj:IsA("ParticleEmitter")
		or obj:IsA("Trail")
		or obj:IsA("Beam")
		or obj:IsA("Smoke")
		or obj:IsA("Fire")
		or obj:IsA("Sparkles") then

		pcall(function()
			obj.Enabled = false
		end)
	end
end

local function optimize()
	-- FULL BRIGHT
	Lighting.Brightness = 3
	Lighting.ClockTime = 14
	Lighting.GlobalShadows = false
	Lighting.FogStart = 0
	Lighting.FogEnd = 100000
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	-- Disable every lighting/post effect
	for _, obj in ipairs(Lighting:GetChildren()) do
		disableEffect(obj)
	end

	-- Disable effects anywhere in the game
	for _, obj in ipairs(Workspace:GetDescendants()) do
		disableEffect(obj)
	end

	-- Reduce terrain detail
	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain.Decoration = false
	end
end

-- New effects get disabled immediately
game.DescendantAdded:Connect(function(obj)
	task.defer(function()
		disableEffect(obj)
	end)
end)

-- Keep lighting enforced every frame
RunService.RenderStepped:Connect(function()
	Lighting.Brightness = 3
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 100000
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0
end)

-- Heavy optimization pass
task.spawn(function()
	while true do
		optimize()
		task.wait(0.25)
	end
end)

optimize()
