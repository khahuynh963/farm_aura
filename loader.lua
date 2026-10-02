--[[
    ===================================================================
    ⚡ +1 AURA FOR ANIME HUB - LOADER V1.0
    Game: +1 Aura for Anime!
    Developer: SonionLLC
    Repository: https://github.com/khahuynh963/farm_aura.git
    Author: khahuynh963
    Tương thích 100%: Delta Executor (Android & PC), Codex, Wave, Hydrogen, Fluxus, Solara.
    ===================================================================
--]]

pcall(function()
    local container = (gethui and gethui()) or game:GetService("CoreGui")
    if container then
        if container:FindFirstChild("FarmAuraAnimeHubGui") then
            container.FarmAuraAnimeHubGui:Destroy()
        end
        if container:FindFirstChild("FarmAuraHubGui") then
            container.FarmAuraHubGui:Destroy()
        end
    end
    local pl = game:GetService("Players").LocalPlayer
    if pl and pl:FindFirstChild("PlayerGui") then
        if pl.PlayerGui:FindFirstChild("FarmAuraAnimeHubGui") then
            pl.PlayerGui.FarmAuraAnimeHubGui:Destroy()
        end
        if pl.PlayerGui:FindFirstChild("FarmAuraHubGui") then
            pl.PlayerGui.FarmAuraHubGui:Destroy()
        end
    end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/khahuynh963/farm_aura/main/script.lua?v=" .. tostring(os.time()) .. "_" .. tostring(math.random(10000, 99999))))()
