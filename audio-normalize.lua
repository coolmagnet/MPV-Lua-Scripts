-- audio-normalize.lua
-- Toggles audio normalization using af lavfi compressor
-- Hotkey: Ctrl+`

local mp = require 'mp'

-- Flag to track normalization state
local is_normalized = false

-- Audio filter settings for normalization
local normalizer_filter = 'lavfi=[compand=attacks=0.3:decays=0.8:points=-70/-70|-24/-20|0/-5|20/0]'

function toggle_normalization()
    if not is_normalized then
        -- Enable normalization
        mp.commandv('af', 'add', normalizer_filter)
        mp.osd_message('Audio Normalization: ON')
        is_normalized = true
    else
        -- Disable normalization
        mp.commandv('af', 'remove', normalizer_filter)
        mp.osd_message('Audio Normalization: OFF')
        is_normalized = false
    end
end

-- Bind Ctrl+` to toggle normalization
mp.add_key_binding('Ctrl+`', 'toggle-normalization', toggle_normalization)
