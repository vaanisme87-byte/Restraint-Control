local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- =========================================================
-- REMOTES: ACCESSING RESTRAINT SYSTEM EVENTS
-- =========================================================
local RestraintEvents = ReplicatedStorage:WaitForChild("Restraint System"):WaitForChild("Events")
local ActionRemote = RestraintEvents:WaitForChild("Action")
local GUIRemote = RestraintEvents:WaitForChild("GUI")

local TargetPlayer = nil
local TargetAll = false
local LoopTieActive = false
local IsProcessingTie = false

-- =========================================================
-- PERSISTENT TRACKING & ANTI-REJOIN LOGIC
-- =========================================================
local AntiRejoinActive = false
local LockedTargetUserId = nil
local LockedTargetName = "None"

-- =========================================================
-- BLACKLIST CONFIGURATION (TOTAL: 22)
-- =========================================================
local blacklist = {
    ["Causa21546"] = true,
    ["114514u060"] = true,
    ["chineseikun0"] = true,
    ["NMGBVO2"] = true,
    ["45TVT4531"] = true,
    ["JIAUH3"] = true,
    ["SIeepy_haIosss"] = true,
    ["qweavsgs"] = true,
    ["Dark_angel7473"] = true,
    ["YASSER_ostora10K"] = true,
    ["gigizcc"] = true,
    ["Sickboyundertale"] = true,
    ["brunogmer8436"] = true,
    ["polkyutw"] = true,
    ["shiestymark127"] = true,
    ["guest826_7"] = true,
    ["qwr123034"] = true,
    ["uknlodinroun43434"] = true,
    ["MC6662022"] = true,
    ["lucianogamer123123"] = true,
    ["VIPTubers9347RinNAH"] = true,
    ["qqqqqppppvvvv4"] = true,
}

local blacklistedProcessed = {} 
local blacklistedDetected = {}  

-- =========================================================
-- GUI SETUP & COSMETICS
-- =========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RestraintControl_Sky"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 2147483647 
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 260, 0.4, 0)
NotifContainer.Position = UDim2.new(1, -270, 0.95, 0)
NotifContainer.AnchorPoint = Vector2.new(0, 1)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotifContainer

-- =========================================================
-- NOTIFICATION SYSTEM (PRESERVING X BUTTONS)
-- =========================================================
local function NotifyBlacklist(playerName)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 70)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifContainer
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)

    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 0, 0, 2)
    Glow.Position = UDim2.new(0, 0, 1, -2)
    Glow.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Glow.BorderSizePixel = 0
    Glow.Parent = NotifFrame
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "Blacklisted Player Detected"
    Title.TextColor3 = Color3.fromRGB(255, 70, 70)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = NotifFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -10, 0, 25)
    NameLabel.Position = UDim2.new(0, 10, 0, 30)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = playerName
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = NotifFrame

    local CloseX = Instance.new("TextButton")
    CloseX.Size = UDim2.new(0, 22, 0, 22)
    CloseX.Position = UDim2.new(1, -28, 0, 8)
    CloseX.BackgroundTransparency = 1
    CloseX.Text = "X"
    CloseX.TextColor3 = Color3.fromRGB(150, 150, 150)
    CloseX.Font = Enum.Font.GothamBold
    CloseX.TextSize = 14
    CloseX.Parent = NotifFrame
    CloseX.MouseButton1Click:Connect(function() NotifFrame:Destroy() end)

    task.spawn(function()
        NotifFrame.Position = UDim2.new(1.5, 0, 0, 0)
        TweenService:Create(NotifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
        task.wait(6)
        if NotifFrame and NotifFrame.Parent then
            local t = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, 0)})
            t:Play()
            t.Completed:Wait()
            NotifFrame:Destroy()
        end
    end)
end

