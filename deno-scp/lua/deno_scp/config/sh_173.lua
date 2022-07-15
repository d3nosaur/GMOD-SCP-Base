D_SCPBase = D_SCPBase or {}
D_SCPBase.Config = D_SCPBase.Config or {}

D_SCPBase.Config.SCP_173 = {
    ["ManualBlinkDelay"] = {
        ["Type"] = "Number",
        ["Value"] = 0.5,
        ["Min"] = 0.1,
        ["Max"] = 3,
        ["Description"] = "Delay between manual blinks (Seconds)"
    },
    
    ["ForcedBlinkDelay"] = {
        ["Type"] = "Number",
        ["Value"] = 5,
        ["Min"] = 1,
        ["Max"] = 60,
        ["Description"] = "Delay between each forced blink (Seconds)"
    },

    ["ManualBlinkKey"] = {
        ["Type"] = "Key",
        ["Value"] = KEY_N,
        ["Description"] = "Key to manually blink"
    },

    ["ManualBlinking"] = {
        ["Type"] = "Boolean",
        ["Value"] = true,
        ["Description"] = "Allow the player to blink manually"
    },

    ["BlinkLength"] = {
        ["Type"] = "Number",
        ["Value"] = 0.3,
        ["Min"] = 0.01,
        ["Max"] = 1,
        ["Description"] = "Length of the blink (Seconds)"
    },

    ["AnimatedBlink"] = {
        ["Type"] = "Boolean",
        ["Value"] = true,
        ["Description"] = "Animated visual blinking"
    },

    ["ChangePoses"] = {
        ["Type"] = "Boolean",
        ["Value"] = true,
        ["Description"] = "Change pose when unfrozen"
    },

    ["Model"] = {
        ["Type"] = "Multiple",
        ["Value"] = "Pandemic",
        ["Options"] = {
            ["Peanut"] = "models/scp173_new/scp173_new.mdl",
            ["Pandemic"] = "models/scp_pandemic/deno_ports/scp_173/scp_173.mdl",
        },
        ["Description"] = "SCP-173 Model"
    },

    ["AttackDelay"] = {
        ["Type"] = "Number",
        ["Value"] = 3,
        ["Min"] = 0.1,
        ["Max"] = 10,
        ["Description"] = "Delay between each attack (Seconds)"
    },

    ["AttackRange"] = {
        ["Type"] = "Number",
        ["Value"] = 256,
        ["Min"] = 1,
        ["Max"] = 2048,
        ["Description"] = "Range of SCP-173's attack (Source Units)"
    },

    ["AttackDamage"] = {
        ["Type"] = "Number",
        ["Value"] = 1000,
        ["Min"] = 1,
        ["Max"] = 100000,
        ["Description"] = "Damage of SCP-173's attack"
    },

    ["Health"] = {
        ["Type"] = "Number",
        ["Value"] = 10000,
        ["Min"] = 1,
        ["Max"] = 100000,
        ["Description"] = "Health of SCP-173"
    },

    ["Armor"] = {
        ["Type"] = "Number",
        ["Value"] = 0,
        ["Min"] = 0,
        ["Max"] = 100000,
        ["Description"] = "Armor of SCP-173"
    },

    ["RunSpeed"] = {
        ["Type"] = "Number",
        ["Value"] = 600,
        ["Min"] = 1,
        ["Max"] = 5000,
        ["Description"] = "Speed of SCP-173's run"
    },

    ["WalkSpeed"] = {
        ["Type"] = "Number",
        ["Value"] = 400,
        ["Min"] = 1,
        ["Max"] = 5000,
        ["Description"] = "Speed of SCP-173's walk"
    },

    ["CanSpeak"] = {
        ["Type"] = "Boolean",
        ["Value"] = true,
        ["Description"] = "Allow SCP-173 to speak"
    },

    ["RemoveOnDeath"] = {
        ["Type"] = "Boolean",
        ["Value"] = true,
        ["Description"] = "Remove player from SCP-173 when they die"
    },
}