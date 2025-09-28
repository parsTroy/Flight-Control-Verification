# Flight Control Verification Project (Aerospace)

## Project Overview

This project implements a comprehensive quadcopter altitude control system simulation in MATLAB/Simulink, following DO-178C verification standards for aerospace applications.

## Objective

Model a simplified quadcopter vertical controller (altitude hold) in Simulink, build a test harness that injects sensor noise and wind gusts, and produce a V&V report that maps requirements → model elements → test cases.

## Project Structure

```
Flight-Control-Verification/
├── README.md
├── quad_alt_hold.slx          # Main Simulink model
├── matlab/                    # MATLAB scripts and utilities
│   ├── run_tests.m
│   └── utils.m
├── docs/                      # Documentation and V&V reports
│   └── VnV_report.pdf
├── plots/                     # Generated plots and figures
├── requirements/              # Requirements management
│   └── requirements.csv
└── test_results/              # Test outputs and data
```

## Technical Specifications

### Simplified Dynamics Model
- Vertical motion: `mẍ = T - mg - D(ż)`
- Thrust: `T = k_u * u` (actuator command)
- Sensor: Altimeter with Gaussian noise and sample period
- Actuator: First-order lag dynamics

### Test Cases
- **Nominal**: No disturbance, steady hover ±5% power
- **Step disturbance**: Downward wind gust, recovery time validation
- **Sensor noise**: Controller robustness to noise variance
- **Actuator failure**: Reduced thrust safe behavior evaluation

## Requirements

- MATLAB R2020b or later
- Simulink
- Control System Toolbox
- Simulink Test (for automated testing)

## Getting Started

1. Clone this repository
2. Open MATLAB and navigate to the project directory
3. Run `matlab/run_tests.m` to execute the test suite
4. Open `quad_alt_hold.slx` to view the Simulink model

## Development Notes

This project follows DO-178C principles for requirements traceability, configuration control, and test evidence. Each phase is developed in its own git branch and merged to main upon completion.

## License

This project is for educational and portfolio purposes.
