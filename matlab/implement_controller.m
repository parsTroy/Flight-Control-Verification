function implement_controller()
% IMPLEMENT_CONTROLLER - Implement PID controller with anti-windup
%
% This function implements the Controller subsystem with:
% - PID controller with configurable gains
% - Anti-windup logic using back-calculation
% - Output saturation
% - Derivative filtering
%
% Author: Flight Control Verification Project
% Date: 2024

    fprintf('Implementing Controller Subsystem...\n');
    
    model_name = 'quad_alt_hold';
    
    % Check if model exists
    if ~exist([model_name '.slx'], 'file')
        error('Model %s.slx not found. Please run setup_phase0.m first.', model_name);
    end
    
    % Open the model
    open_system(model_name);
    
    % Create Controller subsystem
    create_controller_subsystem(model_name);
    
    % Implement PID controller
    implement_pid_controller(model_name);
    
    % Implement anti-windup
    implement_anti_windup(model_name);
    
    % Implement output saturation
    implement_output_saturation(model_name);
    
    % Connect all components
    connect_controller_components(model_name);
    
    % Save the model
    save_system(model_name);
    
    fprintf('Controller implementation completed.\n');

end

function create_controller_subsystem(model_name)
% CREATE_CONTROLLER_SUBSYSTEM - Create the Controller subsystem structure

    subsystem_name = [model_name '/Controller'];
    
    % Create subsystem
    add_block('simulink/Ports & Subsystems/Subsystem', subsystem_name);
    set_param(subsystem_name, 'Name', 'Controller');
    set_param(subsystem_name, 'Position', [150, 50, 250, 200]);
    
    % Add input ports
    add_block('simulink/Sources/In1', [subsystem_name '/Altitude_Error']);
    set_param([subsystem_name '/Altitude_Error'], 'Position', [20, 50, 50, 70]);
    
    add_block('simulink/Sources/In1', [subsystem_name '/Altitude_Command']);
    set_param([subsystem_name '/Altitude_Command'], 'Position', [20, 100, 50, 120]);
    
    % Add output port
    add_block('simulink/Sinks/Out1', [subsystem_name '/Thrust_Command']);
    set_param([subsystem_name '/Thrust_Command'], 'Position', [180, 75, 210, 95]);
    
    fprintf('  Controller subsystem structure created.\n');

end

function implement_pid_controller(model_name)
% IMPLEMENT_PID_CONTROLLER - Implement PID controller components

    subsystem_name = [model_name '/Controller'];
    
    % Proportional term
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Proportional_Gain']);
    set_param([subsystem_name '/Proportional_Gain'], 'Position', [70, 50, 100, 70]);
    set_param([subsystem_name '/Proportional_Gain'], 'Gain', '1.0');  % Will be set to Kp
    
    % Integral term
    add_block('simulink/Continuous/Integrator', [subsystem_name '/Integral_Integrator']);
    set_param([subsystem_name '/Integral_Integrator'], 'Position', [70, 100, 100, 120]);
    set_param([subsystem_name '/Integral_Integrator'], 'InitialCondition', '0');
    
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Integral_Gain']);
    set_param([subsystem_name '/Integral_Gain'], 'Position', [120, 100, 150, 120]);
    set_param([subsystem_name '/Integral_Gain'], 'Gain', '0.1');  % Will be set to Ki
    
    % Derivative term
    add_block('simulink/Continuous/Derivative', [subsystem_name '/Derivative_Derivative']);
    set_param([subsystem_name '/Derivative_Derivative'], 'Position', [70, 150, 100, 170]);
    set_param([subsystem_name '/Derivative_Derivative'], 'InitialCondition', '0');
    
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Derivative_Gain']);
    set_param([subsystem_name '/Derivative_Gain'], 'Position', [120, 150, 150, 170]);
    set_param([subsystem_name '/Derivative_Gain'], 'Gain', '0.5');  % Will be set to Kd
    
    % Sum for PID terms
    add_block('simulink/Math Operations/Sum', [subsystem_name '/PID_Sum']);
    set_param([subsystem_name '/PID_Sum'], 'Position', [150, 75, 180, 95]);
    set_param([subsystem_name '/PID_Sum'], 'Inputs', '+++');
    
    fprintf('  PID controller implemented.\n');

end

