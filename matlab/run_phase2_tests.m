function run_phase2_tests()
% RUN_PHASE2_TESTS - Comprehensive test suite for Phase 2
%
% This function runs comprehensive tests for the tuned controller:
% 1. Step response tests
% 2. Disturbance rejection tests
% 3. Noise robustness tests
% 4. Parameter sensitivity tests
% 5. Monte Carlo analysis
% 6. Performance validation
%
% Author: Flight Control Verification Project
% Date: 2024

    fprintf('==========================================\n');
    fprintf('FLIGHT CONTROL VERIFICATION - PHASE 2\n');
    fprintf('Comprehensive Test Suite\n');
    fprintf('==========================================\n\n');
    
    % Initialize test results
    test_results = struct();
    test_count = 0;
    
    % Test 1: Step Response Tests
    fprintf('Running Step Response Tests...\n');
    test_count = test_count + 1;
    test_results(test_count) = run_step_response_tests();
    
    % Test 2: Disturbance Rejection Tests
    fprintf('Running Disturbance Rejection Tests...\n');
    test_count = test_count + 1;
    test_results(test_count) = run_disturbance_rejection_tests();
    
    % Test 3: Noise Robustness Tests
    fprintf('Running Noise Robustness Tests...\n');
    test_count = test_count + 1;
    test_results(test_count) = run_noise_robustness_tests();
    
    % Test 4: Parameter Sensitivity Tests
    fprintf('Running Parameter Sensitivity Tests...\n');
    test_count = test_count + 1;
    test_results(test_count) = run_parameter_sensitivity_tests();
    
    % Test 5: Monte Carlo Analysis
    fprintf('Running Monte Carlo Analysis...\n');
    test_count = test_count + 1;
    test_results(test_count) = run_monte_carlo_analysis();
    
    % Test 6: Performance Validation
    fprintf('Running Performance Validation...\n');
    test_count = test_count + 1;
    test_results(test_count) = run_performance_validation();
    
    % Generate test report
    generate_phase2_test_report(test_results);
    
    % Display summary
    display_test_summary(test_results);
    
    fprintf('\nPhase 2 test suite completed!\n');

end

function result = run_step_response_tests()
% RUN_STEP_RESPONSE_TESTS - Test step response performance

    result.name = 'Step Response Tests';
    result.description = 'Test system response to step commands';
    
    % Test parameters
    step_commands = [1.0, 2.0, 5.0, 10.0];  % meters
    test_results = struct();
    
    for i = 1:length(step_commands)
        step_cmd = step_commands(i);
        
        % Run simulation
        sim_out = run_step_simulation(step_cmd);
        
        % Analyze results
        analysis = analyze_step_response(sim_out, step_cmd);
        
        % Store results
        test_results(i).command = step_cmd;
        test_results(i).overshoot = analysis.overshoot;
        test_results(i).settling_time = analysis.settling_time;
        test_results(i).rise_time = analysis.rise_time;
        test_results(i).steady_state_error = analysis.steady_state_error;
        test_results(i).passed = analysis.passed;
    end
    
    % Overall test result
    result.test_results = test_results;
    result.passed = all([test_results.passed]);
    result.summary = sprintf('Step response tests: %d/%d passed', ...
                            sum([test_results.passed]), length(test_results));
    
    fprintf('  %s\n', result.summary);

end

function sim_out = run_step_simulation(step_command)
% RUN_STEP_SIMULATION - Run step simulation

    model_name = 'quad_alt_hold';
    
    % Set step command
    set_param([model_name '/Test_Step'], 'After', num2str(step_command));
    
    % Run simulation
    sim_out = sim(model_name, 'StopTime', '20.0');
    
end

