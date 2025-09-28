function implement_disturbance()
% IMPLEMENT_DISTURBANCE - Implement disturbance generation
%
% This function implements the Disturbance subsystem with:
% - Wind gust generation (step, impulse, white noise)
% - Disturbance selection switch
% - Timing control
%
% Author: Flight Control Verification Project
% Date: 2024

    fprintf('Implementing Disturbance Subsystem...\n');
    
    model_name = 'quad_alt_hold';
    
    % Check if model exists
    if ~exist([model_name '.slx'], 'file')
        error('Model %s.slx not found. Please run setup_phase0.m first.', model_name);
    end
    
    % Open the model
    open_system(model_name);
    
    % Create Disturbance subsystem
    create_disturbance_subsystem(model_name);
    
    % Implement wind gust generation
    implement_wind_gust_generation(model_name);
    
    % Implement disturbance selection
    implement_disturbance_selection(model_name);
    
    % Connect all components
    connect_disturbance_components(model_name);
    
    % Save the model
    save_system(model_name);
    
    fprintf('Disturbance implementation completed.\n');

end

function create_disturbance_subsystem(model_name)
% CREATE_DISTURBANCE_SUBSYSTEM - Create the Disturbance subsystem structure

    subsystem_name = [model_name '/Disturbance'];
    
    % Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', subsystem_name);
    set_param(subsystem_name, 'Name', 'Disturbance');
    set_param(subsystem_name, 'Position', [500, 50, 600, 200]);
    
    % Add output port
    add_block('simulink/Sinks/Out1', [subsystem_name '/Wind_Velocity']);
    set_param([subsystem_name '/Wind_Velocity'], 'Position', [230, 50, 260, 70]);
    
    fprintf('  Disturbance subsystem structure created.\n');

end

function implement_wind_gust_generation(model_name)
% IMPLEMENT_WIND_GUST_GENERATION - Implement various wind gust types

    subsystem_name = [model_name '/Disturbance'];
    
    % Step wind gust
    add_block('simulink/Sources/Step', [subsystem_name '/Step_Gust']);
    set_param([subsystem_name '/Step_Gust'], 'Position', [70, 50, 100, 70]);
    set_param([subsystem_name '/Step_Gust'], 'Time', '5.0');  % Will be set to wind_gust_start_time
    set_param([subsystem_name '/Step_Gust'], 'Before', '0');
    set_param([subsystem_name '/Step_Gust'], 'After', '-2.0');  % Will be set to -wind_gust_magnitude
    
    % Impulse wind gust
    add_block('simulink/Sources/Step', [subsystem_name '/Impulse_Gust']);
    set_param([subsystem_name '/Impulse_Gust'], 'Position', [70, 100, 100, 120]);
    set_param([subsystem_name '/Impulse_Gust'], 'Time', '5.0');  % Will be set to wind_gust_start_time
    set_param([subsystem_name '/Impulse_Gust'], 'Before', '0');
    set_param([subsystem_name '/Impulse_Gust'], 'After', '-1.0');  % Will be set to -wind_gust_magnitude/2
    
    % White noise wind
    add_block('simulink/Sources/Random Number', [subsystem_name '/White_Noise_Wind']);
    set_param([subsystem_name '/White_Noise_Wind'], 'Position', [70, 150, 100, 170]);
    set_param([subsystem_name '/White_Noise_Wind'], 'Mean', '0');
    set_param([subsystem_name '/White_Noise_Wind'], 'Variance', '0.25');  % Will be set to (wind_gust_magnitude/4)^2
    set_param([subsystem_name '/White_Noise_Wind'], 'Seed', '54321');
    set_param([subsystem_name '/White_Noise_Wind'], 'SampleTime', '0.01');
    
    % No disturbance
    add_block('simulink/Sources/Constant', [subsystem_name '/No_Disturbance']);
    set_param([subsystem_name '/No_Disturbance'], 'Position', [70, 200, 100, 220]);
    set_param([subsystem_name '/No_Disturbance'], 'Value', '0');
    
    fprintf('  Wind gust generation implemented.\n');

end

function implement_disturbance_selection(model_name)
% IMPLEMENT_DISTURBANCE_SELECTION - Implement disturbance selection switch

    subsystem_name = [model_name '/Disturbance'];
    
    % Add switch for disturbance selection
    add_block('simulink/Signal Routing/Switch', [subsystem_name '/Disturbance_Switch']);
    set_param([subsystem_name '/Disturbance_Switch'], 'Position', [170, 50, 200, 70]);
    set_param([subsystem_name '/Disturbance_Switch'], 'Inputs', '4');
    
    % Add constant for switch control
    add_block('simulink/Sources/Constant', [subsystem_name '/Switch_Control']);
    set_param([subsystem_name '/Switch_Control'], 'Position', [120, 200, 150, 220]);
    set_param([subsystem_name '/Switch_Control'], 'Value', '1');  % Will be set to disturbance type
    
    fprintf('  Disturbance selection implemented.\n');

end

function connect_disturbance_components(model_name)
% CONNECT_DISTURBANCE_COMPONENTS - Connect all disturbance components

    subsystem_name = [model_name '/Disturbance'];
    
    % Connect all disturbance sources to switch
    add_line(subsystem_name, 'Step_Gust/1', 'Disturbance_Switch/1');
    add_line(subsystem_name, 'Impulse_Gust/1', 'Disturbance_Switch/2');
    add_line(subsystem_name, 'White_Noise_Wind/1', 'Disturbance_Switch/3');
    add_line(subsystem_name, 'No_Disturbance/1', 'Disturbance_Switch/4');
    
    % Connect switch control to switch
    add_line(subsystem_name, 'Switch_Control/1', 'Disturbance_Switch/5');
    
    % Connect switch to output
    add_line(subsystem_name, 'Disturbance_Switch/1', 'Wind_Velocity/1');
    
    fprintf('  Disturbance components connected.\n');

end
