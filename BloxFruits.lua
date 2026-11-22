local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local VirtualUser = (function()
	local ok, srv = pcall(function() return game:GetService("VirtualUser") end)
	return ok and srv or nil
end)()

local VirtualInputManager = (function()
	local ok, srv = pcall(function() return game:GetService("VirtualInputManager") end)
	return ok and srv or nil
end)()

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

local AutoFarmEnabled = false
local FarmVampireEnabled = false
local FarmDemonicSoulEnabled = false
local FarmDragonScaleEnabled = false
local FarmBonesEnabled = false
local BringMobsEnabled = true
local AutoQuestEnabled = true
local FastAttackEnabled = true
local AutoHakiEnabled = true
local AntiAFKEnabled = true
local WalkOnWaterEnabled = false
local WalkSpeedEnabled = false
local TargetWalkSpeed = 100
local BoatSpeedEnabled = false
local TargetBoatSpeed = 180
local AutoSailEnabled = false
local LockedSailDir = nil
local BoatNoclipEnabled = false
local AutoChestEnabled = false
local AutoAttackSeaEnabled = false
local ESPEnabled = false
local RemoveFogEnabled = false
local AutoGetFruitsEnabled = false
local AutoStoreFruitEnabled = false
local AutoRollFruitEnabled = false
local PvPEnabled = false
local AimBotEnabled = false
local PvPSpeed = 340
local SelectedPvPPlayer = nil
local FlySpeed = 350
local BringRadius = 140
local ScriptRunning = true

local LastHitTick = 0
local LastBringTick = 0
local LastRollTick = 0
local LastStoreTick = 0
local LastHakiTick = 0
local LastQuestAttemptTick = 0
local LastFistAlertTick = 0
local FistDetectedState = false

local WaterPart = nil
local SavedFogState = nil
local LockedFarmBracket = nil
local CachedCombatRemote = nil
local ActiveFarmEnemy = nil

local HydraIslandFallbackPos = Vector3.new(5750, 610, -280)
local HauntedCastleFallbackPos = Vector3.new(-9500, 145, 6080)
local HighDiscipleFallbackPos = Vector3.new(-6730, 75, -1285)

local WeaponModes = {"Melee", "Fruit", "Sword", "Gun"}
local WeaponModeIndex = 1
local SelectedFarmWeapon = WeaponModes[WeaponModeIndex]

local FightingStylesList = {
	{
		name = "Dark Step",
		calls = {{"BuyBlackLeg"}, {"BuyBlackLeg", true}, {"BuyBlackLeg", "Buy"}},
		toolKeywords = {"dark step", "black leg", "step"}
	},
	{
		name = "Electric",
		calls = {{"BuyElectro"}, {"BuyElectro", true}, {"BuyElectro", "Buy"}},
		toolKeywords = {"electric", "electro"}
	},
	{
		name = "Water Kung Fu",
		calls = {{"BuyFishmanKarate"}, {"BuyFishmanKarate", true}, {"BuyFishmanKarate", "Buy"}},
		toolKeywords = {"water kung", "fishman karate", "water kung fu"}
	},
	{
		name = "Dragon Breath",
		calls = {{"BlackbeardReward", "DragonClaw", "1"}, {"BlackbeardReward", "DragonClaw", "2"}, {"BuyDragonClaw"}},
		toolKeywords = {"dragon breath", "dragon claw"}
	},
	{
		name = "Superhuman",
		calls = {{"BuySuperhuman"}, {"BuySuperhuman", true}, {"BuySuperhuman", "Buy"}},
		toolKeywords = {"superhuman"}
	},
	{
		name = "Death Step",
		calls = {{"BuyDeathStep"}, {"BuyDeathStep", true}, {"BuyDeathStep", "Buy"}},
		toolKeywords = {"death step"}
	},
	{
		name = "Sharkman Karate",
		calls = {{"BuySharkmanKarate"}, {"BuySharkmanKarate", true}, {"BuySharkmanKarate", "Buy"}},
		toolKeywords = {"sharkman karate", "sharkman"}
	},
	{
		name = "Electric Claw",
		calls = {{"BuyElectricClaw"}, {"BuyElectricClaw", true}, {"BuyElectricClaw", "Buy"}},
		toolKeywords = {"electric claw"}
	},
	{
		name = "Dragon Talon",
		calls = {{"BuyDragonTalon"}, {"BuyDragonTalon", true}, {"BuyDragonTalon", "Buy"}},
		toolKeywords = {"dragon talon"}
	},
	{
		name = "Godhuman",
		calls = {{"BuyGodhuman"}, {"BuyGodhuman", true}, {"BuyGodhuman", "Buy"}},
		toolKeywords = {"godhuman"}
	},
	{
		name = "Sanguine Art",
		calls = {{"BuySanguineArt"}, {"BuySanguineArt", true}, {"BuySanguineArt", "Buy"}},
		toolKeywords = {"sanguine art", "sanguine"}
	}
}

