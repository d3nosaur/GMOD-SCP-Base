D_SCPBase = D_SCPBase or {}
D_SCPBase.SCPs = D_SCPBase.SCPs or {}

--- Finds a player by their name.
-- @param name The name of the player.
-- @return boolean player The player if found, true if multiple players with name found, false if no players found.
local function findPlayer(name)
    local target
    for k,v in ipairs(player.GetAll()) do
        if string.find(string.lower(v:Nick()), string.lower(name)) then
            if IsValid(target) then return true end
            target = v
        end
    end

    return target and target or false
end

--- Set a player to an SCP
-- @param ply The player to set.
-- @param scp The scp to set the player to.
concommand.Add("scp_setplayer", function(ply, cmd, args)
    if not ply:IsValid() then return end
    
    local target = args[1]
    local scp = args[2]

    if not target or not scp then 
        ply:PrintMessage(HUD_PRINTCONSOLE, "Usage: scp_setplayer <player> <scp>")
        return
    end

    if not D_SCPBase.SCPs[scp] then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid SCP, list of valid SCPs:")
        for k,v in pairs(D_SCPBase.SCPs) do
            ply:PrintMessage(HUD_PRINTCONSOLE, k)
        end
        return
    end

    local plyTarget = findPlayer(target)

    if plyTarget == true then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Multiple users with name " .. target .. " found.")
        return
    elseif plyTarget == false then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Can't find user with name " .. target .. ".")
        return
    end

    plyTarget:SetSCP(scp)
    ply:PrintMessage(HUD_PRINTCONSOLE, "Set " .. plyTarget:Nick() .. " to " .. scp .. ".")
end)

--- Removes a player from their active SCP
-- @param ply The player to remove.
concommand.Add("scp_removeplayer", function(ply, cmd, args)
    if not ply:IsValid() then return end
    
    local target = args[1]

    if not target then 
        ply:PrintMessage(HUD_PRINTCONSOLE, "Usage: scp_removeplayer <player>")
        return
    end

    local plyTarget = findPlayer(target)

    if plyTarget == true then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Multiple users with name " .. target .. " found.")
        return
    elseif plyTarget == false then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Can't find user with name " .. target .. ".")
        return
    end

    if plyTarget:RemoveSCP() then
        ply:PrintMessage(HUD_PRINTCONSOLE, "Removed " .. plyTarget:Nick() .. " from their active SCP.")
    else
        ply:PrintMessage(HUD_PRINTCONSOLE, plyTarget:Nick() .. " is not currently an SCP.")
    end
end)