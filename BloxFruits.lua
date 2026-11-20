local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")

local VirtualInputManager = nil
pcall(function()
	VirtualInputManager = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local BgVoid = Color3.fromRGB(7, 8, 16)
local BgPanel = Color3.fromRGB(13, 15, 28)
local CardSurface = Color3.fromRGB(19, 22, 40)
local CardHover = Color3.fromRGB(26, 30, 54)
local AccentPrimary = Color3.fromRGB(139, 92, 246)
local AccentCyan = Color3.fromRGB(34, 211, 238)
local AccentSoft = Color3.fromRGB(196, 181, 253)
local TextBright = Color3.fromRGB(248, 250, 252)
local TextSub = Color3.fromRGB(148, 163, 184)
local DangerColor = Color3.fromRGB(244, 63, 94)
local SuccessColor = Color3.fromRGB(52, 211, 153)
local WarnColor = Color3.fromRGB(251, 191, 36)
local SeaColor = Color3.fromRGB(56, 189, 248)
local ChestColor = Color3.fromRGB(250, 204, 21)
local FruitColor = Color3.fromRGB(192, 132, 252)

local BoatSpeedEnabled = false
local TargetBoatSpeed = 180
local AutoSailEnabled = false
local LockedSailDir = nil
local BoatNoclipEnabled = false
local AutoChestEnabled = false
local AutoAttackSeaEnabled = false
local WalkSpeedEnabled = false
local TargetWalkSpeed = 120
local AutoQuestFarmEnabled = false
local StayAndWaitRespawn = true
local FarmVampireEnabled = false
local FarmDemonicSoulEnabled = false
local FarmDragonScaleEnabled = false
local FarmBonesEnabled = false
local BringMobsEnabled = true
local AutoQuestEnabled = true
local AntiAFKEnabled = true
local ESPEnabled = true
local ChestESPEnabled = false
local RemoveFogEnabled = false
local FruitESPEnabled = false
local AutoGetFruitsEnabled = false
local AutoStoreFruitEnabled = false
local AutoRollFruitEnabled = false
local PvPEnabled = false
local AimBotEnabled = false
local PvPSpeed = 340
local SelectedPvPPlayer = nil
local FlySpeed = 300
local BringRadius = 240
local ScriptRunning = true
local ActiveMode = "NONE"

local LastHitTick = 0
local LastPvPClickTick = 0
local LastRollTick = 0
local LastStoreTick = 0
local LastQuestTick = 0
local SavedFogState = nil

local HydraIslandFallbackPos = Vector3.new(5750, 610, -280)
local HauntedCastleFallbackPos = Vector3.new(-9500, 145, 6080)
local SubmergedFallbackPos = Vector3.new(10850, -2100, 9400)

local EnemyDatabase = {
	{minLvl = 1, maxLvl = 14, enemy = "Bandit", questNpc = "Bandit Quest Giver", questNum = 1, island = "Starter Island", pos = Vector3.new(1060, 17, 1545)},
	{minLvl = 15, maxLvl = 29, enemy = "Monkey", questNpc = "Monkey Quest Giver", questNum = 1, island = "Jungle", pos = Vector3.new(-1598, 36, 153)},
	{minLvl = 30, maxLvl = 59, enemy = "Pirate", questNpc = "Pirate Quest Giver", questNum = 1, island = "Pirate Village", pos = Vector3.new(-1140, 48, 3828)},
	{minLvl = 60, maxLvl = 89, enemy = "Brute", questNpc = "Brute Quest Giver", questNum = 1, island = "Pirate Village", pos = Vector3.new(-1145, 148, 4315)},
	{minLvl = 90, maxLvl = 119, enemy = "Snow Bandit", questNpc = "Snow Quest Giver", questNum = 1, island = "Frozen Village", pos = Vector3.new(1390, 88, -1405)},
	{minLvl = 120, maxLvl = 149, enemy = "Chief Petty Officer", questNpc = "Marine Quest Giver", questNum = 1, island = "Marine Fortress", pos = Vector3.new(-2850, 75, 2060)},
	{minLvl = 150, maxLvl = 199, enemy = "Sky Bandit", questNpc = "Sky Quest Giver", questNum = 1, island = "Skylands", pos = Vector3.new(-4920, 718, -2620)},
	{minLvl = 200, maxLvl = 249, enemy = "Prisoner", questNpc = "Prison Quest Giver", questNum = 1, island = "Prison", pos = Vector3.new(4850, 88, 740)},
	{minLvl = 250, maxLvl = 299, enemy = "Toga Warrior", questNpc = "Colosseum Quest Giver", questNum = 1, island = "Colosseum", pos = Vector3.new(-1820, 45, -2790)},
	{minLvl = 300, maxLvl = 374, enemy = "Military Soldier", questNpc = "Magma Quest Giver", questNum = 1, island = "Magma Village", pos = Vector3.new(-5415, 110, 5950)},
	{minLvl = 375, maxLvl = 449, enemy = "Fishman Warrior", questNpc = "Fishman Quest Giver", questNum = 1, island = "Underwater City", pos = Vector3.new(61120, 19, 1569)},
	{minLvl = 450, maxLvl = 624, enemy = "God's Guard", questNpc = "Sky Quest Giver 2", questNum = 1, island = "Upper Skylands", pos = Vector3.new(-4720, 845, -1940)},
	{minLvl = 625, maxLvl = 699, enemy = "Galley Pirate", questNpc = "Fountain Quest Giver", questNum = 1, island = "Fountain City", pos = Vector3.new(5555, 165, 4000)},
	{minLvl = 700, maxLvl = 774, enemy = "Raider", questNpc = "Area 1 Quest Giver", questNum = 1, island = "Kingdom of Rose", pos = Vector3.new(-740, 39, 2340)},
	{minLvl = 775, maxLvl = 874, enemy = "Swan Pirate", questNpc = "Area 2 Quest Giver", questNum = 1, island = "Kingdom of Rose", pos = Vector3.new(1050, 120, 1300)},
	{minLvl = 875, maxLvl = 999, enemy = "Marine Lieutenant", questNpc = "Marine Quest Giver 2", questNum = 1, island = "Green Zone", pos = Vector3.new(-2500, 120, -3050)},
	{minLvl = 1000, maxLvl = 1099, enemy = "Snow Trooper", questNpc = "Snow Mountain Quest Giver", questNum = 1, island = "Snow Mountain", pos = Vector3.new(550, 420, -5300)},
	{minLvl = 1100, maxLvl = 1249, enemy = "Lab Subordinate", questNpc = "Hot and Cold Quest Giver", questNum = 1, island = "Hot and Cold", pos = Vector3.new(-5750, 45, -5100)},
	{minLvl = 1250, maxLvl = 1399, enemy = "Ship Deckhand", questNpc = "Ship Quest Giver", questNum = 1, island = "Cursed Ship", pos = Vector3.new(920, 125, 32800)},
	{minLvl = 1400, maxLvl = 1499, enemy = "Arctic Warrior", questNpc = "Frost Quest Giver", questNum = 1, island = "Ice Castle", pos = Vector3.new(5660, 125, -6480)},
	{minLvl = 1500, maxLvl = 1574, enemy = "Pirate Millionaire", questNpc = "Port Quest Giver", questNum = 1, island = "Port Town", pos = Vector3.new(-290, 44, 5580)},
	{minLvl = 1575, maxLvl = 1699, enemy = "Dragon Crew Warrior", questNpc = "Hydra Quest Giver", questNum = 1, island = "Hydra Island", pos = Vector3.new(6300, 290, 950)},
	{minLvl = 1700, maxLvl = 1774, enemy = "Marine Commodore", questNpc = "Tree Quest Giver", questNum = 1, island = "Great Tree", pos = Vector3.new(2280, 125, -7500)},
	{minLvl = 1775, maxLvl = 1899, enemy = "Fishman Raider", questNpc = "Turtle Quest Giver", questNum = 1, island = "Floating Turtle", pos = Vector3.new(-10500, 330, -8750)},
	{minLvl = 1900, maxLvl = 1974, enemy = "Forest Pirate", questNpc = "Turtle Quest Giver 2", questNum = 1, island = "Floating Turtle", pos = Vector3.new(-13250, 330, -7760)},
	{minLvl = 1975, maxLvl = 2074, enemy = "Reborn Skeleton", questNpc = "Haunted Quest Giver", questNum = 1, island = "Haunted Castle", pos = Vector3.new(-8760, 142, 6060)},
	{minLvl = 2075, maxLvl = 2124, enemy = "Peanut Scout", questNpc = "Nuts Quest Giver", questNum = 1, island = "Sea of Treats", pos = Vector3.new(-2100, 40, -10100)},
	{minLvl = 2125, maxLvl = 2199, enemy = "Ice Cream Chef", questNpc = "Ice Cream Quest Giver", questNum = 1, island = "Ice Cream Island", pos = Vector3.new(-815, 66, -10960)},
	{minLvl = 2200, maxLvl = 2299, enemy = "Cookie Crafter", questNpc = "Cake Quest Giver", questNum = 1, island = "Cake Land", pos = Vector3.new(-2020, 38, -12020)},
	{minLvl = 2300, maxLvl = 2449, enemy = "Cocoa Warrior", questNpc = "Chocolate Quest Giver", questNum = 1, island = "Chocolate Island", pos = Vector3.new(230, 25, -12200)},
	{minLvl = 2450, maxLvl = 2549, enemy = "Sun-kissed Warrior", questNpc = "Tiki Quest Giver 1", questNum = 1, island = "Tiki Outpost", pos = Vector3.new(-16540, 55, 1050)},
	{minLvl = 2550, maxLvl = 2599, enemy = "Serpent Hunter", questNpc = "Tiki Quest Giver 2", questNum = 1, island = "Tiki Outpost", pos = Vector3.new(-16540, 55, 1050)},
	{minLvl = 2600, maxLvl = 2649, enemy = "Reef Bandit", questNpc = "Submerged Quest Giver 1", questNum = 1, island = "Submerged Island", pos = SubmergedFallbackPos},
	{minLvl = 2650, maxLvl = 2699, enemy = "Sea Chanter", questNpc = "Submerged Quest Giver 2", questNum = 1, island = "Submerged Island", pos = SubmergedFallbackPos},
	{minLvl = 2700, maxLvl = 2724, enemy = "Ocean Prophet", questNpc = "Submerged Quest Giver 3", questNum = 1, island = "Submerged Island", pos = SubmergedFallbackPos},
	{minLvl = 2725, maxLvl = 2749, enemy = "High Disciple", questNpc = "Submerged Quest Giver 3", questNum = 2, island = "Submerged Island", pos = SubmergedFallbackPos},
	{minLvl = 2750, maxLvl = 3000, enemy = "Grand Devotee", questNpc = "Submerged Quest Giver 4", questNum = 1, island = "Submerged Island", pos = SubmergedFallbackPos}
}

local AllowedChestNames = {
	"GoldChest",
	"SilverChest",
	"DiamondChest"
}

local BloxFruitNames = {
	"Rocket Fruit", "Spin Fruit", "Blade Fruit", "Chop Fruit", "Spring Fruit",
	"Bomb Fruit", "Smoke Fruit", "Spike Fruit", "Flame Fruit", "Falcon Fruit",
	"Ice Fruit", "Sand Fruit", "Dark Fruit", "Diamond Fruit", "Light Fruit",
	"Rubber Fruit", "Barrier Fruit", "Ghost Fruit", "Magma Fruit", "Quake Fruit",
	"Buddha Fruit", "Love Fruit", "Spider Fruit", "Sound Fruit", "Phoenix Fruit",
	"Portal Fruit", "Rumble Fruit", "Pain Fruit", "Paw Fruit", "Blizzard Fruit",
	"Gravity Fruit", "Mammoth Fruit", "T-Rex Fruit", "Dough Fruit", "Shadow Fruit",
	"Venom Fruit", "Control Fruit", "Gas Fruit", "Spirit Fruit", "Leopard Fruit",
	"Yeti Fruit", "Dragon Fruit", "Kitsune Fruit"
}

local BloxFruitLookup = {}
for _, fruitName in ipairs(BloxFruitNames) do
	local lower = string.lower(fruitName)
	BloxFruitLookup[lower] = fruitName
	local withoutSuffix = string.gsub(lower, "%s*fruit%s*$", "")
	if withoutSuffix ~= "" then
		BloxFruitLookup[withoutSuffix] = fruitName
		BloxFruitLookup[withoutSuffix .. "-" .. withoutSuffix] = fruitName
	end
end

local TrackedPlayers = {}
local TrackedNPCs = {}
local TrackedChests = {}
local TrackedFruits = {}
local SeaEventKeywords = {"seabeast", "sea beast", "terror", "shark", "leviathan", "piranha", "ship", "ghost", "mirage", "kitsune"}

local function captureOriginalFogState()
	if SavedFogState then
		return
	end
	pcall(function()
		local state = {
			FogStart = Lighting.FogStart,
			FogEnd = Lighting.FogEnd,
			FogColor = Lighting.FogColor,
			Atmospheres = {},
			Effects = {}
		}
		for _, obj in ipairs(Lighting:GetDescendants()) do
			if obj:IsA("Atmosphere") then
				state.Atmospheres[obj] = {Density = obj.Density, Haze = obj.Haze, Glare = obj.Glare}
			elseif obj:IsA("ColorCorrectionEffect") or obj:IsA("BlurEffect") then
				state.Effects[obj] = obj.Enabled
			end
		end
		for _, obj in ipairs(Camera:GetDescendants()) do
			if obj:IsA("Atmosphere") then
				state.Atmospheres[obj] = {Density = obj.Density, Haze = obj.Haze, Glare = obj.Glare}
			elseif obj:IsA("ColorCorrectionEffect") or obj:IsA("BlurEffect") then
				state.Effects[obj] = obj.Enabled
			end
		end
		SavedFogState = state
	end)
end

local function restoreOriginalFogState()
	if not SavedFogState then
		return
	end
	pcall(function()
		Lighting.FogStart = SavedFogState.FogStart
		Lighting.FogEnd = SavedFogState.FogEnd
		Lighting.FogColor = SavedFogState.FogColor
		for obj, props in pairs(SavedFogState.Atmospheres) do
			if obj and obj.Parent then
				obj.Density = props.Density
				obj.Haze = props.Haze
				obj.Glare = props.Glare
			end
		end
		for obj, wasEnabled in pairs(SavedFogState.Effects) do
			if obj and obj.Parent then
				obj.Enabled = wasEnabled
			end
		end
	end)
	SavedFogState = nil
end

local function clearSeaFog()
	pcall(function()
		captureOriginalFogState()
		Lighting.FogStart = 100000
		Lighting.FogEnd = 1000000
		Lighting.FogColor = Color3.fromRGB(190, 225, 255)
		for _, obj in ipairs(Lighting:GetDescendants()) do
			if obj:IsA("Atmosphere") then
				if SavedFogState and not SavedFogState.Atmospheres[obj] then
					SavedFogState.Atmospheres[obj] = {Density = obj.Density, Haze = obj.Haze, Glare = obj.Glare}
				end
				obj.Density = 0
				obj.Haze = 0
				obj.Glare = 0
			elseif obj:IsA("ColorCorrectionEffect") or obj:IsA("BlurEffect") then
				local n = string.lower(obj.Name)
				if string.find(n, "fog") or string.find(n, "danger") or string.find(n, "sea") or string.find(n, "dark") then
					if SavedFogState and SavedFogState.Effects[obj] == nil then
						SavedFogState.Effects[obj] = obj.Enabled
					end
					obj.Enabled = false
				end
			end
		end
	end)
end

local function isSeaEvent(name)
	local lower = string.lower(tostring(name))
	for _, kw in ipairs(SeaEventKeywords) do
		if string.find(lower, kw) then
			return true
		end
	end
	return false
end

local function isVampireEnemy(model)
	if not model or not model.Name then
		return false
	end
	return string.find(string.lower(tostring(model.Name)), "vampire") ~= nil
end

local function isDemonicSoulEnemy(model)
	if not model or not model.Name then
		return false
	end
	return string.find(string.lower(tostring(model.Name)), "demonic soul") ~= nil
end

local function isDragonScaleEnemy(model)
	if not model or not model.Name then
		return false
	end
	local lower = string.lower(tostring(model.Name))
	return string.find(lower, "dragon crew warrior") ~= nil or string.find(lower, "dragon crew archer") ~= nil
end

local function isBoneEnemy(model)
	if not model or not model.Name then
		return false
	end
	local lower = string.lower(tostring(model.Name))
	return string.find(lower, "reborn skeleton") ~= nil or string.find(lower, "living zombie") ~= nil or string.find(lower, "demonic soul") ~= nil or string.find(lower, "posessed mummy") ~= nil or string.find(lower, "possessed mummy") ~= nil
end

local function getPlayerLevel()
	local ok, lvl = pcall(function()
		local data = LocalPlayer:FindFirstChild("Data")
		local levelVal = data and data:FindFirstChild("Level")
		if levelVal and typeof(levelVal.Value) == "number" then
			return levelVal.Value
		end
		local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
		local lsLevel = leaderstats and (leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("Lvl"))
		if lsLevel and typeof(lsLevel.Value) == "number" then
			return lsLevel.Value
		end
		return 1
	end)
	return ok and lvl or 1
end

local function getLevelBracketEntry(lvl)
	local chosen = EnemyDatabase[1]
	for _, entry in ipairs(EnemyDatabase) do
		if lvl >= entry.minLvl and lvl <= entry.maxLvl then
			chosen = entry
			break
		elseif lvl >= entry.minLvl then
			chosen = entry
		end
	end
	return chosen
end

local function findSpawnAnchorForEnemy(enemyName, fallbackPos)
	local ok, pos = pcall(function()
		local lowerTarget = string.lower(tostring(enemyName))
		local spawns = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
		if spawns then
			for _, sp in ipairs(spawns:GetChildren()) do
				if string.find(string.lower(sp.Name), lowerTarget, 1, true) then
					local part = sp:IsA("BasePart") and sp or sp:FindFirstChildWhichIsA("BasePart", true)
					if part then
						return part.Position + Vector3.new(0, 14, 0)
					end
				end
			end
		end
		local enemiesFolder = Workspace:FindFirstChild("Enemies")
		if enemiesFolder then
			for _, en in ipairs(enemiesFolder:GetChildren()) do
				if string.find(string.lower(en.Name), lowerTarget, 1, true) then
					local r = en:FindFirstChild("HumanoidRootPart")
					if r then
						return r.Position + Vector3.new(0, 12, 0)
					end
				end
			end
		end
		return fallbackPos
	end)
	return (ok and pos) or fallbackPos
end

local function getHydraDragonScalePosition()
	local ok, pos = pcall(function()
		local map = Workspace:FindFirstChild("Map")
		if map then
			local hydra = map:FindFirstChild("HydraIsland") or map:FindFirstChild("Hydra Island") or map:FindFirstChild("Hydra")
			if hydra then
				local part = hydra:IsA("BasePart") and hydra or hydra.PrimaryPart or hydra:FindFirstChildWhichIsA("BasePart", true)
				if part then
					return part.Position + Vector3.new(0, 120, 0)
				end
			end
		end
		return findSpawnAnchorForEnemy("Dragon Crew", HydraIslandFallbackPos)
	end)
	return (ok and pos) or HydraIslandFallbackPos
end

local function getHauntedCastleBonesPosition()
	local ok, pos = pcall(function()
		local map = Workspace:FindFirstChild("Map")
		if map then
			local castle = map:FindFirstChild("HauntedCastle") or map:FindFirstChild("Haunted Castle")
			if castle then
				local part = castle:IsA("BasePart") and castle or castle.PrimaryPart or castle:FindFirstChildWhichIsA("BasePart", true)
				if part then
					return part.Position + Vector3.new(0, 35, 0)
				end
			end
		end
		return findSpawnAnchorForEnemy("Reborn Skeleton", HauntedCastleFallbackPos)
	end)
	return (ok and pos) or HauntedCastleFallbackPos
end

local function resolveBloxFruitName(rawName)
	if not rawName then
		return nil
	end
	local lower = string.lower(tostring(rawName))
	lower = string.gsub(lower, "^%s*(.-)%s*$", "%1")
	lower = string.gsub(lower, "%s+fruit%s+fruit%s*$", " fruit")
	if BloxFruitLookup[lower] then
		return BloxFruitLookup[lower]
	end
	local stripped = string.gsub(lower, "%s*fruit%s*$", "")
	if BloxFruitLookup[stripped] then
		return BloxFruitLookup[stripped]
	end
	local dashBase = string.match(lower, "^([a-z%-]+)%-[a-z%-]+$")
	if dashBase and BloxFruitLookup[dashBase] then
		return BloxFruitLookup[dashBase]
	end
	for _, fullName in ipairs(BloxFruitNames) do
		local fLower = string.lower(fullName)
		local fBase = string.gsub(fLower, "%s*fruit%s*$", "")
		if lower == fLower or lower == fBase or lower == (fBase .. "-" .. fBase) then
			return fullName
		end
	end
	return nil
end

local function getStoreFruitKey(item, resolvedName)
	if item and item:GetAttribute("FruitName") then
		return tostring(item:GetAttribute("FruitName"))
	end
	local base = string.gsub(resolvedName, "%s*Fruit%s*$", "")
	return base .. "-" .. base
end

local function isPickupableFruitInstance(obj)
	if not obj or not obj.Name or not obj.Parent then
		return false
	end
	if Players:GetPlayerFromCharacter(obj) or obj:FindFirstAncestorWhichIsA("Player") then
		return false
	end
	if not resolveBloxFruitName(obj.Name) then
		return false
	end
	if obj:IsA("Tool") then
		return true
	end
	if obj:IsA("Model") then
		if obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("TouchTransmitter", true) or obj:FindFirstChildWhichIsA("ProximityPrompt", true) or obj:FindFirstChildWhichIsA("ClickDetector", true) then
			return true
		end
	elseif obj:IsA("BasePart") then
		if obj.Name == "Handle" or obj:FindFirstChildWhichIsA("TouchTransmitter", true) or obj:FindFirstChildWhichIsA("ProximityPrompt", true) or obj:FindFirstChildWhichIsA("ClickDetector", true) then
			return true
		end
	end
	return false
end

local function getFruitAnchorPart(obj)
	if not obj or not obj.Parent then
		return nil
	end
	if obj:IsA("BasePart") then
		return obj
	end
	if obj:IsA("Model") then
		return obj:FindFirstChild("Handle") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
	end
	if obj:IsA("Tool") then
		return obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function hasActiveTargetFarm()
	return AutoQuestFarmEnabled or FarmVampireEnabled or FarmDemonicSoulEnabled or FarmDragonScaleEnabled or FarmBonesEnabled
end

local function moveToPositionSmooth(root, targetPos, speed, maxTime)
	if not root or not root.Parent then
		return
	end
	local dist = (root.Position - targetPos).Magnitude
	if dist <= 6 then
		root.CFrame = CFrame.new(targetPos)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		return
	end
	local dur = math.clamp(dist / math.max(speed, 60), 0.04, maxTime or 8)
	local tw = TweenService:Create(root, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
	tw:Play()
	local t0 = tick()
	while ScriptRunning and (tick() - t0) < dur do
		if not root.Parent then
			pcall(function() tw:Cancel() end)
			return
		end
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		task.wait(0.03)
	end
	pcall(function() tw:Cancel() end)
end

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
	for _, gui in ipairs(playerGui:GetChildren()) do
		if gui.Name == "NexoaroHubV3" or gui.Name == "NexoaroController" then
			gui:Destroy()
		end
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexoaroHubV3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = playerGui

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local UIScale = Instance.new("UIScale")
UIScale.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.BackgroundColor3 = BgVoid
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local function applyDeviceLayout()
	local vp = Camera.ViewportSize
	isMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) or vp.X < 750
	if isMobile then
		MainFrame.Size = UDim2.new(0, 326, 0, 385)
		UIScale.Scale = math.clamp(vp.Y / 480, 0.72, 0.96)
	else
		MainFrame.Size = UDim2.new(0, 445, 0, 460)
		UIScale.Scale = math.clamp(vp.Y / 900, 0.88, 1.15)
	end
end

MainFrame.Position = isMobile and UDim2.new(0.03, 0, 0.10, 0) or UDim2.new(0.02, 0, 0.20, 0)
applyDeviceLayout()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyDeviceLayout)

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = AccentPrimary
mainStroke.Thickness = 1.6
mainStroke.Transparency = 0.18

