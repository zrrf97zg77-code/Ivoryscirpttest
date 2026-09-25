local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- FULL BRIGHT
Lighting.Brightness = 3
Lighting.ClockTime = 14
Lighting.FogEnd = 100000
Lighting.FogStart = 0
Lighting.GlobalShadows = false
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0

-- REMOVE LIGHTING EFFECTS
for _, effect in ipairs(Lighting:GetChildren()) do
	if effect:IsA("PostEffect") then
		effect.Enabled = false
	end
end

-- DISABLE TERRAIN DECORATION
local terrain = Workspace:FindFirstChildOfClass("Terrain")
if terrain then
	terrain.Decoration = false
end

-- REMOVE PARTICLE / EFFECT HEAVINESS
local function optimize(obj)
	if obj:IsA("ParticleEmitter") then
		obj.Enabled = false
	elseif obj:IsA("Trail") then
		obj.Enabled = false
	elseif obj:IsA("Beam") then
		obj.Enabled = false
	elseif obj:IsA("Smoke") then
		obj.Enabled = false
	elseif obj:IsA("Fire") then
		obj.Enabled = false
	elseif obj:IsA("Sparkles") then
		obj.Enabled = false
	elseif obj:IsA("BloomEffect")
		or obj:IsA("BlurEffect")
		or obj:IsA("ColorCorrectionEffect")
		or obj:IsA("SunRaysEffect")
		or obj:IsA("DepthOfFieldEffect") then
		obj.Enabled = false
	end
end

-- APPLY TO EXISTING OBJECTS
for _, obj in ipairs(game:GetDescendants()) do
	optimize(obj)
end

-- OPTIMIZE NEW EFFECTS THAT GET CREATED
game.DescendantAdded:Connect(function(obj)
	task.defer(function()
		optimize(obj)
	end)
end)

-- LOWER QUALITY
pcall(function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
end)
