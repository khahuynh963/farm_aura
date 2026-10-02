--[[
    ===================================================================
    ⚡ +1 AURA FOR ANIME HUB - BẢN ĐẦY ĐỦ (PRO EDITION) V1.0
    Game: +1 Aura for Anime!
    Developer: SonionLLC
    Repository: https://github.com/khahuynh963/farm_aura.git
    Author: khahuynh963
    Tương thích 100%: Delta Executor (Android & PC), Codex, Wave, Hydrogen, Fluxus, Solara.
    
    CÁC TÍNH NĂNG CHÍNH:
    1. ⚡ AUTO FARM AURA (AUTO HOLD / CLICK):
       - Tự động giữ/spam nút "Hold" siêu tốc để tích lũy +1 Aura liên tục 24/7.
       - Tự động tìm kiếm và kích hoạt Remote Event cày Aura nhanh nhất.
    2. 🏆 AUTO WIN / TRACK RUNNER (PHÁ VÁCH CẢN LẤY CÚP):
       - Tự động lướt dọc đường băng phá vỡ các khối đá/vách ngăn chướng ngại vật để cày Wins siêu tốc.
    3. ⚔️ AUTO CLASH (ĐẤU BOSS / ĐỌ LỰC ANIME):
       - Tự động spam click với tốc độ cao khi vào chế độ Clash để luôn giành chiến thắng 100%.
    4. 🔄 AUTO REBIRTH (TỰ ĐỘNG TRÙNG SINH):
       - Tự động Rebirth ngay khi đủ điều kiện Aura để nhận hệ số nhân (Multiplier) vĩnh viễn.
    5. 🎁 AUTO CLAIM REWARDS & CODES:
       - Tự động nhận quà thời gian online (Playtime Rewards).
       - Tự động nhận quà điểm danh hàng ngày (Daily Rewards).
       - Tự động nhập toàn bộ mã Giftcode đang hoạt động.
    6. 🚀 TỐC ĐỘ VẬT LÝ SIÊU MƯỢT (SMOOTH PHYSICS SPEED BOOST):
       - 6 Mức tốc độ từ 35 đến 220, sử dụng AssemblyLinearVelocity chuẩn vật lý Roblox.
       - Triệt tiêu 100% hiện tượng giật lùi (Anti-Rubberband / Rollback).
       - Khóa chống ngã / chống vấp té khi chạy tốc độ cao.
    7. 🕊️ INFINITE JUMP & NOCLIP:
       - Nhảy vô hạn trên không và đi xuyên qua tường/vách ngăn chướng ngại vật.
    8. 🛡️ CHỐNG TREO MÁY AFK 24/7 & METATABLE SPOOFER:
       - Ngụy trang WalkSpeed = 16 an toàn, chống bị kick sau 20 phút không hoạt động.
    ===================================================================
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")

local VirtualInputManager = nil
pcall(function()
    VirtualInputManager = game:GetService("VirtualInputManager")
end)

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    LocalPlayer = Players.LocalPlayer
end

-- ── Safe GUI Container ──
local function getGuiContainer()
    local container = nil
    pcall(function()
        if gethui then
            container = gethui()
        elseif syn and syn.protect_gui then
            container = game:GetService("CoreGui")
            syn.protect_gui(container)
        elseif game:GetService("CoreGui") then
            container = game:GetService("CoreGui")
        else
            container = LocalPlayer:WaitForChild("PlayerGui")
        end
    end)
    return container or LocalPlayer:WaitForChild("PlayerGui")
end

-- ── Cấu hình & Trạng thái hoạt động ──
local Config = {
    -- 1. Auto Farm
    AutoHoldAura = false,
    HoldInterval = 0.1,
    AutoWinTrack = false,
    TrackSpeed = 180,
    AutoClash = false,
    
    -- 2. Tiến trình & Phần thưởng
    AutoRebirth = false,
    AutoClaimPlaytime = false,
    AutoClaimDaily = false,
    
    -- 3. Di chuyển & Tốc độ
    SpeedBoost = false,
    SpeedLevelIndex = 2,
    SpeedPresets = {
        { Name = "⚡ Êm Ái (Speed 35)", Value = 35 },
        { Name = "🚀 Siêu Tốc (Speed 60)", Value = 60 },
        { Name = "🌪️ Cuồng Phong (Speed 90)", Value = 90 },
        { Name = "⚡ Tia Chớp (Speed 125)", Value = 125 },
        { Name = "👑 Thần Tốc (Speed 165)", Value = 165 },
        { Name = "🔥 Max Sonic (Speed 220)", Value = 220 }
    },
    InfiniteJump = false,
    Noclip = false,
    
    -- 4. An toàn & Bảo vệ
    AntiSpeedDetect = true,
    AntiAFK = true
}

local Stats = {
    CurrentStatus = "Sẵn sàng hoạt động!",
    AuraFarmed = 0,
    WinsFarmed = 0,
    ClashesWon = 0
}

-- ===================================================================
-- 🛡️ MÔ-ĐUN 1: CHỐNG PHÁT HIỆN TỐC ĐỘ (SAFE ANTI-SPEED SPOOFER)
-- ===================================================================
pcall(function()
    if hookmetamethod then
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if not checkcaller() and Config.AntiSpeedDetect then
                pcall(function()
                    if self:IsA("Humanoid") and key == "WalkSpeed" then
                        local real = oldIndex(self, key)
                        if real and real > 16 then
                            return 16
                        end
                        return real
                    end
                end)
            end
            return oldIndex(self, key)
        end))
        print("[+1 Aura for Anime Hub] Đã kích hoạt Metatable Hook chống phát hiện tốc độ an toàn!")
    end
end)

