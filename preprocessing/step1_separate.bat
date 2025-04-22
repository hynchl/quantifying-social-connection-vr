@echo off
setlocal enabledelayedexpansion

set "input_folder=..\data\RawAudio"
set "output_folder=..\data\TempAudio"

:: Create the output folder if it doesn't exist
if not exist "%output_folder%" mkdir "%output_folder%"

:: For each .wav file in the input folder
for %%f in ("%input_folder%\*.wav") do (
    :: Extract the filename without extension
    set "filename=%%~nf"
    :: Use FFmpeg to split stereo channels into left and right
    ffmpeg -i "%%f" -filter_complex "[0:a]channelsplit=channel_layout=stereo[left][right]" -map "[left]" "%output_folder%\%%~nf_left.wav" -map "[right]" "%output_folder%\%%~nf_right.wav"
)

pause