local EnemyLevelBrackets = {
	{minLvl = 1, maxLvl = 9, keywords = {"bandit"}, questText = "Bandit", questName = "BanditQuest1", questNum = 1},
	{minLvl = 10, maxLvl = 14, keywords = {"monkey"}, questText = "Monkey", questName = "JungleQuest", questNum = 1},
	{minLvl = 15, maxLvl = 29, keywords = {"gorilla"}, questText = "Gorilla", questName = "JungleQuest", questNum = 2},
	{minLvl = 30, maxLvl = 39, keywords = {"pirate"}, questText = "Pirate", questName = "BuggyQuest1", questNum = 1},
	{minLvl = 40, maxLvl = 59, keywords = {"brute"}, questText = "Brute", questName = "BuggyQuest1", questNum = 2},
	{minLvl = 60, maxLvl = 74, keywords = {"desert bandit"}, questText = "Desert Bandit", questName = "DesertQuest", questNum = 1},
	{minLvl = 75, maxLvl = 89, keywords = {"desert officer"}, questText = "Desert Officer", questName = "DesertQuest", questNum = 2},
	{minLvl = 90, maxLvl = 99, keywords = {"snow bandit"}, questText = "Snow Bandit", questName = "SnowQuest", questNum = 1},
	{minLvl = 100, maxLvl = 119, keywords = {"snowman"}, questText = "Snowman", questName = "SnowQuest", questNum = 2},
	{minLvl = 120, maxLvl = 149, keywords = {"chief petty officer"}, questText = "Chief Petty Officer", questName = "MarineQuest2", questNum = 1},
	{minLvl = 150, maxLvl = 174, keywords = {"sky bandit"}, questText = "Sky Bandit", questName = "SkyQuest", questNum = 1},
	{minLvl = 175, maxLvl = 189, keywords = {"dark master"}, questText = "Dark Master", questName = "SkyQuest", questNum = 2},
	{minLvl = 190, maxLvl = 209, keywords = {"prisoner"}, questText = "Prisoner", questName = "PrisonerQuest", questNum = 1},
	{minLvl = 210, maxLvl = 249, keywords = {"dangerous prisoner"}, questText = "Dangerous Prisoner", questName = "PrisonerQuest", questNum = 2},
	{minLvl = 250, maxLvl = 274, keywords = {"toga warrior"}, questText = "Toga Warrior", questName = "ColosseumQuest", questNum = 1},
	{minLvl = 275, maxLvl = 299, keywords = {"gladiator"}, questText = "Gladiator", questName = "ColosseumQuest", questNum = 2},
	{minLvl = 300, maxLvl = 324, keywords = {"military soldier"}, questText = "Military Soldier", questName = "MagmaQuest", questNum = 1},
	{minLvl = 325, maxLvl = 374, keywords = {"military spy"}, questText = "Military Spy", questName = "MagmaQuest", questNum = 2},
	{minLvl = 375, maxLvl = 399, keywords = {"fishman warrior"}, questText = "Fishman Warrior", questName = "FishmanQuest", questNum = 1},
	{minLvl = 400, maxLvl = 449, keywords = {"fishman commando"}, questText = "Fishman Commando", questName = "FishmanQuest", questNum = 2},
	{minLvl = 450, maxLvl = 474, keywords = {"god's guard", "gods guard"}, questText = "God's Guard", questName = "SkyExp1Quest", questNum = 1},
	{minLvl = 475, maxLvl = 524, keywords = {"shanda"}, questText = "Shanda", questName = "SkyExp1Quest", questNum = 2},
	{minLvl = 525, maxLvl = 549, keywords = {"royal squad"}, questText = "Royal Squad", questName = "SkyExp2Quest", questNum = 1},
	{minLvl = 550, maxLvl = 624, keywords = {"royal soldier"}, questText = "Royal Soldier", questName = "SkyExp2Quest", questNum = 2},
	{minLvl = 625, maxLvl = 649, keywords = {"galley pirate"}, questText = "Galley Pirate", questName = "FountainQuest", questNum = 1},
	{minLvl = 650, maxLvl = 699, keywords = {"galley captain"}, questText = "Galley Captain", questName = "FountainQuest", questNum = 2},
	{minLvl = 700, maxLvl = 724, keywords = {"raider"}, questText = "Raider", questName = "Area1Quest", questNum = 1},
	{minLvl = 725, maxLvl = 774, keywords = {"mercenary"}, questText = "Mercenary", questName = "Area1Quest", questNum = 2},
	{minLvl = 775, maxLvl = 799, keywords = {"swan pirate"}, questText = "Swan Pirate", questName = "Area2Quest", questNum = 1},
	{minLvl = 800, maxLvl = 874, keywords = {"factory staff"}, questText = "Factory Staff", questName = "Area2Quest", questNum = 2},
	{minLvl = 875, maxLvl = 899, keywords = {"marine lieutenant"}, questText = "Marine Lieutenant", questName = "MarineQuest3", questNum = 1},
	{minLvl = 900, maxLvl = 949, keywords = {"marine captain"}, questText = "Marine Captain", questName = "MarineQuest3", questNum = 2},
	{minLvl = 950, maxLvl = 974, keywords = {"zombie"}, questText = "Zombie", questName = "ZombieQuest", questNum = 1},
	{minLvl = 975, maxLvl = 999, keywords = {"vampire"}, questText = "Vampire", questName = "ZombieQuest", questNum = 2},
	{minLvl = 1000, maxLvl = 1049, keywords = {"snow trooper"}, questText = "Snow Trooper", questName = "SnowMountainQuest", questNum = 1},
	{minLvl = 1050, maxLvl = 1099, keywords = {"winter warrior"}, questText = "Winter Warrior", questName = "SnowMountainQuest", questNum = 2},
	{minLvl = 1100, maxLvl = 1124, keywords = {"lab subordinate"}, questText = "Lab Subordinate", questName = "IceSideQuest", questNum = 1},
	{minLvl = 1125, maxLvl = 1174, keywords = {"horn warrior"}, questText = "Horn Warrior", questName = "IceSideQuest", questNum = 2},
	{minLvl = 1175, maxLvl = 1199, keywords = {"magma ninja"}, questText = "Magma Ninja", questName = "FireSideQuest", questNum = 1},
	{minLvl = 1200, maxLvl = 1249, keywords = {"lava pirate"}, questText = "Lava Pirate", questName = "FireSideQuest", questNum = 2},
	{minLvl = 1250, maxLvl = 1274, keywords = {"ship deckhand"}, questText = "Ship Deckhand", questName = "ShipQuest1", questNum = 1},
	{minLvl = 1275, maxLvl = 1299, keywords = {"ship engineer"}, questText = "Ship Engineer", questName = "ShipQuest1", questNum = 2},
	{minLvl = 1300, maxLvl = 1324, keywords = {"ship steward"}, questText = "Ship Steward", questName = "ShipQuest2", questNum = 1},
	{minLvl = 1325, maxLvl = 1349, keywords = {"ship officer"}, questText = "Ship Officer", questName = "ShipQuest2", questNum = 2},
	{minLvl = 1350, maxLvl = 1374, keywords = {"arctic warrior"}, questText = "Arctic Warrior", questName = "FrostQuest", questNum = 1},
	{minLvl = 1375, maxLvl = 1424, keywords = {"snow lurker"}, questText = "Snow Lurker", questName = "FrostQuest", questNum = 2},
	{minLvl = 1425, maxLvl = 1449, keywords = {"sea soldier"}, questText = "Sea Soldier", questName = "ForgottenQuest", questNum = 1},
	{minLvl = 1450, maxLvl = 1474, keywords = {"water fighter"}, questText = "Water Fighter", questName = "ForgottenQuest", questNum = 2},
	{minLvl = 1475, maxLvl = 1499, keywords = {"pirate millionaire"}, questText = "Pirate Millionaire", questName = "PiratePortQuest", questNum = 1},
	{minLvl = 1500, maxLvl = 1524, keywords = {"pistol billionaire"}, questText = "Pistol Billionaire", questName = "PiratePortQuest", questNum = 2},
	{minLvl = 1525, maxLvl = 1574, keywords = {"dragon crew warrior"}, questText = "Dragon Crew Warrior", questName = "AmazonQuest", questNum = 1},
	{minLvl = 1575, maxLvl = 1599, keywords = {"dragon crew archer"}, questText = "Dragon Crew Archer", questName = "AmazonQuest", questNum = 2},
	{minLvl = 1600, maxLvl = 1624, keywords = {"female island"}, questText = "Female Island", questName = "AmazonQuest2", questNum = 1},
	{minLvl = 1625, maxLvl = 1649, keywords = {"giant sky island"}, questText = "Giant Sky Island", questName = "AmazonQuest2", questNum = 2},
	{minLvl = 1650, maxLvl = 1699, keywords = {"head baker"}, questText = "Head Baker", questName = "CakeQuest1", questNum = 1},
	{minLvl = 1700, maxLvl = 1724, keywords = {"baking staff"}, questText = "Baking Staff", questName = "CakeQuest1", questNum = 2},
	{minLvl = 1725, maxLvl = 1749, keywords = {"cake guard"}, questText = "Cake Guard", questName = "CakeQuest2", questNum = 1},
	{minLvl = 1750, maxLvl = 1774, keywords = {"cookie crafter"}, questText = "Cookie Crafter", questName = "CakeQuest2", questNum = 2},
	{minLvl = 1775, maxLvl = 1799, keywords = {"cake queen"}, questText = "Cake Queen", questName = "CakeQuest2", questNum = 2},
	{minLvl = 1800, maxLvl = 1824, keywords = {"peanut president"}, questText = "Peanut President", questName = "ChocQuest1", questNum = 1},
	{minLvl = 1825, maxLvl = 1849, keywords = {"ice cream chef"}, questText = "Ice Cream Chef", questName = "ChocQuest1", questNum = 2},
	{minLvl = 1850, maxLvl = 1899, keywords = {"ice cream commander"}, questText = "Ice Cream Commander", questName = "ChocQuest2", questNum = 1},
	{minLvl = 1900, maxLvl = 1924, keywords = {"cookie disciple"}, questText = "Cookie Disciple", questName = "ChocQuest2", questNum = 2},
	{minLvl = 1925, maxLvl = 1974, keywords = {"mint mark"}, questText = "Mint Mark", questName = "CandyQuest1", questNum = 1},
	{minLvl = 1975, maxLvl = 1999, keywords = {"cocoa warrior"}, questText = "Cocoa Warrior", questName = "CandyQuest1", questNum = 2},
	{minLvl = 2000, maxLvl = 2024, keywords = {"chocolate bar battler"}, questText = "Chocolate Bar Battler", questName = "CandyQuest2", questNum = 1},
	{minLvl = 2025, maxLvl = 2049, keywords = {"sweet thief"}, questText = "Sweet Thief", questName = "CandyQuest2", questNum = 2},
	{minLvl = 2050, maxLvl = 2074, keywords = {"candy rebel"}, questText = "Candy Rebel", questName = "TikiQuest1", questNum = 1},
	{minLvl = 2075, maxLvl = 2099, keywords = {"candy pirate"}, questText = "Candy Pirate", questName = "TikiQuest1", questNum = 2},
	{minLvl = 2100, maxLvl = 2124, keywords = {"snow demon"}, questText = "Snow Demon", questName = "TikiQuest1", questNum = 2},
	{minLvl = 2125, maxLvl = 2149, keywords = {"isle outcast"}, questText = "Isle Outcast", questName = "TikiQuest2", questNum = 1},
	{minLvl = 2150, maxLvl = 2199, keywords = {"island boy"}, questText = "Island Boy", questName = "TikiQuest2", questNum = 2},
	{minLvl = 2200, maxLvl = 2224, keywords = {"sun-kissed warrior"}, questText = "Sun-kissed Warrior", questName = "TikiQuest2", questNum = 2},
	{minLvl = 2225, maxLvl = 2249, keywords = {"isle champion"}, questText = "Isle Champion", questName = "TikiQuest3", questNum = 1},
	{minLvl = 2250, maxLvl = 2274, keywords = {"serpent hunter"}, questText = "Serpent Hunter", questName = "TikiQuest3", questNum = 2},
	{minLvl = 2275, maxLvl = 2299, keywords = {"skull slayer"}, questText = "Skull Slayer", questName = "HauntedQuest1", questNum = 1},
	{minLvl = 2300, maxLvl = 2349, keywords = {"reborn skeleton"}, questText = "Reborn Skeleton", questName = "HauntedQuest1", questNum = 2},
	{minLvl = 2350, maxLvl = 2399, keywords = {"living zombie"}, questText = "Living Zombie", questName = "HauntedQuest2", questNum = 1},
	{minLvl = 2400, maxLvl = 2449, keywords = {"demonic soul"}, questText = "Demonic Soul", questName = "HauntedQuest2", questNum = 2},
	{minLvl = 2450, maxLvl = 2474, keywords = {"posessed mummy", "possessed mummy"}, questText = "Possessed Mummy", questName = "HauntedQuest2", questNum = 2},
	{minLvl = 2475, maxLvl = 2524, keywords = {"peanut scout"}, questText = "Peanut Scout", questName = "NutsQuest", questNum = 1},
	{minLvl = 2525, maxLvl = 2549, keywords = {"dragon crew"}, questText = "Dragon Crew", questName = "NutsQuest", questNum = 2},
	{minLvl = 2550, maxLvl = 2574, keywords = {"hydra enforcer"}, questText = "Hydra Enforcer", questName = "HydraQuest", questNum = 1},
	{minLvl = 2575, maxLvl = 2599, keywords = {"venous knight"}, questText = "Venous Knight", questName = "HydraQuest", questNum = 2},
	{minLvl = 2600, maxLvl = 2624, keywords = {"marine commodore"}, questText = "Marine Commodore", questName = "MarineTreeQuest", questNum = 1},
	{minLvl = 2625, maxLvl = 2649, keywords = {"marine rear admiral"}, questText = "Marine Rear Admiral", questName = "MarineTreeQuest", questNum = 2},
	{minLvl = 2650, maxLvl = 2674, keywords = {"fishman raider"}, questText = "Fishman Raider", questName = "DeepForestQuest", questNum = 1},
	{minLvl = 2675, maxLvl = 2699, keywords = {"fishman captain"}, questText = "Fishman Captain", questName = "DeepForestQuest", questNum = 2},
	{minLvl = 2700, maxLvl = 2724, keywords = {"high disciple"}, questText = "High Disciple", questName = "DeepForestQuest", questNum = 2},
	{minLvl = 2725, maxLvl = 9999, keywords = {"high disciple"}, questText = "High Disciple", questName = "DeepForestQuest", questNum = 2}
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
local SeaEventKeywords = {"seabeast", "sea beast", "terror", "shark", "leviathan", "piranha", "ship", "ghost", "mirage", "kitsune"}

local function hasActiveTargetFarm()
	return AutoFarmEnabled or FarmVampireEnabled or FarmDemonicSoulEnabled or FarmDragonScaleEnabled or FarmBonesEnabled
end

local function safeGetGuiParent()
	local ok, coreGui = pcall(function() return game:GetService("CoreGui") end)
	if ok and coreGui then
		local testOk = pcall(function()
			local f = Instance.new("Folder")
			f.Name = "NexoaroProbe"
			f.Parent = coreGui
			f:Destroy()
		end)
		if testOk then
			return coreGui
		end
	end
	return LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
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

local function getCombatRemote()
	if CachedCombatRemote and CachedCombatRemote.Parent then
		return CachedCombatRemote
	end
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if remotes then
		for _, name in ipairs({"Combat", "Hit", "Attack", "Melee"}) do
			local r = remotes:FindFirstChild(name)
			if r and r:IsA("RemoteEvent") then
				CachedCombatRemote = r
				return r
			end
		end
	end
	for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
		if desc:IsA("RemoteEvent") then
			local n = string.lower(desc.Name)
			if n == "combat" or n == "hit" then
				CachedCombatRemote = desc
				return desc
			end
		end
	end
	return nil
end

local function invokeOrFireRemote(rem, ...)
	if not rem then
		return false
	end
	local args = {...}
	if rem:IsA("RemoteFunction") and type(rem.InvokeServer) == "function" then
		return pcall(function() rem:InvokeServer(table.unpack(args)) end)
	elseif rem:IsA("RemoteEvent") and type(rem.FireServer) == "function" then
		return pcall(function() rem:FireServer(table.unpack(args)) end)
	end
	return false
end

local function clearFlyMover(root)
	pcall(function()
		if root then
			for _, obj in ipairs(root:GetChildren()) do
				if obj.Name == "NexoaroFlyVel" or obj.Name == "NexoaroFlyGyro" or obj.Name == "NexoaroBodyPos" then
					pcall(function() obj:Destroy() end)
				end
			end
		end
	end)
end

local function moveToTarget(root, targetCF, speed)
	if not root or not root.Parent then
		return
	end
	local delta = targetCF.Position - root.Position
	local dist = delta.Magnitude
	local travelSpeed = math.max(speed or FlySpeed, 180)
	local stepDist = travelSpeed * 0.05

	if dist <= math.max(2.5, stepDist) then
		clearFlyMover(root)
		root.CFrame = CFrame.lookAt(targetCF.Position, targetCF.Position + targetCF.LookVector)
		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		return
	end

	local dir = delta.Unit
	local nextPos = root.Position + (dir * stepDist)

	local bv = root:FindFirstChild("NexoaroFlyVel")
	if not bv or not bv:IsA("BodyVelocity") then
		if bv then pcall(function() bv:Destroy() end) end
		bv = Instance.new("BodyVelocity")
		bv.Name = "NexoaroFlyVel"
		bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bv.P = 5e4
		bv.Parent = root
	end
	bv.Velocity = dir * travelSpeed

	root.CFrame = CFrame.lookAt(nextPos, targetCF.Position)
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

local function getPlayerLevel()
	local ok, lvl = pcall(function()
		local data = LocalPlayer:FindFirstChild("Data")
		local levelVal = data and data:FindFirstChild("Level")
		if levelVal and type(levelVal.Value) == "number" then
			return levelVal.Value
		end
		local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
		local lsLevel = leaderstats and (leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("Lvl"))
		if lsLevel and type(lsLevel.Value) == "number" then
			return lsLevel.Value
		end
		return 1
	end)
	return ok and lvl or 1
end

local function getBracketForLevel(lvl)
	local targetLvl = tonumber(lvl) or 1
	local bestBracket = nil
	for _, b in ipairs(EnemyLevelBrackets) do
		if type(b) == "table" and type(b.minLvl) == "number" and type(b.maxLvl) == "number" then
			if targetLvl >= b.minLvl and targetLvl <= b.maxLvl then
				return b
			end
			if b.minLvl <= targetLvl then
				bestBracket = b
			end
		end
	end
	return bestBracket or EnemyLevelBrackets[1]
end

local function enemyMatchesBracket(enemyModel, bracket)
	if not enemyModel or not bracket then
		return false
	end
	local lowerName = string.lower(tostring(enemyModel.Name))
	for _, kw in ipairs(bracket.keywords or {}) do
		if string.find(lowerName, string.lower(kw), 1, true) then
			return true
		end
	end
	return false
end

local function isEnemyAliveModel(enemy, predicate, bracket)
	if not enemy or not enemy.Parent or not enemy:IsA("Model") then
		return nil, nil
	end
	if predicate and not predicate(enemy) then
		return nil, nil
	end
	if bracket and not enemyMatchesBracket(enemy, bracket) then
		return nil, nil
	end
	local eRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
	local eHum = enemy:FindFirstChildOfClass("Humanoid")
	if eRoot and eRoot.Parent and eHum and eHum.Parent and eHum.Health > 0 then
		return eRoot, eHum
	end
	return nil, nil
end

local function getLockedOrNearestEnemy(myPos, predicate, bracket)
	if ActiveFarmEnemy then
		local aRoot, aHum = isEnemyAliveModel(ActiveFarmEnemy, predicate, bracket)
		if aRoot and aHum then
			return ActiveFarmEnemy, aRoot, aHum
		end
		ActiveFarmEnemy = nil
	end

	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then return nil, nil, nil end

	local bestEnemy, bestRoot, bestHum, bestDist = nil, nil, nil, math.huge
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		local eRoot, eHum = isEnemyAliveModel(enemy, predicate, bracket)
		if eRoot and eHum then
			local dist = (myPos - eRoot.Position).Magnitude
			if dist < bestDist then
				bestDist, bestEnemy, bestRoot, bestHum = dist, enemy, eRoot, eHum
			end
		end
	end

	ActiveFarmEnemy = bestEnemy
	return bestEnemy, bestRoot, bestHum
end

local function getChestAnchorPart(obj)
	if not obj or not obj.Parent then return nil end
	if obj:IsA("BasePart") then
		if obj:FindFirstChildWhichIsA("TouchTransmitter", true) or string.find(string.lower(obj.Name), "chest", 1, true) then
			return obj
		end
	elseif obj:IsA("Model") then
		local lower = string.lower(obj.Name)
		if string.find(lower, "chest", 1, true) then
			return obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart", true)
		end
	end
	return nil
end

local function findNearestChestPart(myPos)
	local bestPart, bestName, bestDist = nil, nil, math.huge
	for _, obj in ipairs(Workspace:GetDescendants()) do
		local part = getChestAnchorPart(obj)
		if part and part.Parent and part.CanTouch ~= false then
			local dist = (myPos - part.Position).Magnitude
			if dist < bestDist then
				bestDist, bestPart, bestName = dist, part, obj.Name
			end
		end
	end
	return bestPart, bestName, bestDist
end

local function isVampireEnemy(model)
	return model and model.Name and string.find(string.lower(tostring(model.Name)), "vampire") ~= nil
end

local function isDemonicSoulEnemy(model)
	return model and model.Name and string.find(string.lower(tostring(model.Name)), "demonic soul") ~= nil
end

local function isDragonScaleEnemy(model)
	if not model or not model.Name then return false end
	local lower = string.lower(tostring(model.Name))
	return string.find(lower, "dragon crew warrior") ~= nil or string.find(lower, "dragon crew archer") ~= nil
end

local function isBoneEnemy(model)
	if not model or not model.Name then return false end
	local lower = string.lower(tostring(model.Name))
	return string.find(lower, "reborn skeleton") ~= nil
		or string.find(lower, "living zombie") ~= nil
		or string.find(lower, "demonic soul") ~= nil
		or string.find(lower, "posessed mummy") ~= nil
		or string.find(lower, "possessed mummy") ~= nil
end

local function getSpawnPositionForKeywords(keywords, fallbackPos)
	local spawns = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")
	if spawns then
		for _, sp in ipairs(spawns:GetChildren()) do
			local lower = string.lower(sp.Name)
			for _, kw in ipairs(keywords or {}) do
				if string.find(lower, string.lower(kw), 1, true) then
					local part = sp:IsA("BasePart") and sp or sp:FindFirstChildWhichIsA("BasePart", true)
					if part then
						return part.Position + Vector3.new(0, 10, 0)
					end
				end
			end
		end
	end
	return fallbackPos or HighDiscipleFallbackPos
end

local function getHydraDragonScalePosition()
	return getSpawnPositionForKeywords({"dragon crew warrior", "dragon crew archer"}, HydraIslandFallbackPos)
end

local function getHauntedCastleBonesPosition()
	return getSpawnPositionForKeywords({"reborn skeleton", "living zombie", "demonic soul"}, HauntedCastleFallbackPos)
end

local function resolveBloxFruitName(rawName)
	if not rawName then return nil end
	local lower = string.lower(tostring(rawName))
	lower = string.gsub(lower, "^%s*(.-)%s*$", "%1")
	lower = string.gsub(lower, "%s+fruit%s+fruit%s*$", " fruit")
	if BloxFruitLookup[lower] then return BloxFruitLookup[lower] end
	local stripped = string.gsub(lower, "%s*fruit%s*$", "")
	if BloxFruitLookup[stripped] then return BloxFruitLookup[stripped] end
	local dashBase = string.match(lower, "^([a-z%-]+)%-[a-z%-]+$")
	if dashBase and BloxFruitLookup[dashBase] then return BloxFruitLookup[dashBase] end
	return nil
end

local function getStoreFruitKey(item, resolvedName)
	if item and item.GetAttribute then
		local ok, attr = pcall(function() return item:GetAttribute("FruitName") end)
		if ok and attr then return tostring(attr) end
	end
	local base = string.gsub(resolvedName, "%s*Fruit%s*$", "")
	return base .. "-" .. base
end

local function isPickupableFruitInstance(obj)
	if not obj or not obj.Name or not obj.Parent then return false end
	if Players:GetPlayerFromCharacter(obj) or obj:FindFirstAncestorWhichIsA("Player") then return false end
	if not resolveBloxFruitName(obj.Name) then return false end
	if obj:IsA("Tool") then return true end
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
	if not obj or not obj.Parent then return nil end
	if obj:IsA("BasePart") then return obj end
	if obj:IsA("Model") then
		return obj:FindFirstChild("Handle") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
	end
	if obj:IsA("Tool") then
		return obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
	end
	return nil
end

local function isFistOfDarknessName(rawName)
	if not rawName then return false end
	local lower = string.lower(tostring(rawName))
	return string.find(lower, "fist of darkness", 1, true) ~= nil
		or string.find(lower, "dark fist", 1, true) ~= nil
		or string.find(lower, "fistofdarkness", 1, true) ~= nil
end

local function findFistOfDarknessLocation()
	local containers = {
		{container = Workspace, label = "Map/World"},
		{container = LocalPlayer and LocalPlayer:FindFirstChild("Backpack"), label = "Backpack"},
		{container = LocalPlayer and LocalPlayer.Character, label = "Character"}
	}
	for _, entry in ipairs(containers) do
		local c = entry.container
		if c then
			for _, obj in ipairs(c:GetDescendants()) do
				if isFistOfDarknessName(obj.Name) then
					local part = nil
					if obj:IsA("BasePart") then
						part = obj
					elseif obj:IsA("Model") or obj:IsA("Tool") then
						part = obj:FindFirstChild("Handle") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
					end
					local distText = ""
					local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if part and myRoot then
						distText = " [" .. tostring(math.floor((myRoot.Position - part.Position).Magnitude)) .. "m]"
					end
					return true, tostring(obj.Name) .. " (" .. entry.label .. ")" .. distText
				end
			end
		end
	end
	return false, nil
end

local function triggerAutoHaki()
	if not AutoHakiEnabled then return end
	local now = tick()
	if (now - LastHakiTick) < 8 then return end
	LastHakiTick = now
	local char = LocalPlayer.Character
	if not char or char:FindFirstChild("HasBuso") then return end
	local commf = getCommF()
	if commf then
		invokeOrFireRemote(commf, "Buso")
	end
end

local function ensureWalkOnWaterPart(rootPos)
	pcall(function()
		if not WalkOnWaterEnabled or not rootPos then
			if WaterPart then
				pcall(function() WaterPart:Destroy() end)
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

local function captureOriginalFogState()
	if SavedFogState then return end
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
		SavedFogState = state
	end)
end

local function restoreOriginalFogState()
	if not SavedFogState then return end
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

if VirtualUser and LocalPlayer and LocalPlayer.Idled then
	LocalPlayer.Idled:Connect(function()
		if AntiAFKEnabled then
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new(500, 500))
			end)
		end
	end)
