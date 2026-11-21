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

local BgDark = Color3.fromRGB(9, 8, 15)
local CardDark = Color3.fromRGB(17, 15, 28)
local ThemeColor = Color3.fromRGB(168, 85, 247)
local AccentGlow = Color3.fromRGB(216, 180, 254)
local TextMain = Color3.fromRGB(246, 245, 255)
local TextMuted = Color3.fromRGB(154, 150, 178)
local EnemyColor = Color3.fromRGB(244, 63, 94)
local SeaBeastColor = Color3.fromRGB(56, 189, 248)
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
local TargetWalkSpeed = 100
local AutoQuestFarmEnabled = false
local FarmVampireEnabled = false
local FarmDemonicSoulEnabled = false
local FarmDragonScaleEnabled = false
local FarmBonesEnabled = false
local BringMobsEnabled = false
local AutoQuestEnabled = true
local FastAttackEnabled = true
local AutoHakiEnabled = true
local AntiAFKEnabled = true
local WalkOnWaterEnabled = false
local ESPEnabled = false
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
local FlySpeed = 320
local BringRadius = 280
local CurrentTween = nil
local ActiveTweenOwner = nil
local ScriptRunning = true
local LastHitTick = 0
local LastBringTick = 0
local LastRollTick = 0
local LastStoreTick = 0
local LastHakiTick = 0
local LastQuestAttemptTick = 0
local WaterPart = nil

local SavedFogState = nil
local LockedFarmBracket = nil

local HydraIslandFallbackPos = Vector3.new(5750, 610, -280)
local HauntedCastleFallbackPos = Vector3.new(-9500, 145, 6080)

local FightingStylesList = {
	{name = "Dark Step", argsList = {{"BuyBlackLeg"}}, toolKeywords = {"dark step", "black leg"}},
	{name = "Electric", argsList = {{"BuyElectro"}}, toolKeywords = {"electric", "electro"}},
	{name = "Water Kung Fu", argsList = {{"BuyFishmanKarate"}}, toolKeywords = {"water kung", "fishman karate"}},
	{name = "Dragon Breath", argsList = {{"BlackbeardReward", "DragonClaw", "1"}, {"BlackbeardReward", "DragonClaw", "2"}, {"BuyDragonClaw"}}, toolKeywords = {"dragon breath", "dragon claw"}},
	{name = "Superhuman", argsList = {{"BuySuperhuman"}}, toolKeywords = {"superhuman"}},
	{name = "Death Step", argsList = {{"BuyDeathStep"}}, toolKeywords = {"death step"}},
	{name = "Sharkman Karate", argsList = {{"BuySharkmanKarate"}}, toolKeywords = {"sharkman karate", "sharkman"}},
	{name = "Electric Claw", argsList = {{"BuyElectricClaw"}}, toolKeywords = {"electric claw"}},
	{name = "Dragon Talon", argsList = {{"BuyDragonTalon"}}, toolKeywords = {"dragon talon"}},
	{name = "Godhuman", argsList = {{"BuyGodhuman"}}, toolKeywords = {"godhuman"}},
	{name = "Sanguine Art", argsList = {{"BuySanguineArt"}}, toolKeywords = {"sanguine art", "sanguine"}}
}