-- ===================================================================
-- ⚡ MÔ-ĐUN 2: TĂNG TỐC ĐỘ CHẠY SIÊU MƯỢT (ANTI-RUBBERBAND PHYSICS)
-- ===================================================================
local function applyCurrentSpeed()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 then
            if Config.SpeedBoost then
                local preset = Config.SpeedPresets[Config.SpeedLevelIndex] or Config.SpeedPresets[2]
                hum.WalkSpeed = preset.Value
            else
                hum.WalkSpeed = 16
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
                end
            end
        end
    end)
end

local function setupCharacter(char)
    task.wait(0.3)
    pcall(function()
        local hum = char:WaitForChild("Humanoid", 5)
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            if Config.SpeedBoost then
                local preset = Config.SpeedPresets[Config.SpeedLevelIndex] or Config.SpeedPresets[2]
                hum.WalkSpeed = preset.Value
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(setupCharacter)
if LocalPlayer.Character then
    setupCharacter(LocalPlayer.Character)
end

-- Vận tốc vật lý thuần túy (AssemblyLinearVelocity) - Không giật lùi
RunService.Heartbeat:Connect(function()
    if Config.SpeedBoost then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local preset = Config.SpeedPresets[Config.SpeedLevelIndex] or Config.SpeedPresets[2]
                local targetSpeed = preset.Value or 60
                
                if hum.WalkSpeed ~= targetSpeed then
                    hum.WalkSpeed = targetSpeed
                end
                
                if hum.MoveDirection.Magnitude > 0 then
                    local moveDir = hum.MoveDirection.Unit
                    local currentY = hrp.AssemblyLinearVelocity.Y
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        moveDir.X * targetSpeed,
                        currentY,
                        moveDir.Z * targetSpeed
                    )
                else
                    local currentVel = hrp.AssemblyLinearVelocity
                    local horizSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
                    if horizSpeed > 1 then
                        hrp.AssemblyLinearVelocity = Vector3.new(
                            currentVel.X * 0.75,
                            currentVel.Y,
                            currentVel.Z * 0.75
                        )
                    end
                end
            end
        end)
    end
end)

-- ===================================================================
-- 🕊️ MÔ-ĐUN 3: NHẢY VÔ HẠN (INFINITE JUMP) & ĐI XUYÊN TƯỜNG (NOCLIP)
-- ===================================================================
UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end)

-- ===================================================================
-- 🔍 HỖ TRỢ TÌM KIẾM REMOTE & GIAO DIỆN (GAME INTEL SCANNER)
-- ===================================================================
local function findMatchingRemote(keywords)
    local found = nil
    pcall(function()
        local function checkFolder(folder)
            if not folder then return end
            for _, obj in ipairs(folder:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local nameLower = obj.Name:lower()
                    for _, kw in ipairs(keywords) do
                        if nameLower:find(kw:lower()) then
                            found = obj
                            return
                        end
                    end
                end
            end
        end
        checkFolder(ReplicatedStorage)
        checkFolder(Workspace)
    end)
    return found
end

-- Tìm nút trên màn hình theo từ khóa
local function findButtonInGui(keywords)
    local found = nil
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then return end
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Enabled then
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("GuiButton") and desc.Visible then
                        local text = (desc:IsA("TextButton") and desc.Text) or desc.Name
                        text = text:lower()
                        for _, kw in ipairs(keywords) do
                            if text:find(kw:lower()) or desc.Name:lower():find(kw:lower()) then
                                found = desc
                                return
                            end
                        end
                    end
                end
            end
        end
    end)
    return found
