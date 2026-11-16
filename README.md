# Gearbox
Parametric gearbox generator for various applications, complete with engineering calculations and design tools!
# Gear reducers: planetary, cycloidal, and a cycloidal design tool

Reducers I designed, printed and ran, each with its CAD and the calculation behind it, plus a browser tool I wrote for designing cycloidal drives.

Author: Abu Saimoom, mechanical engineering student, LUT University.
Video of the gearboxes running: https://youtube.com/shorts/e-lkEnf8GHA

## Contents

| Folder / file | What it is | Status |
|---|---|---|
| `4.1 planetary/` | 4:1 helical planetary gearbox, 100 mm outer diameter | Built; drove the sorting mechanism of the "Rheo" AI waste-sorting bin (Deep Tech Hackathon, Oct 2026) |
| `cycloidal_drive/` | 20:1 cycloidal drive with 6812 output bearing | Built and running; base joint of my robot arm (see the `Robot-arm` repository) |
| `cycloidal_drive_designer_v4.html` | Cycloidal Drive Designer: single-file browser tool | Working |

## 4:1 helical planetary gearbox

Ring fixed in the housing, sun as input, carrier as output. Printed and greased.

| Parameter | Value |
|---|---|
| Teeth: sun / planet / ring | 18 / 18 / 54 |
| Planets | 3 |
| Normal module | 1.5 mm |
| Normal pressure angle | 20 deg |
| Helix angle | 20 deg |
| Face width | 15 mm |
| Ratio | 4:1 |
| Planet bearings | 2 x 625 per planet |

Files: `cad/` holds the SolidWorks parts and assembly. `cad/gear_globals.txt` is the SolidWorks global-variable file that drives the gear geometry. `clc.m` is the MATLAB calculation.

**What `clc.m` checks:** kinematics and assembly condition, geometry and ring wall, helix twist over the face width, contact ratios, mesh forces, efficiency and output torque, tooth bending (Lewis), planet bearing load and life.

| Check | Result at 0.5 Nm input (as in the script) | At servo stall, 0.92 Nm |
|---|---|---|
| Assembly condition (Zs + Zr) / N | 24, integer | |
| Ring wall thickness | 5.0 mm | |
| Transverse contact ratio: sun-planet / planet-ring | 1.42 / 1.74 | |
| Overlap ratio | 1.09 | |
| Estimated efficiency | 0.925 | |
| Output torque | 1.85 Nm | 3.4 Nm |
| Tooth bending stress / safety factor (15 MPa allowable assumed) | 2.1 MPa / 7.3 | 3.8 MPa / 3.9 |
| Worst planet bearing load / static safety | 43 N / 15.8 | 79 N / 8.6 |

In the Rheo bin it was driven by an MG996R hobby servo on a 5 V USB power bank (about 0.9 Nm at stall). The calculation was done after the event as a check; the 15 MPa allowable for printed plastic is an assumption, and wear and creep will limit continuous torque below the bending limit.

## 20:1 cycloidal drive

Two 19-lobe discs phased 180 degrees, 20 steel ring pins (dia 5) on a 75 mm pin circle, 1 mm eccentricity, rotating housing as output on a 6812 bearing. `print/` has STEP files of every printed part; `calculation/checks.m` is the MATLAB verification. Results and known limits are documented in the `Robot-arm` repository (J1).

The first build did not work: the discs were printed with zero pin clearance and barely turned. The profile now includes clearance, and the pins and eccentric shaft were redesigned.

## Cycloidal Drive Designer

Open `cycloidal_drive_designer_v4.html` in a browser; no install and no server.

- Enter pin count, pin circle, pin size, eccentricity and bearing sizes; see the cross-section at any crank angle
- Status panel flags geometry problems
- Loads, stresses and geometry curves for the current design
- Optimizer for the free parameters
- The governing equations shown with the current design's numbers
- STEP export for every part, plus a buy / cut list and a report

While verifying the tool against a MATLAB model I found and corrected a missing eccentricity term in the disc profile equation I had started from.

## Running the MATLAB scripts

Base MATLAB, no toolboxes. Run the script; it prints numbered sections and a pass/fail summary. Inputs are at the top.
