function create_model()
% CREATE_MODEL - Create initial Simulink model structure
%
% This function creates the basic structure for the quad_alt_hold.slx model
% following the specifications in model_specification.md
%
% Author: Flight Control Verification Project
% Date: 2024

    fprintf('Creating Quadcopter Altitude Control Model...\n');
    
    % Check if Simulink is available
    if ~license('test', 'Simulink')
        error('Simulink license not available. Please ensure Simulink is installed.');
    end
    
    % Model name
    model_name = 'quad_alt_hold';
    
    % Check if model already exists
    if exist([model_name '.slx'], 'file')
        fprintf('Model %s.slx already exists. Opening existing model...\n', model_name);
        open_system(model_name);
        return;
    end
    
    % Create new model
    fprintf('Creating new Simulink model: %s\n', model_name);
    new_system(model_name);
    
    % Set model configuration parameters
    configure_model_parameters(model_name);
    
    % Create main subsystems
    create_controller_subsystem(model_name);
    create_actuator_subsystem(model_name);
    create_plant_subsystem(model_name);
    create_sensor_subsystem(model_name);
    create_disturbance_subsystem(model_name);
    
    % Add input and output ports
    add_input_output_ports(model_name);
    
    % Save the model
    save_system(model_name);
    
    fprintf('Model %s.slx created successfully!\n', model_name);
    fprintf('Opening model in Simulink...\n');
    open_system(model_name);
    
    % Display next steps
    fprintf('\nNext Steps:\n');
    fprintf('1. Review the model structure in Simulink\n');
    fprintf('2. Implement detailed subsystem contents\n');
    fprintf('3. Configure parameters and simulation settings\n');
    fprintf('4. Run initial validation tests\n');

end

function configure_model_parameters(model_name)
% CONFIGURE_MODEL_PARAMETERS - Set up model configuration parameters

    % Set solver and simulation parameters
    set_param(model_name, 'Solver', 'ode45');
    set_param(model_name, 'StopTime', '20');
    set_param(model_name, 'MaxStep', '0.001');
    set_param(model_name, 'RelTol', '1e-6');
    set_param(model_name, 'AbsTol', '1e-8');
    
    % Set data import/export
    set_param(model_name, 'SaveOutput', 'on');
    set_param(model_name, 'OutputSaveName', 'yout');
    set_param(model_name, 'SaveState', 'on');
    set_param(model_name, 'StateSaveName', 'xout');
    set_param(model_name, 'SaveTime', 'on');
    set_param(model_name, 'TimeSaveName', 'tout');
    
    fprintf('Model configuration parameters set.\n');

end

function create_controller_subsystem(model_name)
% CREATE_CONTROLLER_SUBSYSTEM - Create PID controller subsystem

    subsystem_name = [model_name '/Controller'];
    
    % Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', subsystem_name);
    
    % Set subsystem name
    set_param(subsystem_name, 'Name', 'Controller');
    
    % Add input ports
    add_block('simulink/Sources/In1', [subsystem_name '/Altitude_Error']);
    add_block('simulink/Sources/In1', [subsystem_name '/Altitude_Command']);
    
    % Add output port
    add_block('simulink/Sinks/Out1', [subsystem_name '/Thrust_Command']);
    
    % Add PID controller block
    add_block('simulink/Continuous/PID Controller', [subsystem_name '/PID_Controller']);
    
    % Configure PID parameters
    set_param([subsystem_name '/PID_Controller'], 'P', '1.0');
    set_param([subsystem_name '/PID_Controller'], 'I', '0.1');
    set_param([subsystem_name '/PID_Controller'], 'D', '0.5');
    
    % Add saturation block
    add_block('simulink/Discontinuities/Saturation', [subsystem_name '/Saturation']);
    set_param([subsystem_name '/Saturation'], 'UpperLimit', '1.0');
    set_param([subsystem_name '/Saturation'], 'LowerLimit', '0.0');
    
    fprintf('Controller subsystem created.\n');

end

function create_actuator_subsystem(model_name)
% CREATE_ACTUATOR_SUBSYSTEM - Create actuator dynamics subsystem

    subsystem_name = [model_name '/Actuator'];
    
    % Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', subsystem_name);
    set_param(subsystem_name, 'Name', 'Actuator');
    
    % Add input and output ports
    add_block('simulink/Sources/In1', [subsystem_name '/Thrust_Command']);
    add_block('simulink/Sinks/Out1', [subsystem_name '/Thrust_Force']);
    
    % Add transfer function for actuator dynamics
    add_block('simulink/Continuous/Transfer Fcn', [subsystem_name '/Actuator_Dynamics']);
    set_param([subsystem_name '/Actuator_Dynamics'], 'Numerator', '[1]');
    set_param([subsystem_name '/Actuator_Dynamics'], 'Denominator', '[0.1 1]');
    
    % Add gain for thrust conversion
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Thrust_Gain']);
    set_param([subsystem_name '/Thrust_Gain'], 'Gain', '10.0');
    
    fprintf('Actuator subsystem created.\n');

