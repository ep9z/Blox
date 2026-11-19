local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local State = {
	BoxESPEnabled = false,
	TracerESPEnabled = false,
	DistanceESPEnabled = false,
	HealthESPEnabled = false,
	BoxColor = Color3.fromRGB(168, 85, 247),
	TracerColor = Color3.fromRGB(168, 85, 247),
	NameColor = Color3.fromRGB(255, 255, 255),

	HighlightEnabled = true,
	EnemiesOnly = true,
	ShowNames = true,
	FillColor = Color3.fromRGB(168, 85, 247),
	OutlineColor = Color3.fromRGB(255, 255, 255),
	FillTransparency = 0.5,
	OutlineTransparency = 0,

	PvPEnabled = false,
	TeamCheck = true,
	AliveCheck = true,
	AimLock = true,
	AutoFaceTarget = true,
	AutoEquipTool = true,
	AutoAttack = true,
	Prediction = true,
	PredictionMultiplier = 0.135,
	AimSmoothness = 1,
	MaxDistance = 150,
	OrbitEnabled = false,
	OrbitRadius = 7,
	OrbitSpeed = 8,
	OrbitHeightOffset = 0,
	TargetPart = "HumanoidRootPart",
	AttackCooldown = 0.07,

	AutoStore = false,
	AutoGetFruit = false,
	AutoRandomFruit = false,
	FruitESPEnabled = false,
	StoreCooldown = 1,
	CollectCooldown = 0.2,
	RandomCooldown = 1.5,
	FruitKeywords = { "Fruit" },

	WalkSpeedEnabled = false,
	WalkSpeedValue = 28,
	JumpPowerEnabled = false,
	JumpPowerValue = 75,
	NoClipEnabled = false,
	InfiniteJumpEnabled = false,
	AutoRespawn = false,
	AntiAFKEnabled = true,
	TeleportTargetName = ""
}

local DrawingESP = {}
local ESPEntries = {}
local ESPGlobalConnections = {}
local FruitESPObjects = {}
local LastAttackTime = 0
local OrbitAngle = 0
local LastStore = 0
local LastCollect = 0
local LastRandom = 0
local SavedDeathCFrame = nil

local function GetCharacter(plr)
	return plr and plr.Character
end

local function GetHumanoid(char)
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot(char)
	return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"))
end

local function IsAlive(plr)
	local char = GetCharacter(plr)
	local hum = GetHumanoid(char)
	local root = GetRoot(char)
	return char ~= nil and hum ~= nil and root ~= nil and hum.Health > 0
end

local function IsEnemy(plr)
	if plr == LocalPlayer then return false end
	if not State.TeamCheck and not State.EnemiesOnly then return true end
	if LocalPlayer.Neutral or plr.Neutral then return true end
	if LocalPlayer.Team and plr.Team then
		return LocalPlayer.Team ~= plr.Team
	end
	return true
end

local function CreateDrawingESP(player)
	if player == LocalPlayer or DrawingESP[player] or typeof(Drawing) ~= "table" then return end

	local box = Drawing.new("Square")
	box.Visible = false
	box.Color = State.BoxColor
	box.Thickness = 1.5
	box.Filled = false

	local tracer = Drawing.new("Line")
	tracer.Visible = false
	tracer.Color = State.TracerColor
	tracer.Thickness = 1

	local distTag = Drawing.new("Text")
	distTag.Visible = false
	distTag.Color = State.NameColor
	distTag.Size = 13
	distTag.Center = true
	distTag.Outline = true

	local hpTag = Drawing.new("Text")
	hpTag.Visible = false
	hpTag.Color = Color3.fromRGB(192, 132, 252)
	hpTag.Size = 12
	hpTag.Center = true
	hpTag.Outline = true

	DrawingESP[player] = {
		Box = box,
		Tracer = tracer,
		Dist = distTag,
		HP = hpTag
	}
end

local function RemoveDrawingESP(player)
	local data = DrawingESP[player]
	if data then
		pcall(function()
			data.Box:Remove()
			data.Tracer:Remove()
			data.Dist:Remove()
			data.HP:Remove()
		end)
		DrawingESP[player] = nil
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	CreateDrawingESP(player)
end

