# MPV Lua Scripts
<br>
<b>auto-sort-mpv-internal-sorting.lua</b><br>
Original work:  https://github.com/mpv-player/mpv/blob/master/TOOLS/lua/autoload.lua<br>
<br>
This is a modified verson of 'autoload.lua'.  mpv by default sorts the playlist by name (A-Z), this Lua script sorts by default by date-desc (newest to oldest) but can be changed to sort by name (A-Z) or date (oldest to newest).  It addresses the playlist refresh issue in the original 'autoload.lua' where dragging and dropping files or folder into a running mpv player causes the sorting to revert back to name (A-Z).<br><br>
Behavior:<br>
<ol>
  <li>Passing a single file to mpv = No playlist, no sorting</li>
  <li>Passing multiple files to mpv = Playlist is sorted</li>
  <li>Passing a folder to mpv = mpv builtin will scan the folder and subfolders by default and sort by name (A-Z) then pass the sorting to this Lua script.  On initial launch of mpv you will see the playlist briefly shuffle as the sorting is being settled.</li>
</ol>
<hr>
<b>audio-normalize.lua</b><br>
Provides audio normalization using a dynamic range compressor filter.<br><br>
The script uses these compressor settings:<br>
<ul>
  <li>Quick attack time (0.3s) and moderate decay (0.8s)</li>
</ul>
<ul>
  <li>Compression curve points:</li>
    <ul>
    <li>-70dB stays at -70dB (preserves quiet sounds)</li>
    <li>-24dB becomes -20dB</li>
    <li>0dB becomes -5dB</li>
    <li>-20dB stays at 0dB</li>
    </ul>
</ul>
<ul>
  <li>This creates a gentle compression that normalizes volume while maintaining dynamics</li>
</ul>

When you press Ctrl+` in MPV:<br>
<ul>
  <li>First press: Enables normalization and shows "Audio Normalization: ON"</li>
  <li>Second press: Disables normalization and shows "Audio Normalization: OFF"</li>
</ul>

The filter provides a reasonable balance between normalization and audio quality, but you can adjust the <mark>normalizer_filter</mark> parameters to taste:<br>
<ul>
  <li><mark>attacks</mark> and <mark>decays</mark>: Response times in seconds</li>
  <li><mark>points</mark>: Input/output dB pairs defining the compression curve</li>
</ul>
<hr>
<b>dump-section.lua</b><br>
Requires:  ffmpeg<br>
<b>Only works on local files!</b><br>
While watching a video, you can cut a section (also known as stream copy) from a video by marking it from start to end and have that section saved as a MP4 container (by default) with the option to change the container to TS on the fly.  MP4 is preferred because it can also capture subtitles.<br><br>
Stream copying relies on keyframes, keyframes are points in the video where a full frame is stored, and they occur at intervals (e.g., every 2-10 seconds, depending on the video’s encoding settings) so the start/end points might snap to the nearest keyframe, potentially causing slight inaccuracies (e.g., a few frames off). If precision is critical, transcoding might still be needed, or you could use FFmpeg with -noaccurate_seek<br><br>
This script requires no additional transcoding/re-encoding so its lightweight for lower powered machines (eg. Intel Celeron, Raspberry Pi).<br>
<hr>
<b>extend-OSD-playlist.lua</b><br>
The OSD playlist display [F8] is set by 'osd-duration' (one second by default) in mpv.conf.  This script extends the OSD playlist display to 10 seconds and can be position onto the upper-left, lower-left, upper-right, and lower-right.<br><br>
Behavior:<br>
<ol>
  <li>Press F8 when playlist is hidden: Shows playlist with 10-second timeout</li>
  <li>Press F8 while playlist is visible (within 10 seconds): Hides playlist immediately</li>
  <li>If you don't press F8 again, playlist auto-hides after 10 seconds</li>
  <li>Subsequent F8 presses continue to toggle the playlist on/off</li>
</ol>  
<hr>
<b>dir-list.lua</b><br>
This list all the files of the directory that the current file that mpv is playing resides in.<br>
<hr>
<b>osd-test.lua</b><br>
This creates a 'Test Message' on the upper-left, lower-left, upper-right, and lower-right.  Useful for figuring out how OSD uses font color and positioning.