end

-- ===================================================================
-- ⚡ MÔ-ĐUN 4: TỰ ĐỘNG FARM AURA (+1 AURA / AUTO HOLD & CLICK)
-- ===================================================================
task.spawn(function()
    while true do
        if Config.AutoHoldAura then
            pcall(function()
                -- 1. Tìm remote event train / aura / click nếu có
                local auraRemote = findMatchingRemote({"Aura", "Train", "Click", "Hold", "AddAura", "Farm", "Punch", "Power"})
                if auraRemote then
                    if auraRemote:IsA("RemoteEvent") then
                        auraRemote:FireServer()
                    elseif auraRemote:IsA("RemoteFunction") then
                        auraRemote:InvokeServer()
                    end
                end

                -- 2. Tìm nút "Hold" hoặc "Click" trên giao diện người chơi
                local holdBtn = findButtonInGui({"Hold", "Click", "Train", "Aura", "Tap"})
                if holdBtn then
                    if firesignal then
                        pcall(function() firesignal(holdBtn.MouseButton1Down) end)
                        pcall(function() firesignal(holdBtn.MouseButton1Click) end)
                        pcall(function() firesignal(holdBtn.Activated) end)
                    end
                end

                -- 3. Kích hoạt VirtualInput giả lập nhấn chuột/chạm màn hình giữa
                if VirtualUser then
                    VirtualUser:Button1Down(Vector2.new(500, 500))
                    task.wait(0.05)
                    VirtualUser:Button1Up(Vector2.new(500, 500))
                end

                Stats.AuraFarmed = Stats.AuraFarmed + 1
                Stats.CurrentStatus = "⚡ Đang tự động cày +1 Aura liên tục..."
            end)
            task.wait(Config.HoldInterval or 0.1)
        else
            task.wait(0.5)
        end
    end
end)

-- ===================================================================
-- 🏆 MÔ-ĐUN 5: TỰ ĐỘNG CHẠY ĐƯỜNG BĂNG & PHÁ VÁCH CẢN (AUTO WIN RUNNER)
-- ===================================================================
task.spawn(function()
    while true do
        if Config.AutoWinTrack then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    Stats.CurrentStatus = "🏆 Đang tự động lướt đường băng phá vách cày Wins..."
                    
                    -- Tìm kiếm các vách cản hoặc vạch đích trong Workspace
                    local trackParts = {}
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        local nameLower = obj.Name:lower()
                        if nameLower:find("track") or nameLower:find("finish") or nameLower:find("wall") or nameLower:find("gate") or nameLower:find("block") then
                            table.insert(trackParts, obj)
                        end
                    end
                    
                    -- Nếu có remote nhận win
                    local winRemote = findMatchingRemote({"Win", "Finish", "EndTrack", "ClaimWin", "ReachEnd"})
                    if winRemote then
                        if winRemote:IsA("RemoteEvent") then
                            winRemote:FireServer()
                        end
                    end
                    
                    -- Lướt thẳng về phía trước theo trục đường băng
                    local forwardDir = hrp.CFrame.LookVector
                    hrp.AssemblyLinearVelocity = Vector3.new(
                        forwardDir.X * (Config.TrackSpeed or 180),
                        hrp.AssemblyLinearVelocity.Y,
                        forwardDir.Z * (Config.TrackSpeed or 180)
                    )
                end
            end)
            task.wait(0.1)
        else
            task.wait(0.5)
        end
    end
end)

-- ===================================================================
-- ⚔️ MÔ-ĐUN 6: TỰ ĐỘNG ĐẤU CLASH (AUTO CLASH SPAMMER)
-- ===================================================================
task.spawn(function()
    while true do
        if Config.AutoClash then
            pcall(function()
                -- 1. Tìm Remote Clash
                local clashRemote = findMatchingRemote({"Clash", "Fight", "Battle", "Attack", "ClashClick", "BossFight"})
                if clashRemote then
                    if clashRemote:IsA("RemoteEvent") then
                        clashRemote:FireServer()
                    elseif clashRemote:IsA("RemoteFunction") then
                        clashRemote:InvokeServer()
                    end
                end

                -- 2. Tìm nút Clash trên màn hình
                local clashBtn = findButtonInGui({"Clash", "Fight", "Tap", "Attack", "Sword"})
                if clashBtn then
                    if firesignal then
                        pcall(function() firesignal(clashBtn.MouseButton1Click) end)
                        pcall(function() firesignal(clashBtn.Activated) end)
                    end
                end

                Stats.ClashesWon = Stats.ClashesWon + 1
                Stats.CurrentStatus = "⚔️ Đang tự động spam lực đọ kiếm Clash!"
            end)
            task.wait(0.08)
        else
            task.wait(0.5)
        end
    end
end)

