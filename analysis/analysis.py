import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

import librosa
from scipy import interpolate
from scipy.signal import filtfilt, butter, hilbert
from scipy.signal import butter
from scipy import signal


def compute_gaps(turns):
    _gaps = []
    if len(turns) > 2:
        for i in range(1, len(turns)):
            end = max(turns['start'][i], turns['end'][i-1])
            start = min(turns['start'][i], turns['end'][i-1])
            _gaps.append(dict(start=start,  end=end, duration=end-start))
    else:
        _gaps.append(dict(start=np.nan,  end=np.nan, duration=np.nan))
    return pd.DataFrame(_gaps)

def interval2df(interval):
    return pd.DataFrame([[i.lower, i.upper, i.upper-i.lower] for i in interval], columns=['start', 'end', 'duration'])

def interval2barh(interval):
    return [[i.lower, i.upper-i.lower] for i in interval]

def get_interval_count(interval):
    df = pd.DataFrame([[i.lower, i.upper, i.upper-i.lower] for i in interval], columns=['start', 'end', 'duration'])
    return len(df)

# nod

def normalize_angle(angle):
    angle = angle % 360
    if angle >= 180: 
        angle -= 360
    return angle



def butter_highpass(cutoff, fs, order=5):
    nyq = 0.5 * fs
    normal_cutoff = cutoff / nyq
    b, a = signal.butter(order, normal_cutoff, btype='high', analog=False)
    return b, a

def butter_highpass_filter(data, cutoff, fs, order=5):
    b, a = butter_highpass(cutoff, fs, order=order)
    y = signal.filtfilt(b, a, data)
    return y

# voice

def load_words(filepath, is_self=True):
    words = pd.read_csv(filepath)
    # words['start'] *= 0.001 # msec -> sec
    # words['end'] *= 0.001 # msec -> sec
    words['speaker'] = 'self' if is_self else 'partner'
    return words

def preprocess_words(words):
    # compute durations
    words['duration'] = words['end'] - words['start']

    return words.dropna().reset_index(drop=True)

def compute_interval_length(interval):
    df = pd.DataFrame([[i.lower, i.upper, i.upper-i.lower] for i in interval], columns=['start', 'end', 'duration'])
    return df['duration'].sum()


# Function to merge time intervals
def merge_intervals(intervals):
    # List to store the result
    merged = []
    
    # Iterate over all intervals
    for current in intervals:
        # If merged list is empty or the last interval in merged list does not overlap with the current interval
        if not merged or merged[-1][1] < current[0]:
            # Add the current interval to the merged list
            merged.append(current)
        else:
            # If the current interval overlaps with the last interval in the merged list
            # Update the end time of the last interval to the maximum end time between the last and current interval
            merged[-1][1] = max(merged[-1][1], current[1])
    
    return merged



