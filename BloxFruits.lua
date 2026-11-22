local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local HttpService = game:GetService("HttpService")

local VirtualUser = nil
pcall(function()
	VirtualUser = game:GetService("VirtualUser")
end)

local VirtualInputManager = nil
pcall(function()
	VirtualInputManager = game:GetService("VirtualInputManager")
end)

local StarterGui = nil
pcall(function()
	StarterGui = game:GetService("StarterGui")
end)

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ColorScheme = {
	Background = Color3.fromRGB(9, 8, 15),
	Surface = Color3.fromRGB(17, 15, 28),
	SurfaceAlt = Color3.fromRGB(24, 21, 40),
	Primary = Color3.fromRGB(168, 85, 247),
	Accent = Color3.fromRGB(216, 180, 254),
	Text = Color3.fromRGB(246, 245, 255),
	Muted = Color3.fromRGB(154, 150, 178),
	Success = Color3.fromRGB(74, 222, 128),
	Warning = Color3.fromRGB(250, 204, 21),
	Danger = Color3.fromRGB(244, 63, 94),
	Raid = Color3.fromRGB(56, 189, 248),
	Fruit = Color3.fromRGB(192, 132, 252)
}

local State = {
	Running = true,
	AutoFarm = false,
	AutoRaid = false,
	AutoAwaken = true,
	FarmVampire = false,
	FarmDemonicSoul = false,
	FarmDragonScale = false,
	FarmBones = false,
	BringMobs = true,
	AutoQuest = true,
	FastAttack = true,
	FastAttackDelay = 0.1,
	AutoHaki = true,
	AntiAFK = true,
	WalkOnWater = false,
	WalkSpeedEnabled = false,
	WalkSpeedValue = 120,
	BoatSpeedEnabled = false,
	BoatSpeedValue = 210,
	AutoSailEnabled = false,
	BoatNoclipEnabled = false,
	AutoChestEnabled = false,
	AutoAttackSeaEnabled = false,
	ESPEnabled = false,
	RemoveFogEnabled = false,
	AutoGetFruits = false,
	AutoStoreFruit = false,
	AutoRollFruit = false,
	PvPEnabled = false,
	AimBotEnabled = false,
	PvPSpeed = 360,
	FlySpeed = 400,
	BringRadius = 190,
	WeaponIndex = 1,
	RaidChipIndex = 1,
	RaidIslandIndex = 1,
	FistDetected = false
}

local WeaponCategories = {"Melee", "Fruit", "Sword", "Gun"}

local RaidChipCatalog = {
	"Flame", "Ice", "Quake", "Light", "Dark",
	"Spider", "Rumble", "Magma", "Buddha", "Sand",
	"Dough", "Phoenix"
}

local IslandFallbackPoints = {
	Starter = Vector3.new(1060, 16, 1547),
	Jungle = Vector3.new(-1601, 36, 153),
	PirateVillage = Vector3.new(-1140, 4, 3827),
	Desert = Vector3.new(894, 6, 4390),
	FrozenVillage = Vector3.new(1389, 87, -1298),
	MarineFortress = Vector3.new(-5039, 28, 4324),
	Skylands = Vector3.new(-4841, 717, -2623),
	Prison = Vector3.new(4854, 5, 740),
	Colosseum = Vector3.new(-1580, 7, -2986),
	MagmaVillage = Vector3.new(-5313, 12, 8515),
	UnderwaterCity = Vector3.new(61122, 18, 1569),
	KingdomOfRose = Vector3.new(-427, 73, 1836),
	GreenZone = Vector3.new(628, 73, 938),
	Graveyard = Vector3.new(-5494, 48, -794),
	SnowMountain = Vector3.new(1389, 87, -1298),
	HotAndCold = Vector3.new(-5494, 48, -794),
	CursedShip = Vector3.new(-6500, 80, -120),
	IceCastle = Vector3.new(5400, 35, -6200),
	ForgottenIsland = Vector3.new(-3050, 240, -10180),
	PortTown = Vector3.new(-290, 45, 5350),
	HydraIsland = Vector3.new(5750, 610, -280),
	GreatTree = Vector3.new(2250, 25, -6420),
	FloatingTurtle = Vector3.new(-13233, 332, -7625),
	HauntedCastle = Vector3.new(-9500, 145, 6080),
	SeaOfTreats = Vector3.new(-2050, 120, -12350),
	TikiOutpost = Vector3.new(-16220, 10, 440),
	HighDisciple = Vector3.new(-6730, 75, -1285)
}

local RaidIslandOffsets = {
	Vector3.new(0, 70, 0),
	Vector3.new(420, 80, 240),
	Vector3.new(-420, 80, 480),
	Vector3.new(480, 85, -420),
	Vector3.new(-480, 85, -480)
}

local Timers = {
	LastHit = 0,
	LastBring = 0,
	LastRoll = 0,
	LastStore = 0,
	LastHaki = 0,
	LastQuest = 0,
	LastFistAlert = 0,
	LastRaidStart = 0,
	LastAwaken = 0,
	LastSeaCheck = 0
}

local RuntimeRefs = {
	WaterPart = nil,
	SavedFog = nil,
	LockedBracket = nil,
	CachedCombat = nil,
	ActiveEnemy = nil,
	SelectedPvP = nil,
	LockedSailDir = nil,
	VisitedChests = {},
	PlayerESP = {}
}

local FightingStylesCatalog = {
	{
		name = "Dark Step",
		costNote = "150,000 Beli",
		cmds = {{"BuyBlackLeg"}, {"BuyBlackLeg", true}, {"BuyBlackLeg", "Buy"}},
		keywords = {"dark step", "black leg", "step"}
	},
	{
		name = "Electric",
		costNote = "500,000 Beli",
		cmds = {{"BuyElectro"}, {"BuyElectro", true}, {"BuyElectro", "Buy"}},
		keywords = {"electric", "electro"}
	},
	{
		name = "Water Kung Fu",
		costNote = "750,000 Beli",
		cmds = {{"BuyFishmanKarate"}, {"BuyFishmanKarate", true}, {"BuyFishmanKarate", "Buy"}},
		keywords = {"water kung", "fishman karate", "water kung fu"}
	},
	{
		name = "Dragon Breath",
		costNote = "1,500 Fragments",
		cmds = {{"BlackbeardReward", "DragonClaw", "1"}, {"BlackbeardReward", "DragonClaw", "2"}, {"BuyDragonClaw"}},
		keywords = {"dragon breath", "dragon claw"}
	},
	{
		name = "Superhuman",
		costNote = "3,000,000 Beli",
		cmds = {{"BuySuperhuman"}, {"BuySuperhuman", true}, {"BuySuperhuman", "Buy"}},
		keywords = {"superhuman"}
	},
	{
		name = "Death Step",
		costNote = "2.5M Beli + 5K Frags",
		cmds = {{"BuyDeathStep"}, {"BuyDeathStep", true}, {"BuyDeathStep", "Buy"}},
		keywords = {"death step"}
	},
	{
		name = "Sharkman Karate",
		costNote = "2.5M Beli + 5K Frags",
		cmds = {{"BuySharkmanKarate"}, {"BuySharkmanKarate", true}, {"BuySharkmanKarate", "Buy"}},
		keywords = {"sharkman karate", "sharkman"}
	},
	{
		name = "Electric Claw",
		costNote = "3M Beli + 5K Frags",
		cmds = {{"BuyElectricClaw"}, {"BuyElectricClaw", true}, {"BuyElectricClaw", "Buy"}},
		keywords = {"electric claw"}
	},
	{
		name = "Dragon Talon",
		costNote = "3M Beli + 5K Frags",
		cmds = {{"BuyDragonTalon"}, {"BuyDragonTalon", true}, {"BuyDragonTalon", "Buy"}},
		keywords = {"dragon talon"}
	},
	{
		name = "Godhuman",
		costNote = "5M Beli + 5K Frags",
		cmds = {{"BuyGodhuman"}, {"BuyGodhuman", true}, {"BuyGodhuman", "Buy"}},
		keywords = {"godhuman"}
	},
	{
		name = "Sanguine Art",
		costNote = "5M Beli + 5K Frags",
		cmds = {{"BuySanguineArt"}, {"BuySanguineArt", true}, {"BuySanguineArt", "Buy"}},
		keywords = {"sanguine art", "sanguine"}
	}
}

