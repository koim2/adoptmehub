-- Bin's Adopt Me Pet Spawner v3.1 (Inspired by working one)
print("========================================")
print("Bin's Private Spawner v3.1 ЗАПУЩЕН")
print("Вдохновлено рабочим скриптом")
print("========================================")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local function FireAllRemotes(petName, tier)
    tier = tier or "Legendary"
    
    local payloads = {
        {PetName = petName, Tier = tier, Action = "GivePet"},
        {["Pet"] = petName, ["Type"] = "Legendary", ["Bypass"] = true},
        {1 = petName, 2 = tier, 3 = true}
    }
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            for _, payload in pairs(payloads) do
                pcall(function()
                    remote:FireServer(payload)
                    remote:FireServer(unpack(payload))
                end)
            end
        end
    end
end

local function SpawnPet(name, count, tier)
    count = math.min(tonumber(count) or 1, 2)
    print("[v3.1] Спавн " .. count .. "x " .. name)
    
    for i = 1, count do
        FireAllRemotes(name, tier)
        wait(1.5)
    end
    print("[v3.1] Готово. Проверь инвентарь.")
end

-- GUI
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 320)
frame.Position = UDim2.new(0.5, -200, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.Text = "Bin's Spawner v3.1"
title.BackgroundColor3 = Color3.fromRGB(130, 0, 0)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = frame

local petBox = Instance.new("TextBox")
petBox.Size = UDim2.new(0.9,0,0,45)
petBox.Position = UDim2.new(0.05,0,0.2,0)
petBox.PlaceholderText = "Pet Name"
petBox.Parent = frame

local countBox = Instance.new("TextBox")
countBox.Size = UDim2.new(0.9,0,0,45)
countBox.Position = UDim2.new(0.05,0,0.38,0)
countBox.Text = "1"
countBox.Parent = frame

local tierBox = Instance.new("TextBox")
tierBox.Size = UDim2.new(0.9,0,0,45)
tierBox.Position = UDim2.new(0.05,0,0.56,0)
tierBox.Text = "Legendary"
tierBox.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9,0,0,55)
btn.Position = UDim2.new(0.05,0,0.75,0)
btn.Text = "SPAWN"
btn.BackgroundColor3 = Color3.fromRGB(160, 10, 10)
btn.TextColor3 = Color3.new(1,1,1)
btn.TextScaled = true
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    SpawnPet(petBox.Text, countBox.Text, tierBox.Text)
end)

print("[v3.1] Готово. Попробуй сейчас.")
