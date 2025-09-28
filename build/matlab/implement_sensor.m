function implement_sensor()
% IMPLEMENT_SENSOR - Implement sensor model with noise and sampling
%
% This function implements the Sensor subsystem with:
% - Altimeter measurement model
% - Gaussian noise generation
% - Sample and hold
% - Quantization effects
%
% Author: Flight Control Verification Project
% Date: 2024

    fprintf('Implementing Sensor Subsystem...\n');
    
    model_name = 'quad_alt_hold';
    
    % Check if model exists
    if ~exist([model_name '.slx'], 'file')
        error('Model %s.slx not found. Please run setup_phase0.m first.', model_name);
    end
    
    % Open the model
    open_system(model_name);
    
    % Create Sensor subsystem
    create_sensor_subsystem(model_name);
    
    % Implement noise generation
    implement_noise_generation(model_name);
    
    % Implement sample and hold
    implement_sample_hold(model_name);
    
    % Implement quantization
    implement_quantization(model_name);
    
    % Connect all components
    connect_sensor_components(model_name);
    
    % Save the model
    save_system(model_name);
    
    fprintf('Sensor implementation completed.\n');

end

function create_sensor_subsystem(model_name)
% CREATE_SENSOR_SUBSYSTEM - Create the Sensor subsystem structure

    subsystem_name = [model_name '/Sensor'];
    
    % Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', subsystem_name);
    set_param(subsystem_name, 'Name', 'Sensor');
    set_param(subsystem_name, 'Position', [400, 50, 500, 200]);
    
    % Add input port
    add_block('simulink/Sources/In1', [subsystem_name '/True_Altitude']);
    set_param([subsystem_name '/True_Altitude'], 'Position', [20, 50, 50, 70]);
    
    % Add output port
    add_block('simulink/Sinks/Out1', [subsystem_name '/Measured_Altitude']);
    set_param([subsystem_name '/Measured_Altitude'], 'Position', [230, 50, 260, 70]);
    
    fprintf('  Sensor subsystem structure created.\n');

end

function implement_noise_generation(model_name)
% IMPLEMENT_NOISE_GENERATION - Implement Gaussian noise generation

    subsystem_name = [model_name '/Sensor'];
    
    % Add random number generator for noise
    add_block('simulink/Sources/Random Number', [subsystem_name '/Noise_Generator']);
    set_param([subsystem_name '/Noise_Generator'], 'Position', [70, 100, 100, 120]);
    set_param([subsystem_name '/Noise_Generator'], 'Mean', '0');
    set_param([subsystem_name '/Noise_Generator'], 'Variance', '0.01');  % Will be set to sensor_noise_variance
    set_param([subsystem_name '/Noise_Generator'], 'Seed', '12345');
    set_param([subsystem_name '/Noise_Generator'], 'SampleTime', '0.01');  % Will be set to sensor_sample_time
    
    % Add gain for noise scaling
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Noise_Gain']);
    set_param([subsystem_name '/Noise_Gain'], 'Position', [120, 100, 150, 120]);
    set_param([subsystem_name '/Noise_Gain'], 'Gain', '1.0');  % Will be set to sqrt(noise_variance)
    
    % Add sum for noise addition
    add_block('simulink/Math Operations/Sum', [subsystem_name '/Noise_Sum']);
    set_param([subsystem_name '/Noise_Sum'], 'Position', [120, 50, 150, 70]);
    set_param([subsystem_name '/Noise_Sum'], 'Inputs', '++');
    
    fprintf('  Noise generation implemented.\n');

end

function implement_sample_hold(model_name)
% IMPLEMENT_SAMPLE_HOLD - Implement sample and hold

    subsystem_name = [model_name '/Sensor'];
    
    % Add zero-order hold for sampling
    add_block('simulink/Discrete/Zero-Order Hold', [subsystem_name '/Sample_Hold']);
    set_param([subsystem_name '/Sample_Hold'], 'Position', [170, 50, 200, 70]);
    set_param([subsystem_name '/Sample_Hold'], 'SampleTime', '0.01');  % Will be set to sensor_sample_time
    
    fprintf('  Sample and hold implemented.\n');

end

function implement_quantization(model_name)
% IMPLEMENT_QUANTIZATION - Implement quantization effects

    subsystem_name = [model_name '/Sensor'];
    
    % Add quantization block
    add_block('simulink/Discontinuities/Quantizer', [subsystem_name '/Quantizer']);
    set_param([subsystem_name '/Quantizer'], 'Position', [200, 50, 230, 70]);
    set_param([subsystem_name '/Quantizer'], 'QuantizationInterval', '0.1');  % Will be set to sensor_resolution
    
    fprintf('  Quantization implemented.\n');

end

function connect_sensor_components(model_name)
% CONNECT_SENSOR_COMPONENTS - Connect all sensor components

    subsystem_name = [model_name '/Sensor'];
    
    % Connect true altitude to noise sum
    add_line(subsystem_name, 'True_Altitude/1', 'Noise_Sum/1');
    
    % Connect noise generator to noise gain
    add_line(subsystem_name, 'Noise_Generator/1', 'Noise_Gain/1');
    
    % Connect noise gain to noise sum
    add_line(subsystem_name, 'Noise_Gain/1', 'Noise_Sum/2');
    
    % Connect noise sum to sample hold
    add_line(subsystem_name, 'Noise_Sum/1', 'Sample_Hold/1');
    
    % Connect sample hold to quantizer
    add_line(subsystem_name, 'Sample_Hold/1', 'Quantizer/1');
    
    % Connect quantizer to output
    add_line(subsystem_name, 'Quantizer/1', 'Measured_Altitude/1');
    
    fprintf('  Sensor components connected.\n');

end
