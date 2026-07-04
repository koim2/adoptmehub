-- Standalone Client Interface for Visual Simulation
-- Creates a localized graphical frame to display simulated structural data

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local PetInput = Instance.new("TextBox")
local ModifierInput = Instance.new("TextBox")
local GenerateButton = Instance.new("TextButton")
local DisplayLabel = Instance.new("TextLabel")

-- Setup UI Hierarchy and Properties
ScreenGui.Name = "VisualSimulatorUI"
ScreenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "MainContainer"
MainFrame.Size = UDim2.new(0, 300, 0, 250)
MainFrame.Position = UDim2.new(0.5, -150, 0.4, -125)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
TitleLabel.Text = "Visual Inventory Emulator"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextSize = 18
TitleLabel.Parent = MainFrame

PetInput.Size = UDim2.new(0.8, 0, 0, 35)
PetInput.Position = UDim2.new(0.1, 0, 0.25, 0)
PetInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PetInput.Text = ""
PetInput.PlaceholderText = "Enter Pet Name (e.g., Shadow Dragon)"
PetInput.TextColor3 = Color3.fromRGB(255, 255, 255)
PetInput.Parent = MainFrame

ModifierInput.Size = UDim2.new(0.8, 0, 0, 35)
ModifierInput.Position = UDim2.new(0.1, 0, 0.45, 0)
ModifierInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
ModifierInput.Text = ""
ModifierInput.PlaceholderText = "Modifier (MFR, NFR, FR, REG)"
ModifierInput.TextColor3 = Color3.fromRGB(255, 255, 255)
ModifierInput.Parent = MainFrame

GenerateButton.Size = UDim2.new(0.8, 0, 0, 40)
GenerateButton.Position = UDim2.new(0.1, 0, 0.65, 0)
GenerateButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
GenerateButton.Text = "Simulate Addition"
GenerateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
GenerateButton.Font = Enum.Font.SourceSansBold
GenerateButton.TextSize = 16
GenerateButton.Parent = MainFrame

DisplayLabel.Size = UDim2.new(1, 0, 0, 30)
DisplayLabel.Position = UDim2.new(0, 0, 0.85, 0)
DisplayLabel.BackgroundTransparency = 1
DisplayLabel.Text = "Status: Idle"
DisplayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
DisplayLabel.TextSize = 14
DisplayLabel.Parent = MainFrame

-- Interaction Logic
GenerateButton.MouseButton1Click:Connect(function()
    local name = PetInput.Text
    local mod = ModifierInput.Text
    
    if name ~= "" and mod ~= "" then
        DisplayLabel.Text = string.format("Simulated: %s (%s)", name, string.upper(mod))
        DisplayLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
        
        -- Outputs local debug state representation to standard output boundaries
        print(string.format("[UI Log]: Rendering client-side data frame for object [%s] with tier structure [%s]", name, string.upper(mod)))
    else
        DisplayLabel.Text = "Error: Fields cannot be empty."
        DisplayLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)