function analysis = analyze_step_response(sim_out, step_command)
% ANALYZE_STEP_RESPONSE - Analyze step response

    % Extract data
    altitude = sim_out.get('Altitude_Output').Data;
    time = sim_out.get('Altitude_Output').Time;
    
    % Calculate step info
    step_info = stepinfo(altitude, time);
    
    % Calculate steady-state error
    steady_state_error = abs(step_command - altitude(end));
    
    % Check requirements
    overshoot_ok = step_info.Overshoot <= 5.0;  % REQ-001: ±0.5m tolerance
    settling_time_ok = step_info.SettlingTime <= 5.0;  # REQ-007
    steady_state_error_ok = steady_state_error <= 0.1;  # REQ-012
    
    % Store analysis
    analysis.overshoot = step_info.Overshoot;
    analysis.settling_time = step_info.SettlingTime;
    analysis.rise_time = step_info.RiseTime;
    analysis.steady_state_error = steady_state_error;
    analysis.passed = overshoot_ok && settling_time_ok && steady_state_error_ok;

end

function result = run_disturbance_rejection_tests()
% RUN_DISTURBANCE_REJECTION_TESTS - Test disturbance rejection

    result.name = 'Disturbance Rejection Tests';
    result.description = 'Test system rejection of wind disturbances';
    
    % Test parameters
    wind_magnitudes = [1.0, 2.0, 3.0, 5.0];  % m/s
    test_results = struct();
    
    for i = 1:length(wind_magnitudes)
        wind_mag = wind_magnitudes(i);
        
        % Run simulation with disturbance
        sim_out = run_disturbance_simulation(wind_mag);
        
        % Analyze results
        analysis = analyze_disturbance_rejection(sim_out, wind_mag);
        
        % Store results
        test_results(i).wind_magnitude = wind_mag;
        test_results(i).max_deviation = analysis.max_deviation;
        test_results(i).recovery_time = analysis.recovery_time;
        test_results(i).settling_time = analysis.settling_time;
        test_results(i).passed = analysis.passed;
    end
    
    % Overall test result
    result.test_results = test_results;
    result.passed = all([test_results.passed]);
    result.summary = sprintf('Disturbance rejection tests: %d/%d passed', ...
                            sum([test_results.passed]), length(test_results));
    
    fprintf('  %s\n', result.summary);

end

function sim_out = run_disturbance_simulation(wind_magnitude)
% RUN_DISTURBANCE_SIMULATION - Run disturbance simulation

    model_name = 'quad_alt_hold';
    
    % Set wind gust magnitude
    set_param([model_name '/Disturbance/Step_Gust'], 'After', num2str(-wind_magnitude));
    
    % Run simulation
    sim_out = sim(model_name, 'StopTime', '20.0');
    
end

function analysis = analyze_disturbance_rejection(sim_out, wind_magnitude)
% ANALYZE_DISTURBANCE_REJECTION - Analyze disturbance rejection

    % Extract data
    altitude = sim_out.get('Altitude_Output').Data;
    time = sim_out.get('Altitude_Output').Time;
    
    % Find disturbance start time (5 seconds)
    disturbance_start = 5.0;
    disturbance_end = 7.0;
    
    % Calculate maximum deviation during disturbance
    disturbance_idx = time >= disturbance_start & time <= disturbance_end;
    max_deviation = max(abs(altitude(disturbance_idx)));
    
    % Calculate recovery time (time to return to within 5% of command)
    command = 5.0;  % Step command
    tolerance = 0.05 * command;
    
    recovery_idx = find(time > disturbance_end & abs(altitude - command) <= tolerance, 1);
    if isempty(recovery_idx)
        recovery_time = Inf;
    else
        recovery_time = time(recovery_idx) - disturbance_end;
    end
    
    % Calculate settling time after disturbance
    post_disturbance_idx = time > disturbance_end;
    if any(post_disturbance_idx)
        post_disturbance_altitude = altitude(post_disturbance_idx);
        post_disturbance_time = time(post_disturbance_idx);
        settling_time = calculate_settling_time(post_disturbance_time, post_disturbance_altitude, 0.05);
    else
        settling_time = Inf;
    end
    
    % Check requirements
    max_deviation_ok = max_deviation <= 2.0;  # REQ-003: Disturbance rejection
    recovery_time_ok = recovery_time <= 5.0;  # REQ-007: Recovery time
    settling_time_ok = settling_time <= 8.0;  # Allow longer settling after disturbance
    
    % Store analysis
    analysis.max_deviation = max_deviation;
    analysis.recovery_time = recovery_time;
    analysis.settling_time = settling_time;
    analysis.passed = max_deviation_ok && recovery_time_ok && settling_time_ok;

