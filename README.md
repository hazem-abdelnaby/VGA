# Parameterizable VGA Controller (640×480)

## Overview

This project implements a parameterizable VGA timing controller and RGB output stage in Verilog. It generates the horizontal and vertical synchronization signals, tracks the current pixel position, gates RGB output during the active display region, and calculates a pixel-memory address.

The default configuration targets **640×480 VGA timing** with an 8-bit RGB input in **RGB332** format.

## Features

- **Parameterizable display timing:** horizontal and vertical sync, back porch, active video, and front porch are configurable.
- **Parameterizable RGB format:** red, green, and blue channel widths can be changed, provided their sum equals `rgb_width`.
- **Pixel coordinates:** horizontal and vertical counters provide the current pixel position.
- **Active-video gating:** RGB outputs are forced to zero outside the active display region.
- **Pixel address generation:** calculates the linear address using `addr = pixel_y × H_ACTIVE + pixel_x`.
- **Asynchronous active-low reset:** the timing counters are reset when `RST` is low.
- **Lint status:** the design is reported as lint-free for the checks performed.

## Architecture

The design is divided into three main modules:

### 1. `VGA_SYNC`

Generates the VGA timing signals and pixel coordinates.

Main responsibilities:

- Maintains horizontal (`H_CNT`) and vertical (`V_CNT`) counters.
- Increments the horizontal counter on every rising edge of `CLK`.
- Increments the vertical counter when the horizontal counter reaches the end of a line.
- Resets both counters after the complete frame.
- Generates active-low `h_sync` and `v_sync` pulses.
- Asserts `video_on` only when the current coordinate is inside the active display area.

The counter widths are calculated using `$clog2` from the configured total line and frame dimensions.

### 2. `RGB`

Controls the RGB output.

- When `video_on` is high, `rgb_in` is passed to the output channels.
- When `video_on` is low, all RGB output bits are set to zero.
- The input bus is split into red, green, and blue fields according to their configured widths.

For the default RGB332 format:

| Channel | Width | Bits |
|---|---:|---|
| Red | 3 | `rgb_in[7:5]` |
| Green | 3 | `rgb_in[4:2]` |
| Blue | 2 | `rgb_in[1:0]` |

### 3. `VGA_TOP`

Connects the timing generator and RGB output stage.

It:

- Instantiates `VGA_SYNC` and `RGB`.
- Connects the generated `video_on` signal to the RGB stage.
- Combines the red, green, and blue channels into the `RGB` output bus.
- Calculates the linear pixel address:

  `addr = pixel_y * H_ACTIVE + pixel_x`

The address corresponds to row-major pixel storage, where the first active pixel is address 0.

## Default VGA timing

The default parameters are:

| Parameter | Description | Default |
|---|---|---:|
| `H_SYNC` | Horizontal sync width | 96 |
| `H_BACK` | Horizontal back porch | 48 |
| `H_ACTIVE` | Active horizontal pixels | 640 |
| `H_FRONT` | Horizontal front porch | 16 |
| `V_SYNC` | Vertical sync width | 2 |
| `V_BACK` | Vertical back porch | 33 |
| `V_ACTIVE` | Active vertical lines | 480 |
| `V_FRONT` | Vertical front porch | 10 |

This gives:

- Total horizontal pixels per line: `96 + 48 + 640 + 16 = 800`
- Total vertical lines per frame: `2 + 33 + 480 + 10 = 525`
- Total pixel-clock cycles per frame: `800 × 525 = 420,000`

At a 25 MHz pixel clock, the nominal refresh rate is approximately 59.52 Hz. The actual refresh rate depends on the clock frequency supplied to `CLK`.

## Parameterization

The design is parameter-changeable. The timing parameters can be overridden when instantiating `VGA_TOP`, allowing the same RTL to be configured for other display resolutions or timing standards.

The RGB bus and channel widths are also configurable through:

- `rgb_width`
- `red_width`
- `green_width`
- `blue_width`

**Configuration requirement:** `red_width + green_width + blue_width` must equal `rgb_width`. The selected timing values must also be positive and large enough for the counter-width calculations.

Example: to use a different active resolution, override `H_ACTIVE` and `V_ACTIVE` together with the corresponding sync and porch values required by that display mode.

## Testbench

`VGA_TOP_TB` provides a basic simulation-level timing check.

The testbench:

1. Generates the clock using `CLK_PERIOD` (40 ns by default).
2. Applies an active-low reset.
3. Measures the low pulse width of `h_sync`.
4. Measures the low pulse width of `v_sync`.
5. Compares the measured pulse widths against the expected timing.

For the default configuration:

- Expected horizontal sync low width: `H_SYNC = 96` pixel-clock cycles.
- Expected vertical sync low width: `V_SYNC × H_TOTAL = 2 × 800 = 1600` pixel-clock cycles.

The testbench also writes a waveform dump to `VGA_TOP.vcd` for inspection.

## Important integration note

The pixel address is meaningful as an active-frame memory address only while the pixel coordinates are within the active display region:

- `pixel_x < H_ACTIVE`
- `pixel_y < V_ACTIVE`

The current `VGA_TOP` implementation does not expose `video_on` as a top-level output. If the downstream frame-buffer or memory interface needs to know when `addr` is valid, consider exposing an active-video/`video_on` output from `VGA_TOP` and using it as the address-valid or read-enable qualifier.

## Tools and verification

- **HDL:** Verilog
- **Verification:** Verilog testbench and waveform inspection
- **Lint:** Reported lint-free for the checks performed

No specific lint tool, rule set, or version is stated here. Add those details to this section if you want the lint result to be independently reproducible.

## Repository contents

Suggested source organization:

```text
.
├── RTL/
│   ├── RGB.v
│   ├── VGA_SYNC.v
│   └── VGA_TOP.v
├── TB/
│   └── VGA_TOP_TB.v
└── README.md
```

Adjust the file names and folder structure to match the actual repository.
