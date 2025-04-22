@echo off
setlocal enabledelayedexpansion

REM Set input and output folder paths
set input_folder=..\data\StereoAudio
set output_folder=..\data\VadResult

REM Check if input folder exists; if not, exit
if not exist "%input_folder%" (
    echo Input folder "%input_folder%" does not exist.
    exit /b 1
)

REM Create output folder if it does not exist
if not exist "%output_folder%" (
    mkdir "%output_folder%"
)

REM Loop through all .wav files in the input folder
for %%f in ("%input_folder%\*.wav") do (
    REM Extract filename without extension
    set "filename=%%~nf"
    
    REM Run the Python script
    echo Processing "%%f"...
    python VoiceActivityProjection/run.py --audio "%%f" -sd example/VAP_3mmz3t0u_50Hz_ad20s_134-epoch9-val_2.56.pt --filename "%output_folder%\!filename!.json"
    
    echo Finished processing "%%f".
)

pause
