@echo off
setlocal enabledelayedexpansion

set "input_folder=..\data\RawData"
set "output_folder=..\data\RawAudio"

if not exist "%output_folder%" mkdir "%output_folder%"

for %%f in ("%input_folder%\*.mkv") do (

    set "input_file=%%f"
    set "output_file=%output_folder%\%%~nf.wav"

    echo Processing "!input_file!"...

    ffmpeg -i "!input_file!" -filter_complex "[0:a:1]channelsplit=channel_layout=stereo:channels=FL[left]; [0:a:2]channelsplit=channel_layout=stereo:channels=FR[right]; [left][right]join=inputs=2:channel_layout=stereo[out]" -map "[out]" "!output_file!"

    echo Done processing "!input_file!"
)

echo All files processed!
endlocal
