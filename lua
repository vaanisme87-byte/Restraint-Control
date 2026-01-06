local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Remotes
local RestraintEvents = ReplicatedStorage:WaitForChild("Restraint System"):WaitForChild("Events")
local ActionRemote = RestraintEvents:WaitForChild("Action")
local GUIRemote = RestraintEvents:WaitForChild("GUI")

local TargetPlayer = nil
local TargetAll = false

-- GUI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RestraintControl_Sky"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

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
ActionsFrame.Parent = MainFrame

local ActionLayout = Instance.new("UIListLayout")
ActionLayout.Padding = UDim.new(0, 5)
ActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ActionLayout.Parent = ActionsFrame

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

-- Full Actions List
CreateActionButton("Arrest (Cuffs)", "Metal Cuffs", "ArrestPrompt")
CreateActionButton("Detain", "Metal Cuffs", "Detain")
CreateActionButton("Grab", "Metal Cuffs", "Grab")
CreateActionButton("Pin", "Metal Cuffs", "Pin")
CreateActionButton("Kneel", "Metal Cuffs", "Kneel") -- New Kneel button
CreateActionButton("Carry", "Rope", "Carry")       -- New Carry button
CreateActionButton("Rope", "Rope", "Rope")         -- New Rope button
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
                TargetAll = false
                TargetPlayer = p
                UpdateList()
            end)
        end
    end
end

UpdateList()
Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(UpdateList)

local Minimized = false
local SavedSize = MainFrame.Size

MinimizeBtn.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        SavedSize = MainFrame.Size
        MainFrame.Size = UDim2.new(0, 350, 0, 40)
        MinimizeBtn.Text = "+"
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") and child ~= Title and child ~= CloseBtn and child ~= MinimizeBtn then
                child.Visible = false
            end
        end
    else
        MainFrame.Size = SavedSize
        MinimizeBtn.Text = "-"
        for _, child in pairs(MainFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                child.Visible = true
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
