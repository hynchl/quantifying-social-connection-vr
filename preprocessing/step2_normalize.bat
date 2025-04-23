@echo off
setlocal enabledelayedexpansion

set "input_folder=..\data\TempAudio"
set "output_folder=..\data\TempAudio"

:: Normalize all .wav files in the input folder
for %%f in ("%input_folder%\*.wav") do (
    :: Extract filename without extension
    set "filename=%%~nf"
    :: Run ffmpeg-normalize and save to the same folder with _normalized suffix
    ffmpeg-normalize "%%f" -o "%output_folder%\%%~nf_normalized.wav"
)

pause
