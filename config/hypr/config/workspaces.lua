-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Add your workspace rules here. Increment the workspace number as you go. Do not have duplicate workspaces.
hl.workspace_rule({ workspace = "name:gaming", monitor = PRIMARY_MONITOR })
-- No persistent = true anywhere: workspaces are created on demand and disappear
-- again once their last window closes, so the bar only shows ones in use.
hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true })
hl.workspace_rule({ workspace = "2", monitor = MONITOR1 })
hl.workspace_rule({ workspace = "3", monitor = MONITOR1 })
hl.workspace_rule({ workspace = "4", monitor = MONITOR1 })
hl.workspace_rule({ workspace = "5", monitor = MONITOR1 })
hl.workspace_rule({ workspace = "6", monitor = MONITOR1 })
hl.workspace_rule({ workspace = "7", monitor = MONITOR1 })
hl.workspace_rule({ workspace = "8", monitor = MONITOR1 })
hl.workspace_rule({ workspace = "9", monitor = MONITOR1 })
-- When you add a second monitor, set MONITOR2 in variables.lua and move some of
-- the rules above onto it, e.g. monitor = MONITOR2, default = true.