end

local guiParent = safeGetGuiParent()
for _, gui in ipairs(guiParent:GetChildren()) do
	if gui.Name == "NexoaroHub" then
		pcall(function() gui:Destroy() end)
	end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "NexoaroHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = guiParent

local isMobile = false
pcall(function()
	local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
	isMobile = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) or vp.X < 750
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = isMobile and UDim2.new(0, 326, 0, 368) or UDim2.new(0, 445, 0, 442)
MainFrame.Position = isMobile and UDim2.new(0.03, 0, 0.11, 0) or UDim2.new(0.02, 0, 0.22, 0)
MainFrame.BackgroundColor3 = BgDark
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke", MainFrame)
mainStroke.Color = ThemeColor
mainStroke.Thickness = 1.6
mainStroke.Transparency = 0.18

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, isMobile and 38 or 44)
TopBar.BackgroundColor3 = CardDark
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -180, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "NEXOARO  |  BLOX FRUITS"
Title.TextColor3 = TextMain
Title.Font = Enum.Font.GothamBlack
Title.TextSize = isMobile and 12 or 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

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
OpenPill.Size = UDim2.new(0, 120, 0, 32)
OpenPill.Position = UDim2.new(0.02, 0, 0.1, 0)
OpenPill.BackgroundColor3 = CardDark
OpenPill.Text = "◆ NEXOARO"
OpenPill.TextColor3 = AccentGlow
OpenPill.Font = Enum.Font.GothamBold
OpenPill.TextSize = 11
OpenPill.Visible = false
OpenPill.Parent = ScreenGui
Instance.new("UICorner", OpenPill).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", OpenPill).Color = ThemeColor

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
	ActiveFarmEnemy = nil
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
		local root = char and char:FindFirstChild("HumanoidRootPart")
		clearFlyMover(root)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = 16 end
	end)
	for _, esp in pairs(TrackedPlayers) do
		for _, d in pairs(esp) do
			if d and type(d.Remove) == "function" then pcall(function() d:Remove() end) end
		end
	end
	for _, esp in pairs(TrackedNPCs) do
		if esp and esp.Text and type(esp.Text.Remove) == "function" then
			pcall(function() esp.Text:Remove() end)
		end
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
Instance.new("UIStroke", StatusCard).Color = Color3.fromRGB(52, 44, 78)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -16, 1, 0)
StatusLabel.Position = UDim2.new(0, 8, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "●  Status: Ready | Dark Fist: None"
StatusLabel.TextColor3 = TextMuted
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 10
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusCard

local FistAlertBanner = Instance.new("TextLabel")
FistAlertBanner.Size = UDim2.new(1, -20, 0, 24)
FistAlertBanner.Position = UDim2.new(0, 10, 0, topOffset + 36)
FistAlertBanner.BackgroundColor3 = Color3.fromRGB(127, 29, 29)
FistAlertBanner.TextColor3 = Color3.new(1, 1, 1)
FistAlertBanner.Font = Enum.Font.GothamBold
FistAlertBanner.TextSize = 10
FistAlertBanner.Text = "★  DARK FIST / FIST OF DARKNESS DETECTED!"
FistAlertBanner.Visible = false
FistAlertBanner.Parent = MainFrame
Instance.new("UICorner", FistAlertBanner).CornerRadius = UDim.new(0, 7)

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

local bodyTop = topOffset + 80
local function makeTabContainer(canvasH, visible)
	local sf = Instance.new("ScrollingFrame")
	sf.Size = UDim2.new(1, -20, 1, -(bodyTop + 10))
	sf.Position = UDim2.new(0, 10, 0, bodyTop)
	sf.BackgroundTransparency = 1
	sf.ScrollBarThickness = 3
	sf.ScrollBarImageColor3 = ThemeColor
	sf.CanvasSize = UDim2.new(0, 0, 0, canvasH)
	sf.Visible = visible
	sf.Parent = MainFrame
	return sf
end

local Container1 = makeTabContainer(460, true)
local Container2 = makeTabContainer(240, false)
local Container3 = makeTabContainer(240, false)
local Container4 = makeTabContainer(160, false)
local Container5 = makeTabContainer(275, false)
local Container6 = makeTabContainer(160, false)
local Container7 = makeTabContainer((#FightingStylesList * 38) + 12, false)

local function setFistAlertUI(found, detailText)
	if found then
		FistAlertBanner.Visible = true
		FistAlertBanner.Text = "★  DARK FIST SPAWNED: " .. tostring(detailText or "Found")
		TabBar.Position = UDim2.new(0, 10, 0, topOffset + 64)
		for _, sf in ipairs({Container1, Container2, Container3, Container4, Container5, Container6, Container7}) do
			if sf then
				sf.Position = UDim2.new(0, 10, 0, topOffset + 104)
				sf.Size = UDim2.new(1, -20, 1, -(topOffset + 114))
			end
		end
	else
		FistAlertBanner.Visible = false
		TabBar.Position = UDim2.new(0, 10, 0, topOffset + 40)
		for _, sf in ipairs({Container1, Container2, Container3, Container4, Container5, Container6, Container7}) do
			if sf then
				sf.Position = UDim2.new(0, 10, 0, bodyTop)
				sf.Size = UDim2.new(1, -20, 1, -(bodyTop + 10))
			end
		end
	end
end

local tabNames = {"Farm", "Sea", "Player", "Visuals", "PvP", "Fruits", "Shop"}
local containers = {Container1, Container2, Container3, Container4, Container5, Container6, Container7}
local tabButtons = {}

local function switchTab(idx)
	for i, c in ipairs(containers) do
		c.Visible = (i == idx)
	end
	for i, b in ipairs(tabButtons) do
		local active = (i == idx)
		b.BackgroundTransparency = active and 0 or 1
		b.BackgroundColor3 = active and ThemeColor or Color3.fromRGB(24, 21, 38)
		b.TextColor3 = active and Color3.new(1, 1, 1) or TextMuted
	end
end

for i, name in ipairs(tabNames) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1 / #tabNames, -2.5, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(24, 21, 38)
	btn.BackgroundTransparency = (i == 1) and 0 or 1
	btn.Text = name
	btn.TextColor3 = (i == 1) and Color3.new(1, 1, 1) or TextMuted
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 8.5
	btn.Parent = TabBar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
	btn.MouseButton1Click:Connect(function() switchTab(i) end)
	table.insert(tabButtons, btn)
end

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
			target.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
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

	pill.MouseButton1Click:Connect(function()
		state = not state
		pill.Text = state and "ON" or "OFF"
		pill.BackgroundColor3 = state and ThemeColor or Color3.fromRGB(34, 30, 50)
		pill.TextColor3 = state and Color3.new(1, 1, 1) or TextMuted
		stroke.Color = state and ThemeColor or Color3.fromRGB(42, 36, 64)
		pcall(function() callback(state) end)
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
	Instance.new("UIStroke", row).Color = Color3.fromRGB(46, 39, 72)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -88, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = TextMain
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 10.5
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = row

	local actionBtn = Instance.new("TextButton")
	actionBtn.Size = UDim2.new(0, 72, 0, 20)
	actionBtn.Position = UDim2.new(1, -80, 0.5, -10)
	actionBtn.BackgroundColor3 = ThemeColor
	actionBtn.Text = buttonText
	actionBtn.TextColor3 = Color3.new(1, 1, 1)
	actionBtn.Font = Enum.Font.GothamBold
	actionBtn.TextSize = 9.5
	actionBtn.Active = true
	actionBtn.Parent = row
	Instance.new("UICorner", actionBtn).CornerRadius = UDim.new(0, 6)

	actionBtn.MouseButton1Click:Connect(function()
		pcall(function() callback(actionBtn) end)
	end)
	return row, actionBtn
end

local function createSlider(parent, yPos, prefix, minVal, maxVal, initialVal, onChange)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 42)
	card.Position = UDim2.new(0, 2, 0, yPos)
	card.BackgroundColor3 = CardDark
	card.BorderSizePixel = 0
	card.Parent = parent
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", card).Color = Color3.fromRGB(42, 36, 64)

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

local function toolMatchesCategory(tool, category)
	if not tool or not tool:IsA("Tool") then return false end
	local tip = string.lower(tostring(tool.ToolTip or ""))
	local name = string.lower(tostring(tool.Name or ""))
	if category == "Melee" then
		if string.find(tip, "melee", 1, true) then return true end
		for _, styleEntry in ipairs(FightingStylesList) do
			for _, kw in ipairs(styleEntry.toolKeywords or {}) do
				if string.find(name, string.lower(kw), 1, true) then return true end
			end
		end
		return false
	elseif category == "Fruit" then
		return string.find(tip, "fruit", 1, true) ~= nil or string.find(name, "fruit", 1, true) ~= nil
	elseif category == "Sword" then
		return string.find(tip, "sword", 1, true) ~= nil
	elseif category == "Gun" then
		return string.find(tip, "gun", 1, true) ~= nil
	end
	return true
end

local function equipSelectedWeapon(preferredCategory)
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		if not char or not hum or hum.Health <= 0 then return end

		local wanted = preferredCategory or SelectedFarmWeapon or "Melee"
		local current = char:FindFirstChildOfClass("Tool")
		if current and toolMatchesCategory(current, wanted) then return end

		if backpack then
			for _, tool in ipairs(backpack:GetChildren()) do
				if toolMatchesCategory(tool, wanted) then
					pcall(function() hum:EquipTool(tool) end)
					return
				end
			end
		end

		if not current and backpack then
			for _, fallbackCat in ipairs({"Melee", "Sword", "Fruit", "Gun"}) do
				for _, tool in ipairs(backpack:GetChildren()) do
					if toolMatchesCategory(tool, fallbackCat) then
						pcall(function() hum:EquipTool(tool) end)
						return
					end
				end
			end
		end
	end)
end

local function equipMatchingFightingStyle(styleEntry)
	local equipped = false
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local backpack = LocalPlayer:FindFirstChild("Backpack")
		if not char or not hum then return end

		local function matchesStyleTool(tool)
			if not tool or not tool:IsA("Tool") then return false end
			local tName = string.lower(tostring(tool.Name))
			local tType = string.lower(tostring(tool.ToolTip or ""))
			for _, kw in ipairs(styleEntry.toolKeywords or {}) do
				local k = string.lower(tostring(kw))
				if string.find(tName, k, 1, true) or string.find(tType, k, 1, true) then
					return true
				end
			end
			return false
		end

		for _, item in ipairs(char:GetChildren()) do
			if matchesStyleTool(item) then equipped = true; return end
		end
		if backpack then
			for _, item in ipairs(backpack:GetChildren()) do
				if matchesStyleTool(item) then
					pcall(function() hum:EquipTool(item) end)
					equipped = true
					return
				end
			end
		end
	end)
	return equipped
end

local function purchaseFightingStyle(styleEntry)
	StatusLabel.Text = "●  Shop: Buying " .. tostring(styleEntry.name) .. "..."
	StatusLabel.TextColor3 = AccentGlow
	task.spawn(function()
		pcall(function()
			local commf = getCommF()
			if commf then
				for _, argPack in ipairs(styleEntry.calls or {}) do
					invokeOrFireRemote(commf, table.unpack(argPack))
					task.wait(0.14)
				end
			end
			task.wait(0.35)
			if equipMatchingFightingStyle(styleEntry) then
				StatusLabel.Text = "●  Shop: Equipped " .. tostring(styleEntry.name)
				StatusLabel.TextColor3 = Color3.fromRGB(74, 222, 128)
			else
				StatusLabel.Text = "●  Shop: Sent Buy (" .. tostring(styleEntry.name) .. ")"
				StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
			end
		end)
	end)
end

local function strikeEnemy(char, targetRoot)
	local now = tick()
	local cooldown = FastAttackEnabled and 0.05 or 0.16
	if (now - LastHitTick) < cooldown then return end
	LastHitTick = now
	triggerAutoHaki()

	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local tool = char and char:FindFirstChildOfClass("Tool")
	if not tool or not toolMatchesCategory(tool, SelectedFarmWeapon) then
		equipSelectedWeapon(SelectedFarmWeapon)
		tool = char and char:FindFirstChildOfClass("Tool")
	end

	if hum and hum.Health > 0 and tool and tool:IsA("Tool") then
		pcall(function()
			if type(tool.Activate) == "function" then
				tool:Activate()
			end
		end)

		local combatRemote = getCombatRemote()
		if combatRemote and targetRoot and targetRoot.Parent then
			pcall(function()
				combatRemote:FireServer(targetRoot.Position, {targetRoot})
			end)
		end

		local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
		local cx, cy = vp.X * 0.5, vp.Y * 0.5
		if VirtualInputManager then
			pcall(function()
				VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
				VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
			end)
		end
		if VirtualUser then
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton1(Vector2.new(cx, cy))
			end)
		end
		if type(mouse1click) == "function" then
			pcall(mouse1click)
		end
	end
