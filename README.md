APB to SPI Master Controller IP Core
Overview

This project implements a custom APB (Advanced Peripheral Bus) to SPI (Serial Peripheral Interface) Master Controller IP Core in Verilog HDL. The design enables a processor or APB master to communicate with SPI-compatible peripherals through a configurable SPI master interface.

The IP core provides configurable SPI clock generation, programmable baud rate selection, support for multiple SPI modes, automatic slave select control, interrupt generation, and APB-compliant register access.

Features
APB Interface
APB3 compatible slave interface
Read and write access to SPI configuration registers
Status monitoring through APB registers
APB ready and error signaling
SPI Master Features
Master mode operation
Configurable baud rate generation
Support for SPI Mode 0, Mode 1, Mode 2, and Mode 3
Configurable CPOL (Clock Polarity)
Configurable CPHA (Clock Phase)
MSB-first and LSB-first transmission
Automatic Slave Select (SS) generation
Full-duplex SPI communication
Interrupt Support
SPI transfer complete interrupt
Transmit buffer empty interrupt
Mode fault interrupt
Data Width
8-bit transmit and receive data path
Architecture
                    +----------------+
                    |   APB Master   |
                    +--------+-------+
                             |
                             v
                    +----------------+
                    |   APB Slave    |
                    +--------+-------+
                             |
         +-------------------+-------------------+
         |                                       |
         v                                       v
+-------------------+               +-------------------+
| Baud Rate         |               | Slave Select      |
| Generator         |               | Controller        |
+--------+----------+               +---------+---------+
         |                                    |
         v                                    v
                  +-------------------+
                  | Shift Register    |
                  | MOSI / MISO Logic |
                  +---------+---------+
                            |
        +-------------------+-------------------+
        |                   |                   |
        v                   v                   v
      MOSI                MISO                SCLK
Module Description
1. APB Slave Interface (APB_slave.v)

The APB Slave Interface acts as the control and configuration block of the SPI controller.

Responsibilities:

APB protocol handling
SPI register management
Configuration decoding
Interrupt generation
Status reporting
Data register management
Registers
Address	Register	Description
0x0	SPI_CR1	SPI Control Register 1
0x1	SPI_CR2	SPI Control Register 2
0x2	SPI_BR	Baud Rate Register
0x3	SPI_SR	Status Register
0x5	SPI_DR	Data Register
2. Baud Rate Generator (Baud_rate_generator.v)

Generates the SPI serial clock (SCLK) and timing pulses required for data transmission and reception.

Baud Rate Formula
BaudRateDivisor = (SPPR + 1) × 2^(SPR + 1)

Functions:

SPI clock generation
Clock division
MOSI transmit timing generation
MISO sampling timing generation
CPOL/CPHA support
3. Shift Register (Shift_reg.v)

Handles serial data transmission and reception.

Functions:

Parallel-to-serial conversion
Serial-to-parallel conversion
MOSI transmission
MISO reception
MSB-first support
LSB-first support
4. Slave Select Controller (spi_slave_select.v)

Controls SPI transaction boundaries.

Functions:

Automatic SS assertion
Transfer duration tracking
Receive complete indication
Transfer-In-Progress (TIP) generation
5. Top Module (top_module.v)

Integrates all submodules and provides the complete APB-to-SPI Master Controller.

Connected Modules:

APB Slave Interface
Baud Rate Generator
Shift Register
Slave Select Controller
6. Testbench (top_module_tb.v)

Verification environment for the SPI controller.

Testbench Features:

Clock generation
Reset generation
APB register configuration
Data transmission testing
Status register verification
Integration testing
SPI Configuration
SPI Modes
Mode	CPOL	CPHA
Mode 0	0	0
Mode 1	0	1
Mode 2	1	0
Mode 3	1	1
Data Flow
CPU/APB Master
      |
      v
APB Write SPI_DR
      |
      v
APB Slave
      |
      v
send_data
      |
      v
Slave Select Active
      |
      v
Baud Generator Creates SCLK
      |
      v
Shift Register Sends MOSI
      |
      v
Slave Responds Through MISO
      |
      v
Received Data Stored In SPI_DR
      |
      v
CPU Reads SPI_DR
Simulation
Running Simulation

Compile all source files:

Baud_rate_generator.v
Shift_reg.v
spi_slave_select.v
APB_slave.v
top_module.v
top_module_tb.v

Run simulation using your preferred simulator:

ModelSim / QuestaSim
Vivado Simulator
Xcelium
VCS
Riviera-PRO

Example:

vlog *.v
vsim top_module_tb
run -all
Expected Outputs

During simulation observe:

sclk_o : SPI clock generation
ss_o : Slave select assertion
mosi_o : Serial transmit data
prdata_o : APB read data
spi_interrupt_request : Interrupt generation
Design Highlights
Fully synthesizable RTL
Modular architecture
APB-compliant register interface
Configurable SPI operation
Parameterizable baud-rate generation
Supports all standard SPI modes
Suitable for FPGA and ASIC implementation
Future Improvements
Parameterized data width (8/16/32-bit)
TX/RX FIFO support
Multi-slave selection
DMA support
Enhanced interrupt controller
APB4 support
SPI Slave mode support
Applications
Sensor interfacing
EEPROM/Flash communication
ADC/DAC control
FPGA peripheral communication
Embedded SoC integration
Custom ASIC peripheral subsystem
Author

Kaviyanandh K

APB to SPI Master Controller RTL Design Project developed as part of VLSI/RTL Design learning and verification activities.