local mainGrad = Instance.new("UIGradient", MainFrame)
mainGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 16, 32)),
	ColorSequenceKeypoint.new(0.55, BgVoid),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 11, 22))
})
mainGrad.Rotation = 135

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, isMobile and 40 or 46)
TopBar.BackgroundColor3 = BgPanel
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topAccentLine = Instance.new("Frame")
topAccentLine.Size = UDim2.new(1, 0, 0, 2)
topAccentLine.Position = UDim2.new(0, 0, 1, -2)
topAccentLine.BackgroundColor3 = AccentCyan
topAccentLine.BorderSizePixel = 0
topAccentLine.Parent = TopBar

local topLineGrad = Instance.new("UIGradient", topAccentLine)
topLineGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, AccentPrimary),
	ColorSequenceKeypoint.new(0.5, AccentCyan),
	ColorSequenceKeypoint.new(1, AccentPrimary)
})

local BrandBadge = Instance.new("Frame")
BrandBadge.Size = UDim2.new(0, 24, 0, 24)
BrandBadge.Position = UDim2.new(0, 10, 0.5, -12)
BrandBadge.BackgroundColor3 = AccentPrimary
BrandBadge.BorderSizePixel = 0
BrandBadge.Parent = TopBar
Instance.new("UICorner", BrandBadge).CornerRadius = UDim.new(0, 7)