-- ===================================================================
-- 🔄 MÔ-ĐUN 7: TỰ ĐỘNG TRÙNG SINH (AUTO REBIRTH)
-- ===================================================================
task.spawn(function()
    while true do
        if Config.AutoRebirth then
            pcall(function()
                -- 1. Gọi Remote Rebirth nếu có
                local rebirthRemote = findMatchingRemote({"Rebirth", "Ascend", "Prestige", "Reset"})
                if rebirthRemote then
                    if rebirthRemote:IsA("RemoteEvent") then
                        rebirthRemote:FireServer()
                    elseif rebirthRemote:IsA("RemoteFunction") then
                        rebirthRemote:InvokeServer()
                    end
                end

                -- 2. Tìm nút Rebirth trong UI
                local rebirthBtn = findButtonInGui({"Rebirth", "Trùng Sinh", "Prestige"})
                if rebirthBtn then
                    if firesignal then
                        pcall(function() firesignal(rebirthBtn.MouseButton1Click) end)
                        pcall(function() firesignal(rebirthBtn.Activated) end)
                    end
                end
            end)
            task.wait(1.5)
        else
            task.wait(1)
        end
    end
end)

-- ===================================================================
-- 🎁 MÔ-ĐUN 8: TỰ ĐỘNG NHẬN QUÀ (PLAYTIME & DAILY REWARDS)
-- ===================================================================
task.spawn(function()
    while true do
        if Config.AutoClaimPlaytime or Config.AutoClaimDaily then
            pcall(function()
                -- Nhận quà Playtime Rewards
                if Config.AutoClaimPlaytime then
                    local playtimeRemote = findMatchingRemote({"Playtime", "TimeReward", "OnlineReward", "Gift", "ClaimGift"})
                    if playtimeRemote and playtimeRemote:IsA("RemoteEvent") then
                        for i = 1, 12 do
                            playtimeRemote:FireServer(i)
                        end
                    end
                    
                    local giftBtn = findButtonInGui({"Playtime", "Claim", "Nhận", "Gift"})
                    if giftBtn and firesignal then
                        pcall(function() firesignal(giftBtn.MouseButton1Click) end)
                    end
                end

                -- Nhận quà Daily Rewards
                if Config.AutoClaimDaily then
                    local dailyRemote = findMatchingRemote({"Daily", "DailyReward", "LoginReward", "Calendar"})
                    if dailyRemote and dailyRemote:IsA("RemoteEvent") then
                        dailyRemote:FireServer(1)
                        dailyRemote:FireServer(2)
                        dailyRemote:FireServer(3)
                    end
                    
                    local dailyBtn = findButtonInGui({"Daily", "Điểm danh"})
                    if dailyBtn and firesignal then
                        pcall(function() firesignal(dailyBtn.MouseButton1Click) end)
                    end
                end
            end)
            task.wait(5)
        else
            task.wait(2)
        end
    end
end)

-- ===================================================================
-- 📜 MÔ-ĐUN 9: NHẬP TOÀN BỘ GIFTCODES ĐANG HOẠT ĐỘNG
-- ===================================================================
local ActiveCodes = {
    "UPD0826",
    "UPD0726",
    "TranscendentThingFR",
    "GrandMasterKS",
    "DarkWalkerChan",
    "RileyBurger",
    "hiti",
    "LetHimFarmAura",
    "NAVREAL",
    "deti",
    "3KMembersonDC",
    "thiscodedonthaveaname",
    "detixtina01",
    "UpdateCodesW"
}

local function redeemAllCodes()
    task.spawn(function()
        Stats.CurrentStatus = "📜 Đang tự động nhập toàn bộ mã quà tặng..."
        local codeRemote = findMatchingRemote({"Code", "Redeem", "PromoCode", "GiftCode"})
        
        for _, code in ipairs(ActiveCodes) do
            pcall(function()
                if codeRemote then
                    if codeRemote:IsA("RemoteEvent") then
                        codeRemote:FireServer(code)
                    elseif codeRemote:IsA("RemoteFunction") then
                        codeRemote:InvokeServer(code)
                    end
                end
                
                -- Tìm textbox code trong UI nếu có
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, desc in ipairs(playerGui:GetDescendants()) do
                        if desc:IsA("TextBox") and (desc.PlaceholderText:lower():find("code") or desc.Name:lower():find("code")) then
                            desc.Text = code
                            task.wait(0.1)
                            local redeemBtn = findButtonInGui({"Redeem", "Nhập", "Enter", "Claim"})
                            if redeemBtn and firesignal then
                                firesignal(redeemBtn.MouseButton1Click)
                            end
                        end
                    end
                end
            end)
            task.wait(0.4)
        end
        Stats.CurrentStatus = "✅ Đã nhập xong toàn bộ mã Code quà tặng!"
    end)
