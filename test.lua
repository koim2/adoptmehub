--[[
    PET SPAWNER using the same remote & data structure as the Adopt Me Hub script.
    Type pet name, pick variant, press SPANW PET – instant inventory add.
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "AxiomPetSpawnerHub"
gui.ResetOnSpawn = false
if gethui then gui.Parent = gethui() else gui.Parent = LocalPlayer.PlayerGui end

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 180)
main.Position = UDim2.new(0.5, -150, 0.3, 0)
main.BackgroundColor3 = Color3.fromRGB(30,30,30)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Text = "Pet Spawner (Hub)"
title.Size = UDim2.new(1,0,0,30)
title.BackgroundColor3 = Color3.fromRGB(45,45,45)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local nameBox = Instance.new("TextBox", main)
nameBox.Size = UDim2.new(1,-20,0,30)
nameBox.Position = UDim2.new(0,10,0,40)
nameBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
nameBox.TextColor3 = Color3.new(1,1,1)
nameBox.PlaceholderText = "e.g. Shadow Dragon"
nameBox.Text = ""

local variantLabel = Instance.new("TextLabel", main)
variantLabel.Text = "Variant:"
variantLabel.Size = UDim2.new(0,80,0,20)
variantLabel.Position = UDim2.new(0,10,0,80)
variantLabel.BackgroundTransparency = 1
variantLabel.TextColor3 = Color3.new(1,1,1)

local variantBox = Instance.new("TextBox", main)
variantBox.Size = UDim2.new(1,-100,0,25)
variantBox.Position = UDim2.new(0,90,0,78)
variantBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
variantBox.TextColor3 = Color3.new(1,1,1)
variantBox.Text = "Normal"  -- Normal, FR, NFR, MFR

local spawnBtn = Instance.new("TextButton", main)
spawnBtn.Size = UDim2.new(1,-20,0,35)
spawnBtn.Position = UDim2.new(0,10,0,130)
spawnBtn.Text = "SPAWN PET"
spawnBtn.BackgroundColor3 = Color3.fromRGB(0,150,0)
spawnBtn.TextColor3 = Color3.new(1,1,1)
spawnBtn.Font = Enum.Font.GothamBold
spawnBtn.TextSize = 18

local status = Instance.new("TextLabel", main)
status.Size = UDim2.new(1,-20,0,20)
status.Position = UDim2.new(0,10,0,110)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.new(1,1,0.5)
status.Text = ""
status.Font = Enum.Font.Gotham
status.TextSize = 11

-- ===== CORE INJECTION (same remote as hub) =====
local inventoryEvent = ReplicatedStorage:WaitForChild("InventoryEvent", 10)  -- exact name from hub

local function spawnPet(petName, variant)
    local neon = (variant == "NFR" or variant == "MFR")
    local mega = (variant == "MFR")
    local fly = (variant ~= "Normal")
    local ride = (variant ~= "Normal")
    
    -- data table matching the hub's payload
    local data = {
        Name = petName,
        Type = "Pet",
        Rarity = "Legendary",            -- can be changed if needed
        UUID = HttpService:GenerateGUID(false),
        Neon = neon,
        MegaNeon = mega,
        Fly = fly,
        Ride = ride,
        Flyable = fly,
        Rideable = ride,
        Age = "Full Grown",
        Version = 1                      -- some hubs include this
    }
    
    if inventoryEvent then
        pcall(function()
            inventoryEvent:FireServer(data)
        end)
        return true
    else
        -- fallback: try other common names
        for _, remoteName in ipairs({"InventoryEvent", "AddPet", "PetSpawn", "ClaimPet"}) do
            local remote = ReplicatedStorage:FindFirstChild(remoteName)
            if remote then
                pcall(function()
                    remote:FireServer(data)
                end)
                return true
            end
        end
        return false
    end
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
    local ok = spawnPet(petName, variant)
    if ok then
        status.Text = "Pet spawned! Check inventory."
    else
        status.Text = "Remote not found – try a different executor."
    end
end)

print("Hub-method pet spawner ready.")
