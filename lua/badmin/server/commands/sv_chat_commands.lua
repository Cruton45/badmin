local config = badmin.Config

local function parseCommand(text)
    local args = {}
    local current = {}

    local inQuotes = false
    local tokenStarted = false

    for i = 1, #text do
        -- Grab our next char in the command string
        local character = text:sub(i, i)

        if character == '"' then
            inQuotes = not inQuotes
            tokenStarted = true
        elseif character:match("%s") and not inQuotes then
            if tokenStarted then
                args[#args + 1] = table.concat(current)
                current = {}
                tokenStarted = false
            end
        else
            current[#current + 1] = character
            tokenStarted = true
        end
    end

    -- Reached end of command string without finding ending qoutes
    if inQuotes then
        return nil, "Could not read command, missing ending quotes."
    end

    if tokenStarted then
        args[#args + 1] = table.concat(current)
    end

    return args
end

local function runCommand(ply, text)
    -- Parse command
    local args, err = parseCommand(text)

    -- If finding args failed print error and return
    if not args then
        ply:ChatPrint("[badmin] " .. err)
        return
    end

    -- Get our requested command by popping from the args stack.
    local requestedCommand = table.remove(args, 1)


end

hook.Add("PlayerSay", "BADMIN.PlayerSay", function(ply, text)
    local prefix = config.ChatPrefix or "!"

    -- Allow ordinary chat.
    if text:sub(1, #prefix) ~= prefix then
        return
    end

    local input = text:sub(#prefix + 1)

    -- Treat "(PREFIX)" and "(PREFIX) command" as ordinary chat rather than commands.
    if input == "" or input:sub(1, 1):match("%s") then
        return
    end

    runCommand(ply, input)

    -- Hide the command from chat.
    return ""
end)