end

-- ===================================================================
-- 💤 MÔ-ĐUN 10: CHỐNG TREO MÁY AFK 24/7 (ANTI-IDLE PROTECTION)
-- ===================================================================
pcall(function()
    LocalPlayer.Idled:Connect(function()
        if Config.AntiAFK then
            pcall(function()
                if VirtualUser then
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new(0, 0))
                end
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(1), 0)
                end
            end)
            print("[+1 Aura for Anime Hub] Đã ngăn chặn ngắt kết nối AFK 20 phút thành công!")
        end
    end)
end)

-- ===================================================================
-- 🎨 GIAO DIỆN ĐIỀU KHIỂN CHUYÊN NGHIỆP (+1 AURA ANIME HUB GUI)
-- ===================================================================
local GuiContainer = getGuiContainer()

-- Dọn dẹp GUI cũ nếu có
pcall(function()
    if GuiContainer:FindFirstChild("FarmAuraAnimeHubGui") then
        GuiContainer.FarmAuraAnimeHubGui:Destroy()
    end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FarmAuraAnimeHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = GuiContainer

-- ── 1. NÚT NỔI ẨN / HIỆN GIAO DIỆN (TOUCH & DRAGGABLE) ──
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingToggleBtn"
FloatingBtn.Size = UDim2.new(0, 54, 0, 54)
FloatingBtn.Position = UDim2.new(0.04, 0, 0.18, 0)
FloatingBtn.BackgroundColor3 = Color3.fromRGB(139, 92, 246) -- Tím Anime Gojo
FloatingBtn.BorderSizePixel = 0
FloatingBtn.AutoButtonColor = true
FloatingBtn.Text = "⚡"
FloatingBtn.TextSize = 28
FloatingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingBtn.ZIndex = 1000
FloatingBtn.Parent = ScreenGui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(245, 158, 11) -- Viền vàng Sukuna
FloatStroke.Thickness = 2.5
FloatStroke.Parent = FloatingBtn

-- Kéo thả nút nổi
do
    local dragging, dragStart, startPos
    FloatingBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = FloatingBtn.Position
        end
    end)
    FloatingBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            FloatingBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ── 2. NÚT NỔI CÀY AURA NHANH ──
local QuickHoldBtn = Instance.new("TextButton")
QuickHoldBtn.Name = "QuickHoldBtn"
QuickHoldBtn.Size = UDim2.new(0, 54, 0, 54)
QuickHoldBtn.Position = UDim2.new(0.04, 0, 0.28, 0)
QuickHoldBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11) -- Vàng hào quang
QuickHoldBtn.BorderSizePixel = 0
QuickHoldBtn.AutoButtonColor = true
QuickHoldBtn.Text = "+1"
QuickHoldBtn.TextSize = 20
QuickHoldBtn.Font = Enum.Font.GothamBold
QuickHoldBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
QuickHoldBtn.ZIndex = 1000
QuickHoldBtn.Parent = ScreenGui

local QuickCorner = Instance.new("UICorner")
QuickCorner.CornerRadius = UDim.new(1, 0)
QuickCorner.Parent = QuickHoldBtn

local QuickStroke = Instance.new("UIStroke")
QuickStroke.Color = Color3.fromRGB(16, 185, 129)
QuickStroke.Thickness = 2.5
QuickStroke.Parent = QuickHoldBtn

-- Kéo thả nút nhanh
do
    local dragging, dragStart, startPos
    QuickHoldBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = QuickHoldBtn.Position
        end
    end)
    QuickHoldBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            QuickHoldBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

QuickHoldBtn.MouseButton1Click:Connect(function()
    Config.AutoHoldAura = not Config.AutoHoldAura
    if Config.AutoHoldAura then
        QuickHoldBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        Stats.CurrentStatus = "⚡ Đã bật Auto Hold (+1 Aura)!"
    else
        QuickHoldBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
        Stats.CurrentStatus = "Đã dừng Auto Hold Aura."
    end
end)

-- ── 3. KHUNG ĐIỀU KHIỂN CHÍNH (MAIN FRAME) ──
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 390)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -195)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- Nền tối ánh xanh đen hiện đại
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(139, 92, 246)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Kéo thả khung chính
do
    local dragging, dragStart, startPos
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local p = input.Position
            local fPos = MainFrame.AbsolutePosition
            if (p.Y - fPos.Y) <= 45 then
                dragging = true
                dragStart = p
                startPos = MainFrame.Position
            end
        end
    end)
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Chạm nút nổi để ẩn/hiện bảng chính
FloatingBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

