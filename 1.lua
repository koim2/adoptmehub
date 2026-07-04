-- Adopt Me Pet Spawner by Bin
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

print("Adopt Me Pet Spawner загружен. Пиши название пета.")

-- Основные Remote
local petRemote = ReplicatedStorage:FindFirstChild("PetRemote") or ReplicatedStorage:WaitForChild("Remotes", 5):FindFirstChild("PetSystem") 

local function SpawnPet(petName, amount)
    amount = amount or 1
    
    for i = 1, amount do
        -- Основной способ через Pet System
        local args = {
            [1] = "SpawnPet",
            [2] = petName,
            [3] = "Legendary",  -- Common, Uncommon, Rare, UltraRare, Legendary
            [4] = LocalPlayer.Character and LocalPlayer.Character.HumanoidRootPart.Position or Vector3.new(0,0,0)
        }
        
        -- Пробуем разные remotes
        local success = false
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") and (remote.Name:find("Pet") or remote.Name:find("Spawn")) then
                pcall(function()
                    remote:FireServer(unpack(args))
                end)
                success = true
            end
        end
        
        if not success then
            -- Альтернативный метод
            local buyPet = ReplicatedStorage:FindFirstChild("BuyPet") or ReplicatedStorage.Remotes:FindFirstChild("BuyPet")
            if buyPet then
                buyPet:FireServer(petName, "MegaNeon") -- или Neon, Fly, etc.
            end
        end
        
        wait(0.3) -- анти-античит
    end
    print(amount .. "x " .. petName .. " заспавнено!")
end

-- Команды
LocalPlayer.Chatted:Connect(function(msg)
    if msg:sub(1,1) == "." then
        local cmd = msg:lower():split(" ")
        if cmd[1] == ".pet" and cmd[2] then
            local amount = tonumber(cmd[3]) or 1
            SpawnPet(cmd[2], amount)
        end
    end
end)

-- Примеры использования в чате:
-- .pet Dragon 5
-- .pet Frost 10
-- .pet Neon Owl

print("Используй .pet [название] [кол-во]")
print("Примеры: Dragon, Unicorn, Frost Fury, Shadow Dragon, Bat Dragon и т.д.")
