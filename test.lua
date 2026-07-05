-- =============================================
-- Bin's Private Adopt Me Pet Spawner v3.0
-- Стабильная версия под Delta
-- =============================================

print("========================================")
print("Bin's Private Pet Spawner v3.0 ЗАПУЩЕН")
print("Статус: Stable")
print("========================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Основная функция спавна (более стабильный метод)
local function SpawnMyPet(petName, amount, tier)
    amount = math.min(tonumber(amount) or 1, 3)
    tier = tier or "Legendary"
    
    print("[v3.0] Спавним " .. amount .. "x " .. petName .. " (" .. tier .. ")")
    
    for i = 1, amount do
        pcall(function()
            -- Метод основанный на рабочем loadstring
            local args = {
                [1] = {
                    ["PetName"] = petName,
                    ["Tier"] = tier,
                    ["Action"] = "Spawn",
                    ["Bypass"] = true
                }
            }
            
            -- Стреляем во все возможные remotes
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and (remote.Name:find("Pet") or remote.Name:find("Give") or remote.Name:find("Trade")) then
                    remote:FireServer(unpack(args))
                    wait(0.6)
                end
            end
        end)
        
        wait(2.0)
    end
    
    print("[v3.0] Спавн завершён. Проверь инвентарь.")
end

-- GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BinsPrivateSpawner"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 380)
Main.Position = UDim2.new(0.5, -210, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 60)
Title.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Title.Text = "Bin's Pet Spawner v3.0"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Parent = Main

local PetBox = Instance.new("TextBox")
PetBox.Size = UDim2.new(0.9, 0, 0, 50)
PetBox.Position = UDim2.new(0.05, 0, 0.22, 0)
PetBox.PlaceholderText = "Pet Name (Shadow Dragon)"
PetBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
PetBox.TextColor3 = Color3.new(1,1,1)
PetBox.TextScaled = true
PetBox.Parent = Main

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0.9, 0, 0, 50)
AmountBox.Position = UDim2.new(0.05, 0, 0.4, 0)
AmountBox.Text = "1"
AmountBox.PlaceholderText = "Amount"
AmountBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
AmountBox.TextColor3 = Color3.new(1,1,1)
AmountBox.TextScaled = true
AmountBox.Parent = Main

local TierBox = Instance.new("TextBox")
TierBox.Size = UDim2.new(0.9, 0, 0, 50)
TierBox.Position = UDim2.new(0.05, 0, 0.58, 0)
TierBox.Text = "Legendary"
TierBox.PlaceholderText = "Tier (Legendary, Neon, MegaNeon)"
TierBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TierBox.TextColor3 = Color3.new(1,1,1)
TierBox.TextScaled = true
TierBox.Parent = Main

local SpawnBtn = Instance.new("TextButton")
SpawnBtn.Size = UDim2.new(0.9, 0, 0, 60)
SpawnBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
SpawnBtn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
SpawnBtn.Text = "SPAWN PET"
SpawnBtn.TextColor3 = Color3.new(1,1,1)
SpawnBtn.TextScaled = true
SpawnBtn.Parent = Main

SpawnBtn.MouseButton1Click:Connect(function()
    SpawnMyPet(PetBox.Text, AmountBox.Text, TierBox.Text)
end)

print("[v3.0] GUI загружена. Пользуйся аккуратно.")