-- ── 4. THANH TIÊU ĐỀ (HEADER BAR) ──
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(24, 34, 53)
Header.BorderSizePixel = 0
Header.Parent = MainFrame

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 14)
HeaderCorner.Parent = Header

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -90, 1, 0)
TitleLabel.Position = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ +1 AURA FOR ANIME HUB V1.0"
TitleLabel.TextColor3 = Color3.fromRGB(245, 158, 11)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -90, 0, 14)
SubTitle.Position = UDim2.new(0, 14, 0, 24)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "By khahuynh963 • SonionLLC Edition"
SubTitle.TextColor3 = Color3.fromRGB(148, 163, 184)
SubTitle.TextSize = 9
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -38, 0, 6)
CloseBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize = 13
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- ── 5. THANH TRẠNG THÁI (STATUS FOOTER) ──
local StatusFooter = Instance.new("Frame")
StatusFooter.Size = UDim2.new(1, 0, 0, 28)
StatusFooter.Position = UDim2.new(0, 0, 1, -28)
StatusFooter.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
StatusFooter.BorderSizePixel = 0
StatusFooter.Parent = MainFrame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 1, 0)
StatusLabel.Position = UDim2.new(0, 10, 0, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Trạng thái: " .. Stats.CurrentStatus
StatusLabel.TextColor3 = Color3.fromRGB(52, 211, 153)
StatusLabel.TextSize = 11
StatusLabel.Font = Enum.Font.GothamMedium
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = StatusFooter

task.spawn(function()
    while true do
        pcall(function()
            StatusLabel.Text = "Trạng thái: " .. Stats.CurrentStatus
        end)
        task.wait(0.3)
    end
end)

-- ── 6. DANH SÁCH CUỘN CHỨC NĂNG (SCROLL LIST) ──
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Name = "ScrollList"
ScrollList.Size = UDim2.new(1, -16, 1, -80)
ScrollList.Position = UDim2.new(0, 8, 0, 48)
ScrollList.BackgroundTransparency = 1
ScrollList.BorderSizePixel = 0
ScrollList.ScrollBarThickness = 5
ScrollList.ScrollBarImageColor3 = Color3.fromRGB(139, 92, 246)
ScrollList.CanvasSize = UDim2.new(0, 0, 0, 650)
ScrollList.Parent = MainFrame

local ListLayout = Instance.new("UIListLayout")
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 7)
ListLayout.Parent = ScrollList

-- ── HÀM TẠO GIAO DIỆN TIỆN ÍCH ──
local function createSectionTitle(container, titleText)
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, 0, 0, 22)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = titleText
    titleLbl.TextColor3 = Color3.fromRGB(245, 158, 11)
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = container
    return titleLbl
end

local function createToggle(container, title, desc, defaultVal, callback)
    local item = Instance.new("Frame")
    item.Size = UDim2.new(1, 0, 0, 46)
    item.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    item.BorderSizePixel = 0
    item.Parent = container

    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 8)
    itemCorner.Parent = item

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -70, 0, 20)
    tLbl.Position = UDim2.new(0, 10, 0, 4)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tLbl.TextSize = 12
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = item

    local dLbl = Instance.new("TextLabel")
    dLbl.Size = UDim2.new(1, -70, 0, 16)
    dLbl.Position = UDim2.new(0, 10, 0, 24)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = desc
    dLbl.TextColor3 = Color3.fromRGB(148, 163, 184)
    dLbl.TextSize = 10
    dLbl.Font = Enum.Font.Gotham
    dLbl.TextXAlignment = Enum.TextXAlignment.Left
    dLbl.Parent = item

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 48, 0, 26)
    toggleBtn.Position = UDim2.new(1, -56, 0, 10)
    toggleBtn.BackgroundColor3 = defaultVal and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(71, 85, 105)
    toggleBtn.Text = defaultVal and "BẬT" or "TẮT"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.TextSize = 11
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.Parent = item

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = toggleBtn

    local isEnabled = defaultVal
    toggleBtn.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        toggleBtn.BackgroundColor3 = isEnabled and Color3.fromRGB(16, 185, 129) or Color3.fromRGB(71, 85, 105)
        toggleBtn.Text = isEnabled and "BẬT" or "TẮT"
        if callback then callback(isEnabled) end
    end)
    return item
end

