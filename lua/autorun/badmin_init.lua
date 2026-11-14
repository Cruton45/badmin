if bAdmin and bAdmin.Loaded then
    return
end

bAdmin = bAdmin or {}
bAdmin.Version = "2.0.0-dev"

-- Prevent the legacy bloodyAdmin.lua loader from running in mixed checkouts.
-- Remove this compatibility flag once the legacy loader has been deleted.
bAdmin_IsLoaded = true

local ROOT = "badmin/"
local CAMI_PATH = ROOT .. "lib/sh_cami.lua"

local REALM_SHARED = 1
local REALM_SERVER = 2
local REALM_CLIENT = 3

local realmNames = {
    [REALM_SHARED] = "shared",
    [REALM_SERVER] = "server",
    [REALM_CLIENT] = "client"
}

local function log(message)
    MsgC(Color(255, 0, 0), "[bAdmin] ", color_white, message .. "\n")
end

local function loadFile(path, realm)
    if realm == REALM_SHARED then
        if SERVER then
            AddCSLuaFile(path)
        end

        include(path)
        return
    end

    if realm == REALM_SERVER then
        if SERVER then
            include(path)
        end

        return
    end

    if realm == REALM_CLIENT then
        if SERVER then
            AddCSLuaFile(path)
        else
            include(path)
        end
    end
end

local function loadDirectory(directory, realm)
    local searchPath = ROOT .. directory .. "/*.lua"
    local files = file.Find(searchPath, "LUA", "nameasc") or {}

    for _, fileName in ipairs(files) do
        local path = ROOT .. directory .. "/" .. fileName
        loadFile(path, realm)
        log("Loaded " .. realmNames[realm] .. " file: " .. path)
    end
end

-- CAMI is a required shared dependency and must be available before badmin.
if not file.Exists(CAMI_PATH, "LUA") then
    ErrorNoHalt("[bAdmin] Missing required dependency: lua/" .. CAMI_PATH .. "\n")
    return
end

loadFile(CAMI_PATH, REALM_SHARED)
log("Loaded dependency: " .. CAMI_PATH)

-- Shared files load first so both realms have the same configuration and APIs.
loadDirectory("shared", REALM_SHARED)

if SERVER then
    -- Server systems load before command definitions that depend on them.
    loadDirectory("server", REALM_SERVER)
    loadDirectory("server/commands", REALM_SERVER)

    -- Client files are distributed now and included by each client later.
    loadDirectory("client", REALM_CLIENT)
else
    loadDirectory("client", REALM_CLIENT)
end

bAdmin.Loaded = true
log("Version " .. bAdmin.Version .. " loaded successfully")