local EnemyLevelBrackets = {
	{minLvl = 1, maxLvl = 9, keywords = {"bandit"}, questText = "Bandit"},
	{minLvl = 10, maxLvl = 14, keywords = {"monkey"}, questText = "Monkey"},
	{minLvl = 15, maxLvl = 29, keywords = {"gorilla"}, questText = "Gorilla"},
	{minLvl = 30, maxLvl = 39, keywords = {"pirate"}, questText = "Pirate"},
	{minLvl = 40, maxLvl = 59, keywords = {"brute"}, questText = "Brute"},
	{minLvl = 60, maxLvl = 74, keywords = {"desert bandit"}, questText = "Desert Bandit"},
	{minLvl = 75, maxLvl = 89, keywords = {"desert officer"}, questText = "Desert Officer"},
	{minLvl = 90, maxLvl = 99, keywords = {"snow bandit"}, questText = "Snow Bandit"},
	{minLvl = 100, maxLvl = 119, keywords = {"snowman"}, questText = "Snowman"},
	{minLvl = 120, maxLvl = 149, keywords = {"chief petty officer"}, questText = "Chief Petty Officer"},
	{minLvl = 150, maxLvl = 174, keywords = {"sky bandit"}, questText = "Sky Bandit"},
	{minLvl = 175, maxLvl = 189, keywords = {"dark master"}, questText = "Dark Master"},
	{minLvl = 190, maxLvl = 209, keywords = {"prisoner"}, questText = "Prisoner"},
	{minLvl = 210, maxLvl = 249, keywords = {"dangerous prisoner"}, questText = "Dangerous Prisoner"},
	{minLvl = 250, maxLvl = 274, keywords = {"toga warrior"}, questText = "Toga Warrior"},
	{minLvl = 275, maxLvl = 299, keywords = {"gladiator"}, questText = "Gladiator"},
	{minLvl = 300, maxLvl = 324, keywords = {"military soldier"}, questText = "Military Soldier"},
	{minLvl = 325, maxLvl = 374, keywords = {"military spy"}, questText = "Military Spy"},
	{minLvl = 375, maxLvl = 399, keywords = {"fishman warrior"}, questText = "Fishman Warrior"},
	{minLvl = 400, maxLvl = 449, keywords = {"fishman commando"}, questText = "Fishman Commando"},
	{minLvl = 450, maxLvl = 474, keywords = {"god's guard", "gods guard"}, questText = "God's Guard"},
	{minLvl = 475, maxLvl = 524, keywords = {"shanda"}, questText = "Shanda"},
	{minLvl = 525, maxLvl = 549, keywords = {"royal squad"}, questText = "Royal Squad"},
	{minLvl = 550, maxLvl = 624, keywords = {"royal soldier"}, questText = "Royal Soldier"},
	{minLvl = 625, maxLvl = 649, keywords = {"galley pirate"}, questText = "Galley Pirate"},
	{minLvl = 650, maxLvl = 699, keywords = {"galley captain"}, questText = "Galley Captain"},
	{minLvl = 700, maxLvl = 724, keywords = {"raider"}, questText = "Raider"},
	{minLvl = 725, maxLvl = 774, keywords = {"mercenary"}, questText = "Mercenary"},
	{minLvl = 775, maxLvl = 799, keywords = {"swan pirate"}, questText = "Swan Pirate"},
	{minLvl = 800, maxLvl = 874, keywords = {"factory staff"}, questText = "Factory Staff"},
	{minLvl = 875, maxLvl = 899, keywords = {"marine lieutenant"}, questText = "Marine Lieutenant"},
	{minLvl = 900, maxLvl = 949, keywords = {"marine captain"}, questText = "Marine Captain"},
	{minLvl = 950, maxLvl = 974, keywords = {"zombie"}, questText = "Zombie"},
	{minLvl = 975, maxLvl = 999, keywords = {"vampire"}, questText = "Vampire"},
	{minLvl = 1000, maxLvl = 1049, keywords = {"snow trooper"}, questText = "Snow Trooper"},
	{minLvl = 1050, maxLvl = 1099, keywords = {"winter warrior"}, questText = "Winter Warrior"},
	{minLvl = 1100, maxLvl = 1124, keywords = {"lab subordinate"}, questText = "Lab Subordinate"},
	{minLvl = 1125, maxLvl = 1174, keywords = {"horn warrior"}, questText = "Horn Warrior"},
	{minLvl = 1175, maxLvl = 1199, keywords = {"magma ninja"}, questText = "Magma Ninja"},
	{minLvl = 1200, maxLvl = 1249, keywords = {"lava pirate"}, questText = "Lava Pirate"},
	{minLvl = 1250, maxLvl = 1274, keywords = {"ship deckhand"}, questText = "Ship Deckhand"},
	{minLvl = 1275, maxLvl = 1299, keywords = {"ship engineer"}, questText = "Ship Engineer"},
	{minLvl = 1300, maxLvl = 1324, keywords = {"ship steward"}, questText = "Ship Steward"},
	{minLvl = 1325, maxLvl = 1349, keywords = {"ship officer"}, questText = "Ship Officer"},
	{minLvl = 1350, maxLvl = 1374, keywords = {"arctic warrior"}, questText = "Arctic Warrior"},
	{minLvl = 1375, maxLvl = 1424, keywords = {"snow lurker"}, questText = "Snow Lurker"},
	{minLvl = 1425, maxLvl = 1449, keywords = {"sea soldier"}, questText = "Sea Soldier"},
	{minLvl = 1450, maxLvl = 1474, keywords = {"water fighter"}, questText = "Water Fighter"},
	{minLvl = 1475, maxLvl = 1499, keywords = {"pirate millionaire"}, questText = "Pirate Millionaire"},
	{minLvl = 1500, maxLvl = 1524, keywords = {"pistol billionaire"}, questText = "Pistol Billionaire"},
	{minLvl = 1525, maxLvl = 1574, keywords = {"dragon crew warrior"}, questText = "Dragon Crew Warrior"},
	{minLvl = 1575, maxLvl = 1599, keywords = {"dragon crew archer"}, questText = "Dragon Crew Archer"},
	{minLvl = 1600, maxLvl = 1624, keywords = {"female island"}, questText = "Female Island"},
	{minLvl = 1625, maxLvl = 1649, keywords = {"giant sky island"}, questText = "Giant Sky Island"},
	{minLvl = 1650, maxLvl = 1699, keywords = {"head baker"}, questText = "Head Baker"},
	{minLvl = 1700, maxLvl = 1724, keywords = {"baking staff"}, questText = "Baking Staff"},
	{minLvl = 1725, maxLvl = 1749, keywords = {"cake guard"}, questText = "Cake Guard"},
	{minLvl = 1750, maxLvl = 1774, keywords = {"cookie crafter"}, questText = "Cookie Crafter"},
	{minLvl = 1775, maxLvl = 1799, keywords = {"cake queen"}, questText = "Cake Queen"},
	{minLvl = 1800, maxLvl = 1824, keywords = {"peanut president"}, questText = "Peanut President"},
	{minLvl = 1825, maxLvl = 1849, keywords = {"ice cream chef"}, questText = "Ice Cream Chef"},
	{minLvl = 1850, maxLvl = 1899, keywords = {"ice cream commander"}, questText = "Ice Cream Commander"},
	{minLvl = 1900, maxLvl = 1924, keywords = {"cookie disciple"}, questText = "Cookie Disciple"},
	{minLvl = 1925, maxLvl = 1974, keywords = {"mint mark"}, questText = "Mint Mark"},
	{minLvl = 1975, maxLvl = 1999, keywords = {"cocoa warrior"}, questText = "Cocoa Warrior"},
	{minLvl = 2000, maxLvl = 2024, keywords = {"chocolate bar battler"}, questText = "Chocolate Bar Battler"},
	{minLvl = 2025, maxLvl = 2049, keywords = {"sweet thief"}, questText = "Sweet Thief"},
	{minLvl = 2050, maxLvl = 2074, keywords = {"candy rebel"}, questText = "Candy Rebel"},
	{minLvl = 2075, maxLvl = 2099, keywords = {"candy pirate"}, questText = "Candy Pirate"},
	{minLvl = 2100, maxLvl = 2124, keywords = {"snow demon"}, questText = "Snow Demon"},
	{minLvl = 2125, maxLvl = 2149, keywords = {"isle outcast"}, questText = "Isle Outcast"},
	{minLvl = 2150, maxLvl = 2199, keywords = {"island boy"}, questText = "Island Boy"},
	{minLvl = 2200, maxLvl = 2224, keywords = {"sun-kissed warrior"}, questText = "Sun-kissed Warrior"},
	{minLvl = 2225, maxLvl = 2249, keywords = {"isle champion"}, questText = "Isle Champion"},
	{minLvl = 2250, maxLvl = 2274, keywords = {"serpent hunter"}, questText = "Serpent Hunter"},
	{minLvl = 2275, maxLvl = 2299, keywords = {"skull slayer"}, questText = "Skull Slayer"},
	{minLvl = 2300, maxLvl = 2349, keywords = {"reborn skeleton"}, questText = "Reborn Skeleton"},
	{minLvl = 2350, maxLvl = 2399, keywords = {"living zombie"}, questText = "Living Zombie"},
	{minLvl = 2400, maxLvl = 2449, keywords = {"demonic soul"}, questText = "Demonic Soul"},
	{minLvl = 2450, maxLvl = 2474, keywords = {"posessed mummy", "possessed mummy"}, questText = "Possessed Mummy"},
	{minLvl = 2475, maxLvl = 2524, keywords = {"peanut scout"}, questText = "Peanut Scout"},
	{minLvl = 2525, maxLvl = 2549, keywords = {"dragon crew"}, questText = "Dragon Crew"},
	{minLvl = 2550, maxLvl = 2574, keywords = {"hydra enforcer"}, questText = "Hydra Enforcer"},
	{minLvl = 2575, maxLvl = 2599, keywords = {"venous knight"}, questText = "Venous Knight"},
	{minLvl = 2600, maxLvl = 2624, keywords = {"marine commodore"}, questText = "Marine Commodore"},
	{minLvl = 2625, maxLvl = 2649, keywords = {"marine rear admiral"}, questText = "Marine Rear Admiral"},
	{minLvl = 2650, maxLvl = 2674, keywords = {"fishman raider"}, questText = "Fishman Raider"},
	{minLvl = 2675, maxLvl = 2699, keywords = {"fishman captain"}, questText = "Fishman Captain"},
	{minLvl = 2700, maxLvl = 2724, keywords = {"high disciple"}, questText = "High Disciple"},
	{minLvl = 2725, maxLvl = 9999, keywords = {"high disciple"}, questText = "High Disciple"}
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

local function stopTween(owner)
	if CurrentTween and (not owner or ActiveTweenOwner == owner) then
		pcall(function() CurrentTween:Cancel() end)
		CurrentTween = nil
		ActiveTweenOwner = nil
	end
end

local function startTween(root, owner, targetCF, speed, maxDur)
	if not root or not root.Parent then
		return
	end
	local dist = (root.Position - targetCF.Position).Magnitude
	if dist <= 3.0 then
		stopTween(owner)
		root.CFrame = targetCF
		return
	end
	local dur = math.clamp(dist / math.max(speed or FlySpeed, 60), 0.04, maxDur or 8)
	if CurrentTween and ActiveTweenOwner == owner then
		pcall(function() CurrentTween:Cancel() end)
	end
	ActiveTweenOwner = owner
	CurrentTween = TweenService:Create(root, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = targetCF})
	CurrentTween:Play()
end

local function getBracketForLevel(lvl)
	local targetLvl = tonumber(lvl) or 1
	local bestBracket = nil
	for _, b in ipairs(EnemyLevelBrackets) do
		if targetLvl >= b.minLvl and targetLvl <= b.maxLvl then
			return b
		end
		if b.minLvl <= targetLvl then
			bestBracket = b
		end
	end
	return bestBracket or EnemyLevelBrackets[1]
end

local function enemyMatchesBracket(enemyModel, bracket)
	if not enemyModel or not bracket then
		return false
	end
	local lowerName = string.lower(tostring(enemyModel.Name))
	for _, kw in ipairs(bracket.keywords) do
		if string.find(lowerName, string.lower(kw), 1, true) then
			return true
		end
	end
	return false
end

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
				obj.Density = 0
				obj.Haze = 0
				obj.Glare = 0
			elseif obj:IsA("ColorCorrectionEffect") or obj:IsA("BlurEffect") then
				local n = string.lower(obj.Name)
				if string.find(n, "fog") or string.find(n, "danger") or string.find(n, "sea") or string.find(n, "dark") then
					obj.Enabled = false
				end
			end
		end
	end)
end

