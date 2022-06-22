D_SCPBase = D_SCPBase or {}
D_SCPBase.Config = D_SCPBase.Config or {}

D_SCPBase.Config.General = {
    ["scp_setplayer"] = {
        ["Type"] = "Boolean",
        ["Value"] = true,
        ["Description"] = "Enable the scp_setplayer command"
    },

    ["scp_removeplayer"] = {
        ["Type"] = "Boolean",
        ["Value"] = true,
        ["Description"] = "Enable the scp_removeplayer command."
    },

    ["Debug"] = {
        ["Type"] = "Boolean",
        ["Value"] = false,
        ["Description"] = "Debug messages in console."
    },
}