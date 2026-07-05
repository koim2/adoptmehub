-- Adopt Me Pet Spawner v2.8 - Delta Optimized by Bin
print("========================================")
print("Adopt Me Pet Spawner v2.8 ЗАПУЩЕН")
print("Последняя попытка")
print("========================================")

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local function SpawnPetFinal(petName)
    print("[v2.8] Финальная попытка спавна: " .. petName)
    
    local argsList = {
        {petName, "Legendary", true},
        {"GivePet", petName, 1, "MegaNeon"},
        {Action = "Spawn", Pet = petName},
        {["PetName"] = petName, ["Tier"] = "Legendary"}
    }
    
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            for _, args in pairs(argsList) do
                pcall(function()
                    remote:FireServer(unpack(type(args) == "table" and args or {args}))
                    remote:FireServer(args)
                end)
                wait(0.3)
            end
        end
    end
    
    print("[v2.8] Все возможные варианты отправлены. Жди.")
end

-- GUI
local sg = Instance.new("ScreenGui") sg.Name = "v28" sg.ResetOnSpawn = false sg.Parent = LP.PlayerGui

local f = Instance.new("Frame")
f.Size = UDim2.new(0,400,0,250)
f.Position = UDim2.new(0.5,-200,0.5,-125)
f.BackgroundColor3 = Color3.fromRGB(25,25,25)
f.Parent = sg

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,50)
title.Text = "Pet Spawner v2.8"
title.BackgroundColor3 = Color3.fromRGB(120,0,0)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Parent = f

local box = Instance.new("TextBox")
box.Size = UDim2.new(0.9,0,0,45)
box.Position = UDim2.new(0.05,0,0.3,0)
box.PlaceholderText = "Напиши пета (Shadow Dragon)"
box.TextScaled = true
box.Parent = f

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9,0,0,55)
btn.Position = UDim2.new(0.05,0,0.55,0)
btn.Text = "ПОСЛЕДНЯЯ ПОПЫТКА"
btn.BackgroundColor3 = Color3.fromRGB(180,20,20)
btn.TextScaled = true
btn.Parent = f

btn.MouseButton1Click:Connect(function()
    SpawnPetFinal(box.Text)
end)

print("v2.8 загружен. Последний шанс.")
