local gsub, lower, find, gfind = string.gsub, string.lower, string.find, string.gfind
local getn, loadfile, type = table.getn, loadfile, type
local setfenv, setmetatable = setfenv, setmetatable
local unpack, sub, pairs = unpack, string.sub, pairs

if _G.stitch then
    Trace("[Stitch] Reusing old stitch")
    Trace('[Stitch] We are on version "' .. stitch._VERSION .. '"')
    return
end

local stitch = { 
    _VERSION = 'Stitch 190731 dev' 
}

_G.stitch = stitch
_G.stx = stitch

local folder = '/'..THEME:GetCurThemeName()..'/'
local addFolder = lower(PREFSMAN:GetPreference('AdditionalFolders'))
local add = './themes,' .. gsub(addFolder, ',' ,'/themes,') .. '/themes'
local hit = ''

local requireCache = {}

local function load(name)
    local file = gsub(lower(name), '%.', '/') .. '.lua'
    local log={}
    for w in gfind(hit .. add,'[^,]+') do
        local path = gsub(w .. folder .. file, '/+', '/')
        local func, err = loadfile(path)
        if func then
            hit = w .. ','
            _G.Debug('[Loading] ' .. path)
            return func
        end
        log[getn(log)+1] = '[Error] ' .. err --gsub(err,'\n.+','')
    end

    for i=1, getn(log) do
        if not find(log[i], 'cannot read') then _G.Debug(log[i]) return end
    end
    _G.Debug(log[1])
end

function stitch.nocache( name, env, ... )
    name = lower(name)
    local func = load(name)
    if not func then
        return
    end

    env = env or {}
    env.arg = arg

    if not getmetatable(env) then
        setmetatable( env, { __index = _G, __newindex = _G } )
    end
    setfenv( func, env )

    return func()
end

function stitch.RequireEnv(name, env, ...)
    name = lower(name)
    if requireCache[name] then
        return unpack(requireCache[name])
    end
    local func = load(name)
    if not func then
        return
    end

    env = env or {}
    env.arg = arg

    if not getmetatable(env) then
        setmetatable( env, { __index = _G, __newindex = _G } )
    end

    setfenv( func, env )
    requireCache[name] = {func()}
    return unpack(requireCache[name])
end

function stitch.Require( name, ... )
    return stitch.RequireEnv(name, nil, unpack(arg))
end

function stitch:__call(name, ...)
    return stitch.RequireEnv(name, nil, unpack(arg))
end

setmetatable(stitch, stitch)

_G.Trace '[Stitch] Initialized!'
_G.Trace('[Stitch] We are on version "' .. stitch._VERSION .. '"')

-- Preload config
-- local config = setmetatable({},{})
-- stitch.RequireEnv("config", config)
-- requireCache["config"] = {config}

return stitch