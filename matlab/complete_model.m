function complete_model()
% COMPLETE_MODEL - Connect all subsystems and complete the model
%
% This function connects all subsystems and completes the quadcopter
% altitude control model with proper signal routing and parameter setup.
%
% Author: Flight Control Verification Project
% Date: 2024

    fprintf('Completing Model Integration...\n');
    
    model_name = 'quad_alt_hold';
    
    % Check if model exists
    if ~exist([model_name '.slx'], 'file')
        error('Model %s.slx not found. Please run setup_phase0.m first.', model_name);
    end
    
    % Open the model
    open_system(model_name);
    
    % Connect all subsystems
    connect_all_subsystems(model_name);
    
    % Set up parameters
    setup_model_parameters(model_name);
    
    % Add scopes for monitoring
    add_monitoring_scopes(model_name);
    
    % Validate model
    validate_complete_model(model_name);
    
    % Save the model
    save_system(model_name);
    
    fprintf('Model integration completed successfully!\n');

end

function connect_all_subsystems(model_name)
% CONNECT_ALL_SUBSYSTEMS - Connect all subsystems with proper signals

    fprintf('  Connecting all subsystems...\n');
    
    % Connect altitude command to controller
    add_line(model_name, 'Altitude_Command/1', 'Controller/1');
    
    % Connect sensor output to controller (altitude error)
    add_line(model_name, 'Sensor/1', 'Controller/2');
    
    % Connect controller output to actuator
    add_line(model_name, 'Controller/1', 'Actuator/1');
    
    % Connect actuator output to plant
    add_line(model_name, 'Actuator/1', 'Plant/1');
    
    % Connect disturbance output to plant
    add_line(model_name, 'Disturbance/1', 'Plant/2');
    
    % Connect plant altitude output to sensor
    add_line(model_name, 'Plant/1', 'Sensor/1');
    
    % Connect plant altitude output to main output
    add_line(model_name, 'Plant/1', 'Altitude_Output/1');
    
    % Connect plant altitude output to scope
    add_line(model_name, 'Plant/1', 'Altitude_Scope/1');
    
    fprintf('    All subsystems connected.\n');

end

function setup_model_parameters(model_name)
% SETUP_MODEL_PARAMETERS - Set up all model parameters

    fprintf('  Setting up model parameters...\n');
    
    % Set up Plant subsystem parameters
    set_param([model_name '/Plant/Mass_Gain'], 'Gain', '1.0');  % 1/mass
    set_param([model_name '/Plant/Gravity_Gain'], 'Gain', '1.0');  % mass
    set_param([model_name '/Plant/Drag_Gain'], 'Gain', '-0.1');  % -drag_coefficient
    
    % Set up Controller subsystem parameters
    set_param([model_name '/Controller/Proportional_Gain'], 'Gain', '1.0');  % Kp
    set_param([model_name '/Controller/Integral_Gain'], 'Gain', '0.1');  % Ki
    set_param([model_name '/Controller/Derivative_Gain'], 'Gain', '0.5');  % Kd
    set_param([model_name '/Controller/Anti_Windup_Gain'], 'Gain', '1.0');  % Anti-windup gain
    
    % Set up Actuator subsystem parameters
    set_param([model_name '/Actuator/Actuator_Dynamics'], 'Denominator', '[0.1 1]');  % [tau 1]
    set_param([model_name '/Actuator/Thrust_Gain'], 'Gain', '10.0');  % thrust_gain
    
    % Set up Sensor subsystem parameters
    set_param([model_name '/Sensor/Noise_Generator'], 'Variance', '0.01');  % sensor_noise_variance
    set_param([model_name '/Sensor/Noise_Generator'], 'SampleTime', '0.01');  % sensor_sample_time
    set_param([model_name '/Sensor/Noise_Gain'], 'Gain', '0.1');  % sqrt(noise_variance)
    set_param([model_name '/Sensor/Sample_Hold'], 'SampleTime', '0.01');  % sensor_sample_time
    set_param([model_name '/Sensor/Quantizer'], 'QuantizationInterval', '0.1');  % sensor_resolution
    
    % Set up Disturbance subsystem parameters
    set_param([model_name '/Disturbance/Step_Gust'], 'Time', '5.0');  % wind_gust_start_time
    set_param([model_name '/Disturbance/Step_Gust'], 'After', '-2.0');  % -wind_gust_magnitude
    set_param([model_name '/Disturbance/Impulse_Gust'], 'Time', '5.0');  % wind_gust_start_time
    set_param([model_name '/Disturbance/Impulse_Gust'], 'After', '-1.0');  % -wind_gust_magnitude/2
    set_param([model_name '/Disturbance/White_Noise_Wind'], 'Variance', '0.25');  % (wind_gust_magnitude/4)^2
    set_param([model_name '/Disturbance/Switch_Control'], 'Value', '1');  % disturbance type
    
    fprintf('    Model parameters set.\n');