end

function create_plant_subsystem(model_name)
% CREATE_PLANT_SUBSYSTEM - Create quadcopter dynamics subsystem

    subsystem_name = [model_name '/Plant'];
    
    % Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', subsystem_name);
    set_param(subsystem_name, 'Name', 'Plant');
    
    % Add input and output ports
    add_block('simulink/Sources/In1', [subsystem_name '/Thrust_Force']);
    add_block('simulink/Sources/In1', [subsystem_name '/Wind_Disturbance']);
    add_block('simulink/Sinks/Out1', [subsystem_name '/Altitude']);
    add_block('simulink/Sinks/Out1', [subsystem_name '/Velocity']);
    
    % Add integrators for dynamics
    add_block('simulink/Continuous/Integrator', [subsystem_name '/Velocity_Integrator']);
    add_block('simulink/Continuous/Integrator', [subsystem_name '/Position_Integrator']);
    
    % Add sum blocks for force balance
    add_block('simulink/Math Operations/Sum', [subsystem_name '/Force_Sum']);
    set_param([subsystem_name '/Force_Sum'], 'Inputs', '+-');
    
    % Add gain blocks
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Mass_Gain']);
    set_param([subsystem_name '/Mass_Gain'], 'Gain', '1.0');
    
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Gravity_Gain']);
    set_param([subsystem_name '/Gravity_Gain'], 'Gain', '-9.81');
    
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Drag_Gain']);
    set_param([subsystem_name '/Drag_Gain'], 'Gain', '-0.1');
    
    fprintf('Plant subsystem created.\n');

end

function create_sensor_subsystem(model_name)
% CREATE_SENSOR_SUBSYSTEM - Create sensor model subsystem

    subsystem_name = [model_name '/Sensor'];
    
    % Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', subsystem_name);
    set_param(subsystem_name, 'Name', 'Sensor');
    
    % Add input and output ports
    add_block('simulink/Sources/In1', [subsystem_name '/True_Altitude']);
    add_block('simulink/Sinks/Out1', [subsystem_name '/Measured_Altitude']);
    
    % Add noise generator
    add_block('simulink/Sources/Random Number', [subsystem_name '/Noise']);
    set_param([subsystem_name '/Noise'], 'Mean', '0');
    set_param([subsystem_name '/Noise'], 'Variance', '0.01');
    set_param([subsystem_name '/Noise'], 'Seed', '12345');
    
    % Add sum for noise addition
    add_block('simulink/Math Operations/Sum', [subsystem_name '/Noise_Sum']);
    
    % Add zero-order hold for sampling
    add_block('simulink/Discrete/Zero-Order Hold', [subsystem_name '/Sample_Hold']);
    set_param([subsystem_name '/Sample_Hold'], 'SampleTime', '0.01');
    
    fprintf('Sensor subsystem created.\n');

end

function create_disturbance_subsystem(model_name)
% CREATE_DISTURBANCE_SUBSYSTEM - Create disturbance generator subsystem

    subsystem_name = [model_name '/Disturbance'];
    
    % Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', subsystem_name);
    set_param(subsystem_name, 'Name', 'Disturbance');
    
    % Add output port
    add_block('simulink/Sinks/Out1', [subsystem_name '/Wind_Velocity']);
    
    % Add step block for wind gust
    add_block('simulink/Sources/Step', [subsystem_name '/Wind_Gust']);
    set_param([subsystem_name '/Wind_Gust'], 'Time', '5');
    set_param([subsystem_name '/Wind_Gust'], 'Before', '0');
    set_param([subsystem_name '/Wind_Gust'], 'After', '-2.0');
    
    % Add switch for disturbance selection
    add_block('simulink/Signal Routing/Switch', [subsystem_name '/Disturbance_Switch']);
    
    % Add constant for no disturbance
    add_block('simulink/Sources/Constant', [subsystem_name '/No_Disturbance']);
    set_param([subsystem_name '/No_Disturbance'], 'Value', '0');
    
    fprintf('Disturbance subsystem created.\n');

end

function add_input_output_ports(model_name)
% ADD_INPUT_OUTPUT_PORTS - Add main input and output ports

    % Add input port for altitude command
    add_block('simulink/Sources/In1', [model_name '/Altitude_Command']);
    set_param([model_name '/Altitude_Command'], 'Position', [50, 100, 80, 120]);
    
    % Add output port for altitude
    add_block('simulink/Sinks/Out1', [model_name '/Altitude_Output']);
    set_param([model_name '/Altitude_Output'], 'Position', [600, 100, 630, 120]);
    
    fprintf('Input and output ports added.\n');

end