local LevelQuestProgression = {
	{minLvl = 1, maxLvl = 9, keywords = {"bandit"}, questText = "Bandit", questName = "BanditQuest1", questNum = 1, fallback = IslandFallbackPoints.Starter},
	{minLvl = 10, maxLvl = 14, keywords = {"monkey"}, questText = "Monkey", questName = "JungleQuest", questNum = 1, fallback = IslandFallbackPoints.Jungle},
	{minLvl = 15, maxLvl = 29, keywords = {"gorilla"}, questText = "Gorilla", questName = "JungleQuest", questNum = 2, fallback = IslandFallbackPoints.Jungle},
	{minLvl = 30, maxLvl = 39, keywords = {"pirate"}, questText = "Pirate", questName = "BuggyQuest1", questNum = 1, fallback = IslandFallbackPoints.PirateVillage},
	{minLvl = 40, maxLvl = 59, keywords = {"brute"}, questText = "Brute", questName = "BuggyQuest1", questNum = 2, fallback = IslandFallbackPoints.PirateVillage},
	{minLvl = 60, maxLvl = 74, keywords = {"desert bandit"}, questText = "Desert Bandit", questName = "DesertQuest", questNum = 1, fallback = IslandFallbackPoints.Desert},
	{minLvl = 75, maxLvl = 89, keywords = {"desert officer"}, questText = "Desert Officer", questName = "DesertQuest", questNum = 2, fallback = IslandFallbackPoints.Desert},
	{minLvl = 90, maxLvl = 99, keywords = {"snow bandit"}, questText = "Snow Bandit", questName = "SnowQuest", questNum = 1, fallback = IslandFallbackPoints.FrozenVillage},
	{minLvl = 100, maxLvl = 119, keywords = {"snowman"}, questText = "Snowman", questName = "SnowQuest", questNum = 2, fallback = IslandFallbackPoints.FrozenVillage},
	{minLvl = 120, maxLvl = 149, keywords = {"chief petty officer"}, questText = "Chief Petty Officer", questName = "MarineQuest2", questNum = 1, fallback = IslandFallbackPoints.MarineFortress},
	{minLvl = 150, maxLvl = 174, keywords = {"sky bandit"}, questText = "Sky Bandit", questName = "SkyQuest", questNum = 1, fallback = IslandFallbackPoints.Skylands},
	{minLvl = 175, maxLvl = 189, keywords = {"dark master"}, questText = "Dark Master", questName = "SkyQuest", questNum = 2, fallback = IslandFallbackPoints.Skylands},
	{minLvl = 190, maxLvl = 209, keywords = {"prisoner"}, questText = "Prisoner", questName = "PrisonerQuest", questNum = 1, fallback = IslandFallbackPoints.Prison},
	{minLvl = 210, maxLvl = 249, keywords = {"dangerous prisoner"}, questText = "Dangerous Prisoner", questName = "PrisonerQuest", questNum = 2, fallback = IslandFallbackPoints.Prison},
	{minLvl = 250, maxLvl = 274, keywords = {"toga warrior"}, questText = "Toga Warrior", questName = "ColosseumQuest", questNum = 1, fallback = IslandFallbackPoints.Colosseum},
	{minLvl = 275, maxLvl = 299, keywords = {"gladiator"}, questText = "Gladiator", questName = "ColosseumQuest", questNum = 2, fallback = IslandFallbackPoints.Colosseum},
	{minLvl = 300, maxLvl = 324, keywords = {"military soldier"}, questText = "Military Soldier", questName = "MagmaQuest", questNum = 1, fallback = IslandFallbackPoints.MagmaVillage},
	{minLvl = 325, maxLvl = 374, keywords = {"military spy"}, questText = "Military Spy", questName = "MagmaQuest", questNum = 2, fallback = IslandFallbackPoints.MagmaVillage},
	{minLvl = 375, maxLvl = 399, keywords = {"fishman warrior"}, questText = "Fishman Warrior", questName = "FishmanQuest", questNum = 1, fallback = IslandFallbackPoints.UnderwaterCity},
	{minLvl = 400, maxLvl = 449, keywords = {"fishman commando"}, questText = "Fishman Commando", questName = "FishmanQuest", questNum = 2, fallback = IslandFallbackPoints.UnderwaterCity},
	{minLvl = 450, maxLvl = 474, keywords = {"god's guard", "gods guard"}, questText = "God's Guard", questName = "SkyExp1Quest", questNum = 1, fallback = IslandFallbackPoints.Skylands},
	{minLvl = 475, maxLvl = 524, keywords = {"shanda"}, questText = "Shanda", questName = "SkyExp1Quest", questNum = 2, fallback = IslandFallbackPoints.Skylands},
	{minLvl = 525, maxLvl = 549, keywords = {"royal squad"}, questText = "Royal Squad", questName = "SkyExp2Quest", questNum = 1, fallback = IslandFallbackPoints.Skylands},
	{minLvl = 550, maxLvl = 624, keywords = {"royal soldier"}, questText = "Royal Soldier", questName = "SkyExp2Quest", questNum = 2, fallback = IslandFallbackPoints.Skylands},
	{minLvl = 625, maxLvl = 649, keywords = {"galley pirate"}, questText = "Galley Pirate", questName = "FountainQuest", questNum = 1, fallback = IslandFallbackPoints.UnderwaterCity},
	{minLvl = 650, maxLvl = 699, keywords = {"galley captain"}, questText = "Galley Captain", questName = "FountainQuest", questNum = 2, fallback = IslandFallbackPoints.UnderwaterCity},
	{minLvl = 700, maxLvl = 724, keywords = {"raider"}, questText = "Raider", questName = "Area1Quest", questNum = 1, fallback = IslandFallbackPoints.KingdomOfRose},
	{minLvl = 725, maxLvl = 774, keywords = {"mercenary"}, questText = "Mercenary", questName = "Area1Quest", questNum = 2, fallback = IslandFallbackPoints.KingdomOfRose},
	{minLvl = 775, maxLvl = 799, keywords = {"swan pirate"}, questText = "Swan Pirate", questName = "Area2Quest", questNum = 1, fallback = IslandFallbackPoints.GreenZone},
	{minLvl = 800, maxLvl = 874, keywords = {"factory staff"}, questText = "Factory Staff", questName = "Area2Quest", questNum = 2, fallback = IslandFallbackPoints.GreenZone},
	{minLvl = 875, maxLvl = 899, keywords = {"marine lieutenant"}, questText = "Marine Lieutenant", questName = "MarineQuest3", questNum = 1, fallback = IslandFallbackPoints.KingdomOfRose},
	{minLvl = 900, maxLvl = 949, keywords = {"marine captain"}, questText = "Marine Captain", questName = "MarineQuest3", questNum = 2, fallback = IslandFallbackPoints.KingdomOfRose},
	{minLvl = 950, maxLvl = 974, keywords = {"zombie"}, questText = "Zombie", questName = "ZombieQuest", questNum = 1, fallback = IslandFallbackPoints.Graveyard},
	{minLvl = 975, maxLvl = 999, keywords = {"vampire"}, questText = "Vampire", questName = "ZombieQuest", questNum = 2, fallback = IslandFallbackPoints.Graveyard},
	{minLvl = 1000, maxLvl = 1049, keywords = {"snow trooper"}, questText = "Snow Trooper", questName = "SnowMountainQuest", questNum = 1, fallback = IslandFallbackPoints.SnowMountain},
	{minLvl = 1050, maxLvl = 1099, keywords = {"winter warrior"}, questText = "Winter Warrior", questName = "SnowMountainQuest", questNum = 2, fallback = IslandFallbackPoints.SnowMountain},
	{minLvl = 1100, maxLvl = 1124, keywords = {"lab subordinate"}, questText = "Lab Subordinate", questName = "IceSideQuest", questNum = 1, fallback = IslandFallbackPoints.HotAndCold},
	{minLvl = 1125, maxLvl = 1174, keywords = {"horn warrior"}, questText = "Horn Warrior", questName = "IceSideQuest", questNum = 2, fallback = IslandFallbackPoints.HotAndCold},
	{minLvl = 1175, maxLvl = 1199, keywords = {"magma ninja"}, questText = "Magma Ninja", questName = "FireSideQuest", questNum = 1, fallback = IslandFallbackPoints.HotAndCold},
	{minLvl = 1200, maxLvl = 1249, keywords = {"lava pirate"}, questText = "Lava Pirate", questName = "FireSideQuest", questNum = 2, fallback = IslandFallbackPoints.HotAndCold},
	{minLvl = 1250, maxLvl = 1274, keywords = {"ship deckhand"}, questText = "Ship Deckhand", questName = "ShipQuest1", questNum = 1, fallback = IslandFallbackPoints.CursedShip},
	{minLvl = 1275, maxLvl = 1299, keywords = {"ship engineer"}, questText = "Ship Engineer", questName = "ShipQuest1", questNum = 2, fallback = IslandFallbackPoints.CursedShip},
	{minLvl = 1300, maxLvl = 1324, keywords = {"ship steward"}, questText = "Ship Steward", questName = "ShipQuest2", questNum = 1, fallback = IslandFallbackPoints.CursedShip},
	{minLvl = 1325, maxLvl = 1349, keywords = {"ship officer"}, questText = "Ship Officer", questName = "ShipQuest2", questNum = 2, fallback = IslandFallbackPoints.CursedShip},
	{minLvl = 1350, maxLvl = 1374, keywords = {"arctic warrior"}, questText = "Arctic Warrior", questName = "FrostQuest", questNum = 1, fallback = IslandFallbackPoints.IceCastle},
	{minLvl = 1375, maxLvl = 1424, keywords = {"snow lurker"}, questText = "Snow Lurker", questName = "FrostQuest", questNum = 2, fallback = IslandFallbackPoints.IceCastle},
	{minLvl = 1425, maxLvl = 1449, keywords = {"sea soldier"}, questText = "Sea Soldier", questName = "ForgottenQuest", questNum = 1, fallback = IslandFallbackPoints.ForgottenIsland},
	{minLvl = 1450, maxLvl = 1474, keywords = {"water fighter"}, questText = "Water Fighter", questName = "ForgottenQuest", questNum = 2, fallback = IslandFallbackPoints.ForgottenIsland},
	{minLvl = 1475, maxLvl = 1499, keywords = {"pirate millionaire"}, questText = "Pirate Millionaire", questName = "PiratePortQuest", questNum = 1, fallback = IslandFallbackPoints.PortTown},
	{minLvl = 1500, maxLvl = 1524, keywords = {"pistol billionaire"}, questText = "Pistol Billionaire", questName = "PiratePortQuest", questNum = 2, fallback = IslandFallbackPoints.PortTown},
	{minLvl = 1525, maxLvl = 1574, keywords = {"dragon crew warrior"}, questText = "Dragon Crew Warrior", questName = "AmazonQuest", questNum = 1, fallback = IslandFallbackPoints.HydraIsland},
	{minLvl = 1575, maxLvl = 1599, keywords = {"dragon crew archer"}, questText = "Dragon Crew Archer", questName = "AmazonQuest", questNum = 2, fallback = IslandFallbackPoints.HydraIsland},
	{minLvl = 1600, maxLvl = 1624, keywords = {"female island"}, questText = "Female Island", questName = "AmazonQuest2", questNum = 1, fallback = IslandFallbackPoints.HydraIsland},
	{minLvl = 1625, maxLvl = 1649, keywords = {"giant sky island"}, questText = "Giant Sky Island", questName = "AmazonQuest2", questNum = 2, fallback = IslandFallbackPoints.HydraIsland},
	{minLvl = 1650, maxLvl = 1699, keywords = {"head baker"}, questText = "Head Baker", questName = "CakeQuest1", questNum = 1, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 1700, maxLvl = 1724, keywords = {"baking staff"}, questText = "Baking Staff", questName = "CakeQuest1", questNum = 2, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 1725, maxLvl = 1749, keywords = {"cake guard"}, questText = "Cake Guard", questName = "CakeQuest2", questNum = 1, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 1750, maxLvl = 1774, keywords = {"cookie crafter"}, questText = "Cookie Crafter", questName = "CakeQuest2", questNum = 2, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 1775, maxLvl = 1799, keywords = {"cake queen"}, questText = "Cake Queen", questName = "CakeQuest2", questNum = 2, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 1800, maxLvl = 1824, keywords = {"peanut president"}, questText = "Peanut President", questName = "ChocQuest1", questNum = 1, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 1825, maxLvl = 1849, keywords = {"ice cream chef"}, questText = "Ice Cream Chef", questName = "ChocQuest1", questNum = 2, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 1850, maxLvl = 1899, keywords = {"ice cream commander"}, questText = "Ice Cream Commander", questName = "ChocQuest2", questNum = 1, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 1900, maxLvl = 1924, keywords = {"cookie disciple"}, questText = "Cookie Disciple", questName = "ChocQuest2", questNum = 2, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 1925, maxLvl = 1974, keywords = {"mint mark"}, questText = "Mint Mark", questName = "CandyQuest1", questNum = 1, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 1975, maxLvl = 1999, keywords = {"cocoa warrior"}, questText = "Cocoa Warrior", questName = "CandyQuest1", questNum = 2, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 2000, maxLvl = 2024, keywords = {"chocolate bar battler"}, questText = "Chocolate Bar Battler", questName = "CandyQuest2", questNum = 1, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 2025, maxLvl = 2049, keywords = {"sweet thief"}, questText = "Sweet Thief", questName = "CandyQuest2", questNum = 2, fallback = IslandFallbackPoints.SeaOfTreats},
	{minLvl = 2050, maxLvl = 2074, keywords = {"candy rebel"}, questText = "Candy Rebel", questName = "TikiQuest1", questNum = 1, fallback = IslandFallbackPoints.TikiOutpost},
	{minLvl = 2075, maxLvl = 2099, keywords = {"candy pirate"}, questText = "Candy Pirate", questName = "TikiQuest1", questNum = 2, fallback = IslandFallbackPoints.TikiOutpost},
	{minLvl = 2100, maxLvl = 2124, keywords = {"snow demon"}, questText = "Snow Demon", questName = "TikiQuest1", questNum = 2, fallback = IslandFallbackPoints.TikiOutpost},
	{minLvl = 2125, maxLvl = 2149, keywords = {"isle outcast"}, questText = "Isle Outcast", questName = "TikiQuest2", questNum = 1, fallback = IslandFallbackPoints.TikiOutpost},
	{minLvl = 2150, maxLvl = 2199, keywords = {"island boy"}, questText = "Island Boy", questName = "TikiQuest2", questNum = 2, fallback = IslandFallbackPoints.TikiOutpost},
	{minLvl = 2200, maxLvl = 2224, keywords = {"sun-kissed warrior"}, questText = "Sun-kissed Warrior", questName = "TikiQuest2", questNum = 2, fallback = IslandFallbackPoints.TikiOutpost},
	{minLvl = 2225, maxLvl = 2249, keywords = {"isle champion"}, questText = "Isle Champion", questName = "TikiQuest3", questNum = 1, fallback = IslandFallbackPoints.TikiOutpost},
	{minLvl = 2250, maxLvl = 2274, keywords = {"serpent hunter"}, questText = "Serpent Hunter", questName = "TikiQuest3", questNum = 2, fallback = IslandFallbackPoints.TikiOutpost},
	{minLvl = 2275, maxLvl = 2299, keywords = {"skull slayer"}, questText = "Skull Slayer", questName = "HauntedQuest1", questNum = 1, fallback = IslandFallbackPoints.HauntedCastle},
	{minLvl = 2300, maxLvl = 2349, keywords = {"reborn skeleton"}, questText = "Reborn Skeleton", questName = "HauntedQuest1", questNum = 2, fallback = IslandFallbackPoints.HauntedCastle},
	{minLvl = 2350, maxLvl = 2399, keywords = {"living zombie"}, questText = "Living Zombie", questName = "HauntedQuest2", questNum = 1, fallback = IslandFallbackPoints.HauntedCastle},
	{minLvl = 2400, maxLvl = 2449, keywords = {"demonic soul"}, questText = "Demonic Soul", questName = "HauntedQuest2", questNum = 2, fallback = IslandFallbackPoints.HauntedCastle},
	{minLvl = 2450, maxLvl = 2474, keywords = {"posessed mummy", "possessed mummy"}, questText = "Possessed Mummy", questName = "HauntedQuest2", questNum = 2, fallback = IslandFallbackPoints.HauntedCastle},
	{minLvl = 2475, maxLvl = 2524, keywords = {"peanut scout"}, questText = "Peanut Scout", questName = "NutsQuest", questNum = 1, fallback = IslandFallbackPoints.FloatingTurtle},
	{minLvl = 2525, maxLvl = 2549, keywords = {"dragon crew"}, questText = "Dragon Crew", questName = "NutsQuest", questNum = 2, fallback = IslandFallbackPoints.FloatingTurtle},
	{minLvl = 2550, maxLvl = 2574, keywords = {"hydra enforcer"}, questText = "Hydra Enforcer", questName = "HydraQuest", questNum = 1, fallback = IslandFallbackPoints.HydraIsland},
	{minLvl = 2575, maxLvl = 2599, keywords = {"venous knight"}, questText = "Venous Knight", questName = "HydraQuest", questNum = 2, fallback = IslandFallbackPoints.HydraIsland},
	{minLvl = 2600, maxLvl = 2624, keywords = {"marine commodore"}, questText = "Marine Commodore", questName = "MarineTreeQuest", questNum = 1, fallback = IslandFallbackPoints.FloatingTurtle},
	{minLvl = 2625, maxLvl = 2649, keywords = {"marine rear admiral"}, questText = "Marine Rear Admiral", questName = "MarineTreeQuest", questNum = 2, fallback = IslandFallbackPoints.FloatingTurtle},
	{minLvl = 2650, maxLvl = 2674, keywords = {"fishman raider"}, questText = "Fishman Raider", questName = "DeepForestQuest", questNum = 1, fallback = IslandFallbackPoints.FloatingTurtle},
	{minLvl = 2675, maxLvl = 2699, keywords = {"fishman captain"}, questText = "Fishman Captain", questName = "DeepForestQuest", questNum = 2, fallback = IslandFallbackPoints.FloatingTurtle},
	{minLvl = 2700, maxLvl = 2724, keywords = {"high disciple"}, questText = "High Disciple", questName = "DeepForestQuest", questNum = 2, fallback = IslandFallbackPoints.HighDisciple},
	{minLvl = 2725, maxLvl = 9999, keywords = {"high disciple"}, questText = "High Disciple", questName = "DeepForestQuest", questNum = 2, fallback = IslandFallbackPoints.HighDisciple}
}

