-- Speedline: cel-shaded comic panels with everything flowing ↘ (top-left to bottom-right).
--
-- Hyprland can only slide a surface along one axis, so the diagonal is built
-- from pairs that move on both axes at once:
--   * workspaces: the old one drifts right while the new one drops in from above
--   * windows:    they fall in from the top and kick out to the right
--   * moves:      swapping/resizing tiles travel on x and y together, with overshoot
--   * borders:    a 45° pink/yellow/cyan streak that sweeps once on every focus

local active_border_color = { colors = { "rgba(ff4fa3ff)", "rgba(ffd93dff)", "rgba(3de1ffff)" }, angle = 45 }
local inactive_border_color = "rgba(5d529488)"

hl.config({
  general = {
    border_size = 3,
    gaps_in = 6,
    gaps_out = 14,

    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    rounding = 12,

    -- Hard, offset "ink" shadow down-right: the comic-panel look.
    shadow = {
      enabled = true,
      sharp = true,
      range = 2,
      offset = { 9, 9 },
      color = "rgba(07050fee)",
      color_inactive = "rgba(07050f88)",
    },
  },

  animations = {
    enabled = true,
  },
})

-- Curves ------------------------------------------------------------------
-- cartoonPop overshoots ~10% and settles, like a cel-animated "boing".
hl.curve("cartoonPop", { type = "bezier", points = { { 0.34, 1.56 }, { 0.64, 1 } } })
-- dash is a fast-out, long-tail ease for speed-line swipes.
hl.curve("dash", { type = "bezier", points = { { 0.16, 1 }, { 0.3, 1 } } })
-- windup accelerates away, for things leaving the frame.
hl.curve("windup", { type = "bezier", points = { { 0.7, 0 }, { 0.84, 0 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

-- Animations (speed is in tenths of a second) -------------------------------
hl.animation({ leaf = "global", enabled = true, speed = 8, bezier = "default" })

-- Windows: fall in from the top with a bounce, exit sliding right.
hl.animation({ leaf = "windows", enabled = true, speed = 4.2, bezier = "cartoonPop" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.6, bezier = "cartoonPop", style = "slide top" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2.2, bezier = "windup", style = "slide right" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4.0, bezier = "cartoonPop" })

hl.animation({ leaf = "fadeIn", enabled = true, speed = 2.0, bezier = "dash" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.8, bezier = "windup" })
hl.animation({ leaf = "fade", enabled = true, speed = 2.6, bezier = "dash" })
hl.animation({ leaf = "fadeSwitch", enabled = false })

-- Borders: colour change is quick; the 45° gradient sweeps once per focus.
hl.animation({ leaf = "border", enabled = true, speed = 4.0, bezier = "dash" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 9, bezier = "dash", style = "once" })

-- Workspaces: the pair below makes one ↘ wipe.
--   Out: "left" edge → the old workspace travels to the right.
--   In:  "top" edge  → the new workspace drops down from above.
hl.animation({ leaf = "workspaces", enabled = true, speed = 4.4, bezier = "dash" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 4.4, bezier = "dash", style = "slidefade top 22%" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 3.6, bezier = "dash", style = "slidefade left 22%" })

-- Layers that the shell leaves to the compositor (polkit, notifications).
hl.animation({ leaf = "layers", enabled = true, speed = 3.4, bezier = "cartoonPop" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 3.4, bezier = "cartoonPop", style = "popin 85%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.6, bezier = "windup", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.6, bezier = "dash" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.3, bezier = "linear" })

-- Notifications drop in from the top edge, same direction as new windows.
hl.layer_rule({ match = { namespace = "^omarchy-notifications$" }, animation = "slide top" })