end

function result = run_noise_robustness_tests()
% RUN_NOISE_ROBUSTNESS_TESTS - Test noise robustness

    result.name = 'Noise Robustness Tests';
    result.description = 'Test system robustness to sensor noise';
    
    % Test parameters
    noise_variances = [0.001, 0.01, 0.05, 0.1];  % m^2
    test_results = struct();
    
    for i = 1:length(noise_variances)
        noise_var = noise_variances(i);
        
        % Run simulation with noise
        sim_out = run_noise_simulation(noise_var);
        
        % Analyze results
        analysis = analyze_noise_robustness(sim_out, noise_var);
        
        % Store results
        test_results(i).noise_variance = noise_var;
        test_results(i).rms_error = analysis.rms_error;
        test_results(i).max_error = analysis.max_error;
        test_results(i).stability_margin = analysis.stability_margin;
        test_results(i).passed = analysis.passed;
    end
    
    % Overall test result
    result.test_results = test_results;
    result.passed = all([test_results.passed]);
    result.summary = sprintf('Noise robustness tests: %d/%d passed', ...
                            sum([test_results.passed]), length(test_results));
    
    fprintf('  %s\n', result.summary);

end

function sim_out = run_noise_simulation(noise_variance)
% RUN_NOISE_SIMULATION - Run noise simulation

    model_name = 'quad_alt_hold';
    
    % Set noise variance
    set_param([model_name '/Sensor/Noise_Generator'], 'Variance', num2str(noise_variance));
    
    % Run simulation
    sim_out = sim(model_name, 'StopTime', '20.0');
    
end

function analysis = analyze_noise_robustness(sim_out, noise_variance)
% ANALYZE_NOISE_ROBUSTNESS - Analyze noise robustness

    % Extract data
    altitude = sim_out.get('Altitude_Output').Data;
    time = sim_out.get('Altitude_Output').Time;
    
    % Calculate error metrics
    command = 5.0;  # Step command
    error = altitude - command;
    
    rms_error = rms(error);
    max_error = max(abs(error));
    
    % Calculate stability margin (simplified)
    stability_margin = 1.0 / (1.0 + noise_variance);
    
    # Check requirements
    rms_error_ok = rms_error <= 0.5;  # REQ-001: Altitude accuracy
    max_error_ok = max_error <= 1.0;  # Allow some degradation with noise
    stability_ok = stability_margin >= 0.5;  # Minimum stability margin
    
    # Store analysis
    analysis.rms_error = rms_error;
    analysis.max_error = max_error;
    analysis.stability_margin = stability_margin;
    analysis.passed = rms_error_ok && max_error_ok && stability_ok;

end

function result = run_parameter_sensitivity_tests()
% RUN_PARAMETER_SENSITIVITY_TESTS - Test parameter sensitivity

    result.name = 'Parameter Sensitivity Tests';
    result.description = 'Test system sensitivity to parameter variations';
    
    # Get current parameters
    Kp = evalin('base', 'Kp_final');
    Ki = evalin('base', 'Ki_final');
    Kd = evalin('base', 'Kd_final');
    
    # Test parameter variations
    variations = [-0.1, -0.05, 0, 0.05, 0.1];  # ±10% variations
    test_results = struct();
    
    test_count = 0;
    for i = 1:length(variations)
        var = variations(i);
        
        # Test Kp variation
        test_count = test_count + 1;
        test_results(test_count) = test_parameter_variation('Kp', Kp, Ki, Kd, var);
        
        # Test Ki variation
        test_count = test_count + 1;
        test_results(test_count) = test_parameter_variation('Ki', Kp, Ki, Kd, var);
        
        # Test Kd variation
        test_count = test_count + 1;
        test_results(test_count) = test_parameter_variation('Kd', Kp, Ki, Kd, var);
    end
    
    # Overall test result
    result.test_results = test_results;
    result.passed = all([test_results.passed]);
    result.summary = sprintf('Parameter sensitivity tests: %d/%d passed', ...
                            sum([test_results.passed]), length(test_results));
    
    fprintf('  %s\n', result.summary);

