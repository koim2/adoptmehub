-- adoptme_packet_interceptor_v2.5.lua
-- Version: 2.5 (DIAGNOSTIC MODE)
-- Purpose: Diagnose why pet equipping fails and identify available remotes
-- Features: Remote scanner, hook tester, manual remote firing

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- ===================== CONFIG =====================
local Config = {
    InterceptEnabled = false,
    CaptureAll = true,
    MaxPackets = 100
}

-- ===================== STATE =====================
local PacketCache = {}
local OriginalNamecall = nil
local PacketCount = 0
local DiscoveredRemotes = {}

-- ===================== REMOTE SCANNER =====================
local function ScanRemotes()
    print("\n[SCANNER] Scanning for RemoteEvents/Functions...")
    local count = 0
    
    local function scanInstance(inst)
        if inst:IsA("RemoteEvent") or inst:IsA("RemoteFunction") then
            count = count + 1
            table.insert(DiscoveredRemotes, {
                Name = inst.Name,
                ClassName = inst.ClassName,
                Parent = inst.Parent.Name,
                FullPath = inst:GetFullName(),
                Instance = inst
            })
            print(string.format("  [%d] %s (%s) - Parent: %s", count, inst.Name, inst.ClassName, inst.Parent.Name))
        end
    end
    
    -- Scan ReplicatedStorage
    local function recursiveScan(parent)
        for _, child in ipairs(parent:GetChildren()) do
            scanInstance(child)
            recursiveScan(child)
        end
    end
    
    recursiveScan(ReplicatedStorage)
    print(string.format("[SCANNER] Found %d remotes total\n", count))
    return count
end

-- ===================== UI SETUP =====================
local statusLabel, enableBtn, disableBtn, scanBtn, replayBtn