local function ensureWalkOnWaterPart(rootPos)
	pcall(function()
		if not WalkOnWaterEnabled or not rootPos then
			if WaterPart then
				WaterPart:Destroy()
				WaterPart = nil
			end
			return
		end
		if not WaterPart or not WaterPart.Parent then
			WaterPart = Instance.new("Part")
			WaterPart.Name = "NexoaroSeaPlatform"
			WaterPart.Size = Vector3.new(28, 1, 28)
			WaterPart.Anchored = true
			WaterPart.CanCollide = true
			WaterPart.Transparency = 1
			WaterPart.Parent = Workspace
		end
		WaterPart.Position = Vector3.new(rootPos.X, -0.5, rootPos.Z)
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
	return model and model.Name and string.find(string.lower(tostring(model.Name)), "vampire") ~= nil
end

local function isDemonicSoulEnemy(model)
	return model and model.Name and string.find(string.lower(tostring(model.Name)), "demonic soul") ~= nil
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
	return string.find(lower, "reborn skeleton") ~= nil
		or string.find(lower, "living zombie") ~= nil
		or string.find(lower, "demonic soul") ~= nil
		or string.find(lower, "posessed mummy") ~= nil
		or string.find(lower, "possessed mummy") ~= nil
end

local function getSpawnPositionForKeywords(keywords, fallbackPos)
	local ok, pos = pcall(function()
		local spawns = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
		if spawns then
			for _, sp in ipairs(spawns:GetChildren()) do
				local lower = string.lower(sp.Name)
				for _, kw in ipairs(keywords or {}) do
					if string.find(lower, string.lower(kw), 1, true) then
						local part = sp:IsA("BasePart") and sp or sp:FindFirstChildWhichIsA("BasePart", true)
						if part then
							return part.Position + Vector3.new(0, 12, 0)
						end
					end
				end
			end
		end
		return fallbackPos
	end)
	return (ok and pos) or fallbackPos
end

local function getHydraDragonScalePosition()
	return getSpawnPositionForKeywords({"dragon crew warrior", "dragon crew archer"}, HydraIslandFallbackPos)
end

local function getHauntedCastleBonesPosition()
	return getSpawnPositionForKeywords({"reborn skeleton", "living zombie", "demonic soul"}, HauntedCastleFallbackPos)
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
	if obj:IsA("Model") or obj:IsA("BasePart") then
		if obj:FindFirstChild("Handle")
			or obj:FindFirstChildWhichIsA("TouchTransmitter", true)
			or obj:FindFirstChildWhichIsA("ProximityPrompt", true)
			or obj:FindFirstChildWhichIsA("ClickDetector", true)
			or obj.Name == "Handle" then
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

local function getCommF()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		local commf = remotes:FindFirstChild("CommF_")
		if commf then
			return commf
		end
	end
	for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
		if (rem:IsA("RemoteFunction") or rem:IsA("RemoteEvent")) and string.lower(rem.Name) == "commf_" then
			return rem
		end
	end
	return nil
end

local function invokeOrFireRemote(rem, ...)
	if not rem then
		return false
	end
	local args = {...}
	if rem:IsA("RemoteFunction") then
		return pcall(function()
			rem:InvokeServer(table.unpack(args))
		end)
	elseif rem:IsA("RemoteEvent") then
		return pcall(function()
			rem:FireServer(table.unpack(args))
		end)
	end
	return false
end

local function triggerAutoHaki()
	if not AutoHakiEnabled then
		return
	end
	local now = tick()
	if (now - LastHakiTick) < 8 then
		return
	end
	LastHakiTick = now
	pcall(function()
		local char = LocalPlayer.Character
		if not char or char:FindFirstChild("HasBuso") then
			return
		end
		local commf = getCommF()
		if commf then
			invokeOrFireRemote(commf, "Buso")
		end
	end)
end

LocalPlayer.Idled:Connect(function()
	if AntiAFKEnabled then
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new(Camera.ViewportSize.X * 0.5, Camera.ViewportSize.Y * 0.5))
		end)
	end
end)

local playerGui = LocalPlayer:WaitForChild("PlayerGui")
pcall(function()
	for _, gui in ipairs(playerGui:GetChildren()) do
		if gui.Name == "NexoaroController" then
			gui:Destroy()
		end
	end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexoaroController"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = playerGui

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local UIScale = Instance.new("UIScale")
UIScale.Parent = ScreenGui

local MainFrame = Instance.new("Frame")
MainFrame.BackgroundColor3 = BgDark
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local function applyDeviceLayout()
	local vp = Camera.ViewportSize
	isMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) or vp.X < 750

	if isMobile then
		MainFrame.Size = UDim2.new(0, 326, 0, 368)
		UIScale.Scale = math.clamp(vp.Y / 480, 0.72, 0.96)
	else
		MainFrame.Size = UDim2.new(0, 445, 0, 442)
		UIScale.Scale = math.clamp(vp.Y / 900, 0.88, 1.15)
	end
end

MainFrame.Position = isMobile and UDim2.new(0.03, 0, 0.11, 0) or UDim2.new(0.02, 0, 0.22, 0)
applyDeviceLayout()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(applyDeviceLayout)

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)
local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = ThemeColor
mainStroke.Thickness = 1.6
mainStroke.Transparency = 0.18

local mainGrad = Instance.new("UIGradient", MainFrame)
mainGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(18, 13, 30)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 7, 14))
})
mainGrad.Rotation = 135

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, isMobile and 38 or 44)
TopBar.BackgroundColor3 = CardDark
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topGrad = Instance.new("UIGradient", TopBar)
topGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(38, 18, 62)),
	ColorSequenceKeypoint.new(1, CardDark)
})
topGrad.Rotation = 90

local BrandDot = Instance.new("Frame")
BrandDot.Size = UDim2.new(0, 8, 0, 8)
BrandDot.Position = UDim2.new(0, 12, 0.5, -4)
BrandDot.BackgroundColor3 = ThemeColor
BrandDot.BorderSizePixel = 0
BrandDot.Parent = TopBar
Instance.new("UICorner", BrandDot).CornerRadius = UDim.new(1, 0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -95, 1, 0)
Title.Position = UDim2.new(0, 26, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NEXOARO"
Title.TextColor3 = TextMain
Title.Font = Enum.Font.GothamBlack
Title.TextSize = isMobile and 13 or 15
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 120, 1, 0)
SubTitle.Position = UDim2.new(0, isMobile and 88 or 104, 0, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "PRO SEA & FARM HUB"
SubTitle.TextColor3 = AccentGlow
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextSize = isMobile and 8.8 or 9.8
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = TopBar

local ExitBtn = Instance.new("TextButton")
ExitBtn.Size = UDim2.new(0, 24, 0, 24)
ExitBtn.Position = UDim2.new(1, -32, 0.5, -12)
ExitBtn.BackgroundColor3 = Color3.fromRGB(225, 29, 72)
ExitBtn.Text = "X"
ExitBtn.TextColor3 = Color3.new(1, 1, 1)
ExitBtn.Font = Enum.Font.GothamBold
ExitBtn.TextSize = 11
ExitBtn.Parent = TopBar
Instance.new("UICorner", ExitBtn).CornerRadius = UDim.new(0, 7)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -60, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(36, 33, 54)
MinBtn.Text = "-"
MinBtn.TextColor3 = TextMain
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 13
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 7)

local OpenPill = Instance.new("TextButton")
OpenPill.Size = UDim2.new(0, 116, 0, 32)
OpenPill.Position = UDim2.new(0.02, 0, 0.1, 0)
OpenPill.BackgroundColor3 = CardDark
OpenPill.Text = "◆ NEXOARO"
OpenPill.TextColor3 = AccentGlow
OpenPill.Font = Enum.Font.GothamBold
OpenPill.TextSize = 11
OpenPill.Visible = false
OpenPill.Parent = ScreenGui
Instance.new("UICorner", OpenPill).CornerRadius = UDim.new(1, 0)
local pillStroke = Instance.new("UIStroke", OpenPill)
pillStroke.Color = ThemeColor
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
	LockedFarmBracket = nil
	WalkOnWaterEnabled = false
	ensureWalkOnWaterPart(nil)
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
	stopTween()
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

local topOffset = isMobile and 38 or 44

local StatusCard = Instance.new("Frame")
StatusCard.Size = UDim2.new(1, -20, 0, 26)
StatusCard.Position = UDim2.new(0, 10, 0, topOffset + 8)
StatusCard.BackgroundColor3 = CardDark
StatusCard.BorderSizePixel = 0
StatusCard.Parent = MainFrame
Instance.new("UICorner", StatusCard).CornerRadius = UDim.new(0, 8)
local statusStroke = Instance.new("UIStroke", StatusCard)
statusStroke.Color = Color3.fromRGB(52, 44, 78)
statusStroke.Thickness = 1

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 1, 0)
StatusLabel.Position = UDim2.new(0, 8, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "●  Status: Ready"
StatusLabel.TextColor3 = TextMuted
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusCard

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, topOffset + 40)
TabBar.BackgroundColor3 = CardDark
TabBar.BorderSizePixel = 0
TabBar.ClipsDescendants = true
TabBar.Parent = MainFrame
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 8)

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 2)
tabLayout.Parent = TabBar

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingLeft = UDim.new(0, 2)
tabPadding.PaddingRight = UDim.new(0, 2)
tabPadding.PaddingTop = UDim.new(0, 3)
tabPadding.PaddingBottom = UDim.new(0, 3)
tabPadding.Parent = TabBar