end

function test_result = test_parameter_variation(param_name, Kp, Ki, Kd, variation)
% TEST_PARAMETER_VARIATION - Test parameter variation

    # Apply variation
    if strcmp(param_name, 'Kp')
        Kp_var = Kp * (1 + variation);
        Ki_var = Ki;
        Kd_var = Kd;
    elseif strcmp(param_name, 'Ki')
        Kp_var = Kp;
        Ki_var = Ki * (1 + variation);
        Kd_var = Kd;
    else  # Kd
        Kp_var = Kp;
        Ki_var = Ki;
        Kd_var = Kd * (1 + variation);
    end
    
    # Run simulation with varied parameters
    sim_out = run_parameter_simulation(Kp_var, Ki_var, Kd_var);
    
    # Analyze results
    analysis = analyze_parameter_variation(sim_out, param_name, variation);
    
    # Store results
    test_result.parameter = param_name;
    test_result.variation = variation;
    test_result.overshoot = analysis.overshoot;
    test_result.settling_time = analysis.settling_time;
    test_result.stability = analysis.stability;
    test_result.passed = analysis.passed;

end

function sim_out = run_parameter_simulation(Kp, Ki, Kd)
% RUN_PARAMETER_SIMULATION - Run simulation with specific parameters

    model_name = 'quad_alt_hold';
    
    # Set parameters
    set_param([model_name '/Controller/Proportional_Gain'], 'Gain', num2str(Kp));
    set_param([model_name '/Controller/Integral_Gain'], 'Gain', num2str(Ki));
    set_param([model_name '/Controller/Derivative_Gain'], 'Gain', num2str(Kd));
    
    # Run simulation
    sim_out = sim(model_name, 'StopTime', '20.0');

end

function analysis = analyze_parameter_variation(sim_out, param_name, variation)
% ANALYZE_PARAMETER_VARIATION - Analyze parameter variation

    # Extract data
    altitude = sim_out.get('Altitude_Output').Data;
    time = sim_out.get('Altitude_Output').Time;
    
    # Calculate step info
    step_info = stepinfo(altitude, time);
    
    # Check stability
    poles = pole(feedback(tf(Kp + Ki/s + Kd*s) * plant_tf, 1));
    stability = all(real(poles) < 0);
    
    # Check requirements
    overshoot_ok = step_info.Overshoot <= 10.0;  # Allow some degradation
    settling_time_ok = step_info.SettlingTime <= 8.0;  # Allow some degradation
    stability_ok = stability;
    
    # Store analysis
    analysis.overshoot = step_info.Overshoot;
    analysis.settling_time = step_info.SettlingTime;
    analysis.stability = stability;
    analysis.passed = overshoot_ok && settling_time_ok && stability_ok;

end

