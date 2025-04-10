local mp = require 'mp'

function show_osd(text, duration, position)
    local width = mp.get_property_number("osd-width")
    local height = mp.get_property_number("osd-height")
    
    mp.msg.info("Resolution: " .. width .. "x" .. height)
    
    local base_font_size = 28
    local scale_factor = math.min(width / 1280, height / 720)
    local adjusted_font_size = math.floor(base_font_size * scale_factor)
    
    local positions = {
        top_center = string.format("{\\1c&H00FFFF&\\fs%d\\an5\\pos(%d,%d)}", 
            adjusted_font_size, width / 2, adjusted_font_size),
        upper_right = string.format("{\\1c&H00FFFF&\\fs%d\\an9\\pos(%d,%d)}", 
            adjusted_font_size, width - 10, 5), -- Near top-right corner
        middle_center = string.format("{\\1c&H00FFFF&\\fs%d\\an5\\pos(%d,%d)}", 
            adjusted_font_size, width / 2, height / 2),
        bottom_center = string.format("{\\1c&H00FFFF&\\fs%d\\an2\\pos(%d,%d)}", 
            adjusted_font_size, width / 2, height * 0.9),
        bottom_right = string.format("{\\1c&H00FFFF&\\fs%d\\an3\\pos(%d,%d)}", 
            adjusted_font_size, width * 0.9, height * 0.9)
    }
    
    local pos_data = positions[position]
    mp.msg.info("OSD Position: " .. pos_data)
    
    mp.command_native({
        name = "osd-overlay",
        id = 1,
        format = "ass-events",
        data = pos_data .. text,
        res_x = width,
        res_y = height
    })
    mp.add_timeout(duration, function()
        mp.command_native({
            name = "osd-overlay",
            id = 1,
            format = "none",
            data = ""
        })
    end)
end

mp.add_key_binding("Alt+5", "top_center", function()
    show_osd("Test Message", 3, "top_center")
end)
mp.add_key_binding("Alt+6", "upper_right", function()
    show_osd("Test Message", 3, "upper_right")
end)
mp.add_key_binding("Alt+7", "middle_center", function()
    show_osd("Test Message", 3, "middle_center")
end)
mp.add_key_binding("Alt+8", "bottom_center", function()
    show_osd("Test Message", 3, "bottom_center")
end)
mp.add_key_binding("Alt+9", "bottom_right", function()
    show_osd("Test Message", 3, "bottom_right")
end)
