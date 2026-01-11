local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Remotes
local RestraintEvents = ReplicatedStorage:WaitForChild("Restraint System"):WaitForChild("Events")
local ActionRemote = RestraintEvents:WaitForChild("Action")
local GUIRemote = RestraintEvents:WaitForChild("GUI")

local TargetPlayer = nil
local TargetAll = false
local LoopTieActive = false
local IsProcessingTie = false
local IsSelfTargeted = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RestraintControl_Sky"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Status Tracker UI (Top Right)
local StatusFrame = Instance.new("Frame")
StatusFrame.Size = UDim2.new(0, 220, 0, 180)
StatusFrame.Position = UDim2.new(1, -230, 0, 10)
StatusFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
StatusFrame.BackgroundTransparency = 0.2
StatusFrame.BorderSizePixel = 0
StatusFrame.Parent = ScreenGui
Instance.new("UICorner", StatusFrame).CornerRadius = UDim.new(0, 8)

local StatusTitle = Instance.new("TextLabel")
StatusTitle.Size = UDim2.new(1, 0, 0, 25)
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
StatusText.TextSize = 15
StatusText.TextXAlignment = Enum.TextXAlignment.Left
StatusText.TextYAlignment = Enum.TextYAlignment.Top
StatusText.Text = "Please select a player..."
StatusText.Parent = StatusFrame

-- Main Control Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 350, 0, 280)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

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

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = PlayerList

local ActionsFrame = Instance.new("ScrollingFrame")
ActionsFrame.Size = UDim2.new(0.6, -5, 1, -50)
ActionsFrame.Position = UDim2.new(0.4, 0, 0, 45)
ActionsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
ActionsFrame.BorderSizePixel = 0
ActionsFrame.ScrollBarThickness = 2
ActionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ActionsFrame.CanvasSize = UDim2.new(0,0,0,0)
ActionsFrame.Parent = MainFrame

local ActionLayout = Instance.new("UIListLayout")
ActionLayout.Padding = UDim.new(0, 5)
ActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ActionLayout.Parent = ActionsFrame

-- Logic Functions
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

-- Reactive Loop Tie Execution
task.spawn(function()
    while true do
        task.wait(0.3)
        if LoopTieActive and TargetPlayer and TargetPlayer.Character then
            local char = TargetPlayer.Character
            local isDetained = checkState(char, "Detained") or checkState(char, "Cuffed") or checkState(char, "Metal Cuffs")
            local isTied = checkState(char, "Tied") or checkState(char, "Rope")
            
            if not isDetained and not isTied and not IsProcessingTie then
                IsProcessingTie = true
                ActionRemote:FireServer("Rope", "Rope", char)
                ActionRemote:FireServer("Muffle", "Muffler", char)
                ActionRemote:FireServer("Blindfold", "Blindfold", char)
                ActionRemote:FireServer("Blindfold", "Hood", char)
                GUIRemote:InvokeServer("Add", char)
                ActionRemote:FireServer("Detain", "Metal Cuffs", char)
                task.spawn(function()
                    local timeout = 0
                    repeat 
                        task.wait(0.5)
                        timeout = timeout + 1
                    until (checkState(char, "Tied") or not LoopTieActive or not TargetPlayer or timeout > 10)
                    IsProcessingTie = false
                end)
            end
        end
    end
end)

local function GetTargets()
    if TargetAll then
        local t = {}
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then table.insert(t, p) end
        end
        return t
    elseif TargetPlayer then
        return {TargetPlayer}
    end
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
        if #targets == 0 then return end
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

