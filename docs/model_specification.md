# Quadcopter Altitude Control Model Specification

## Model Overview

The `quad_alt_hold.slx` Simulink model implements a simplified quadcopter vertical controller for altitude hold operations. This document provides detailed specifications for implementing the model in Simulink.

## Model Architecture

### Top-Level Structure

```
quad_alt_hold.slx
├── Altitude_Command (Input)
├── Controller_Subsystem
│   ├── PID_Controller
│   ├── Anti_Windup
│   └── Output_Saturation
├── Actuator_Subsystem
│   ├── First_Order_Lag
│   └── Thrust_Conversion
├── Plant_Subsystem
│   ├── Vertical_Dynamics
│   ├── Gravity_Compensation
│   └── Drag_Model
├── Sensor_Subsystem
│   ├── Altimeter_Model
│   ├── Noise_Generator
│   └── Sample_Hold
├── Disturbance_Subsystem
│   ├── Wind_Gust_Generator
│   └── Disturbance_Switch
└── Altitude_Output (Output)
```

## Detailed Subsystem Specifications

### 1. Controller Subsystem

**Purpose**: Implement PID control with anti-windup and output saturation

**Components**:
- **PID Controller Block**
  - Proportional Gain (Kp): 1.0
  - Integral Gain (Ki): 0.1
  - Derivative Gain (Kd): 0.5
  - Derivative Filter Time Constant: 0.01 s

- **Anti-Windup Logic**
  - Back-calculation method
  - Anti-windup gain: 1.0
  - Integrator saturation limits: [-0.5, 0.5]

- **Output Saturation**
  - Minimum thrust: 0.0 (normalized)
  - Maximum thrust: 1.0 (normalized)

**Inputs**:
- Altitude error (m)
- Altitude command (m)

**Outputs**:
- Thrust command (normalized 0-1)

### 2. Actuator Subsystem

**Purpose**: Model actuator dynamics and thrust conversion

**Components**:
- **First-Order Lag**
  - Time constant: 0.1 s
  - Transfer function: 1/(0.1s + 1)

- **Thrust Conversion**
  - Thrust gain: 10.0 N per unit command
  - Output: Thrust force (N)

**Inputs**:
- Thrust command (normalized 0-1)

**Outputs**:
- Thrust force (N)

### 3. Plant Subsystem

**Purpose**: Implement quadcopter vertical dynamics

**Components**:
- **Vertical Dynamics**
  - Mass: 1.0 kg
  - Gravity: 9.81 m/s²
  - Equation: m*ẍ = T - m*g - D(ẋ)
  - Drag coefficient: 0.1 Ns/m

- **Gravity Compensation**
  - Constant: -9.81 m/s²

- **Drag Model**
  - Linear drag: D = 0.1 * velocity
  - Input: Vertical velocity (m/s)
  - Output: Drag force (N)

**Inputs**:
- Thrust force (N)
- Wind disturbance (m/s)

**Outputs**:
- Altitude (m)
- Vertical velocity (m/s)
- Vertical acceleration (m/s²)

### 4. Sensor Subsystem

**Purpose**: Model altimeter with noise and sampling

**Components**:
- **Altimeter Model**
  - Perfect measurement (no bias)
  - Resolution: 0.1 m

- **Noise Generator**
  - Gaussian white noise
  - Variance: 0.01 m²
  - Standard deviation: 0.1 m

- **Sample and Hold**
  - Sample time: 0.01 s
  - Zero-order hold

**Inputs**:
- True altitude (m)

**Outputs**:
- Measured altitude (m)

### 5. Disturbance Subsystem

**Purpose**: Generate various disturbance scenarios

**Components**:
- **Wind Gust Generator**
  - Step gust: -2.0 m/s for 2 seconds
  - Impulse gust: -1.0 m/s for 0.5 seconds
  - White noise: 0.5 m/s RMS

- **Disturbance Switch**
  - Manual selection of disturbance type
  - Timing control for step/impulse disturbances

**Inputs**:
- Disturbance type selection
- Timing signals

**Outputs**:
- Wind velocity disturbance (m/s)

## Implementation Guidelines

### Simulink Block Selection

1. **Continuous Blocks**:
   - Integrator (for velocity and position)
   - Transfer Function (for actuator dynamics)
   - Sum (for combining forces)
   - Gain (for scaling)

2. **Discrete Blocks**:
   - Zero-Order Hold (for sensor sampling)
   - Unit Delay (for discrete-time systems)

3. **Sources**:
   - Step (for altitude commands)
   - Random Number (for noise generation)
   - Constant (for parameters)

4. **Sinks**:
   - Scope (for visualization)
   - To Workspace (for data logging)

### Parameter Configuration

All parameters should be defined in the MATLAB workspace or as Simulink parameters:

```matlab
% Physical parameters
mass = 1.0;                    % kg
gravity = 9.81;                 % m/s^2
drag_coefficient = 0.1;         % Ns/m
thrust_gain = 10.0;             % N per unit command

% Actuator parameters
actuator_time_constant = 0.1;    % s

% Sensor parameters
sensor_noise_variance = 0.01;   % m^2
sensor_sample_time = 0.01;      % s

% Controller parameters
kp = 1.0;                       % Proportional gain
ki = 0.1;                       % Integral gain
kd = 0.5;                       % Derivative gain

% Simulation parameters
simulation_time = 20.0;         % s
time_step = 0.001;             % s
```

### Model Validation

1. **Open-loop Test**: Verify plant dynamics without controller
2. **Closed-loop Test**: Verify controller performance
3. **Disturbance Rejection**: Test with various disturbances
4. **Parameter Sensitivity**: Test robustness to parameter variations

## Next Steps

1. Create the Simulink model file `quad_alt_hold.slx`
2. Implement each subsystem according to this specification
3. Configure parameters and simulation settings
4. Run initial validation tests
5. Document any deviations from specification

## Learning Resources

- **Simulink Basics**: [MathWorks Simulink Tutorial](https://www.mathworks.com/help/simulink/getting-started-with-simulink.html)
- **Control Systems**: [PID Controller Design](https://www.mathworks.com/help/control/ug/pid-controller-design.html)
- **Aerospace Modeling**: [Aircraft Dynamics Modeling](https://www.mathworks.com/help/aeroblks/)
- **DO-178C**: [Software Life Cycle Processes](https://www.rtca.org/store/product/do-178c-software-considerations-in-airborne-systems-and-equipment-certification/)