Players.PlayerAdded:Connect(CreateDrawingESP)
Players.PlayerRemoving:Connect(RemoveDrawingESP)

local function ClearPlayerESP(player)
	local entry = ESPEntries[player]
	if entry then
		for _, conn in ipairs(entry.Connections) do
			conn:Disconnect()
		end
		if entry.Highlight then
			entry.Highlight:Destroy()
		end
		if entry.Billboard then
			entry.Billboard:Destroy()
		end
		ESPEntries[player] = nil
	end
end

local function CreateBillboard(character, playerName)
	local head = character:FindFirstChild("Head") or GetRoot(character)
	if not head then return nil end

	local gui = Instance.new("BillboardGui")
	gui.Name = "NexoaroNameTag"
	gui.Adornee = head
	gui.Size = UDim2.new(0, 150, 0, 28)
	gui.StudsOffset = Vector3.new(0, 2.3, 0)
	gui.AlwaysOnTop = true
	gui.Parent = gethui and gethui() or CoreGui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = playerName
	label.TextColor3 = State.NameColor
	label.TextStrokeColor3 = State.FillColor
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextSize = 14
	label.Parent = gui

	return gui
end

local function ApplyESP(player, character)
	local entry = ESPEntries[player]
	if not entry then return end

	if entry.Highlight then
		entry.Highlight:Destroy()
		entry.Highlight = nil
	end
	if entry.Billboard then
		entry.Billboard:Destroy()
		entry.Billboard = nil
	end

	if not State.HighlightEnabled or not character then return end
	if State.EnemiesOnly and not IsEnemy(player) then return end

	local hl = Instance.new("Highlight")
	hl.Name = "NexoaroHighlight"
	hl.Adornee = character
	hl.FillColor = State.FillColor
	hl.OutlineColor = State.OutlineColor
	hl.FillTransparency = State.FillTransparency
	hl.OutlineTransparency = State.OutlineTransparency
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = gethui and gethui() or CoreGui

	entry.Highlight = hl
	if State.ShowNames then
		entry.Billboard = CreateBillboard(character, player.Name)
	end
end

local function RefreshAllESP()
	for player in pairs(ESPEntries) do
		ApplyESP(player, player.Character)
	end
end

local function TrackPlayerESP(player)
	if player == LocalPlayer then return end
	ClearPlayerESP(player)

	ESPEntries[player] = {
		Highlight = nil,
		Billboard = nil,
		Connections = {}
	}

	if player.Character then
		ApplyESP(player, player.Character)
	end

	table.insert(ESPEntries[player].Connections, player.CharacterAdded:Connect(function(char)
		ApplyESP(player, char)
	end))

	table.insert(ESPEntries[player].Connections, player.CharacterRemoving:Connect(function()
		if ESPEntries[player] then
			if ESPEntries[player].Highlight then
				ESPEntries[player].Highlight:Destroy()
				ESPEntries[player].Highlight = nil
			end
			if ESPEntries[player].Billboard then
				ESPEntries[player].Billboard:Destroy()
				ESPEntries[player].Billboard = nil
			end
		end
	end))

	table.insert(ESPEntries[player].Connections, player:GetPropertyChangedSignal("Team"):Connect(function()
		ApplyESP(player, player.Character)
	end))

	table.insert(ESPEntries[player].Connections, player:GetPropertyChangedSignal("Neutral"):Connect(function()
		ApplyESP(player, player.Character)
	end))
end

for _, player in ipairs(Players:GetPlayers()) do
	TrackPlayerESP(player)
end

table.insert(ESPGlobalConnections, Players.PlayerAdded:Connect(TrackPlayerESP))
table.insert(ESPGlobalConnections, Players.PlayerRemoving:Connect(ClearPlayerESP))
table.insert(ESPGlobalConnections, LocalPlayer:GetPropertyChangedSignal("Team"):Connect(RefreshAllESP))
table.insert(ESPGlobalConnections, LocalPlayer:GetPropertyChangedSignal("Neutral"):Connect(RefreshAllESP))

local function GetPredictedPosition(targetRoot)
	local pos = targetRoot.Position
	if State.Prediction then
		pos = pos + (targetRoot.AssemblyLinearVelocity * State.PredictionMultiplier)
	end
	return pos
end

