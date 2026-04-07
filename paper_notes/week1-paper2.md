# Paper 2 — Week 1

**Title:** Removal of Baseline Wander from ECG Signal 
Based on a Statistical Weighted Moving Average Filter

**Authors:** Xiao Hu, Zhong Xiao, Ni Zhang

**Year:** 2011

**Journal:** Journal of Zhejiang University-Science C

**Link:** https://ieeexplore.ieee.org/document/11285722

## 5-Bullet Summary

1. **Problem:** ECG signals get corrupted by baseline wander 
   (BW) — a slow drift caused by patient breathing, movement, 
   and sweat changing electrode contact. Traditional fixes 
   (moving average filter and wavelet transform) remove the 
   drift but also distort the QRS complex and ST segment — 
   the exact features cardiologists need for diagnosis.

2. **Dataset used:** PhysioNet T-wave alternans challenge 
   database — 100 multichannel ECG records sampled at 500 Hz. 
   Records twa18 and twa34 were specifically used — one clean 
   reference and one severely contaminated by baseline wander.

3. **Method:** Statistical Weighted Moving Average (SMA). 
   A sliding window moves across the ECG. Inside each window, 
   sample values are grouped into sub-regions. The sub-regions 
   where most samples cluster (near the baseline, away from 
   QRS spikes) get weight=1. QRS spike samples get weight=0. 
   Only the weighted samples are averaged to estimate the 
   baseline — so the QRS complex is never distorted.

4. **Sampling frequency:** 500 Hz — satisfies Nyquist for 
   ECG (need ≥ 300 Hz for signals up to 150 Hz). Higher than 
   MIT-BIH's 360 Hz — gives better time resolution for 
   detecting fast QRS features.

5. **Performance metric:** NRMSE (Normalized Root Mean 
   Square Error) and ME (Maximum Error) — measured between 
   original clean ECG and filtered output. SMA achieved lower 
   NRMSE than both traditional moving average (MA) and wavelet 
   packet transform (WPT) at all tested window sizes.

## One thing I didn't understand

Wavelet Packet Transform (WPT) — the paper compares SMA 
against WPT but I don't yet understand how wavelet transforms 
decompose signals differently from FFT. 

## Why this matters to my project

This paper introduces NRMSE as a quality metric — which is 
more informative than SNR alone because it measures 
morphological distortion, not just noise power. In my
ECG project, I should add NRMSE alongside SNR to evaluate 
my Butterworth filter's performance more completely.

