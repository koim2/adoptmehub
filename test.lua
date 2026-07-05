-- Adopt Me Simple Spawner v2.7 for Delta
print("Adopt Me Pet Spawner v2.7 (Delta version) ЗАПУЩЕН")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer

local function TrySpawn(petName)
    print("[v2.7] Пробуем " .. petName)
    
    -- Специально для Delta / новых античитов
    local success = false
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") and remote.Name == "Client" or remote.Name:find("Pet") then
            pcall(function()
                remote:FireServer("SpawnPet", petName, "Legendary", true)
                remote:FireServer({Pet = petName, Action = "Give"})
            end)
            success = true
        end
    end
    
    if not success then
        print("[v2.7] Не удалось найти рабочие remotes. Возможно нужен другой executor.")
    end
end

-- GUI упрощённая
local sg = Instance.new("ScreenGui")
sg.Parent = LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 200)
frame.Position = UDim2.new(0.5, -175, 0.5, -100)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = sg

local box = Instance.new("TextBox")
box.Size = UDim2.new(0.9,0,0,40)
box.Position = UDim2.new(0.05,0,0.2,0)
box.PlaceholderText = "Shadow Dragon"
box.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9,0,0,50)
btn.Position = UDim2.new(0.05,0,0.5,0)
btn.Text = "СПАВНИТЬ"
btn.BackgroundColor3 = Color3.fromRGB(150,0,0)
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    TrySpawn(box.Text)
end)

print("v2.7 готов. Попробуй.")