local function GetBestTarget()
	local myChar = GetCharacter(LocalPlayer)
	local myRoot = GetRoot(myChar)
	if not myRoot then return nil end

	local bestTarget = nil
	local bestScore = math.huge
	local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, plr in ipairs(Players:GetPlayers()) do
		if IsEnemy(plr) and (not State.AliveCheck or IsAlive(plr)) then
			local char = GetCharacter(plr)
			local root = char and (char:FindFirstChild(State.TargetPart) or GetRoot(char))
			if root then
				local dist = (root.Position - myRoot.Position).Magnitude
				if dist <= State.MaxDistance then
					local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
					local screenDist = onScreen and (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude or (dist * 10)
					local score = dist + (screenDist * 0.15)
					if score < bestScore then
						bestScore = score
						bestTarget = {
							Player = plr,
							Character = char,
							Root = root,
							Distance = dist
						}
					end
				end
			end
		end
	end

	return bestTarget
end

local function EquipWeapon()
	if not State.AutoEquipTool then return end
	local char = GetCharacter(LocalPlayer)
	local hum = GetHumanoid(char)
	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	if not char or not hum or not backpack then return end

	if char:FindFirstChildOfClass("Tool") then return end

	for _, item in ipairs(backpack:GetChildren()) do
		if item:IsA("Tool") then
			hum:EquipTool(item)
			break
		end
	end
end

local function TriggerAttack()
	if not State.AutoAttack then return end
	local now = os.clock()
	if now - LastAttackTime < State.AttackCooldown then return end
	LastAttackTime = now

	local char = GetCharacter(LocalPlayer)
	local tool = char and char:FindFirstChildOfClass("Tool")
	if tool then
		pcall(function()
			tool:Activate()
		end)
	end

	if typeof(mouse1press) == "function" and typeof(mouse1release) == "function" then
		pcall(function()
			mouse1press()
			task.delay(0.02, function()
				pcall(mouse1release)
			end)
		end)
	elseif typeof(mouse1click) == "function" then
		pcall(mouse1click)
	end
end

local function UpdateMovement(myRoot, targetRoot, dt)
	if not State.OrbitEnabled or not myRoot or not targetRoot then return end
	OrbitAngle = (OrbitAngle + State.OrbitSpeed * dt) % (math.pi * 2)
	local offset = Vector3.new(
		math.cos(OrbitAngle) * State.OrbitRadius,
		State.OrbitHeightOffset,
		math.sin(OrbitAngle) * State.OrbitRadius
	)
	local desiredPos = targetRoot.Position + offset
	myRoot.CFrame = CFrame.lookAt(desiredPos, Vector3.new(targetRoot.Position.X, desiredPos.Y, targetRoot.Position.Z))
end

local function IsFruitTool(item)
	if not item or not item:IsA("Tool") then return false end
	if item:GetAttribute("OriginalName") or item:FindFirstChild("Fruit") then
		return true
	end
	local lower = string.lower(item.Name)
	for _, kw in ipairs(State.FruitKeywords) do
		if string.find(lower, string.lower(kw), 1, true) then
			return true
		end
	end
	return false
end

local function IsGroundFruit(obj)
	if not obj then return nil end
	if obj:IsA("Tool") then
		local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
		if handle and obj.Parent and not obj.Parent:IsA("Backpack") and not obj.Parent:FindFirstChildOfClass("Humanoid") then
			return handle, obj.Name
		end
	elseif obj:IsA("Model") then
		local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
		local lower = string.lower(obj.Name)
		if primary and (string.find(lower, "fruit", 1, true) or obj:FindFirstChildWhichIsA("TouchTransmitter", true) or obj:FindFirstChildWhichIsA("ProximityPrompt", true)) then
			return primary, obj.Name
		end
	elseif obj:IsA("BasePart") then
		local lower = string.lower(obj.Name)
		if string.find(lower, "fruit", 1, true) and obj.Parent and not obj.Parent:FindFirstChildOfClass("Humanoid") then
			return obj, obj.Name
		end
	end
	return nil
end

local function FindRemotes()
	local remotes = {}
	for _, container in ipairs({ ReplicatedStorage, Workspace }) do
		for _, desc in ipairs(container:GetDescendants()) do
			if desc:IsA("RemoteFunction") or desc:IsA("RemoteEvent") then
				local n = string.lower(desc.Name)
				if string.find(n, "store", 1, true) or string.find(n, "fruit", 1, true) or string.find(n, "gacha", 1, true) or string.find(n, "random", 1, true) or string.find(n, "commf", 1, true) then
					table.insert(remotes, desc)
				end
			end
		end
	end
	return remotes
end

local CachedRemotes = FindRemotes()

local function TryStoreFruit(tool)
	if not tool or not IsFruitTool(tool) then return end
	local hum = GetHumanoid(LocalPlayer.Character)
	if hum and tool.Parent ~= LocalPlayer.Character then
		pcall(function()
			hum:EquipTool(tool)
		end)
		task.wait(0.1)
	end

	local fruitName = tool:GetAttribute("OriginalName") or string.gsub(tool.Name, "%s*Fruit%s*$", "")
	for _, remote in ipairs(CachedRemotes) do
		local n = string.lower(remote.Name)
		if string.find(n, "store", 1, true) or string.find(n, "commf", 1, true) then
			if remote:IsA("RemoteFunction") then
				pcall(function()
					remote:InvokeServer("StoreFruit", fruitName, tool)
					remote:InvokeServer("Store", fruitName, tool)
					remote:InvokeServer(fruitName)
				end)
			elseif remote:IsA("RemoteEvent") then
				pcall(function()
					remote:FireServer("StoreFruit", fruitName, tool)
					remote:FireServer("Store", fruitName, tool)
					remote:FireServer(fruitName)
				end)
			end
		end
	end
end

local function AutoStoreFruits()
	if not State.AutoStore then return end
	local now = os.clock()
	if now - LastStore < State.StoreCooldown then return end
	LastStore = now

	local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
	local char = LocalPlayer.Character
	if backpack then
		for _, item in ipairs(backpack:GetChildren()) do
			if IsFruitTool(item) then
				TryStoreFruit(item)
			end
		end
	end
	if char then
		for _, item in ipairs(char:GetChildren()) do
			if IsFruitTool(item) then
				TryStoreFruit(item)
			end
		end
	end
end

local function AutoCollectFruits()
	if not State.AutoGetFruit then return end
	local now = os.clock()
	if now - LastCollect < State.CollectCooldown then return end

	local root = GetRoot(LocalPlayer.Character)
	if not root then return end

	for _, obj in ipairs(Workspace:GetDescendants()) do
		local targetPart = IsGroundFruit(obj)
		if targetPart then
			LastCollect = now
			pcall(function()
				root.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
				if typeof(firetouchinterest) == "function" then
					firetouchinterest(root, targetPart, 0)
					task.wait(0.03)
					firetouchinterest(root, targetPart, 1)
				end
				local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
				if prompt and typeof(fireproximityprompt) == "function" then
					fireproximityprompt(prompt)
				end
			end)
			break
		end
	end
end

local function AutoRollFruit()
	if not State.AutoRandomFruit then return end
	local now = os.clock()
	if now - LastRandom < State.RandomCooldown then return end
	LastRandom = now

	for _, remote in ipairs(CachedRemotes) do
		local n = string.lower(remote.Name)
		if string.find(n, "random", 1, true) or string.find(n, "gacha", 1, true) or string.find(n, "roll", 1, true) or string.find(n, "commf", 1, true) then
			if remote:IsA("RemoteFunction") then
				pcall(function()
					remote:InvokeServer("Cousin")
					remote:InvokeServer("RandomFruit")
					remote:InvokeServer("RollFruit")
					remote:InvokeServer("Gacha")
				end)
			elseif remote:IsA("RemoteEvent") then
				pcall(function()
					remote:FireServer("Cousin")
					remote:FireServer("RandomFruit")
					remote:FireServer("RollFruit")
					remote:FireServer("Gacha")
				end)
			end
		end
	end
end

local function ClearFruitESP()
	for _, tag in pairs(FruitESPObjects) do
		if tag then
			pcall(function()
				tag:Destroy()
			end)
		end
	end
	table.clear(FruitESPObjects)
end

local function UpdateFruitESP()
	ClearFruitESP()
	if not State.FruitESPEnabled then return end

	for _, obj in ipairs(Workspace:GetDescendants()) do
		local part, fruitName = IsGroundFruit(obj)
		if part and fruitName then
			local gui = Instance.new("BillboardGui")
			gui.Name = "NexoaroFruitTag"
			gui.Adornee = part
			gui.Size = UDim2.new(0, 140, 0, 24)
			gui.StudsOffset = Vector3.new(0, 2, 0)
			gui.AlwaysOnTop = true
			gui.Parent = gethui and gethui() or CoreGui

			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = fruitName
			lbl.TextColor3 = Color3.fromRGB(216, 180, 254)
			lbl.TextStrokeColor3 = Color3.fromRGB(20, 10, 35)
			lbl.TextStrokeTransparency = 0
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 13
			lbl.Parent = gui

			FruitESPObjects[obj] = gui
		end
	end
end

local function TeleportToPlayerName(partialName)
	local root = GetRoot(LocalPlayer.Character)
	if not root or partialName == "" then return end
	local lower = string.lower(partialName)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LocalPlayer then
			if string.find(string.lower(plr.Name), lower, 1, true) or string.find(string.lower(plr.DisplayName), lower, 1, true) then
				local targetRoot = GetRoot(plr.Character)
				if targetRoot then
					root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
					break
				end
			end
		end
	end
end

LocalPlayer.Idled:Connect(function()
	if State.AntiAFKEnabled then
		pcall(function()
			VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightShift, false, game)
			task.wait(0.05)
			VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightShift, false, game)
		end)
	end
