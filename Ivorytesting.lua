local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local function optimize(obj)
	-- Keep some particles, but reduce how many are rendered
	if obj:IsA("ParticleEmitter") then
		pcall(function()
			obj.Rate = math.min(obj.Rate, 10)
			obj.Lifetime = NumberRange.new(
				math.min(obj.Lifetime.Min, 1),
				math.min(obj.Lifetime.Max, 2)
			)
		end)

	-- Disable the heavier effects
	elseif obj:IsA("Smoke") then
		obj.Enabled = false

	elseif obj:IsA("Fire") then
		obj.Enabled = false

	elseif obj:IsA("Sparkles") then
		obj.Enabled = false

	elseif obj:IsA("Beam") then
		obj.Enabled = false

	elseif obj:IsA("Trail") then
		obj.Enabled = false

	-- Disable post-processing
	elseif obj:IsA("PostEffect") then
		obj.Enabled = false

	-- Make meshes cheaper
	elseif obj:IsA("MeshPart") then
		pcall(function()
			obj.RenderFidelity = Enum.RenderFidelity.Performance
			obj.CastShadow = false
		end)

	-- Remove expensive shadows while keeping materials
	elseif obj:IsA("BasePart") then
		pcall(function()
			obj.CastShadow = false
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

	-- Terrain
	local terrain = Workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		pcall(function()
			terrain.Decoration = false
			terrain.WaterWaveSize = 0
			terrain.WaterWaveSpeed = 0
			terrain.WaterReflectance = 0
		end)
	end

	-- Optimize loaded objects
	for _, obj in ipairs(Workspace:GetDescendants()) do
		optimize(obj)
	end

	for _, obj in ipairs(Lighting:GetChildren()) do
		optimize(obj)
	end
end

-- Initial optimization
optimize()

-- Handle effects created later
game.DescendantAdded:Connect(function(obj)
	task.defer(function()
		optimize(obj)
	end)
end)

-- Keep important settings active
task.spawn(function()
	while true do
		Lighting.GlobalShadows = false
		Lighting.Brightness = 3
		Lighting.EnvironmentDiffuseScale = 0
		Lighting.EnvironmentSpecularScale = 0

		task.wait(1)
	end
end)
