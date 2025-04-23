# Preprocessing  

This procedure generates 50 Hz voice activity probability data used for extracting turn-taking patterns. To this end, download raw data at [here](https://www.dropbox.com/scl/fo/mbyu1fbh136sibbrdru8e/AIlflQd9JwqrqBPu90ZGFwE?rlkey=ebba3njgsz8l08w6mp3yn4mhx&st=6uhd5bqo&dl=0). Then, uncompress and save it in `../data`.

You can skip the below preprocessing step by using our preprocessed dataset, [VADResult](https://www.dropbox.com/scl/fo/xfv76gujl0910acnh2ifd/AEcd0_LTu0B2pp3dPlSUfug?rlkey=m96cxf2qq56gq1ab9ms6ir535&st=kh8xc92d&dl=0). To use this processed results, download the archive from the link, uncompress it into the `../data` directory, and then move on to the analysis in `../analysis`.

> ⚠️ The following preprocessing steps were tested in a **Windows environment**.  
> Additionally, the [VoiceActivityProjection](https://github.com/ErikEkstedt/VoiceActivityProjection) tool requires an **NVIDIA GPU** and the **CUDA Toolkit** for proper operation.


### 1. Extract Audio from Video  

1. **Extract audio from video**
   - `step0_video_to_wav.bat`  
   - `step1_separate.bat`

2. **Normalize the volume of the extracted audio**

You can install ffmpeg-normalize in a Python environment.

```
pip install ffmpeg-normalize
```

Then, run `step2_normalize.bat`. *This step is critical for accurate voice activity detection!*

3. **Merge the two audio tracks into one file**
   - `step3_merged.bat`

### 2. Voice Activity Projection  
1. **Clone** [VoiceActivityProjection](https://github.com/ErikEkstedt/VoiceActivityProjection) into this folder:

    ```bash
    git clone https://github.com/ErikEkstedt/VoiceActivityProjection.git
    cd VoiceActivityProjection
    git checkout f39a78b
    ```

2. **Install dependencies** as described in the `Installation` section of the repository.

3. **Run** `step4_process.bat` to perform voice activity projection on the merged audio file.

4. **Output**: `.json` files will be saved in `../data/VadResult`, containing 50 Hz voice activity probabilities.