end)

UserInputService.JumpRequest:Connect(function()
	if State.InfiniteJumpEnabled then
		local hum = GetHumanoid(LocalPlayer.Character)
		if hum then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

RunService.Stepped:Connect(function()
	local char = LocalPlayer.Character
	local hum = GetHumanoid(char)
	local root = GetRoot(char)

	if hum then
		if State.WalkSpeedEnabled then
			hum.WalkSpeed = State.WalkSpeedValue
		end
		if State.JumpPowerEnabled then
			hum.UseJumpPower = true
			hum.JumpPower = State.JumpPowerValue
		end
	end

	if State.NoClipEnabled and char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end

	if root and hum and hum.Health > 0 then
		SavedDeathCFrame = root.CFrame
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	if State.AutoRespawn and SavedDeathCFrame then
		task.wait(0.25)
		local root = GetRoot(char)
		if root then
			root.CFrame = SavedDeathCFrame
		end
	end
end)

local function BuildUI()
	local oldGui = (gethui and gethui() or CoreGui):FindFirstChild("NexoaroHub")
	if oldGui then oldGui:Destroy() end

	local gui = Instance.new("ScreenGui")
	gui.Name = "NexoaroHub"
	gui.ResetOnSpawn = false
	gui.Parent = gethui and gethui() or CoreGui

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 480, 0, 340)
	main.Position = UDim2.new(0.5, -240, 0.5, -170)
	main.BackgroundColor3 = Color3.fromRGB(16, 14, 24)
	main.BorderSizePixel = 0
	main.Active = true
	main.Draggable = true
	main.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = main

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(168, 85, 247)
	stroke.Thickness = 1.5
	stroke.Parent = main

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 38)
	header.BackgroundColor3 = Color3.fromRGB(24, 20, 36)
	header.BorderSizePixel = 0
	header.Parent = main

	local hCorner = Instance.new("UICorner")
	hCorner.CornerRadius = UDim.new(0, 10)
	hCorner.Parent = header

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -50, 1, 0)
	title.Position = UDim2.new(0, 14, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "NEXOARO HUB"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.TextSize = 15
	title.Parent = header

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0, 28, 0, 28)
	toggleBtn.Position = UDim2.new(1, -34, 0, 5)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
	toggleBtn.Text = "-"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 16
	toggleBtn.Parent = header

	local tCorner = Instance.new("UICorner")
	tCorner.CornerRadius = UDim.new(0, 6)
	tCorner.Parent = toggleBtn

	local body = Instance.new("Frame")
	body.Size = UDim2.new(1, 0, 1, -38)
	body.Position = UDim2.new(0, 0, 0, 38)
	body.BackgroundTransparency = 1
	body.Parent = main

	local tabsBar = Instance.new("Frame")
	tabsBar.Size = UDim2.new(0, 125, 1, -12)
	tabsBar.Position = UDim2.new(0, 8, 0, 6)
	tabsBar.BackgroundColor3 = Color3.fromRGB(22, 19, 33)
	tabsBar.BorderSizePixel = 0
	tabsBar.Parent = body

	local tbCorner = Instance.new("UICorner")
	tbCorner.CornerRadius = UDim.new(0, 8)
	tbCorner.Parent = tabsBar

	local tabsLayout = Instance.new("UIListLayout")
	tabsLayout.Padding = UDim.new(0, 6)
	tabsLayout.Parent = tabsBar

	local tabPad = Instance.new("UIPadding")
	tabPad.PaddingTop = UDim.new(0, 8)
	tabPad.PaddingLeft = UDim.new(0, 8)
	tabPad.PaddingRight = UDim.new(0, 8)
	tabPad.Parent = tabsBar

	local pagesContainer = Instance.new("Frame")
	pagesContainer.Size = UDim2.new(1, -145, 1, -12)
	pagesContainer.Position = UDim2.new(0, 139, 0, 6)
	pagesContainer.BackgroundColor3 = Color3.fromRGB(22, 19, 33)
	pagesContainer.BorderSizePixel = 0
	pagesContainer.Parent = body

	local pcCorner = Instance.new("UICorner")
	pcCorner.CornerRadius = UDim.new(0, 8)
	pcCorner.Parent = pagesContainer

	local pages = {}
	local tabButtons = {}

	local function CreateTab(name)
		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.ScrollBarThickness = 4
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = pagesContainer

		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, 7)
		list.Parent = page

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 8)
		pad.PaddingLeft = UDim.new(0, 8)
		pad.PaddingRight = UDim.new(0, 8)
		pad.PaddingBottom = UDim.new(0, 8)
		pad.Parent = page

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(32, 27, 48)
		btn.Text = name
		btn.TextColor3 = Color3.fromRGB(220, 215, 235)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.Parent = tabsBar

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = btn

		btn.MouseButton1Click:Connect(function()
			for n, p in pairs(pages) do
				p.Visible = (n == name)
			end
			for n, b in pairs(tabButtons) do
				b.BackgroundColor3 = (n == name) and Color3.fromRGB(168, 85, 247) or Color3.fromRGB(32, 27, 48)
			end
		end)

		pages[name] = page
		tabButtons[name] = btn
		return page
	end

	local function AddToggle(page, labelText, initial, callback)
		local row = Instance.new("TextButton")
		row.Size = UDim2.new(1, 0, 0, 32)
		row.BackgroundColor3 = initial and Color3.fromRGB(88, 42, 138) or Color3.fromRGB(32, 27, 48)
		row.Text = labelText .. ": " .. (initial and "ON" or "OFF")
		row.TextColor3 = Color3.fromRGB(255, 255, 255)
		row.Font = Enum.Font.GothamBold
		row.TextSize = 12
		row.Parent = page

		local rCorner = Instance.new("UICorner")
		rCorner.CornerRadius = UDim.new(0, 6)
		rCorner.Parent = row

		local state = initial
		row.MouseButton1Click:Connect(function()
			state = not state
			row.Text = labelText .. ": " .. (state and "ON" or "OFF")
			row.BackgroundColor3 = state and Color3.fromRGB(88, 42, 138) or Color3.fromRGB(32, 27, 48)
			callback(state)
		end)
	end

	local function AddButton(page, labelText, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 32)
		btn.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
		btn.Text = labelText
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.Parent = page

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = btn

		btn.MouseButton1Click:Connect(callback)
	end

	local function AddInput(page, placeholder, callback)
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1, 0, 0, 32)
		box.BackgroundColor3 = Color3.fromRGB(32, 27, 48)
		box.PlaceholderText = placeholder
		box.Text = ""
		box.TextColor3 = Color3.fromRGB(255, 255, 255)
		box.PlaceholderColor3 = Color3.fromRGB(150, 145, 170)
		box.Font = Enum.Font.Gotham
		box.TextSize = 12
		box.ClearTextOnFocus = false
		box.Parent = page

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 6)
		bCorner.Parent = box

		box.FocusLost:Connect(function()
			callback(box.Text)
		end)
	end

	local espPage = CreateTab("Highlight & ESP")
	local pvpPage = CreateTab("Auto PvP")
	local fruitPage = CreateTab("Fruits")
	local playerPage = CreateTab("Player")

	AddToggle(espPage, "Highlight ESP", State.HighlightEnabled, function(v)
		State.HighlightEnabled = v
		RefreshAllESP()
	end)
	AddToggle(espPage, "Enemies Only", State.EnemiesOnly, function(v)
		State.EnemiesOnly = v
		RefreshAllESP()
	end)
	AddToggle(espPage, "Show Names", State.ShowNames, function(v)
		State.ShowNames = v
		RefreshAllESP()
	end)
	AddToggle(espPage, "Box ESP", State.BoxESPEnabled, function(v)
		State.BoxESPEnabled = v
	end)
	AddToggle(espPage, "Tracer ESP", State.TracerESPEnabled, function(v)
		State.TracerESPEnabled = v
	end)
	AddToggle(espPage, "Distance ESP", State.DistanceESPEnabled, function(v)
		State.DistanceESPEnabled = v
	end)
	AddToggle(espPage, "Health ESP", State.HealthESPEnabled, function(v)
		State.HealthESPEnabled = v
	end)

	AddToggle(pvpPage, "Auto PvP", State.PvPEnabled, function(v)
		State.PvPEnabled = v
	end)
	AddToggle(pvpPage, "AimLock", State.AimLock, function(v)
		State.AimLock = v
	end)
	AddToggle(pvpPage, "Prediction", State.Prediction, function(v)
		State.Prediction = v
	end)
	AddToggle(pvpPage, "Auto Face Target", State.AutoFaceTarget, function(v)
		State.AutoFaceTarget = v
	end)
	AddToggle(pvpPage, "Auto Equip", State.AutoEquipTool, function(v)
		State.AutoEquipTool = v
	end)
	AddToggle(pvpPage, "Auto Attack", State.AutoAttack, function(v)
		State.AutoAttack = v
	end)
	AddToggle(pvpPage, "Orbit", State.OrbitEnabled, function(v)
		State.OrbitEnabled = v
	end)
	AddInput(pvpPage, "Orbit Radius (e.g. 7)", function(txt)
		local num = tonumber(txt)
		if num then State.OrbitRadius = num end
	end)
	AddInput(pvpPage, "Max Distance (e.g. 150)", function(txt)
		local num = tonumber(txt)
		if num then State.MaxDistance = num end
	end)

	AddToggle(fruitPage, "Auto Store Fruit", State.AutoStore, function(v)
		State.AutoStore = v
	end)
	AddToggle(fruitPage, "Auto Get Fruit", State.AutoGetFruit, function(v)
		State.AutoGetFruit = v
	end)
	AddToggle(fruitPage, "Auto Roll Fruit", State.AutoRandomFruit, function(v)
		State.AutoRandomFruit = v
	end)
	AddToggle(fruitPage, "Fruit ESP", State.FruitESPEnabled, function(v)
		State.FruitESPEnabled = v
		UpdateFruitESP()
	end)
	AddButton(fruitPage, "Refresh Remotes & Fruit ESP", function()
		CachedRemotes = FindRemotes()
		UpdateFruitESP()
	end)

	AddToggle(playerPage, "WalkSpeed", State.WalkSpeedEnabled, function(v)
		State.WalkSpeedEnabled = v
	end)
	AddInput(playerPage, "WalkSpeed Value (e.g. 28)", function(txt)
		local num = tonumber(txt)
		if num then State.WalkSpeedValue = num end
	end)
	AddToggle(playerPage, "JumpPower", State.JumpPowerEnabled, function(v)
		State.JumpPowerEnabled = v
	end)
	AddInput(playerPage, "JumpPower Value (e.g. 75)", function(txt)
		local num = tonumber(txt)
		if num then State.JumpPowerValue = num end
	end)
	AddToggle(playerPage, "NoClip", State.NoClipEnabled, function(v)
		State.NoClipEnabled = v
	end)
	AddToggle(playerPage, "Infinite Jump", State.InfiniteJumpEnabled, function(v)
		State.InfiniteJumpEnabled = v
	end)
	AddToggle(playerPage, "Auto Return on Respawn", State.AutoRespawn, function(v)
		State.AutoRespawn = v
	end)
	AddToggle(playerPage, "Anti AFK", State.AntiAFKEnabled, function(v)
		State.AntiAFKEnabled = v
	end)
	AddInput(playerPage, "Player Name to TP", function(txt)
		State.TeleportTargetName = txt
	end)
	AddButton(playerPage, "Teleport to Player", function()
		TeleportToPlayerName(State.TeleportTargetName)
	end)
	AddButton(playerPage, "Rejoin Server", function()
		pcall(function()
			TeleportService:Teleport(game.PlaceId, LocalPlayer)
		end)
	end)

	local minimized = false
	toggleBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		body.Visible = not minimized
		main.Size = minimized and UDim2.new(0, 480, 0, 38) or UDim2.new(0, 480, 0, 340)
		toggleBtn.Text = minimized and "+" or "-"
	end)

	pages["Highlight & ESP"].Visible = true
	tabButtons["Highlight & ESP"].BackgroundColor3 = Color3.fromRGB(168, 85, 247)
