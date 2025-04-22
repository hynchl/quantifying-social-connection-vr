@echo off
setlocal enabledelayedexpansion

set "input_folder=..\data\TempAudio"
set "output_folder=..\data\StereoAudio"

:: Create the output folder if it doesn't exist
if not exist "%output_folder%" mkdir "%output_folder%"

:: Loop over 1a to 30b
for /L %%n in (1,1,30) do (
    for %%c in (a b) do (
        :: Create code (e.g., 1a, 1b, ..., 30a, 30b)
        set "code=%%n%%c"

        :: Define input file paths
        set "left_file=%input_folder%\%%n%%c_left_normalized.wav"
        set "right_file=%input_folder%\%%n%%c_right_normalized.wav"

        echo Processing !code!
        echo Left:  !left_file!
        echo Right: !right_file!

        :: Check if both files exist
        if exist "!left_file!" if exist "!right_file!" (
            :: Merge left and right into stereo
            ffmpeg -i "!left_file!" -i "!right_file!" -filter_complex "[0:a][1:a]amerge=inputs=2[aout];[aout]pan=stereo|c0<c0|c1<c1[out]" -map "[out]" "%output_folder%\%%n%%c_stereo.wav"
        )
    )
)

pause