local BadgeIcon = Instance.new("TextLabel")
BadgeIcon.Size = UDim2.new(1, 0, 1, 0)
BadgeIcon.BackgroundTransparency = 1
BadgeIcon.Text = "N"
BadgeIcon.TextColor3 = Color3.new(1, 1, 1)
BadgeIcon.Font = Enum.Font.GothamBlack
BadgeIcon.TextSize = 13
BadgeIcon.Parent = BrandBadge

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 96, 1, 0)
Title.Position = UDim2.new(0, 40, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NEXOARO"
Title.TextColor3 = TextBright
Title.Font = Enum.Font.GothamBlack
Title.TextSize = isMobile and 13 or 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubPill = Instance.new("Frame")
SubPill.Size = UDim2.new(0, 92, 0, 18)
SubPill.Position = UDim2.new(0, isMobile and 112 or 126, 0.5, -9)
SubPill.BackgroundColor3 = Color3.fromRGB(26, 31, 56)
SubPill.BorderSizePixel = 0
SubPill.Parent = TopBar
Instance.new("UICorner", SubPill).CornerRadius = UDim.new(1, 0)
local subStroke = Instance.new("UIStroke", SubPill)
subStroke.Color = AccentCyan
subStroke.Thickness = 1
subStroke.Transparency = 0.45

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 1, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "PRO V3 • HUB"
SubTitle.TextColor3 = AccentCyan
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextSize = 8.5
SubTitle.Parent = SubPill

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(0, 24, 0, 24)
ExitBtn.Position = UDim2.new(1, -32, 0.5, -12)
ExitBtn.BackgroundColor3 = DangerColor
ExitBtn.Text = "X"
ExitBtn.TextColor3 = Color3.new(1, 1, 1)
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.TextSize = 11
ExitBtn.Parent = TopBar
Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 7)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -60, 0.5, -12)
MinBtn.BackgroundColor3 = CardSurface
MinBtn.Text = "—"
MinBtn.TextColor3 = TextBright
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 11
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 7)

local OpenPill = Instance.new("TextButton")
OpenPill.Size = UDim2.new(0, 128, 0, 34)
OpenPill.Position = UDim2.new(0.02, 0, 0.1, 0)
OpenPill.BackgroundColor3 = BgPanel
OpenPill.Text = "⚡ NEXOARO V3"
OpenPill.TextColor3 = AccentCyan
OpenPill.Font = Enum.Font.GothamBold
OpenPill.TextSize = 11
OpenPill.Visible = false
OpenPill.Parent = ScreenGui
Instance.new("UICorner", OpenPill).CornerRadius = UDim.new(1, 0)
local pillStroke = Instance.new("UIStroke", OpenPill)
pillStroke.Color = AccentPrimary
pillStroke.Thickness = 1.5

MinBtn.MouseButton1Click:Connect(function()
	MainFrame.Visible = false
	OpenPill.Visible = true
end)

OpenPill.MouseButton1Click:Connect(function()
	MainFrame.Visible = true
	OpenPill.Visible = false
end)

ExitBtn.MouseButton1Click:Connect(function()
	ScriptRunning = false
	LockedSailDir = nil
	if RemoveFogEnabled then
		RemoveFogEnabled = false
		restoreOriginalFogState()
	end
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16
		end
	end)
	for _, esp in pairs(TrackedPlayers) do
		for _, d in pairs(esp) do
			pcall(function() d:Remove() end)
		end
	end
	for _, esp in pairs(TrackedNPCs) do
		pcall(function() if esp.Text then esp.Text:Remove() end end)
	end
	for _, esp in pairs(TrackedChests) do
		pcall(function() if esp.Text then esp.Text:Remove() end end)
	end
	for _, esp in pairs(TrackedFruits) do
		pcall(function() if esp.Text then esp.Text:Remove() end end)
	end
	pcall(function() ScreenGui:Destroy() end)
end)

local topOffset = isMobile and 40 or 46

local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, -20, 0, 28)
StatusCard.Position = UDim2.new(0, 10, 0, topOffset + 8)
StatusCard.BackgroundColor3 = CardSurface
StatusCard.BorderSizePixel = 0
StatusCard.Parent = MainFrame
Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 8)
local statusStroke = Instance.new("UIStroke", StatusCard)
statusStroke.Color = Color3.fromRGB(45, 52, 86)
statusStroke.Thickness = 1

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 1, 0)
StatusLabel.Position = UDim2.new(0, 8, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "●  Status: Ready • Lv." .. tostring(getPlayerLevel())
StatusLabel.TextColor3 = AccentCyan
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
StatusLabel.Parent = StatusCard

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, topOffset + 42)
TabBar.BackgroundColor3 = BgPanel
TabBar.BorderSizePixel = 0
TabBar.ClipsDescendants = true
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 3)
tabLayout.Parent = TabBar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 3)
tabPadding.PaddingRight = UDim.new(0, 3)
tabPadding.PaddingTop = UDim.new(0, 3)
tabPadding.PaddingBottom = UDim.new(0, 3)
tabPadding.Parent = TabBar

local function createTabButton(name, total)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1 / total, -3, 1, 0)
	tabBtn.BackgroundColor3 = CardSurface
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = name
	tabBtn.TextColor3 = TextSub
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = 9
	tabBtn.Parent = TabBar
	Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
	return tabBtn
end

local bodyTop = topOffset + 82
local Container1 = Instance.new("ScrollingFrame")
Container1.Size = UDim2.new(1, -20, 1, -(bodyTop + 10))
Container1.Position = UDim2.new(0, 10, 0, bodyTop)
Container1.BackgroundTransparency = 1
Container1.ScrollBarThickness = 3
Container1.ScrollBarImageColor3 = AccentCyan
Container1.CanvasSize = UDim2.new(0, 0, 0, 235)
Container1.Visible = true
Container1.Parent = MainFrame

local Container2 = Instance.new("ScrollingFrame")
Container2.Size = Container1.Size
Container2.Position = Container1.Position
Container2.BackgroundTransparency = 1
Container2.ScrollBarThickness = 3
Container2.ScrollBarImageColor3 = AccentCyan
Container2.CanvasSize = UDim2.new(0, 0, 0, 420)
Container2.Visible = false
Container2.Parent = MainFrame

local Container3 = Instance.new("ScrollingFrame")
Container3.Size = Container1.Size
Container3.Position = Container1.Position
Container3.BackgroundTransparency = 1
Container3.ScrollBarThickness = 3
Container3.ScrollBarImageColor3 = AccentCyan
Container3.CanvasSize = UDim2.new(0, 0, 0, 195)
Container3.Visible = false
Container3.Parent = MainFrame

