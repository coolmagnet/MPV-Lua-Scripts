local mp = require 'mp'

-- Global variables to track overlay state
local overlay = nil
local timer = nil
local is_visible = false

-- Function to show/hide the playlist
local function toggle_playlist()
    -- If overlay exists and is visible, remove it
    if is_visible and overlay then
        overlay:remove()
        if timer then
            timer:kill()  -- Cancel the existing timer
        end
        is_visible = false
        return
    end

    -- Get playlist data
    local playlist = mp.get_property_native("playlist")
    if not playlist or #playlist == 0 then
        mp.osd_message("No playlist available", 10)
        return
    end

    -- Build the playlist text with ASS formatting
    local playlist_text = "{\\an7\\c&H00FFFF&}" -- Top-left alignment, yellow color
--    local playlist_text = "{\\an1\\c&H00FFFF&}" -- Bottom-left alignment, yellow color
--    local playlist_text = "{\\an9\\c&H00FFFF&}" -- Top-right alignment, yellow color
--    local playlist_text = "{\\an3\\c&H00FFFF&}" -- Bottom-right alignment, yellow color
    local current_pos = mp.get_property_number("playlist-pos-1", 1)
    for i, item in ipairs(playlist) do
        local dot = (i == current_pos) and "●" or "○"
        local name = item.filename:match("^.+/(.+)$") or item.filename
        playlist_text = playlist_text .. dot .. " " .. name .. "\\N"
    end

    -- Create or update the overlay
    if not overlay then
        overlay = mp.create_osd_overlay("ass-events")
    end
    overlay.data = playlist_text
    overlay:update()
    is_visible = true

    -- Set up the 10-second timeout
    if timer then
        timer:kill()  -- Cancel any existing timer
    end
    timer = mp.add_timeout(10, function()
        if overlay then
            overlay:remove()
            is_visible = false
        end
    end)
end

-- Bind F8 key to toggle the playlist
mp.add_key_binding("F8", "toggle-playlist", toggle_playlist)
