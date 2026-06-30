-- Local Asset Visual Simulation Interface (Client-Side Only)
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer

-- UI Root Container Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AssetSimulationPipeline"
ScreenGui.ResetOnSpawn = false
-- Safe check for execution context environments
pcall(function() ScreenGui.Parent = CoreGui end) or pcall(function() ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

-- Main Frame Panel Architecture
local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(0, 350, 0, 250)
MainPanel.Position = UDim2.new(0.5, -175, 0.5, -125)
MainPanel.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
MainPanel.BorderSizePixel = 0
MainPanel.Active = true
MainPanel.Draggable = true
MainPanel.Parent = ScreenGui

-- Corner Smoothing Constraint
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainPanel

-- Input Field for Target Asset Name
local NameInput = Instance.new("TextBox")
NameInput.Size = UDim2.new(0, 310, 0, 40)
NameInput.Position = UDim2.new(0, 20, 0, 20)
NameInput.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
NameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
NameInput.PlaceholderText = "Enter Pet Name (e.g., Shadow Dragon)..."
NameInput.Text = ""
NameInput.Font = Enum.Font.SourceSans
NameInput.TextSize = 16
NameInput.Parent = MainPanel

-- Modifier State Memory
local ActiveModifier = "Normal"

-- Factory Function for Configuration Buttons (MFR, NFR, FR)
local function CreateModifierButton(text, positionIndex)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 90, 0, 35)
    button.Position = UDim2.new(0, 20 + (positionIndex * 110), 0, 80)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
    button.TextColor3 = Color3.fromRGB(200, 200, 200)
    button.Text = text
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.Parent = MainPanel
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = button

    button.MouseButton1Click:Connect(function()
        ActiveModifier = text
        -- Visual reset for peers
        for _, child in ipairs(MainPanel:GetChildren()) do
            if child:IsA("TextButton") and child.Name == "ModBtn" then
                child.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
            end
        end
        button.BackgroundColor3 = Color3.fromRGB(0, 120, 215) -- Highlight active state
    end)
    button.Name = "ModBtn"
    return button
end

CreateModifierButton("MFR", 0)
CreateModifierButton("NFR", 1)
CreateModifierButton("FR", 2)

-- Action Trigger Button (Simulate Execution)
local ActionButton = Instance.new("TextButton")
ActionButton.Size = UDim2.new(0, 310, 0, 50)
ActionButton.Position = UDim2.new(0, 20, 0, 180)
ActionButton.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
ActionButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionButton.Text = "Spawn Pet (Visual Spoof)"
ActionButton.Font = Enum.Font.SourceSansBold
ActionButton.TextSize = 18
ActionButton.Parent = MainPanel

local actCorner = Instance.new("UICorner")
actCorner.CornerRadius = UDim.new(0, 6)
actCorner.Parent = ActionButton

-- Event Linkage
ActionButton.MouseButton1Click:Connect(function()
    local targetPet = NameInput.Text
    if targetPet ~= "" then
        -- This logic changes local UI data only; it does not replicate to the server database.
        print(string.format("[Simulation Engine] Generated client-side visual reference: %s (%s)", targetPet, ActiveModifier))
    end
end)
