local mp = require 'mp'
local utils = require 'mp.utils'

function show_directory_contents()
    -- Get current file path
    local filepath = mp.get_property("path")
    if not filepath then
        mp.msg.warn("No file currently playing")
        return
    end
    
    -- Get directory from filepath
    local directory = utils.split_path(filepath)
    if directory == "." then
        directory = mp.get_property("working-directory")
    end
    
    -- Get all files in directory
    local files = utils.readdir(directory, "files")
    if not files then
        mp.msg.warn("Could not read directory")
        return
    end
    
    -- Sort files alphabetically
    table.sort(files, function(a, b)
        return a:lower() < b:lower()  -- Case-insensitive sorting
    end)
    
    -- Prepare OSD text
    local osd_text = "Directory contents:\\N"
    for i, file in ipairs(files) do
        osd_text = osd_text .. file .. "\\N"
    end
    
    -- Get screen dimensions
    local width = mp.get_property_number("osd-width")
    local height = mp.get_property_number("osd-height")
    
    -- Calculate font size based on screen resolution
    local base_font_size = 28
    local scale_factor = math.min(width / 1280, height / 720)
    local adjusted_font_size = math.floor(base_font_size * scale_factor)
    
    -- Upper-left position with yellow font
    local pos_data = string.format("{\\1c&H00FFFF&\\fs%d\\an7\\pos(%d,%d)}", 
        adjusted_font_size, 10, 5) -- an7 is upper-left, 10,5 is near top-left corner
    
    -- Show OSD
    mp.command_native({
        name = "osd-overlay",
        id = 1,
        format = "ass-events",
        data = pos_data .. osd_text,
        res_x = width,
        res_y = height
    })
    
    -- Remove OSD after 10 seconds
    mp.add_timeout(10, function()
        mp.command_native({
            name = "osd-overlay",
            id = 1,
            format = "none",
            data = ""
        })
    end)
end

-- Bind to Ctrl+d
mp.add_key_binding("Ctrl+d", "show_directory", show_directory_contents)