local function createTabButton(name, total)
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1 / total, -2.5, 1, 0)
	tabBtn.BackgroundColor3 = Color3.fromRGB(24, 21, 38)
	tabBtn.BackgroundTransparency = 1
	tabBtn.Text = name
	tabBtn.TextColor3 = TextMuted
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = 8.4
	tabBtn.TextScaled = false
	tabBtn.Parent = TabBar
	Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
	return tabBtn
end

local bodyTop = topOffset + 80
local Container1 = Instance.new("ScrollingFrame")
Container1.Size = UDim2.new(1, -20, 1, -(bodyTop + 10))
Container1.Position = UDim2.new(0, 10, 0, bodyTop)
Container1.BackgroundTransparency = 1
Container1.ScrollBarThickness = 3
Container1.ScrollBarImageColor3 = ThemeColor
Container1.CanvasSize = UDim2.new(0, 0, 0, 240)
Container1.Visible = true
Container1.Parent = MainFrame

local Container2 = Instance.new("ScrollingFrame")
Container2.Size = Container1.Size
Container2.Position = Container1.Position
Container2.BackgroundTransparency = 1
Container2.ScrollBarThickness = 3
Container2.ScrollBarImageColor3 = ThemeColor
Container2.CanvasSize = UDim2.new(0, 0, 0, 420)
Container2.Visible = false
Container2.Parent = MainFrame

local Container3 = Instance.new("ScrollingFrame")
Container3.Size = Container1.Size
Container3.Position = Container1.Position
Container3.BackgroundTransparency = 1
Container3.ScrollBarThickness = 3
Container3.ScrollBarImageColor3 = ThemeColor
Container3.CanvasSize = UDim2.new(0, 0, 0, 240)
Container3.Visible = false
Container3.Parent = MainFrame

local Container4 = Instance.new("ScrollingFrame")
Container4.Size = Container1.Size
Container4.Position = Container1.Position
Container4.BackgroundTransparency = 1
Container4.ScrollBarThickness = 3
Container4.ScrollBarImageColor3 = ThemeColor
Container4.CanvasSize = UDim2.new(0, 0, 0, 160)
Container4.Visible = false
Container4.Parent = MainFrame

local Container5 = Instance.new("ScrollingFrame")
Container5.Size = Container1.Size
Container5.Position = Container1.Position
Container5.BackgroundTransparency = 1
Container5.ScrollBarThickness = 3
Container5.ScrollBarImageColor3 = ThemeColor
Container5.CanvasSize = UDim2.new(0, 0, 0, 275)
Container5.Visible = false
Container5.Parent = MainFrame

local Container6 = Instance.new("ScrollingFrame")
Container6.Size = Container1.Size
Container6.Position = Container1.Position
Container6.BackgroundTransparency = 1
Container6.ScrollBarThickness = 3
Container6.ScrollBarImageColor3 = ThemeColor
Container6.CanvasSize = UDim2.new(0, 0, 0, 160)
Container6.Visible = false
Container6.Parent = MainFrame

local Container7 = Instance.new("ScrollingFrame")
Container7.Size = Container1.Size
Container7.Position = Container1.Position
Container7.BackgroundTransparency = 1
Container7.ScrollBarThickness = 3
Container7.ScrollBarImageColor3 = ThemeColor
Container7.CanvasSize = UDim2.new(0, 0, 0, (#FightingStylesList * 38) + 12)
Container7.Visible = false
Container7.Parent = MainFrame

local tab1Btn = createTabButton("Sea", 7)
local tab2Btn = createTabButton("Farm", 7)
local tab3Btn = createTabButton("Player", 7)
local tab4Btn = createTabButton("Visuals", 7)
local tab5Btn = createTabButton("PvP", 7)
local tab6Btn = createTabButton("Fruits", 7)
local tab7Btn = createTabButton("Shop", 7)

tab1Btn.BackgroundTransparency = 0
tab1Btn.BackgroundColor3 = ThemeColor
tab1Btn.TextColor3 = Color3.new(1, 1, 1)

local function switchTab(activeBtn, activeContainer)
	for _, c in ipairs({Container1, Container2, Container3, Container4, Container5, Container6, Container7}) do
		c.Visible = false
	end
	for _, b in ipairs({tab1Btn, tab2Btn, tab3Btn, tab4Btn, tab5Btn, tab6Btn, tab7Btn}) do
		b.BackgroundTransparency = 1
		b.TextColor3 = TextMuted
	end
	activeContainer.Visible = true
	activeBtn.BackgroundTransparency = 0
	activeBtn.BackgroundColor3 = ThemeColor
	activeBtn.TextColor3 = Color3.new(1, 1, 1)
end

tab1Btn.MouseButton1Click:Connect(function() switchTab(tab1Btn, Container1) end)
tab2Btn.MouseButton1Click:Connect(function() switchTab(tab2Btn, Container2) end)
tab3Btn.MouseButton1Click:Connect(function() switchTab(tab3Btn, Container3) end)
tab4Btn.MouseButton1Click:Connect(function() switchTab(tab4Btn, Container4) end)
tab5Btn.MouseButton1Click:Connect(function() switchTab(tab5Btn, Container5) end)
tab6Btn.MouseButton1Click:Connect(function() switchTab(tab6Btn, Container6) end)
tab7Btn.MouseButton1Click:Connect(function() switchTab(tab7Btn, Container7) end)

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
	row.BackgroundColor3 = CardDark
	row.BorderSizePixel = 0
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", row)
	stroke.Color = defaultState and ThemeColor or Color3.fromRGB(42, 36, 64)
	stroke.Thickness = 1

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -62, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = TextMain
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 10.5
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local state = defaultState or false
	local pill = Instance.new("TextButton")
	pill.Size = UDim2.new(0, 44, 0, 20)
	pill.Position = UDim2.new(1, -52, 0.5, -10)
	pill.BackgroundColor3 = state and ThemeColor or Color3.fromRGB(34, 30, 50)
	pill.Text = state and "ON" or "OFF"
	pill.TextColor3 = state and Color3.new(1, 1, 1) or TextMuted
	pill.Font = Enum.Font.GothamBold
	pill.TextSize = 9.5
	pill.Active = true
	pill.Parent = row
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

	local function setState(newState)
		state = newState
		pill.Text = state and "ON" or "OFF"
		pill.BackgroundColor3 = state and ThemeColor or Color3.fromRGB(34, 30, 50)
		pill.TextColor3 = state and Color3.new(1, 1, 1) or TextMuted
		stroke.Color = state and ThemeColor or Color3.fromRGB(42, 36, 64)
		pcall(function() callback(state, pill) end)
	end

	pill.MouseButton1Click:Connect(function()
		setState(not state)
	end)
	return row
end

local function createActionButton(parent, text, buttonText, yPos, callback)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, -6, 0, 32)
	row.Position = UDim2.new(0, 2, 0, yPos)
	row.BackgroundColor3 = CardDark
	row.BorderSizePixel = 0
	row.Parent = parent
	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", row)
	stroke.Color = Color3.fromRGB(46, 39, 72)
	stroke.Thickness = 1

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -78, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = TextMain
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 10.5
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local actionBtn = Instance.new("TextButton")
	actionBtn.Size = UDim2.new(0, 58, 0, 20)
	actionBtn.Position = UDim2.new(1, -66, 0.5, -10)
	actionBtn.BackgroundColor3 = ThemeColor
	actionBtn.Text = buttonText
	actionBtn.TextColor3 = Color3.new(1, 1, 1)
	actionBtn.Font = Enum.Font.GothamBold
	actionBtn.TextSize = 9.5
	actionBtn.Active = true
	actionBtn.Parent = row
	Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

	actionBtn.MouseButton1Click:Connect(function()
		stroke.Color = AccentGlow
		actionBtn.BackgroundColor3 = Color3.fromRGB(139, 92, 246)
		pcall(function() callback(actionBtn) end)
		task.delay(0.25, function()
			if stroke and stroke.Parent then
				stroke.Color = Color3.fromRGB(46, 39, 72)
			end
			if actionBtn and actionBtn.Parent then
				actionBtn.BackgroundColor3 = ThemeColor
			end
		end)
	end)

	return row
end

local function createSlider(parent, yPos, prefix, minVal, maxVal, initialVal, onChange)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 42)
	card.Position = UDim2.new(0, 2, 0, yPos)
	card.BackgroundColor3 = CardDark
	card.BorderSizePixel = 0
	card.Parent = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", card)
	stroke.Color = Color3.fromRGB(42, 36, 64)
	stroke.Thickness = 1

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -20, 0, 16)
	lbl.Position = UDim2.new(0, 10, 0, 5)
	lbl.BackgroundTransparency = 1
	lbl.Text = prefix .. ": " .. tostring(initialVal)
	lbl.TextColor3 = TextMain
	lbl.Font = Enum.Font.GothamSemibold
	lbl.TextSize = 10
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = card

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, -20, 0, 7)
	bg.Position = UDim2.new(0, 10, 0, 26)
	bg.BackgroundColor3 = Color3.fromRGB(32, 28, 48)
	bg.BorderSizePixel = 0
	bg.Parent = card
	Instance.new("UICorner", bg).CornerRadius = UDim.new(1, 0)

	local initRatio = math.clamp((initialVal - minVal) / (maxVal - minVal), 0, 1)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(initRatio, 0, 1, 0)
	fill.BackgroundColor3 = ThemeColor
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

