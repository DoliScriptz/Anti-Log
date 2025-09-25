--[[
    Roblox LuaU Script to block Chilli Notifiers and So.
    CLAIMING THIS SCRIPT AS YOUR OWN IS NOT ALLOWED.
    Made by Xynnn 至 (1hatsuneeee)
    still WIP and may not work for all notifiers
]]
local CONSOLE_URL = "https://raw.githubusercontent.com/notpoiu/Scripts/main/utils/console/main.lua" -- coloured shit thing i found looks cool
local function fetch_remote(url)
    local ok,res = pcall(function() return game:HttpGet(url) end)
    if ok and res then return res end
    ok,res = pcall(function()
        local req = rawget(_G,"request") or rawget(_G,"http_request")
        if req then
            local r = req({Url=url,Method="GET"})
            return (type(r)=="table" and (r.Body or r.body)) or r
        end
    end)
    if ok and res then return res end
    return nil
end

local remote_code = fetch_remote(CONSOLE_URL)
local console_utils
if remote_code then
    local ok,chunk = pcall(loadstring,remote_code)
    if ok and chunk then
        local ok2,result = pcall(chunk)
        console_utils = (ok2 and result) or (getgenv and getgenv().console_utils) or shared.console_utils or _G.console_utils
    end
else
    console_utils = (getgenv and getgenv().console_utils) or shared.console_utils or _G.console_utils
end

local custom_print = (console_utils and console_utils.custom_print) or function(m) if type(m)=="table" then print(m.message or tostring(m)) else print(tostring(m)) end end

local req = (syn and syn.request) or request or http_request or (http and http.request)
if not req then
    return
end

local old_request = req

local function has_blocked_title(body)  -- unsure about this will work for all notifiers
    if type(body) ~= "string" then
        return false
    end

    local ok, decoded = pcall(game:GetService("HttpService").JSONDecode, game:GetService("HttpService"), body)
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
                        if fv:find("job id") or fv:find("click to join") or fv:find("game:getservice") or fv:find("chillihub1.github.io") or fv:find("fern.wtf/joiner") or fv:find("github") then
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
    custom_print({message="[REQUEST] "..original_url, color=Color3.fromRGB(100,100,255)}) -- prints header and shit
    local blocked, title = has_blocked_title(data.Body or data.body)
    if blocked then
        custom_print({message="[BLOCKED] request because of title: "..title, color=Color3.fromRGB(255,0,0)}) -- reason it blocked
        return nil
    end
    if original_url ~= "" then
        custom_print({message="[HOOKED] "..original_url, color=Color3.fromRGB(0,255,0)})
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
        custom_print({message="[WARN] http.request is readonly, use hookfunction to intercept", color=Color3.fromRGB(255,255,0)}) -- will never possibly happen unless ur executor is shitty twin
    end
end
custom_print({message="Made by Xynnn 至 (1hatsuneeee) | Join Discord.gg/makalhub", color=Color3.fromRGB(255,100,200)})
