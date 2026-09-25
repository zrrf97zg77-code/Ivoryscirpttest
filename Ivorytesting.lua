local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local function optimize(obj)
	if obj:IsA("ParticleEmitter")
		or obj:IsA("Trail")
		or obj:IsA("Beam")
		or obj:IsA("Smoke")
		or obj:IsA("Fire")
		or obj:IsA("Sparkles") then
		obj.Enabled = false
	end

	if obj:IsA("PostEffect") then
		obj.Enabled = false
	end
end

local function applyLiteGraphics()
	-- FULL BRIGHT
	Lighting.Brightness = 3
	Lighting.ClockTime = 14
	Lighting.GlobalShadows = false
	Lighting.FogEnd = 100000
	Lighting.EnvironmentDiffuseScale = 0
	Lighting.EnvironmentSpecularScale = 0

	-- LOW TERRAIN DETAIL
	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain.Decoration = false
	end

	-- DISABLE EFFECTS
	for _, obj in ipairs(game:GetDescendants()) do
		optimize(obj)
	end

	-- LOWEST GRAPHICS QUALITY
	pcall(function()
		settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	end)
end

-- APPLY IMMEDIATELY
applyLiteGraphics()

-- KEEP IT ACTIVE
local timer = 0

RunService.RenderStepped:Connect(function(dt)
	timer += dt

	-- Reapply every 0.5 seconds
	if timer >= 0.5 then
		timer = 0
		applyLiteGraphics()
	end
end)

-- Catch effects as soon as they're created
game.DescendantAdded:Connect(function(obj)
	task.defer(function()
		optimize(obj)
	end)
end)