local function equipMatchingFightingStyle(styleEntry)
	local equipped = false
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		if not char or not hum then
			return
		end

		local function matchesStyleTool(tool)
			if not tool or not tool:IsA("Tool") then
				return false
			end
			local tName = string.lower(tool.Name)
			local tType = string.lower(tostring(tool.ToolTip or ""))
			for _, kw in ipairs(styleEntry.toolKeywords or {}) do
				local k = string.lower(kw)
				if string.find(tName, k, 1, true) or string.find(tType, k, 1, true) then
					return true
				end
			end
			return false
		end

		for _, item in ipairs(char:GetChildren()) do
			if matchesStyleTool(item) then
				equipped = true
				return
			end
		end

		if backpack then
			for _, item in ipairs(backpack:GetChildren()) do
				if matchesStyleTool(item) then
					hum:EquipTool(item)
					equipped = true
					return
				end
			end
		end
	end)
	return equipped
end

local function equipBestCombatTool()
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		if not char or not hum or not backpack then
			return
		end

		local current = char:FindFirstChildOfClass("Tool")
		if current and current.ToolTip ~= "Blox Fruit" then
			return
		end

		local preferred = nil
		local fallback = nil
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				local tip = tostring(tool.ToolTip or "")
				if tip == "Melee" or tip == "Sword" then
					preferred = preferred or tool
				elseif tip ~= "Blox Fruit" then
					fallback = fallback or tool
				end
			end
		end

		local chosen = preferred or fallback
		if chosen then
			hum:EquipTool(chosen)
		end
	end)
end

local function purchaseFightingStyle(styleEntry)
	StatusLabel.Text = "●  Shop: Buying " .. styleEntry.name .. "..."
	StatusLabel.TextColor3 = AccentGlow
	pcall(function()
		local commf = getCommF()
		if commf then
			for _, argPack in ipairs(styleEntry.argsList or {}) do
				invokeOrFireRemote(commf, table.unpack(argPack))
				task.wait(0.12)
			end
		end

		task.wait(0.25)
		if equipMatchingFightingStyle(styleEntry) then
			StatusLabel.Text = "●  Shop: Equipped " .. styleEntry.name
			StatusLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
		else
			StatusLabel.Text = "●  Shop: Sent Request (" .. styleEntry.name .. ")"
			StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
		end
	end)
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
	if ok and dir then
		return dir
	end
	return Vector3.new(0, 0, -1)
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
			seat.MaxSpeed = math.max(speed, 150)
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
			if hum and hum.SeatPart then
				LockedSailDir = captureStraightSailDirection(hum.SeatPart)
			else
				LockedSailDir = nil
			end
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
		StatusLabel.Text = "●  Status: Ready"
		StatusLabel.TextColor3 = TextMuted
	end
end)
createToggle(Container1, "Boat Noclip (Rocks)", 38, false, function(state) BoatNoclipEnabled = state end)
createToggle(Container1, "Auto Chest (All Map)", 76, false, function(state)
	AutoChestEnabled = state
	if not state then
		stopTween("Chest")
		StatusLabel.Text = "●  Status: Ready"
		StatusLabel.TextColor3 = TextMuted
	end
end)
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

createSlider(Container1, 152, "Boat Speed", 16, 1000, TargetBoatSpeed, function(val)
	TargetBoatSpeed = val
end)

createToggle(Container2, "Auto Farm Mobs (Level Locked)", 0, false, function(state)
	AutoQuestFarmEnabled = state
	if state then
		LockedFarmBracket = getBracketForLevel(getPlayerLevel())
	elseif not AutoQuestFarmEnabled then
		LockedFarmBracket = nil
	end
	if not hasActiveTargetFarm() then
		stopTween("Farm")
	end
end)
createToggle(Container2, "Farm Vampire (Fangs)", 38, false, function(state)
	FarmVampireEnabled = state
	if not hasActiveTargetFarm() then
		stopTween("Farm")
	end
end)
createToggle(Container2, "Farm Demonic Soul", 76, false, function(state)
	FarmDemonicSoulEnabled = state
	if not hasActiveTargetFarm() then
		stopTween("Farm")
	end
end)
createToggle(Container2, "Auto farm dragon scale", 114, false, function(state)
	FarmDragonScaleEnabled = state
	if not hasActiveTargetFarm() then
		stopTween("Farm")
	end
end)
createToggle(Container2, "Auto Farm Bones", 152, false, function(state)
	FarmBonesEnabled = state
	if not hasActiveTargetFarm() then
		stopTween("Farm")
	end
end)
createToggle(Container2, "Bring Mobs Under You", 190, false, function(state)
	BringMobsEnabled = state
end)
createToggle(Container2, "Auto Quest (Level Based)", 228, true, function(state)
	AutoQuestEnabled = state
end)
createToggle(Container2, "Fast Attack", 266, true, function(state)
	FastAttackEnabled = state
end)
createSlider(Container2, 304, "Farm Fly Speed", 60, 800, FlySpeed, function(val)
	FlySpeed = val
end)

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
createToggle(Container3, "Walk On Water", 88, false, function(state)
	WalkOnWaterEnabled = state
	if not state then
		ensureWalkOnWaterPart(nil)
	end
end)
createToggle(Container3, "Auto Haki (Buso)", 126, true, function(state)
	AutoHakiEnabled = state
end)
createToggle(Container3, "Anti AFK", 164, true, function(state)
	AntiAFKEnabled = state
end)
createToggle(Container3, "Auto Attack Sea Beast / Shark", 202, false, function(state)
	AutoAttackSeaEnabled = state
end)

createToggle(Container4, "ESP (Players & Sea)", 0, false, function(state) ESPEnabled = state end)
createToggle(Container4, "ESP (Chests)", 38, false, function(state) ChestESPEnabled = state end)
createToggle(Container4, "Remove Fog", 76, false, function(state)
	RemoveFogEnabled = state
	if state then
		clearSeaFog()
	else
		restoreOriginalFogState()
	end
end)

createToggle(Container5, "Auto Kill Target", 0, false, function(state)
	PvPEnabled = state
	if not state then
		stopTween("PvP")
		if not AimBotEnabled then
			StatusLabel.Text = "●  Status: Ready"
			StatusLabel.TextColor3 = TextMuted
		end
	end
end)

createToggle(Container5, "Aim Bot", 38, false, function(state)
	AimBotEnabled = state
	if not state and not PvPEnabled then
		StatusLabel.Text = "●  Status: Ready"
		StatusLabel.TextColor3 = TextMuted
	end
end)

local TargetCard = Instance.new("Frame")
TargetCard.Size = UDim2.new(1, -6, 0, 34)
TargetCard.Position = UDim2.new(0, 2, 0, 76)
TargetCard.BackgroundColor3 = CardDark
TargetCard.BorderSizePixel = 0
TargetCard.Parent = Container5
Instance.new("UICorner", TargetCard).CornerRadius = UDim.new(0, 8)
local targetStroke = Instance.new("UIStroke", TargetCard)
targetStroke.Color = Color3.fromRGB(42, 36, 64)
targetStroke.Thickness = 1

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, -86, 1, 0)
TargetLabel.Position = UDim2.new(0, 10, 0, 0)
TargetLabel.BackgroundTransparency = 1
TargetLabel.Text = "Target: None"
TargetLabel.TextColor3 = TextMain
TargetLabel.Font = Enum.Font.GothamSemibold
TargetLabel.TextSize = 10
TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
TargetLabel.TextTruncate = Enum.TextTruncate.AtEnd
TargetLabel.Parent = TargetCard