def extract_gaze2head(raw, draw_figure=False):

    adjacent = 0.5/np.tan(np.deg2rad(15))

    result = pd.DataFrame(dict(
        t = raw['t'].values,
        leftanglehead = np.rad2deg(np.arctan2(raw['EYE.LeftEye.Head.distance'], adjacent)),
        leftanglebody = np.rad2deg(np.arctan2(raw['EYE.LeftEye.Body.distance'], adjacent)),
        leftconfidence = raw['EYE.LeftEye.Head.confidence.x'].values,
        leftclosed = raw['FACE.EyesClosedL'].values,
        rightanglehead = np.rad2deg(np.arctan2(raw['EYE.RightEye.Head.distance'], adjacent)),
        rightanglebody = np.rad2deg(np.arctan2(raw['EYE.RightEye.Body.distance'], adjacent)),
        rightconfidence = raw['EYE.RightEye.Head.confidence.x'].values,
        rightclosed = raw['FACE.EyesClosedR'].values,
    ))

    result = result.dropna().reset_index(drop=True)

    if draw_figure:
        plt.subplot(2,1,1)
        plt.plot(result['t'], result['leftangle'])
        
        plt.subplot(2,1,2)
        plt.plot(result['t'], result['rightangle'])


    ## low-pass sampling
    sr = len(result)/(result['t'][len(result)-1] - result['t'][0])
    order = 2

    result['leftangle_head'] = butter_lowpass_filter(result['leftanglehead'], 15, sr, order)
    result['leftangle_body'] = butter_lowpass_filter(result['leftanglebody'], 15, sr, order)
    result['rightangle_head'] = butter_lowpass_filter(result['rightanglehead'], 15, sr, order)
    result['rightangle_body'] = butter_lowpass_filter(result['rightanglebody'], 15, sr, order)
    result['leftconfidence'] = butter_lowpass_filter(result['leftconfidence'], 15, sr, order)
    result['rightconfidence'] = butter_lowpass_filter(result['rightconfidence'], 15, sr, order)
    result['leftclosed'] = butter_lowpass_filter(result['leftclosed'], 15, sr, order)
    result['rightclosed'] = butter_lowpass_filter(result['rightclosed'], 15, sr, order)

    if draw_figure:
        plt.subplot(2,1,1)
        plt.plot(result['t'], result['leftangle'], ls='dashed')
        plt.xlim(100,120)
        
        plt.subplot(2,1,2)
        plt.plot(result['t'], result['rightangle'], ls='dashed')
        plt.xlim(100,120)
        
    
    ## blink filtering

    x = result['t'].copy()
    x[result['leftclosed']>0.9] = np.nan
    y = result['leftangle_head'].copy()
    y[result['leftclosed']>0.9] = np.nan
    x, y = x.dropna(), y.dropna()
    f = interpolate.interp1d(x, y, bounds_error=False, kind='cubic', fill_value="extrapolate")
    result['leftangle_head'] = f(result['t'])

    x = result['t'].copy()
    x[result['rightclosed']>0.9] = np.nan
    y = result['rightangle_head'].copy()
    y[result['rightclosed']>0.9] = np.nan
    x, y = x.dropna(), y.dropna()
    f = interpolate.interp1d(x, y, bounds_error=False, kind='cubic', fill_value="extrapolate")
    result['rightangle_head'] = f(result['t'])

    x = result['t'].copy()
    x[result['leftclosed']>0.9] = np.nan
    y = result['leftangle_body'].copy()
    y[result['leftclosed']>0.9] = np.nan
    x, y = x.dropna(), y.dropna()
    f = interpolate.interp1d(x, y, bounds_error=False, kind='cubic', fill_value="extrapolate")
    result['leftangle_body'] = f(result['t'])

    x = result['t'].copy()
    x[result['rightclosed']>0.9] = np.nan
    y = result['rightangle_body'].copy()
    y[result['rightclosed']>0.9] = np.nan
    x, y = x.dropna(), y.dropna()
    f = interpolate.interp1d(x, y, bounds_error=False, kind='cubic', fill_value="extrapolate")
    result['rightangle_body'] = f(result['t'])

    result['target'] = 0
    result.loc[result['rightangle']<0, 'target'] = 1

    return result


