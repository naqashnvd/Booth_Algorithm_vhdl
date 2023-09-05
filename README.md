# VHDL Booth's Multiplication Module

This repository contains the VHDL source code for a Booth's Multiplication module. Booth's Multiplication is a hardware-based algorithm used for efficient binary multiplication.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Usage](#usage)
  - [Instantiation](#instantiation)
  - [Configuration](#configuration)
- [Algorithm Overview](#algorithm-overview)
- [Contributing](#contributing)

## Introduction

Booth's Multiplication is a multiplication algorithm commonly used in digital systems for efficient binary multiplication. This VHDL module provides a hardware implementation of Booth's Multiplication algorithm, allowing you to perform binary multiplication with reduced hardware complexity.

## Features

- **Configurable Data Width**: The module supports a configurable data width (`bW`) to accommodate different data requirements in your projects.

- **Clock Synchronization**: The module operates with a clock signal (`CLK`), ensuring synchronized multiplication in your digital system.

- **Control Signals**: Control signals like `nRST` (reset), `LOAD` (load input values), `START` (initiate multiplication), and `DONE` (result ready) provide control over the operation of the module.

## Usage

### Instantiation

To use the Booth's Multiplication module in your VHDL project, follow these steps:

1. Instantiate the `booth_multiplication` entity in your VHDL design.

```vhdl
-- Instantiate the Booth's Multiplication module
booth_mult_inst : entity work.booth_multiplication
  generic map (
    bW => 4  -- Configure the data width as needed
  )
  port map (
    m => your_multiplier_signal,  -- Connect to the multiplier input
    r => your_multiplicand_signal,  -- Connect to the multiplicand input
    product => your_product_signal,  -- Connect to the product output
    CLK => your_clock_signal,  -- Connect to your clock signal
    nRST => your_reset_signal,  -- Connect to your reset signal
    LOAD => your_load_signal,  -- Connect to load input values
    START => your_start_signal,  -- Connect to start multiplication
    DONE => your_done_signal  -- Check for multiplication completion
  );
```
### Configuration
You can configure the Booth's Multiplication module by setting the `bW` generic parameter according to your data width requirements. Connect the module to your clock and control signals, as well as your input (m and r) and output (product) signals.

## Algorithm Overview
Booth's Multiplication is an algorithm that reduces the number of partial products generated during binary multiplication by detecting groups of consecutive 1s and 0s in the multiplier. The algorithm shifts the multiplicand and adds or subtracts it from the product register based on the multiplier bits. This approach results in a more efficient multiplication process with fewer hardware resources.

For detailed information on how the Booth's Multiplication algorithm works, you can refer to the provided VHDL code and associated documentation.

## Contributing
Contributions to this project are welcome. If you have suggestions, improvements, or bug fixes, please feel free to submit a pull request or open an issue in this repository.