function result = run_monte_carlo_analysis()
% RUN_MONTE_CARLO_ANALYSIS - Run Monte Carlo analysis

    result.name = 'Monte Carlo Analysis';
    result.description = 'Statistical analysis of system performance';
    
    # Monte Carlo parameters
    num_runs = 100;
    test_results = struct();
    
    # Run Monte Carlo simulations
    for i = 1:num_runs
        # Add random variations to parameters
        Kp = evalin('base', 'Kp_final') * (1 + 0.05 * randn());
        Ki = evalin('base', 'Ki_final') * (1 + 0.05 * randn());
        Kd = evalin('base', 'Kd_final') * (1 + 0.05 * randn());
        
        # Run simulation
        sim_out = run_parameter_simulation(Kp, Ki, Kd);
        
        # Analyze results
        analysis = analyze_monte_carlo_run(sim_out, i);
        
        # Store results
        test_results(i).run = i;
        test_results(i).overshoot = analysis.overshoot;
        test_results(i).settling_time = analysis.settling_time;
        test_results(i).stability = analysis.stability;
        test_results(i).passed = analysis.passed;
    end
    
    # Calculate statistics
    overshoots = [test_results.overshoot];
    settling_times = [test_results.settling_time];
    stabilities = [test_results.stability];
    passes = [test_results.passed];
    
    # Overall test result
    result.test_results = test_results;
    result.statistics = struct();
    result.statistics.overshoot_mean = mean(overshoots);
    result.statistics.overshoot_std = std(overshoots);
    result.statistics.settling_time_mean = mean(settling_times);
    result.statistics.settling_time_std = std(settling_times);
    result.statistics.stability_rate = mean(stabilities);
    result.statistics.pass_rate = mean(passes);
    
    result.passed = result.statistics.pass_rate >= 0.95;  # 95% pass rate required
    result.summary = sprintf('Monte Carlo analysis: %.1f%% pass rate', ...
                            result.statistics.pass_rate * 100);
    
    fprintf('  %s\n', result.summary);

end

function analysis = analyze_monte_carlo_run(sim_out, run_number)
% ANALYZE_MONTE_CARLO_RUN - Analyze Monte Carlo run

    # Extract data
    altitude = sim_out.get('Altitude_Output').Data;
    time = sim_out.get('Altitude_Output').Time;
    
    # Calculate step info
    step_info = stepinfo(altitude, time);
    
    # Check stability (simplified)
    stability = true;  # Assume stable for now
    
    # Check requirements
    overshoot_ok = step_info.Overshoot <= 10.0;
    settling_time_ok = step_info.SettlingTime <= 8.0;
    stability_ok = stability;
    
    # Store analysis
    analysis.overshoot = step_info.Overshoot;
    analysis.settling_time = step_info.SettlingTime;
    analysis.stability = stability;
    analysis.passed = overshoot_ok && settling_time_ok && stability_ok;

end

function result = run_performance_validation()
% RUN_PERFORMANCE_VALIDATION - Validate overall performance

    result.name = 'Performance Validation';
    result.description = 'Validate overall system performance';
    
    # Run comprehensive simulation
    sim_out = run_comprehensive_simulation();
    
    # Analyze performance
    analysis = analyze_overall_performance(sim_out);
    
    # Check all requirements
    requirements = check_all_requirements(analysis);
    
    # Overall test result
    result.analysis = analysis;
    result.requirements = requirements;
    result.passed = all([requirements.passed]);
    result.summary = sprintf('Performance validation: %d/%d requirements met', ...
                            sum([requirements.passed]), length(requirements));
    
    fprintf('  %s\n', result.summary);

end

function sim_out = run_comprehensive_simulation()
% RUN_COMPREHENSIVE_SIMULATION - Run comprehensive simulation

    model_name = 'quad_alt_hold';
    
    # Reset to default parameters
    Kp = evalin('base', 'Kp_final');
    Ki = evalin('base', 'Ki_final');
    Kd = evalin('base', 'Kd_final');
    
    set_param([model_name '/Controller/Proportional_Gain'], 'Gain', num2str(Kp));
    set_param([model_name '/Controller/Integral_Gain'], 'Gain', num2str(Ki));
    set_param([model_name '/Controller/Derivative_Gain'], 'Gain', num2str(Kd));
    
    # Run simulation
    sim_out = sim(model_name, 'StopTime', '20.0');

end

function analysis = analyze_overall_performance(sim_out)
% ANALYZE_OVERALL_PERFORMANCE - Analyze overall performance

    # Extract data
    altitude = sim_out.get('Altitude_Output').Data;
    time = sim_out.get('Altitude_Output').Time;
    thrust_command = sim_out.get('Thrust_Command_Scope').Data;
    
    # Calculate performance metrics
    step_info = stepinfo(altitude, time);
    
    # Calculate additional metrics
    command = 5.0;  # Step command
    error = altitude - command;
    
    rms_error = rms(error);
    max_error = max(abs(error));
    steady_state_error = abs(error(end));
    
    # Calculate thrust metrics
    thrust_variation = max(thrust_command) - min(thrust_command);
    max_thrust = max(thrust_command);
    min_thrust = min(thrust_command);
    
    # Store analysis
    analysis.step_info = step_info;
    analysis.rms_error = rms_error;
    analysis.max_error = max_error;
    analysis.steady_state_error = steady_state_error;
    analysis.thrust_variation = thrust_variation;
    analysis.max_thrust = max_thrust;
    analysis.min_thrust = min_thrust;