local NextTargetBtn = Instance.new("TextButton")
NextTargetBtn.Size = UDim2.new(0, 68, 0, 22)
NextTargetBtn.Position = UDim2.new(1, -74, 0.5, -11)
NextTargetBtn.BackgroundColor3 = ThemeColor
NextTargetBtn.Text = "Next Player"
NextTargetBtn.TextColor3 = Color3.new(1, 1, 1)
NextTargetBtn.Font = Enum.Font.GothamBold
NextTargetBtn.TextSize = 9.5
NextTargetBtn.Parent = TargetCard
Instance.new("UICorner", NextTargetBtn).CornerRadius = UDim.new(0, 6)

createSlider(Container5, 116, "PvP Follow Speed", 80, 900, PvPSpeed, function(val)
	PvPSpeed = val
end)

local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(1, -6, 0, 102)
PlayerListFrame.Position = UDim2.new(0, 2, 0, 164)
PlayerListFrame.BackgroundColor3 = CardDark
PlayerListFrame.BorderSizePixel = 0
PlayerListFrame.ScrollBarThickness = 2
PlayerListFrame.ScrollBarImageColor3 = ThemeColor
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.Parent = Container5
Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0, 8)
local listStroke = Instance.new("UIStroke", PlayerListFrame)
listStroke.Color = Color3.fromRGB(42, 36, 64)
listStroke.Thickness = 1

createToggle(Container6, "Auto Get Fruits", 0, false, function(state)
	AutoGetFruitsEnabled = state
	if not state then
		stopTween("Fruit")
		StatusLabel.Text = "●  Status: Ready"
		StatusLabel.TextColor3 = TextMuted
	end
end)

createToggle(Container6, "ESP Fruits", 38, false, function(state)
	FruitESPEnabled = state
end)

createToggle(Container6, "Auto Store Fruit", 76, false, function(state)
	AutoStoreFruitEnabled = state
end)

createToggle(Container6, "Auto Roll Fruit", 114, false, function(state)
	AutoRollFruitEnabled = state
end)

for i, styleEntry in ipairs(FightingStylesList) do
	createActionButton(Container7, styleEntry.name, "Buy", (i - 1) * 38, function()
		purchaseFightingStyle(styleEntry)
	end)
end

local function selectPvPPlayer(plr)
	SelectedPvPPlayer = plr
	if plr and plr.Parent then
		TargetLabel.Text = "Target: " .. tostring(plr.Name)
		TargetLabel.TextColor3 = AccentGlow
	else
		TargetLabel.Text = "Target: None"
		TargetLabel.TextColor3 = TextMuted
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
			btn.BackgroundColor3 = isSel and ThemeColor or Color3.fromRGB(26, 22, 42)
			btn.Text = (isSel and "▶ " or "") .. tostring(p.Name)
			btn.TextColor3 = isSel and Color3.new(1, 1, 1) or TextMain
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

local function hasActiveQuest()
	local ok, active = pcall(function()
		local main = playerGui:FindFirstChild("Main")
		local questFrame = main and main:FindFirstChild("Quest")
		if questFrame and questFrame.Visible then
			return true
		end
		return false
	end)
	return ok and active or false
end

local function storeFruitsInInventory()
	local now = tick()
	if (now - LastStoreTick) < 1.2 then
		return
	end
	LastStoreTick = now
	pcall(function()
		local commf = getCommF()
		local containers = {LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}
		for _, cont in ipairs(containers) do
			if cont then
				for _, item in ipairs(cont:GetChildren()) do
					local resolvedFruit = item:IsA("Tool") and resolveBloxFruitName(item.Name) or nil
					if resolvedFruit then
						local fruitKey = getStoreFruitKey(item, resolvedFruit)
						if commf then
							invokeOrFireRemote(commf, "StoreFruit", fruitKey, item)
							invokeOrFireRemote(commf, "StoreFruit", resolvedFruit, item)
						end
					end
				end
			end
		end
	end)
end

local function tryAutoRollFruit()
	local now = tick()
	if (now - LastRollTick) < 2.2 then
		return
	end
	LastRollTick = now
	pcall(function()
		local commf = getCommF()
		if commf then
			invokeOrFireRemote(commf, "Censor")
			invokeOrFireRemote(commf, "RollFruit")
		end
	end)
end

local function getNearestDroppedFruit(myPos)
	local bestObj, bestPart, bestDist, bestName = nil, nil, math.huge, nil
	pcall(function()
		for _, obj in ipairs(Workspace:GetChildren()) do
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

task.spawn(function()
	while ScriptRunning do
		task.wait(0.15)
		if AutoGetFruitsEnabled then
			pcall(function()
				local char = LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not root or not hum or hum.Health <= 0 then
					return
				end

				local fruitObj, fruitPart, dist, fruitLabel = getNearestDroppedFruit(root.Position)
				if fruitObj and fruitPart and fruitPart.Parent then
					StatusLabel.Text = "●  Fruit: " .. tostring(fruitLabel) .. " [" .. tostring(math.floor(dist)) .. "m]"
					StatusLabel.TextColor3 = FruitColor

					local goalCF = fruitPart.CFrame + Vector3.new(0, 1.5, 0)
					startTween(root, "Fruit", goalCF, FlySpeed, 12)

					if (root.Position - goalCF.Position).Magnitude <= 6 then
						stopTween("Fruit")
						root.CFrame = goalCF
						for _, desc in ipairs(fruitObj:GetDescendants()) do
							if desc:IsA("ProximityPrompt") and fireproximityprompt then
								pcall(function() fireproximityprompt(desc) end)
							elseif desc:IsA("ClickDetector") and fireclickdetector then
								pcall(function() fireclickdetector(desc) end)
							end
						end
					end
				else
					StatusLabel.Text = "●  Auto Get Fruits: Scanning Blox Fruits..."
					StatusLabel.TextColor3 = AccentGlow
				end
			end)
		end

		if AutoStoreFruitEnabled then
			storeFruitsInInventory()
		end

		if AutoRollFruitEnabled then
			tryAutoRollFruit()
		end
	end
end)

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

local function applyAimBot(char, root)
	if not AimBotEnabled or not char or not root then
		return
	end
	pcall(function()
		local aimPart, aimName = getAimTargetPart(root)
		if aimPart then
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, aimPart.Position)
			local flatLook = CFrame.lookAt(root.Position, Vector3.new(aimPart.Position.X, root.Position.Y, aimPart.Position.Z))
			root.CFrame = CFrame.new(root.Position) * flatLook.Rotation
			if not PvPEnabled and not AutoGetFruitsEnabled then
				StatusLabel.Text = "●  Aim Bot: " .. tostring(aimName)
				StatusLabel.TextColor3 = AccentGlow
			end
		end
	end)
end

local function fireCombatStrike(char, minCooldown, useExtraClicks)
	local now = tick()
	if (now - LastHitTick) < minCooldown then
		return
	end
	LastHitTick = now
	triggerAutoHaki()
	pcall(function()
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local tool = char and char:FindFirstChildOfClass("Tool")
		if not tool then
			equipBestCombatTool()
			tool = char and char:FindFirstChildOfClass("Tool")
		end
		if tool and hum and hum.Health > 0 then
			pcall(function() tool:Activate() end)
			local remote = tool:FindFirstChild("LeftClickRemote") or tool:FindFirstChildWhichIsA("RemoteEvent", true)
			if remote then
				pcall(function() remote:FireServer(1) end)
			end
		end
		local x = Camera.ViewportSize.X * 0.5
		local y = Camera.ViewportSize.Y * 0.5
		if VirtualInputManager then
			pcall(function() VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1) end)
			pcall(function() VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1) end)
		end
		pcall(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton1(Vector2.new(x, y))
		end)
		if useExtraClicks and mouse1click then
			pcall(function() mouse1click() end)
		end
	end)
end

local function triggerAutoClickerHit(char)
	fireCombatStrike(char, FastAttackEnabled and 0.09 or 0.16, true)
end

local function triggerHit(char)
	if isPointerOverUI() then
		return
	end
	fireCombatStrike(char, FastAttackEnabled and 0.11 or 0.18, false)
