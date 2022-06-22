D_SCPBase = D_SCPBase or {}
D_SCPBase.Config = D_SCPBase.Config or {}

// Copies tbl1's contents into tbl2. If tbl1 doesn't have a key from tbl2, it will be added.
local function copyTable(tbl1, tbl2)
    for k,v in pairs(tbl2) do
        if tbl1[k] == nil then
            tbl1[k] = v
            continue
        end

        if type(v) == "table" then
            copyTable(v, tbl1[k])
        end
    end

    return tbl1
end

D_SCPBase.LoadStoredConfig = function()
    local JSONTable = file.Read("d_scpbase_config.json")
    local config = util.JSONToTable(JSONTable)

    copyTable(config, D_SCPBase.Config)

    D_SCPBase.Config = config
    if D_SCPBase.Config.General.Debug.Value then print("[(D) SCP-Base] Loaded config.") end
end

D_SCPBase.SaveConfig = function()
    local JSONTable = util.TableToJSON(D_SCPBase.Config)
    file.Write("d_scpbase_config.json", JSONTable)

    D_SCPBase.UpdateAllClientsConfig()

    if D_SCPBase.Config.General.Debug.Value then print("[(D) SCP-Base] Saved config.") end
end

D_SCPBase.UpdateConfig = function(config)
    PrintTable(config)
    D_SCPBase.Config = copyTable(config, D_SCPBase.Config)

    D_SCPBase.SaveConfig()
end

D_SCPBase.LoadStoredConfig()