local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- UI Root Container
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VisualSimulationPipeline"
ScreenGui.ResetOnSpawn = false

-- Safe execution context routing
pcall(function() ScreenGui.Parent = CoreGui end) or pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

-- Main Control Panel Frame
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 360, 0, 320)
MainPanel.Position = UDim2.new(0.5, -180, 0.5, -160)
MainPanel.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
MainPanel.BorderSizePixel = 0
MainPanel.Active = true
MainPanel.Draggable = true
MainPanel.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainPanel

-- Header Title
local HeaderLabel = Instance.new("TextLabel")
HeaderLabel.Size = UDim2.new(1, 0, 0, 40)
HeaderLabel.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
HeaderLabel.Text = "  ASSET VISUALIZER MATRIX"
HeaderLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
HeaderLabel.Font = Enum.Font.SourceSansBold
HeaderLabel.TextSize = 16
HeaderLabel.Parent = MainPanel

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = HeaderLabel

-- Input Field for Pet Name
local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(0, 320, 0, 40)
NameInput.Position = UDim2.new(0, 20, 0, 60)
NameInput.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.PlaceholderText = "Enter Pet Name (e.g., Shadow Dragon)..."
NameInput.Text = ""
NameInput.Font = Enum.Font.SourceSans
NameInput.TextSize = 16
NameInput.Parent = MainPanel

local InputCorner = Instance.new("UICorner")
InputCorner.CornerRadius = UDim.new(0, 6)
InputCorner.Parent = NameInput

-- Modifier State Memory
local ActiveModifier = "FR"
local Buttons = {}

-- Factory Function for Grid Buttons (MFR, NFR, FR)
local function CreateModButton(text, index)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 95, 0, 40)
    button.Position = UDim2.new(0, 20 + (index * 112), 0, 120)
    button.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Parent = MainPanel
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        ActiveModifier = text
        for _, btn in ipairs(Buttons) do
            btn.BackgroundColor3 = Color3.fromRGB(44, 44, 52)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
        button.BackgroundColor3 = Color3.fromRGB(230, 126, 34) -- Neon amber highlight
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    
    table.insert(Buttons, button)
    return button
end

local btn1 = CreateModButton("MFR", 0)
local btn2 = CreateModButton("NFR", 1)
local btn3 = CreateModButton("FR", 2)
btn3.BackgroundColor3 = Color3.fromRGB(230, 126, 34) -- Default selection

-- Pseudo Feedback Progress Bar Background
local ProgressBackground = Instance.new("Frame")
ProgressBackground.Size = UDim2.new(0, 320, 0, 8)
ProgressBackground.Position = UDim2.new(0, 20, 0, 185)
ProgressBackground.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
ProgressBackground.Parent = MainPanel

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(0, 4)
BarCorner.Parent = ProgressBackground

-- Active Progress Fill
local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ProgressFill.Parent = ProgressBackground

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(0, 4)
FillCorner.Parent = ProgressFill

-- Simulation Trigger Action Button
local SpawnButton = Instance.new("TextButton")
SpawnButton.Size = UDim2.new(0, 320, 0, 50)
SpawnButton.Position = UDim2.new(0, 20, 0, 210)
SpawnButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
SpawnButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpawnButton.Text = "SPAWN VISUAL ASSET"
SpawnButton.Font = Enum.Font.SourceSansBold
SpawnButton.TextSize = 18
SpawnButton.Parent = MainPanel

local SpawnCorner = Instance.new("UICorner")
SpawnCorner.CornerRadius = UDim.new(0, 6)
SpawnCorner.Parent = SpawnButton

-- Dynamic Visual Pop-up Notification Engine
local function TriggerVisualNotification(petName, modifier)
    local Notification = Instance.new("Frame")
    Notification.Size = UDim2.new(0, 280, 0, 60)
    Notification.Position = UDim2.new(0.5, -140, 0, -80)
    Notification.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
    Notification.BackgroundTransparency = 0.1
    Notification.Parent = ScreenGui

    local NotifCorner = Instance.new("UICorner")
    NotifCorner.CornerRadius = UDim.new(0, 8)
    NotifCorner.Parent = Notification

    local NotifText = Instance.new("TextLabel")
    NotifText.Size = UDim2.new(1, 0, 1, 0)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = string.format("Added [%s] %s\nto Local Inventory!", modifier, petName)
    NotifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifText.Font = Enum.Font.SourceSansBold
    NotifText.TextSize = 16
    NotifText.Parent = Notification

    -- Animation Chain: Slide down, pause, slide away, destroy
    Notification:TweenPosition(UDim2.new(0.5, -140, 0, 20), "Out", "Quad", 0.4, true)
    task.wait(2.5)
    Notification:TweenPosition(UDim2.new(0.5, -140, 0, -80), "In", "Quad", 0.4, true)
    task.wait(0.5)
    Notification:Destroy()
end

-- Event Wire-up
SpawnButton.MouseButton1Click:Connect(function()
    local petName = NameInput.Text
    if petName == "" then return end
    
    SpawnButton.Active = false
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    
    -- Animate local generation bar sequence [5]
    local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local progressTween = TweenService:Create(ProgressFill, tweenInfo, {Size = UDim2.new(1, 0, 1, 0)})
    
    progressTween:Play()
    progressTween.Completed:Wait()
    
    -- Reset state sequence
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    SpawnButton.Active = true
    
    -- Fire local decorative confirmation event thread
    task.spawn(TriggerVisualNotification, petName, ActiveModifier)
end)