end

task.spawn(function()
	while ScriptRunning do
		task.wait(0.06)
		if PvPEnabled or AimBotEnabled then
			pcall(function()
				local char = LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not root or not hum or hum.Health <= 0 then
					return
				end

				if AimBotEnabled then
					applyAimBot(char, root)
				end

				if PvPEnabled then
					local targetPlr = SelectedPvPPlayer
					if not targetPlr or not targetPlr.Parent or targetPlr == LocalPlayer then
						StatusLabel.Text = "●  PvP: Select a Player"
						StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
						return
					end

					local tChar = targetPlr.Character
					local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
					local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
					if not tRoot or not tHum or tHum.Health <= 0 then
						StatusLabel.Text = "●  PvP: Waiting for " .. tostring(targetPlr.Name)
						StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
						return
					end

					equipBestCombatTool()
					StatusLabel.Text = "●  PvP Auto-Click: " .. tostring(targetPlr.Name) .. " [" .. tostring(math.floor(tHum.Health)) .. " HP]"
					StatusLabel.TextColor3 = EnemyColor

					local stickPos = tRoot.CFrame * CFrame.new(0, 0, 3.0)
					local goalCF = CFrame.lookAt(stickPos.Position, tRoot.Position)
					local dist = (root.Position - goalCF.Position).Magnitude

					if dist > 4 then
						startTween(root, "PvP", goalCF, PvPSpeed, 2.5)
					else
						stopTween("PvP")
						root.CFrame = goalCF
						Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tRoot.Position)
					end

					root.AssemblyLinearVelocity = Vector3.zero
					root.AssemblyAngularVelocity = Vector3.zero
					if dist <= 22 then
						triggerAutoClickerHit(char)
					end
				end
			end)
		end
	end
end)

local function findQuestNPC(myPos)
	local bestPart, bestDist = nil, math.huge
	pcall(function()
		local npcFolder = Workspace:FindFirstChild("NPCs")
		local searchList = npcFolder and npcFolder:GetChildren() or Workspace:GetChildren()
		for _, obj in ipairs(searchList) do
			if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and not obj:FindFirstChildOfClass("Humanoid") then
				if string.find(string.lower(obj.Name), "quest") then
					local part = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
					if part then
						local d = (myPos - part.Position).Magnitude
						if d < bestDist then
							bestDist = d
							bestPart = part
						end
					end
				end
			end
		end
	end)
	return bestPart, bestDist
end

local function interactWithQuest(root, questPart)
	pcall(function()
		if questPart then
			root.CFrame = questPart.CFrame * CFrame.new(0, 0, -4)
			for _, desc in ipairs(questPart.Parent:GetDescendants()) do
				if desc:IsA("ProximityPrompt") and fireproximityprompt then
					pcall(function() fireproximityprompt(desc) end)
				elseif desc:IsA("ClickDetector") and fireclickdetector then
					pcall(function() fireclickdetector(desc) end)
				end
			end
		end
	end)
end

local function getNearestByPredicate(myPos, predicate)
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		return nil, nil, nil
	end

	local bestEnemy, bestRoot, bestHum, bestDist = nil, nil, nil, math.huge
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if enemy:IsA("Model") and predicate(enemy) then
			local eRoot = enemy:FindFirstChild("HumanoidRootPart")
			local eHum = enemy:FindFirstChildOfClass("Humanoid")
			if eRoot and eHum and eHum.Health > 0 then
				local dist = (myPos - eRoot.Position).Magnitude
				if dist < bestDist then
					bestDist = dist
					bestEnemy = enemy
					bestRoot = eRoot
					bestHum = eHum
				end
			end
		end
	end
	return bestEnemy, bestRoot, bestHum
end

local function getBracketEnemy(myPos, bracket)
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder or not bracket then
		return nil, nil, nil
	end

	local bestEnemy, bestRoot, bestHum, bestDist = nil, nil, nil, math.huge
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if enemy:IsA("Model") and enemyMatchesBracket(enemy, bracket) then
			local eRoot = enemy:FindFirstChild("HumanoidRootPart")
			local eHum = enemy:FindFirstChildOfClass("Humanoid")
			if eRoot and eHum and eHum.Health > 0 then
				local dist = (myPos - eRoot.Position).Magnitude
				if dist < bestDist then
					bestDist = dist
					bestEnemy = enemy
					bestRoot = eRoot
					bestHum = eHum
				end
			end
		end
	end
	return bestEnemy, bestRoot, bestHum
end

local function bringMobsUnderPlayer(centerPos, mainEnemyRoot, activeBracket)
	if not BringMobsEnabled then
		return
	end
	local now = tick()
	if (now - LastBringTick) < 0.14 then
		return
	end
	LastBringTick = now
	pcall(function()
		local enemiesFolder = Workspace:FindFirstChild("Enemies")
		if not enemiesFolder then
			return
		end
		local stackPos = mainEnemyRoot and mainEnemyRoot.Position or (centerPos + Vector3.new(0, -5, 0))
		for _, enemy in ipairs(enemiesFolder:GetChildren()) do
			if enemy:IsA("Model") and (not activeBracket or enemyMatchesBracket(enemy, activeBracket)) then
				local eRoot = enemy:FindFirstChild("HumanoidRootPart")
				local eHum = enemy:FindFirstChildOfClass("Humanoid")
				if eRoot and eHum and eHum.Health > 0 then
					local dist = (centerPos - eRoot.Position).Magnitude
					if dist <= BringRadius then
						eRoot.CanCollide = false
						eRoot.Anchored = false
						eRoot.AssemblyLinearVelocity = Vector3.zero
						eRoot.AssemblyAngularVelocity = Vector3.zero
						eRoot.CFrame = CFrame.new(stackPos)
					end
				end
			end
		end
	end)
end

local function farmTargetModel(char, root, targetEnemy, tRoot, tHum, statusPrefix, statusColor, activeBracket)
	if targetEnemy and tRoot and tHum and tHum.Health > 0 then
		local reqTag = activeBracket and (" [Lv." .. tostring(activeBracket.minLvl) .. "-" .. tostring(activeBracket.maxLvl) .. "]") or ""
		StatusLabel.Text = "●  " .. statusPrefix .. ": " .. tostring(targetEnemy.Name) .. reqTag
		StatusLabel.TextColor3 = statusColor

		local targetPos = tRoot.Position + Vector3.new(0, 4.5, 0)
		local lookCF = CFrame.lookAt(targetPos, tRoot.Position)
		local dist = (root.Position - targetPos).Magnitude

		if dist > 4.5 then
			startTween(root, "Farm", lookCF, FlySpeed, 2.5)
		else
			stopTween("Farm")
			root.CFrame = lookCF
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position + Vector3.new(0, 2, 0), tRoot.Position)
		end

		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		bringMobsUnderPlayer(root.Position, tRoot, activeBracket)
		if dist <= 18 then
			triggerHit(char)
		end
		return true
	end
	return false
end

