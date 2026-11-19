local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local VirtualInputManager = nil
pcall(function()
	VirtualInputManager = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local BgDark = Color3.fromRGB(10, 9, 16)
local CardDark = Color3.fromRGB(18, 16, 28)
local ThemeColor = Color3.fromRGB(168, 85, 247)
local AccentGlow = Color3.fromRGB(216, 180, 254)
local TextMain = Color3.fromRGB(244, 244, 255)
local TextMuted = Color3.fromRGB(156, 152, 178)
local EnemyColor = Color3.fromRGB(244, 63, 94)
local SeaBeastColor = Color3.fromRGB(56, 189, 248)
local ChestColor = Color3.fromRGB(250, 204, 21)
local FruitColor = Color3.fromRGB(168, 85, 247)

local BoatSpeedEnabled = false
local TargetBoatSpeed = 150
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
local BringMobsEnabled = true
local AutoQuestEnabled = true
local ESPEnabled = true
local ChestESPEnabled = false
local FruitESPEnabled = false
local AutoGetFruitsEnabled = false
local AutoStoreFruitEnabled = false
local AutoRollFruitEnabled = false
local PvPEnabled = false
local AimBotEnabled = false
local PvPSpeed = 320
local SelectedPvPPlayer = nil
local FlySpeed = 280
local BringRadius = 220
local CurrentTween = nil
local ScriptRunning = true
local LastHitTick = 0
local LastPvPClickTick = 0
local LastRollTick = 0

local AllowedChestNames = {
	"GoldChest",
	"SilverChest",
	"DiamondChest"
}

local BloxFruitNames = {
	"Rocket Fruit",
	"Spin Fruit",
	"Blade Fruit",
	"Chop Fruit",
	"Spring Fruit",
	"Bomb Fruit",
	"Smoke Fruit",
	"Spike Fruit",
	"Flame Fruit",
	"Falcon Fruit",
	"Ice Fruit",
	"Sand Fruit",
	"Dark Fruit",
	"Diamond Fruit",
	"Light Fruit",
	"Rubber Fruit",
	"Barrier Fruit",
	"Ghost Fruit",
	"Magma Fruit",
	"Quake Fruit",
	"Buddha Fruit",
	"Love Fruit",
	"Spider Fruit",
	"Sound Fruit",
	"Phoenix Fruit",
	"Portal Fruit",
	"Rumble Fruit",
	"Pain Fruit",
	"Paw Fruit",
	"Blizzard Fruit",
	"Gravity Fruit",
	"Mammoth Fruit",
	"T-Rex Fruit",
	"Dough Fruit",
	"Shadow Fruit",
	"Venom Fruit",
	"Control Fruit",
	"Gas Fruit",
	"Spirit Fruit",
	"Leopard Fruit",
	"Yeti Fruit",
	"Dragon Fruit",
	"Kitsune Fruit"
}

local BloxFruitLookup = {}
for _, fruitName in ipairs(BloxFruitNames) do
	local lower = string.lower(fruitName)
	BloxFruitLookup[lower] = fruitName
	local withoutSuffix = string.gsub(lower, "%s*fruit%s*$", "")
	if withoutSuffix ~= "" then
		BloxFruitLookup[withoutSuffix] = fruitName
	end
end

local TrackedPlayers = {}
local TrackedNPCs = {}
local TrackedChests = {}
local TrackedFruits = {}
local SeaEventKeywords = {"seabeast", "sea beast", "terror", "shark", "leviathan", "piranha", "ship", "ghost", "mirage", "kitsune"}

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
	for _, fullName in ipairs(BloxFruitNames) do
		local fLower = string.lower(fullName)
		local fBase = string.gsub(fLower, "%s*fruit%s*$", "")
		if lower == fLower or lower == fBase then
			return fullName
		end
	end
	return nil
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
	return AutoQuestFarmEnabled or FarmVampireEnabled or FarmDemonicSoulEnabled
end

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
		MainFrame.Size = UDim2.new(0, 310, 0, 355)
		UIScale.Scale = math.clamp(vp.Y / 480, 0.72, 0.96)
	else
		MainFrame.Size = UDim2.new(0, 410, 0, 425)
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
mainStroke.Transparency = 0.2

local mainGrad = Instance.new("UIGradient", MainFrame)
mainGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 13, 28)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 8, 15))
})
mainGrad.Rotation = 135

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, isMobile and 38 or 44)
TopBar.BackgroundColor3 = CardDark
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topGrad = Instance.new("UIGradient", TopBar)
topGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 18, 56)),
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
SubTitle.Size = UDim2.new(0, 95, 1, 0)
SubTitle.Position = UDim2.new(0, isMobile and 88 or 102, 0, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "SEA & FARM HUB"
SubTitle.TextColor3 = AccentGlow
SubTitle.Font = Enum.Font.GothamBold
SubTitle.TextSize = isMobile and 9 or 10
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
OpenPill.Size = UDim2.new(0, 112, 0, 32)
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
	pcall(function()
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16
		end
	end)
	pcall(function()
		if CurrentTween then
			CurrentTween:Cancel()
		end
	end)
	for _, esp in pairs(TrackedPlayers) do
		for _, d in pairs(esp) do
			pcall(function() d:Remove() end)
		end
	end
	for _, esp in pairs(TrackedNPCs) do
		pcall(function()
			if esp.Text then
				esp.Text:Remove()
			end
		end)
	end
	for _, esp in pairs(TrackedChests) do
		pcall(function()
			if esp.Text then
				esp.Text:Remove()
			end
		end)
	end
	for _, esp in pairs(TrackedFruits) do
		pcall(function()
			if esp.Text then
				esp.Text:Remove()
			end
		end)
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
	tabBtn.TextSize = 8.8
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
Container1.CanvasSize = UDim2.new(0, 0, 0, 230)
Container1.Visible = true
Container1.Parent = MainFrame

local Container2 = Instance.new("ScrollingFrame")
Container2.Size = Container1.Size
Container2.Position = Container1.Position
Container2.BackgroundTransparency = 1
Container2.ScrollBarThickness = 3
Container2.ScrollBarImageColor3 = ThemeColor
Container2.CanvasSize = UDim2.new(0, 0, 0, 265)
Container2.Visible = false
Container2.Parent = MainFrame

local Container3 = Instance.new("ScrollingFrame")
Container3.Size = Container1.Size
Container3.Position = Container1.Position
Container3.BackgroundTransparency = 1
Container3.ScrollBarThickness = 3
Container3.ScrollBarImageColor3 = ThemeColor
Container3.CanvasSize = UDim2.new(0, 0, 0, 150)
Container3.Visible = false
Container3.Parent = MainFrame

local Container4 = Instance.new("ScrollingFrame")
Container4.Size = Container1.Size
Container4.Position = Container1.Position
Container4.BackgroundTransparency = 1
Container4.ScrollBarThickness = 3
Container4.ScrollBarImageColor3 = ThemeColor
Container4.CanvasSize = UDim2.new(0, 0, 0, 120)
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

local tab1Btn = createTabButton("Sea", 6)
local tab2Btn = createTabButton("Farm", 6)
local tab3Btn = createTabButton("Player", 6)
local tab4Btn = createTabButton("Visuals", 6)
local tab5Btn = createTabButton("PvP", 6)
local tab6Btn = createTabButton("Fruits", 6)

tab1Btn.BackgroundTransparency = 0
tab1Btn.BackgroundColor3 = ThemeColor
tab1Btn.TextColor3 = Color3.new(1, 1, 1)

local function switchTab(activeBtn, activeContainer)
	for _, c in ipairs({Container1, Container2, Container3, Container4, Container5, Container6}) do
		c.Visible = false
	end
	for _, b in ipairs({tab1Btn, tab2Btn, tab3Btn, tab4Btn, tab5Btn, tab6Btn}) do
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

		local parts = getBoatParts(seat)
		for _, part in ipairs(parts) do
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
		pcall(function()
			if CurrentTween then
				CurrentTween:Cancel()
				CurrentTween = nil
			end
		end)
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

createToggle(Container2, "Auto Farm Mobs", 0, false, function(state)
	AutoQuestFarmEnabled = state
	if not hasActiveTargetFarm() and CurrentTween then
		pcall(function() CurrentTween:Cancel() end)
		CurrentTween = nil
	end
end)
createToggle(Container2, "Farm Vampire (Fangs)", 38, false, function(state)
	FarmVampireEnabled = state
	if not hasActiveTargetFarm() and CurrentTween then
		pcall(function() CurrentTween:Cancel() end)
		CurrentTween = nil
	end
end)
createToggle(Container2, "Farm Demonic Soul", 76, false, function(state)
	FarmDemonicSoulEnabled = state
	if not hasActiveTargetFarm() and CurrentTween then
		pcall(function() CurrentTween:Cancel() end)
		CurrentTween = nil
	end
end)
createToggle(Container2, "Bring Mobs Under You", 114, true, function(state)
	BringMobsEnabled = state
end)
createToggle(Container2, "Auto Quest (Level Based)", 152, true, function(state)
	AutoQuestEnabled = state
end)
createSlider(Container2, 190, "Farm Fly Speed", 60, 800, FlySpeed, function(val)
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
createToggle(Container3, "Auto Attack Sea Beast / Shark", 88, false, function(state)
	AutoAttackSeaEnabled = state
end)

createToggle(Container4, "ESP (Players & Sea)", 0, true, function(state) ESPEnabled = state end)
createToggle(Container4, "ESP (Chests)", 38, false, function(state) ChestESPEnabled = state end)

createToggle(Container5, "Auto Kill Target", 0, false, function(state)
	PvPEnabled = state
	if not state then
		pcall(function()
			if CurrentTween then
				CurrentTween:Cancel()
				CurrentTween = nil
			end
		end)
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
		pcall(function()
			if CurrentTween then
				CurrentTween:Cancel()
				CurrentTween = nil
			end
		end)
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

local function getEnemyLevel(enemyModel)
	local ok, lvl = pcall(function()
		if not enemyModel then
			return nil
		end
		for _, attrName in ipairs({"Level", "Lvl", "level", "lvl"}) do
			local attr = enemyModel:GetAttribute(attrName)
			if typeof(attr) == "number" then
				return attr
			end
		end
		for _, childName in ipairs({"Level", "Lvl", "level", "lvl"}) do
			local valObj = enemyModel:FindFirstChild(childName)
			if valObj and (valObj:IsA("IntValue") or valObj:IsA("NumberValue")) then
				return valObj.Value
			end
		end
		local matched = string.match(tostring(enemyModel.Name), "%[%s*[Ll][Vv]?%.?%s*(%d+)%s*%]") or string.match(tostring(enemyModel.Name), "[Ll][Vv]?%.?%s*(%d+)")
		if matched then
			return tonumber(matched)
		end
		for _, desc in ipairs(enemyModel:GetDescendants()) do
			if desc:IsA("TextLabel") then
				local txtMatch = string.match(tostring(desc.Text), "[Ll][Vv]?%.?%s*(%d+)")
				if txtMatch then
					return tonumber(txtMatch)
				end
			end
		end
		return nil
	end)
	if ok then
		return lvl
	end
	return nil
end

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

local function storeFruitsInInventory()
	pcall(function()
		local containers = {LocalPlayer:FindFirstChild("Backpack"), LocalPlayer.Character}
		for _, cont in ipairs(containers) do
			if cont then
				for _, item in ipairs(cont:GetChildren()) do
					local resolvedFruit = item:IsA("Tool") and resolveBloxFruitName(item.Name) or nil
					if resolvedFruit then
						for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
							if rem:IsA("RemoteFunction") or rem:IsA("RemoteEvent") then
								local n = string.lower(rem.Name)
								if string.find(n, "store") or string.find(n, "fruit") or string.find(n, "inventory") or string.find(n, "commf") then
									if rem:IsA("RemoteFunction") then
										pcall(function() rem:InvokeServer("StoreFruit", resolvedFruit, item) end)
										pcall(function() rem:InvokeServer(resolvedFruit, item) end)
										pcall(function() rem:InvokeServer("Store", resolvedFruit) end)
									elseif rem:IsA("RemoteEvent") then
										pcall(function() rem:FireServer("StoreFruit", resolvedFruit, item) end)
										pcall(function() rem:FireServer(resolvedFruit, item) end)
										pcall(function() rem:FireServer("Store", resolvedFruit) end)
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
						pcall(function() rem:InvokeServer("Roll") end)
					elseif rem:IsA("RemoteEvent") then
						pcall(function() rem:FireServer("Censor") end)
						pcall(function() rem:FireServer("RollFruit") end)
						pcall(function() rem:FireServer("Roll") end)
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

task.spawn(function()
	while ScriptRunning do
		task.wait(0.12)
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
					local dur = math.clamp(dist / math.max(FlySpeed, 120), 0.04, 12)
					if CurrentTween then
						pcall(function() CurrentTween:Cancel() end)
					end
					CurrentTween = TweenService:Create(root, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = goalCF})
					CurrentTween:Play()

					local t0 = tick()
					while ScriptRunning and AutoGetFruitsEnabled and fruitPart.Parent and (tick() - t0) < (dur + 0.35) do
						root.AssemblyLinearVelocity = Vector3.zero
						task.wait(0.05)
					end
					if CurrentTween then
						pcall(function() CurrentTween:Cancel() end)
						CurrentTween = nil
					end
					if fruitPart.Parent then
						root.CFrame = goalCF
						for _, desc in ipairs(fruitObj:GetDescendants()) do
							if desc:IsA("ProximityPrompt") then
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
	if (now - LastHitTick) < 0.08 then
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

task.spawn(function()
	while ScriptRunning do
		task.wait(0.025)
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

					ensureEquippedIfNone()
					StatusLabel.Text = "●  PvP Auto-Click: " .. tostring(targetPlr.Name) .. " [" .. tostring(math.floor(tHum.Health)) .. " HP]"
					StatusLabel.TextColor3 = EnemyColor

					local stickPos = tRoot.CFrame * CFrame.new(0, 0, 3.2)
					local goalCF = CFrame.lookAt(stickPos.Position, tRoot.Position)
					local dist = (root.Position - goalCF.Position).Magnitude

					if dist > 4 then
						local dur = math.clamp(dist / math.max(PvPSpeed, 80), 0.02, 2.5)
						if CurrentTween then
							pcall(function() CurrentTween:Cancel() end)
						end
						CurrentTween = TweenService:Create(root, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = goalCF})
						CurrentTween:Play()
					else
						if CurrentTween then
							pcall(function() CurrentTween:Cancel() end)
							CurrentTween = nil
						end
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
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("Model") and not Players:GetPlayerFromCharacter(obj) and not obj:FindFirstChildOfClass("Humanoid") then
				local n = string.lower(obj.Name)
				if string.find(n, "quest") then
					local part = obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
					if part then
						local d = (myPos - part.Position).Magnitude
						if d < bestDist then
							bestDist = d
							bestPart = part
						end
					end
				end
			elseif obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
				local parentModel = obj:FindFirstAncestorOfClass("Model")
				if parentModel and not Players:GetPlayerFromCharacter(parentModel) then
					local pn = string.lower(parentModel.Name)
					local on = string.lower(obj.Name)
					if string.find(pn, "quest") or string.find(on, "quest") then
						local part = parentModel:FindFirstChild("HumanoidRootPart") or parentModel.PrimaryPart or (obj.Parent and obj.Parent:IsA("BasePart") and obj.Parent)
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
		end
	end)
	return bestPart, bestDist
end

local function interactWithQuest(root, questPart)
	pcall(function()
		root.CFrame = questPart.CFrame * CFrame.new(0, 0, -4)
		task.wait(0.25)
		for _, desc in ipairs(questPart.Parent:GetDescendants()) do
			if desc:IsA("ProximityPrompt") then
				fireproximityprompt(desc)
			elseif desc:IsA("ClickDetector") and fireclickdetector then
				fireclickdetector(desc)
			end
		end
		for _, gui in ipairs(playerGui:GetDescendants()) do
			if gui:IsA("TextButton") and gui.Visible then
				local txt = string.lower(gui.Text)
				if string.find(txt, "accept") or string.find(txt, "start") or string.find(txt, "quest") then
					for _, conn in ipairs(getconnections(gui.MouseButton1Click)) do
						conn:Fire()
					end
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

local function getNearestEnemy(myPos, myLvl)
	local enemiesFolder = Workspace:FindFirstChild("Enemies")
	if not enemiesFolder then
		return nil, nil, nil
	end

	local bestTierEnemy, bestTierRoot, bestTierHum, bestTierScore = nil, nil, nil, math.huge
	local fallbackEnemy, fallbackRoot, fallbackHum, fallbackDist = nil, nil, nil, math.huge

	for _, enemy in ipairs(enemiesFolder:GetChildren()) do
		if enemy:IsA("Model") then
			local eRoot = enemy:FindFirstChild("HumanoidRootPart")
			local eHum = enemy:FindFirstChildOfClass("Humanoid")
			if eRoot and eHum and eHum.Health > 0 then
				local dist = (myPos - eRoot.Position).Magnitude
				local eLvl = getEnemyLevel(enemy)

				if not eLvl or eLvl <= myLvl then
					if dist < fallbackDist then
						fallbackDist = dist
						fallbackEnemy = enemy
						fallbackRoot = eRoot
						fallbackHum = eHum
					end

					if eLvl then
						local lvlDiff = myLvl - eLvl
						if lvlDiff >= 0 and lvlDiff <= 50 then
							local score = dist + (lvlDiff * 25)
							if score < bestTierScore then
								bestTierScore = score
								bestTierEnemy = enemy
								bestTierRoot = eRoot
								bestTierHum = eHum
							end
						end
					end
				end
			end
		end
	end

	if bestTierEnemy then
		return bestTierEnemy, bestTierRoot, bestTierHum
	end
	return fallbackEnemy, fallbackRoot, fallbackHum
end

local function bringMobsUnderPlayer(centerPos, mainEnemyRoot)
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
			if enemy:IsA("Model") then
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

local function farmTargetModel(char, root, targetEnemy, tRoot, tHum, statusPrefix, statusColor)
	if targetEnemy and tRoot and tHum and tHum.Health > 0 then
		local tLvl = getEnemyLevel(targetEnemy)
		local lvlTag = tLvl and (" [Lv." .. tostring(tLvl) .. "]") or ""
		StatusLabel.Text = "●  " .. statusPrefix .. ": " .. tostring(targetEnemy.Name) .. lvlTag
		StatusLabel.TextColor3 = statusColor

		local targetPos = tRoot.Position + Vector3.new(0, 6.5, 0)
		local lookCF = CFrame.lookAt(targetPos, tRoot.Position)
		local dist = (root.Position - targetPos).Magnitude

		if dist > 6.5 then
			local duration = math.clamp(dist / math.max(FlySpeed, 60), 0.04, 2.5)
			if CurrentTween then
				pcall(function() CurrentTween:Cancel() end)
			end
			CurrentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = lookCF})
			CurrentTween:Play()
		else
			if CurrentTween then
				pcall(function() CurrentTween:Cancel() end)
				CurrentTween = nil
			end
			root.CFrame = lookCF
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tRoot.Position)
		end

		root.AssemblyLinearVelocity = Vector3.zero
		root.AssemblyAngularVelocity = Vector3.zero
		bringMobsUnderPlayer(root.Position, tRoot)
		if dist <= 18 then
			triggerHit(char)
		end
		return true
	end
	return false
end

task.spawn(function()
	while ScriptRunning do
		task.wait(0.05)
		if hasActiveTargetFarm() then
			pcall(function()
				local char = LocalPlayer.Character
				local root = char and char:FindFirstChild("HumanoidRootPart")
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if not root or not hum or hum.Health <= 0 then
					return
				end

				local myLvl = getPlayerLevel()
				ensureEquippedIfNone()

				if FarmVampireEnabled then
					local vampEnemy, vRoot, vHum = getNearestByPredicate(root.Position, isVampireEnemy)
					if not farmTargetModel(char, root, vampEnemy, vRoot, vHum, "Fangs Farm", Color3.fromRGB(244, 63, 94)) then
						StatusLabel.Text = "●  Searching Vampire (Fangs)..."
						StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
					end
					return
				end

				if FarmDemonicSoulEnabled then
					local soulEnemy, sRoot, sHum = getNearestByPredicate(root.Position, isDemonicSoulEnemy)
					if not farmTargetModel(char, root, soulEnemy, sRoot, sHum, "Demonic Soul Farm", Color3.fromRGB(192, 132, 252)) then
						StatusLabel.Text = "●  Searching Demonic Soul..."
						StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
					end
					return
				end

				if AutoQuestEnabled and not hasActiveQuest() then
					local qPart, qDist = findQuestNPC(root.Position)
					if qPart and qDist < 900 then
						StatusLabel.Text = "●  Lv." .. tostring(myLvl) .. " | Taking Quest..."
						StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
						local targetQPos = qPart.Position + Vector3.new(0, 2, -4)
						local d = (root.Position - targetQPos).Magnitude
						if d > 8 then
							local dur = math.clamp(d / math.max(FlySpeed, 60), 0.05, 3)
							if CurrentTween then
								pcall(function() CurrentTween:Cancel() end)
							end
							CurrentTween = TweenService:Create(root, TweenInfo.new(dur, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetQPos)})
							CurrentTween:Play()
							task.wait(dur)
						end
						interactWithQuest(root, qPart)
					end
				end

				local mainEnemy, eRoot, eHum = getNearestEnemy(root.Position, myLvl)
				if not farmTargetModel(char, root, mainEnemy, eRoot, eHum, "Lv." .. tostring(myLvl) .. " | Farm", Color3.fromRGB(74, 222, 128)) then
					StatusLabel.Text = "●  Lv." .. tostring(myLvl) .. " | Searching Level Mobs..."
					StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
				end
			end)
		else
			pcall(function()
				local enemiesFolder = Workspace:FindFirstChild("Enemies")
				if enemiesFolder then
					for _, enemy in ipairs(enemiesFolder:GetChildren()) do
						local eRoot = enemy:FindFirstChild("HumanoidRootPart")
						if eRoot and eRoot.Anchored then
							eRoot.Anchored = false
						end
					end
				end
			end)
		end
	end
end)

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
		task.wait(0.12)
		if AutoAttackSeaEnabled then
			pcall(function()
				local myChar = LocalPlayer.Character
				local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
				if myRoot then
					for model, esp in pairs(TrackedNPCs) do
						if model and model.Parent and esp and esp.Root and esp.Humanoid and esp.Humanoid.Health > 0 then
							if isSeaEvent(model.Name) then
								local dist = (myRoot.Position - esp.Root.Position).Magnitude
								if dist < 250 then
									ensureEquippedIfNone()
									triggerHit(myChar)
									break
								end
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
		task.wait(0.12)
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
					local travelTime = math.clamp(dist / math.max(FlySpeed, 120), 0.04, 12)

					if CurrentTween then
						pcall(function() CurrentTween:Cancel() end)
					end
					CurrentTween = TweenService:Create(root, TweenInfo.new(travelTime, Enum.EasingStyle.Linear), {CFrame = goalCF})
					CurrentTween:Play()

					local startTime = tick()
					while ScriptRunning and AutoChestEnabled and isValidChestPart(targetChest) and (tick() - startTime) < (travelTime + 0.4) do
						root.AssemblyLinearVelocity = Vector3.zero
						task.wait(0.05)
					end

					if CurrentTween then
						pcall(function() CurrentTween:Cancel() end)
						CurrentTween = nil
					end
					if isValidChestPart(targetChest) then
						root.CFrame = goalCF
						root.AssemblyLinearVelocity = Vector3.zero
						task.wait(0.18)
					end
				else
					StatusLabel.Text = "●  Auto Chest: Scanning Entire Map..."
					StatusLabel.TextColor3 = Color3.fromRGB(250, 204, 21)
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
				pcall(function()
					if data.Text then
						data.Text:Remove()
					end
				end)
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
				pcall(function()
					if data.Text then
						data.Text:Remove()
					end
				end)
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
				pcall(function()
					if data.Text then
						data.Text:Remove()
					end
				end)
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
						local tag = esp.IsSeaEvent and "[SEA EVENT] " or "[NPC] "
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

print("[NEXOARO] Loaded")
