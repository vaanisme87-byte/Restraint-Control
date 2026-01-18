local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Remotes
local RestraintEvents = ReplicatedStorage:WaitForChild("Restraint System"):WaitForChild("Events")
local ActionRemote = RestraintEvents:WaitForChild("Action")
local GUIRemote = RestraintEvents:WaitForChild("GUI")

local TargetPlayer = nil
local TargetAll = false
local LoopTieActive = false
local IsProcessingTie = false

-- Anti Rejoin Logic
local AntiRejoinActive = false
local LockedTargetUserId = nil
local LockedTargetName = "None"

-- Blacklist configuration
local blacklist = {
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
}

local blacklistedProcessed = {} 
local blacklistedDetected = {}  

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RestraintControl_Sky"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 2147483647 
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Notification System
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 260, 1, -20)
NotifContainer.Position = UDim2.new(1, -270, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotifContainer

local function NotifyBlacklist(playerName)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 70)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifContainer
    
    local Corner = Instance.new("UICorner", NotifFrame)
    Corner.CornerRadius = UDim.new(0, 8)

    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 0, 0, 2)
    Glow.Position = UDim2.new(0, 0, 1, -2)
    Glow.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Glow.BorderSizePixel = 0
    Glow.Parent = NotifFrame
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 0, 30)
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

    task.spawn(function()
        NotifFrame.Position = UDim2.new(1.5, 0, 0, 0)
        TweenService:Create(NotifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
        task.wait(6)
        local t = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, 0)})
        t:Play()
        t.Completed:Wait()
        NotifFrame:Destroy()
    end)
end

local function NotifyBlacklistLeft(playerName)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 70)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifContainer
    
    local Corner = Instance.new("UICorner", NotifFrame)
    Corner.CornerRadius = UDim.new(0, 8)

    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 0, 0, 2)
    Glow.Position = UDim2.new(0, 0, 1, -2)
    Glow.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Glow.BorderSizePixel = 0
    Glow.Parent = NotifFrame
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 0, 30)
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

    task.spawn(function()
        NotifFrame.Position = UDim2.new(1.5, 0, 0, 0)
        TweenService:Create(NotifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
        task.wait(6)
        local t = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, 0)})
        t:Play()
        t.Completed:Wait()
        NotifFrame:Destroy()
    end)
end

local function NotifyWelcome(playerName)
    local NotifFrame = Instance.new("Frame")
    NotifFrame.Size = UDim2.new(0, 250, 0, 70)
    NotifFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30) 
    NotifFrame.BorderSizePixel = 0
    NotifFrame.Parent = NotifContainer
    
    local Corner = Instance.new("UICorner", NotifFrame)
    Corner.CornerRadius = UDim.new(0, 8)

    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 0, 0, 2)
    Glow.Position = UDim2.new(0, 0, 1, -2)
    Glow.BackgroundColor3 = Color3.fromRGB(0, 191, 255) 
    Glow.BorderSizePixel = 0
    Glow.Parent = NotifFrame
    Instance.new("UICorner", Glow).CornerRadius = UDim.new(0, 8)
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 0, 30)
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

    task.spawn(function()
        NotifFrame.Position = UDim2.new(1.5, 0, 0, 0)
        TweenService:Create(NotifFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0,0,0,0)}):Play()
        task.wait(6)
        local t = TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1.5, 0, 0, 0)})
        t:Play()
        t.Completed:Wait()
        NotifFrame:Destroy()
    end)
end

NotifyWelcome(LocalPlayer.DisplayName or LocalPlayer.Name)

-- Control GUI Elements
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

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -110, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "  RESTRAINT CONTROL By Sky!"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 13
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Parent = MainFrame

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

local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.4, -10, 1, -50)
PlayerList.Position = UDim2.new(0, 5, 0, 45)
PlayerList.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 2
PlayerList.AutomaticCanvasSize = Enum.AutomaticSize.Y
PlayerList.CanvasSize = UDim2.new(0,0,0,0)
PlayerList.Parent = MainFrame
Instance.new("UIListLayout", PlayerList).Padding = UDim.new(0, 2)