local Container4 = Instance.new("ScrollingFrame")
Container4.Size = Container1.Size
Container4.Position = Container1.Position
Container4.BackgroundTransparency = 1
Container4.ScrollBarThickness = 3
Container4.ScrollBarImageColor3 = AccentCyan
Container4.CanvasSize = UDim2.new(0, 0, 0, 150)
Container4.Visible = false
Container4.Parent = MainFrame

local Container5 = Instance.new("ScrollingFrame")
Container5.Size = Container1.Size
Container5.Position = Container1.Position
Container5.BackgroundTransparency = 1
Container5.ScrollBarThickness = 3
Container5.ScrollBarImageColor3 = AccentCyan
Container5.CanvasSize = UDim2.new(0, 0, 0, 280)
Container5.Visible = false
Container5.Parent = MainFrame

local Container6 = Instance.new("ScrollingFrame")
Container6.Size = Container1.Size
Container6.Position = Container1.Position
Container6.BackgroundTransparency = 1
Container6.ScrollBarThickness = 3
Container6.ScrollBarImageColor3 = AccentCyan
Container6.CanvasSize = UDim2.new(0, 0, 0, 165)
Container6.Visible = false
Container6.Parent = MainFrame

local tab1Btn = createTabButton("Sea", 6)
local tab2Btn = createTabButton("Farm", 6)
local tab3Btn = createTabButton("Player", 6)
local tab4Btn = createTabButton("Visuals", 6)
local tab5Btn = createTabButton("PvP", 6)
local tab6Btn = createTabButton("Fruits", 6)

tab1Btn.BackgroundTransparency = 0
tab1Btn.BackgroundColor3 = AccentPrimary
tab1Btn.TextColor3 = Color3.new(1, 1, 1)

local function switchTab(activeBtn, activeContainer)
	for _, c in ipairs({Container1, Container2, Container3, Container4, Container5, Container6}) do
		c.Visible = false
	end
	for _, b in ipairs({tab1Btn, tab2Btn, tab3Btn, tab4Btn, tab5Btn, tab6Btn}) do
		b.BackgroundTransparency = 1
		b.TextColor3 = TextSub
	end
	activeContainer.Visible = true
	activeBtn.BackgroundTransparency = 0
	activeBtn.BackgroundColor3 = AccentPrimary
	activeBtn.TextColor3 = Color3.new(1, 1, 1)
end

tab1Btn.MouseButton1Click:Connect(function() switchTab(tab1Btn, Container1) end)
tab2Btn.MouseButton1Click:Connect(function() switchTab(tab2Btn, Container2) end)
tab3Btn.MouseButton1Click:Connect(function() switchTab(tab3Btn, Container3) end)
tab4Btn.MouseButton1Click:Connect(function() switchTab(tab4Btn, Container4) end)
tab5Btn.MouseButton1Click:Connect(function() switchTab(tab5Btn, Container5) end)
tab6Btn.MouseButton1Click:Connect(function() switchTab(tab6Btn, Container6) end)

local function makeDraggable(handle, target)
	local dragging, dragStart, startPos = false, nil, nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, input.Position, target.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			local scale = UIScale.Scale > 0 and UIScale.Scale or 1
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + (delta.X / scale), startPos.Y.Scale, startPos.Y.Offset + (delta.Y / scale))
		end
	end)
	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end
makeDraggable(TopBar, MainFrame)
makeDraggable(OpenPill, OpenPill)

local function createToggle(parent, text, yPos, defaultState, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 32)
	row.Position = UDim2.new(0, 2, 0, yPos)
	row.BackgroundColor3 = CardSurface
	row.BorderSizePixel = 0
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", row)
	stroke.Color = defaultState and AccentCyan or Color3.fromRGB(40, 47, 78)
	stroke.Thickness = 1

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -64, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = TextBright
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 10.5
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local state = defaultState or false
	local pill = Instance.new("TextButton")
	pill.Size = UDim2.new(0, 46, 0, 20)
	pill.Position = UDim2.new(1, -54, 0.5, -10)
	pill.BackgroundColor3 = state and AccentPrimary or Color3.fromRGB(30, 35, 58)
	pill.Text = state and "ON" or "OFF"
	pill.TextColor3 = state and Color3.new(1, 1, 1) or TextSub
	pill.Font = Enum.Font.GothamBold
	pill.TextSize = 9.5
	pill.Active = true
	pill.Parent = row
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

	local function setState(newState)
		state = newState
		pill.Text = state and "ON" or "OFF"
		pill.BackgroundColor3 = state and AccentPrimary or Color3.fromRGB(30, 35, 58)
		pill.TextColor3 = state and Color3.new(1, 1, 1) or TextSub
		stroke.Color = state and AccentCyan or Color3.fromRGB(40, 47, 78)
		pcall(function() callback(state, pill) end)
	end

	pill.MouseButton1Click:Connect(function()
		setState(not state)
	end)
	return row
end

local function createSlider(parent, yPos, prefix, minVal, maxVal, initialVal, onChange)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 42)
	card.Position = UDim2.new(0, 2, 0, yPos)
	card.BackgroundColor3 = CardSurface
	card.BorderSizePixel = 0
	card.Parent = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", card)
	stroke.Color = Color3.fromRGB(40, 47, 78)
	stroke.Thickness = 1

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -20, 0, 16)
	lbl.Position = UDim2.new(0, 10, 0, 5)
	lbl.BackgroundTransparency = 1
	lbl.Text = prefix .. ": " .. tostring(initialVal)
	lbl.TextColor3 = TextBright
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = card

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -20, 0, 7)
	bg.Position = UDim2.new(0, 10, 0, 26)
	bg.BackgroundColor3 = Color3.fromRGB(28, 33, 56)
	bg.BorderSizePixel = 0
	bg.Parent = card
	Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

	local initRatio = math.clamp((initialVal - minVal) / (maxVal - minVal), 0, 1)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(initRatio, 0, 1, 0)
	fill.BackgroundColor3 = AccentCyan
	fill.BorderSizePixel = 0
	fill.Parent = bg
	Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

	local dragging = false
	bg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			pcall(function()
				local relX = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
				fill.Size = UDim2.new(relX, 0, 1, 0)
				local val = math.floor(minVal + (relX * (maxVal - minVal)))
				lbl.Text = prefix .. ": " .. tostring(val)
				onChange(val)
			end)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	return card
end

local function clearBoatMover(seat)
	pcall(function()
		if not seat then
			return
		end
		local mover = seat:FindFirstChild("NexoaroBoatVel")
		if mover then
			mover:Destroy()
		end
		local boatModel = seat:FindFirstAncestorOfClass("Model")
		if boatModel then
			for _, desc in ipairs(boatModel:GetDescendants()) do
				if desc.Name == "NexoaroBoatVel" then
					desc:Destroy()
				end
			end
		end
	end)
end

local function captureStraightSailDirection(seat)
	local ok, dir = pcall(function()
		if not seat or not seat:IsA("BasePart") then
			return Vector3.new(0, 0, -1)
		end
		local boatModel = seat:FindFirstAncestorOfClass("Model")
		local primary = (boatModel and (boatModel.PrimaryPart or seat)) or seat
		local look = primary.CFrame.LookVector
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude < 0.01 then
			look = seat.CFrame.LookVector
			flat = Vector3.new(look.X, 0, look.Z)
		end
		if flat.Magnitude < 0.01 then
			return Vector3.new(0, 0, -1)
		end
		return flat.Unit
	end)
	return (ok and dir) or Vector3.new(0, 0, -1)
end

local function getBoatParts(seat)
	local parts = {}
	local seen = {}
	local function addPart(p)
		if p and p:IsA("BasePart") and not seen[p] then
			seen[p] = true
			table.insert(parts, p)
		end
	end
	if seat and seat:IsA("BasePart") then
		addPart(seat)
		local boatModel = seat:FindFirstAncestorOfClass("Model")
		if boatModel then
			addPart(boatModel.PrimaryPart)
			for _, obj in ipairs(boatModel:GetDescendants()) do
				if obj:IsA("BasePart") and not obj.Anchored then
					addPart(obj)
				end
			end
		end
	end
	return parts
end

local function applyLockedSailVelocity(seat, speed, dir)
	pcall(function()
		if not seat or not seat:IsA("BasePart") or not dir then
			return
		end
		local flatDir = Vector3.new(dir.X, 0, dir.Z)
		if flatDir.Magnitude < 0.01 then
			flatDir = Vector3.new(0, 0, -1)
		else
			flatDir = flatDir.Unit
		end

		local boatModel = seat:FindFirstAncestorOfClass("Model")
		local primary = (boatModel and (boatModel.PrimaryPart or seat)) or seat
		local targetVel = flatDir * speed

		for _, part in ipairs(getBoatParts(seat)) do
			if not part.Anchored then
				part.AssemblyLinearVelocity = Vector3.new(targetVel.X, part.AssemblyLinearVelocity.Y, targetVel.Z)
			end
		end

		local bv = primary:FindFirstChild("NexoaroBoatVel")
		if not bv or not bv:IsA("BodyVelocity") then
			if bv then
				bv:Destroy()
			end
			bv = Instance.new("BodyVelocity")
			bv.Name = "NexoaroBoatVel"
			bv.MaxForce = Vector3.new(1e7, 0, 1e7)
			bv.P = 1e5
			bv.Parent = primary
		end
		bv.Velocity = targetVel

		if seat:IsA("VehicleSeat") then
			seat.MaxSpeed = math.max(speed, 180)
			seat.Throttle = 1
			seat.Steer = 0
		end
	end)
end

createToggle(Container1, "Auto Sail (Stop on Event)", 0, false, function(state)
	AutoSailEnabled = state
	if state then
		pcall(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			LockedSailDir = (hum and hum.SeatPart) and captureStraightSailDirection(hum.SeatPart) or nil
		end)
	else
		LockedSailDir = nil
		pcall(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and hum.SeatPart then
				clearBoatMover(hum.SeatPart)
				if hum.SeatPart:IsA("VehicleSeat") then
					hum.SeatPart.Throttle = 0
					hum.SeatPart.Steer = 0
				end
			end
		end)
	end
end)
createToggle(Container1, "Boat Noclip (Rocks)", 38, false, function(state) BoatNoclipEnabled = state end)
createToggle(Container1, "Auto Chest (All Map)", 76, false, function(state) AutoChestEnabled = state end)
createToggle(Container1, "Boat Speed Boost", 114, false, function(state)
	BoatSpeedEnabled = state
	if not state then
		pcall(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and hum.SeatPart then
				clearBoatMover(hum.SeatPart)
			end
		end)
	end
end)
createSlider(Container1, 152, "Boat Speed", 16, 1000, TargetBoatSpeed, function(val) TargetBoatSpeed = val end)

