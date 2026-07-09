-- adoptme_packet_interceptor_v2.4.lua
-- Version: 2.4 (AGGRESSIVE MODE - Captures ALL packets for analysis)
-- Changes: Removed keyword filter. Captures EVERY FireServer/InvokeServer call.
--          Detailed logging to identify pet-related packets.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- ===================== CONFIG =====================
local Config = {
    InterceptEnabled = false,
    CaptureAll = true, -- v2.4: Capture ALL packets, not just "relevant" ones
    MaxPackets = 50    -- Limit cache size
}

-- ===================== PACKET CACHE =====================
local PacketCache = {}
local OriginalNamecall = nil
local PacketCount = 0

-- ===================== UI SETUP =====================
local statusLabel, enableBtn, disableBtn, clearBtn

local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PacketInterceptor"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 340, 0, 300)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.Text = "Packet Interceptor v2.4 [AGGRESSIVE]"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STATUS: SAFE MODE"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    local packetCountLabel = Instance.new("TextLabel")
    packetCountLabel.Name = "PacketCountLabel"
    packetCountLabel.Size = UDim2.new(1, -20, 0, 20)
    packetCountLabel.Position = UDim2.new(0, 10, 0, 70)
    packetCountLabel.BackgroundTransparency = 1
    packetCountLabel.Text = "Packets captured: 0"
    packetCountLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    packetCountLabel.Font = Enum.Font.Gotham
    packetCountLabel.TextSize = 11
    packetCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    packetCountLabel.Parent = frame

    enableBtn = Instance.new("TextButton")
    enableBtn.Size = UDim2.new(0.48, -10, 0, 35)
    enableBtn.Position = UDim2.new(0, 10, 0, 100)
    enableBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    enableBtn.Text = "ENABLE"
    enableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enableBtn.Font = Enum.Font.GothamBold
    enableBtn.TextSize = 12
    enableBtn.Parent = frame
    enableBtn.MouseButton1Click:Connect(function()
        Config.InterceptEnabled = true
        statusLabel.Text = "STATUS: CAPTURING ALL PACKETS"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        enableBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        enableBtn.Text = "ACTIVE"
        print("[+] AGGRESSIVE MODE ENABLED - Capturing ALL packets")
    end)

    disableBtn = Instance.new("TextButton")
    disableBtn.Size = UDim2.new(0.48, -10, 0, 35)
    disableBtn.Position = UDim2.new(0.5, 5, 0, 100)
    disableBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    disableBtn.Text = "DISABLE"
    disableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    disableBtn.Font = Enum.Font.GothamBold
    disableBtn.TextSize = 12
    disableBtn.Parent = frame
    disableBtn.MouseButton1Click:Connect(function()
        Config.InterceptEnabled = false
        statusLabel.Text = "STATUS: SAFE MODE"
        statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        enableBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        enableBtn.Text = "ENABLE"
        print("[+] Interceptor DISABLED")
    end)

    local replayBtn = Instance.new("TextButton")
    replayBtn.Size = UDim2.new(0.48, -10, 0, 35)
    replayBtn.Position = UDim2.new(0, 10, 0, 145)
    replayBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
    replayBtn.Text = "REPLAY LAST"
    replayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    replayBtn.Font = Enum.Font.GothamBold
    replayBtn.TextSize = 12
    replayBtn.Parent = frame
    replayBtn.MouseButton1Click:Connect(function()
        ReplayLastPacket()
    end)

    clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.48, -10, 0, 35)
    clearBtn.Position = UDim2.new(0.5, 5, 0, 145)
    clearBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
    clearBtn.Text = "CLEAR CACHE"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 12
    clearBtn.Parent = frame
    clearBtn.MouseButton1Click:Connect(function()
        PacketCache = {}
        PacketCount = 0
        local countLabel = frame:FindFirstChild("PacketCountLabel")
        if countLabel then countLabel.Text = "Packets captured: 0" end
        print("[+] Cache cleared")
    end)

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 50)
    infoLabel.Position = UDim2.new(0, 10, 0, 190)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "v2.4: Captures ALL packets. Enable, equip pet, check console for captured data."
    infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 10
    infoLabel.TextWrapped = true
    infoLabel.Parent = frame

    return screenGui
end

-- ===================== REPLAY FUNCTION =====================
function ReplayLastPacket()
    if #PacketCache == 0 then
        warn("[!] No packets captured yet.")
        return
    end

    local lastPacket = PacketCache[#PacketCache]
    local remote = lastPacket.Remote
    local rawArgs = lastPacket.Args

    local payloadArgs = {}
    for i = 2, #rawArgs do
        table.insert(payloadArgs, rawArgs[i])
    end

    print("[+] Replaying packet:", remote.Name)
    for i, arg in ipairs(payloadArgs) do
        print("  Arg", i, ":", typeof(arg), tostring(arg))
    end

    local success, err = pcall(function()
        remote:FireServer(unpack(payloadArgs))
    end)

    if not success then
        warn("[!] Replay failed:", err)
    else
        print("[+] Replay sent.")
    end
end

-- ===================== HOOKING (AGGRESSIVE MODE) =====================
OriginalNamecall = hookmetamethod(game, "__namecall", function(...)
    local args = {...}
    local self = args[1]
    local method = getnamecallmethod()

    local result = {OriginalNamecall(...)}

    if Config.InterceptEnabled and (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        PacketCount = PacketCount + 1
        
        -- Cache packet
        table.insert(PacketCache, {
            Remote = self,
            Args = args,
            Method = method
        })

        -- Limit cache size
        if #PacketCache > Config.MaxPackets then
            table.remove(PacketCache, 1)
        end

        -- Update UI counter
        local gui = game:GetService("CoreGui"):FindFirstChild("PacketInterceptor")
        if gui then
            local countLabel = gui:FindFirstChild("Frame"):FindFirstChild("PacketCountLabel")
            if countLabel then
                countLabel.Text = "Packets captured: " .. PacketCount
            end
        end

        -- VERBOSE LOGGING - Show EVERY packet
        print(string.format("[PACKET #%d] %s:%s()", PacketCount, self.Name, method))
        for i = 2, #args do
            local arg = args[i]
            local argType = typeof(arg)
            local argStr = tostring(arg)
            if argType == "table" then
                -- Show table structure
                local keys = {}
                for k, v in pairs(arg) do
                    table.insert(keys, string.format("%s=%s", tostring(k), tostring(v)))
                end
                argStr = "{" .. table.concat(keys, ", ") .. "}"
            end
            print(string.format("  Arg[%d] (%s): %s", i-1, argType, argStr))
        end
    end

    return unpack(result)
end)

-- ===================== INIT =====================
local function Init()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.CharacterAdded:Wait()
    end
    wait(1)
    CreateUI()
    print("[+] Packet Interceptor v2.4 initialized.")
    print("[+] AGGRESSIVE MODE: Will capture ALL packets when enabled.")
    print("[+] Instructions: 1) Click ENABLE, 2) Equip a pet, 3) Check console for packet details")
end

Init()
