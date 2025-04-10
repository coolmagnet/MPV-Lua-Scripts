local SORT_MODES = {"date", "date-desc", "name"}
local current_sort_idx = 2
local SORTBY = SORT_MODES[current_sort_idx]
local last_playlist_count = 0
local is_directory_loaded = false
local playlist_stable_timer = nil

mputils = require 'mp.utils'

function show_osd(text, duration)
    local width = mp.get_property_number("osd-width")
    local height = mp.get_property_number("osd-height")
    
    local base_font_size = 28
    local scale_factor = math.min(width / 1280, height / 720)
    local adjusted_font_size = math.floor(base_font_size * scale_factor)
    
    local osd_format = string.format("{\\1c&H00FFFF&\\fs%d\\an5\\pos(%d,%d)}", 
        adjusted_font_size, width / 2, adjusted_font_size)
    
    mp.command_native({
        name = "osd-overlay",
        id = 1,
        format = "ass-events",
        data = osd_format .. text,
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

function get_file_info_from_path(filepath)
    local dir, filename = mputils.split_path(filepath)
    local info = mputils.file_info(filepath)
    return {
        path = filepath,
        name = filename,
        mtime = info and info.mtime or 0
    }
end

function sort_files(files, sortby)
    table.sort(files, function(a, b)
        if sortby == "date" then
            return a.mtime < b.mtime
        elseif sortby == "date-desc" then
            return a.mtime > b.mtime
        elseif sortby == "name" then
            return a.name < b.name
        end
        return false
    end)
    return files
end

function sort_current_playlist()
    local pl_count = mp.get_property_number("playlist-count", 0)
    if pl_count <= 1 then return end

    -- Get current playlist
    local files = {}
    for i = 0, pl_count - 1 do
        local filepath = mp.get_property("playlist/" .. i .. "/filename")
        table.insert(files, get_file_info_from_path(filepath))
    end
    
    -- Sort and rebuild playlist
    sort_files(files, SORTBY)
    mp.commandv("playlist-clear")
    for i, file in ipairs(files) do
        local flag = i == 1 and "replace" or "append-play"
        mp.commandv("loadfile", file.path, flag)
    end
end

function check_playlist_stability()
    local current_count = mp.get_property_number("playlist-count", 0)
    if current_count == last_playlist_count and is_directory_loaded then
        -- Playlist has stabilized, apply sorting
        sort_current_playlist()
        is_directory_loaded = false -- Reset flag
        if playlist_stable_timer then
            playlist_stable_timer:kill()
            playlist_stable_timer = nil
        end
    end
    last_playlist_count = current_count
end

function on_start_file()
    local path = mp.get_property("path", "")
    local info = mputils.file_info(path)
    
    if info and info.is_dir then
        is_directory_loaded = true
        last_playlist_count = 0 -- Reset to detect growth
        -- Start a timer to check for playlist stability
        if not playlist_stable_timer then
            playlist_stable_timer = mp.add_periodic_timer(0.5, check_playlist_stability)
        end
        return
    end
    
    if info and info.is_file then
        local pl_count = mp.get_property_number("playlist-count", 0)
        if pl_count <= 1 then
            return
        end
    end
end

function on_playlist_change(name, value)
    local current_count = mp.get_property_number("playlist-count", 0)
    
    -- For non-directory cases (e.g., multiple files), sort immediately
    if current_count > last_playlist_count and last_playlist_count >= 0 and not is_directory_loaded then
        mp.add_timeout(0.1, function()
            sort_current_playlist()
        end)
    end
    
    last_playlist_count = current_count
end

function toggle_sort()
    local pl_count = mp.get_property_number("playlist-count", 1)
    if pl_count <= 1 then return end

    current_sort_idx = (current_sort_idx % #SORT_MODES) + 1
    SORTBY = SORT_MODES[current_sort_idx]
    show_osd("Sort mode: " .. SORTBY, 3)
    
    sort_current_playlist()
end

-- Helper functions from original script
function add_files_at(index, files)
    index = index - 1
    local oldcount = mp.get_property_number("playlist-count", 1)
    for i = 1, #files do
        mp.commandv("loadfile", files[i], "append")
        mp.commandv("playlist-move", oldcount + i - 1, index + i - 1)
    end
end

function get_extension(path)
    local match = string.match(path, "%.([^%.]+)$")
    return match and match:lower() or "nomatch"
end

function get_file_info(dir, filename)
    local filepath = mputils.join_path(dir, filename)
    local info = mputils.file_info(filepath)
    return {
        path = filepath,
        name = filename,
        mtime = info and info.mtime or 0
    }
end

mp.register_event("start-file", on_start_file)
mp.add_key_binding("Ctrl+z", "toggle_sort", toggle_sort)
mp.observe_property("playlist-count", "number", on_playlist_change)