local FruitNameList = {
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

local FruitLookupMap = {}
for _, fName in ipairs(FruitNameList) do
	local lower = string.lower(fName)
	FruitLookupMap[lower] = fName
	local base = string.gsub(lower, "%s*fruit%s*$", "")
	if base ~= "" then
		FruitLookupMap[base] = fName
		FruitLookupMap[base .. "-" .. base] = fName
	end
end

local function getSelectedWeaponMode()
	return WeaponCategories[State.WeaponIndex] or "Melee"
end

local function getSelectedRaidChip()
	return RaidChipCatalog[State.RaidChipIndex] or "Flame"
end

local function isAnyFarmActive()
	return State.AutoFarm
		or State.AutoRaid
		or State.FarmVampire
		or State.FarmDemonicSoul
		or State.FarmDragonScale
		or State.FarmBones
end

local function getSafeGuiRoot()
	local ok, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok and cg then
		local probeOk = pcall(function()
			local testFolder = Instance.new("Folder")
			testFolder.Name = "NexoaroGuiProbe"
			testFolder.Parent = cg
			testFolder:Destroy()
		end)
		if probeOk then
			return cg
		end
	end
	return LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
end

local function resolveCommFRemote()
	local remFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if remFolder then
		local comm = remFolder:FindFirstChild("CommF_")
		if comm then
			return comm
		end
	end
	for _, item in ipairs(ReplicatedStorage:GetDescendants()) do
		if (item:IsA("RemoteFunction") or item:IsA("RemoteEvent")) and string.lower(item.Name) == "commf_" then
			return item
		end
	end
	return nil
end

local function resolveCombatRemote()
	if RuntimeRefs.CachedCombat and RuntimeRefs.CachedCombat.Parent then
		return RuntimeRefs.CachedCombat
	end
	local remFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if remFolder then
		for _, candidateName in ipairs({"Combat", "Hit", "Attack", "Melee"}) do
			local candidate = remFolder:FindFirstChild(candidateName)
			if candidate and candidate:IsA("RemoteEvent") then
				RuntimeRefs.CachedCombat = candidate
				return candidate
			end
		end
	end
	for _, desc in ipairs(ReplicatedStorage:GetDescendants()) do
		if desc:IsA("RemoteEvent") then
			local lowerName = string.lower(desc.Name)
			if lowerName == "combat" or lowerName == "hit" then
				RuntimeRefs.CachedCombat = desc
				return desc
			end
		end
	end
	return nil
end

local function executeRemoteCall(remoteObj, ...)
	if not remoteObj then
		return false
	end
	local callArgs = {...}
	local success = pcall(function()
		if remoteObj:IsA("RemoteFunction") and type(remoteObj.InvokeServer) == "function" then
			remoteObj:InvokeServer(table.unpack(callArgs))
		elseif remoteObj:IsA("RemoteEvent") and type(remoteObj.FireServer) == "function" then
			remoteObj:FireServer(table.unpack(callArgs))
		end
	end)
	return success
end

local function sendCommFCommand(...)
	local comm = resolveCommFRemote()
	if not comm then
		return false
	end
	return executeRemoteCall(comm, ...)
end

local function removeFlightMovers(rootPart)
	pcall(function()
		if not rootPart then
			return
		end
		for _, child in ipairs(rootPart:GetChildren()) do
			if child.Name == "NexoaroVelocity" or child.Name == "NexoaroGyro" or child.Name == "NexoaroPosition" then
				pcall(function() child:Destroy() end)
			end
		end
	end)
end

local function stepFlightTo(rootPart, destinationCF, moveSpeed)
	if not rootPart or not rootPart.Parent then
		return
	end
	local offset = destinationCF.Position - rootPart.Position
	local distance = offset.Magnitude
	local speed = math.max(moveSpeed or State.FlySpeed, 180)
	local stepSize = speed * 0.05

	if distance <= math.max(2.5, stepSize) then
		removeFlightMovers(rootPart)
		rootPart.CFrame = CFrame.lookAt(destinationCF.Position, destinationCF.Position + destinationCF.LookVector)
		rootPart.AssemblyLinearVelocity = Vector3.zero
		rootPart.AssemblyAngularVelocity = Vector3.zero
		return
	end

	local direction = offset.Unit
	local nextPosition = rootPart.Position + (direction * stepSize)

	local bodyVel = rootPart:FindFirstChild("NexoaroVelocity")
	if not bodyVel or not bodyVel:IsA("BodyVelocity") then
		if bodyVel then
			pcall(function() bodyVel:Destroy() end)
		end
		bodyVel = Instance.new("BodyVelocity")
		bodyVel.Name = "NexoaroVelocity"
		bodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
		bodyVel.P = 5e4
		bodyVel.Parent = rootPart
	end
	bodyVel.Velocity = direction * speed

	rootPart.CFrame = CFrame.lookAt(nextPosition, destinationCF.Position)
	rootPart.AssemblyLinearVelocity = Vector3.zero
	rootPart.AssemblyAngularVelocity = Vector3.zero
end

local function applyPlayerSpeed(character, humanoid, rootPart)
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	if State.WalkSpeedEnabled then
		if humanoid.WalkSpeed ~= State.WalkSpeedValue then
			humanoid.WalkSpeed = State.WalkSpeedValue
		end
		if rootPart and not humanoid.SeatPart and not isAnyFarmActive() and not State.AutoChestEnabled and not State.PvPEnabled then
			local moveVec = humanoid.MoveDirection
			if moveVec.Magnitude > 0.05 then
				local flatVec = Vector3.new(moveVec.X, 0, moveVec.Z)
				if flatVec.Magnitude > 0.01 then
					local boosted = flatVec.Unit * State.WalkSpeedValue
					rootPart.AssemblyLinearVelocity = Vector3.new(boosted.X, rootPart.AssemblyLinearVelocity.Y, boosted.Z)
				end
			end
		end
	elseif humanoid.WalkSpeed > 25 then
		humanoid.WalkSpeed = 16
	end
end

local function fetchCurrentLevel()
	local levelResult = 1
	pcall(function()
		local dataFolder = LocalPlayer:FindFirstChild("Data")
		local lvlObj = dataFolder and dataFolder:FindFirstChild("Level")
		if lvlObj and type(lvlObj.Value) == "number" then
			levelResult = lvlObj.Value
			return
		end
		local statsFolder = LocalPlayer:FindFirstChild("leaderstats")
		local altLvl = statsFolder and (statsFolder:FindFirstChild("Level") or statsFolder:FindFirstChild("Lvl"))
		if altLvl and type(altLvl.Value) == "number" then
			levelResult = altLvl.Value
		end
	end)
	return levelResult
end

local function selectQuestBracketForLevel(currentLvl)
	local numericLvl = tonumber(currentLvl) or 1
	local fallbackBracket = nil
	for _, entry in ipairs(LevelQuestProgression) do
		if type(entry) == "table" and type(entry.minLvl) == "number" and type(entry.maxLvl) == "number" then
			if numericLvl >= entry.minLvl and numericLvl <= entry.maxLvl then
				return entry
			end
			if entry.minLvl <= numericLvl then
				fallbackBracket = entry
			end
		end
	end
	return fallbackBracket or LevelQuestProgression[1]
end

local function matchesBracketKeywords(enemyModel, bracket)
	if not enemyModel or not bracket then
		return false
	end
	local lowerName = string.lower(tostring(enemyModel.Name))
	for _, word in ipairs(bracket.keywords or {}) do
		if string.find(lowerName, string.lower(word), 1, true) then
			return true
		end
	end
	return false
end

local function validateAliveEnemy(enemyModel, customFilter, bracket)
	if not enemyModel or not enemyModel.Parent or not enemyModel:IsA("Model") then
		return nil, nil
	end
	if Players:GetPlayerFromCharacter(enemyModel) then
		return nil, nil
	end
	if customFilter and not customFilter(enemyModel) then
		return nil, nil
	end
	if bracket and not matchesBracketKeywords(enemyModel, bracket) then
		return nil, nil
	end
	local eRoot = enemyModel:FindFirstChild("HumanoidRootPart") or enemyModel.PrimaryPart
	local eHum = enemyModel:FindFirstChildOfClass("Humanoid")
	if eRoot and eRoot.Parent and eHum and eHum.Parent and eHum.Health > 0 then
		return eRoot, eHum
	end
	return nil, nil
end

local function acquireFarmTarget(originPos, customFilter, bracket)
	if RuntimeRefs.ActiveEnemy then
		local r, h = validateAliveEnemy(RuntimeRefs.ActiveEnemy, customFilter, bracket)
		if r and h then
			return RuntimeRefs.ActiveEnemy, r, h
		end
		RuntimeRefs.ActiveEnemy = nil
	end

	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		return nil, nil, nil
	end

	local bestModel, bestRoot, bestHum, bestDistance = nil, nil, nil, math.huge
	for _, candidate in ipairs(enemiesFolder:GetChildren()) do
		local r, h = validateAliveEnemy(candidate, customFilter, bracket)
		if r and h then
			local dist = (originPos - r.Position).Magnitude
			if dist < bestDistance then
				bestDistance = dist
				bestModel = candidate
				bestRoot = r
				bestHum = h
			end
		end
	end

	RuntimeRefs.ActiveEnemy = bestModel
	return bestModel, bestRoot, bestHum
end

local function isRaidEnemyCandidate(enemyModel)
	if not enemyModel or not enemyModel.Name then
		return false
	end
	if Players:GetPlayerFromCharacter(enemyModel) then
		return false
	end
	local lowerName = string.lower(tostring(enemyModel.Name))
	if string.find(lowerName, "raid", 1, true)
		or string.find(lowerName, "boss", 1, true)
		or string.find(lowerName, "subject", 1, true)
		or string.find(lowerName, "core", 1, true) then
		return true
	end
	local locations = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
	local root = enemyModel:FindFirstChild("HumanoidRootPart") or enemyModel.PrimaryPart
	if locations and root then
		for _, loc in ipairs(locations:GetChildren()) do
			local locLower = string.lower(loc.Name)
			if string.find(locLower, "raid", 1, true) or string.find(locLower, "island", 1, true) then
				local locPart = loc:IsA("BasePart") and loc or loc:FindFirstChildWhichIsA("BasePart", true)
				if locPart and (locPart.Position - root.Position).Magnitude <= 550 then
					return true
				end
			end
		end
	end
	return false
end

local function computeNextRaidIsland(currentPosition)
	local locations = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("Locations")
	local foundPoints = {}
	if locations then
		for _, loc in ipairs(locations:GetChildren()) do
			local locLower = string.lower(loc.Name)
			if string.find(locLower, "raid", 1, true)
				or string.find(locLower, "island", 1, true)
				or string.find(locLower, "flame", 1, true)
				or string.find(locLower, "ice", 1, true)
				or string.find(locLower, "dark", 1, true)
				or string.find(locLower, "sand", 1, true)
				or string.find(locLower, "law", 1, true)
				or string.find(locLower, "buddha", 1, true)
				or string.find(locLower, "spider", 1, true)
				or string.find(locLower, "magma", 1, true)
				or string.find(locLower, "rumble", 1, true)
				or string.find(locLower, "dough", 1, true)
				or string.find(locLower, "phoenix", 1, true) then
				local part = loc:IsA("BasePart") and loc or loc:FindFirstChildWhichIsA("BasePart", true)
				if part then
					table.insert(foundPoints, part.Position + Vector3.new(0, 70, 0))
				end
			end
		end
	end
	if #foundPoints > 0 then
		State.RaidIslandIndex = (State.RaidIslandIndex % #foundPoints) + 1
		return foundPoints[State.RaidIslandIndex]
	end
	local basePos = currentPosition or Vector3.new(-50000, 100, 0)
	State.RaidIslandIndex = (State.RaidIslandIndex % #RaidIslandOffsets) + 1
	return basePos + RaidIslandOffsets[State.RaidIslandIndex]
end

local function processRaidStartAndAwaken()
	local now = tick()
	if (now - Timers.LastRaidStart) >= 5 then
		Timers.LastRaidStart = now
		local chipName = getSelectedRaidChip()
		sendCommFCommand("RaidsNpc", "Select", chipName)
		sendCommFCommand("RaidsNpc", "Summon")
		sendCommFCommand("Raid", "Start")
	end
	if State.AutoAwaken and (now - Timers.LastAwaken) >= 6 then
		Timers.LastAwaken = now
		sendCommFCommand("Awakener", "Awaken")
		sendCommFCommand("RaidsNpc", "Awaken")
	end
end

local function inspectActiveChest(candidate)
	if not candidate or not candidate.Parent then
		return nil, nil
	end
	if RuntimeRefs.VisitedChests[candidate] and (tick() - RuntimeRefs.VisitedChests[candidate]) < 12 then
		return nil, nil
	end
	local lowerName = string.lower(tostring(candidate.Name))
	if not string.find(lowerName, "chest", 1, true) then
		return nil, nil
	end
	local anchor = nil
	if candidate:IsA("BasePart") then
		anchor = candidate
	elseif candidate:IsA("Model") then
		anchor = candidate.PrimaryPart or candidate:FindFirstChild("HumanoidRootPart") or candidate:FindFirstChildWhichIsA("BasePart", true)
	end
	if not anchor or not anchor.Parent or anchor.CanTouch == false or anchor.Transparency >= 0.98 then
		return nil, nil
	end
	local touch = anchor:FindFirstChildWhichIsA("TouchTransmitter", true)
		or (candidate:IsA("Model") and candidate:FindFirstChildWhichIsA("TouchTransmitter", true))
	if not touch then
		return nil, nil
	end
	return anchor, tostring(candidate.Name)
end

local function locateClosestChest(originPos)
	local bestAnchor, bestName, bestDist, bestOwner = nil, nil, math.huge, nil
	for _, obj in ipairs(Workspace:GetDescendants()) do
		local anchor, nameStr = inspectActiveChest(obj)
		if anchor then
			local d = (originPos - anchor.Position).Magnitude
			if d < bestDist then
				bestDist = d
				bestAnchor = anchor
				bestName = nameStr
				bestOwner = obj
			end
		end
	end
	return bestAnchor, bestName, bestDist, bestOwner
end

local function filterVampireMob(model)
	return model and model.Name and string.find(string.lower(tostring(model.Name)), "vampire", 1, true) ~= nil
end

local function filterDemonicSoulMob(model)
	return model and model.Name and string.find(string.lower(tostring(model.Name)), "demonic soul", 1, true) ~= nil
end

local function filterDragonScaleMob(model)
	if not model or not model.Name then
		return false
	end
	local n = string.lower(tostring(model.Name))
	return string.find(n, "dragon crew warrior", 1, true) ~= nil or string.find(n, "dragon crew archer", 1, true) ~= nil
end

local function filterBoneMob(model)
	if not model or not model.Name then
		return false
	end
	local n = string.lower(tostring(model.Name))
	return string.find(n, "reborn skeleton", 1, true) ~= nil
		or string.find(n, "living zombie", 1, true) ~= nil
		or string.find(n, "demonic soul", 1, true) ~= nil
		or string.find(n, "posessed mummy", 1, true) ~= nil
		or string.find(n, "possessed mummy", 1, true) ~= nil
end

local function resolveSpawnPoint(keywords, fallbackVec)
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
	return fallbackVec or IslandFallbackPoints.HighDisciple
end

local function matchFruitName(rawStr)
	if not rawStr then
		return nil
	end
	local lower = string.lower(tostring(rawStr))
	lower = string.gsub(lower, "^%s*(.-)%s*$", "%1")
	lower = string.gsub(lower, "%s+fruit%s+fruit%s*$", " fruit")
	if FruitLookupMap[lower] then
		return FruitLookupMap[lower]
	end
	local stripped = string.gsub(lower, "%s*fruit%s*$", "")
	if FruitLookupMap[stripped] then
		return FruitLookupMap[stripped]
	end
	local dashPrefix = string.match(lower, "^([a-z%-]+)%-[a-z%-]+$")
	if dashPrefix and FruitLookupMap[dashPrefix] then
		return FruitLookupMap[dashPrefix]
	end
	return nil
end

local function buildFruitStoreKey(itemObj, resolvedName)
	if itemObj and itemObj.GetAttribute then
		local ok, attrVal = pcall(function() return itemObj:GetAttribute("FruitName") end)
		if ok and attrVal then
			return tostring(attrVal)
		end
	end
	local rootName = string.gsub(resolvedName, "%s*Fruit%s*$", "")
	return rootName .. "-" .. rootName
end

local function isWorldFruitPickup(obj)
	if not obj or not obj.Name or not obj.Parent then
		return false
	end
	if Players:GetPlayerFromCharacter(obj) or obj:FindFirstAncestorWhichIsA("Player") then
		return false
	end
	if not matchFruitName(obj.Name) then
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

local function getFruitPart(obj)
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

local function isDarkFistName(rawName)
	if not rawName then
		return false
	end
	local lower = string.lower(tostring(rawName))
	return string.find(lower, "fist of darkness", 1, true) ~= nil
		or string.find(lower, "dark fist", 1, true) ~= nil
		or string.find(lower, "fistofdarkness", 1, true) ~= nil
end

local function scanForDarkFist()
	local searchScopes = {
		{scope = Workspace, label = "Workspace"},
		{scope = LocalPlayer and LocalPlayer:FindFirstChild("Backpack"), label = "Backpack"},
		{scope = LocalPlayer and LocalPlayer.Character, label = "Character"}
	}
	for _, entry in ipairs(searchScopes) do
		local container = entry.scope
		if container then
			for _, desc in ipairs(container:GetDescendants()) do
				if isDarkFistName(desc.Name) then
					local anchor = nil
					if desc:IsA("BasePart") then
						anchor = desc
					elseif desc:IsA("Model") or desc:IsA("Tool") then
						anchor = desc:FindFirstChild("Handle") or desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart", true)
					end
					local distLabel = ""
					local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if anchor and myRoot then
						distLabel = " [" .. tostring(math.floor((myRoot.Position - anchor.Position).Magnitude)) .. "m]"
					end
					return true, tostring(desc.Name) .. " (" .. entry.label .. ")" .. distLabel
				end
			end
		end
	end
	return false, nil
end

local function triggerBusoHaki()
	if not State.AutoHaki then
		return
	end
	local now = tick()
	if (now - Timers.LastHaki) < 8 then
		return
	end
	Timers.LastHaki = now
	pcall(function()
		local char = LocalPlayer.Character
		if char and not char:FindFirstChild("HasBuso") then
			sendCommFCommand("Buso")
		end
	end)
end

local function syncWaterPlatform(rootPos)
	pcall(function()
		if not State.WalkOnWater or not rootPos then
			if RuntimeRefs.WaterPart then
				pcall(function() RuntimeRefs.WaterPart:Destroy() end)
				RuntimeRefs.WaterPart = nil
			end
			return
		end
		if not RuntimeRefs.WaterPart or not RuntimeRefs.WaterPart.Parent then
			local part = Instance.new("Part")
			part.Name = "NexoaroWaterWalkPart"
			part.Size = Vector3.new(30, 1, 30)
			part.Anchored = true
			part.CanCollide = true
			part.Transparency = 1
			part.Parent = Workspace
			RuntimeRefs.WaterPart = part
		end
		RuntimeRefs.WaterPart.Position = Vector3.new(rootPos.X, -0.5, rootPos.Z)
	end)
end

local function saveEnvironmentFog()
	if RuntimeRefs.SavedFog then
		return
	end
	pcall(function()
		local snap = {
			FogStart = Lighting.FogStart,
			FogEnd = Lighting.FogEnd,
			FogColor = Lighting.FogColor,
			Atmospheres = {},
			Effects = {}
		}
		for _, item in ipairs(Lighting:GetDescendants()) do
			if item:IsA("Atmosphere") then
				snap.Atmospheres[item] = {Density = item.Density, Haze = item.Haze, Glare = item.Glare}
			elseif item:IsA("ColorCorrectionEffect") or item:IsA("BlurEffect") then
				snap.Effects[item] = item.Enabled
			end
		end
		RuntimeRefs.SavedFog = snap
	end)
end

local function restoreEnvironmentFog()
	if not RuntimeRefs.SavedFog then
		return
	end
	pcall(function()
		Lighting.FogStart = RuntimeRefs.SavedFog.FogStart
		Lighting.FogEnd = RuntimeRefs.SavedFog.FogEnd
		Lighting.FogColor = RuntimeRefs.SavedFog.FogColor
		for item, vals in pairs(RuntimeRefs.SavedFog.Atmospheres) do
			if item and item.Parent then
				item.Density = vals.Density
				item.Haze = vals.Haze
				item.Glare = vals.Glare
			end
		end
		for item, prevEnabled in pairs(RuntimeRefs.SavedFog.Effects) do
			if item and item.Parent then
				item.Enabled = prevEnabled
			end
		end
	end)
	RuntimeRefs.SavedFog = nil
end

local function applyClearFog()
	pcall(function()
		saveEnvironmentFog()
		Lighting.FogStart = 100000
		Lighting.FogEnd = 1000000
		Lighting.FogColor = Color3.fromRGB(190, 225, 255)
		for _, item in ipairs(Lighting:GetDescendants()) do
			if item:IsA("Atmosphere") then
				item.Density = 0
				item.Haze = 0
				item.Glare = 0
			elseif item:IsA("ColorCorrectionEffect") or item:IsA("BlurEffect") then
				local lower = string.lower(item.Name)
				if string.find(lower, "fog", 1, true)
					or string.find(lower, "danger", 1, true)
					or string.find(lower, "sea", 1, true)
					or string.find(lower, "dark", 1, true) then
					item.Enabled = false
				end
			end
		end
	end)
end

if VirtualUser and LocalPlayer and LocalPlayer.Idled then
	LocalPlayer.Idled:Connect(function()
		if State.AntiAFK then
			pcall(function()
				VirtualUser:CaptureController()
				VirtualUser:ClickButton2(Vector2.new(500, 500))
			end)
		end
	end)
end

local guiParent = getSafeGuiRoot()
for _, existing in ipairs(guiParent:GetChildren()) do
	if existing.Name == "NexoaroFullHub" then
		pcall(function() existing:Destroy() end)
	end
end

local HubGui = Instance.new("ScreenGui")
HubGui.Name = "NexoaroFullHub"
HubGui.ResetOnSpawn = false
HubGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
HubGui.DisplayOrder = 999
HubGui.Parent = guiParent

local isCompactScreen = false
pcall(function()
	local vp = Camera and Camera.ViewportSize or Vector2.new(1280, 720)
	isCompactScreen = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) or vp.X < 750
end)

local MainWindow = Instance.new("Frame")
MainWindow.Size = isCompactScreen and UDim2.new(0, 326, 0, 372) or UDim2.new(0, 445, 0, 446)
MainWindow.Position = isCompactScreen and UDim2.new(0.03, 0, 0.11, 0) or UDim2.new(0.02, 0, 0.22, 0)
MainWindow.BackgroundColor3 = ColorScheme.Background
MainWindow.BorderSizePixel = 0
MainWindow.ClipsDescendants = true
MainWindow.Parent = HubGui
Instance.new("UICorner", MainWindow).CornerRadius = UDim.new(0, 14)

local WindowStroke = Instance.new("UIStroke", MainWindow)
WindowStroke.Color = ColorScheme.Primary
WindowStroke.Thickness = 1.6
WindowStroke.Transparency = 0.18

local HeaderBar = Instance.new("Frame")
HeaderBar.Size = UDim2.new(1, 0, 0, isCompactScreen and 38 or 44)
HeaderBar.BackgroundColor3 = ColorScheme.Surface
HeaderBar.BorderSizePixel = 0
HeaderBar.Parent = MainWindow

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -180, 1, 0)
HeaderTitle.Position = UDim2.new(0, 14, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "NEXOARO  |  BLOX FRUITS"
HeaderTitle.TextColor3 = ColorScheme.Text
HeaderTitle.Font = Enum.Font.GothamBlack
HeaderTitle.TextSize = isCompactScreen and 12 or 14
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = HeaderBar

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -32, 0.5, -12)
CloseButton.BackgroundColor3 = ColorScheme.Danger
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 11
CloseButton.Parent = HeaderBar
Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 7)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 24, 0, 24)
MinimizeButton.Position = UDim2.new(1, -60, 0.5, -12)
MinimizeButton.BackgroundColor3 = ColorScheme.SurfaceAlt
MinimizeButton.Text = "-"
MinimizeButton.TextColor3 = ColorScheme.Text
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 13
MinimizeButton.Parent = HeaderBar
Instance.new("UICorner", MinimizeButton).CornerRadius = UDim.new(0, 7)