end

createToggle(Container1, "Auto Farm Mobs (Level Locked)", 0, false, function(state)
	AutoFarmEnabled = state
	ActiveFarmEnemy = nil
	if state then
		LockedFarmBracket = getBracketForLevel(getPlayerLevel())
	elseif not hasActiveTargetFarm() then
		LockedFarmBracket = nil
		clearFlyMover(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
		StatusLabel.Text = "●  Status: Ready | Dark Fist: None"
		StatusLabel.TextColor3 = TextMuted
	end
end)

createToggle(Container1, "Farm Vampire (Fangs)", 38, false, function(state)
	FarmVampireEnabled = state
	ActiveFarmEnemy = nil
	if not hasActiveTargetFarm() then
		clearFlyMover(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
	end
end)

createToggle(Container1, "Farm Demonic Soul", 76, false, function(state)
	FarmDemonicSoulEnabled = state
	ActiveFarmEnemy = nil
	if not hasActiveTargetFarm() then
		clearFlyMover(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
	end
end)

createToggle(Container1, "Auto Farm Dragon Scale", 114, false, function(state)
	FarmDragonScaleEnabled = state
	ActiveFarmEnemy = nil
	if not hasActiveTargetFarm() then
		clearFlyMover(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
	end
end)

createToggle(Container1, "Auto Farm Bones", 152, false, function(state)
	FarmBonesEnabled = state
	ActiveFarmEnemy = nil
	if not hasActiveTargetFarm() then
		clearFlyMover(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
	end
end)

local _, weaponBtn = createActionButton(Container1, "Farm Weapon", SelectedFarmWeapon, 190, function(btn)
	WeaponModeIndex = (WeaponModeIndex % #WeaponModes) + 1
	SelectedFarmWeapon = WeaponModes[WeaponModeIndex]
	btn.Text = SelectedFarmWeapon
	equipSelectedWeapon(SelectedFarmWeapon)
end)

createToggle(Container1, "Bring Mobs Under You", 228, true, function(state) BringMobsEnabled = state end)
createToggle(Container1, "Auto Quest (Level Based)", 266, true, function(state) AutoQuestEnabled = state end)
createToggle(Container1, "Fast Attack", 304, true, function(state) FastAttackEnabled = state end)
createSlider(Container1, 342, "Farm Fly Speed", 60, 800, FlySpeed, function(val) FlySpeed = val end)

createToggle(Container2, "Boat Noclip (Rocks)", 0, false, function(state) BoatNoclipEnabled = state end)
createToggle(Container2, "Auto Chest (All Map)", 38, false, function(state)
	AutoChestEnabled = state
	if not state and not hasActiveTargetFarm() then
		clearFlyMover(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
	end
end)
createToggle(Container2, "Boat Speed Boost", 76, false, function(state) BoatSpeedEnabled = state end)
createSlider(Container2, 114, "Boat Speed", 16, 1000, TargetBoatSpeed, function(val) TargetBoatSpeed = val end)
createToggle(Container2, "Auto Attack Sea Beast / Shark", 164, false, function(state) AutoAttackSeaEnabled = state end)
createToggle(Container2, "Auto Sail (Stop on Event)", 202, false, function(state)
	AutoSailEnabled = state
	if state then
		pcall(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and hum.SeatPart then
				local look = hum.SeatPart.CFrame.LookVector
				local flat = Vector3.new(look.X, 0, look.Z)
				LockedSailDir = flat.Magnitude > 0.01 and flat.Unit or Vector3.new(0, 0, -1)
			end
		end)
	else
		LockedSailDir = nil
	end
end)

createToggle(Container3, "Walk Speed Boost", 0, false, function(state)
	WalkSpeedEnabled = state
	pcall(function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = state and TargetWalkSpeed or 16 end
	end)
end)
createSlider(Container3, 38, "Walk Speed", 16, 350, TargetWalkSpeed, function(val) TargetWalkSpeed = val end)
createToggle(Container3, "Walk On Water", 88, false, function(state)
	WalkOnWaterEnabled = state
	if not state then ensureWalkOnWaterPart(nil) end
end)
createToggle(Container3, "Auto Haki (Buso)", 126, true, function(state) AutoHakiEnabled = state end)
createToggle(Container3, "Anti AFK", 164, true, function(state) AntiAFKEnabled = state end)

createToggle(Container4, "ESP (Players & Sea)", 0, false, function(state) ESPEnabled = state end)
createToggle(Container4, "Remove Fog", 38, false, function(state)
	RemoveFogEnabled = state
	if state then clearSeaFog() else restoreOriginalFogState() end
end)

createToggle(Container5, "Auto Kill Target", 0, false, function(state) PvPEnabled = state end)
createToggle(Container5, "Aim Bot", 38, false, function(state) AimBotEnabled = state end)

local TargetLabel = Instance.new("TextLabel")
TargetLabel.Size = UDim2.new(1, -92, 0, 28)
TargetLabel.Position = UDim2.new(0, 8, 0, 78)
TargetLabel.BackgroundColor3 = CardDark
TargetLabel.Text = "Target: None"
TargetLabel.TextColor3 = TextMain
TargetLabel.Font = Enum.Font.GothamSemibold
TargetLabel.TextSize = 10
TargetLabel.Parent = Container5
Instance.new("UICorner", TargetLabel).CornerRadius = UDim.new(0, 8)

local NextTargetBtn = Instance.new("TextButton")
NextTargetBtn.Size = UDim2.new(0, 76, 0, 28)
NextTargetBtn.Position = UDim2.new(1, -80, 0, 78)
NextTargetBtn.BackgroundColor3 = ThemeColor
NextTargetBtn.Text = "Next Player"
NextTargetBtn.TextColor3 = Color3.new(1, 1, 1)
NextTargetBtn.Font = Enum.Font.GothamBold
NextTargetBtn.TextSize = 9.5
NextTargetBtn.Parent = Container5
Instance.new("UICorner", NextTargetBtn).CornerRadius = UDim.new(0, 8)

createSlider(Container5, 114, "PvP Follow Speed", 80, 900, PvPSpeed, function(val) PvPSpeed = val end)

local PlayerListFrame = Instance.new("ScrollingFrame")
PlayerListFrame.Size = UDim2.new(1, -6, 0, 102)
PlayerListFrame.Position = UDim2.new(0, 2, 0, 162)
PlayerListFrame.BackgroundColor3 = CardDark
PlayerListFrame.ScrollBarThickness = 2
PlayerListFrame.ScrollBarImageColor3 = ThemeColor
PlayerListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerListFrame.Parent = Container5
Instance.new("UICorner", PlayerListFrame).CornerRadius = UDim.new(0, 8)

createToggle(Container6, "Auto Get Fruits", 0, false, function(state) AutoGetFruitsEnabled = state end)
createToggle(Container6, "Auto Store Fruit", 38, false, function(state) AutoStoreFruitEnabled = state end)
createToggle(Container6, "Auto Roll Fruit", 76, false, function(state) AutoRollFruitEnabled = state end)

for i, styleEntry in ipairs(FightingStylesList) do
	createActionButton(Container7, styleEntry.name, "Buy", (i - 1) * 38, function()
		purchaseFightingStyle(styleEntry)
	end)
end

local function selectPvPPlayer(plr)
	SelectedPvPPlayer = plr
	TargetLabel.Text = (plr and plr.Parent) and ("Target: " .. tostring(plr.Name)) or "Target: None"
end

local function refreshPlayerList()
	pcall(function()
		for _, child in ipairs(PlayerListFrame:GetChildren()) do
			if child:IsA("TextButton") then child:Destroy() end
		end
		local others = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then table.insert(others, p) end
		end
		if not SelectedPvPPlayer or not SelectedPvPPlayer.Parent then
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
		if p ~= LocalPlayer then table.insert(others, p) end
	end
	if #others == 0 then selectPvPPlayer(nil); refreshPlayerList(); return end
	local nextIdx = 1
	for i, p in ipairs(others) do
		if p == SelectedPvPPlayer then nextIdx = (i % #others) + 1; break end
	end
	selectPvPPlayer(others[nextIdx])
	refreshPlayerList()
end)

Players.PlayerAdded:Connect(function() task.wait(0.2); refreshPlayerList() end)
Players.PlayerRemoving:Connect(function(plr)
	if plr == SelectedPvPPlayer then SelectedPvPPlayer = nil end
	refreshPlayerList()
end)
refreshPlayerList()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
		MainFrame.Visible = not MainFrame.Visible
		OpenPill.Visible = not MainFrame.Visible
	end
end)

local function hasActiveQuest()
	local pg = LocalPlayer:FindFirstChild("PlayerGui")
	local main = pg and pg:FindFirstChild("Main")
	local questFrame = main and main:FindFirstChild("Quest")
	return (questFrame and questFrame.Visible) == true
end

local function tryTakeBracketQuest(bracket)
	if not AutoQuestEnabled or not bracket then return end
	local commf = getCommF()
	if commf and bracket.questName then
		invokeOrFireRemote(commf, "StartQuest", bracket.questName, bracket.questNum or 1)
	end
end

local function bringMobsUnderPlayer(centerPos, mainEnemyRoot, activeBracket)
	if not BringMobsEnabled or not mainEnemyRoot then return end
	local now = tick()
	if (now - LastBringTick) < 0.28 then return end
	LastBringTick = now
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then return end
	local stackPos = mainEnemyRoot.Position - Vector3.new(0, 2, 0)
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if enemy:IsA("Model") and enemy ~= ActiveFarmEnemy and (not activeBracket or enemyMatchesBracket(enemy, activeBracket)) then
			local eRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
			local eHum = enemy:FindFirstChildOfClass("Humanoid")
			if eRoot and eHum and eHum.Health > 0 and eRoot ~= mainEnemyRoot then
				if (centerPos - eRoot.Position).Magnitude <= BringRadius then
					pcall(function()
						eRoot.CanCollide = false
						eRoot.Anchored = false
						eRoot.AssemblyLinearVelocity = Vector3.zero
						eRoot.AssemblyAngularVelocity = Vector3.zero
						eRoot.CFrame = CFrame.new(stackPos)
					end)
				end
			end
		end
	end
end

local function farmTargetModel(char, root, targetEnemy, tRoot, tHum, prefix, color, activeBracket)
	if targetEnemy and tRoot and tHum and tHum.Health > 0 then
		local fistTag = FistDetectedState and " | ★ DARK FIST!" or ""
		StatusLabel.Text = "●  " .. prefix .. " [" .. SelectedFarmWeapon .. "]: " .. tostring(targetEnemy.Name) .. " (" .. tostring(math.floor(tHum.Health)) .. " HP)" .. fistTag
		StatusLabel.TextColor3 = FistDetectedState and Color3.fromRGB(250, 204, 21) or color
		local hoverHeight = (SelectedFarmWeapon == "Gun") and 11 or 8
		local targetPos = tRoot.Position + Vector3.new(0, hoverHeight, 0)
		moveToTarget(root, CFrame.lookAt(targetPos, tRoot.Position), FlySpeed)
		if (root.Position - tRoot.Position).Magnitude <= 80 then
			bringMobsUnderPlayer(root.Position, tRoot, activeBracket)
			strikeEnemy(char, tRoot)
		end
		return true
	end
	return false
end

task.spawn(function()
	while ScriptRunning do
		task.wait(0.35)
		local ok, found, detail = pcall(findFistOfDarknessLocation)
		if ok and found then
			FistDetectedState = true
			setFistAlertUI(true, detail)
			if (tick() - LastFistAlertTick) >= 3 then
				LastFistAlertTick = tick()
				pcall(function()
					game:GetService("StarterGui"):SetCore("SendNotification", {
						Title = "NEXOARO | DARK FIST",
						Text = "Spawned: " .. tostring(detail),
						Duration = 5
					})
				end)
			end
		else
			if FistDetectedState then
				FistDetectedState = false
				setFistAlertUI(false, nil)
			end
		end
	end
end)

task.spawn(function()
	while ScriptRunning do
		task.wait(0.05)
		if hasActiveTargetFarm() then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				local myLvl = getPlayerLevel()
				equipSelectedWeapon(SelectedFarmWeapon)

				if FarmBonesEnabled then
					local e, eRoot, eHum = getLockedOrNearestEnemy(root.Position, isBoneEnemy, nil)
					if not farmTargetModel(char, root, e, eRoot, eHum, "Bones", Color3.fromRGB(226, 232, 240), nil) then
						moveToTarget(root, CFrame.new(getHauntedCastleBonesPosition()), FlySpeed)
					end
				elseif FarmDragonScaleEnabled then
					local e, eRoot, eHum = getLockedOrNearestEnemy(root.Position, isDragonScaleEnemy, nil)
					if not farmTargetModel(char, root, e, eRoot, eHum, "Dragon Scale", Color3.fromRGB(249, 115, 22), nil) then
						moveToTarget(root, CFrame.new(getHydraDragonScalePosition()), FlySpeed)
					end
				elseif FarmVampireEnabled then
					local e, eRoot, eHum = getLockedOrNearestEnemy(root.Position, isVampireEnemy, nil)
					if not farmTargetModel(char, root, e, eRoot, eHum, "Vampire", EnemyColor, nil) then
						StatusLabel.Text = "●  Vampire: Waiting Respawn..."
						StatusLabel.TextColor3 = ChestColor
					end
				elseif FarmDemonicSoulEnabled then
					local e, eRoot, eHum = getLockedOrNearestEnemy(root.Position, isDemonicSoulEnemy, nil)
					if not farmTargetModel(char, root, e, eRoot, eHum, "Demonic Soul", FruitColor, nil) then
						StatusLabel.Text = "●  Demonic Soul: Waiting Respawn..."
						StatusLabel.TextColor3 = ChestColor
					end
				elseif AutoFarmEnabled then
					if not LockedFarmBracket or myLvl > LockedFarmBracket.maxLvl or myLvl < LockedFarmBracket.minLvl then
						LockedFarmBracket = getBracketForLevel(myLvl)
					end
					local bracket = LockedFarmBracket
					if AutoQuestEnabled and not hasActiveQuest() and (tick() - LastQuestAttemptTick) > 2.5 then
						LastQuestAttemptTick = tick()
						tryTakeBracketQuest(bracket)
					end
					local e, eRoot, eHum = getLockedOrNearestEnemy(root.Position, nil, bracket)
					if not farmTargetModel(char, root, e, eRoot, eHum, "Lv." .. tostring(myLvl) .. " | " .. bracket.questText, Color3.fromRGB(74, 222, 128), bracket) then
						local sp = getSpawnPositionForKeywords(bracket.keywords, HighDiscipleFallbackPos)
						StatusLabel.Text = "●  Waiting/Moving to " .. bracket.questText .. " [Lv." .. tostring(bracket.minLvl) .. "-" .. tostring(bracket.maxLvl) .. "]..."
						StatusLabel.TextColor3 = ChestColor
						moveToTarget(root, CFrame.new(sp), FlySpeed)
					end
				end
			end
		else
			ActiveFarmEnemy = nil
		end
	end
end)

task.spawn(function()
	while ScriptRunning do
		task.wait(0.08)
		if AutoChestEnabled and not hasActiveTargetFarm() then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				local chestPart, chestName, chestDist = findNearestChestPart(root.Position)
				if chestPart then
					StatusLabel.Text = "●  Chest: " .. tostring(chestName) .. " [" .. tostring(math.floor(chestDist)) .. "m]"
					StatusLabel.TextColor3 = ChestColor
					moveToTarget(root, chestPart.CFrame + Vector3.new(0, 1.5, 0), FlySpeed)
				else
					StatusLabel.Text = "●  Chest: No loaded chests nearby"
					StatusLabel.TextColor3 = TextMuted
				end
			end
		end
	end
end)

task.spawn(function()
	while ScriptRunning do
		task.wait(0.1)
		if AutoGetFruitsEnabled then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				local bestPart, bestName, bestDist = nil, nil, math.huge
				for _, obj in ipairs(Workspace:GetChildren()) do
					if isPickupableFruitInstance(obj) then
						local part = getFruitAnchorPart(obj)
						if part and part.Parent then
							local d = (root.Position - part.Position).Magnitude
							if d < bestDist then
								bestDist, bestPart, bestName = d, part, resolveBloxFruitName(obj.Name) or obj.Name
							end
						end
					end
				end
				if bestPart then
					StatusLabel.Text = "●  Fruit: " .. tostring(bestName) .. " [" .. tostring(math.floor(bestDist)) .. "m]"
					StatusLabel.TextColor3 = FruitColor
					moveToTarget(root, bestPart.CFrame + Vector3.new(0, 1.5, 0), FlySpeed)
				end
			end
		end

		if AutoStoreFruitEnabled and (tick() - LastStoreTick) >= 1.2 then
			LastStoreTick = tick()
			local commf = getCommF()
			if commf then
				for _, cont in ipairs({LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}) do
					if cont then
						for _, item in ipairs(cont:GetChildren()) do
							local resolved = item:IsA("Tool") and resolveBloxFruitName(item.Name) or nil
							if resolved then
								invokeOrFireRemote(commf, "StoreFruit", getStoreFruitKey(item, resolved), item)
								invokeOrFireRemote(commf, "StoreFruit", resolved, item)
							end
						end
					end
				end
			end
		end

		if AutoRollFruitEnabled and (tick() - LastRollTick) >= 2.2 then
			LastRollTick = tick()
			local commf = getCommF()
			if commf then
				invokeOrFireRemote(commf, "Censor")
				invokeOrFireRemote(commf, "RollFruit")
			end
		end
	end
end)

task.spawn(function()
	while ScriptRunning do
		task.wait(0.05)
		if PvPEnabled or AimBotEnabled then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local targetPlr = SelectedPvPPlayer
			if root and targetPlr and targetPlr.Parent and targetPlr ~= LocalPlayer and targetPlr.Character then
				local tRoot = targetPlr.Character:FindFirstChild("HumanoidRootPart")
				local tHum = targetPlr.Character:FindFirstChildOfClass("Humanoid")
				if tRoot and tHum and tHum.Health > 0 then
					if AimBotEnabled and Camera then
						Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tRoot.Position)
					end
					if PvPEnabled then
						local goalCF = CFrame.lookAt((tRoot.CFrame * CFrame.new(0, 0, 3)).Position, tRoot.Position)
						moveToTarget(root, goalCF, PvPSpeed)
						if (root.Position - tRoot.Position).Magnitude <= 25 then
							strikeEnemy(char, tRoot)
						end
					end
				end
			end
		end
	end
end)

RunService.Stepped:Connect(function()
	if not ScriptRunning then return end
	local char = LocalPlayer.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	if WalkOnWaterEnabled and root then
		ensureWalkOnWaterPart(root.Position)
	end
	if hum and WalkSpeedEnabled and hum.WalkSpeed ~= TargetWalkSpeed then
		hum.WalkSpeed = TargetWalkSpeed
	end
	if AutoSailEnabled and hum and hum.SeatPart and LockedSailDir then
		local seat = hum.SeatPart
		local vel = LockedSailDir * TargetBoatSpeed
		seat.AssemblyLinearVelocity = Vector3.new(vel.X, seat.AssemblyLinearVelocity.Y, vel.Z)
		if seat:IsA("VehicleSeat") then
			seat.MaxSpeed = math.max(TargetBoatSpeed, 150)
			seat.Throttle = 1
			seat.Steer = 0
		end
	end

	local noclipActive = hasActiveTargetFarm() or AutoChestEnabled or PvPEnabled or AutoGetFruitsEnabled or (BoatNoclipEnabled and hum and hum.SeatPart)
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

if Drawing and type(Drawing.new) == "function" then
	local function addPlayerESP(player)
		if player == LocalPlayer or TrackedPlayers[player] then return end
		pcall(function()
			TrackedPlayers[player] = {
				Box = Drawing.new("Square"),
				Name = Drawing.new("Text")
			}
			TrackedPlayers[player].Box.Thickness = 1.5
			TrackedPlayers[player].Box.Color = ThemeColor
			TrackedPlayers[player].Box.Filled = false
			TrackedPlayers[player].Box.Visible = false
			TrackedPlayers[player].Name.Size = 12
			TrackedPlayers[player].Name.Center = true
			TrackedPlayers[player].Name.Outline = true
			TrackedPlayers[player].Name.Color = Color3.new(1, 1, 1)
			TrackedPlayers[player].Name.Visible = false
		end)
	end

	for _, p in ipairs(Players:GetPlayers()) do addPlayerESP(p) end
	Players.PlayerAdded:Connect(addPlayerESP)
	Players.PlayerRemoving:Connect(function(p)
		local d = TrackedPlayers[p]
		if d then
			for _, obj in pairs(d) do pcall(function() obj:Remove() end) end
			TrackedPlayers[p] = nil
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not ScriptRunning or not Camera then return end
		local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		for player, esp in pairs(TrackedPlayers) do
			local char = player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if ESPEnabled and root and hum and hum.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
				if onScreen then
					local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
					esp.Box.Size = Vector2.new(36, 54)
					esp.Box.Position = Vector2.new(pos.X - 18, pos.Y - 27)
					esp.Box.Visible = true
					esp.Name.Text = player.Name .. " [" .. dist .. "m]"
					esp.Name.Position = Vector2.new(pos.X, pos.Y - 40)
					esp.Name.Visible = true
				else
					esp.Box.Visible = false
					esp.Name.Visible = false
				end
			else
				esp.Box.Visible = false
				esp.Name.Visible = false
			end
		end
	end)
end

print("[NEXOARO] Blox Fruits Hub Loaded")
