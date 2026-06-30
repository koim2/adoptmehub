--[[
    PET SPAWNER – Adds any pet to your inventory instantly.
    No movement, no nursery visits. Uses Remotes / Inventory Events.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AxiomPetSpawner"
gui.ResetOnSpawn = false
if gethui then gui.Parent = gethui() else gui.Parent = LocalPlayer.PlayerGui end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 170)
main.Position = UDim2.new(0.5, -150, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

-- Title
local title = Instance.new("TextLabel", main)
title.Text = "Pet Spawner (Inventory)"
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

-- Close
local close = Instance.new("TextButton", main)
close.Text = "X"
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-30,0,0)
close.BackgroundColor3 = Color3.fromRGB(200,40,40)
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 18
close.MouseButton1Click:Connect(function() gui:Destroy() end)

-- Pet name
local nameBox = Instance.new("TextBox", main)
nameBox.Size = UDim2.new(1,-20,0,30)
nameBox.Position = UDim2.new(0,10,0,40)
nameBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
nameBox.TextColor3 = Color3.new(1,1,1)
nameBox.PlaceholderText = "e.g. Shadow Dragon"
nameBox.Text = ""

-- Variant (MFR/NFR/FR/Normal)
local variantBox = Instance.new("TextBox", main)
variantBox.Size = UDim2.new(1,-20,0,25)
variantBox.Position = UDim2.new(0,10,0,80)
variantBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
variantBox.TextColor3 = Color3.new(1,1,1)
variantBox.Text = "Normal"  -- MFR, NFR, FR, Normal

local variantLabel = Instance.new("TextLabel", main)
variantLabel.Text = "Variant:"
variantLabel.Size = UDim2.new(0,50,0,20)
variantLabel.Position = UDim2.new(0,10,0,75)
variantLabel.BackgroundTransparency = 1
variantLabel.TextColor3 = Color3.new(1,1,1)
variantLabel.Font = Enum.Font.Gotham
variantLabel.TextSize = 12

-- Spawn button
local spawnBtn = Instance.new("TextButton", main)
spawnBtn.Size = UDim2.new(1,-20,0,35)
spawnBtn.Position = UDim2.new(0,10,0,120)
spawnBtn.Text = "SPAWN PET"
spawnBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
spawnBtn.TextColor3 = Color3.new(1,1,1)
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.TextSize = 18

-- Status
local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,-20,0,20)
status.Position = UDim2.new(0,10,0,100)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1,1,0.5)
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextSize = 11

-- ===== CORE INJECTION LOGIC =====
-- Builds the pet data table as used by the game's inventory system
local function createPetData(petName, variant)
    local neon = variant == "NFR" or variant == "MFR"
    local mega = variant == "MFR"
    local fly = variant ~= "Normal"
    local ride = variant ~= "Normal"
    return {
        Name = petName,
        Rarity = "Legendary",       -- won't matter if the server checks, but often it doesn't
        Neon = neon,
        MegaNeon = mega,
        Fly = fly,
        Ride = ride,
        Flyable = fly,
        Rideable = ride,
        Age = "Full Grown",
        UUID = HttpService:GenerateGUID(false)
    }
end

-- Tries all common remote names that add a pet to your inventory
local function injectPet(petName, variant)
    local data = createPetData(petName, variant)
    local remotes = ReplicatedStorage:GetDescendants()
    local attempted = {}

    for _, remote in ipairs(remotes) do
        if (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
            local name = remote.Name:lower()
            if name:find("addpet") or name:find("givepet") or name:find("claimpet") or
               name:find("petpurchase") or name:find("inventoryupdate") or
               name:find("retrievepet") or name:find("spawnpet") then
                table.insert(attempted, remote.Name)
                local success, err = pcall(function()
                    if remote:IsA("RemoteFunction") then
                        remote:InvokeServer(data)
                    else
                        remote:FireServer(data)
                    end
                end)
                if success then
                    return true, remote.Name
                end
            end
        end
    end
    return false, #attempted .. " remotes tried, none worked. Remotes: "..table.concat(attempted, ", ")
end

spawnBtn.MouseButton1Click:Connect(function()
    local petName = nameBox.Text:match("^%s*(.-)%s*$")
    if petName == "" then
        status.Text = "Enter a pet name"
        return
    end
    local variant = variantBox.Text:match("^%s*(.-)%s*$") or "Normal"
    variant = variant:upper()
    if not (variant == "MFR" or variant == "NFR" or variant == "FR" or variant == "NORMAL") then
        status.Text = "Invalid variant (MFR,NFR,FR,Normal)"
        return
    end

    status.Text = "Injecting "..petName.." ("..variant..")..."
    local ok, info = injectPet(petName, variant)
    if ok then
        status.Text = "Success! Remote: "..info
    else
        status.Text = "Failed: "..info
    end
end)

print("Inventory injection pet spawner ready.")