local function NotifyBlacklistLeft(playerName)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 70)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifContainer
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)

    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 0, 0, 2)
    Glow.Position = UDim2.new(0, 0, 1, -2)
    Glow.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Glow.BorderSizePixel = 0
    Glow.Parent = NotifFrame
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "Blacklisted Player Left lol"
    Title.TextColor3 = Color3.fromRGB(255, 70, 70)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = NotifFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -10, 0, 25)
    NameLabel.Position = UDim2.new(0, 10, 0, 30)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = playerName
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = NotifFrame

    local CloseX = Instance.new("TextButton")
    CloseX.Size = UDim2.new(0, 22, 0, 22)
    CloseX.Position = UDim2.new(1, -28, 0, 8)
    CloseX.BackgroundTransparency = 1
    CloseX.Text = "X"
    CloseX.TextColor3 = Color3.fromRGB(150, 150, 150)
    CloseX.Font = Enum.Font.GothamBold
    CloseX.TextSize = 14
    CloseX.Parent = NotifFrame
    CloseX.MouseButton1Click:Connect(function() NotifFrame:Destroy() end)

    task.spawn(function()
        NotifFrame.Position = UDim2.new(1.5, 0, 0, 0)
        TweenService:Create(NotifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
        task.wait(6)
        if NotifFrame and NotifFrame.Parent then
            local t = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, 0)})
            t:Play()
            t.Completed:Wait()
            NotifFrame:Destroy()
        end
    end)
end

local function NotifyWelcome(playerName)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 70)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifContainer
    Instance.new("UICorner", NotifFrame).CornerRadius = UDim.new(0, 8)

    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 0, 0, 2)
    Glow.Position = UDim2.new(0, 0, 1, -2)
    Glow.BackgroundColor3 = Color3.fromRGB(0, 191, 255) 
    Glow.BorderSizePixel = 0
    Glow.Parent = NotifFrame
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -40, 0, 30)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = "Hello Thanks For Using Sky's Gui"
    Title.TextColor3 = Color3.fromRGB(0, 191, 255) 
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = NotifFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -10, 0, 25)
    NameLabel.Position = UDim2.new(0, 10, 0, 30)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = playerName
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255) 
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = NotifFrame

    local CloseX = Instance.new("TextButton")
    CloseX.Size = UDim2.new(0, 22, 0, 22)
    CloseX.Position = UDim2.new(1, -28, 0, 8)
    CloseX.BackgroundTransparency = 1
    CloseX.Text = "X"
    CloseX.TextColor3 = Color3.fromRGB(150, 150, 150)
    CloseX.Font = Enum.Font.GothamBold
    CloseX.TextSize = 14
    CloseX.Parent = NotifFrame
    CloseX.MouseButton1Click:Connect(function() NotifFrame:Destroy() end)

    task.spawn(function()
        NotifFrame.Position = UDim2.new(1.5, 0, 0, 0)
        TweenService:Create(NotifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
        task.wait(6)
        if NotifFrame and NotifFrame.Parent then
            local t = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, 0)})
            t:Play()
            t.Completed:Wait()
            NotifFrame:Destroy()
        end
    end)
end

NotifyWelcome(LocalPlayer.Name)

-- =========================================================
-- [AGGRESSIVE DEEP SEARCH DETECTION]
-- =========================================================
local function checkState(char, stateName)
    if not char then return false end
    if char:GetAttribute(stateName) ~= nil then return char:GetAttribute(stateName) end
    
    local target = string.lower(stateName)
    for _, obj in pairs(char:GetDescendants()) do
        local objName = string.lower(obj.Name)
        
        if objName == target or objName == target.."d" or objName == target.."n" then
            if obj:IsA("BoolValue") then return obj.Value end
            if obj:IsA("StringValue") then return obj.Value ~= "" and obj.Value ~= "None" end
            if obj:IsA("Model") or obj:IsA("Folder") then return true end
        end
        
        if target == "rope" or target == "tied" then
            if obj:IsA("RopeConstraint") and obj.Enabled then return true end
            if (obj:IsA("Constraint") or obj:IsA("JointInstance")) and string.find(objName, "rope") then return true end
            if obj:IsA("BasePart") and string.find(objName, "rope") and obj.Transparency < 1 then return true end
        end
    end
    return false
end