createToggle(Container2, "Auto Farm (Level + Wait Respawn)", 0, false, function(state) AutoQuestFarmEnabled = state end)
createToggle(Container2, "Stay & Wait Respawn (No Island Hop)", 38, true, function(state) StayAndWaitRespawn = state end)
createToggle(Container2, "Farm Vampire (Fangs)", 76, false, function(state) FarmVampireEnabled = state end)
createToggle(Container2, "Farm Demonic Soul", 114, false, function(state) FarmDemonicSoulEnabled = state end)
createToggle(Container2, "Auto Farm Dragon Scale", 152, false, function(state) FarmDragonScaleEnabled = state end)
createToggle(Container2, "Auto Farm Bones", 190, false, function(state) FarmBonesEnabled = state end)
createToggle(Container2, "Bring Mobs Under You", 228, true, function(state) BringMobsEnabled = state end)
createToggle(Container2, "Auto Quest (Level Bracket)", 266, true, function(state) AutoQuestEnabled = state end)
createSlider(Container2, 304, "Farm Fly Speed", 60, 800, FlySpeed, function(val) FlySpeed = val end)

createToggle(Container3, "Walk Speed Boost", 0, false, function(state)
	WalkSpeedEnabled = state
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = state and TargetWalkSpeed or 16
		end
	end)
end)
createSlider(Container3, 38, "Walk Speed", 16, 350, TargetWalkSpeed, function(val)
	TargetWalkSpeed = val
	if WalkSpeedEnabled then
		pcall(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = val
			end
		end)
	end
end)
createToggle(Container3, "Auto Attack Sea Beast / Shark", 88, false, function(state) AutoAttackSeaEnabled = state end)
createToggle(Container3, "Anti-AFK Protection", 126, true, function(state) AntiAFKEnabled = state end)

createToggle(Container4, "ESP (Players & Sea)", 0, true, function(state) ESPEnabled = state end)
createToggle(Container4, "ESP (Chests)", 38, false, function(state) ChestESPEnabled = state end)
createToggle(Container4, "Remove Fog", 76, false, function(state)
	RemoveFogEnabled = state
	if state then
		clearSeaFog()
	else
		restoreOriginalFogState()
	end
end)

createToggle(Container5, "Auto Kill Target", 0, false, function(state) PvPEnabled = state end)
createToggle(Container5, "Aim Bot", 38, false, function(state) AimBotEnabled = state end)

local TargetCard = Instance.new("Frame")
TargetCard.Size = UDim2.new(1, -6, 0, 34)
TargetCard.Position = UDim2.new(0, 2, 0, 76)
TargetCard.BackgroundColor3 = CardSurface
TargetCard.BorderSizePixel = 0
TargetCard.Parent = Container5
Instance.new("UICorner", TargetCard).CornerRadius = UDim.new(0, 8)
local targetStroke = Instance.new("UIStroke", TargetCard)
targetStroke.Color = Color3.fromRGB(40, 47, 78)
targetStroke.Thickness = 1

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, -86, 1, 0)
TargetLabel.Position = UDim2.new(0, 10, 0, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Target: None"
TargetLabel.TextColor3 = TextBright
TargetLabel.Font = Enum.Font.GothamSemibold
TargetLabel.TextSize = 10
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.TextTruncate = Enum.TextTruncate.AtEnd
TargetLabel.Parent = TargetCard

local NextTargetBtn = Instance.new("TextButton")
NextTargetBtn.Size = UDim2.new(0, 68, 0, 22)
NextTargetBtn.Position = UDim2.new(1, -74, 0.5, -11)
NextTargetBtn.BackgroundColor3 = AccentPrimary
NextTargetBtn.Text = "Next Player"
NextTargetBtn.TextColor3 = Color3.new(1, 1, 1)
NextTargetBtn.Font = Enum.Font.GothamBold
NextTargetBtn.TextSize = 9.5
NextTargetBtn.Parent = TargetCard
Instance.new("UICorner", NextTargetBtn).CornerRadius = UDim.new(0, 6)

createSlider(Container5, 116, "PvP Follow Speed", 80, 900, PvPSpeed, function(val) PvPSpeed = val end)

local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(1, -6, 0, 102)
PlayerListFrame.Position = UDim2.new(0, 2, 0, 164)
PlayerListFrame.BackgroundColor3 = CardSurface
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ScrollBarThickness = 2
PlayerListFrame.ScrollBarImageColor3 = AccentCyan
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.Parent = Container5
Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0, 8)
local listStroke = Instance.new("UIStroke", PlayerListFrame)
listStroke.Color = Color3.fromRGB(40, 47, 78)
listStroke.Thickness = 1

createToggle(Container6, "Auto Get Fruits", 0, false, function(state) AutoGetFruitsEnabled = state end)
createToggle(Container6, "ESP Fruits", 38, false, function(state) FruitESPEnabled = state end)
createToggle(Container6, "Auto Store Fruit", 76, false, function(state) AutoStoreFruitEnabled = state end)
createToggle(Container6, "Auto Roll Fruit", 114, false, function(state) AutoRollFruitEnabled = state end)

local function selectPvPPlayer(plr)
	SelectedPvPPlayer = plr
	if plr and plr.Parent then
		TargetLabel.Text = "Target: " .. tostring(plr.Name)
		TargetLabel.TextColor3 = AccentCyan
	else
		TargetLabel.Text = "Target: None"
		TargetLabel.TextColor3 = TextSub
	end
end

local function refreshPlayerList()
	pcall(function()
		for _, child in ipairs(PlayerListFrame:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		local others = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				table.insert(others, p)
			end
		end
		if SelectedPvPPlayer and (not SelectedPvPPlayer.Parent or SelectedPvPPlayer == LocalPlayer) then
			SelectedPvPPlayer = others[1]
			selectPvPPlayer(SelectedPvPPlayer)
		elseif not SelectedPvPPlayer and #others > 0 then
			selectPvPPlayer(others[1])
		end
		for i, p in ipairs(others) do
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -10, 0, 24)
			btn.Position = UDim2.new(0, 5, 0, 4 + ((i - 1) * 28))
			local isSel = (p == SelectedPvPPlayer)
			btn.BackgroundColor3 = isSel and AccentPrimary or CardHover
			btn.Text = (isSel and "▶ " or "") .. tostring(p.Name)
			btn.TextColor3 = isSel and Color3.new(1, 1, 1) or TextBright
			btn.Font = Enum.Font.GothamSemibold
			btn.TextSize = 9.5
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.Parent = PlayerListFrame
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
			btn.MouseButton1Click:Connect(function()
				selectPvPPlayer(p)
				refreshPlayerList()
			end)
		end
		PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, math.max(20, 8 + (#others * 28)))
	end)
end

NextTargetBtn.MouseButton1Click:Connect(function()
	local others = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(others, p)
		end
	end
	if #others == 0 then
		selectPvPPlayer(nil)
		refreshPlayerList()
		return
	end
	local nextIdx = 1
	for i, p in ipairs(others) do
		if p == SelectedPvPPlayer then
			nextIdx = (i % #others) + 1
			break
		end
	end
	selectPvPPlayer(others[nextIdx])
	refreshPlayerList()
end)

Players.PlayerAdded:Connect(function()
	task.wait(0.2)
	refreshPlayerList()
end)
Players.PlayerRemoving:Connect(function(plr)
	if plr == SelectedPvPPlayer then
		SelectedPvPPlayer = nil
	end
	refreshPlayerList()
end)
refreshPlayerList()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		MainFrame.Visible = not MainFrame.Visible
		OpenPill.Visible = not MainFrame.Visible
	end
end)

LocalPlayer.Idled:Connect(function()
	if ScriptRunning and AntiAFKEnabled then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)
	end
end)

local function bindWalkSpeedGuard(char)
	pcall(function()
		if not char then
			return
		end
		local hum = char:WaitForChild("Humanoid", 5)
		if hum then
			hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				if ScriptRunning and WalkSpeedEnabled and hum.WalkSpeed ~= TargetWalkSpeed then
					hum.WalkSpeed = TargetWalkSpeed
				end
			end)
			if WalkSpeedEnabled then
				hum.WalkSpeed = TargetWalkSpeed
			end
		end
	end)
end

if LocalPlayer.Character then
	bindWalkSpeedGuard(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(bindWalkSpeedGuard)

local function hasActiveQuest()
	local ok, active = pcall(function()
		local main = playerGui:FindFirstChild("Main")
		local questFrame = main and main:FindFirstChild("Quest")
		if questFrame and questFrame.Visible then
			return true
		end
		for _, gui in ipairs(playerGui:GetDescendants()) do
			if gui:IsA("Frame") and string.find(string.lower(gui.Name), "quest") and gui.Visible then
				local titleLbl = gui:FindFirstChildWhichIsA("TextLabel", true)
				if titleLbl and titleLbl.Text ~= "" and not string.find(string.lower(titleLbl.Text), "select") then
					return true
				end
			end
		end
		return false
	end)
	return ok and active or false
end

local function ensureEquippedIfNone()
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		if not char or not hum or not backpack then
			return
		end
		if char:FindFirstChildOfClass("Tool") then
			return
		end
		local firstTool = backpack:FindFirstChildOfClass("Tool")
		if firstTool then
			hum:EquipTool(firstTool)
		end
	end)
end

local function tryTakeQuestForBracket(root, bracketEntry)
	if not bracketEntry then
		return
	end
	local now = tick()
	if (now - LastQuestTick) < 3.5 then
		return
	end
	LastQuestTick = now
	pcall(function()
		local questNpcName = string.lower(tostring(bracketEntry.questNpc or ""))
		local questNum = bracketEntry.questNum or 1
		for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
			if rem:IsA("RemoteFunction") or rem:IsA("RemoteEvent") then
				local n = string.lower(rem.Name)
				if string.find(n, "commf") or string.find(n, "quest") then
					if rem:IsA("RemoteFunction") then
						pcall(function() rem:InvokeServer("StartQuest", bracketEntry.questNpc, questNum) end)
					elseif rem:IsA("RemoteEvent") then
						pcall(function() rem:FireServer("StartQuest", bracketEntry.questNpc, questNum) end)
					end
				end
			end
		end
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and string.find(string.lower(obj.Name), questNpcName, 1, true) then
				local part = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
				if part and (root.Position - part.Position).Magnitude < 450 then
					moveToPositionSmooth(root, part.Position + Vector3.new(0, 2, -4), FlySpeed, 4)
					for _, desc in ipairs(obj:GetDescendants()) do
						if desc:IsA("ProximityPrompt") then
							pcall(function() fireproximityprompt(desc) end)
						elseif desc:IsA("ClickDetector") and fireclickdetector then
							pcall(function() fireclickdetector(desc) end)
						end
					end
					break
				end
			end
		end
	end)
end

