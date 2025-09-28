function implement_actuator()
% IMPLEMENT_ACTUATOR - Implement actuator dynamics and thrust conversion
%
% This function implements the Actuator subsystem with:
% - First-order lag dynamics: 1/(τs + 1)
% - Thrust conversion from normalized command to force
% - Saturation limits
%
% Author: Flight Control Verification Project
% Date: 2024

    fprintf('Implementing Actuator Subsystem...\n');
    
    model_name = 'quad_alt_hold';
    
    % Check if model exists
    if ~exist([model_name '.slx'], 'file')
        error('Model %s.slx not found. Please run setup_phase0.m first.', model_name);
    end
    
    % Open the model
    open_system(model_name);
    
    % Create Actuator subsystem
    create_actuator_subsystem(model_name);
    
    % Implement actuator dynamics
    implement_actuator_dynamics(model_name);
    
    % Implement thrust conversion
    implement_thrust_conversion(model_name);
    
    % Connect all components
    connect_actuator_components(model_name);
    
    % Save the model
    save_system(model_name);
    
    fprintf('Actuator implementation completed.\n');

end

function create_actuator_subsystem(model_name)
% CREATE_ACTUATOR_SUBSYSTEM - Create the Actuator subsystem structure

    subsystem_name = [model_name '/Actuator'];
    
    % Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', subsystem_name);
    set_param(subsystem_name, 'Name', 'Actuator');
    set_param(subsystem_name, 'Position', [200, 50, 300, 150]);
    
    % Add input port
    add_block('simulink/Sources/In1', [subsystem_name '/Thrust_Command']);
    set_param([subsystem_name '/Thrust_Command'], 'Position', [20, 50, 50, 70]);
    
    % Add output port
    add_block('simulink/Sinks/Out1', [subsystem_name '/Thrust_Force']);
    set_param([subsystem_name '/Thrust_Force'], 'Position', [230, 50, 260, 70]);
    
    fprintf('  Actuator subsystem structure created.\n');

end

function implement_actuator_dynamics(model_name)
% IMPLEMENT_ACTUATOR_DYNAMICS - Implement first-order lag dynamics

    subsystem_name = [model_name '/Actuator'];
    
    % Add transfer function for actuator dynamics
    add_block('simulink/Continuous/Transfer Fcn', [subsystem_name '/Actuator_Dynamics']);
    set_param([subsystem_name '/Actuator_Dynamics'], 'Position', [70, 50, 100, 70]);
    set_param([subsystem_name '/Actuator_Dynamics'], 'Numerator', '[1]');
    set_param([subsystem_name '/Actuator_Dynamics'], 'Denominator', '[0.1 1]');  % Will be set to [tau 1]
    
    % Add saturation for command limits
    add_block('simulink/Discontinuities/Saturation', [subsystem_name '/Command_Saturation']);
    set_param([subsystem_name '/Command_Saturation'], 'Position', [120, 50, 150, 70]);
    set_param([subsystem_name '/Command_Saturation'], 'UpperLimit', '1.0');
    set_param([subsystem_name '/Command_Saturation'], 'LowerLimit', '0.0');
    
    fprintf('  Actuator dynamics implemented.\n');

end

function implement_thrust_conversion(model_name)
% IMPLEMENT_THRUST_CONVERSION - Implement thrust conversion

    subsystem_name = [model_name '/Actuator'];
    
    % Add gain for thrust conversion
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Thrust_Gain']);
    set_param([subsystem_name '/Thrust_Gain'], 'Position', [170, 50, 200, 70]);
    set_param([subsystem_name '/Thrust_Gain'], 'Gain', '10.0');  % Will be set to thrust_gain
    
    % Add saturation for thrust limits
    add_block('simulink/Discontinuities/Saturation', [subsystem_name '/Thrust_Saturation']);
    set_param([subsystem_name '/Thrust_Saturation'], 'Position', [200, 50, 230, 70]);
    set_param([subsystem_name '/Thrust_Saturation'], 'UpperLimit', '10.0');  % Will be set to max_thrust * thrust_gain
    set_param([subsystem_name '/Thrust_Saturation'], 'LowerLimit', '0.0');
    
    fprintf('  Thrust conversion implemented.\n');

end

function connect_actuator_components(model_name)
% CONNECT_ACTUATOR_COMPONENTS - Connect all actuator components

    subsystem_name = [model_name '/Actuator'];
    
    % Connect thrust command to command saturation
    add_line(subsystem_name, 'Thrust_Command/1', 'Command_Saturation/1');
    
    % Connect command saturation to actuator dynamics
    add_line(subsystem_name, 'Command_Saturation/1', 'Actuator_Dynamics/1');
    
    % Connect actuator dynamics to thrust gain
    add_line(subsystem_name, 'Actuator_Dynamics/1', 'Thrust_Gain/1');
    
    % Connect thrust gain to thrust saturation
    add_line(subsystem_name, 'Thrust_Gain/1', 'Thrust_Saturation/1');
    
    % Connect thrust saturation to output
    add_line(subsystem_name, 'Thrust_Saturation/1', 'Thrust_Force/1');
    
    fprintf('  Actuator components connected.\n');

end