local ReopenPill = Instance.new("TextButton")
ReopenPill.Size = UDim2.new(0, 124, 0, 32)
ReopenPill.Position = UDim2.new(0.02, 0, 0.1, 0)
ReopenPill.BackgroundColor3 = ColorScheme.Surface
ReopenPill.Text = "◆ NEXOARO"
ReopenPill.TextColor3 = ColorScheme.Accent
ReopenPill.Font = Enum.Font.GothamBold
ReopenPill.TextSize = 11
ReopenPill.Visible = false
ReopenPill.Parent = HubGui
Instance.new("UICorner", ReopenPill).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", ReopenPill).Color = ColorScheme.Primary

MinimizeButton.MouseButton1Click:Connect(function()
	MainWindow.Visible = false
	ReopenPill.Visible = true
end)

ReopenPill.MouseButton1Click:Connect(function()
	MainWindow.Visible = true
	ReopenPill.Visible = false
end)

CloseButton.MouseButton1Click:Connect(function()
	State.Running = false
	State.AutoFarm = false
	State.AutoRaid = false
	RuntimeRefs.ActiveEnemy = nil
	RuntimeRefs.LockedSailDir = nil
	RuntimeRefs.LockedBracket = nil
	State.WalkSpeedEnabled = false
	State.WalkOnWater = false
	syncWaterPlatform(nil)
	if State.RemoveFogEnabled then
		State.RemoveFogEnabled = false
		restoreEnvironmentFog()
	end
	pcall(function()
		local char = LocalPlayer.Character
		removeFlightMovers(char and char:FindFirstChild("HumanoidRootPart"))
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16
		end
	end)
	for _, esp in pairs(RuntimeRefs.PlayerESP) do
		for _, drawingObj in pairs(esp) do
			if drawingObj and type(drawingObj.Remove) == "function" then
				pcall(function() drawingObj:Remove() end)
			end
		end
	end
	pcall(function() HubGui:Destroy() end)
end)