local function FireRestraintSequence(char)
    if not char or IsProcessingTie then return end
    IsProcessingTie = true
    ActionRemote:FireServer("Kneel", "Metal Cuffs", char)
    ActionRemote:FireServer("Pin", "Metal Cuffs", char)
    ActionRemote:FireServer("Rope", "Rope", char)
    ActionRemote:FireServer("Muffle", "Muffler", char)
    ActionRemote:FireServer("Blindfold", "Blindfold", char)
    ActionRemote:FireServer("Blindfold", "Hood", char)
    GUIRemote:InvokeServer("Add", char)
    ActionRemote:FireServer("Detain", "Metal Cuffs", char)
    task.spawn(function()
        local timeout = 0
        repeat task.wait(0.5) timeout = timeout + 1 until (checkState(char, "Rope") or checkState(char, "Tied") or timeout > 10 or not (LoopTieActive or AntiRejoinActive))
        IsProcessingTie = false
    end)
end

-- =========================================================
-- [FIXED: SINGLE LINE ESP FORMATTING]
-- =========================================================
local function CreateESP(player)
    if player == LocalPlayer then return end
    local function ApplyESP(character)
        local head = character:WaitForChild("Head", 10)
        local humanoid = character:WaitForChild("Humanoid", 10)
        if not head or not humanoid then return end

        local bGui = Instance.new("BillboardGui", head)
        bGui.Name = "SkyESP_V2"
        bGui.Adornee = head
        bGui.Size = UDim2.new(0, 400, 0, 30)
        bGui.StudsOffset = Vector3.new(0, 3.5, 0)
        bGui.AlwaysOnTop = true

        local label = Instance.new("TextLabel", bGui)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0.5
        label.Font = Enum.Font.GothamBold
        label.TextSize = 14
        label.RichText = true

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not character.Parent or not head.Parent or not humanoid or humanoid.Health <= 0 or not _G.SkyESP_Active then
                if bGui then bGui:Destroy() end
                connection:Disconnect()
                return
            end
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local dist = math.floor((hrp and (hrp.Position - head.Position).Magnitude) or 0)
            -- Format: Name | Health❤️: Value | Studs : Distance
            label.Text = string.format('<font color="rgb(0, 191, 255)">%s</font> | <font color="rgb(255, 50, 50)">Health❤️: %d</font> | Studs : %d', player.Name, math.floor(humanoid.Health), dist)
        end)
    end
    if player.Character then ApplyESP(player.Character) end
    player.CharacterAdded:Connect(ApplyESP)
end

local function ToggleESP()
    _G.SkyESP_Active = not _G.SkyESP_Active
    if _G.SkyESP_Active then
        for _, player in pairs(Players:GetPlayers()) do CreateESP(player) end
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character and player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("SkyESP_V2") then
                player.Character.Head.SkyESP_V2:Destroy()
            end
        end
    end
end

-- =========================================================
-- STATUS & CONTROL FRAMES
-- =========================================================
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0, 220, 0, 195)
StatusFrame.Position = UDim2.new(1, -230, 0, 10)
StatusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
StatusFrame.BackgroundTransparency = 0.2
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = ScreenGui
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 8)

local StatusTitle = Instance.new("TextLabel")
StatusTitle.Size = UDim2.new(1, -30, 0, 25)
StatusTitle.Position = UDim2.new(0, 5, 0, 0)
StatusTitle.BackgroundTransparency = 1
StatusTitle.Text = "TARGET STATUS"
StatusTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusTitle.Font = Enum.Font.GothamBold
StatusTitle.TextSize = 14
StatusTitle.Parent = StatusFrame

local StatusText = Instance.new("TextLabel")
StatusText.Size = UDim2.new(1, -20, 1, -30)
StatusText.Position = UDim2.new(0, 10, 0, 25)
StatusText.BackgroundTransparency = 1
StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusText.Font = Enum.Font.Code
StatusText.TextSize = 14
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextYAlignment = Enum.TextYAlignment.Top
StatusText.Text = "Please select a player..."
StatusText.Parent = StatusFrame

local TrackerMinBtn = Instance.new("TextButton")
TrackerMinBtn.Size = UDim2.new(0, 20, 0, 20)
TrackerMinBtn.Position = UDim2.new(1, -25, 0, 5)
TrackerMinBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
TrackerMinBtn.Text = "-"
TrackerMinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrackerMinBtn.Font = Enum.Font.GothamBold
TrackerMinBtn.Parent = StatusFrame
Instance.new("UICorner", TrackerMinBtn).CornerRadius = UDim.new(0, 4)

