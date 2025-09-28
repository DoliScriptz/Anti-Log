--[[
    Roblox LuaU Script to block Chilli Notifiers and similar.
    CLAIMING THIS SCRIPT AS YOUR OWN IS NOT ALLOWED.
    Made by Xynnn 至 (1hatsuneeee)
    WIP, may not catch all notifiers.
]]
if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(2)
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local execName = (identifyexecutor and identifyexecutor()) 
              or (getexecutorname and getexecutorname()) 
              or "Unknown"

if execName == "Xeno" or execName == "Solara" then
    return
end

local function log(message, level)
    level = level or "INFO"
    if type(message) == "table" then
        message = message.message or tostring(message)
    end
    local prefix = "[" .. level .. "] "
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Notifier Blocker",
            Text = prefix .. message,
            Duration = 5
        })
    end)
end
local function try_cloneref(val)
    if type(cloneref) == "function" then
        local ok, out = pcall(cloneref, val)
        if ok then return out end
    end
    if type(syn) == "table" and type(syn.cloneref) == "function" then
        local ok, out = pcall(syn.cloneref, val)
        if ok then return out end
    end
    if type(http) == "table" and type(http.cloneref) == "function" then
        local ok, out = pcall(http.cloneref, val)
        if ok then return out end
    end
    return val
end
local function is_suspicious_text(str)
    if type(str) ~= "string" then return false end
    str = str:lower()
    local bad = {
        "discord.com/api/webhooks",
        "notify",
        "notifier",
        "hub",
        "brainrot",
        "chillihub1.github.io",
        "fern.wtf/joiner",
        "github",
        "job id",
        "click to join",
        "game:getservice"
    }
    for _, word in ipairs(bad) do
        if str:find(word, 1, true) then
            return true, word
        end
    end
    return false
end
local function has_blocked_body(body)
    if type(body) ~= "string" then return false end
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok or type(decoded) ~= "table" then
        return is_suspicious_text(body)
    end

    if decoded.embeds then
        for _, embed in ipairs(decoded.embeds) do
            for k, v in pairs(embed) do
                if type(v) == "string" then
                    local bad, match = is_suspicious_text(v)
                    if bad then return true, match end
                elseif type(v) == "table" then
                    for _, sub in pairs(v) do
                        if type(sub) == "string" then
                            local bad, match = is_suspicious_text(sub)
                            if bad then return true, match end
                        end
                    end
                end
            end
        end
    end

    return false
end

local function hook_request(data)
    local urlRaw = tostring(data.Url or data.URL or data.url or "")
    local urlCloned = tostring(try_cloneref(urlRaw))
    local bodyRaw = tostring(data.Body or data.body or "")
    local bodyCloned = tostring(try_cloneref(bodyRaw))

    local blocked, reason =
        is_suspicious_text(urlRaw) or is_suspicious_text(urlCloned)
    if not blocked then
        blocked, reason =
            has_blocked_body(bodyRaw) or has_blocked_body(bodyCloned)
    end

    if blocked then
        log("Blocked suspicious request (" .. reason .. ")", "WARN")
        return nil
    end

    log("Allowed request -> " .. urlRaw, "INFO")
    return old_request(data)
end
-- define old_request *before* hook_request sees it
local req = (syn and syn.request) or request or http_request or (http and http.request)
if not req then
    log("No request function found. Cannot hook.", "ERROR")
    return
end
local old_request = req

local function hook_request(data)
    local urlRaw = tostring(data.Url or data.URL or data.url or "")
    local urlCloned = tostring(try_cloneref(urlRaw))
    local bodyRaw = tostring(data.Body or data.body or "")
    local bodyCloned = tostring(try_cloneref(bodyRaw))

    local blocked, reason = is_suspicious_text(urlRaw)
    if not blocked then
        blocked, reason = is_suspicious_text(urlCloned)
    end
    if not blocked then
        blocked, reason = has_blocked_body(bodyRaw)
    end
    if not blocked then
        blocked, reason = has_blocked_body(bodyCloned)
    end

    if blocked then
        log("Blocked suspicious request (" .. tostring(reason) .. ")", "WARN")
        return nil
    end

    log("Allowed request -> " .. urlRaw, "INFO")
    return old_request(data)
end

if syn and syn.request then
    syn.request = hook_request
end
if http_request then
    http_request = hook_request
end
if request then
    request = hook_request
end
if http and http.request and hookfunction then
    hookfunction(http.request, hook_request)
end


log("Notifier Blocker active! Made by Xynnn 至 (1hatsuneeee)", "INFO")