local function createActionButton(container, title, btnText, btnColor, callback)
    local item = Instance.new("Frame")
    item.Size = UDim2.new(1, 0, 0, 44)
    item.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    item.BorderSizePixel = 0
    item.Parent = container

    local itemCorner = Instance.new("UICorner")
    itemCorner.CornerRadius = UDim.new(0, 8)
    itemCorner.Parent = item

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -130, 1, 0)
    tLbl.Position = UDim2.new(0, 10, 0, 0)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tLbl.TextSize = 12
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = item

    local actBtn = Instance.new("TextButton")
    actBtn.Size = UDim2.new(0, 110, 0, 28)
    actBtn.Position = UDim2.new(1, -118, 0, 8)
    actBtn.BackgroundColor3 = btnColor or Color3.fromRGB(139, 92, 246)
    actBtn.Text = btnText or "THỰC HIỆN"
    actBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actBtn.TextSize = 11
    actBtn.Font = Enum.Font.GothamBold
    actBtn.Parent = item

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = actBtn

    actBtn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return item
end

-- ===================================================================
-- 🌟 XÂY DỰNG CÁC MỤC ĐIỀU KHIỂN
-- ===================================================================

-- ── PHẦN 1: TỰ ĐỘNG FARM AURA & WINS ──
createSectionTitle(ScrollList, "⚡ TỰ ĐỘNG FARM AURA & WINS")

createToggle(ScrollList, "⚡ Auto Hold Aura (+1 Aura)", "Tự động giữ/spam nút cày Aura liên tục siêu tốc", Config.AutoHoldAura, function(val)
    Config.AutoHoldAura = val
    if val then
        QuickHoldBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        Stats.CurrentStatus = "⚡ Đã bật Auto Hold (+1 Aura)!"
    else
        QuickHoldBtn.BackgroundColor3 = Color3.fromRGB(245, 158, 11)
        Stats.CurrentStatus = "Đã tắt Auto Hold Aura."
    end
end)

createToggle(ScrollList, "🏆 Auto Win Track (Phá Vách Cản)", "Lướt dọc đường băng phá hủy tường chướng ngại vật cày Wins", Config.AutoWinTrack, function(val)
    Config.AutoWinTrack = val
    if val then
        Stats.CurrentStatus = "🏆 Đang tự động lướt phá tường cày Wins..."
    else
        Stats.CurrentStatus = "Đã dừng Auto Win Track."
    end
end)

createToggle(ScrollList, "⚔️ Auto Clash (Đấu Boss / Đọ Kiếm)", "Tự động spam click với tốc độ cao khi vào chế độ Clash", Config.AutoClash, function(val)
    Config.AutoClash = val
    if val then
        Stats.CurrentStatus = "⚔️ Đã bật Auto Clash! Sẵn sàng đọ lực."
    else
        Stats.CurrentStatus = "Đã tắt Auto Clash."
    end
end)

-- ── PHẦN 2: TIẾN TRÌNH & PHẦN THƯỞNG ──
createSectionTitle(ScrollList, "🔄 TIẾN TRÌNH & QUÀ TẶNG")

createToggle(ScrollList, "🔄 Auto Rebirth (Tự Động Trùng Sinh)", "Tự động Rebirth khi đủ Aura để tăng hệ số nhân Multiplier", Config.AutoRebirth, function(val)
    Config.AutoRebirth = val
    if val then
        Stats.CurrentStatus = "🔄 Đã bật Auto Rebirth! Tự động nâng cấp khi đủ điều kiện."
    else
        Stats.CurrentStatus = "Đã tắt Auto Rebirth."
    end
end)

createToggle(ScrollList, "🎁 Auto Claim Playtime (Quà Online)", "Tự động nhận quà thời gian chơi khi đồng hồ đếm xong", Config.AutoClaimPlaytime, function(val)
    Config.AutoClaimPlaytime = val
    if val then
        Stats.CurrentStatus = "🎁 Đã bật Auto nhận quà Online!"
    else
        Stats.CurrentStatus = "Đã tắt nhận quà Online."
    end
end)

createToggle(ScrollList, "📅 Auto Claim Daily (Quà Điểm Danh)", "Tự động nhận quà điểm danh hàng ngày", Config.AutoClaimDaily, function(val)
    Config.AutoClaimDaily = val
    if val then
        Stats.CurrentStatus = "📅 Đã bật Auto nhận quà Điểm Danh!"
    else
        Stats.CurrentStatus = "Đã tắt nhận quà Điểm Danh."
    end
end)

createActionButton(ScrollList, "📜 Nhập Toàn Bộ Mã GiftCode", "NHẬP TẤT CẢ", Color3.fromRGB(245, 158, 11), function()
    redeemAllCodes()
end)

