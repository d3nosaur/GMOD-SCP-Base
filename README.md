# D-SCP Base

A base for player-controlled SCPs in Garry's Mod. SCP-173 is included as the reference implementation. You register an SCP with a stats table and a `Hooks` table; the base handles spawning, networking, config, and cleanup.

## Loading

`lua/autorun/deno_scp_loader.lua` recursively loads `config`, `core`, then `scp` in that order. Order matters: SCP files read from `D_SCPBase.Config` and call `D_SCPBase.RegisterSCP`, both populated by the earlier dirs.

Everything is on the global `D_SCPBase`.

## Registering an SCP

`D_SCPBase.RegisterSCP(scpTable)`, server-side. Only `ID` is required; everything else defaults in `sv_main.lua`. `sh_scp_1.lua` is a template with every field documented.

Player API (`ply:SetSCP(id)`, `:RemoveSCP()`, `:GetSCP()`, `:IsSCP()`). `SetSCP` sets a player to an SCP, overriding existing SCP if previously set. State is in `D_SCPBase.ActiveSCPs[ply]` server-side, mirrored to clients via the `SCP`/`SCP_ID` networked vars. Admin commands `scp_setplayer`/`scp_removeplayer` exist (toggleable in General config).

## Hooks

SCPs don't add Gmod hooks. They declare functions in their `Hooks` table keyed by name (`OnTick`, `OnDamaged`, `OnDeath`, `OnSpawn`, `OnPrimaryAttack`, `CalcMainActivity`, `Timer1s`, `Timer5s`, `Timer1/4s`, `OnRemoved`), and `RegisterSCPHooks` wires them up as listeners.

The dispatcher:
- Only adds the real Gmod hook/timer when a listener exists, removes it when the listener table empties.
- Stores the `SCPID` per listener; drops it automatically when the player's current SCP no longer matches (switched or removed).
- The `TimerNs` keys are second-based timers instead of per-frame.

Prefer the hook system over per-SCP `hook.Add` so things stay free when no one's that SCP.

## Config

Tables in `config/`, settings keyed with `Type` (`Number`/`Boolean`/`Key`/`Multiple`), default `Value`, and metadata. SCPs read at registration (`scp.Health = config.Health.Value`).

Server loads `d_scpbase_config.json` over the defaults on startup (so new settings still appear). `scp_config` opens the menu, which builds itself from the tables- a new setting renders automatically with the right widget. On close the client pushes the edited config back, server saves and broadcasts.

## SCP-173

The reference for non-trivial work on the base:
- Client checks every 0.1s whether it can see a 173 (`ply:CanSee`, `sh_libfunctions.lua`) and registers/deregisters itself as a watcher, so the server isn't running visibility for everyone (primary optimization technique- still verified by server).
- Server `OnTick` iterates only watchers, handles per-watcher forced blinks, and freezes/unfreezes 173 based on whether any non-blinking watcher sees it.

Blinking is per-player and desynced; manual blink (`KEY_N`) is rate-limited server-side; the blink is a client HUD draw off a net message. Attacks fire on `OnPrimaryAttack`, range/cooldown gated.

## Layout

```
autorun/deno_scp_loader.lua   loader
deno_scp/
  config/                     setting defs
  core/
    sv_main.lua               RegisterSCP, SetSCP, defaults
    sv/cl_metafunctions.lua   player API
    sv_hooks.lua              hook dispatcher
    sv_scpsetup.lua           stat application, weapon/voice/death rules
    sv_commands.lua           console commands
    sh_libfunctions.lua       CanSee, TraceToEnd, lookups
    config_menu/              net + storage + VGUI
    render_util/              stencil outline
  scp/
    sh_scp_1.lua              template
    sh_scp_173.lua            173
```