task.spawn(function()
	while ScriptRunning do
		task.wait(0.08)
		if hasActiveTargetFarm() then
			pcall(function()
				local char = LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not root or not hum or hum.Health <= 0 then
					return
				end

				local myLvl = getPlayerLevel()
				equipBestCombatTool()

				if FarmBonesEnabled then
					local boneEnemy, bRoot, bHum = getNearestByPredicate(root.Position, isBoneEnemy)
					if not farmTargetModel(char, root, boneEnemy, bRoot, bHum, "Bones Farm", Color3.fromRGB(226, 232, 240), nil) then
						local castlePos = getHauntedCastleBonesPosition()
						local distToCastle = (root.Position - castlePos).Magnitude
						StatusLabel.Text = "●  Bones Farm: Moving/Waiting [" .. tostring(math.floor(distToCastle)) .. "m]"
						StatusLabel.TextColor3 = Color3.fromRGB(226, 232, 240)
						if distToCastle > 12 then
							startTween(root, "Farm", CFrame.new(castlePos), FlySpeed, 8)
						end
					end
					return
				end

				if FarmDragonScaleEnabled then
					local scaleEnemy, sRoot, sHum = getNearestByPredicate(root.Position, isDragonScaleEnemy)
					if not farmTargetModel(char, root, scaleEnemy, sRoot, sHum, "Dragon Scale Farm", Color3.fromRGB(249, 115, 22), nil) then
						local hydraPos = getHydraDragonScalePosition()
						local distToHydra = (root.Position - hydraPos).Magnitude
						StatusLabel.Text = "●  Dragon Scale Farm: Moving/Waiting [" .. tostring(math.floor(distToHydra)) .. "m]"
						StatusLabel.TextColor3 = Color3.fromRGB(249, 115, 22)
						if distToHydra > 12 then
							startTween(root, "Farm", CFrame.new(hydraPos), FlySpeed, 8)
						end
					end
					return
				end

				if FarmVampireEnabled then
					local vampEnemy, vRoot, vHum = getNearestByPredicate(root.Position, isVampireEnemy)
					if not farmTargetModel(char, root, vampEnemy, vRoot, vHum, "Fangs Farm", Color3.fromRGB(244, 63, 94), nil) then
						StatusLabel.Text = "●  Fangs Farm: Waiting Vampire Respawn..."
						StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
					end
					return
				end

				if FarmDemonicSoulEnabled then
					local soulEnemy, sRoot, sHum = getNearestByPredicate(root.Position, isDemonicSoulEnemy)
					if not farmTargetModel(char, root, soulEnemy, sRoot, sHum, "Demonic Soul Farm", Color3.fromRGB(192, 132, 252), nil) then
						StatusLabel.Text = "●  Demonic Soul Farm: Waiting Respawn..."
						StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
					end
					return
				end

				if AutoQuestFarmEnabled then
					if not LockedFarmBracket or myLvl > LockedFarmBracket.maxLvl or myLvl < LockedFarmBracket.minLvl then
						LockedFarmBracket = getBracketForLevel(myLvl)
					end

					local bracket = LockedFarmBracket
					local reqRangeText = "Lv." .. tostring(bracket.minLvl) .. "-" .. tostring(bracket.maxLvl)

					if AutoQuestEnabled and not hasActiveQuest() and (tick() - LastQuestAttemptTick) > 2.0 then
						local qPart, qDist = findQuestNPC(root.Position)
						if qPart and qDist < 220 then
							LastQuestAttemptTick = tick()
							StatusLabel.Text = "●  Lv." .. tostring(myLvl) .. " | Taking Quest (" .. bracket.questText .. ")..."
							StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
							interactWithQuest(root, qPart)
						end
					end

					local mainEnemy, eRoot, eHum = getBracketEnemy(root.Position, bracket)
					if not farmTargetModel(char, root, mainEnemy, eRoot, eHum, "Lv." .. tostring(myLvl) .. " | " .. bracket.questText, Color3.fromRGB(74, 222, 128), bracket) then
						local spawnPos = getSpawnPositionForKeywords(bracket.keywords, root.Position)
						local distSpawn = (root.Position - spawnPos).Magnitude
						StatusLabel.Text = "●  Lv." .. tostring(myLvl) .. " | Waiting Respawn: " .. bracket.questText .. " [" .. reqRangeText .. "]"
						StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
						if distSpawn > 14 then
							startTween(root, "Farm", CFrame.new(spawnPos), FlySpeed, 8)
						end
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
					end
				end
			end)
		end
	end
end)

local function getActiveSeaEvent(myPos)
	local ok, rName, rDist = pcall(function()
		for _, folderName in ipairs({"SeaBeasts", "Enemies", "Boats"}) do
			local folder = Workspace:FindFirstChild(folderName)
			if folder then
				for _, obj in ipairs(folder:GetChildren()) do
					if obj and isSeaEvent(obj.Name) then
						local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
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
		for _, obj in ipairs(Workspace:GetChildren()) do
			if isValidChestPart(obj) then
				local dist = (myRoot.Position - obj.Position).Magnitude
				if dist < shortestDist then
					shortestDist, nearestPart = dist, obj
				end
			elseif obj:IsA("Model") or obj:IsA("Folder") then
				for _, child in ipairs(obj:GetChildren()) do
					if isValidChestPart(child) then
						local dist = (myRoot.Position - child.Position).Magnitude
						if dist < shortestDist then
							shortestDist, nearestPart = dist, child
						end
					end
				end
			end
		end
	end)
	return nearestPart, shortestDist
end

task.spawn(function()
	while ScriptRunning do
		task.wait(0.15)
		if AutoAttackSeaEnabled then
			pcall(function()
				local myChar = LocalPlayer.Character
				local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				local enemiesFolder = Workspace:FindFirstChild("Enemies")
				if myRoot and enemiesFolder then
					for _, enemy in ipairs(enemiesFolder:GetChildren()) do
						if enemy:IsA("Model") and isSeaEvent(enemy.Name) then
							local eRoot = enemy:FindFirstChild("HumanoidRootPart")
							local eHum = enemy:FindFirstChildOfClass("Humanoid")
							if eRoot and eHum and eHum.Health > 0 and (myRoot.Position - eRoot.Position).Magnitude < 250 then
								equipBestCombatTool()
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
		task.wait(0.15)
		if AutoChestEnabled then
			pcall(function()
				local char = LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not root or not hum or hum.Health <= 0 then
					return
				end

				local targetChest, dist = getNearestChest(root)
				if targetChest and isValidChestPart(targetChest) then
					StatusLabel.Text = "●  Chest: " .. tostring(getChestDisplayName(targetChest)) .. " [" .. tostring(math.floor(dist)) .. "m]"
					StatusLabel.TextColor3 = ChestColor

					local goalCF = targetChest.CFrame + Vector3.new(0, 2.5, 0)
					startTween(root, "Chest", goalCF, FlySpeed, 12)

					if (root.Position - goalCF.Position).Magnitude <= 5 then
						stopTween("Chest")
						root.CFrame = goalCF
						root.AssemblyLinearVelocity = Vector3.zero
						task.wait(0.18)
					end
				else
					StatusLabel.Text = "●  Auto Chest: Scanning..."
					StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
				end
			end)
		end
	end
end)

task.spawn(function()
	while ScriptRunning do
		task.wait(0.08)
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
					StatusLabel.TextColor3 = SeaBeastColor
					clearBoatMover(seat)
					if seat:IsA("VehicleSeat") then
						seat.Throttle = 0
						seat.Steer = 0
					end
				else
					StatusLabel.Text = "●  Auto Sailing Straight (" .. tostring(TargetBoatSpeed) .. ")..."
					StatusLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
					applyLockedSailVelocity(seat, TargetBoatSpeed, LockedSailDir)
				end
			elseif AutoSailEnabled then
				LockedSailDir = nil
				StatusLabel.Text = "●  Sit in Boat Seat!"
				StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
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
		local char = LocalPlayer.Character
		if not char then
			return
		end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")

		if WalkOnWaterEnabled and root then
			ensureWalkOnWaterPart(root.Position)
		end

		if hum and WalkSpeedEnabled and hum.WalkSpeed ~= TargetWalkSpeed then
			hum.WalkSpeed = TargetWalkSpeed
		end

		if AutoSailEnabled and hum and hum.SeatPart and root and LockedSailDir then
			local eventName = getActiveSeaEvent(root.Position)
			if not eventName then
				applyLockedSailVelocity(hum.SeatPart, TargetBoatSpeed, LockedSailDir)
			end
		end

		local noclipActive = AutoChestEnabled or hasActiveTargetFarm() or PvPEnabled or AutoGetFruitsEnabled or (BoatNoclipEnabled and hum and hum.SeatPart)

		if (hasActiveTargetFarm() or AutoChestEnabled or PvPEnabled or AutoGetFruitsEnabled) and root then
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end

		if noclipActive then
			for _, part in ipairs(char:GetChildren()) do
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
				Box = createDrawing("Square", {Thickness = 1.5, Color = ThemeColor, Filled = false, Visible = false}),
				Tracer = createDrawing("Line", {Thickness = 1.2, Color = ThemeColor, Transparency = 0.7, Visible = false}),
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
				Text = createDrawing("Text", {Size = seaEvent and 13 or 11, Center = true, Outline = true, Color = seaEvent and SeaBeastColor or EnemyColor, Visible = false})
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

	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if enemiesFolder then
		for _, m in ipairs(enemiesFolder:GetChildren()) do
			addNPC(m)
		end
		enemiesFolder.ChildAdded:Connect(function(m)
			task.wait(0.15)
			addNPC(m)
		end)
		enemiesFolder.ChildRemoved:Connect(removeNPC)
	end

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
						local tag = esp.IsSeaEvent and "[SEA EVENT] " or "[NPC] "
						esp.Text.Text = tag .. model.Name .. " [" .. dist .. "m]"
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

print("[NEXOARO] Loaded")