local function storeFruitsInInventory()
	local now = tick()
	if (now - LastStoreTick) < 1.2 then
		return
	end
	LastStoreTick = now
	pcall(function()
		local containers = {LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}
		for _, cont in ipairs(containers) do
			if cont then
				for _, item in ipairs(cont:GetChildren()) do
					local resolvedFruit = item:IsA("Tool") and resolveBloxFruitName(item.Name) or nil
					if resolvedFruit then
						local fruitKey = getStoreFruitKey(item, resolvedFruit)
						for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
							if rem:IsA("RemoteFunction") or rem:IsA("RemoteEvent") then
								local n = string.lower(rem.Name)
								if string.find(n, "commf") or string.find(n, "store") or string.find(n, "fruit") or string.find(n, "inventory") then
									if rem:IsA("RemoteFunction") then
										pcall(function() rem:InvokeServer("StoreFruit", fruitKey, item) end)
										pcall(function() rem:InvokeServer("StoreFruit", resolvedFruit, item) end)
									elseif rem:IsA("RemoteEvent") then
										pcall(function() rem:FireServer("StoreFruit", fruitKey, item) end)
										pcall(function() rem:FireServer("StoreFruit", resolvedFruit, item) end)
									end
								end
							end
						end
					end
				end
			end
		end
	end)
end

local function tryAutoRollFruit()
	local now = tick()
	if (now - LastRollTick) < 2.0 then
		return
	end
	LastRollTick = now
	pcall(function()
		for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
			if rem:IsA("RemoteFunction") or rem:IsA("RemoteEvent") then
				local n = string.lower(rem.Name)
				if string.find(n, "roll") or string.find(n, "gacha") or string.find(n, "spin") or string.find(n, "fruit") then
					if rem:IsA("RemoteFunction") then
						pcall(function() rem:InvokeServer("Censor") end)
						pcall(function() rem:InvokeServer("RollFruit") end)
					elseif rem:IsA("RemoteEvent") then
						pcall(function() rem:FireServer("Censor") end)
						pcall(function() rem:FireServer("RollFruit") end)
					end
				end
			end
		end
	end)
end

local function getNearestDroppedFruit(myPos)
	local bestObj, bestPart, bestDist, bestName = nil, nil, math.huge, nil
	pcall(function()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if isPickupableFruitInstance(obj) then
				local part = getFruitAnchorPart(obj)
				if part and part.Parent then
					local d = (myPos - part.Position).Magnitude
					if d < bestDist then
						bestDist = d
						bestObj = obj
						bestPart = part
						bestName = resolveBloxFruitName(obj.Name) or obj.Name
					end
				end
			end
		end
	end)
	return bestObj, bestPart, bestDist, bestName
end

local function isPointerOverUI()
	local ok, over = pcall(function()
		if not MainFrame.Visible then
			return false
		end
		local mousePos = UserInputService:GetMouseLocation()
		local topLeft = MainFrame.AbsolutePosition
		local bottomRight = topLeft + MainFrame.AbsoluteSize
		return mousePos.X >= topLeft.X and mousePos.X <= bottomRight.X and mousePos.Y >= topLeft.Y and mousePos.Y <= bottomRight.Y
	end)
	return ok and over or false
end

local function getAimTargetPart(myRoot)
	local targetPlr = SelectedPvPPlayer
	if targetPlr and targetPlr.Parent and targetPlr ~= LocalPlayer then
		local tChar = targetPlr.Character
		local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
		local tPart = tChar and (tChar:FindFirstChild("Head") or tChar:FindFirstChild("HumanoidRootPart"))
		if tHum and tHum.Health > 0 and tPart then
			return tPart, targetPlr.Name
		end
	end
	if not myRoot then
		return nil, nil
	end
	local bestPart, bestName, bestDist = nil, nil, math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local pHum = p.Character:FindFirstChildOfClass("Humanoid")
			local pPart = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
			if pHum and pHum.Health > 0 and pPart then
				local d = (myRoot.Position - pPart.Position).Magnitude
				if d < bestDist then
					bestDist = d
					bestPart = pPart
					bestName = p.Name
				end
			end
		end
	end
	return bestPart, bestName
end

local function applyAimBot(root)
	if not AimBotEnabled or not root then
		return
	end
	pcall(function()
		local aimPart = getAimTargetPart(root)
		if aimPart then
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, aimPart.Position)
			local flatLook = CFrame.lookAt(root.Position, Vector3.new(aimPart.Position.X, root.Position.Y, aimPart.Position.Z))
			root.CFrame = CFrame.new(root.Position) * flatLook.Rotation
		end
	end)
end

local function triggerAutoClickerHit(char)
	local now = tick()
	if (now - LastPvPClickTick) < 0.025 then
		return
	end
	LastPvPClickTick = now
	pcall(function()
		local tool = char and char:FindFirstChildOfClass("Tool")
		if tool then
			tool:Activate()
		end
		local x = Camera.ViewportSize.X * 0.5
		local y = Camera.ViewportSize.Y * 0.5
		if VirtualInputManager then
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
		end
		VirtualUser:CaptureController()
		VirtualUser:ClickButton1(Vector2.new(x, y))
		if mouse1click then
			mouse1click()
		end
	end)
end

local function triggerHit(char)
	if isPointerOverUI() then
		return
	end
	local now = tick()
	if (now - LastHitTick) < 0.075 then
		return
	end
	LastHitTick = now
	pcall(function()
		local tool = char and char:FindFirstChildOfClass("Tool")
		if tool then
			tool:Activate()
		end
		local x = Camera.ViewportSize.X * 0.5
		local y = Camera.ViewportSize.Y * 0.5
		if VirtualInputManager then
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
			VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
		else
			VirtualUser:CaptureController()
			VirtualUser:ClickButton1(Vector2.new(x, y))
		end
	end)
end

local function getNearestByPredicate(myPos, predicate, maxSearchDist)
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		return nil, nil, nil, 0
	end
	local bestEnemy, bestRoot, bestHum, bestDist = nil, nil, nil, math.huge
	local count = 0
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if enemy:IsA("Model") and predicate(enemy) then
			local eRoot = enemy:FindFirstChild("HumanoidRootPart")
			local eHum = enemy:FindFirstChildOfClass("Humanoid")
			if eRoot and eHum and eHum.Health > 0 then
				local dist = (myPos - eRoot.Position).Magnitude
				if not maxSearchDist or dist <= maxSearchDist then
					count += 1
					if dist < bestDist then
						bestDist = dist
						bestEnemy = enemy
						bestRoot = eRoot
						bestHum = eHum
					end
				end
			end
		end
	end
	return bestEnemy, bestRoot, bestHum, count
end

local function matchesBracketEnemy(enemyModel, bracketEntry)
	if not enemyModel or not bracketEntry then
		return false
	end
	local eNameLower = string.lower(tostring(enemyModel.Name))
	local targetLower = string.lower(tostring(bracketEntry.enemy))
	return string.find(eNameLower, targetLower, 1, true) ~= nil
end

local function bringMobsUnderPlayer(centerPos, mainEnemyRoot, filterPredicate)
	if not BringMobsEnabled then
		return
	end
	pcall(function()
		local enemiesFolder = Workspace:FindFirstChild("Enemies")
		if not enemiesFolder then
			return
		end
		local stackPos = mainEnemyRoot and mainEnemyRoot.Position or (centerPos + Vector3.new(0, -6.5, 0))
		for _, enemy in ipairs(enemiesFolder:GetChildren()) do
			if enemy:IsA("Model") and (not filterPredicate or filterPredicate(enemy)) then
				local eRoot = enemy:FindFirstChild("HumanoidRootPart")
				local eHum = enemy:FindFirstChildOfClass("Humanoid")
				if eRoot and eHum and eHum.Health > 0 then
					local dist = (centerPos - eRoot.Position).Magnitude
					if dist <= BringRadius then
						for _, part in ipairs(enemy:GetDescendants()) do
							if part:IsA("BasePart") then
								part.CanCollide = false
								part.AssemblyLinearVelocity = Vector3.zero
								part.AssemblyAngularVelocity = Vector3.zero
							end
						end
						eRoot.Anchored = false
						eRoot.CFrame = CFrame.new(stackPos, Vector3.new(centerPos.X, stackPos.Y, centerPos.Z))
					end
				end
			end
		end
	end)
end

local function farmTargetModel(char, root, targetEnemy, tRoot, tHum, statusPrefix, statusColor, filterPredicate)
	if targetEnemy and tRoot and tHum and tHum.Health > 0 then
		StatusLabel.Text = "●  " .. statusPrefix .. " • " .. tostring(targetEnemy.Name)
		StatusLabel.TextColor3 = statusColor

		local targetPos = tRoot.Position + Vector3.new(0, 7, 0)
		local lookCF = CFrame.lookAt(targetPos, tRoot.Position)
		moveToPositionSmooth(root, targetPos, FlySpeed, 2.5)
		root.CFrame = lookCF
		Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tRoot.Position)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero

		bringMobsUnderPlayer(root.Position, tRoot, filterPredicate)
		if (root.Position - tRoot.Position).Magnitude <= 22 then
			triggerHit(char)
		end
		return true
	end
	return false
end

local function getActiveSeaEvent(myPos)
	local ok, rName, rDist = pcall(function()
		for model, esp in pairs(TrackedNPCs) do
			if model and model.Parent and esp and esp.Root and esp.Root.Parent and esp.Humanoid and esp.Humanoid.Health > 0 then
				if isSeaEvent(model.Name) then
					local dist = (myPos - esp.Root.Position).Magnitude
					if dist < 2500 then
						return model.Name, math.floor(dist)
					end
				end
			end
		end
		for _, folderName in ipairs({"SeaBeasts", "Enemies", "Boats"}) do
			local folder = Workspace:FindFirstChild(folderName)
			if folder then
				for _, obj in ipairs(folder:GetChildren()) do
					if obj and isSeaEvent(obj.Name) then
						local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
						if part then
							local dist = (myPos - part.Position).Magnitude
							if dist < 2500 then
								return obj.Name, math.floor(dist)
							end
						end
					end
				end
			end
		end
		return nil, nil
	end)
	if ok then
		return rName, rDist
	end
	return nil, nil
end

local function getChestDisplayName(part)
	if part and part.Parent and part.Parent ~= Workspace then
		local pName = part.Parent.Name
		for _, allowed in ipairs(AllowedChestNames) do
			if string.lower(pName) == string.lower(allowed) then
				return pName
			end
		end
	end
	return part and part.Name or "Chest"
end

local function isValidChestPart(part)
	if not part or not part:IsA("BasePart") or not part.Parent then
		return false
	end
	if part.Transparency >= 0.95 then
		return false
	end
	local lowerName = string.lower(part.Name)
	local parentLower = part.Parent and string.lower(part.Parent.Name) or ""
	if string.find(lowerName, "hitbox") or string.find(lowerName, "trigger") then
		return false
	end
	for _, allowed in ipairs(AllowedChestNames) do
		local aLower = string.lower(allowed)
		if lowerName == aLower or parentLower == aLower then
			return true
		end
	end
	return false