local ActionsFrame = Instance.new("ScrollingFrame")
ActionsFrame.Size = UDim2.new(0.6, -5, 1, -50)
ActionsFrame.Position = UDim2.new(0.4, 0, 0, 45)
ActionsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ActionsFrame.BorderSizePixel = 0
ActionsFrame.ScrollBarThickness = 2
ActionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ActionsFrame.CanvasSize = UDim2.new(0,0,0,0)
ActionsFrame.Parent = MainFrame
Instance.new("UIListLayout", ActionsFrame).Padding = UDim.new(0, 5)
ActionsFrame.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Logic and Sequences
local function checkState(char, stateName)
    if not char then return false end
    if char:GetAttribute(stateName) ~= nil then return char:GetAttribute(stateName) end
    local found = char:FindFirstChild(stateName, true)
    if found and (found:IsA("BoolValue") or found:IsA("StringValue")) then
        return found.Value ~= false and found.Value ~= "" and found.Value ~= "None"
    end
    if char:FindFirstChild(stateName, true) then return true end
    return false
end

-- Blacklist Sequences
local function FireBlacklistRestraintOnce(player)
    if not player.Character or blacklistedProcessed[player.UserId] then return end
    local char = player.Character
    ActionRemote:FireServer("Kneel", "Metal Cuffs", char)
    ActionRemote:FireServer("Pin", "Metal Cuffs", char)
    ActionRemote:FireServer("Blindfold", "Blindfold", char)
    ActionRemote:FireServer("Hood", "Hood", char)
    ActionRemote:FireServer("Rope", "Rope", char)
    GUIRemote:InvokeServer("Add", char)
    ActionRemote:FireServer("Detain", "Metal Cuffs", char)
    blacklistedProcessed[player.UserId] = true
end

-- Case-Insensitive Blacklist Check Logic
local function HandleBlacklistedPlayer(player)
    local isBlacklisted = false
    local checkName = string.lower(player.Name)
    for bName, _ in pairs(blacklist) do
        if string.lower(bName) == checkName then
            isBlacklisted = true
            break
        end
    end

    if not isBlacklisted or blacklistedDetected[player.UserId] then return end
    blacklistedDetected[player.UserId] = true 
    
    NotifyBlacklist(player.DisplayName or player.Name)
    blacklistedProcessed[player.UserId] = false
    
    player.CharacterAdded:Connect(function(char)
        blacklistedProcessed[player.UserId] = false
        task.wait(1)
        FireBlacklistRestraintOnce(player)
    end)
    
    if player.Character then 
        task.wait(1)
        FireBlacklistRestraintOnce(player) 
    end
end

-- Watchdog
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do HandleBlacklistedPlayer(p) end
        task.wait(1)
    end
end)

-- Main Listeners
Players.PlayerAdded:Connect(function(p)
    if AntiRejoinActive and LockedTargetUserId and p.UserId == LockedTargetUserId then TargetPlayer = p end
    UpdateList()
end)

Players.PlayerRemoving:Connect(function(plr) 
    local isBlacklisted = false
    local checkName = string.lower(plr.Name)
    for bName, _ in pairs(blacklist) do
        if string.lower(bName) == checkName then isBlacklisted = true break end
    end

    if isBlacklisted then
        NotifyBlacklistLeft(plr.DisplayName or plr.Name)
        blacklistedDetected[plr.UserId] = nil 
        blacklistedProcessed[plr.UserId] = nil
    end
    if TargetPlayer == plr and not AntiRejoinActive then TargetPlayer = nil LoopTieActive = false end 
    UpdateList() 
end)

-- Shared loop logic
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
            local isDetained = checkState(activeChar, "Detained") or checkState(activeChar, "Cuffed") or checkState(activeChar, "Metal Cuffs")
            local isRoped = checkState(activeChar, "Tied") or checkState(activeChar, "Rope")
            if not isDetained and not isRoped then 
                ActionRemote:FireServer("Kneel", "Metal Cuffs", activeChar)
                ActionRemote:FireServer("Pin", "Metal Cuffs", activeChar)
                ActionRemote:FireServer("Rope", "Rope", activeChar)
                ActionRemote:FireServer("Muffle", "Muffler", activeChar)
                ActionRemote:FireServer("Blindfold", "Blindfold", activeChar)
                ActionRemote:FireServer("Blindfold", "Hood", activeChar)
                GUIRemote:InvokeServer("Add", activeChar)
                ActionRemote:FireServer("Detain", "Metal Cuffs", activeChar)
            end
        end
    end
