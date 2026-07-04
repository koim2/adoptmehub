-- =============================================
-- Adopt Me Pet Spawner v2.5 - by Bin (Anti-Kick)
-- =============================================
print("========================================")
print("Adopt Me Pet Spawner v2.5 ЗАПУЩЕН")
print("Режим: Stealth / Low Detection")
print("========================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function SpawnPetStealth(petName, amount)
    amount = math.min(tonumber(amount) or 1, 3) -- сильно уменьшил количество за раз
    print("[v2.5] Запуск stealth спавна " .. amount .. "x " .. petName)
    
    for i = 1, amount do
        pcall(function()
            local args = {
                [1] = "RequestPet",
                [2] = petName,
                [3] = "Legendary",
                [4] = false,
                [5] = LocalPlayer.UserId
            }
            
            for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                if remote:IsA("RemoteEvent") and (remote.Name:find("Pet") or remote.Name:find("Give") or remote.Name:find("Trade")) then
                    remote:FireServer(unpack(args))
                    wait(0.4) -- очень важная задержка
                end
            end
        end)
        
        wait(2.5) -- большая пауза между петами
    end
    
    print("[v2.5] Спавн завершён. Подожди 15-30 секунд и проверь инвентарь.")
end

-- GUI v2.5
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BinPetSpawner_v2_5"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer.PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 360)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 55)
Title.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Title.Text = "Adopt Me Pet Spawner v2.5 - Stealth"
Title.TextColor3 = Color3.fromRGB(255, 70, 70)
Title.TextScaled = true
Title.Parent = MainFrame

local PetNameBox = Instance.new("TextBox")
PetNameBox.Size = UDim2.new(0.85, 0, 0, 50)
PetNameBox.Position = UDim2.new(0.075, 0, 0.23, 0)
PetNameBox.PlaceholderText = "Название пета"
PetNameBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
PetNameBox.TextColor3 = Color3.new(1,1,1)
PetNameBox.TextScaled = true
PetNameBox.Parent = MainFrame

local AmountBox = Instance.new("TextBox")
AmountBox.Size = UDim2.new(0.85, 0, 0, 50)
AmountBox.Position = UDim2.new(0.075, 0, 0.43, 0)
AmountBox.Text = "1"
AmountBox.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
AmountBox.TextColor3 = Color3.new(1,1,1)
AmountBox.TextScaled = true
AmountBox.Parent = MainFrame

local SpawnButton = Instance.new("TextButton")
SpawnButton.Size = UDim2.new(0.85, 0, 0, 65)
SpawnButton.Position = UDim2.new(0.075, 0, 0.65, 0)
SpawnButton.BackgroundColor3 = Color3.fromRGB(130, 10, 10)
SpawnButton.Text = "СПАВНИТЬ (Stealth)"
SpawnButton.TextColor3 = Color3.new(1,1,1)
SpawnButton.TextScaled = true
SpawnButton.Parent = MainFrame

SpawnButton.MouseButton1Click:Connect(function()
    SpawnPetStealth(PetNameBox.Text, AmountBox.Text)
end)

print("[v2.5] Stealth режим активен. Не спамь сильно.")
