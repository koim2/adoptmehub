-- =============================================
-- Adopt Me Pet Spawner v2.3 - by Bin
-- =============================================

print("========================================")
print("Adopt Me Pet Spawner v2.3 ЗАПУЩЕН")
print("Автор: Bin")
print("Дата: " .. os.date("%Y-%m-%d %H:%M"))
print("Режим: Advanced Remote Spawner")
print("========================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function FindRemotes()
    local remotes = {}
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if obj.Name:lower():find("pet") or obj.Name:lower():find("spawn") or 
               obj.Name:lower():find("give") or obj.Name:lower():find("inventory") then
                table.insert(remotes, obj)
            end
        end
    end
    return remotes
end

local function SpawnPetAdvanced(petName, amount)
    amount = math.min(tonumber(amount) or 1, 8)
    local remotes = FindRemotes()
    
    print("[v2.3] Пытаемся заспавнить " .. amount .. "x " .. petName)
    print("[v2.3] Найдено remotes: " .. #remotes)
    
    for i = 1, amount do
        for _, remote in ipairs(remotes) do
            pcall(function()
                remote:FireServer("GivePet", petName, "MegaNeon", true)
                remote:FireServer(petName, 999, "Legendary")
            end)
            pcall(function()
                remote:InvokeServer(petName, amount, "Neon")
            end)
        end
        wait(0.75)
    end
    
    print("[v2.3] Спавн " .. petName .. " завершён. Проверь инвентарь.")
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BinPetSpawner_v2_3"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 320)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Title.Text = "Adopt Me Pet Spawner v2.3"
Title.TextColor3 = Color3.fromRGB(255, 80, 80)
Title.TextScaled = true
Title.Parent = MainFrame

local PetNameBox = Instance.new("TextBox")
PetNameBox.Size = UDim2.new(0.85, 0, 0, 45)
PetNameBox.Position = UDim2.new(0.075, 0, 0.25, 0)
PetNameBox.PlaceholderText = "Название пета (например: Shadow Dragon)"
PetNameBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
PetNameBox.TextColor3 = Color3.new(1,1,1)
PetNameBox.TextScaled = true
PetNameBox.Parent = MainFrame

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0.85, 0, 0, 45)
AmountBox.Position = UDim2.new(0.075, 0, 0.45, 0)
AmountBox.PlaceholderText = "Количество"
AmountBox.Text = "1"
AmountBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
AmountBox.TextColor3 = Color3.new(1,1,1)
AmountBox.TextScaled = true
AmountBox.Parent = MainFrame

local SpawnButton = Instance.new("TextButton")
SpawnButton.Size = UDim2.new(0.85, 0, 0, 55)
SpawnButton.Position = UDim2.new(0.075, 0, 0.65, 0)
SpawnButton.BackgroundColor3 = Color3.fromRGB(120, 20, 20)
SpawnButton.Text = "СПАВНИТЬ"
SpawnButton.TextColor3 = Color3.new(1,1,1)
SpawnButton.TextScaled = true
SpawnButton.Parent = MainFrame

-- Drag functionality
local dragging = false
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        local mousePos = input.Position
        local framePos = MainFrame.Position
        
        game:GetService("RunService").RenderStepped:Connect(function()
            if dragging then
                local delta = game:GetService("UserInputService"):GetMouseLocation() - mousePos
                MainFrame.Position = UDim2.new(0, framePos.X.Offset + delta.X, 0, framePos.Y.Offset + delta.Y)
            end
        end)
    end
end)

MainFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

SpawnButton.MouseButton1Click:Connect(function()
    SpawnPetAdvanced(PetNameBox.Text, AmountBox.Text)
end)

print("[v2.3] GUI успешно загружена. Готов к работе.")
