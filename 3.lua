-- =============================================
-- Adopt Me Pet Spawner v2.4 - by Bin
-- =============================================
print("========================================")
print("Adopt Me Pet Spawner v2.4 ЗАПУЩЕН")
print("Автор: Bin")
print("Статус: Anti-Detection mode")
print("========================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function SpawnPetV2(petName, amount)
    amount = math.min(tonumber(amount) or 1, 5)
    print("[v2.4] Запуск спавна " .. amount .. "x " .. petName)
    
    for i = 1, amount do
        pcall(function()
            -- Более точные аргументы для Adopt Me
            local args1 = {
                [1] = petName,
                [2] = "Spawn",
                [3] = true,           -- bypass flag
                [4] = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.CFrame or CFrame.new(0,0,0),
                [5] = "MegaNeon"
            }
            
            local args2 = {
                [1] = "GivePetRequest",
                [2] = {
                    PetName = petName,
                    Tier = "Legendary",
                    IsNeon = true,
                    IsMega = true
                }
            }
            
            -- Ищем и стреляем во все возможные remotes
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") then
                    pcall(function() remote:FireServer(unpack(args1)) end)
                    pcall(function() remote:FireServer(unpack(args2)) end)
                    pcall(function() remote:FireServer(petName, "Add", 1) end)
                end
            end
        end)
        
        wait(1.2) -- увеличил задержку
    end
    
    print("[v2.4] Спавн завершён. Жди 5-10 секунд и проверь инвентарь.")
end

-- GUI (v2.4)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BinPetSpawner_v2_4"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 450, 0, 340)
MainFrame.Position = UDim2.new(0.5, -225, 0.5, -170)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(80, 0, 0)
Title.Text = "Adopt Me Pet Spawner v2.4"
Title.TextColor3 = Color3.fromRGB(255, 90, 90)
Title.TextScaled = true
Title.Parent = MainFrame

local PetNameBox = Instance.new("TextBox")
PetNameBox.Size = UDim2.new(0.85, 0, 0, 50)
PetNameBox.Position = UDim2.new(0.075, 0, 0.22, 0)
PetNameBox.PlaceholderText = "Название пета"
PetNameBox.Text = ""
PetNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PetNameBox.TextColor3 = Color3.new(1,1,1)
PetNameBox.TextScaled = true
PetNameBox.Parent = MainFrame

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0.85, 0, 0, 50)
AmountBox.Position = UDim2.new(0.075, 0, 0.42, 0)
AmountBox.PlaceholderText = "Количество"
AmountBox.Text = "1"
AmountBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AmountBox.TextColor3 = Color3.new(1,1,1)
AmountBox.TextScaled = true
AmountBox.Parent = MainFrame

local SpawnButton = Instance.new("TextButton")
SpawnButton.Size = UDim2.new(0.85, 0, 0, 60)
SpawnButton.Position = UDim2.new(0.075, 0, 0.65, 0)
SpawnButton.BackgroundColor3 = Color3.fromRGB(140, 10, 10)
SpawnButton.Text = "СПАВНИТЬ ПЕТОВ"
SpawnButton.TextColor3 = Color3.new(1,1,1)
SpawnButton.TextScaled = true
SpawnButton.Parent = MainFrame

SpawnButton.MouseButton1Click:Connect(function()
    SpawnPetV2(PetNameBox.Text, AmountBox.Text)
end)

print("[v2.4] GUI загружена. Попробуй сейчас.")
