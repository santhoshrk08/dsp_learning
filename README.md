# DSP Learning — Signal Processing Journey

ECE student at PSG College of Technology working through Digital Signal
Processing from fundamentals to research-grade projects, with the long-term
goal of MS/PhD admission in signal processing.

**Status:** Two complete IEEE-format paper drafts (Month 1 and Month 2-4),
both awaiting professor review before conference submission. Upcoming
semesters (Signals and Systems, Control Systems) will deepen the
theoretical foundation before final submission push.

---

## Project Overview

**Core project — ECG Signal Denoising.** Started as a filter comparison
study (Butterworth IIR vs. FIR Kaiser), grew into a full clinical-validation
pipeline, then extended into adaptive filtering (LMS/RLS), wavelet analysis,
a hybrid filter architecture, and a real FPGA hardware implementation —
now spanning two complete paper-length bodies of work.

---

## Paper 1 (Month 1) — ECG Denoising: IIR vs FIR

Comparative study of Butterworth IIR and FIR Kaiser Window filters for ECG
denoising on the MIT-BIH Arrhythmia Database, extended with clinical
validation (Pan-Tompkins R-peak detection, QRS duration, paired t-test)
beyond standard signal-domain metrics.

**Key finding:** Butterworth IIR outperforms FIR Kaiser on QRS morphology
preservation and cross-record consistency despite FIR's linear-phase
advantage. Both filters share a fundamental limitation: neither can remove
noise falling inside the ECG's own diagnostic band (0.5–40Hz).

**Status:** Complete IEEE paper draft (Overleaf, IEEEtran, 5 pages).
Professor-reviewed and approved; awaiting conference venue selection.

| Notebook | Topic |
|---|---|
| `ecg_denoising_project.ipynb` | Full Month 1 pipeline |

---

## Paper 2 (Month 2–4) — Adaptive and Hybrid Filtering for In-Band Noise

Directly extends Paper 1's limitation. Systematically tests whether
wavelet thresholding, LMS, RLS, and a hybrid IIR+LMS cascade can resolve
the in-band noise problem that defeats both static filters from Paper 1.

**Key findings:**
- Wavelet DWT thresholding fails identically to static filters (F1=83.33%)
  — noise-character-dependent, not noise-frequency-dependent
- **LMS adaptive filtering resolves it** (F1=96.30%), generalizing across
  4 diverse cardiac conditions (96.04% ± 0.40%) and the entire 6–14Hz
  vulnerable frequency band, with no per-condition parameter re-tuning
  required
- **Hybrid Butterworth+LMS cascade** improves SNR by a statistically
  validated 4.9× over LMS alone (paired t-test, n=30, t(29)=69.23,
  p<0.001) at only 14% additional computational cost

**Status:** Complete IEEE paper draft (Overleaf, IEEEtran). Literature
review grounded against Thakor & Zhu (1991), Makdessy et al. (2020), and
Khiter et al. (2020). Not yet reviewed by professor.

| Notebook | Topic |
|---|---|
| `month2_wavelet_analysis.ipynb` | CWT scalograms, DWT denoising, LMS/RLS, in-band noise resolution |
| Month 4 extensions (multi-record, frequency sweep, hybrid, robustness) | Generalization and statistical validation |

---

## Month 3 — FPGA Hardware Implementation

Implements the Paper 1 FIR Kaiser filter (873 taps) in VHDL on a real
Cyclone V FPGA, verified against the Python software implementation.

**Key result:** 1000/1000 samples verified against Python reference (max
error 4 Q15 units). Time-multiplexed architecture uses 1 DSP block (of
156 available), 9% logic utilization. Meets 50MHz real-time timing target
with +2.036ns positive slack under worst-case silicon conditions.

Full writeup: [`paper_notes/month3_fpga_report.md`](paper_notes/month3_fpga_report.md)

| File | Purpose |
|---|---|
| `fir_filter_873tap.vhd` | Filter entity + 3-process architecture (FSM + datapath) |
| `fir_filter_tb.vhd` | Questa testbench with file-based verification |
| `fir_coeffs.vhd` | Q1.15 coefficient ROM (873 entries) |
| `fir_filter_873tap.sdc` | Timing constraint (50MHz clock) |

---

## Foundational Notebooks (Pre-Paper-1)

| Notebook | Topic |
|---|---|
| `week1-signals-basics.ipynb` | Sine waves, sampling, aliasing |
| `week1-filtering-basics.ipynb` | Low-pass filter, SNR measurement |
| `signal-composition-demo.ipynb` | Complete signal analysis pipeline |
| `week2_day1_fft.ipynb` | FFT fundamentals |

---

## Paper Notes / Literature Review

| File | Paper |
|---|---|
| `paper_notes/week1_paper1.md` | ECG Baseline Denoising — Shi et al. 2021 |
| `paper_notes/month3_fpga_report.md` | Month 3 FPGA implementation full report |
| Das & Chakraborty (2017), Gond et al. (2024) | Paper 1 literature grounding |
| Thakor & Zhu (1991), Makdessy et al. (2020), Khiter et al. (2020) | Paper 2 literature grounding |

---

## Tools

Python · NumPy · SciPy · Matplotlib · PyWavelets · MIT-BIH PhysioNet Dataset ·
VHDL · Questa · Quartus Prime (Cyclone V) · Overleaf/LaTeX (IEEEtran)