local function CreateUI()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PacketInterceptor"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game:GetService("CoreGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 360, 0, 350)
    frame.Position = UDim2.new(0, 20, 0, 20)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    title.Text = "Packet Interceptor v2.5 [DIAGNOSTIC]"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.Parent = frame

    statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -20, 0, 25)
    statusLabel.Position = UDim2.new(0, 10, 0, 40)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STATUS: SAFE MODE"
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 11
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = frame

    local packetCountLabel = Instance.new("TextLabel")
    packetCountLabel.Name = "PacketCountLabel"
    packetCountLabel.Size = UDim2.new(1, -20, 0, 20)
    packetCountLabel.Position = UDim2.new(0, 10, 0, 70)
    packetCountLabel.BackgroundTransparency = 1
    packetCountLabel.Text = "Packets: 0 | Remotes: 0"
    packetCountLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
    packetCountLabel.Font = Enum.Font.Gotham
    packetCountLabel.TextSize = 10
    packetCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    packetCountLabel.Parent = frame

    scanBtn = Instance.new("TextButton")
    scanBtn.Size = UDim2.new(1, -20, 0, 35)
    scanBtn.Position = UDim2.new(0, 10, 0, 100)
    scanBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 50)
    scanBtn.Text = "SCAN REMOTES"
    scanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    scanBtn.Font = Enum.Font.GothamBold
    scanBtn.TextSize = 12
    scanBtn.Parent = frame
    scanBtn.MouseButton1Click:Connect(function()
        local count = ScanRemotes()
        local countLabel = frame:FindFirstChild("PacketCountLabel")
        if countLabel then
            countLabel.Text = string.format("Packets: %d | Remotes: %d", PacketCount, count)
        end
    end)

    enableBtn = Instance.new("TextButton")
    enableBtn.Size = UDim2.new(0.48, -10, 0, 35)
    enableBtn.Position = UDim2.new(0, 10, 0, 145)
    enableBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    enableBtn.Text = "ENABLE CAPTURE"
    enableBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    enableBtn.Font = Enum.Font.GothamBold
    enableBtn.TextSize = 11
    enableBtn.Parent = frame
    enableBtn.MouseButton1Click:Connect(function()
        Config.InterceptEnabled = true
        statusLabel.Text = "STATUS: CAPTURING"
        statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        enableBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
        enableBtn.Text = "ACTIVE"
        print("[+] Capture ENABLED")
    end)

    disableBtn = Instance.new("TextButton")
    disableBtn.Size = UDim2.new(0.48, -10, 0, 35)
    disableBtn.Position = UDim2.new(0.5, 5, 0, 145)
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
        enableBtn.Text = "ENABLE CAPTURE"
        print("[+] Capture DISABLED")
    end)

    replayBtn = Instance.new("TextButton")
    replayBtn.Size = UDim2.new(0.48, -10, 0, 35)
    replayBtn.Position = UDim2.new(0, 10, 0, 190)
    replayBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 150)
    replayBtn.Text = "REPLAY LAST"
    replayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    replayBtn.Font = Enum.Font.GothamBold
    replayBtn.TextSize = 11
    replayBtn.Parent = frame
    replayBtn.MouseButton1Click:Connect(function()
        ReplayLastPacket()
    end)

    local clearBtn = Instance.new("TextButton")
    clearBtn.Size = UDim2.new(0.48, -10, 0, 35)
    clearBtn.Position = UDim2.new(0.5, 5, 0, 190)
    clearBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50)
    clearBtn.Text = "CLEAR"
    clearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    clearBtn.Font = Enum.Font.GothamBold
    clearBtn.TextSize = 11
    clearBtn.Parent = frame
    clearBtn.MouseButton1Click:Connect(function()
        PacketCache = {}
        PacketCount = 0
        local countLabel = frame:FindFirstChild("PacketCountLabel")
        if countLabel then
            countLabel.Text = string.format("Packets: 0 | Remotes: %d", #DiscoveredRemotes)
        end
        print("[+] Cache cleared")
    end)

    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(1, -20, 0, 70)
    infoLabel.Position = UDim2.new(0, 10, 0, 235)
    infoLabel.BackgroundTransparency = 1
    infoLabel.Text = "DIAGNOSTIC STEPS:\n1. Click SCAN REMOTES to find all network endpoints\n2. Click ENABLE CAPTURE\n3. Try to equip a pet\n4. Check console for errors AND captured packets\n5. If NO packets captured = game is broken client-side"
    infoLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 9
    infoLabel.TextWrapped = true
    infoLabel.TextXAlignment = Enum.TextXAlignment.Left
    infoLabel.TextYAlignment = Enum.TextYAlignment.Top
    infoLabel.Parent = frame

    return screenGui
end

-- ===================== REPLAY FUNCTION =====================
function ReplayLastPacket()
    if #PacketCache == 0 then
        warn("[!] No packets captured.")
        return
    end

    local lastPacket = PacketCache[#PacketCache]
    local remote = lastPacket.Remote
    local rawArgs = lastPacket.Args

    local payloadArgs = {}
    for i = 2, #rawArgs do
        table.insert(payloadArgs, rawArgs[i])
    end

    print("[+] Replaying:", remote.Name)
    local success, err = pcall(function()
        remote:FireServer(unpack(payloadArgs))
    end)

    print(success and "[+] Replay sent" or "[!] Replay failed: " .. tostring(err))
end

-- ===================== HOOKING =====================
OriginalNamecall = hookmetamethod(game, "__namecall", function(...)
    local args = {...}
    local self = args[1]
    local method = getnamecallmethod()

    local result = {OriginalNamecall(...)}

    if Config.InterceptEnabled and (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction")) then
        PacketCount = PacketCount + 1
        
        table.insert(PacketCache, {
            Remote = self,
            Args = args,
            Method = method
        })

        if #PacketCache > Config.MaxPackets then
            table.remove(PacketCache, 1)
        end

        -- Update UI
        local gui = game:GetService("CoreGui"):FindFirstChild("PacketInterceptor")
        if gui then
            local countLabel = gui:FindFirstChild("Frame"):FindFirstChild("PacketCountLabel")
            if countLabel then
                countLabel.Text = string.format("Packets: %d | Remotes: %d", PacketCount, #DiscoveredRemotes)
            end
        end

        -- Log packet
        print(string.format("\n[PACKET #%d] === %s:%s()", PacketCount, self.Name, method))
        for i = 2, #args do
            local arg = args[i]
            local argType = typeof(arg)
            local argStr = tostring(arg)
            if argType == "table" then
                local keys = {}
                for k, v in pairs(arg) do
                    table.insert(keys, string.format("%s=%s", tostring(k), tostring(v)))
                end
                argStr = "{" .. table.concat(keys, ", ") .. "}"
            end
            print(string.format("  Arg[%d] (%s): %s", i-1, argType, argStr))
        end
        print("[END PACKET]\n")
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
    print("\n[+] Packet Interceptor v2.5 [DIAGNOSTIC] initialized")
    print("[+] IMPORTANT: Your console shows game ERRORS when equipping pets")
    print("[+] This means the GAME is broken, not the script")
    print("[+] Steps:")
    print("  1. Click SCAN REMOTES to see what's available")
    print("  2. Click ENABLE CAPTURE")
    print("  3. Try equipping a pet again")
    print("  4. If you see ERRORS but NO packets = game client is crashing before sending")
    print("  5. Share the console output so we can diagnose\n")
end

Init()