-- Status Loop
RunService.RenderStepped:Connect(function()
    local target = TargetPlayer
    if target and target.Character then
        local char = target.Character
        StatusTitle.Text = (target == LocalPlayer and "[SELF] " or "[SELECTED] ") .. target.DisplayName
        local isDetained = checkState(char, "Detained") or checkState(char, "Cuffed") or checkState(char, "Metal Cuffs")
        local isMuffled = checkState(char, "Muffled") or checkState(char, "Muffler") or checkState(char, "Muffle")
        local isBlinded = checkState(char, "Hooded") or checkState(char, "Blindfolded") or checkState(char, "Hood") or checkState(char, "Blindfold")
        local isTied = checkState(char, "Tied") or checkState(char, "Rope")
        local isCollared = checkState(char, "Collared") or checkState(char, "Collar")

        StatusText.Text = string.format("detained = %s\nmuffled  = %s\nblinded  = %s\ntied     = %s\ncollared = %s",
            tostring(isDetained), tostring(isMuffled), tostring(isBlinded), tostring(isTied), tostring(isCollared))
        StatusText.TextColor3 = (isDetained or isMuffled or isBlinded or isTied or isCollared) and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 255, 255)
    else
        StatusTitle.Text = "NO TARGET"
        StatusText.Text = "Please select a player\nto track their status."
        StatusText.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Action Buttons
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

local function UpdateList()
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local AllBtn = Instance.new("TextButton")
    AllBtn.Size = UDim2.new(1, 0, 0, 30)
    AllBtn.BackgroundColor3 = TargetAll and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(45, 45, 50)
    AllBtn.Text = "TARGET EVERYONE"
    AllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AllBtn.Font = Enum.Font.GothamBold
    AllBtn.TextSize = 10
    AllBtn.Parent = PlayerList
    AllBtn.MouseButton1Click:Connect(function()
        TargetAll = not TargetAll
        TargetPlayer = nil
        LoopTieActive = false
        IsSelfTargeted = false
        UpdateList()
    end)

    local LoopBtn = Instance.new("TextButton")
    LoopBtn.Size = UDim2.new(1, 0, 0, 30)
    LoopBtn.BackgroundColor3 = LoopTieActive and Color3.fromRGB(200, 60, 60) or Color3.fromRGB(45, 45, 50)
    LoopBtn.Text = "LOOP TIE"
    LoopBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LoopBtn.Font = Enum.Font.GothamBold
    LoopBtn.TextSize = 10
    LoopBtn.Parent = PlayerList
    LoopBtn.MouseButton1Click:Connect(function()
        if TargetPlayer then
            LoopTieActive = not LoopTieActive
            TargetAll = false
            UpdateList()
        end
    end)

    local SelfBtn = Instance.new("TextButton")
    SelfBtn.Size = UDim2.new(1, 0, 0, 30)
    SelfBtn.BackgroundColor3 = (TargetPlayer == LocalPlayer) and Color3.fromRGB(60, 200, 100) or Color3.fromRGB(45, 45, 50)
    SelfBtn.Text = "SELF TARGET"
    SelfBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SelfBtn.Font = Enum.Font.GothamBold
    SelfBtn.TextSize = 10
    SelfBtn.Parent = PlayerList
    SelfBtn.MouseButton1Click:Connect(function()
        TargetAll = false
        if TargetPlayer == LocalPlayer then
            TargetPlayer = nil
            LoopTieActive = false
        else
            TargetPlayer = LocalPlayer
        end
        UpdateList()
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
                if TargetPlayer == p then
                    TargetPlayer = nil
                    LoopTieActive = false
                else
                    TargetAll = false
                    TargetPlayer = p
                end
                UpdateList()
            end)
        end
    end
end

UpdateList()
Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(function(plr)
    if TargetPlayer == plr then TargetPlayer = nil LoopTieActive = false end
    UpdateList()
end)

local Minimized = false
local SavedSize = MainFrame.Size

MinimizeBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        SavedSize = MainFrame.Size
        MainFrame.Size = UDim2.new(0, 350, 0, 40)
        MinimizeBtn.Text = "+"
        StatusFrame.Visible = false
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") and child ~= Title and child ~= CloseBtn and child ~= MinimizeBtn then
                child.Visible = false
            end
        end
    else
        MainFrame.Size = SavedSize
        MinimizeBtn.Text = "-"
        StatusFrame.Visible = true
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") then child.Visible = true end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
        StatusFrame.Visible = MainFrame.Visible
    end
end)