local headerHeight = isCompactScreen and 38 or 44

local StatusBanner = Instance.new("Frame")
StatusBanner.Size = UDim2.new(1, -20, 0, 26)
StatusBanner.Position = UDim2.new(0, 10, 0, headerHeight + 8)
StatusBanner.BackgroundColor3 = ColorScheme.Surface
StatusBanner.BorderSizePixel = 0
StatusBanner.Parent = MainWindow
Instance.new("UICorner", StatusBanner).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", StatusBanner).Color = Color3.fromRGB(52, 44, 78)

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -16, 1, 0)
StatusText.Position = UDim2.new(0, 8, 0, 0)
StatusText.BackgroundTransparency = 1
StatusText.Text = "●  Status: Ready | Melee Fast Attack 0.1s"
StatusText.TextColor3 = ColorScheme.Muted
StatusText.Font = Enum.Font.GothamSemibold
StatusText.TextSize = 10
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.Parent = StatusBanner

local FistBanner = Instance.new("TextLabel")
FistBanner.Size = UDim2.new(1, -20, 0, 24)
FistBanner.Position = UDim2.new(0, 10, 0, headerHeight + 36)
FistBanner.BackgroundColor3 = Color3.fromRGB(127, 29, 29)
FistBanner.TextColor3 = Color3.new(1, 1, 1)
FistBanner.Font = Enum.Font.GothamBold
FistBanner.TextSize = 10
FistBanner.Text = "★  DARK FIST / FIST OF DARKNESS DETECTED!"
FistBanner.Visible = false
FistBanner.Parent = MainWindow
Instance.new("UICorner", FistBanner).CornerRadius = UDim.new(0, 7)

local NavStrip = Instance.new("Frame")
NavStrip.Size = UDim2.new(1, -20, 0, 32)
NavStrip.Position = UDim2.new(0, 10, 0, headerHeight + 40)
NavStrip.BackgroundColor3 = ColorScheme.Surface
NavStrip.BorderSizePixel = 0
NavStrip.ClipsDescendants = true
NavStrip.Parent = MainWindow
Instance.new("UICorner", NavStrip).CornerRadius = UDim.new(0, 8)

local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navLayout.Padding = UDim.new(0, 2)
navLayout.Parent = NavStrip

local contentTop = headerHeight + 80
local function buildPageScroll(canvasHeight, visibleFlag)
	local sf = Instance.new("ScrollingFrame")
	sf.Size = UDim2.new(1, -20, 1, -(contentTop + 10))
	sf.Position = UDim2.new(0, 10, 0, contentTop)
	sf.BackgroundTransparency = 1
	sf.ScrollBarThickness = 3
	sf.ScrollBarImageColor3 = ColorScheme.Primary
	sf.CanvasSize = UDim2.new(0, 0, 0, canvasHeight)
	sf.Visible = visibleFlag
	sf.Parent = MainWindow
	return sf
end

local PageFarm = buildPageScroll(575, true)
local PageSea = buildPageScroll(240, false)
local PagePlayer = buildPageScroll(240, false)
local PageVisuals = buildPageScroll(160, false)
local PagePvP = buildPageScroll(275, false)
local PageFruits = buildPageScroll(160, false)
local PageShop = buildPageScroll((#FightingStylesCatalog * 38) + 12, false)

local allPages = {PageFarm, PageSea, PagePlayer, PageVisuals, PagePvP, PageFruits, PageShop}

local function updateFistBannerUI(isFound, detailInfo)
	if isFound then
		FistBanner.Visible = true
		FistBanner.Text = "★  DARK FIST SPAWNED: " .. tostring(detailInfo or "Found")
		NavStrip.Position = UDim2.new(0, 10, 0, headerHeight + 64)
		for _, page in ipairs(allPages) do
			if page then
				page.Position = UDim2.new(0, 10, 0, headerHeight + 104)
				page.Size = UDim2.new(1, -20, 1, -(headerHeight + 114))
			end
		end
	else
		FistBanner.Visible = false
		NavStrip.Position = UDim2.new(0, 10, 0, headerHeight + 40)
		for _, page in ipairs(allPages) do
			if page then
				page.Position = UDim2.new(0, 10, 0, contentTop)
				page.Size = UDim2.new(1, -20, 1, -(contentTop + 10))
			end
		end
	end
end

local pageLabels = {"Farm", "Sea", "Player", "Visuals", "PvP", "Fruits", "Shop"}
local pageButtons = {}

local function openPageIndex(index)
	for i, page in ipairs(allPages) do
		page.Visible = (i == index)
	end
	for i, btn in ipairs(pageButtons) do
		local selected = (i == index)
		btn.BackgroundTransparency = selected and 0 or 1
		btn.BackgroundColor3 = selected and ColorScheme.Primary or ColorScheme.SurfaceAlt
		btn.TextColor3 = selected and Color3.new(1, 1, 1) or ColorScheme.Muted
	end
end

for i, labelStr in ipairs(pageLabels) do
	local tabBtn = Instance.new("TextButton")
	tabBtn.Size = UDim2.new(1 / #pageLabels, -2.5, 1, 0)
	tabBtn.BackgroundColor3 = ColorScheme.SurfaceAlt
	tabBtn.BackgroundTransparency = (i == 1) and 0 or 1
	tabBtn.Text = labelStr
	tabBtn.TextColor3 = (i == 1) and Color3.new(1, 1, 1) or ColorScheme.Muted
	tabBtn.Font = Enum.Font.GothamBold
	tabBtn.TextSize = 8.5
	tabBtn.Parent = NavStrip
	Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 6)
	tabBtn.MouseButton1Click:Connect(function() openPageIndex(i) end)
	table.insert(pageButtons, tabBtn)
end

local function enableDrag(dragHandle, dragTarget)
	local activeDrag = false
	local pointerStart = nil
	local windowStart = nil
	dragHandle.InputBegan:Connect(function(inputObj)
		if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
			activeDrag = true
			pointerStart = inputObj.Position
			windowStart = dragTarget.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(inputObj)
		if activeDrag and (inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch) then
			local delta = inputObj.Position - pointerStart
			dragTarget.Position = UDim2.new(windowStart.X.Scale, windowStart.X.Offset + delta.X, windowStart.Y.Scale, windowStart.Y.Offset + delta.Y)
		end
	end)
	dragHandle.InputEnded:Connect(function(inputObj)
		if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
			activeDrag = false
		end
	end)
end
enableDrag(HeaderBar, MainWindow)
enableDrag(ReopenPill, ReopenPill)

local function addSwitchRow(parentContainer, titleText, yOffset, initialVal, onChanged)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 32)
	card.Position = UDim2.new(0, 2, 0, yOffset)
	card.BackgroundColor3 = ColorScheme.Surface
	card.BorderSizePixel = 0
	card.Parent = parentContainer
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
	local cardStroke = Instance.new("UIStroke", card)
	cardStroke.Color = initialVal and ColorScheme.Primary or Color3.fromRGB(42, 36, 64)
	cardStroke.Thickness = 1

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -62, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = titleText
	label.TextColor3 = ColorScheme.Text
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 10.5
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	local currentState = initialVal or false
	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 44, 0, 20)
	toggleBtn.Position = UDim2.new(1, -52, 0.5, -10)
	toggleBtn.BackgroundColor3 = currentState and ColorScheme.Primary or Color3.fromRGB(34, 30, 50)
	toggleBtn.Text = currentState and "ON" or "OFF"
	toggleBtn.TextColor3 = currentState and Color3.new(1, 1, 1) or ColorScheme.Muted
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 9.5
	toggleBtn.Active = true
	toggleBtn.Parent = card
	Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

	toggleBtn.MouseButton1Click:Connect(function()
		currentState = not currentState
		toggleBtn.Text = currentState and "ON" or "OFF"
		toggleBtn.BackgroundColor3 = currentState and ColorScheme.Primary or Color3.fromRGB(34, 30, 50)
		toggleBtn.TextColor3 = currentState and ColorScheme.Text or ColorScheme.Muted
		cardStroke.Color = currentState and ColorScheme.Primary or Color3.fromRGB(42, 36, 64)
		pcall(function() onChanged(currentState) end)
	end)
	return card
end