end

local function getNearestChest(myRoot)
	local nearestPart, shortestDist = nil, math.huge
	pcall(function()
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if isValidChestPart(obj) then
				local dist = (myRoot.Position - obj.Position).Magnitude
				if dist < shortestDist then
					shortestDist, nearestPart = dist, obj
				end
			end
		end
	end)
	return nearestPart, shortestDist
end

task.spawn(function()
	while ScriptRunning do
		task.wait(0.06)
		pcall(function()
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not root or not hum or hum.Health <= 0 then
				ActiveMode = "NONE"
				return
			end

			if PvPEnabled or AimBotEnabled then
				ActiveMode = "PVP"
				if AimBotEnabled then
					applyAimBot(root)
				end
				if PvPEnabled then
					local targetPlr = SelectedPvPPlayer
					if not targetPlr or not targetPlr.Parent or targetPlr == LocalPlayer then
						StatusLabel.Text = "●  PvP: Select a Player"
						StatusLabel.TextColor3 = WarnColor
						return
					end
					local tChar = targetPlr.Character
					local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
					local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
					if not tRoot or not tHum or tHum.Health <= 0 then
						StatusLabel.Text = "●  PvP: Waiting " .. tostring(targetPlr.Name)
						StatusLabel.TextColor3 = WarnColor
						return
					end
					ensureEquippedIfNone()
					StatusLabel.Text = "●  PvP Lock: " .. tostring(targetPlr.Name) .. " [" .. tostring(math.floor(tHum.Health)) .. " HP]"
					StatusLabel.TextColor3 = DangerColor
					local stickPos = tRoot.CFrame * CFrame.new(0, 0, 3.2)
					local goalCF = CFrame.lookAt(stickPos.Position, tRoot.Position)
					moveToPositionSmooth(root, goalCF.Position, PvPSpeed, 2.5)
					root.CFrame = goalCF
					Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tRoot.Position)
					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
					if (root.Position - tRoot.Position).Magnitude <= 22 then
						triggerAutoClickerHit(char)
					end
				end
				return
			end

			if AutoGetFruitsEnabled then
				ActiveMode = "FRUIT"
				local fruitObj, fruitPart, dist, fruitLabel = getNearestDroppedFruit(root.Position)
				if fruitObj and fruitPart and fruitPart.Parent then
					StatusLabel.Text = "●  Fruit: " .. tostring(fruitLabel) .. " [" .. tostring(math.floor(dist)) .. "m]"
					StatusLabel.TextColor3 = FruitColor
					local goalPos = fruitPart.Position + Vector3.new(0, 1.5, 0)
					moveToPositionSmooth(root, goalPos, math.max(FlySpeed, 140), 12)
					if fruitPart.Parent then
						root.CFrame = CFrame.new(goalPos)
						for _, desc in ipairs(fruitObj:GetDescendants()) do
							if desc:IsA("ProximityPrompt") then
								pcall(function() fireproximityprompt(desc) end)
							elseif desc:IsA("ClickDetector") and fireclickdetector then
								pcall(function() fireclickdetector(desc) end)
							end
						end
					end
				else
					StatusLabel.Text = "●  Auto Get Fruits: Scanning..."
					StatusLabel.TextColor3 = AccentSoft
				end
				return
			end

			if AutoChestEnabled then
				ActiveMode = "CHEST"
				local targetChest, dist = getNearestChest(root)
				if targetChest and isValidChestPart(targetChest) then
					StatusLabel.Text = "●  Chest: " .. tostring(getChestDisplayName(targetChest)) .. " [" .. tostring(math.floor(dist)) .. "m]"
					StatusLabel.TextColor3 = ChestColor
					local goalPos = targetChest.Position + Vector3.new(0, 2.5, 0)
					moveToPositionSmooth(root, goalPos, math.max(FlySpeed, 140), 12)
					if isValidChestPart(targetChest) then
						root.CFrame = CFrame.new(goalPos)
						root.AssemblyLinearVelocity = Vector3.zero
					end
				else
					StatusLabel.Text = "●  Auto Chest: Scanning Map..."
					StatusLabel.TextColor3 = ChestColor
				end
				return
			end

			if hasActiveTargetFarm() then
				ActiveMode = "FARM"
				local myLvl = getPlayerLevel()
				ensureEquippedIfNone()

				if FarmBonesEnabled then
					local pred = isBoneEnemy
					local bEnemy, bRoot, bHum = getNearestByPredicate(root.Position, pred, StayAndWaitRespawn and 320 or nil)
					if not farmTargetModel(char, root, bEnemy, bRoot, bHum, "Bones", Color3.fromRGB(226, 232, 240), pred) then
						local anchor = getHauntedCastleBonesPosition()
						StatusLabel.Text = "●  Bones • Waiting Respawn [" .. tostring(math.floor((root.Position - anchor).Magnitude)) .. "m]"
						StatusLabel.TextColor3 = WarnColor
						moveToPositionSmooth(root, anchor, FlySpeed, 8)
					end
					return
				end

				if FarmDragonScaleEnabled then
					local pred = isDragonScaleEnemy
					local sEnemy, sRoot, sHum = getNearestByPredicate(root.Position, pred, StayAndWaitRespawn and 320 or nil)
					if not farmTargetModel(char, root, sEnemy, sRoot, sHum, "Dragon Scale", Color3.fromRGB(251, 146, 60), pred) then
						local anchor = getHydraDragonScalePosition()
						StatusLabel.Text = "●  Dragon Scale • Waiting Respawn [" .. tostring(math.floor((root.Position - anchor).Magnitude)) .. "m]"
						StatusLabel.TextColor3 = WarnColor
						moveToPositionSmooth(root, anchor, FlySpeed, 8)
					end
					return
				end

				if FarmVampireEnabled then
					local pred = isVampireEnemy
					local vEnemy, vRoot, vHum = getNearestByPredicate(root.Position, pred, StayAndWaitRespawn and 320 or nil)
					if not farmTargetModel(char, root, vEnemy, vRoot, vHum, "Vampire", DangerColor, pred) then
						StatusLabel.Text = "●  Vampire • Waiting Respawn..."
						StatusLabel.TextColor3 = WarnColor
					end
					return
				end

				if FarmDemonicSoulEnabled then
					local pred = isDemonicSoulEnemy
					local dEnemy, dRoot, dHum = getNearestByPredicate(root.Position, pred, StayAndWaitRespawn and 320 or nil)
					if not farmTargetModel(char, root, dEnemy, dRoot, dHum, "Demonic Soul", FruitColor, pred) then
						StatusLabel.Text = "●  Demonic Soul • Waiting Respawn..."
						StatusLabel.TextColor3 = WarnColor
					end
					return
				end

				local bracket = getLevelBracketEntry(myLvl)
				local bracketPred = function(m)
					return matchesBracketEnemy(m, bracket)
				end

				if AutoQuestEnabled and not hasActiveQuest() then
					tryTakeQuestForBracket(root, bracket)
				end

				local searchRadius = StayAndWaitRespawn and 380 or nil
				local targetEnemy, eRoot, eHum = getNearestByPredicate(root.Position, bracketPred, searchRadius)
				if not targetEnemy and not StayAndWaitRespawn then
					targetEnemy, eRoot, eHum = getNearestByPredicate(root.Position, bracketPred, nil)
				end

				local tag = "Lv." .. tostring(myLvl) .. " [" .. tostring(bracket.minLvl) .. "-" .. tostring(bracket.maxLvl) .. "]"
				if not farmTargetModel(char, root, targetEnemy, eRoot, eHum, tag, SuccessColor, bracketPred) then
					local holdPos = findSpawnAnchorForEnemy(bracket.enemy, bracket.pos)
					local distToHold = (root.Position - holdPos).Magnitude
					StatusLabel.Text = "●  " .. tag .. " • Holding " .. tostring(bracket.enemy) .. " (Waiting Respawn)"
					StatusLabel.TextColor3 = WarnColor
					if distToHold > 14 then
						moveToPositionSmooth(root, holdPos, FlySpeed, 8)
					else
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
					end
				end
				return
			end

			ActiveMode = "NONE"
			if not AutoSailEnabled then
				StatusLabel.Text = "●  Status: Ready • Lv." .. tostring(getPlayerLevel())
				StatusLabel.TextColor3 = AccentCyan
			end
		end)
	end
end)

task.spawn(function()
	while ScriptRunning do
		task.wait(0.12)
		if AutoStoreFruitEnabled then
			storeFruitsInInventory()
		end
		if AutoRollFruitEnabled then
			tryAutoRollFruit()
		end
		if AutoAttackSeaEnabled then
			pcall(function()
				local myChar = LocalPlayer.Character
				local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if myRoot then
					for model, esp in pairs(TrackedNPCs) do
						if model and model.Parent and esp and esp.Root and esp.Humanoid and esp.Humanoid.Health > 0 then
							if isSeaEvent(model.Name) and (myRoot.Position - esp.Root.Position).Magnitude < 250 then
								ensureEquippedIfNone()
								triggerHit(myChar)
								break
							end
						end
					end
				end
			end)
		end
	end
end)

task.spawn(function()
	while ScriptRunning do
		task.wait(0.05)
		pcall(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if AutoSailEnabled and hum and hum.SeatPart and root then
				if not LockedSailDir then
					LockedSailDir = captureStraightSailDirection(hum.SeatPart)
				end
				local seat = hum.SeatPart
				local eventName, eventDist = getActiveSeaEvent(root.Position)
				if eventName then
					StatusLabel.Text = "●  EVENT: " .. tostring(eventName) .. " [" .. tostring(eventDist) .. "m]"
					StatusLabel.TextColor3 = SeaColor
					clearBoatMover(seat)
					if seat:IsA("VehicleSeat") then
						seat.Throttle = 0
						seat.Steer = 0
					end
				else
					if ActiveMode == "NONE" then
						StatusLabel.Text = "●  Auto Sailing (" .. tostring(TargetBoatSpeed) .. ")..."
						StatusLabel.TextColor3 = SuccessColor
					end
					applyLockedSailVelocity(seat, TargetBoatSpeed, LockedSailDir)
				end
			else
				LockedSailDir = nil
			end
		end)
	end
end)

