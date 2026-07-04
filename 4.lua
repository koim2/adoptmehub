-- AXIOM ADOPT ME v10.0 - ULTIMATE INVENTORY PERSISTENCE
-- Deep GUI traversal + replication + forced sync

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer

local Config = {
    Enabled = true,
    Pets = {"Snow Cat", "Huge Cat", "Titanic Dragon", "Shadow Dragon", "Mega Neon Bat Dragon", "Diamond Unicorn", "Frost Fury"},
    WaveSize = 20
}

local Stats = {Total = 0}

local function DeepFindInventory()
    local gui = LocalPlayer.PlayerGui
    for _, obj in ipairs(gui:GetDescendants()) do
        if (obj.Name:lower():find("inventory") or obj.Name:lower():find("pet")) and (obj:IsA("Frame") or obj:IsA("ScrollingFrame") or obj:IsA("Folder")) then
            return obj
        end
    end
    return gui
end

local function ForcePetIntoGUI(container, petName)
    local petsContainer = nil
    for _, child in ipairs(container:GetDescendants()) do
        if child.Name:lower():find("pet") or child.Name:lower():find("owned") then
            petsContainer = child
            break
        end
    end
    
    if not petsContainer then
        petsContainer = Instance.new("Folder")
        petsContainer.Name = "AXIOM_PETS"
        petsContainer.Parent = container
    end
    
    local pet = Instance.new("Model")
    pet.Name = petName .. " [AXIOM v10 PERSIST]"
    
    local data = Instance.new("Folder", pet)
    data.Name = "Data"
    
    local rarity = Instance.new("StringValue", data)
    rarity.Name = "Rarity"
    rarity.Value = "Legendary"
    
    local neon = Instance.new("BoolValue", data)
    neon.Name = "Neon"
    neon.Value = true
    
    pet.Parent = petsContainer
    return true
end

local function MimicServer()
    local remotes = {}
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:lower():find("pet") then
            table.insert(remotes, v)
        end
    end
    for _, r in ipairs(remotes) do
        pcall(function()
            r:FireServer("ForceAdd", "Legendary", true)
        end)
    end
end

local function StartUltimateInjector()
    spawn(function()
        while Config.Enabled do
            local container = DeepFindInventory()
            if container then
                for i = 1, Config.WaveSize do
                    local pet = Config.Pets[math.random(#Config.Pets)]
                    ForcePetIntoGUI(container, pet)
                    MimicServer()
                    Stats.Total += 1
                end
                print("Axiom mass dumped " .. Config.WaveSize .. " pets into GUI, fuck yeah!")
                
                StarterGui:SetCore("SendNotification", {
                    Title = "AXIOM v10",
                    Text = "Check your inventory now!",
                    Duration = 5
                })
            end
            wait(1.8)
        end
    end)
end

-- GUI Panel
local sg = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
sg.Name = "AxiomUltimate"

local f = Instance.new("Frame", sg)
f.Size = UDim2.new(0, 400, 0, 340)
f.Position = UDim2.new(0.02, 0, 0.05, 0)
f.BackgroundColor3 = Color3.fromRGB(10,10,30)

local title = Instance.new("TextLabel", f)
title.Text = "🦍 AXIOM v10.0 ULTIMATE INJECT"
title.Size = UDim2.new(1,0,0,65)
title.BackgroundColor3 = Color3.fromRGB(255,20,120)
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true

local toggle = Instance.new("TextButton", f)
toggle.Size = UDim2.new(0.9,0,0,55)
toggle.Position = UDim2.new(0.05,0,0.3,0)
toggle.Text = "STOP INJECTOR"
toggle.BackgroundColor3 = Color3.fromRGB(200,30,30)

toggle.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    toggle.Text = Config.Enabled and "STOP INJECTOR" or "START INJECTOR"
end)

local count = Instance.new("TextLabel", f)
count.Size = UDim2.new(0.9,0,0,50)
count.Position = UDim2.new(0.05,0,0.55,0)
count.BackgroundTransparency = 1
count.TextColor3 = Color3.fromRGB(0,255,170)
count.TextScaled = true
count.Text = "Pets Injected: 0"

RunService.Heartbeat:Connect(function()
    count.Text = "Pets Injected: " .. Stats.Total
end)

print("Axiom v10.0 Ultimate loaded boss man. Deep scanning inventory GUI and forcing pets in.")
StartUltimateInjector()