local TrackerMinimized = false
TrackerMinBtn.MouseButton1Click:Connect(function()
    TrackerMinimized = not TrackerMinimized
    StatusFrame.BackgroundTransparency = TrackerMinimized and 1 or 0.2
    StatusTitle.Visible = not TrackerMinimized
    StatusText.Visible = not TrackerMinimized
    TrackerMinBtn.Text = TrackerMinimized and "+" or "-"
end)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 280)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true 
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -110, 0, 40)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "  RESTRAINT CONTROL By Sky!"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 13
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.Parent = MainFrame

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = MainFrame
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 5)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = MainFrame
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

-- =========================================================
-- SEARCH BAR [FIXED GAP]
-- =========================================================
local SearchBar = Instance.new("TextBox")
SearchBar.Name = "SearchBar"
SearchBar.Size = UDim2.new(1, 0, 0, 25) 
SearchBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
SearchBar.BorderSizePixel = 0
SearchBar.PlaceholderText = "Search Player..."
SearchBar.Text = ""
SearchBar.TextColor3 = Color3.new(1, 1, 1)
SearchBar.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
SearchBar.Font = Enum.Font.Gotham
SearchBar.TextSize = 12
Instance.new("UICorner", SearchBar).CornerRadius = UDim.new(0, 4)

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.4, -10, 1, -50)
PlayerList.Position = UDim2.new(0, 5, 0, 45)
PlayerList.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 2
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.Parent = MainFrame
local PListL = Instance.new("UIListLayout", PlayerList)
PListL.Padding = UDim.new(0, 2)
PListL.SortOrder = Enum.SortOrder.LayoutOrder

local ActionsFrame = Instance.new("ScrollingFrame")
ActionsFrame.Size = UDim2.new(0.6, -5, 1, -50)
ActionsFrame.Position = UDim2.new(0.4, 0, 0, 45)
ActionsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ActionsFrame.BorderSizePixel = 0
ActionsFrame.ScrollBarThickness = 2
ActionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ActionsFrame.Parent = MainFrame
local ActionListLayout = Instance.new("UIListLayout", ActionsFrame)
ActionListLayout.Padding = UDim.new(0, 5)
ActionListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- =========================================================
-- WATCHDOGS & LOOPS
-- =========================================================
local function FireBlacklistRestraintOnce(player)
    if not player.Character or blacklistedProcessed[player.UserId] then return end
    local char = player.Character
    ActionRemote:FireServer("Kneel", "Metal Cuffs", char)
    ActionRemote:FireServer("Pin", "Metal Cuffs", char)
    ActionRemote:FireServer("Blindfold", "Blindfold", char)
    ActionRemote:FireServer("Blindfold", "Hood", char)
    ActionRemote:FireServer("Rope", "Rope", char)
    GUIRemote:InvokeServer("Add", char)
    ActionRemote:FireServer("Detain", "Metal Cuffs", char)
    blacklistedProcessed[player.UserId] = true
end

local function HandleBlacklistedPlayer(player)
    if not blacklist[player.Name] or blacklistedDetected[player.UserId] then return end
    blacklistedDetected[player.UserId] = true 
    NotifyBlacklist(player.Name)
    blacklistedProcessed[player.UserId] = false
    player.CharacterAdded:Connect(function(char)
        blacklistedProcessed[player.UserId] = false
        task.wait(1)
        FireBlacklistRestraintOnce(player)
    end)
    if player.Character then task.wait(1) FireBlacklistRestraintOnce(player) end
end

task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do HandleBlacklistedPlayer(p) end
        task.wait(1)
    end
end)

