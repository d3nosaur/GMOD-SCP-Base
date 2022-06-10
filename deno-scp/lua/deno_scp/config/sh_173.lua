D_SCPBase = D_SCPBase or {}
D_SCPBase.Config = D_SCPBase.Config or {}

D_SCPBase.Config.SCP_173 = {
    ["ManualBlinkDelay"] = 0.5, -- Delay between each time the player can manually blink
    ["ForcedBlinkDelay"] = 5, -- Delay between each forced blink
    ["ManualBlinkKey"] = KEY_N, -- Key to manually blink (https://wiki.facepunch.com/gmod/Enums/KEY)
    ["ManualBlinking"] = true, -- Whether or not the player can manually blink
    ["BlinkLength"] = 0.3, -- The time that the player will blink for (Effects both client side view and the SCP on server)

    ["AnimatedBlink"] = true, -- Whether or not to animate the blink (Only client side)
    ["ChangePoses"] = true, -- Whether or not to change the SCP's pose when looking away (Only works with Pandemic model)
    ["Model"] = "Peanut", -- Which model to use ("Peanut", or "Pandemic"). Peanut is the one from SCP Containment Breach, Pandemic is the one from SCP Pandemic

    ["AttackDelay"] = 3, -- Delay between attacks
    ["AttackRange"] = 256, -- Range of the attack
    ["AttackDamage"] = 1000, -- Damage of the attack

    ["Health"] = 10000, -- Health of the SCP
    ["Armor"] = 0, -- Armor of the SCP
    ["RunSpeed"] = 600, -- Run speed of the SCP (DarkRP Default = 240)
    ["WalkSpeed"] = 400, -- Walk speed of the SCP (DarkRP Default = 160)

    ["CanSpeak"] = false -- Whether or not the SCP can speak
}