end

BuildUI()

RunService.RenderStepped:Connect(function(dt)
	for player, data in pairs(DrawingESP) do
		local char = GetCharacter(player)
		local root = GetRoot(char)
		local head = char and char:FindFirstChild("Head")
		local hum = GetHumanoid(char)
		local validTarget = (not State.EnemiesOnly or IsEnemy(player)) and char and root and head and hum and hum.Health > 0

		if validTarget then
			local rootPos, onScreen = Camera:WorldToViewportPoint(root.Position)
			if onScreen then
				local topPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.6, 0))
				local bottomPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
				local height = math.abs(topPos.Y - bottomPos.Y)
				local width = height * 0.6

				data.Box.Size = Vector2.new(width, height)
				data.Box.Position = Vector2.new(rootPos.X - width / 2, topPos.Y)
				data.Box.Visible = State.BoxESPEnabled

				data.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
				data.Tracer.To = Vector2.new(rootPos.X, bottomPos.Y)
				data.Tracer.Visible = State.TracerESPEnabled

				local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
				data.Dist.Text = "[" .. dist .. "m]"
				data.Dist.Position = Vector2.new(rootPos.X, bottomPos.Y + 4)
				data.Dist.Visible = State.DistanceESPEnabled

				data.HP.Text = "HP: " .. math.floor(hum.Health)
				data.HP.Position = Vector2.new(rootPos.X, topPos.Y - 15)
				data.HP.Visible = State.HealthESPEnabled
			else
				data.Box.Visible = false
				data.Tracer.Visible = false
				data.Dist.Visible = false
				data.HP.Visible = false
			end
		else
			data.Box.Visible = false
			data.Tracer.Visible = false
			data.Dist.Visible = false
			data.HP.Visible = false
		end
	end

	if not State.PvPEnabled then return end

	local myChar = GetCharacter(LocalPlayer)
	local myRoot = GetRoot(myChar)
	local myHum = GetHumanoid(myChar)
	if not myChar or not myRoot or not myHum or myHum.Health <= 0 then return end

	local target = GetBestTarget()
	if not target then return end

	local aimPos = GetPredictedPosition(target.Root)

	if State.AutoFaceTarget and not State.OrbitEnabled then
		local lookPos = Vector3.new(aimPos.X, myRoot.Position.Y, aimPos.Z)
		myRoot.CFrame = CFrame.lookAt(myRoot.Position, lookPos)
	end

	UpdateMovement(myRoot, target.Root, dt)

	if State.AimLock and Camera then
		local desiredCam = CFrame.lookAt(Camera.CFrame.Position, aimPos)
		if State.AimSmoothness >= 1 then
			Camera.CFrame = desiredCam
		else
			Camera.CFrame = Camera.CFrame:Lerp(desiredCam, math.clamp(State.AimSmoothness, 0.01, 1))
		end
	end

	EquipWeapon()
	TriggerAttack()
end)

RunService.Heartbeat:Connect(function()
	AutoCollectFruits()
	AutoStoreFruits()
	AutoRollFruit()
end)