RunService.Stepped:Connect(function()
	if not ScriptRunning then
		return
	end
	pcall(function()
		if RemoveFogEnabled then
			clearSeaFog()
		end
		local char = LocalPlayer.Character
		if not char then
			return
		end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")

		if hum and WalkSpeedEnabled and hum.WalkSpeed ~= TargetWalkSpeed then
			hum.WalkSpeed = TargetWalkSpeed
		end

		if AutoSailEnabled and hum and hum.SeatPart and root and LockedSailDir then
			if not getActiveSeaEvent(root.Position) then
				applyLockedSailVelocity(hum.SeatPart, TargetBoatSpeed, LockedSailDir)
			end
		end

		local noclipActive = AutoChestEnabled or hasActiveTargetFarm() or PvPEnabled or AutoGetFruitsEnabled or (BoatNoclipEnabled and hum and hum.SeatPart)
		if (hasActiveTargetFarm() or AutoChestEnabled or PvPEnabled or AutoGetFruitsEnabled) and root then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		if noclipActive then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.CanCollide then
					part.CanCollide = false
				end
			end
		end
		if BoatNoclipEnabled and hum and hum.SeatPart then
			local boatModel = hum.SeatPart:FindFirstAncestorOfClass("Model")
			if boatModel then
				for _, part in ipairs(boatModel:GetDescendants()) do
					if part:IsA("BasePart") and part.CanCollide then
						part.CanCollide = false
					end
				end
			end
		end
	end)
end)

if Drawing then
	local function createDrawing(drawType, properties)
		local ok, obj = pcall(function() return Drawing.new(drawType) end)
		if not ok or not obj then
			return nil
		end
		pcall(function()
			for k, v in pairs(properties) do
				obj[k] = v
			end
		end)
		return obj
	end

	local function addPlayer(player)
		pcall(function()
			if player == LocalPlayer or TrackedPlayers[player] then
				return
			end
			TrackedPlayers[player] = {
				Box = createDrawing("Square", {Thickness = 1.5, Color = AccentCyan, Filled = false, Visible = false}),
				Tracer = createDrawing("Line", {Thickness = 1.2, Color = AccentPrimary, Transparency = 0.7, Visible = false}),
				Name = createDrawing("Text", {Size = 12, Center = true, Outline = true, Color = Color3.new(1, 1, 1), Visible = false}),
				HealthBar = createDrawing("Square", {Thickness = 1, Filled = true, Visible = false}),
				HealthOutline = createDrawing("Square", {Thickness = 1, Filled = false, Color = Color3.new(0, 0, 0), Visible = false})
			}
		end)
	end

	local function removePlayer(player)
		pcall(function()
			local data = TrackedPlayers[player]
			if data then
				for _, d in pairs(data) do
					pcall(function() d:Remove() end)
				end
				TrackedPlayers[player] = nil
			end
		end)
	end

	local function addNPC(model)
		pcall(function()
			if TrackedNPCs[model] or not model:IsA("Model") or Players:GetPlayerFromCharacter(model) then
				return
			end
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			local rootPart = model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
			if not humanoid or not rootPart then
				return
			end
			local seaEvent = isSeaEvent(model.Name)
			TrackedNPCs[model] = {
				Root = rootPart,
				Humanoid = humanoid,
				IsSeaEvent = seaEvent,
				Text = createDrawing("Text", {Size = seaEvent and 13 or 11, Center = true, Outline = true, Color = seaEvent and SeaColor or DangerColor, Visible = false})
			}
		end)
	end

	local function removeNPC(model)
		pcall(function()
			local data = TrackedNPCs[model]
			if data then
				pcall(function() if data.Text then data.Text:Remove() end end)
				TrackedNPCs[model] = nil
			end
		end)
	end

	local function addChest(part)
		pcall(function()
			if TrackedChests[part] or not isValidChestPart(part) then
				return
			end
			TrackedChests[part] = {
				Part = part,
				Label = getChestDisplayName(part),
				Text = createDrawing("Text", {Size = 11, Center = true, Outline = true, Color = ChestColor, Visible = false})
			}
		end)
	end

	local function removeChest(part)
		pcall(function()
			local data = TrackedChests[part]
			if data then
				pcall(function() if data.Text then data.Text:Remove() end end)
				TrackedChests[part] = nil
			end
		end)
	end

	local function addFruit(obj)
		pcall(function()
			if TrackedFruits[obj] or not isPickupableFruitInstance(obj) then
				return
			end
			local part = getFruitAnchorPart(obj)
			if not part then
				return
			end
			TrackedFruits[obj] = {
				Object = obj,
				Part = part,
				Label = resolveBloxFruitName(obj.Name) or tostring(obj.Name),
				Text = createDrawing("Text", {Size = 12, Center = true, Outline = true, Color = FruitColor, Visible = false})
			}
		end)
	end

	local function removeFruit(obj)
		pcall(function()
			local data = TrackedFruits[obj]
			if data then
				pcall(function() if data.Text then data.Text:Remove() end end)
				TrackedFruits[obj] = nil
			end
		end)
	end

	for _, p in ipairs(Players:GetPlayers()) do
		addPlayer(p)
	end
	Players.PlayerAdded:Connect(addPlayer)
	Players.PlayerRemoving:Connect(removePlayer)

	local function scanFolder(folder)
		pcall(function()
			for _, obj in ipairs(folder:GetChildren()) do
				if isPickupableFruitInstance(obj) then
					addFruit(obj)
				end
				if obj:IsA("Model") then
					addNPC(obj)
					if isValidChestPart(obj.PrimaryPart) then
						addChest(obj.PrimaryPart)
					end
					for _, desc in ipairs(obj:GetDescendants()) do
						if isValidChestPart(desc) then
							addChest(desc)
						end
						if isPickupableFruitInstance(desc) then
							addFruit(desc)
						end
					end
				elseif obj:IsA("BasePart") then
					if isValidChestPart(obj) then
						addChest(obj)
					end
				elseif obj:IsA("Folder") then
					scanFolder(obj)
				end
			end
		end)
	end
	scanFolder(Workspace)

	Workspace.DescendantAdded:Connect(function(obj)
		pcall(function()
			if obj:IsA("Model") then
				task.wait(0.2)
				addNPC(obj)
				if isPickupableFruitInstance(obj) then
					addFruit(obj)
				end
			elseif obj:IsA("BasePart") then
				task.wait(0.1)
				if isValidChestPart(obj) then
					addChest(obj)
				elseif isPickupableFruitInstance(obj) then
					addFruit(obj)
				end
			elseif obj:IsA("Tool") and isPickupableFruitInstance(obj) then
				task.wait(0.1)
				addFruit(obj)
			end
		end)
	end)

	RunService.RenderStepped:Connect(function()
		if not ScriptRunning then
			return
		end
		pcall(function()
			local myChar = LocalPlayer.Character
			local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
			local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)

			if myHum and WalkSpeedEnabled and myHum.WalkSpeed ~= TargetWalkSpeed then
				myHum.WalkSpeed = TargetWalkSpeed
			end
			if BoatSpeedEnabled and myHum and myHum.SeatPart and myHum.SeatPart:IsA("VehicleSeat") then
				myHum.SeatPart.MaxSpeed = TargetBoatSpeed
			end

			for player, esp in pairs(TrackedPlayers) do
				if not ESPEnabled or not esp.Box then
					for _, d in pairs(esp) do
						d.Visible = false
					end
				else
					local char = player.Character
					local root = char and char:FindFirstChild("HumanoidRootPart")
					local hum = char and char:FindFirstChildOfClass("Humanoid")
					if root and hum and hum.Health > 0 then
						local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
						if onScreen then
							local head = char:FindFirstChild("Head") or root
							local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
							local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
							local height = math.abs(headPos.Y - legPos.Y)
							local width = height / 2

							esp.Box.Size = Vector2.new(width, height)
							esp.Box.Position = Vector2.new(pos.X - width / 2, headPos.Y)
							esp.Box.Visible = true

							esp.Tracer.From = viewportCenter
							esp.Tracer.To = Vector2.new(pos.X, headPos.Y)
							esp.Tracer.Visible = true

							local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
							esp.Name.Text = player.Name .. " [" .. dist .. "m]"
							esp.Name.Position = Vector2.new(pos.X, headPos.Y - 16)
							esp.Name.Visible = true

							local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
							local barH = height * hpPct
							esp.HealthBar.Size = Vector2.new(2, barH)
							esp.HealthBar.Position = Vector2.new(esp.Box.Position.X - 6, esp.Box.Position.Y + (height - barH))
							esp.HealthBar.Color = Color3.fromRGB(255 - (hpPct * 255), hpPct * 255, 0)
							esp.HealthBar.Visible = true

							esp.HealthOutline.Size = Vector2.new(4, height + 2)
							esp.HealthOutline.Position = Vector2.new(esp.Box.Position.X - 7, esp.Box.Position.Y - 1)
							esp.HealthOutline.Visible = true
						else
							for _, d in pairs(esp) do
								d.Visible = false
							end
						end
					else
						for _, d in pairs(esp) do
							d.Visible = false
						end
					end
				end
			end

			for model, esp in pairs(TrackedNPCs) do
				if not model.Parent or not esp.Root.Parent or esp.Humanoid.Health <= 0 then
					removeNPC(model)
				elseif not ESPEnabled or not esp.Text then
					if esp.Text then
						esp.Text.Visible = false
					end
				else
					local pos, onScreen = Camera:WorldToViewportPoint(esp.Root.Position)
					if onScreen then
						local dist = myRoot and math.floor((myRoot.Position - esp.Root.Position).Magnitude) or 0
						local tag = esp.IsSeaEvent and "[SEA] " or "[NPC] "
						esp.Text.Text = tag .. model.Name .. " [" .. dist .. "m]"
						esp.Text.Position = Vector2.new(pos.X, pos.Y)
						esp.Text.Visible = true
					else
						esp.Text.Visible = false
					end
				end
			end

			for part, esp in pairs(TrackedChests) do
				if not isValidChestPart(part) then
					removeChest(part)
				elseif not ChestESPEnabled or not esp.Text then
					if esp.Text then
						esp.Text.Visible = false
					end
				else
					local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
					if onScreen then
						local dist = myRoot and math.floor((myRoot.Position - part.Position).Magnitude) or 0
						esp.Text.Text = "[CHEST] " .. tostring(esp.Label) .. " [" .. dist .. "m]"
						esp.Text.Position = Vector2.new(pos.X, pos.Y)
						esp.Text.Visible = true
					else
						esp.Text.Visible = false
					end
				end
			end

			for obj, esp in pairs(TrackedFruits) do
				if not obj.Parent or not esp.Part or not esp.Part.Parent or not isPickupableFruitInstance(obj) then
					removeFruit(obj)
				elseif not FruitESPEnabled or not esp.Text then
					if esp.Text then
						esp.Text.Visible = false
					end
				else
					local pos, onScreen = Camera:WorldToViewportPoint(esp.Part.Position)
					if onScreen then
						local dist = myRoot and math.floor((myRoot.Position - esp.Part.Position).Magnitude) or 0
						esp.Text.Text = "[FRUIT] " .. tostring(esp.Label) .. " [" .. dist .. "m]"
						esp.Text.Position = Vector2.new(pos.X, pos.Y)
						esp.Text.Visible = true
					else
						esp.Text.Visible = false
					end
				end
			end
		end)
	end)
end

print("[NEXOARO V3] Loaded")
