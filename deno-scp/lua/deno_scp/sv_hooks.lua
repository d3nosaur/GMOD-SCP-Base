D_SCPBase = D_SCPBase or {}

// Hashmap of events and the people who are listening to them
local watchLog = {}

local hooks = {
    ["OnDamaged"] = {
        ["Hook"] = "EntityTakeDamage",
        ["Function"] = function(ply, dmg)
            local listeners = watchLog["OnDamaged"]

            if not istable(listeners) or table.IsEmpty(listeners) then 
                hook.Remove("EntityTakeDamage", "D_SCPBase_OnDamaged")
                print("[(D) SCP-Base Loader] Removed unused hook: D_SCPBase_OnDamaged")
                return 
            end

            if listeners[ply] then
                local hookData = listeners[ply]

                if(hookData.SCPID != ply:GetSCP()) then
                    listeners[ply] = nil
                    return
                end

                hookData.Function(ply, dmg)
            end
        end 
    },
    ["OnDeath"] = {
        ["Hook"] = "PlayerDeath",
        ["Function"] = function(ply, inflictor, attacker)
            local listeners = watchLog["OnDeath"]

            if not istable(listeners) or table.IsEmpty(listeners) then 
                hook.Remove("PlayerDeath", "D_SCPBase_OnDeath")
                print("[(D) SCP-Base Loader] Removed unused hook: D_SCPBase_OnDeath")
                return 
            end

            if listeners[ply] then
                local hookData = listeners[ply]

                if(hookData.SCPID != ply:GetSCP()) then
                    listeners[ply] = nil
                    return
                end

                hookData.Function(ply, inflictor, attacker)
            end
        end 
    },
    ["OnSpawn"] = {
        ["Hook"] = "PlayerSpawn",
        ["Function"] = function(ply)
            local listeners = watchLog["OnSpawn"]

            if not istable(listeners) or table.IsEmpty(listeners) then 
                hook.Remove("PlayerSpawn", "D_SCPBase_OnSpawn")
                print("[(D) SCP-Base Loader] Removed unused hook: D_SCPBase_OnSpawn")
                return 
            end

            if listeners[ply] then
                local hookData = listeners[ply]

                if(hookData.SCPID != ply:GetSCP()) then
                    listeners[ply] = nil
                    return
                end

                hookData.Function(ply)
            end
        end 
    },
    ["OnTick"] = {
        ["Hook"] = "Think",
        ["Function"] = function()
            local listeners = watchLog["OnTick"]

            if not istable(listeners) or table.IsEmpty(listeners) then 
                hook.Remove("Think", "D_SCPBase_OnTick")
                print("[(D) SCP-Base Loader] Removed unused hook: D_SCPBase_OnTick")
                return 
            end

            for ply, hookData in pairs(listeners) do
                if !IsValid(ply) or !istable(hookData) or hookData.SCPID != ply:GetSCP() then
                    listeners[ply] = nil
                    continue
                end
        
                hookData.Function(ply)
            end
        end 
    }
}

--- Registers the SCP hook listeners
-- @param Player ply the player to register the hook listeners for
-- @param Table scpTable the SCP's data
function D_SCPBase.RegisterSCPHooks(ply, scpTable)
    if not IsValid(ply) or not istable(scpTable) then return end

    local scpHooks = scpTable.Hooks

    for hookName, hookFunction in pairs(scpHooks) do
        watchLog[hookName] = watchLog[hookName] or {}

        watchLog[hookName][ply] = {
            ["Function"] = hookFunction,
            ["SCPID"] = scpTable.ID
        }

        hook.Add(hooks[hookName].Hook, "D_SCPBase_" .. hookName, hooks[hookName].Function)
    end
end