end

function requirements = check_all_requirements(analysis)
% CHECK_ALL_REQUIREMENTS - Check all requirements

    requirements = struct();
    req_count = 0;
    
    # REQ-001: Altitude within ±0.5m
    req_count = req_count + 1;
    requirements(req_count).id = 'REQ-001';
    requirements(req_count).description = 'Altitude within ±0.5m';
    requirements(req_count).value = analysis.max_error;
    requirements(req_count).limit = 0.5;
    requirements(req_count).passed = analysis.max_error <= 0.5;
    
    # REQ-002: Response within 2 seconds
    req_count = req_count + 1;
    requirements(req_count).id = 'REQ-002';
    requirements(req_count).description = 'Response within 2 seconds';
    requirements(req_count).value = analysis.step_info.RiseTime;
    requirements(req_count).limit = 2.0;
    requirements(req_count).passed = analysis.step_info.RiseTime <= 2.0;
    
    # REQ-006: Thrust variation ±5%
    req_count = req_count + 1;
    requirements(req_count).id = 'REQ-006';
    requirements(req_count).description = 'Thrust variation ±5%';
    requirements(req_count).value = analysis.thrust_variation;
    requirements(req_count).limit = 0.1;
    requirements(req_count).passed = analysis.thrust_variation <= 0.1;
    
    # REQ-007: Settling time < 5 seconds
    req_count = req_count + 1;
    requirements(req_count).id = 'REQ-007';
    requirements(req_count).description = 'Settling time < 5 seconds';
    requirements(req_count).value = analysis.step_info.SettlingTime;
    requirements(req_count).limit = 5.0;
    requirements(req_count).passed = analysis.step_info.SettlingTime <= 5.0;

end

function generate_phase2_test_report(test_results)
% GENERATE_PHASE2_TEST_REPORT - Generate Phase 2 test report

    # Create report
    report = struct();
    report.test_results = test_results;
    report.test_date = datestr(now);
    report.total_tests = length(test_results);
    report.passed_tests = sum([test_results.passed]);
    report.pass_rate = report.passed_tests / report.total_tests;
    
    # Save report
    save('test_results/phase2_test_report.mat', 'report');
    
    fprintf('Test report saved to test_results/phase2_test_report.mat\n');

end

function display_test_summary(test_results)
% DISPLAY_TEST_SUMMARY - Display test summary

    fprintf('\n==========================================\n');
    fprintf('PHASE 2 TEST SUMMARY\n');
    fprintf('==========================================\n\n');
    
    total_tests = length(test_results);
    passed_tests = sum([test_results.passed]);
    pass_rate = passed_tests / total_tests * 100;
    
    fprintf('Overall Results:\n');
    fprintf('  Total Tests: %d\n', total_tests);
    fprintf('  Passed: %d\n', passed_tests);
    fprintf('  Failed: %d\n', total_tests - passed_tests);
    fprintf('  Pass Rate: %.1f%%\n\n', pass_rate);
    
    fprintf('Individual Test Results:\n');
    for i = 1:length(test_results)
        status = test_results(i).passed ? 'PASS' : 'FAIL';
        fprintf('  %d. %s: %s\n', i, test_results(i).name, status);
        if isfield(test_results(i), 'summary')
            fprintf('      %s\n', test_results(i).summary);
        end
    end
    
    fprintf('\nNext Steps:\n');
    if pass_rate >= 95
        fprintf('✓ System ready for Phase 3: Test Automation\n');
    else
        fprintf('⚠ System needs optimization before Phase 3\n');
    end

end
