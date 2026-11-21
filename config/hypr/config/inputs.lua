-- Input configuration

hl.config({
    input = {
        -- sensitivity = -0.25,
        accel_profile = "flat",
        numlock_by_default = true,
        -- Scroll direction. false = "traditional" (fingers down -> view scrolls down),
        -- true = "natural" (content follows your fingers, phone/Mac style).
        -- Flip both of these together if the direction feels wrong.
        natural_scroll = false,
        scroll_factor  = 1.0,
        touchpad = {
            natural_scroll = false,
            scroll_factor  = 1.0,
        },
    },
    -- Uncomment the section below to enable software cursors; this can help with cursor display or behavior issues
    -- cursor = {
    --     no_hardware_cursors = 1,
    -- },
})

-- hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
