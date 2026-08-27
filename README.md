# asynchronous-cdc
# Parameterized Asynchronous FIFO (CDC Design)

An asynchronous FIFO design implementing safe Clock Domain Crossing (CDC) using Dual-Port RAM, 2-Stage Flip-Flop Pointer Synchronizers, and Gray Code conversion to mitigate metastability.

## Key Features
•⁠  ⁠*Configurable Parameters:* Adjustable ⁠ DATA_WIDTH ⁠ and ⁠ ADDR_WIDTH ⁠ (Depth = $2^{\text{ADDR\_WIDTH}}$).
•⁠  ⁠*Metastability Mitigation:* 2-FF synchronizers for pointer transfer across independent write and read clock domains.
•⁠  ⁠*Race Condition Prevention:* Binary-to-Gray code conversion ensures only a single bit changes per address transition.
•⁠  ⁠*Verification:* Self-checking testbench driving distinct write ($100\text{ MHz}$) and read ($40\text{ MHz}$) clock domains.

## Architecture
•⁠  ⁠⁠ rtl/async_fifo.v ⁠ : Top-level RTL module with integrated dual-port RAM and CDC logic.
•⁠  ⁠⁠ tb/async_fifo_tb.v ⁠ : Dual-clock stimulus generator with boundary assertions (Full/Empty checks).

## Simulation Instructions
Using Icarus Verilog:
```bash
iverilog -o sim_fifo rtl/async_fifo.v tb/async_fifo_tb.v
vvp sim_fifo
gtkwave waveform.vcd
