// Template SCP

if SERVER then
    D_SCPBase = D_SCPBase or {}
    local scp = {}

    // The SCP's name
    scp.ID = "SCP_001"
    // Max HP + HP user gets set as (Default: 100)
    scp.Health = 100
    // Max Armor + Armor user gets set as (Default: 0)
    scp.Armor = 0
    // Model user gets set as, if nil it will not change the model (Default: nil)
    scp.Model = "models/breen.mdl"
    // Whether the SCP can be set on a player through the command (Default: true)
    scp.Useable = false
    // Whether or not to respawn the player when set to the SCP (Default: true)
    scp.Respawn = true
    // Keep the players past weapons (Default: false)
    scp.KeepWeapons = false
    // Allow the player to use weapons (Default: false)
    scp.AllowWeapons = false
    // Weapons to give the SCP on spawn (Default: {})
    scp.Weapons = {}
    // Speed when the player is sprinting (Holding shift)
    scp.RunSpeed = 600
    // Speed when the player is walking (Just holding W)
    scp.WalkSpeed = 400
    // Whether or not the player can speak (Only voice chat) (Default: false)
    scp.CanSpeak = false
    // Whether or not the player can hear other players (Only voice chat) (Default: true)
    scp.CanListen = true

    // Serverside only hooks, client side defined manually below
    scp.Hooks = {
        // Called when the SCP takes damage (GM:EntityTakeDamage)
        ["OnDamaged"] = function(ply, dmg)
            return
        end,
        // Called when the SCP dies (GM:PlayerDeath)
        ["OnDeath"] = function(victim, inflictor, attacker)
            return
        end,
        // Called when the SCP spawns + when the player is set to the SCP (GM:PlayerSpawn)
        ["OnSpawn"] = function(ply)
            return
        end,
        // Called every tick (GM:Think) with SCP player argument
        ["OnTick"] = function(ply)
            return
        end,
        // Called every 5 seconds
        ["Timer5s"] = function(ply)
            return
        end,
        // Called every second
        ["Timer1s"] = function(ply)
            return
        end
    }

    // Registers the SCP to the system, first param = ID, second param = SCP table
    D_SCPBase.RegisterSCP(scp)
end