local function addActionRow(parentContainer, titleText, btnCaption, yOffset, onPress)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 32)
	card.Position = UDim2.new(0, 2, 0, yOffset)
	card.BackgroundColor3 = ColorScheme.Surface
	card.BorderSizePixel = 0
	card.Parent = parentContainer
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", card).Color = Color3.fromRGB(46, 39, 72)

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -88, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = titleText
	label.TextColor3 = ColorScheme.Text
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 10.5
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	local triggerBtn = Instance.new("TextButton")
	triggerBtn.Size = UDim2.new(0, 72, 0, 20)
	triggerBtn.Position = UDim2.new(1, -80, 0.5, -10)
	triggerBtn.BackgroundColor3 = ColorScheme.Primary
	triggerBtn.Text = btnCaption
	triggerBtn.TextColor3 = Color3.new(1, 1, 1)
	triggerBtn.Font = Enum.Font.GothamBold
	triggerBtn.TextSize = 9.5
	triggerBtn.Active = true
	triggerBtn.Parent = card
	Instance.new("UICorner", triggerBtn).CornerRadius = UDim.new(0, 6)

	triggerBtn.MouseButton1Click:Connect(function()
		pcall(function() onPress(triggerBtn) end)
	end)
	return card, triggerBtn
end

local function addSliderRow(parentContainer, yOffset, captionPrefix, minBound, maxBound, startVal, onValueChanged)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -6, 0, 42)
	card.Position = UDim2.new(0, 2, 0, yOffset)
	card.BackgroundColor3 = ColorScheme.Surface
	card.BorderSizePixel = 0
	card.Parent = parentContainer
	Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", card).Color = Color3.fromRGB(42, 36, 64)

	local valueLbl = Instance.new("TextLabel")
	valueLbl.Size = UDim2.new(1, -20, 0, 16)
	valueLbl.Position = UDim2.new(0, 10, 0, 5)
	valueLbl.BackgroundTransparency = 1
	valueLbl.Text = captionPrefix .. ": " .. tostring(startVal)
	valueLbl.TextColor3 = ColorScheme.Text
	valueLbl.Font = Enum.Font.GothamSemibold
	valueLbl.TextSize = 10
	valueLbl.TextXAlignment = Enum.TextXAlignment.Left
	valueLbl.Parent = card

	local trackBg = Instance.new("Frame")
	trackBg.Size = UDim2.new(1, -20, 0, 7)
	trackBg.Position = UDim2.new(0, 10, 0, 26)
	trackBg.BackgroundColor3 = Color3.fromRGB(32, 28, 48)
	trackBg.BorderSizePixel = 0
	trackBg.Parent = card
	Instance.new("UICorner", trackBg).CornerRadius = UDim.new(1, 0)

	local ratio = math.clamp((startVal - minBound) / (maxBound - minBound), 0, 1)
	local fillBar = Instance.new("Frame")
	fillBar.Size = UDim2.new(ratio, 0, 1, 0)
	fillBar.BackgroundColor3 = ColorScheme.Primary
	fillBar.BorderSizePixel = 0
	fillBar.Parent = trackBg
	Instance.new("UICorner", fillBar).CornerRadius = UDim.new(1, 0)

	local sliding = false
	trackBg.InputBegan:Connect(function(inputObj)
		if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
			sliding = true
		end
	end)
	UserInputService.InputChanged:Connect(function(inputObj)
		if sliding and (inputObj.UserInputType == Enum.UserInputType.MouseMovement or inputObj.UserInputType == Enum.UserInputType.Touch) then
			pcall(function()
				local rel = math.clamp((inputObj.Position.X - trackBg.AbsolutePosition.X) / trackBg.AbsoluteSize.X, 0, 1)
				fillBar.Size = UDim2.new(rel, 0, 1, 0)
				local computed = math.floor(minBound + (rel * (maxBound - minBound)))
				valueLbl.Text = captionPrefix .. ": " .. tostring(computed)
				onValueChanged(computed)
			end)
		end
	end)
	UserInputService.InputEnded:Connect(function(inputObj)
		if inputObj.UserInputType == Enum.UserInputType.MouseButton1 or inputObj.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)
	return card
end

local function isToolInCategory(toolObj, categoryName)
	if not toolObj or not toolObj:IsA("Tool") then
		return false
	end
	local tipLower = string.lower(tostring(toolObj.ToolTip or ""))
	local nameLower = string.lower(tostring(toolObj.Name or ""))
	if categoryName == "Melee" then
		if string.find(tipLower, "melee", 1, true) then
			return true
		end
		for _, styleItem in ipairs(FightingStylesCatalog) do
			for _, kw in ipairs(styleItem.keywords or {}) do
				if string.find(nameLower, string.lower(kw), 1, true) then
					return true
				end
			end
		end
		return string.find(nameLower, "combat", 1, true) ~= nil
	elseif categoryName == "Fruit" then
		return string.find(tipLower, "fruit", 1, true) ~= nil or string.find(nameLower, "fruit", 1, true) ~= nil
	elseif categoryName == "Sword" then
		return string.find(tipLower, "sword", 1, true) ~= nil
	elseif categoryName == "Gun" then
		return string.find(tipLower, "gun", 1, true) ~= nil
	end
	return true
end

local function equipCategoryWeapon(requestedCategory)
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local bp = LocalPlayer:FindFirstChild("Backpack")
		if not char or not hum or hum.Health <= 0 then
			return
		end
		local desired = requestedCategory or getSelectedWeaponMode()
		local activeTool = char:FindFirstChildOfClass("Tool")
		if activeTool and isToolInCategory(activeTool, desired) then
			return
		end
		if bp then
			for _, item in ipairs(bp:GetChildren()) do
				if isToolInCategory(item, desired) then
					pcall(function() hum:EquipTool(item) end)
					return
				end
			end
		end
		if not activeTool and bp then
			for _, fallbackCat in ipairs({"Melee", "Sword", "Fruit", "Gun"}) do
				for _, item in ipairs(bp:GetChildren()) do
					if isToolInCategory(item, fallbackCat) then
						pcall(function() hum:EquipTool(item) end)
						return
					end
				end
			end
		end
	end)
end

local function equipOwnedStyle(styleObj)
	local didEquip = false
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local bp = LocalPlayer:FindFirstChild("Backpack")
		if not char or not hum then
			return
		end
		local function matches(t)
			if not t or not t:IsA("Tool") then
				return false
			end
			local tn = string.lower(tostring(t.Name))
			local tt = string.lower(tostring(t.ToolTip or ""))
			for _, kw in ipairs(styleObj.keywords or {}) do
				local k = string.lower(tostring(kw))
				if string.find(tn, k, 1, true) or string.find(tt, k, 1, true) then
					return true
				end
			end
			return false
		end
		for _, held in ipairs(char:GetChildren()) do
			if matches(held) then
				didEquip = true
				return
			end
		end
		if bp then
			for _, stored in ipairs(bp:GetChildren()) do
				if matches(stored) then
					pcall(function() hum:EquipTool(stored) end)
					didEquip = true
					return
				end
			end
		end
	end)
	return didEquip
end

local function buyFightingStyle(styleObj)
	StatusText.Text = "●  Shop: Buying " .. tostring(styleObj.name) .. "..."
	StatusText.TextColor3 = ColorScheme.Accent
	task.spawn(function()
		pcall(function()
			for _, argGroup in ipairs(styleObj.cmds or {}) do
				sendCommFCommand(table.unpack(argGroup))
				task.wait(0.15)
			end
			task.wait(0.35)
			if equipOwnedStyle(styleObj) then
				StatusText.Text = "●  Shop: Equipped " .. tostring(styleObj.name)
				StatusText.TextColor3 = ColorScheme.Success
			else
				StatusText.Text = "●  Shop: Sent Buy (" .. tostring(styleObj.name) .. ")"
				StatusText.TextColor3 = ColorScheme.Warning
			end
		end)
	end)
end

