function implement_plant_dynamics()
% IMPLEMENT_PLANT_DYNAMICS - Implement quadcopter vertical dynamics
%
% This function implements the Plant subsystem with:
% - Vertical dynamics: m*ẍ = T - m*g - D(ẋ)
% - Gravity compensation
% - Drag modeling
% - Force balance equations
%
% Author: Flight Control Verification Project
% Date: 2024

    fprintf('Implementing Plant Dynamics Subsystem...\n');
    
    model_name = 'quad_alt_hold';
    
    % Check if model exists
    if ~exist([model_name '.slx'], 'file')
        error('Model %s.slx not found. Please run setup_phase0.m first.', model_name);
    end
    
    % Open the model
    open_system(model_name);
    
    % Create Plant subsystem
    create_plant_subsystem(model_name);
    
    % Implement vertical dynamics
    implement_vertical_dynamics(model_name);
    
    % Implement gravity compensation
    implement_gravity_compensation(model_name);
    
    % Implement drag model
    implement_drag_model(model_name);
    
    % Connect all components
    connect_plant_components(model_name);
    
    % Save the model
    save_system(model_name);
    
    fprintf('Plant dynamics implementation completed.\n');

end

function create_plant_subsystem(model_name)
% CREATE_PLANT_SUBSYSTEM - Create the Plant subsystem structure

    subsystem_name = [model_name '/Plant'];
    
    % Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', subsystem_name);
    set_param(subsystem_name, 'Name', 'Plant');
    set_param(subsystem_name, 'Position', [300, 50, 400, 200]);
    
    % Add input ports
    add_block('simulink/Sources/In1', [subsystem_name '/Thrust_Force']);
    set_param([subsystem_name '/Thrust_Force'], 'Position', [20, 50, 50, 70]);
    
    add_block('simulink/Sources/In1', [subsystem_name '/Wind_Disturbance']);
    set_param([subsystem_name '/Wind_Disturbance'], 'Position', [20, 100, 50, 120]);
    
    % Add output ports
    add_block('simulink/Sinks/Out1', [subsystem_name '/Altitude']);
    set_param([subsystem_name '/Altitude'], 'Position', [350, 50, 380, 70]);
    
    add_block('simulink/Sinks/Out1', [subsystem_name '/Velocity']);
    set_param([subsystem_name '/Velocity'], 'Position', [350, 100, 380, 120]);
    
    add_block('simulink/Sinks/Out1', [subsystem_name '/Acceleration']);
    set_param([subsystem_name '/Acceleration'], 'Position', [350, 150, 380, 170]);
    
    fprintf('  Plant subsystem structure created.\n');

end

function implement_vertical_dynamics(model_name)
% IMPLEMENT_VERTICAL_DYNAMICS - Implement the core vertical dynamics

    subsystem_name = [model_name '/Plant'];
    
    % Add integrators for velocity and position
    add_block('simulink/Continuous/Integrator', [subsystem_name '/Velocity_Integrator']);
    set_param([subsystem_name '/Velocity_Integrator'], 'Position', [200, 100, 230, 120]);
    set_param([subsystem_name '/Velocity_Integrator'], 'InitialCondition', '0');
    
    add_block('simulink/Continuous/Integrator', [subsystem_name '/Position_Integrator']);
    set_param([subsystem_name '/Position_Integrator'], 'Position', [200, 50, 230, 70]);
    set_param([subsystem_name '/Position_Integrator'], 'InitialCondition', '0');
    
    % Add gain for mass (1/m)
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Mass_Gain']);
    set_param([subsystem_name '/Mass_Gain'], 'Position', [150, 150, 180, 170]);
    set_param([subsystem_name '/Mass_Gain'], 'Gain', '1.0');  % Will be set to 1/mass
    
    % Add sum block for force balance
    add_block('simulink/Math Operations/Sum', [subsystem_name '/Force_Sum']);
    set_param([subsystem_name '/Force_Sum'], 'Position', [100, 150, 130, 170]);
    set_param([subsystem_name '/Force_Sum'], 'Inputs', '+-+');
    
    fprintf('  Vertical dynamics implemented.\n');

end

function implement_gravity_compensation(model_name)
% IMPLEMENT_GRAVITY_COMPENSATION - Implement gravity force

    subsystem_name = [model_name '/Plant'];
    
    % Add constant for gravity
    add_block('simulink/Sources/Constant', [subsystem_name '/Gravity_Constant']);
    set_param([subsystem_name '/Gravity_Constant'], 'Position', [50, 200, 80, 220]);
    set_param([subsystem_name '/Gravity_Constant'], 'Value', '-9.81');
    
    % Add gain for mass * gravity
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Gravity_Gain']);
    set_param([subsystem_name '/Gravity_Gain'], 'Position', [100, 200, 130, 220]);
    set_param([subsystem_name '/Gravity_Gain'], 'Gain', '1.0');  % Will be set to mass
    
    fprintf('  Gravity compensation implemented.\n');

end

function implement_drag_model(model_name)
% IMPLEMENT_DRAG_MODEL - Implement linear drag model

    subsystem_name = [model_name '/Plant'];
    
    % Add gain for drag coefficient
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Drag_Gain']);
    set_param([subsystem_name '/Drag_Gain'], 'Position', [100, 250, 130, 270]);
    set_param([subsystem_name '/Drag_Gain'], 'Gain', '-0.1');  % Will be set to -drag_coefficient
    
    % Add sum for wind effect
    add_block('simulink/Math Operations/Sum', [subsystem_name '/Wind_Sum']);
    set_param([subsystem_name '/Wind_Sum'], 'Position', [50, 250, 80, 270]);
    set_param([subsystem_name '/Wind_Sum'], 'Inputs', '+-');
    
    fprintf('  Drag model implemented.\n');

end

function connect_plant_components(model_name)
% CONNECT_PLANT_COMPONENTS - Connect all plant components

    subsystem_name = [model_name '/Plant'];
    
    % Connect thrust force to force sum
    add_line(subsystem_name, 'Thrust_Force/1', 'Force_Sum/1');
    
    % Connect gravity to force sum
    add_line(subsystem_name, 'Gravity_Constant/1', 'Gravity_Gain/1');
    add_line(subsystem_name, 'Gravity_Gain/1', 'Force_Sum/2');
    
    % Connect wind disturbance to wind sum
    add_line(subsystem_name, 'Wind_Disturbance/1', 'Wind_Sum/1');
    
    % Connect velocity to wind sum
    add_line(subsystem_name, 'Velocity_Integrator/1', 'Wind_Sum/2');
    
    % Connect wind sum to drag gain
    add_line(subsystem_name, 'Wind_Sum/1', 'Drag_Gain/1');
    
    % Connect drag to force sum
    add_line(subsystem_name, 'Drag_Gain/1', 'Force_Sum/3');
    
    % Connect force sum to mass gain
    add_line(subsystem_name, 'Force_Sum/1', 'Mass_Gain/1');
    
    % Connect mass gain to velocity integrator
    add_line(subsystem_name, 'Mass_Gain/1', 'Velocity_Integrator/1');
    
    % Connect velocity integrator to position integrator
    add_line(subsystem_name, 'Velocity_Integrator/1', 'Position_Integrator/1');
    
    % Connect outputs
    add_line(subsystem_name, 'Position_Integrator/1', 'Altitude/1');
    add_line(subsystem_name, 'Velocity_Integrator/1', 'Velocity/1');
    add_line(subsystem_name, 'Mass_Gain/1', 'Acceleration/1');
    
    fprintf('  Plant components connected.\n');

end