Players.PlayerRemoving:Connect(function(plr) 
    if blacklist[plr.Name] then
        NotifyBlacklistLeft(plr.Name)
        blacklistedDetected[plr.UserId] = nil 
        blacklistedProcessed[plr.UserId] = nil
    end
    if TargetPlayer == plr and not AntiRejoinActive then TargetPlayer = nil LoopTieActive = false end 
    UpdateList() 
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        local activeChar = nil
        if AntiRejoinActive and LockedTargetUserId then
            for _, p in pairs(Players:GetPlayers()) do
                if p.UserId == LockedTargetUserId then activeChar = p.Character break end
            end
        elseif LoopTieActive and TargetPlayer and TargetPlayer.Character then
            activeChar = TargetPlayer.Character
        end
        if activeChar then
            local isDetained = checkState(activeChar, "Detained") or checkState(activeChar, "Cuffed")
            local isRoped = checkState(activeChar, "Rope") or checkState(activeChar, "Tied")
            if not isDetained and not isRoped then FireRestraintSequence(activeChar) end
        end
    end
end)

-- =========================================================
-- ACTION BUTTON SYSTEM [PRESERVING COLLAR & HOOD FIXES]
-- =========================================================
local function GetTargets()
    if TargetAll then
        local t = {}
        for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(t, p) end end
        return t
    elseif TargetPlayer then return {TargetPlayer} end
    return {}
end

local function CreateActionButton(text, tool, action, color)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 30)
    Btn.BackgroundColor3 = color or Color3.fromRGB(50, 50, 60)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 12
    Btn.Parent = ActionsFrame
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    Btn.MouseButton1Click:Connect(function()
        if action == "Attach" then
            ActionRemote:FireServer("Attach", "Collar", workspace:WaitForChild("Pole"))
            return
        end
        local targets = GetTargets()
        for _, p in pairs(targets) do
            if p.Character then
                if action == "Detain" then
                    GUIRemote:InvokeServer("Add", p.Character)
                    ActionRemote:FireServer("Detain", tool, p.Character)
                else
                    ActionRemote:FireServer(action, tool, p.Character)
                end
            end
        end
    end)
end

CreateActionButton("Arrest (Cuffs)", "Metal Cuffs", "ArrestPrompt")
CreateActionButton("Detain", "Metal Cuffs", "Detain")
CreateActionButton("Grab", "Metal Cuffs", "Grab")
CreateActionButton("Pin", "Metal Cuffs", "Pin")
CreateActionButton("Kneel", "Metal Cuffs", "Kneel")
CreateActionButton("Carry", "Rope", "Carry")
CreateActionButton("Rope", "Rope", "Rope")
CreateActionButton("Collar", "Collar", "Collar")
CreateActionButton("Chain (Collar)", "Collar", "Chain")
CreateActionButton("Attach (Collar)", "Collar", "Attach")
CreateActionButton("Muffle", "Muffler", "Muffle")
CreateActionButton("Hood", "Hood", "Blindfold")
CreateActionButton("Blindfold", "Blindfold", "Blindfold")