end)

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

-- Original Actions Buttons
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

function UpdateList()
    for _, child in pairs(PlayerList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local function CreateMenuBtn(txt, active, callback)
        local AllBtn = Instance.new("TextButton")
        AllBtn.Size = UDim2.new(1, 0, 0, 30)
        AllBtn.BackgroundColor3 = active and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(45, 45, 50)
        AllBtn.Text = txt
        AllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        AllBtn.Font = Enum.Font.GothamBold
        AllBtn.TextSize = 10
        AllBtn.Parent = PlayerList
        AllBtn.MouseButton1Click:Connect(callback)
    end
    CreateMenuBtn("TARGET EVERYONE", TargetAll, function()
        TargetAll = not TargetAll TargetPlayer = nil LoopTieActive = false AntiRejoinActive = false UpdateList()
    end)
    CreateMenuBtn("LOOP TIE", LoopTieActive, function()
        if TargetPlayer then LoopTieActive = not LoopTieActive TargetAll = false UpdateList() end
    end)
    CreateMenuBtn("ANTI REJOIN TIE", AntiRejoinActive, function()
        if TargetPlayer and TargetPlayer ~= LocalPlayer then
            AntiRejoinActive = not AntiRejoinActive
            LockedTargetUserId = AntiRejoinActive and TargetPlayer.UserId or nil
            LockedTargetName = AntiRejoinActive and TargetPlayer.DisplayName or "None"
            UpdateList()
        elseif not TargetPlayer and AntiRejoinActive then AntiRejoinActive = false LockedTargetUserId = nil UpdateList() end
    end)
    CreateMenuBtn("SELF TARGET", TargetPlayer == LocalPlayer, function()
        TargetAll = false AntiRejoinActive = false if TargetPlayer == LocalPlayer then TargetPlayer = nil LoopTieActive = false else TargetPlayer = LocalPlayer end UpdateList()
    end)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local PBtn = Instance.new("TextButton")
            PBtn.Size = UDim2.new(1, 0, 0, 25)
            PBtn.BackgroundColor3 = (not TargetAll and TargetPlayer == p) and Color3.fromRGB(60, 100, 200) or Color3.fromRGB(35, 35, 40)
            PBtn.Text = p.DisplayName or p.Name
            PBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            PBtn.Font = Enum.Font.Gotham
            PBtn.TextSize = 11
            PBtn.Parent = PlayerList
            PBtn.MouseButton1Click:Connect(function()
                if TargetPlayer == p then TargetPlayer = nil LoopTieActive = false AntiRejoinActive = false else
                    TargetAll = false TargetPlayer = p
                    if AntiRejoinActive then LockedTargetUserId = p.UserId LockedTargetName = p.DisplayName end
                end
                UpdateList()
            end)
        end
    end
end
UpdateList()

RunService.RenderStepped:Connect(function()
    local target = TargetPlayer
    if target and target.Character then
        local char = target.Character
        local prefix = (target == LocalPlayer) and "[SELF] " or (AntiRejoinActive and LockedTargetUserId == target.UserId and "[LOCKED] " or "[SELECTED] ")
        StatusTitle.Text = prefix .. target.DisplayName
        StatusText.Text = string.format("Detained    = %s\nMuffled     = %s\nBlindfolded = %s\nHooded      = %s\nRoped       = %s\nCollared    = %s",
            tostring(checkState(char, "Detained") or checkState(char, "Cuffed")), tostring(checkState(char, "Muffled")), tostring(checkState(char, "Blindfold")), tostring(checkState(char, "Hood")), tostring(checkState(char, "Rope")), tostring(checkState(char, "Collar")))
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
        if child:IsA("GuiObject") and child ~= Title and child ~= CloseBtn and child ~= MinimizeBtn then
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
