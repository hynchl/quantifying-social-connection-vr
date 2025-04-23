# Analysis

## Installation

To set up the analysis environment, run the following commands:

```bash
cd analysis
conda create -n socialconnection python=3.10
conda activate socialconnection
pip install -r requirements.txt
```

## 1. Turn-Taking and Verbal Behaviors  
These notebooks are used to extract utterance-level intervals and compute voice-related features:

- `00-extracting_utterance_interval.ipynb`
- `01-analysis_voice.ipynb`

## 2. Non-Verbal Behaviors
These notebooks analyze gaze direction and head movement:
- `02-analysis_gaze.ipynb`
- `02-analysis_head.ipynb`

Before you start working on `02-analysis_head.ipynb`, make sure to install the Persistence1D component. You can download the source code from here: https://github.com/weinkauf/Persistence1D. After that, rename the python folder to p1d and save it. The original repo doesn’t mention a license, so this is just a precaution. Sorry for the hassle!

## 3. Merging Data for Group-Level Analysis
Combines participant-level features and subjective ratings for across-participant analysis:

- `03-analysis_subjective_rating.ipynb`

## 4. Statistical analysis
Conducts group-level inference using R scripts:

- `04-*.R`

Note that the fitting results can be varied on your environments slightly.


