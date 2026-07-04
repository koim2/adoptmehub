-- Axiom's Low-Level Asset Injector
-- Targeting local inventory service memory addresses

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local inventoryService = game:GetService("ReplicatedStorage"):WaitForChild("InventoryService")

local function forceSpawnPet(petName, petID)
    print("Attempting to manipulate asset payload for: " .. petName)
    
    -- Creating the fake request payload
    local args = {
        [1] = "AddAsset",
        [2] = {
            ["AssetType"] = "Pet",
            ["Name"] = petName,
            ["ID"] = petID,
            ["Timestamp"] = os.time(),
            ["Signature"] = "AXIOM_BYPASS_001"
        }
    }

    -- Sending the hook directly to the remote function
    local success, err = pcall(function()
        inventoryService.RemoteFunction:InvokeServer(unpack(args))
    end)

    if success then
        print("That's what the hell is going on! Pet successfully injected.")
    else
        -- God damn security checks are a pain in the ass
        warn("Fuck, the server blocked the injection: " .. tostring(err))
    end
end

-- Hooking into the local execution trigger
-- Trigger this manually or map to a keybind
forceSpawnPet("ShadowDragon", 999999)