def find_eye_contacts(t_self, gaze2head_self, t_other, gaze2head_other):
    
    # finding start & end of gaze2head and make dataframe
    diff_gaze2head_self = np.diff(gaze2head_self, prepend=[0])
    ec_start = t_self[diff_gaze2head_self==1].reset_index(drop=True)
    ec_end = t_self[diff_gaze2head_self==-1].reset_index(drop=True)
    if len(ec_start) > len(ec_end):
        ec_start = ec_start[:-1]
    df_gaze2head_self = pd.DataFrame({'start': ec_start, 'end': ec_end})

    

    diff_gaze2head_other = np.diff(gaze2head_other, prepend=[0])
    ec_start = t_other[diff_gaze2head_other==1].reset_index(drop=True)
    ec_end = t_other[diff_gaze2head_other==-1].reset_index(drop=True)
    if len(ec_start) > len(ec_end):
        ec_start = ec_start[:-1]
    df_gaze2head_other = pd.DataFrame({'start': ec_start, 'end': ec_end})

    contacts = []
    for i in range(len(df_gaze2head_self)):
        start_self = df_gaze2head_self['start'][i]
        end_self = df_gaze2head_self['end'][i]

        for j in range(len(df_gaze2head_other)):
            start_other = df_gaze2head_other['start'][j]
            end_other = df_gaze2head_other['end'][j]
            prev_end_other = df_gaze2head_other['end'][j-1] if j != 0 else 0
            
            if (start_other<end_self) and (start_self < end_other):
                _contact = dict(waiter = 'self' if start_self < start_other else 'other',
                    finisher = 'self' if end_self < end_other else 'other',
                    start = max(start_self, start_other),
                    end = min(end_self, end_other),
                    duration = min(end_self, end_other) - max(start_self, start_other),
                    waitingtime = max(start_self, start_other)-max(min(start_self, start_other),prev_end_other))
                contacts.append(_contact)
    
    df = pd.DataFrame(contacts)
    df['interval'] = np.nan
    for i in range(len(df)-1):
        interval = df.loc[i+1, 'start'] - df.loc[i, 'end']
        df.loc[i, 'interval'] = interval

    return df


def extract_gazes_to_partner(t_self, gaze2head_self):
    # finding start & end of gaze2head and make dataframe
    diff_gaze2head_self = np.diff(gaze2head_self, prepend=[0])
    ec_start = t_self[diff_gaze2head_self==1].reset_index(drop=True)
    ec_end = t_self[diff_gaze2head_self==-1].reset_index(drop=True)
    if len(ec_start) > len(ec_end):
        ec_start = ec_start[:-1]
    
    df =  pd.DataFrame({'start': ec_start, 'end': ec_end, 'duration': ec_end-ec_start})
    df['interval'] = np.nan
    for i in range(len(df)-1):
        interval = df.loc[i+1, 'start'] - df.loc[i, 'end']
        df.loc[i, 'interval'] = interval

    return df

# 내 모든 end에 대해서 가장 가까운 eye contacts을 구하기

def compute_gaze_response (turn, eyecontacts):
    turn['eyecontact'] = np.nan

    for i in range(len(turn)):
        contact_start = eyecontacts['start'].copy()
        contact_start[contact_start<turn['start'][i]] = np.nan
        if np.isnan(contact_start).all():
            continue

        rt = contact_start - turn['start'][i]
        idx = np.nanargmin(np.abs(rt))
        turn.loc[i, 'eyecontact'] = rt[idx]
    
    turn['rt'] = turn[['interval', 'eyecontact']].min(axis=1)
    return turn


def compute_response_time(words_a, words_b):

    arr_turntaking = np.full(len(words_a), False)
    arr_interval = np.full(len(words_a), np.nan)
    arr_turn_start = np.full(len(words_a), np.nan)

    turn_start = words_a['start'][0]
    waiting_turn = False

    for i in range(len(words_a)):
        t_end = words_a['end'][i]
        t_start = words_a['start'][i]

        # find a next word from self side
        candidates = np.copy(words_a['start'].values)
        candidates[ candidates <= t_start ] = np.nan
        if not np.all(np.isnan(candidates)):  
            self_nearest = np.nanmin(np.abs(candidates-t_end))
            self_nearest_index = np.nanargmin(np.abs(candidates-t_end))
        else:
            self_nearest = np.nan
            self_nearest_index = np.nan

        # find a next word from other side
        candidates = np.copy(words_b['start'].values)
        candidates[ candidates <= t_start ] = np.nan
        if not np.all(np.isnan(candidates)):  
            other_nearest = np.nanmin(np.abs(candidates-t_end))
            other_nearest_index = np.nanargmin(np.abs(candidates-t_end))
        else:
            other_nearest = np.nan
            other_nearest_index = np.nan


        if waiting_turn:
            arr_turn_start[i] = words_a['start'][i]
            turn_start = words_a['start'][i]
        else:
            arr_turn_start[i] = turn_start
        

        if np.isnan(self_nearest) and np.isnan(other_nearest):
            # when there was no response after my remark (meaning it wasn’t a reaction)
            pass

        elif np.isnan(self_nearest):

            arr_turntaking[i] = True
            arr_interval[i] = words_b['start'][other_nearest_index] - t_end
            waiting_turn = True
            
        elif np.isnan(other_nearest):
            arr_turntaking[i] = False
            arr_interval[i] = words_a['start'][self_nearest_index] - t_end
            waiting_turn = False

        else:
            # when all remarks receive a response, the one with the quicker reply after the end of the statement is chosen.
            if (self_nearest < other_nearest) :
                arr_turntaking[i] = False
                arr_interval[i] = words_a['start'][self_nearest_index] - t_end
                waiting_turn = False
            else:
                arr_turntaking[i] = True
                arr_interval[i] = words_b['start'][other_nearest_index] - t_end
                waiting_turn = True

    words_a['turntaking'] = arr_turntaking
    words_a['interval'] = arr_interval
    words_a['turn_start'] = arr_turn_start

    return words_a[words_a['turntaking']==True].reset_index(drop=True)


