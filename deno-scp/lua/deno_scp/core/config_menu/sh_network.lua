D_SCPBase = D_SCPBase or {}

if SERVER then
    util.AddNetworkString("D_SCPBase_UpdateClientConfig")
    util.AddNetworkString("D_SCPBase_UpdateAllClientsConfig")
    util.AddNetworkString("D_SCPBase_RequestConfig")
    util.AddNetworkString("D_SCPBase_UpdateServerConfig")
    util.AddNetworkString("D_SCPBase_OpenConfigMenu")

    D_SCPBase.UpdateClientConfig = function(ply)
        net.Start("D_SCPBase_UpdateClientConfig")
            net.WriteTable(D_SCPBase.Config)
        net.Send(ply)
    end

    D_SCPBase.UpdateAllClientsConfig = function(ply)
        net.Start("D_SCPBase_UpdateAllClientsConfig")
            net.WriteTable(D_SCPBase.Config)
        net.Broadcast()
    end

    D_SCPBase.OpenConfigMenu = function(ply)
        if not ply:IsAdmin() then return end

        net.Start("D_SCPBase_OpenConfigMenu")
        net.Send(ply)
    end

    net.Receive("D_SCPBase_RequestConfig", function(len, ply)
        if not ply:IsAdmin() then return end

        D_SCPBase.UpdateClientConfig(ply)
    end)

    net.Receive("D_SCPBase_UpdateServerConfig", function(len, ply)
        if not ply:IsAdmin() then return end

        local config = net.ReadTable()

        D_SCPBase.UpdateConfig(config)
    end)
end

if CLIENT then
    D_SCPBase.RequestConfig = function()
        net.Start("D_SCPBase_RequestConfig")
        net.SendToServer()
    end

    D_SCPBase.UpdateServerConfig = function(config)
        net.Start("D_SCPBase_UpdateServerConfig")
            net.WriteTable(config)
        net.SendToServer()
    end

    net.Receive("D_SCPBase_UpdateClientConfig", function(len)
        local config = net.ReadTable()

        D_SCPBase.Config = config
    end)

    net.Receive("D_SCPBase_UpdateAllClientsConfig", function(len)
        local config = net.ReadTable()

        D_SCPBase.Config = config
    end)

    net.Receive("D_SCPBase_OpenConfigMenu", function()
        D_SCPBase.OpenConfigMenu()
    end)
end