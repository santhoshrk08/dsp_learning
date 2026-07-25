# Month 3 — FPGA Implementation of 873-Tap FIR Kaiser Filter

## Objective

Implement the Month 1 FIR Kaiser ECG denoising filter (873 taps, Q1.15 fixed-point)
in VHDL, verify functional correctness against the Python golden reference, and
confirm the design meets a 50MHz real-time timing target on a real FPGA device
(Cyclone V, 5CGXFC7C7F23C8).

## Design Decisions and Justification

**FIR over IIR for first hardware implementation.** IIR filters use feedback,
meaning quantization error can be recursively amplified through the feedback path,
potentially causing limit cycles (self-sustaining oscillation with zero input) —
a phenomenon that cannot occur in floating-point software. FIR has no feedback,
guaranteeing stability regardless of quantization. Given this was a first FPGA
project, the added complexity of formally verifying IIR stability post-quantization
was avoided in favor of the inherently stable FIR design.

**Time-multiplexed architecture over full-parallel.** A fully parallel 873-tap FIR
filter would require 873 physical hardware multipliers. Given the ECG sampling
rate (360Hz, one new sample every 2.78ms) and a target clock of 50MHz, a single
multiplier reused sequentially across all 873 taps requires only 873 of the
~139,000 available clock cycles per sample (<1% utilization) — a large safety
margin that made time-multiplexing the clear resource-efficient choice.

**Q1.15 fixed-point format.** Given ECG amplitudes (±1.3mV) and FIR Kaiser
coefficients (range -0.049 to 0.219) are both well within ±1.0 in magnitude,
a 16-bit signed format with 15 fractional bits (Q1.15) provides ample precision.
Verified empirically: center coefficients (largest magnitude, dominant filter
energy) showed max quantization error of 0.00000837 — negligible relative to
coefficient magnitude (~0.004% relative error). Edge coefficients (near-zero,
~0.00001-0.00002) lost more relative precision under quantization but contribute
negligibly to filter output.

**40-bit internal accumulator.** Multiplying two 16-bit signed numbers requires
32 bits to represent the exact product without loss. Accumulating 873 such
products in sequence requires additional headroom beyond 32 bits to avoid
overflow — 40 bits was chosen as a safe margin, following standard DSP hardware
practice of using an accumulator substantially wider than the input/output word
length.

## Architecture

Three-process VHDL design (standard Moore machine template):
1. **State register** (sequential, clocked) — 5-state FSM: IDLE, LOAD_SAMPLE,
   INIT_ACC, MAC_LOOP, OUTPUT
2. **Next-state logic** (combinational) — determines state transitions,
   default-assigned to prevent unintended latch inference
3. **Datapath** (sequential, clocked) — sample buffer shifting (873x16-bit
   shift register), MAC operation (multiply-accumulate with resize to 40-bit),
   output rescaling (Q2.30 accumulator result → Q1.15 output via bits [30:15])

Coefficients converted from the real Month 1 Python FIR Kaiser design
(873 taps, ripple_db=60, width=1.5Hz) to Q1.15 fixed-point via a Python script,
generating a VHDL constant array (`fir_coeffs.vhd`) for direct inclusion in the
coefficient ROM.

## Verification Methodology

A Questa testbench was built to feed real ECG data (Record 100, Month 1 noisy
signal) through the VHDL design and compare output against a Python "golden
reference" — using `scipy.signal.lfilter` (single forward-pass) rather than
`filtfilt` (zero-phase, used in the Month 1 paper), since the hardware
implements real-time, single-pass filtering and cannot use future samples the
way `filtfilt` does.

**Debugging process (documented for reproducibility):**

1. **Off-by-one boundary bug**: `tap_index` incrementing past its declared
   range (0 to 872) caused a fatal simulation error at the final tap. Fixed by
   guarding the increment (`if tap_index < 872 then ...`).

2. **Sample misalignment**: initial comparisons showed large, systematic
   errors where hardware output closely resembled the *previous* iteration's
   expected value. Rather than guess-and-check, exported both hardware output
   and Python reference to files and used Python cross-correlation
   (`np.mean(np.abs(...))` swept across candidate shifts) to mathematically
   determine the exact misalignment: hardware output lags the naive
   sample-index pairing by exactly one sample, attributable to the
   `LOAD_SAMPLE` and `INIT_ACC` FSM stages each consuming one clock cycle
   before MAC computation begins — a pipeline latency on top of the filter's
   inherent 436-sample group delay. Corrected the testbench comparison logic
   accordingly.

**Final verification result:** 1000/1000 test samples compared, 0 errors
(tolerance ±5 Q15 units), maximum observed difference 4 Q15 units — consistent
with expected fixed-point quantization noise.

## Synthesis and Timing Results (Quartus Prime, Cyclone V)

| Metric | Result |
|---|---|
| Logic utilization | 5,343 / 56,480 ALMs (9%) |
| DSP blocks | 1 / 156 (<1%) |
| Total registers | 16,961 |
| Block memory | 0 bits (sample buffer implemented as registers, not BRAM) |

**Timing closure:** initial Timing Analyzer runs reported large failing setup
slack (-15.4ns) with a "design not fully constrained" warning — traced to a
missing SDC (Synopsys Design Constraints) file; the 50MHz target had only ever
existed as an informal design assumption, never formally declared to the tool.
Created `fir_filter_873tap.sdc` (`create_clock -name clk -period 20.0
[get_ports clk]`) and re-ran full compilation (constraint files must be present
before Fitter placement, not just before final timing analysis).

**Final setup timing slack:**
- Worst-case corner (Slow 1100mV, 85°C): **+2.036 ns** — meets 50MHz target
- Best-case corner (Fast 1100mV, 85°C): +11.742 ns

## Key Findings

1. Time-multiplexed architecture successfully reduced hardware multiplier
   usage from a theoretical 873 (full-parallel) to 1 physical DSP block,
   confirmed via synthesis report.
2. Q1.15 fixed-point precision is sufficient for this filter design — dominant
   (center) coefficients retain high relative precision; only negligible
   edge coefficients lose meaningful precision.
3. The design meets real-time 50MHz timing requirements with positive margin
   under worst-case silicon/temperature conditions, closing the loop on the
   central question posed at the start of this investigation: whether a
   single time-multiplexed MAC unit can complete 873 sequential operations
   within the available real-time budget. Confirmed: yes, with room to spare.
4. Debugging this design required combining VHDL/hardware reasoning (FSM
   timing, pipeline stages) with software verification (Python
   cross-correlation for empirical timing-offset diagnosis) — a genuinely
   interdisciplinary debugging process worth noting as a transferable skill.

## Files

- `fir_filter_873tap.vhd` — filter entity and architecture
- `fir_filter_tb.vhd` — Questa testbench
- `fir_coeffs.vhd` — generated Q1.15 coefficient ROM (873 entries)
- `fir_filter_873tap.sdc` — timing constraint file
- `test_input_q15.txt`, `expected_output_q15.txt`, `actual_output_q15.txt` —
  verification data
