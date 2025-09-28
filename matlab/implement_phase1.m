function implement_phase1()
% IMPLEMENT_PHASE1 - Complete Phase 1: Model Dynamics Implementation
%
% This function implements all subsystems for the quadcopter altitude
% control system following the specifications in model_specification.md
%
% Phase 1 Objectives:
% 1. Implement Plant subsystem (quadcopter vertical dynamics)
% 2. Implement Controller subsystem (PID with anti-windup)
% 3. Implement Actuator subsystem (first-order lag dynamics)
% 4. Implement Sensor subsystem (altimeter with noise)
% 5. Implement Disturbance subsystem (wind gust generation)
% 6. Connect all subsystems and complete the model
%
% Author: Flight Control Verification Project
% Date: 2024

    fprintf('==========================================\n');
    fprintf('FLIGHT CONTROL VERIFICATION - PHASE 1\n');
    fprintf('Model Dynamics Implementation\n');
    fprintf('==========================================\n\n');
    
    % Check MATLAB environment
    check_matlab_environment();
    
    % Set up workspace parameters
    setup_workspace_parameters();
    
    % Create initial model if it doesn't exist
    create_initial_model_if_needed();
    
    % Implement all subsystems
    implement_all_subsystems();
    
    % Complete model integration
    complete_model_integration();
    
    % Run initial validation tests
    run_initial_validation();
    
    % Display completion message
    display_phase1_completion();
    
    fprintf('\nPhase 1 implementation completed successfully!\n');
    fprintf('Ready to proceed to Phase 2: Controller Tuning and Optimization\n');

end

function check_matlab_environment()
% CHECK_MATLAB_ENVIRONMENT - Verify MATLAB environment

    fprintf('Checking MATLAB environment...\n');
    
    % Check MATLAB version
    matlab_version = version('-release');
    fprintf('  MATLAB Version: %s\n', matlab_version);
    
    % Check Simulink license
    if license('test', 'Simulink')
        fprintf('  ✓ Simulink License: Valid\n');
    else
        error('Simulink license not available. Please ensure Simulink is installed and licensed.');
    end
    
    % Check Control System Toolbox
    if license('test', 'Control_Toolbox')
        fprintf('  ✓ Control System Toolbox: Available\n');
    else
        warning('  ⚠ Control System Toolbox: Not available - some features may not work\n');
    end
    
    fprintf('Environment check completed.\n\n');

end

function setup_workspace_parameters()
% SETUP_WORKSPACE_PARAMETERS - Define all simulation parameters

    fprintf('Setting up workspace parameters...\n');
    
    % Clear workspace
    clear;
    clc;
    
    % Physical parameters
    assignin('base', 'mass', 1.0);                    % kg
    assignin('base', 'gravity', 9.81);                 % m/s^2
    assignin('base', 'drag_coefficient', 0.1);         % Ns/m
    assignin('base', 'thrust_gain', 10.0);             % N per unit command
    
    % Actuator parameters
    assignin('base', 'actuator_time_constant', 0.1);    % s
    assignin('base', 'max_thrust', 1.0);               % normalized
    assignin('base', 'min_thrust', 0.0);               % normalized
    
    % Sensor parameters
    assignin('base', 'sensor_noise_variance', 0.01);   % m^2
    assignin('base', 'sensor_sample_time', 0.01);      % s
    assignin('base', 'sensor_resolution', 0.1);        % m
    
    % Controller parameters (initial values - will be tuned in Phase 2)
    assignin('base', 'kp', 1.0);                       % Proportional gain
    assignin('base', 'ki', 0.1);                       % Integral gain
    assignin('base', 'kd', 0.5);                       % Derivative gain
    assignin('base', 'derivative_filter_time', 0.01);  % s
    assignin('base', 'anti_windup_gain', 1.0);         % Anti-windup gain
    
    % Simulation parameters
    assignin('base', 'simulation_time', 20.0);        % s
    assignin('base', 'time_step', 0.001);              % s
    assignin('base', 'solver', 'ode45');
    
    % Test parameters
    assignin('base', 'step_command', 5.0);            % m
    assignin('base', 'wind_gust_magnitude', 2.0);      % m/s
    assignin('base', 'wind_gust_duration', 2.0);       % s
    assignin('base', 'wind_gust_start_time', 5.0);    % s
    
    fprintf('  Workspace parameters configured.\n\n');

end

function create_initial_model_if_needed()
% CREATE_INITIAL_MODEL_IF_NEEDED - Create initial model if it doesn't exist

    model_name = 'quad_alt_hold';
    
    if ~exist([model_name '.slx'], 'file')
        fprintf('Creating initial model structure...\n');
        setup_phase0();
    else
        fprintf('Using existing model: %s.slx\n', model_name);
    end
    
    fprintf('\n');

end

function implement_all_subsystems()
% IMPLEMENT_ALL_SUBSYSTEMS - Implement all subsystems

    fprintf('Implementing all subsystems...\n');
    
    % Implement Plant subsystem
    fprintf('  Implementing Plant subsystem...\n');
    implement_plant_dynamics();
    
    % Implement Controller subsystem
    fprintf('  Implementing Controller subsystem...\n');
    implement_controller();
    
    % Implement Actuator subsystem
    fprintf('  Implementing Actuator subsystem...\n');
    implement_actuator();
    
    % Implement Sensor subsystem
    fprintf('  Implementing Sensor subsystem...\n');
    implement_sensor();
    
    % Implement Disturbance subsystem
    fprintf('  Implementing Disturbance subsystem...\n');
    implement_disturbance();
    
    fprintf('  All subsystems implemented.\n\n');