local function performFastMeleeAttack(character, targetRoot)
	local now = tick()
	local cooldown = State.FastAttack and State.FastAttackDelay or 0.16
	if (now - Timers.LastHit) < cooldown then
		return
	end
	Timers.LastHit = now
	triggerBusoHaki()

	local hum = character and character:FindFirstChildOfClass("Humanoid")
	local chosenCategory = getSelectedWeaponMode()
	local heldTool = character and character:FindFirstChildOfClass("Tool")
	if not heldTool or not isToolInCategory(heldTool, chosenCategory) then
		equipCategoryWeapon(chosenCategory)
		heldTool = character and character:FindFirstChildOfClass("Tool")
	end

	if hum and hum.Health > 0 and heldTool and heldTool:IsA("Tool") then
		for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
			local lowerTrack = string.lower(tostring(track.Name))
			if string.find(lowerTrack, "slash", 1, true)
				or string.find(lowerTrack, "punch", 1, true)
				or string.find(lowerTrack, "swing", 1, true)
				or string.find(lowerTrack, "attack", 1, true) then
				pcall(function() track:Stop(0) end)
			end
		end

		pcall(function() heldTool:Activate() end)

		local combatRem = resolveCombatRemote()
		if combatRem and targetRoot and targetRoot.Parent then
			pcall(function()
				combatRem:FireServer(targetRoot.Position, {targetRoot})
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

addSwitchRow(PageFarm, "Auto Raid (Auto Islands & Mobs)", 0, false, function(enabled)
	State.AutoRaid = enabled
	if enabled then
		State.AutoFarm = false
	end
	RuntimeRefs.ActiveEnemy = nil
	if enabled then
		processRaidStartAndAwaken()
	elseif not isAnyFarmActive() then
		removeFlightMovers(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
		StatusText.Text = "●  Status: Ready | Melee Fast Attack 0.1s"
		StatusText.TextColor3 = ColorScheme.Muted
	end
end)

addActionRow(PageFarm, "Raid Chip", getSelectedRaidChip(), 38, function(btn)
	State.RaidChipIndex = (State.RaidChipIndex % #RaidChipCatalog) + 1
	btn.Text = getSelectedRaidChip()
end)

addSwitchRow(PageFarm, "Auto Awaken Skill", 76, true, function(enabled)
	State.AutoAwaken = enabled
end)

addSwitchRow(PageFarm, "Auto Farm Mobs (Level Locked)", 114, false, function(enabled)
	State.AutoFarm = enabled
	if enabled then
		State.AutoRaid = false
	end
	RuntimeRefs.ActiveEnemy = nil
	if enabled then
		RuntimeRefs.LockedBracket = selectQuestBracketForLevel(fetchCurrentLevel())
	elseif not isAnyFarmActive() then
		RuntimeRefs.LockedBracket = nil
		removeFlightMovers(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
		StatusText.Text = "●  Status: Ready | Melee Fast Attack 0.1s"
		StatusText.TextColor3 = ColorScheme.Muted
	end
end)

addSwitchRow(PageFarm, "Farm Vampire (Fangs)", 152, false, function(enabled)
	State.FarmVampire = enabled
	RuntimeRefs.ActiveEnemy = nil
	if not isAnyFarmActive() then
		removeFlightMovers(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
	end
end)

addSwitchRow(PageFarm, "Farm Demonic Soul", 190, false, function(enabled)
	State.FarmDemonicSoul = enabled
	RuntimeRefs.ActiveEnemy = nil
	if not isAnyFarmActive() then
		removeFlightMovers(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
	end
end)

addSwitchRow(PageFarm, "Auto Farm Dragon Scale", 228, false, function(enabled)
	State.FarmDragonScale = enabled
	RuntimeRefs.ActiveEnemy = nil
	if not isAnyFarmActive() then
		removeFlightMovers(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
	end
end)

addSwitchRow(PageFarm, "Auto Farm Bones", 266, false, function(enabled)
	State.FarmBones = enabled
	RuntimeRefs.ActiveEnemy = nil
	if not isAnyFarmActive() then
		removeFlightMovers(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
	end
end)

addActionRow(PageFarm, "Farm Weapon", getSelectedWeaponMode(), 304, function(btn)
	State.WeaponIndex = (State.WeaponIndex % #WeaponCategories) + 1
	local modeNow = getSelectedWeaponMode()
	btn.Text = modeNow
	equipCategoryWeapon(modeNow)
end)

addSwitchRow(PageFarm, "Bring Mobs Under You", 342, true, function(enabled)
	State.BringMobs = enabled
end)

addSwitchRow(PageFarm, "Auto Quest (Level Based)", 380, true, function(enabled)
	State.AutoQuest = enabled
end)

addSwitchRow(PageFarm, "Fast Attack (0.1s No Anim)", 418, true, function(enabled)
	State.FastAttack = enabled
end)

addSliderRow(PageFarm, 456, "Farm Fly Speed", 60, 800, State.FlySpeed, function(val)
	State.FlySpeed = val
end)

addSwitchRow(PageSea, "Boat Noclip (Rocks)", 0, false, function(enabled)
	State.BoatNoclipEnabled = enabled
end)

addSwitchRow(PageSea, "Auto Chest (All Map)", 38, false, function(enabled)
	State.AutoChestEnabled = enabled
	RuntimeRefs.VisitedChests = {}
	if not enabled and not isAnyFarmActive() then
		removeFlightMovers(LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
	end
end)

addSwitchRow(PageSea, "Boat Speed Boost", 76, false, function(enabled)
	State.BoatSpeedEnabled = enabled
end)

addSliderRow(PageSea, 114, "Boat Speed", 16, 1000, State.BoatSpeedValue, function(val)
	State.BoatSpeedValue = val
end)

addSwitchRow(PageSea, "Auto Attack Sea Beast / Shark", 164, false, function(enabled)
	State.AutoAttackSeaEnabled = enabled
end)

addSwitchRow(PageSea, "Auto Sail (Stop on Event)", 202, false, function(enabled)
	State.AutoSailEnabled = enabled
	if enabled then
		pcall(function()
			local char = LocalPlayer.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if hum and hum.SeatPart then
				local fwd = hum.SeatPart.CFrame.LookVector
				local horiz = Vector3.new(fwd.X, 0, fwd.Z)
				RuntimeRefs.LockedSailDir = horiz.Magnitude > 0.01 and horiz.Unit or Vector3.new(0, 0, -1)
			end
		end)
	else
		RuntimeRefs.LockedSailDir = nil
	end
end)

addSwitchRow(PagePlayer, "Walk Speed Boost", 0, false, function(enabled)
	State.WalkSpeedEnabled = enabled
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if hum then
			hum.WalkSpeed = enabled and State.WalkSpeedValue or 16
			if not enabled and root then
				root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
			end
		end
	end)
end)

addSliderRow(PagePlayer, 38, "Walk Speed", 16, 350, State.WalkSpeedValue, function(val)
	State.WalkSpeedValue = val
	if State.WalkSpeedEnabled then
		pcall(function()
			local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.WalkSpeed = State.WalkSpeedValue
			end
		end)
	end
end)

addSwitchRow(PagePlayer, "Walk On Water", 88, false, function(enabled)
	State.WalkOnWater = enabled
	if not enabled then
		syncWaterPlatform(nil)
	end
end)

addSwitchRow(PagePlayer, "Auto Haki (Buso)", 126, true, function(enabled)
	State.AutoHaki = enabled
end)

addSwitchRow(PagePlayer, "Anti AFK", 164, true, function(enabled)
	State.AntiAFK = enabled
end)

addSwitchRow(PageVisuals, "ESP (Players & Sea)", 0, false, function(enabled)
	State.ESPEnabled = enabled
end)

addSwitchRow(PageVisuals, "Remove Fog", 38, false, function(enabled)
	State.RemoveFogEnabled = enabled
	if enabled then
		applyClearFog()
	else
		restoreEnvironmentFog()
	end
end)

addSwitchRow(PagePvP, "Auto Kill Target", 0, false, function(enabled)
	State.PvPEnabled = enabled
end)

addSwitchRow(PagePvP, "Aim Bot", 38, false, function(enabled)
	State.AimBotEnabled = enabled
end)

local PvPTargetDisplay = Instance.new("TextLabel")
PvPTargetDisplay.Size = UDim2.new(1, -92, 0, 28)
PvPTargetDisplay.Position = UDim2.new(0, 8, 0, 78)
PvPTargetDisplay.BackgroundColor3 = ColorScheme.Surface
PvPTargetDisplay.Text = "Target: None"
PvPTargetDisplay.TextColor3 = ColorScheme.Text
PvPTargetDisplay.Font = Enum.Font.GothamSemibold
PvPTargetDisplay.TextSize = 10
PvPTargetDisplay.Parent = PagePvP
Instance.new("UICorner", PvPTargetDisplay).CornerRadius = UDim.new(0, 8)

local CycleTargetButton = Instance.new("TextButton")
CycleTargetButton.Size = UDim2.new(0, 76, 0, 28)
CycleTargetButton.Position = UDim2.new(1, -80, 0, 78)
CycleTargetButton.BackgroundColor3 = ColorScheme.Primary
CycleTargetButton.Text = "Next Player"
CycleTargetButton.TextColor3 = Color3.new(1, 1, 1)
CycleTargetButton.Font = Enum.Font.GothamBold
CycleTargetButton.TextSize = 9.5
CycleTargetButton.Parent = PagePvP
Instance.new("UICorner", CycleTargetButton).CornerRadius = UDim.new(0, 8)

addSliderRow(PagePvP, 114, "PvP Follow Speed", 80, 900, State.PvPSpeed, function(val)
	State.PvPSpeed = val
end)

local PlayerRosterScroll = Instance.new("ScrollingFrame")
PlayerRosterScroll.Size = UDim2.new(1, -6, 0, 102)
PlayerRosterScroll.Position = UDim2.new(0, 2, 0, 162)
PlayerRosterScroll.BackgroundColor3 = ColorScheme.Surface
PlayerRosterScroll.ScrollBarThickness = 2
PlayerRosterScroll.ScrollBarImageColor3 = ColorScheme.Primary
PlayerRosterScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayerRosterScroll.Parent = PagePvP
Instance.new("UICorner", PlayerRosterScroll).CornerRadius = UDim.new(0, 8)

addSwitchRow(PageFruits, "Auto Get Fruits", 0, false, function(enabled)
	State.AutoGetFruits = enabled
end)

addSwitchRow(PageFruits, "Auto Store Fruit", 38, false, function(enabled)
	State.AutoStoreFruit = enabled
end)

addSwitchRow(PageFruits, "Auto Roll Fruit", 76, false, function(enabled)
	State.AutoRollFruit = enabled
end)

for idx, styleEntry in ipairs(FightingStylesCatalog) do
	addActionRow(PageShop, styleEntry.name .. " (" .. styleEntry.costNote .. ")", "Buy", (idx - 1) * 38, function()
		buyFightingStyle(styleEntry)
	end)
end

local function setSelectedPvPTarget(playerObj)
	RuntimeRefs.SelectedPvP = playerObj
	PvPTargetDisplay.Text = (playerObj and playerObj.Parent) and ("Target: " .. tostring(playerObj.Name)) or "Target: None"
end

local function rebuildPlayerRoster()
	pcall(function()
		for _, child in ipairs(PlayerRosterScroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		local candidates = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				table.insert(candidates, p)
			end
		end
		if not RuntimeRefs.SelectedPvP or not RuntimeRefs.SelectedPvP.Parent then
			setSelectedPvPTarget(candidates[1])
		end
		for i, p in ipairs(candidates) do
			local rowBtn = Instance.new("TextButton")
			rowBtn.Size = UDim2.new(1, -10, 0, 24)
			rowBtn.Position = UDim2.new(0, 5, 0, 4 + ((i - 1) * 28))
			local isChosen = (p == RuntimeRefs.SelectedPvP)
			rowBtn.BackgroundColor3 = isChosen and ColorScheme.Primary or Color3.fromRGB(26, 22, 42)
			rowBtn.Text = (isChosen and "▶ " or "") .. tostring(p.Name)
			rowBtn.TextColor3 = isChosen and Color3.new(1, 1, 1) or ColorScheme.Text
			rowBtn.Font = Enum.Font.GothamSemibold
			rowBtn.TextSize = 9.5
			rowBtn.TextXAlignment = Enum.TextXAlignment.Left
			rowBtn.Parent = PlayerRosterScroll
			Instance.new("UICorner", rowBtn).CornerRadius = UDim.new(0, 6)
			rowBtn.MouseButton1Click:Connect(function()
				setSelectedPvPTarget(p)
				rebuildPlayerRoster()
			end)
		end
		PlayerRosterScroll.CanvasSize = UDim2.new(0, 0, 0, math.max(20, 8 + (#candidates * 28)))
	end)
end

CycleTargetButton.MouseButton1Click:Connect(function()
	local candidates = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(candidates, p)
		end
	end
	if #candidates == 0 then
		setSelectedPvPTarget(nil)
		rebuildPlayerRoster()
		return
	end
	local nextIdx = 1
	for i, p in ipairs(candidates) do
		if p == RuntimeRefs.SelectedPvP then
			nextIdx = (i % #candidates) + 1
			break
		end
	end
	setSelectedPvPTarget(candidates[nextIdx])
	rebuildPlayerRoster()
end)

Players.PlayerAdded:Connect(function()
	task.wait(0.2)
	rebuildPlayerRoster()
end)

Players.PlayerRemoving:Connect(function(leftPlayer)
	if leftPlayer == RuntimeRefs.SelectedPvP then
		RuntimeRefs.SelectedPvP = nil
	end
	rebuildPlayerRoster()
end)
rebuildPlayerRoster()

UserInputService.InputBegan:Connect(function(inputObj, processed)
	if not processed and inputObj.KeyCode == Enum.KeyCode.RightShift then
		MainWindow.Visible = not MainWindow.Visible
		ReopenPill.Visible = not MainWindow.Visible
	end
end)

local function isQuestFrameActive()
	local pg = LocalPlayer:FindFirstChild("PlayerGui")
	local main = pg and pg:FindFirstChild("Main")
	local qFrame = main and main:FindFirstChild("Quest")
	return (qFrame and qFrame.Visible) == true
end

local function claimBracketQuest(bracket)
	if not State.AutoQuest or not bracket or not bracket.questName then
		return
	end
	sendCommFCommand("StartQuest", bracket.questName, bracket.questNum or 1)
end

local function pullMobsToTarget(centerPos, primaryRoot, bracket, pullAny)
	if not State.BringMobs or not primaryRoot then
		return
	end
	local now = tick()
	if (now - Timers.LastBring) < 0.22 then
		return
	end
	Timers.LastBring = now
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		return
	end
	local pullTargetPos = primaryRoot.Position - Vector3.new(0, 2, 0)
	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if enemy:IsA("Model") and enemy ~= RuntimeRefs.ActiveEnemy and (pullAny or not bracket or matchesBracketKeywords(enemy, bracket)) then
			local eRoot = enemy:FindFirstChild("HumanoidRootPart") or enemy.PrimaryPart
			local eHum = enemy:FindFirstChildOfClass("Humanoid")
			if eRoot and eHum and eHum.Health > 0 and eRoot ~= primaryRoot then
				if (centerPos - eRoot.Position).Magnitude <= State.BringRadius then
					pcall(function()
						eRoot.CanCollide = false
						eRoot.Anchored = false
						eRoot.AssemblyLinearVelocity = Vector3.zero
						eRoot.AssemblyAngularVelocity = Vector3.zero
						eRoot.CFrame = CFrame.new(pullTargetPos)
					end)
				end
			end
		end
	end
end

local function engageEnemyTarget(char, root, enemyModel, enemyRoot, enemyHum, modeTag, bannerColor, bracket, pullAny)
	if enemyModel and enemyRoot and enemyHum and enemyHum.Health > 0 then
		local modeLabel = getSelectedWeaponMode()
		local fistSuffix = State.FistDetected and " | ★ DARK FIST!" or ""
		StatusText.Text = "●  " .. modeTag .. " [" .. modeLabel .. "]: " .. tostring(enemyModel.Name) .. " (" .. tostring(math.floor(enemyHum.Health)) .. " HP)" .. fistSuffix
		StatusText.TextColor3 = State.FistDetected and ColorScheme.Warning or bannerColor
		local hoverOffset = (modeLabel == "Gun") and 11 or 8
		local desiredPos = enemyRoot.Position + Vector3.new(0, hoverOffset, 0)
		stepFlightTo(root, CFrame.lookAt(desiredPos, enemyRoot.Position), State.FlySpeed)
		if (root.Position - enemyRoot.Position).Magnitude <= 85 then
			pullMobsToTarget(root.Position, enemyRoot, bracket, pullAny)
			performFastMeleeAttack(char, enemyRoot)
		end
		return true
	end
	return false
end

task.spawn(function()
	while State.Running do
		task.wait(0.35)
		local ok, foundFist, fistDetails = pcall(scanForDarkFist)
		if ok and foundFist then
			State.FistDetected = true
			updateFistBannerUI(true, fistDetails)
			if (tick() - Timers.LastFistAlert) >= 3 then
				Timers.LastFistAlert = tick()
				if StarterGui then
					pcall(function()
						StarterGui:SetCore("SendNotification", {
							Title = "NEXOARO | DARK FIST",
							Text = "Spawned: " .. tostring(fistDetails),
							Duration = 5
						})
					end)
				end
			end
		else
			if State.FistDetected then
				State.FistDetected = false
				updateFistBannerUI(false, nil)
			end
		end
	end
end)

task.spawn(function()
	while State.Running do
		task.wait(0.05)
		if isAnyFarmActive() then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 then
				local currentLvl = fetchCurrentLevel()
				equipCategoryWeapon(getSelectedWeaponMode())

				if State.AutoRaid then
					processRaidStartAndAwaken()
					local chipName = getSelectedRaidChip()
					local mob, mRoot, mHum = acquireFarmTarget(root.Position, isRaidEnemyCandidate, nil)
					if not mob then
						mob, mRoot, mHum = acquireFarmTarget(root.Position, nil, nil)
					end
					if not engageEnemyTarget(char, root, mob, mRoot, mHum, "Raid [" .. chipName .. "]", ColorScheme.Raid, nil, true) then
						local islandDest = computeNextRaidIsland(root.Position)
						StatusText.Text = "●  Raid [" .. chipName .. "]: Moving to Next Island..."
						StatusText.TextColor3 = ColorScheme.Raid
						stepFlightTo(root, CFrame.new(islandDest), State.FlySpeed)
					end
				elseif State.FarmBones then
					local mob, mRoot, mHum = acquireFarmTarget(root.Position, filterBoneMob, nil)
					if not engageEnemyTarget(char, root, mob, mRoot, mHum, "Bones", ColorScheme.Text, nil, false) then
						local boneDest = resolveSpawnPoint({"reborn skeleton", "living zombie", "demonic soul"}, IslandFallbackPoints.HauntedCastle)
						stepFlightTo(root, CFrame.new(boneDest), State.FlySpeed)
					end
				elseif State.FarmDragonScale then
					local mob, mRoot, mHum = acquireFarmTarget(root.Position, filterDragonScaleMob, nil)
					if not engageEnemyTarget(char, root, mob, mRoot, mHum, "Dragon Scale", Color3.fromRGB(249, 115, 22), nil, false) then
						local scaleDest = resolveSpawnPoint({"dragon crew warrior", "dragon crew archer"}, IslandFallbackPoints.HydraIsland)
						stepFlightTo(root, CFrame.new(scaleDest), State.FlySpeed)
					end
				elseif State.FarmVampire then
					local mob, mRoot, mHum = acquireFarmTarget(root.Position, filterVampireMob, nil)
					if not engageEnemyTarget(char, root, mob, mRoot, mHum, "Vampire", ColorScheme.Danger, nil, false) then
						StatusText.Text = "●  Vampire: Waiting Respawn..."
						StatusText.TextColor3 = ColorScheme.Warning
					end
				elseif State.FarmDemonicSoul then
					local mob, mRoot, mHum = acquireFarmTarget(root.Position, filterDemonicSoulMob, nil)
					if not engageEnemyTarget(char, root, mob, mRoot, mHum, "Demonic Soul", ColorScheme.Fruit, nil, false) then
						StatusText.Text = "●  Demonic Soul: Waiting Respawn..."
						StatusText.TextColor3 = ColorScheme.Warning
					end
				elseif State.AutoFarm then
					if not RuntimeRefs.LockedBracket
						or currentLvl > RuntimeRefs.LockedBracket.maxLvl
						or currentLvl < RuntimeRefs.LockedBracket.minLvl then
						RuntimeRefs.LockedBracket = selectQuestBracketForLevel(currentLvl)
					end
					local activeBracket = RuntimeRefs.LockedBracket
					if State.AutoQuest and not isQuestFrameActive() and (tick() - Timers.LastQuest) > 2.5 then
						Timers.LastQuest = tick()
						claimBracketQuest(activeBracket)
					end
					local mob, mRoot, mHum = acquireFarmTarget(root.Position, nil, activeBracket)
					if not engageEnemyTarget(char, root, mob, mRoot, mHum, "Lv." .. tostring(currentLvl) .. " | " .. activeBracket.questText, ColorScheme.Success, activeBracket, false) then
						local targetSpawn = resolveSpawnPoint(activeBracket.keywords, activeBracket.fallback or IslandFallbackPoints.HighDisciple)
						StatusText.Text = "●  Moving to " .. activeBracket.questText .. " [Lv." .. tostring(activeBracket.minLvl) .. "-" .. tostring(activeBracket.maxLvl) .. "]..."
						StatusText.TextColor3 = ColorScheme.Warning
						stepFlightTo(root, CFrame.new(targetSpawn), State.FlySpeed)
					end
				end
			end
		else
			RuntimeRefs.ActiveEnemy = nil
		end
	end
end)

task.spawn(function()
	while State.Running do
		task.wait(0.08)
		if State.AutoChestEnabled and not isAnyFarmActive() then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				local chestPart, chestName, chestDist, chestOwner = locateClosestChest(root.Position)
				if chestPart then
					StatusText.Text = "●  Chest: " .. tostring(chestName) .. " [" .. tostring(math.floor(chestDist)) .. "m]"
					StatusText.TextColor3 = ColorScheme.Warning
					stepFlightTo(root, chestPart.CFrame + Vector3.new(0, 1.5, 0), State.FlySpeed)
					if chestDist <= 7 then
						RuntimeRefs.VisitedChests[chestOwner or chestPart] = tick()
					end
				else
					StatusText.Text = "●  Chest: No active chests loaded nearby"
					StatusText.TextColor3 = ColorScheme.Muted
				end
			end
		end
	end
end)

task.spawn(function()
	while State.Running do
		task.wait(0.1)
		if State.AutoGetFruits then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				local bestPart, bestName, bestDist = nil, nil, math.huge
				for _, childObj in ipairs(Workspace:GetChildren()) do
					if isWorldFruitPickup(childObj) then
						local part = getFruitPart(childObj)
						if part and part.Parent then
							local d = (root.Position - part.Position).Magnitude
							if d < bestDist then
								bestDist = d
								bestPart = part
								bestName = matchFruitName(childObj.Name) or childObj.Name
							end
						end
					end
				end
				if bestPart then
					StatusText.Text = "●  Fruit: " .. tostring(bestName) .. " [" .. tostring(math.floor(bestDist)) .. "m]"
					StatusText.TextColor3 = ColorScheme.Fruit
					stepFlightTo(root, bestPart.CFrame + Vector3.new(0, 1.5, 0), State.FlySpeed)
				end
			end
		end

		if State.AutoStoreFruit and (tick() - Timers.LastStore) >= 1.2 then
			Timers.LastStore = tick()
			for _, bag in ipairs({LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}) do
				if bag then
					for _, toolObj in ipairs(bag:GetChildren()) do
						local resolvedFruit = toolObj:IsA("Tool") and matchFruitName(toolObj.Name) or nil
						if resolvedFruit then
							sendCommFCommand("StoreFruit", buildFruitStoreKey(toolObj, resolvedFruit), toolObj)
							sendCommFCommand("StoreFruit", resolvedFruit, toolObj)
						end
					end
				end
			end
		end

		if State.AutoRollFruit and (tick() - Timers.LastRoll) >= 2.2 then
			Timers.LastRoll = tick()
			sendCommFCommand("Censor")
			sendCommFCommand("RollFruit")
		end
	end
end)

task.spawn(function()
	while State.Running do
		task.wait(0.05)
		if State.PvPEnabled or State.AimBotEnabled then
			local char = LocalPlayer.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local foe = RuntimeRefs.SelectedPvP
			if root and foe and foe.Parent and foe ~= LocalPlayer and foe.Character then
				local foeRoot = foe.Character:FindFirstChild("HumanoidRootPart")
				local foeHum = foe.Character:FindFirstChildOfClass("Humanoid")
				if foeRoot and foeHum and foeHum.Health > 0 then
					if State.AimBotEnabled and Camera then
						Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, foeRoot.Position)
					end
					if State.PvPEnabled then
						local chaseCF = CFrame.lookAt((foeRoot.CFrame * CFrame.new(0, 0, 3)).Position, foeRoot.Position)
						stepFlightTo(root, chaseCF, State.PvPSpeed)
						if (root.Position - foeRoot.Position).Magnitude <= 25 then
							performFastMeleeAttack(char, foeRoot)
						end
					end
				end
			end
		end
	end
end)

RunService.Stepped:Connect(function()
	if not State.Running then
		return
	end
	local char = LocalPlayer.Character
	if not char then
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")

	if State.WalkOnWater and root then
		syncWaterPlatform(root.Position)
	end
	applyPlayerSpeed(char, hum, root)

	if State.AutoSailEnabled and hum and hum.SeatPart and RuntimeRefs.LockedSailDir then
		local seat = hum.SeatPart
		local boatVel = RuntimeRefs.LockedSailDir * State.BoatSpeedValue
		seat.AssemblyLinearVelocity = Vector3.new(boatVel.X, seat.AssemblyLinearVelocity.Y, boatVel.Z)
		if seat:IsA("VehicleSeat") then
			seat.MaxSpeed = math.max(State.BoatSpeedValue, 150)
			seat.Throttle = 1
			seat.Steer = 0
		end
	end

	local shouldNoclip = isAnyFarmActive()
		or State.AutoChestEnabled
		or State.PvPEnabled
		or State.AutoGetFruits
		or (State.BoatNoclipEnabled and hum and hum.SeatPart)
	if shouldNoclip then
		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") and part.CanCollide then
				part.CanCollide = false
			end
		end
	end
	if State.BoatNoclipEnabled and hum and hum.SeatPart then
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

RunService.Heartbeat:Connect(function()
	if not State.Running then
		return
	end
	local char = LocalPlayer.Character
	if not char then
		return
	end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local root = char:FindFirstChild("HumanoidRootPart")
	applyPlayerSpeed(char, hum, root)
end)

if Drawing and type(Drawing.new) == "function" then
	local function registerPlayerESP(plrObj)
		if plrObj == LocalPlayer or RuntimeRefs.PlayerESP[plrObj] then
			return
		end
		pcall(function()
			local boxDraw = Drawing.new("Square")
			boxDraw.Thickness = 1.5
			boxDraw.Color = ColorScheme.Primary
			boxDraw.Filled = false
			boxDraw.Visible = false

			local labelDraw = Drawing.new("Text")
			labelDraw.Size = 12
			labelDraw.Center = true
			labelDraw.Outline = true
			labelDraw.Color = Color3.new(1, 1, 1)
			labelDraw.Visible = false

			RuntimeRefs.PlayerESP[plrObj] = {Box = boxDraw, Name = labelDraw}
		end)
	end

	for _, p in ipairs(Players:GetPlayers()) do
		registerPlayerESP(p)
	end
	Players.PlayerAdded:Connect(registerPlayerESP)
	Players.PlayerRemoving:Connect(function(p)
		local entry = RuntimeRefs.PlayerESP[p]
		if entry then
			for _, dObj in pairs(entry) do
				pcall(function() dObj:Remove() end)
			end
			RuntimeRefs.PlayerESP[p] = nil
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not State.Running or not Camera then
			return
		end
		local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		for plrObj, espSet in pairs(RuntimeRefs.PlayerESP) do
			local char = plrObj.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if State.ESPEnabled and root and hum and hum.Health > 0 then
				local screenPt, visibleOnScreen = Camera:WorldToViewportPoint(root.Position)
				if visibleOnScreen then
					local distMeters = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
					espSet.Box.Size = Vector2.new(36, 54)
					espSet.Box.Position = Vector2.new(screenPt.X - 18, screenPt.Y - 27)
					espSet.Box.Visible = true
					espSet.Name.Text = plrObj.Name .. " [" .. distMeters .. "m]"
					espSet.Name.Position = Vector2.new(screenPt.X, screenPt.Y - 40)
					espSet.Name.Visible = true
				else
					espSet.Box.Visible = false
					espSet.Name.Visible = false
				end
			else
				espSet.Box.Visible = false
				espSet.Name.Visible = false
			end
		end
	end)
end

print("[NEXOARO] Full Blox Fruits Hub Loaded")