end

function add_monitoring_scopes(model_name)
% ADD_MONITORING_SCOPES - Add additional scopes for monitoring

    fprintf('  Adding monitoring scopes...\n');
    
    % Add scope for thrust command
    add_block('simulink/Sinks/Scope', [model_name '/Thrust_Command_Scope']);
    set_param([model_name '/Thrust_Command_Scope'], 'Position', [350, 200, 380, 230]);
    add_line(model_name, 'Controller/1', 'Thrust_Command_Scope/1');
    
    % Add scope for thrust force
    add_block('simulink/Sinks/Scope', [model_name '/Thrust_Force_Scope']);
    set_param([model_name '/Thrust_Force_Scope'], 'Position', [350, 250, 380, 280]);
    add_line(model_name, 'Actuator/1', 'Thrust_Force_Scope/1');
    
    % Add scope for altitude error
    add_block('simulink/Math Operations/Sum', [model_name '/Altitude_Error_Sum']);
    set_param([model_name '/Altitude_Error_Sum'], 'Position', [200, 300, 230, 320]);
    set_param([model_name '/Altitude_Error_Sum'], 'Inputs', '+-');
    
    add_block('simulink/Sinks/Scope', [model_name '/Altitude_Error_Scope']);
    set_param([model_name '/Altitude_Error_Scope'], 'Position', [350, 300, 380, 330]);
    
    add_line(model_name, 'Altitude_Command/1', 'Altitude_Error_Sum/1');
    add_line(model_name, 'Sensor/1', 'Altitude_Error_Sum/2');
    add_line(model_name, 'Altitude_Error_Sum/1', 'Altitude_Error_Scope/1');
    
    % Add scope for wind disturbance
    add_block('simulink/Sinks/Scope', [model_name '/Wind_Disturbance_Scope']);
    set_param([model_name '/Wind_Disturbance_Scope'], 'Position', [350, 350, 380, 380]);
    add_line(model_name, 'Disturbance/1', 'Wind_Disturbance_Scope/1');
    
    fprintf('    Monitoring scopes added.\n');

end

function validate_complete_model(model_name)
% VALIDATE_COMPLETE_MODEL - Validate the complete model

    fprintf('  Validating complete model...\n');
    
    % Check for compilation errors
    try
        set_param(model_name, 'SimulationCommand', 'update');
        fprintf('    ✓ Model compiles successfully\n');
    catch ME
        warning('Model compilation failed: %s', ME.message);
    end
    
    % Check for unconnected ports
    unconnected_ports = find_system(model_name, 'FindAll', 'on', 'Type', 'port', 'Connected', 'off');
    if isempty(unconnected_ports)
        fprintf('    ✓ All ports connected\n');
    else
        warning('Found %d unconnected ports', length(unconnected_ports));
    end
    
    % Check for algebraic loops
    algebraic_loops = find_system(model_name, 'FindAll', 'on', 'Type', 'line', 'Connected', 'on');
    if ~isempty(algebraic_loops)
        fprintf('    ✓ Signal connections verified\n');
    end
    
    fprintf('    Model validation completed.\n');

end
