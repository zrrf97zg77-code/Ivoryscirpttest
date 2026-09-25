local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- FULL BRIGHT / LIGHT GRAPHICS
Lighting.Brightness = 3
Lighting.ClockTime = 14
Lighting.GlobalShadows = false
Lighting.FogStart = 0
Lighting.FogEnd = 100000
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0

-- Lower terrain detail
local terrain = Workspace:FindFirstChildOfClass("Terrain")

if terrain then
	pcall(function()
		terrain.Decoration = false
		terrain.WaterWaveSize = 0
		terrain.WaterWaveSpeed = 0
		terrain.WaterReflectance = 0
	end)
end

-- Disable only the expensive visual effects
local function optimize(obj)
	if obj:IsA("PostEffect") then
		obj.Enabled = false

	elseif obj:IsA("Smoke")
		or obj:IsA("Fire")
		or obj:IsA("Sparkles") then
		obj.Enabled = false

	elseif obj:IsA("Beam") then
		obj.Enabled = false

	elseif obj:IsA("Trail") then
		obj.Enabled = false

	elseif obj:IsA("ParticleEmitter") then
		-- Keep particles, just reduce their amount
		pcall(function()
			obj.Rate = math.min(obj.Rate, 20)
		end)

	elseif obj:IsA("BasePart") then
		-- Shadows are expensive but this doesn't change appearance much
		pcall(function()
			obj.CastShadow = false
		end)
	end
end

-- Optimize existing objects ONCE
for _, obj in ipairs(game:GetDescendants()) do
	optimize(obj)
end

-- Optimize new effects without repeatedly scanning the whole game
game.DescendantAdded:Connect(function(obj)
	task.defer(function()
		optimize(obj)
	end)
end)

-- Keep only the lighting settings enforced
task.spawn(function()
	while true do
		Lighting.GlobalShadows = false
		Lighting.Brightness = 3
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.EnvironmentSpecularScale = 0
		task.wait(2)
	end
end)
