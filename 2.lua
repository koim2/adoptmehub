-- Bin's Premium Adopt Me Pet Spawner v4.0
-- Чистая версия, вдохновлено премиум скриптом

print("========================================")
print("Bin's Premium Pet Spawner v4.0 ЗАПУЩЕН")
print("Стабильный / Stealth режим")
print("========================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Кэширование remotes (как в премиум)
local CachedRemotes = {}
for _, v in pairs(ReplicatedStorage:GetDescendants()) do
    if v:IsA("RemoteEvent") and (v.Name:find("Pet") or v.Name:find("Give") or v.Name:find("Trade") or v.Name:find("Spawn")) then
        table.insert(CachedRemotes, v)
    end
end

print("[v4.0] Найдено remotes: " .. #CachedRemotes)

local function SpawnPet(name, amount, tier)
    amount = math.min(tonumber(amount) or 1, 1) -- только 1 за раз для стабильности
    tier = tier or "Legendary"
    
    print("[v4.0] Спавн " .. amount .. "x " .. name .. " (" .. tier .. ")")
    
    for i = 1, amount do
        for _, remote in ipairs(CachedRemotes) do
            pcall(function()
                remote:FireServer({
                    PetName = name,
                    Tier = tier,
                    Action = "GivePet",
                    Bypass = true
                })
                
                remote:FireServer(name, tier, true)
            end)
        end
        wait(2.5) -- большая задержка
    end
    
    print("[v4.0] Спавн отправлен. Проверь инвентарь через 20-40 секунд.")
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.Name = "BinPremiumSpawner"
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 450, 0, 380)
frame.Position = UDim2.new(0.5, -225, 0.5, -190)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 60)
title.Text = "Bin's Premium Spawner v4.0"
title.BackgroundColor3 = Color3.fromRGB(140, 0, 0)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local petBox = Instance.new("TextBox")
petBox.Size = UDim2.new(0.9,0,0,50)
petBox.Position = UDim2.new(0.05,0,0.22,0)
petBox.PlaceholderText = "Pet Name (Shadow Dragon)"
petBox.TextScaled = true
petBox.Parent = frame

local amountBox = Instance.new("TextBox")
amountBox.Size = UDim2.new(0.9,0,0,50)
amountBox.Position = UDim2.new(0.05,0,0.4,0)
amountBox.Text = "1"
amountBox.TextScaled = true
amountBox.Parent = frame

local tierBox = Instance.new("TextBox")
tierBox.Size = UDim2.new(0.9,0,0,50)
tierBox.Position = UDim2.new(0.05,0,0.58,0)
tierBox.Text = "Legendary"
tierBox.TextScaled = true
tierBox.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9,0,0,60)
btn.Position = UDim2.new(0.05,0,0.78,0)
btn.Text = "SPAWN (STEALTH)"
btn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
btn.TextColor3 = Color3.new(1,1,1)
btn.TextScaled = true
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    SpawnPet(petBox.Text, amountBox.Text, tierBox.Text)
end)

print("[v4.0] GUI загружена. Спавнь по 1 пету с перерывами.")
