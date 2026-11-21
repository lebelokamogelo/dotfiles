-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Add your workspace rules here. Increment the workspace number as you go. Do not have duplicate workspaces.
hl.workspace_rule({ workspace = "name:gaming", monitor = PRIMARY_MONITOR })
-- No persistent = true anywhere: workspaces are created on demand and disappear
-- again once their last window closes, so the bar only shows ones in use.