-- =========================================================
-- LIST MANAGEMENT
-- =========================================================
function UpdateList()
    for _, child in pairs(PlayerList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local searchText = string.lower(SearchBar.Text)

    local function CreateMenuBtn(txt, active, callback, order)
        local AllBtn = Instance.new("TextButton")
        AllBtn.Size = UDim2.new(1, 0, 0, 30)
        AllBtn.BackgroundColor3 = active and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(45, 45, 50)
        AllBtn.Text = txt
        AllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        AllBtn.Font = Enum.Font.GothamBold
        AllBtn.TextSize = 10
        AllBtn.LayoutOrder = order
        AllBtn.Parent = PlayerList
        AllBtn.MouseButton1Click:Connect(callback)
    end

    CreateMenuBtn("TARGET EVERYONE", TargetAll, function()
        TargetAll = not TargetAll TargetPlayer = nil LoopTieActive = false AntiRejoinActive = false UpdateList()
    end, 1)
    CreateMenuBtn("LOOP TIE", LoopTieActive, function()
        if TargetPlayer then LoopTieActive = not LoopTieActive TargetAll = false UpdateList() end
    end, 2)
    CreateMenuBtn("ANTI REJOIN TIE", AntiRejoinActive, function()
        if TargetPlayer and TargetPlayer ~= LocalPlayer then
            AntiRejoinActive = not AntiRejoinActive
            LockedTargetUserId = AntiRejoinActive and TargetPlayer.UserId or nil
            LockedTargetName = AntiRejoinActive and TargetPlayer.Name or "None"
            UpdateList()
        elseif not TargetPlayer and AntiRejoinActive then AntiRejoinActive = false LockedTargetUserId = nil UpdateList() end
    end, 3)
    CreateMenuBtn("SELF TARGET", TargetPlayer == LocalPlayer, function()
        TargetAll = false AntiRejoinActive = false if TargetPlayer == LocalPlayer then TargetPlayer = nil LoopTieActive = false else TargetPlayer = LocalPlayer end UpdateList()
    end, 4)

    SearchBar.Parent = PlayerList
    SearchBar.LayoutOrder = 5
    CreateMenuBtn("ESP", _G.SkyESP_Active, function() ToggleESP() UpdateList() end, 6)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local pNameLower = string.lower(p.Name)
            local isMatch = (searchText ~= "" and string.find(pNameLower, searchText))
            local PBtn = Instance.new("TextButton")
            PBtn.Size = UDim2.new(1, 0, 0, 25)
            PBtn.BackgroundColor3 = (not TargetAll and TargetPlayer == p) and Color3.fromRGB(60, 100, 200) or Color3.fromRGB(35, 35, 40)
            PBtn.Text = p.Name
            PBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            PBtn.Font = Enum.Font.Gotham
            PBtn.TextSize = 11
            PBtn.Parent = PlayerList
            PBtn.LayoutOrder = (searchText ~= "" and isMatch) and 10 or 20
            PBtn.MouseButton1Click:Connect(function()
                if TargetPlayer == p then TargetPlayer = nil LoopTieActive = false AntiRejoinActive = false else
                    TargetAll = false TargetPlayer = p
                    if AntiRejoinActive then LockedTargetUserId = p.UserId LockedTargetName = p.Name end
                end
                UpdateList()
            end)
        end
    end
end

SearchBar:GetPropertyChangedSignal("Text"):Connect(function() UpdateList() end)
UpdateList()

-- =========================================================
-- MAIN RENDERING LOOP
-- =========================================================
RunService.RenderStepped:Connect(function()
    local target = TargetPlayer
    if target and target.Character then
        local char = target.Character
        local prefix = (target == LocalPlayer) and "[SELF] " or (AntiRejoinActive and LockedTargetUserId == target.UserId and "[LOCKED] " or "[SELECTED] ")
        StatusTitle.Text = prefix .. target.Name
        
        local isDet = checkState(char, "Detained") or checkState(char, "Cuffed")
        local isMuf = checkState(char, "Muffle") or checkState(char, "Muffled")
        local isBld = checkState(char, "Blindfold")
        local isHod = checkState(char, "Hood")
        local isRop = checkState(char, "Rope") or checkState(char, "Tied")
        local isCol = checkState(char, "Collar")

        StatusText.Text = string.format("Detained    = %s\nMuffled     = %s\nBlindfolded = %s\nHooded      = %s\nRoped       = %s\nCollared    = %s",
            tostring(isDet), tostring(isMuf), tostring(isBld), tostring(isHod), tostring(isRop), tostring(isCol))
    elseif AntiRejoinActive and LockedTargetUserId then
        StatusTitle.Text = "[LOCKED] " .. LockedTargetName
        StatusText.Text = "Status: OFFLINE\nTracking player..."
    else
        StatusTitle.Text = "NO TARGET"
        StatusText.Text = "Please select a player."
    end
end)

local MainMinimized = false
local SavedSize = MainFrame.Size
MinimizeBtn.MouseButton1Click:Connect(function()
    MainMinimized = not MainMinimized
    MainFrame.Size = MainMinimized and UDim2.new(0, 350, 0, 40) or SavedSize
    MinimizeBtn.Text = MainMinimized and "+" or "-"
    for _, child in pairs(MainFrame:GetChildren()) do
        if child:IsA("GuiObject") and child ~= TitleLabel and child ~= CloseBtn and child ~= MinimizeBtn then
            child.Visible = not MainMinimized
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe) 
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then 
        MainFrame.Visible = not MainFrame.Visible 
        StatusFrame.Visible = MainFrame.Visible 
    end 
end)