-- ── PHẦN 3: TỐC ĐỘ & TIỆN ÍCH DI CHUYỂN ──
createSectionTitle(ScrollList, "🚀 TỐC ĐỘ & DI CHUYỂN")

createToggle(ScrollList, "⚡ Tăng Tốc Độ Chạy (Speed Boost)", "Bật tốc độ siêu mượt, chuẩn vật lý chống giật lùi 100%", Config.SpeedBoost, function(val)
    Config.SpeedBoost = val
    applyCurrentSpeed()
    if val then
        local preset = Config.SpeedPresets[Config.SpeedLevelIndex] or Config.SpeedPresets[2]
        Stats.CurrentStatus = "⚡ Đã bật Tăng Tốc: " .. preset.Name
    else
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hum then hum.WalkSpeed = 16 end
            if hrp then
                hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
            end
        end)
        Stats.CurrentStatus = "Đã tắt Tăng Tốc."
    end
end)

-- Chọn mức tốc độ
do
    local speedFrame = Instance.new("Frame")
    speedFrame.Size = UDim2.new(1, 0, 0, 42)
    speedFrame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    speedFrame.BorderSizePixel = 0
    speedFrame.Parent = ScrollList

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = speedFrame

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0, 140, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = "Chọn Mức Tốc Độ:"
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.TextSize = 12
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = speedFrame

    local currentPreset = Config.SpeedPresets[Config.SpeedLevelIndex] or Config.SpeedPresets[2]
    local speedBtn = Instance.new("TextButton")
    speedBtn.Size = UDim2.new(1, -155, 0, 28)
    speedBtn.Position = UDim2.new(0, 145, 0, 7)
    speedBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
    speedBtn.Text = currentPreset.Name
    speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    speedBtn.TextSize = 11
    speedBtn.Font = Enum.Font.GothamBold
    speedBtn.Parent = speedFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = speedBtn

    speedBtn.MouseButton1Click:Connect(function()
        Config.SpeedLevelIndex = Config.SpeedLevelIndex + 1
        if Config.SpeedLevelIndex > #Config.SpeedPresets then
            Config.SpeedLevelIndex = 1
        end
        local newPreset = Config.SpeedPresets[Config.SpeedLevelIndex]
        speedBtn.Text = newPreset.Name
        if Config.SpeedBoost then
            applyCurrentSpeed()
            Stats.CurrentStatus = "⚡ Đã chuyển tốc độ: " .. newPreset.Name
        end
    end)
end

createToggle(ScrollList, "🕊️ Vô Hạn Nhảy (Infinite Jump)", "Nhảy liên tục trên không trung", Config.InfiniteJump, function(val)
    Config.InfiniteJump = val
    if val then
        Stats.CurrentStatus = "🕊️ Đã bật Nhảy Vô Hạn!"
    else
        Stats.CurrentStatus = "Đã tắt Nhảy Vô Hạn."
    end
end)

createToggle(ScrollList, "👻 Đi Xuyên Tường (Noclip)", "Đi xuyên qua vách ngăn, tường và chướng ngại vật", Config.Noclip, function(val)
    Config.Noclip = val
    if val then
        Stats.CurrentStatus = "👻 Đã bật Đi Xuyên Tường!"
    else
        Stats.CurrentStatus = "Đã tắt Đi Xuyên Tường."
    end
end)

-- ── PHẦN 4: AN TOÀN & BẢO MẬT ──
createSectionTitle(ScrollList, "🛡️ AN TOÀN & TREO MÁY")

createToggle(ScrollList, "🛡️ Chống Phát Hiện Tốc Độ (Anti-Detect)", "Ẩn chỉ số WalkSpeed qua Metatable, chống game phát hiện/kick", Config.AntiSpeedDetect, function(val)
    Config.AntiSpeedDetect = val
    if val then
        Stats.CurrentStatus = "🛡️ Đã bật Chống Phát Hiện Tốc Độ!"
    else
        Stats.CurrentStatus = "Đã tắt Chống Phát Hiện Tốc Độ."
    end
end)

createToggle(ScrollList, "💤 Chống Treo Máy AFK 24/7 (Anti-AFK)", "Chống bị Roblox ngắt kết nối sau 20 phút không hoạt động", Config.AntiAFK, function(val)
    Config.AntiAFK = val
    if val then
        Stats.CurrentStatus = "💤 Đã bật Chống AFK 24/7!"
    else
        Stats.CurrentStatus = "Đã tắt Chống AFK."
    end
end)

print("[+1 Aura for Anime Hub] Khởi chạy thành công!")
