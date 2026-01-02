local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ActionRemote = ReplicatedStorage:WaitForChild("Restraint System"):WaitForChild("Events"):WaitForChild("Action")

-- // UI Configuration
local TargetPlayer = nil

-- // Create UI Base
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomRestraintUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 300)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- // Header
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "RESTRAINT CONTROL"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- // Player Selection Area
local PlayerList = Instance.new("ScrollingFrame")
PlayerList.Size = UDim2.new(0.4, -10, 1, -50)
PlayerList.Position = UDim2.new(0, 5, 0, 45)
PlayerList.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
PlayerList.BorderSizePixel = 0
PlayerList.ScrollBarThickness = 4
PlayerList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 2)
UIListLayout.Parent = PlayerList

-- // Action Buttons Area
local ActionsFrame = Instance.new("Frame")
ActionsFrame.Size = UDim2.new(0.6, -5, 1, -50)
ActionsFrame.Position = UDim2.new(0.4, 0, 0, 45)
ActionsFrame.BackgroundTransparency = 1
ActionsFrame.Parent = MainFrame

local ActionLayout = Instance.new("UIListLayout")
ActionLayout.Padding = UDim.new(0, 5)
ActionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ActionLayout.Parent = ActionsFrame

-- // Function to Create Action Buttons
local function CreateActionButton(text, toolName, actionType)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.AutoButtonColor = true
    Btn.Parent = ActionsFrame
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 4)
    Corner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        if TargetPlayer and TargetPlayer.Character then
            local args = {actionType, toolName, TargetPlayer.Character}
            ActionRemote:FireServer(unpack(args))
        end
    end)
end

-- // Action Setup
CreateActionButton("Grab (Cuffs)", "Metal Cuffs", "Grab")
CreateActionButton("Rope", "Rope", "Rope")
CreateActionButton("Muffle (Muffler)", "Muffler", "Muffle")
CreateActionButton("Blindfold (Hood)", "Hood", "Blindfold")
CreateActionButton("Pin (Cuffs)", "Metal Cuffs", "Pin")
CreateActionButton("Kneel (Cuffs)", "Metal Cuffs", "Kneel")

-- // Update Player List
local function UpdateList()
    for _, child in pairs(PlayerList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Players.LocalPlayer then
            local PBtn = Instance.new("TextButton")
            PBtn.Size = UDim2.new(1, 0, 0, 25)
            PBtn.BackgroundColor3 = (TargetPlayer == p) and Color3.fromRGB(100, 100, 255) or Color3.fromRGB(45, 45, 50)
            PBtn.Text = p.Name
            PBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            PBtn.Font = Enum.Font.Gotham
            PBtn.TextSize = 12
            PBtn.Parent = PlayerList
            
            PBtn.MouseButton1Click:Connect(function()
                TargetPlayer = p
                UpdateList()
            end)
        end
    end
end

Players.PlayerAdded:Connect(UpdateList)
Players.PlayerRemoving:Connect(UpdateList)
UpdateList()

-- // Toggle Key (Insert)
game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
