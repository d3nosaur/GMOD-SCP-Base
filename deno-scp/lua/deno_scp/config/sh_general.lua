D_SCPBase = D_SCPBase or {}
D_SCPBase.Config = D_SCPBase.Config or {}

D_SCPBase.Config.General = {
    ["AdminCheck"] = function(ply) -- Used to determine if a player is an admin (Can use the scp_setplayer and scp_removeplayer commands)
        return true
    end,
    ["scp_setplayer"] = true, -- Whether or not to enable the scp_setplayer command
    ["scp_removeplayer"] = true, -- Whether or not to enable the scp_removeplayer command
    ["Debug"] = true, -- Whether or not to send debug messages to the console
}