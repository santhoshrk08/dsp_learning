# DSP Learning — Signal Processing Journey

ECE student at PSG College of Technology working through Digital Signal
Processing from fundamentals to research-grade projects, with the long-term
goal of MS/PhD admission in signal processing.

## What's here

- Week-by-week Jupyter notebooks implementing DSP concepts in Python
- Paper notes from IEEE Xplore reading
- **Month 1** — ECG denoising research project (IIR vs FIR), complete IEEE
  conference paper draft
- **Month 2** — Wavelet transforms and adaptive filtering (LMS/RLS) investigation
- **Month 3** — VHDL/FPGA hardware implementation of the Month 1 filter

## Month 1 — ECG Denoising (Butterworth IIR vs FIR Kaiser)

Complete, professor-reviewed IEEE conference paper comparing a 4th-order
Butterworth IIR filter and an 873-tap FIR Kaiser filter for ECG denoising,
validated with signal-quality metrics (SNR, NRMSE), Pan-Tompkins R-peak
detection, QRS morphology analysis, and statistical significance testing
across four MIT-BIH Arrhythmia Database records.

**Key finding:** Butterworth IIR achieved more consistent SNR improvement and
significantly better QRS duration preservation than FIR Kaiser, despite the
latter's theoretical linear-phase advantage — challenging the common
assumption of unconditional FIR superiority for ECG morphology preservation.
Both filters share a fundamental limitation: neither can remove synthetic
noise injected within the ECG's own diagnostic passband (5–15 Hz).

| Notebook | Topic |
|----------|-------|
| `ecg_denoising_project.ipynb` | Full Month 1 pipeline: filtering, metrics, Pan-Tompkins, multi-record validation, statistical testing |

Paper draft (Overleaf, IEEE format): title *"Comparative Evaluation of IIR
Butterworth and FIR Kaiser Filters for ECG Denoising: A Clinically-Validated
Approach"* — awaiting conference venue selection.

## Month 2 — Wavelets and Adaptive Filtering

Investigated whether alternative denoising strategies could resolve Month 1's
in-band noise limitation (noise that overlaps the ECG's own diagnostic
frequency band, undetectable by frequency-selective filtering).

| Notebook | Topic |
|----------|-------|
| `month2_wavelet_analysis.ipynb` | CWT scalograms, DWT thresholding, LMS and RLS adaptive filters from scratch |

**Key findings:**
- Wavelet (DWT) thresholding: no improvement over Month 1 methods on in-band
  noise (F1=83.33%, identical to Butterworth/FIR Kaiser)
- LMS adaptive filtering (realistic reference signal): F1=96.30% — matches
  Month 1's best clean-signal baseline, the first method to resolve the
  in-band noise limitation
- RLS: matches LMS on detection accuracy, ~4x slower computationally —
  mirrors Month 1's Butterworth-vs-FIR-Kaiser efficiency finding

## Month 3 — FPGA Hardware Implementation

Implemented the Month 1 FIR Kaiser filter (873 taps, Q1.15 fixed-point) in
VHDL, using a time-multiplexed single-multiplier architecture. Verified
functional correctness against the Python golden reference in Questa, then
synthesized and timing-closed on a real Cyclone V FPGA target.

**Key results:**
- 1000/1000 test samples verified against Python reference, max error 4 Q15
  units
- Synthesis: 1/156 DSP blocks used (<1%), 9% logic utilization
- Timing: meets 50MHz real-time target with positive slack (+2.036ns
  worst-case corner)

Full writeup: `paper_notes/month3_fpga_report.md`

Files: `fir_filter_873tap.vhd`, `fir_filter_tb.vhd`, `fir_coeffs.vhd`,
`fir_filter_873tap.sdc`

## Foundational Notebooks (pre-Month-1)

| Notebook | Topic | Week |
|----------|-------|------|
| `week1-signals-basics.ipynb` | Sine waves, sampling, aliasing | Week 1 |
| `week1-filtering-basics.ipynb` | Low-pass filter, SNR measurement | Week 1 |
| `signal-composition-demo.ipynb` | Complete signal analysis pipeline | Week 1 |
| `week2_day1_fft.ipynb` | FFT normalization, frequency resolution | Week 2 |

## Paper Notes

| File | Paper | Context |
|------|-------|---------|
| `paper_notes/week1_paper1.md` | ECG Baseline Denoising — Shi et al. 2021 | Foundational reading |
| `paper_notes/month3_fpga_report.md` | Month 3 FPGA implementation writeup | Month 3 |

## Tools

Python · NumPy · SciPy · Matplotlib · PyWavelets · wfdb · MIT-BIH PhysioNet
Dataset · VHDL · Questa · Quartus Prime (Cyclone V) · Overleaf/LaTeX (IEEEtran)
