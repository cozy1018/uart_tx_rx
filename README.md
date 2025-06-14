# UART TX / RX Module

A SystemVerilog implementation of UART (Universal Asynchronous Receiver Transmitter), including both the transmitter (TX) and receiver (RX) modules.

This design demonstrates bit-accurate serial communication using FSMs, clock division, and handshake logic.

---

## Features

- Configurable **Baud Rate** and **Clock Frequency**
- FSM-based control for both TX and RX
- 8-bit data transfer
- UART framing: 1 start bit, 8 data bits, 1 stop bit
- Ready-to-use **testbench**
- Fully synthesizable and testable
- Verified with **Icarus Verilog** and **GTKWave**

---

## Module Overview

### TX Module (`uart_tx.sv`)
- Sends 8-bit serial data with UART framing
- Starts transmission on `transmit` signal
- Outputs serial data on `tx` line
- Outputs `busy` signal while transmitting

### RX Module (`uart_rx.sv`)
- Receives serial data from `rx` line
- Detects start, reads 8 data bits, and stop
- Sets `data_ready` when a valid byte is received
- Outputs received byte on `data_out`

---

## Project Structure
```
src/       # SystemVerilog RTL source files
tb/        # Testbenches
sim/       # Simulation outputs (.vvp, .vcd, waveform)
```
---

## How to Simulate

```bash
# Compile with Icarus Verilog
iverilog -g2012 -o sim/uart_tb.vvp tb/uart_tx_tb.sv src/uart_tx.sv

# Run simulation
vvp sim/uart_tb.vvp

# View waveform
gtkwave sim/uart_tx_tb.vcd