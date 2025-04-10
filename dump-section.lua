local mp = require 'mp'
local utils = require 'mp.utils'

local start_time = nil
local end_time = nil
local buffer = 2 -- Adjust this (in seconds) based on your video's keyframe interval
local output_dir = "/home/USER/Videos" -- Fixed output directory

-- Container options: "mp4" (default) or "ts"
local container = "mp4" -- Default to MP4

-- Function to cycle between containers
local function cycle_container()
    if container == "mp4" then
        container = "ts"
        mp.osd_message("Container set to TS (video/audio only)")
    else
        container = "ts"
        container = "mp4"
        mp.osd_message("Container set to MP4 (video/audio/subtitles)")
    end
end

-- Function to mark the start of the section
local function mark_start()
    start_time = mp.get_property_number("time-pos")
    mp.osd_message("Start marked at " .. start_time .. " seconds")
end

-- Function to mark the end and dump the section
local function mark_end_and_dump()
    if not start_time then
        mp.osd_message("Error: Mark start time first!")
        return
    end
    end_time = mp.get_property_number("time-pos")
    if end_time <= start_time then
        mp.osd_message("Error: End time must be after start time!")
        return
    end

    local input_file = mp.get_property("path")
    local date_part = os.date("%m-%d-%Y", os.time())
    local epoch_time = os.time()
    local output_ext = (container == "mp4") and ".mp4" or ".ts"
    local output_file = utils.join_path(output_dir, "output_segment-" .. date_part .. "-" .. epoch_time .. output_ext)

    local adjusted_start = math.max(0, start_time - buffer)
    local adjusted_end = end_time + buffer

    -- FFmpeg command based on container
    local ffmpeg_cmd
    if container == "mp4" then
        -- MP4: Copy video, audio, and subtitles
        ffmpeg_cmd = string.format(
            'ffmpeg -i "%s" -ss %f -to %f -c:v copy -c:a copy -c:s copy -map 0:v -map 0:a -map 0:s? -f mp4 "%s" -y',
            input_file, adjusted_start, adjusted_end, output_file
        )
    else -- "ts"
        -- TS: Copy video and audio only (subtitles not supported for mov_text)
        ffmpeg_cmd = string.format(
            'ffmpeg -i "%s" -ss %f -to %f -c:v copy -c:a copy -map 0:v -map 0:a -f mpegts "%s" -y',
            input_file, adjusted_start, adjusted_end, output_file
        )
    end

    mp.osd_message("Dumping section from " .. adjusted_start .. " to " .. adjusted_end .. " as " .. container:upper())

    -- Run the command asynchronously
    local result = mp.command_native_async({
        name = "subprocess",
        args = {"sh", "-c", ffmpeg_cmd},
        capture_stdout = true,
        capture_stderr = true
    }, function(success, result, error)
        if success and result.status == 0 then
            mp.osd_message("Dump completed: " .. output_file)
        else
            local err_msg = result and result.stderr or error or "unknown error"
            mp.osd_message("Error dumping section: " .. err_msg)
            print("FFmpeg command: " .. ffmpeg_cmd)
            print("Error: " .. err_msg)
        end
    end)

    -- Reset for next use
    start_time = nil
    end_time = nil
end

-- Bind keys
mp.add_key_binding("Ctrl+s", "mark-start", mark_start)          -- 's' to mark start
mp.add_key_binding("Ctrl+e", "dump-section", mark_end_and_dump) -- 'e' to dump section
mp.add_key_binding("Ctrl+a", "cycle-container", cycle_container) -- 'c' to cycle container