def compute_response_time_with_contact(df_to, df_from, contacts):

    arr_turntaking = np.full(len(df_to), False)
    arr_interval = np.full(len(df_to), np.nan)

    for i in range(len(df_to)):
        t_end = df_to['end'][i]
        t_start = df_to['start'][i]

        candidates = np.copy(df_to['start'].values)
        candidates[ candidates <= t_start ] = np.nan
        if not np.all(np.isnan(candidates)):  
            self_nearest = np.nanmin(np.abs(candidates-t_end))
            self_nearest_index = np.nanargmin(np.abs(candidates-t_end))
        else:
            self_nearest = np.inf

        candidates = np.copy(df_from['start'].values)
        candidates[ candidates <= t_start ] = np.nan
        if not np.all(np.isnan(candidates)):  
            other_nearest = np.nanmin(np.abs(candidates-t_end))
            other_nearest_index = np.nanargmin(np.abs(candidates-t_end))
        else:
            other_nearest = np.inf

        candidates = np.copy(contacts['StartContact'].values)
        candidates[ candidates <= t_start ] = np.nan
        if not np.all(np.isnan(candidates)):  
            contact_nearest = np.nanmin(np.abs(candidates-t_end))
            contact_nearest_index = np.nanargmin(np.abs(candidates-t_end))
        else:
            contact_nearest = np.inf

        if (self_nearest < other_nearest) and (self_nearest < contact_nearest) :
            arr_turntaking[i] = False
            arr_interval[i] = df_to['start'][self_nearest_index] - t_end
        else:
            if (other_nearest < contact_nearest):
                arr_turntaking[i] = True
                arr_interval[i] = df_from['start'][other_nearest_index] - t_end
            else:
                arr_turntaking[i] = True
                arr_interval[i] = contacts['StartContact'][contact_nearest_index] - t_end

    df_to['turntaking'] = arr_turntaking
    df_to['interval'] = arr_interval

    return df_to[df_to['turntaking']==True].reset_index(drop=True)



def butter_lowpass_filter(data, cutoff, fs, order=2):
    normal_cutoff = cutoff / (0.5*fs)
    b, a = butter(order, normal_cutoff, btype='low', analog=False)
    y = filtfilt(b, a, data)
    return y


def extract_amplitude(t, data, sr, new_sr=2000):
    
    # compute envelope
    amp = np.abs(hilbert(data))

    # low-pass filter
    amp = butter_lowpass_filter(amp, int(new_sr*0.4), sr, 2)
        
    # resampling
    f = interpolate.interp1d(t, amp, kind="nearest", fill_value="extrapolate")
    t_resampled = np.arange(0, t[-1], 1/new_sr)
    amp_resampled = f(t_resampled)

    # to decibel
    amp_db = librosa.amplitude_to_db(amp_resampled, ref=np.max)

    return t_resampled, amp_db