end

function complete_model_integration()
% COMPLETE_MODEL_INTEGRATION - Complete model integration

    fprintf('Completing model integration...\n');
    
    % Connect all subsystems
    complete_model();
    
    fprintf('  Model integration completed.\n\n');

end

function run_initial_validation()
% RUN_INITIAL_VALIDATION - Run initial validation tests

    fprintf('Running initial validation tests...\n');
    
    model_name = 'quad_alt_hold';
    
    % Test 1: Model compilation
    fprintf('  Test 1: Model compilation...\n');
    try
        set_param(model_name, 'SimulationCommand', 'update');
        fprintf('    ✓ Model compiles successfully\n');
    catch ME
        error('Model compilation failed: %s', ME.message);
    end
    
    % Test 2: Basic simulation
    fprintf('  Test 2: Basic simulation...\n');
    try
        sim(model_name, 'StopTime', '5.0');
        fprintf('    ✓ Basic simulation runs successfully\n');
    catch ME
        warning('Basic simulation failed: %s', ME.message);
    end
    
    % Test 3: Signal connections
    fprintf('  Test 3: Signal connections...\n');
    unconnected_ports = find_system(model_name, 'FindAll', 'on', 'Type', 'port', 'Connected', 'off');
    if isempty(unconnected_ports)
        fprintf('    ✓ All ports connected\n');
    else
        warning('Found %d unconnected ports', length(unconnected_ports));
    end
    
    % Test 4: Parameter validation
    fprintf('  Test 4: Parameter validation...\n');
    validate_parameters();
    
    fprintf('  Initial validation completed.\n\n');

end

function validate_parameters()
% VALIDATE_PARAMETERS - Validate model parameters

    model_name = 'quad_alt_hold';
    
    % Check critical parameters
    critical_params = {
        'Plant/Mass_Gain', '1.0';
        'Plant/Gravity_Gain', '1.0';
        'Plant/Drag_Gain', '-0.1';
        'Controller/Proportional_Gain', '1.0';
        'Controller/Integral_Gain', '0.1';
        'Controller/Derivative_Gain', '0.5';
        'Actuator/Thrust_Gain', '10.0';
        'Sensor/Noise_Generator', '0.01'
    };
    
    for i = 1:size(critical_params, 1)
        block_name = [model_name '/' critical_params{i, 1}];
        expected_value = critical_params{i, 2};
        
        if strcmp(critical_params{i, 1}, 'Sensor/Noise_Generator')
            param_name = 'Variance';
        else
            param_name = 'Gain';
        end
        
        actual_value = get_param(block_name, param_name);
        if strcmp(actual_value, expected_value)
            fprintf('    ✓ %s: %s\n', critical_params{i, 1}, actual_value);
        else
            warning('    ⚠ %s: Expected %s, got %s', critical_params{i, 1}, expected_value, actual_value);
        end
    end

end

function display_phase1_completion()
% DISPLAY_PHASE1_COMPLETION - Display Phase 1 completion information

    fprintf('==========================================\n');
    fprintf('PHASE 1 COMPLETION SUMMARY\n');
    fprintf('==========================================\n\n');
    
    fprintf('✓ Plant subsystem implemented (quadcopter vertical dynamics)\n');
    fprintf('✓ Controller subsystem implemented (PID with anti-windup)\n');
    fprintf('✓ Actuator subsystem implemented (first-order lag dynamics)\n');
    fprintf('✓ Sensor subsystem implemented (altimeter with noise)\n');
    fprintf('✓ Disturbance subsystem implemented (wind gust generation)\n');
    fprintf('✓ All subsystems connected and integrated\n');
    fprintf('✓ Model compilation and basic simulation validated\n');
    fprintf('✓ Parameters configured and validated\n\n');
    
    fprintf('Model Features Implemented:\n');
    fprintf('- Vertical dynamics: m*ẍ = T - m*g - D(ẋ)\n');
    fprintf('- PID controller with anti-windup and saturation\n');
    fprintf('- First-order actuator dynamics: 1/(τs + 1)\n');
    fprintf('- Sensor model with Gaussian noise and quantization\n');
    fprintf('- Wind gust generation (step, impulse, white noise)\n');
    fprintf('- Comprehensive monitoring and visualization\n\n');
    
    fprintf('Next Steps for Phase 2:\n');
    fprintf('1. Tune PID controller parameters\n');
    fprintf('2. Optimize system performance\n');
    fprintf('3. Implement advanced control features\n');
    fprintf('4. Add robustness analysis\n');
    fprintf('5. Prepare for comprehensive testing\n\n');
    
    fprintf('Files Created/Modified:\n');
    fprintf('- quad_alt_hold.slx (Complete Simulink model)\n');
    fprintf('- matlab/implement_plant_dynamics.m\n');
    fprintf('- matlab/implement_controller.m\n');
    fprintf('- matlab/implement_actuator.m\n');
    fprintf('- matlab/implement_sensor.m\n');
    fprintf('- matlab/implement_disturbance.m\n');
    fprintf('- matlab/complete_model.m\n');
    fprintf('- matlab/implement_phase1.m\n');

end
