function utils()
% UTILS - Utility functions for Flight Control Verification Project
%
% This file contains helper functions for the quadcopter altitude control
% simulation project. Functions include plotting utilities, data processing,
% and common calculations.
%
% Author: Flight Control Verification Project
% Date: 2024

    fprintf('Flight Control Verification - Utility Functions\n');
    fprintf('Available functions:\n');
    fprintf('  - plot_altitude_response()\n');
    fprintf('  - calculate_performance_metrics()\n');
    fprintf('  - generate_test_report()\n');
    fprintf('  - setup_simulation_parameters()\n');

end

function plot_altitude_response(time, altitude, command, title_str)
% PLOT_ALTITUDE_RESPONSE - Plot altitude response vs command
%
% Inputs:
%   time     - Time vector (s)
%   altitude - Actual altitude (m)
%   command  - Commanded altitude (m)
%   title_str - Plot title string

    figure('Name', 'Altitude Response', 'NumberTitle', 'off');
    
    plot(time, altitude, 'b-', 'LineWidth', 2, 'DisplayName', 'Actual Altitude');
    hold on;
    plot(time, command, 'r--', 'LineWidth', 2, 'DisplayName', 'Commanded Altitude');
    
    xlabel('Time (s)');
    ylabel('Altitude (m)');
    title(title_str);
    legend('Location', 'best');
    grid on;
    
    % Add performance metrics
    error = altitude - command;
    max_error = max(abs(error));
    settling_time = calculate_settling_time(time, error, 0.05); % 5% tolerance
    
    text(0.02, 0.98, sprintf('Max Error: %.3f m\nSettling Time: %.2f s', ...
         max_error, settling_time), 'Units', 'normalized', ...
         'VerticalAlignment', 'top', 'BackgroundColor', 'white');
end

function settling_time = calculate_settling_time(time, error, tolerance)
% CALCULATE_SETTLING_TIME - Calculate 2% settling time
%
% Inputs:
%   time      - Time vector
%   error     - Error signal
%   tolerance - Settling tolerance (e.g., 0.02 for 2%)
%
% Output:
%   settling_time - Time to settle within tolerance

    final_value = error(end);
    tolerance_band = abs(final_value) * tolerance;
    
    % Find last time error exceeds tolerance
    exceeds_tolerance = abs(error) > tolerance_band;
    if any(exceeds_tolerance)
        last_exceed_idx = find(exceeds_tolerance, 1, 'last');
        settling_time = time(last_exceed_idx);
    else
        settling_time = 0; % Already settled
    end
end

function metrics = calculate_performance_metrics(time, altitude, command, thrust)
% CALCULATE_PERFORMANCE_METRICS - Calculate key performance metrics
%
% Inputs:
%   time     - Time vector (s)
%   altitude - Actual altitude (m)
%   command  - Commanded altitude (m)
%   thrust   - Thrust command (0-1)
%
% Output:
%   metrics - Structure containing performance metrics

    error = altitude - command;
    
    metrics.max_error = max(abs(error));
    metrics.rms_error = rms(error);
    metrics.steady_state_error = abs(error(end));
    metrics.settling_time_2pct = calculate_settling_time(time, error, 0.02);
    metrics.settling_time_5pct = calculate_settling_time(time, error, 0.05);
    metrics.max_thrust = max(thrust);
    metrics.min_thrust = min(thrust);
    metrics.thrust_variation = metrics.max_thrust - metrics.min_thrust;
    
    % Overshoot calculation
    if command(end) > command(1) % Step up
        overshoot = max(altitude) - command(end);
        metrics.overshoot_percent = (overshoot / command(end)) * 100;
    else
        metrics.overshoot_percent = 0;
    end
end

function generate_test_report(test_results, filename)
% GENERATE_TEST_REPORT - Generate test results report
%
% Inputs:
%   test_results - Structure containing test results
%   filename     - Output filename (optional)

    if nargin < 2
        filename = 'test_report.txt';
    end
    
    fid = fopen(filename, 'w');
    
    fprintf(fid, 'FLIGHT CONTROL VERIFICATION - TEST REPORT\n');
    fprintf(fid, '==========================================\n\n');
    fprintf(fid, 'Generated: %s\n\n', datestr(now));
    
    % Test summary
    fprintf(fid, 'TEST SUMMARY\n');
    fprintf(fid, '------------\n');
    fprintf(fid, 'Total Tests: %d\n', length(test_results));
    fprintf(fid, 'Passed: %d\n', sum([test_results.passed]));
    fprintf(fid, 'Failed: %d\n', sum(~[test_results.passed]));
    fprintf(fid, '\n');
    
    % Individual test results
    for i = 1:length(test_results)
        fprintf(fid, 'Test %d: %s\n', i, test_results(i).name);
        fprintf(fid, '  Status: %s\n', test_results(i).passed ? 'PASS' : 'FAIL');
        fprintf(fid, '  Max Error: %.3f m\n', test_results(i).max_error);
        fprintf(fid, '  Settling Time: %.2f s\n', test_results(i).settling_time);
        fprintf(fid, '\n');
    end
    
    fclose(fid);
    fprintf('Test report saved to: %s\n', filename);
end

function params = setup_simulation_parameters()
% SETUP_SIMULATION_PARAMETERS - Set up default simulation parameters
%
% Output:
%   params - Structure containing simulation parameters

    % Quadcopter physical parameters
    params.mass = 1.0;              % kg
    params.gravity = 9.81;          % m/s^2
    params.thrust_gain = 10.0;      % N per unit command
    params.drag_coefficient = 0.1;  % Ns/m
    
    % Actuator dynamics
    params.actuator_time_constant = 0.1;  % s
    params.max_thrust = 1.0;              % normalized
    params.min_thrust = 0.0;              % normalized
    
    % Sensor parameters
    params.sensor_noise_variance = 0.01;  % m^2
    params.sensor_sample_time = 0.01;     % s
    
    % Controller parameters (will be tuned)
    params.kp = 1.0;    % Proportional gain
    params.ki = 0.1;    % Integral gain
    params.kd = 0.5;    % Derivative gain
    
    % Simulation parameters
    params.simulation_time = 20.0;  % s
    params.time_step = 0.001;       % s
    
    % Test parameters
    params.step_command = 5.0;      % m
    params.wind_gust_magnitude = 2.0;  % m/s
    params.monte_carlo_runs = 100;
end
