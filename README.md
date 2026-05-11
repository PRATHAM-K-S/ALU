# Parameterized ALU  RTL Design & Verification

> A configurable Arithmetic Logic Unit implemented in Verilog, supporting 13 arithmetic and 14 logical operations across a parameterized operand width, with a self-checking testbench and coverage analysis.

---

## Table of Contents

- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Design Parameters](#design-parameters)
- [Supported Operations](#supported-operations)
- [Getting Started](#getting-started)
- [Running Simulation](#running-simulation)
- [Coverage Collection](#coverage-collection)
- [Verification Plan](#verification-plan)
- [Results Summary](#results-summary)
- [Author](#author)

---

## Overview

This project implements and verifies a **parameterized ALU** in synthesizable Verilog. The ALU is controlled by a `MODE` signal that selects between arithmetic and logical operation sets, with all outputs registered behind a two-stage pipeline (1-cycle latency for standard ops, 3-cycle for multiply ops).

The verification environment consists of:
- **DUT**  `alu_design.v` (the design under test)
- **Reference Model**  `alu_ref.v` (combinational golden model)
- **Testbench**  `alu_tb.v` (directed tests with driver, monitor, scoreboard)

---

## Repository Structure

```
ALU/
+-- src/
¦   +-- alu_design.v          # DUT  parameterized ALU (synthesizable RTL)
¦   +-- alu.v                 # Alternate ALU implementation
¦   +-- test_bench/
¦       +-- alu_tb.v          # Testbench (driver + monitor + scoreboard)
¦       +-- alu_ref.v         # Combinational reference model
+-- docs/
¦   +-- ALU_Project_Report.md # Full project report
¦   +-- ALU_verification_plan.xlsx  # Verification plan with test status
+-- README.md
```

---

## Design Parameters

| Parameter | Default | Description |
|---|---|---|
| `IN_SIZE` | 8 | Width of input operands OPA and OPB (bits) |
| `CMD_SIZE` | 4 | Width of the command bus (bits) |
| `OUT_SIZE` | 2×IN_SIZE | Width of result output RES (auto-derived) |

> The testbench instantiates the DUT with `IN_SIZE=4` to match the 4-bit reference model.

### Port List

| Port | Dir | Width | Description |
|---|---|---|---|
| `CLK` | in | 1 | Rising-edge clock |
| `RST` | in | 1 | Asynchronous active-high reset |
| `CE` | in | 1 | Clock enable  holds outputs when low |
| `MODE` | in | 1 | `1` = Arithmetic, `0` = Logical |
| `CIN` | in | 1 | Carry-in for ADD_CIN / SUB_CIN |
| `INP_VALID` | in | 2 | `[0]`=OPA valid, `[1]`=OPB valid |
| `OPA` | in | IN_SIZE | Operand A |
| `OPB` | in | IN_SIZE | Operand B |
| `CMD` | in | CMD_SIZE | Operation select |
| `RES` | out | OUT_SIZE | Result |
| `COUT` | out | 1 | Carry-out (unsigned add) |
| `OFLOW` | out | 1 | Overflow (signed ops) |
| `G` / `L` / `E` | out | 1 | Greater / Less / Equal (CMP) |
| `ERR` | out | 1 | Error  invalid CMD or INP_VALID |

---

## Supported Operations

### Arithmetic Mode (`MODE = 1`)

| CMD | Operation | Expression |
|---|---|---|
| `0` | ADD | `OPA + OPB` |
| `1` | SUB | `OPA - OPB` |
| `2` | ADD_CIN | `OPA + OPB + CIN` |
| `3` | SUB_CIN | `OPA - OPB - CIN` |
| `4` | INC_A | `OPA + 1` |
| `5` | DEC_A | `OPA - 1` |
| `6` | INC_B | `OPB + 1` |
| `7` | DEC_B | `OPB - 1` |
| `8` | CMP | Sets `G`, `L`, or `E` |
| `9` | INCR_A_MUL_B | `(OPA+1) × (OPB+1)`  3 cycles |
| `10` | LSHIFT_A_MUL_B | `(OPA<<1) × OPB`  3 cycles |
| `11` | SIGNED_ADD | `$signed(OPA) + $signed(OPB)` |
| `12` | SIGNED_SUB | `$signed(OPA) - $signed(OPB)` |

### Logical Mode (`MODE = 0`)

| CMD | Operation | Expression |
|---|---|---|
| `0` | AND | `OPA & OPB` |
| `1` | NAND | `~(OPA & OPB)` |
| `2` | OR | `OPA \| OPB` |
| `3` | NOR | `~(OPA \| OPB)` |
| `4` | XOR | `OPA ^ OPB` |
| `5` | XNOR | `~(OPA ^ OPB)` |
| `6` | NOT_A | `~OPA` |
| `7` | NOT_B | `~OPB` |
| `8` | SHR_A | `OPA >> 1` |
| `9` | SHL_A | `OPA << 1` |
| `10` | SHR_B | `OPB >> 1` |
| `11` | SHL_B | `OPB << 1` |
| `12` | ROL_A_B | Rotate `OPA` left by `OPB[clog2(N)-1:0]` |
| `13` | ROR_A_B | Rotate `OPA` right by `OPB[clog2(N)-1:0]` |

---

## Getting Started

### Prerequisites

- Synopsys VCS **or** Questa SIM (ModelSim)
- URG (Unified Report Generator)  for coverage reports
- Any Verilog-2001 compatible simulator

### Clone

```bash
git clone <repo-url>
cd ALU
```

---

## Running Simulation

### Synopsys VCS

```bash
# Compile
vcs -sverilog -full64 \
    src/alu_design.v \
    src/test_bench/alu_ref.v \
    src/test_bench/alu_tb.v \
    -o simv -cm line+tgl

# Run
./simv -cm line+tgl -cm_dir simv.vdb
```

### Questa SIM / ModelSim

```bash
# Compile
vlog src/alu_design.v src/test_bench/alu_ref.v src/test_bench/alu_tb.v

# Simulate
vsim -c alu_tb -do "run -all; quit"
```

### Expected Output

The simulation log prints pass/fail for each test case:

```
async_reset_assert_deassert: Pass
ce_enable_operation: Pass
add_valid: Pass
...
incr_a_mul_b_valid: Pass
rotate_right_a_b: Pass
```

---

## Coverage Collection

```bash
# Generate HTML coverage report with URG
urg -dir simv.vdb -report alu_coverage_report

# Open in browser
open alu_coverage_report/dashboard.html
```

### Coverage Results

| Metric | Score |
|---|---|
| Overall Score | **94.66%** |
| Line Coverage | **98.74%** |
| Toggle Coverage | **90.57%** |

| Module | Score | Line | Toggle |
|---|---|---|---|
| `alu_tb` | 97.34% | 100.00% | 94.68% |
| `ALU` (DUT) | 88.19% | 96.15% | 80.23% |
| `alu_ref` | 99.22% | 100.00% | 98.44% |

---

## Verification Plan

The full verification plan is in `docs/ALU_verification_plan.xlsx`. Summary of the 81 test cases:

| Suite | Total | Pass | Pending |
|---|---|---|---|
| Sanity Checks | 7 | 7 | 0 |
| Arithmetic Mode (MODE=1) | 44 | 39 | 5 |
| Logical Mode (MODE=0) | 30 | 30 | 0 |
| **Total** | **81** | **76** | **5** |

The 5 pending tests cover mid-operation changes (CMD, MODE, operands) during the 3-cycle multiply operations (CMD 9 and CMD 10) and are planned for a future testbench revision.

---

## Results Summary

- ? All 7 sanity checks passed
- ? All 30 logical mode tests passed
- ? 39 / 44 arithmetic mode tests passed
- ? 5 tests pending (mid-operation 3-cycle scenarios)
- ?? 94.66% overall coverage achieved

---

## Author

**Pratham** | Batch 11  
Synopsys Frontend Verification Program  
Date: May 11, 2026
