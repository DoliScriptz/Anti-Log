--[[
    Roblox LuaU Script to block Chilli Notifiers and similar.
    CLAIMING THIS SCRIPT AS YOUR OWN IS NOT ALLOWED.
    Made by Xynnn 至 (1hatsuneeee)
    Still WIP and may not work for all notifiers.
]]

local function log(message, level)
    level = level or "INFO"
    if type(message) == "table" then
        message = message.message or tostring(message)
    end

    local prefix = "[" .. level .. "] "
    if level == "WARN" then
        warn(prefix .. message)
    elseif level == "ERROR" then
        warn(prefix .. message)
    else
        print(prefix .. message)
    end
end

local HttpService = game:GetService("HttpService")

local req = (syn and syn.request) or request or http_request or (http and http.request)
if not req then
    log("No request function found. Cannot hook.", "ERROR")
    return
end

local old_request = req

local function has_blocked_title(body)
    if type(body) ~= "string" then
        return false
    end

    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, body)
    if not ok or type(decoded) ~= "table" then
        return false
    end

    if decoded.embeds then
        for _, embed in ipairs(decoded.embeds) do
            if type(embed.title) == "string" then
                local t = embed.title:lower()
                if t:find("notify") or t:find("hub") or t:find("notifier") or t:find("pet") or t:find("brainrot") then
                    return true, embed.title
                end
            end

            if type(embed.description) == "string" then
                local d = embed.description:lower()
                if d:find("notify") or d:find("hub") then
                    return true, embed.description
                end
            end

            if type(embed.fields) == "table" then
                for _, field in ipairs(embed.fields) do
                    if type(field.name) == "string" then
                        local fn = field.name:lower()
                        if fn:find("job id") or fn:find("join") or fn:find("script") then
                            return true, field.name
                        end
                    end
                    if type(field.value) == "string" then
                        local fv = field.value:lower()
                        if fv:find("job id") or fv:find("click to join") or fv:find("game:getservice")
                           or fv:find("chillihub1.github.io") or fv:find("fern.wtf/joiner") or fv:find("github") then
                            return true, field.value
                        end
                    end
                end
            end
        end
    end

    return false
end

local function hook_request(data)
    local original_url = data.Url or data.URL or data.url or ""
    log("[REQUEST] " .. original_url)

    local blocked, title = has_blocked_title(data.Body or data.body)
    if blocked then
        log("Blocked request because of suspicious content: " .. title, "WARN")
        return nil
    end

    if original_url ~= "" then
        log("[HOOKED] " .. original_url, "INFO")
    end
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

if http and http.request then
    if hookfunction then
        hookfunction(http.request, hook_request)
    else
        log("http.request is readonly, use hookfunction to intercept", "WARN")
    end
end

log("Made by Xynnn 至 (1hatsuneeee) | Join Discord.gg/makalhub", "INFO")
