-- =============================================
-- Adopt Me Pet Spawner v2.6 - by Bin (Fixed)
-- =============================================
print("========================================")
print("Adopt Me Pet Spawner v2.6 ЗАПУЩЕН")
print("Режим: Targeted Remotes")
print("========================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function GetTargetRemotes()
    local targets = {}
    local folders = {"Remotes", "ClientServices", "SharedPackages", "PetSystem"}
    
    for _, folderName in pairs(folders) do
        local folder = ReplicatedStorage:FindFirstChild(folderName) or ReplicatedStorage
        for _, v in pairs(folder:GetDescendants()) do
            if v:IsA("RemoteEvent") and (v.Name:find("Pet") or v.Name:find("Trade") or v.Name:find("Give") or v.Name:find("Spawn")) then
                table.insert(targets, v)
            end
        end
    end
    return targets
end

local function SpawnPetFixed(petName, amount)
    amount = math.min(tonumber(amount) or 1, 2)
    print("[v2.6] Пытаемся заспавнить " .. amount .. "x " .. petName)
    
    local remotes = GetTargetRemotes()
    print("[v2.6] Найдено целевых remotes: " .. #remotes)
    
    for i = 1, amount do
        for _, remote in pairs(remotes) do
            pcall(function()
                -- Самые рабочие варианты аргументов на 2026
                remote:FireServer({
                    Type = "Pet",
                    Action = "Give",
                    PetName = petName,
                    Tier = "Legendary",
                    Neon = true,
                    Mega = false
                })
                
                remote:FireServer(petName, "AddToInventory", LocalPlayer)
            end)
        end
        wait(1.8)
    end
    
    print("[v2.6] Попытка завершена. Проверь инвентарь через 20 секунд.")
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BinPetSpawner_v2_6"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 360)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 50)
Title.BackgroundColor3 = Color3.fromRGB(110, 0, 0)
Title.Text = "Adopt Me Pet Spawner v2.6"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Parent = MainFrame

local PetNameBox = Instance.new("TextBox")
PetNameBox.Size = UDim2.new(0.85, 0, 0, 50)
PetNameBox.Position = UDim2.new(0.075, 0, 0.22, 0)
PetNameBox.PlaceholderText = "Shadow Dragon / Frost Fury"
PetNameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PetNameBox.TextColor3 = Color3.new(1,1,1)
PetNameBox.TextScaled = true
PetNameBox.Parent = MainFrame

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0.85, 0, 0, 50)
AmountBox.Position = UDim2.new(0.075, 0, 0.42, 0)
AmountBox.Text = "1"
AmountBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AmountBox.TextColor3 = Color3.new(1,1,1)
AmountBox.TextScaled = true
AmountBox.Parent = MainFrame

local SpawnButton = Instance.new("TextButton")
SpawnButton.Size = UDim2.new(0.85, 0, 0, 60)
SpawnButton.Position = UDim2.new(0.075, 0, 0.65, 0)
SpawnButton.BackgroundColor3 = Color3.fromRGB(150, 20, 20)
SpawnButton.Text = "СПАВНИТЬ v2.6"
SpawnButton.TextColor3 = Color3.new(1,1,1)
SpawnButton.TextScaled = true
SpawnButton.Parent = MainFrame

SpawnButton.MouseButton1Click:Connect(function()
    SpawnPetFixed(PetNameBox.Text, AmountBox.Text)
end)

print("[v2.6] Готово. Попробуй.")