function implement_anti_windup(model_name)
% IMPLEMENT_ANTI_WINDUP - Implement anti-windup using back-calculation

    subsystem_name = [model_name '/Controller'];
    
    % Add saturation block for anti-windup
    add_block('simulink/Discontinuities/Saturation', [subsystem_name '/Anti_Windup_Saturation']);
    set_param([subsystem_name '/Anti_Windup_Saturation'], 'Position', [200, 75, 230, 95]);
    set_param([subsystem_name '/Anti_Windup_Saturation'], 'UpperLimit', '1.0');
    set_param([subsystem_name '/Anti_Windup_Saturation'], 'LowerLimit', '0.0');
    
    % Add gain for anti-windup back-calculation
    add_block('simulink/Math Operations/Gain', [subsystem_name '/Anti_Windup_Gain']);
    set_param([subsystem_name '/Anti_Windup_Gain'], 'Position', [200, 200, 230, 220]);
    set_param([subsystem_name '/Anti_Windup_Gain'], 'Gain', '1.0');  % Will be set to anti-windup gain
    
    % Add sum for back-calculation
    add_block('simulink/Math Operations/Sum', [subsystem_name '/Anti_Windup_Sum']);
    set_param([subsystem_name '/Anti_Windup_Sum'], 'Position', [50, 200, 80, 220]);
    set_param([subsystem_name '/Anti_Windup_Sum'], 'Inputs', '+-');
    
    % Add sum for saturation difference
    add_block('simulink/Math Operations/Sum', [subsystem_name '/Saturation_Diff']);
    set_param([subsystem_name '/Saturation_Diff'], 'Position', [170, 200, 200, 220]);
    set_param([subsystem_name '/Saturation_Diff'], 'Inputs', '+-');
    
    fprintf('  Anti-windup implemented.\n');

end

function implement_output_saturation(model_name)
% IMPLEMENT_OUTPUT_SATURATION - Implement output saturation

    subsystem_name = [model_name '/Controller'];
    
    % Add final saturation block
    add_block('simulink/Discontinuities/Saturation', [subsystem_name '/Output_Saturation']);
    set_param([subsystem_name '/Output_Saturation'], 'Position', [250, 75, 280, 95]);
    set_param([subsystem_name '/Output_Saturation'], 'UpperLimit', '1.0');
    set_param([subsystem_name '/Output_Saturation'], 'LowerLimit', '0.0');
    
    fprintf('  Output saturation implemented.\n');

end

function connect_controller_components(model_name)
% CONNECT_CONTROLLER_COMPONENTS - Connect all controller components

    subsystem_name = [model_name '/Controller'];
    
    % Connect altitude error to all PID terms
    add_line(subsystem_name, 'Altitude_Error/1', 'Proportional_Gain/1');
    add_line(subsystem_name, 'Altitude_Error/1', 'Anti_Windup_Sum/1');
    add_line(subsystem_name, 'Altitude_Error/1', 'Derivative_Derivative/1');
    
    % Connect anti-windup sum to integral integrator
    add_line(subsystem_name, 'Anti_Windup_Sum/1', 'Integral_Integrator/1');
    
    % Connect integral integrator to integral gain
    add_line(subsystem_name, 'Integral_Integrator/1', 'Integral_Gain/1');
    
    % Connect derivative derivative to derivative gain
    add_line(subsystem_name, 'Derivative_Derivative/1', 'Derivative_Gain/1');
    
    % Connect all PID terms to PID sum
    add_line(subsystem_name, 'Proportional_Gain/1', 'PID_Sum/1');
    add_line(subsystem_name, 'Integral_Gain/1', 'PID_Sum/2');
    add_line(subsystem_name, 'Derivative_Gain/1', 'PID_Sum/3');
    
    % Connect PID sum to anti-windup saturation
    add_line(subsystem_name, 'PID_Sum/1', 'Anti_Windup_Saturation/1');
    
    % Connect anti-windup saturation to output saturation
    add_line(subsystem_name, 'Anti_Windup_Saturation/1', 'Output_Saturation/1');
    
    % Connect output saturation to output
    add_line(subsystem_name, 'Output_Saturation/1', 'Thrust_Command/1');
    
    % Anti-windup connections
    add_line(subsystem_name, 'PID_Sum/1', 'Saturation_Diff/1');
    add_line(subsystem_name, 'Anti_Windup_Saturation/1', 'Saturation_Diff/2');
    add_line(subsystem_name, 'Saturation_Diff/1', 'Anti_Windup_Gain/1');
    add_line(subsystem_name, 'Anti_Windup_Gain/1', 'Anti_Windup_Sum/2');
    
    fprintf('  Controller components connected.\n');

end
