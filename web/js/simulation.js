// Simulation Engine
class SimulationEngine {
    constructor() {
        this.isRunning = false;
        this.timeStep = 0.01;
        this.simulationTime = 20.0;
        this.data = {
            time: [],
            altitude: [],
            command: [],
            thrust: [],
            error: []
        };
        this.charts = {};
        this.initializeCharts();
        this.setupEventListeners();
    }

    initializeCharts() {
        // Altitude Chart
        const altitudeCtx = document.getElementById('altitude-chart').getContext('2d');
        this.charts.altitude = new Chart(altitudeCtx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Altitude (m)',
                    data: [],
                    borderColor: '#667eea',
                    backgroundColor: 'rgba(102, 126, 234, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                }, {
                    label: 'Command (m)',
                    data: [],
                    borderColor: '#ff6b6b',
                    backgroundColor: 'rgba(255, 107, 107, 0.1)',
                    borderWidth: 2,
                    borderDash: [5, 5],
                    fill: false
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Time (s)'
                        }
                    },
                    y: {
                        title: {
                            display: true,
                            text: 'Altitude (m)'
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top'
                    }
                }
            }
        });

        // Thrust Chart
        const thrustCtx = document.getElementById('thrust-chart').getContext('2d');
        this.charts.thrust = new Chart(thrustCtx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Thrust Command',
                    data: [],
                    borderColor: '#4CAF50',
                    backgroundColor: 'rgba(76, 175, 80, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Time (s)'
                        }
                    },
                    y: {
                        title: {
                            display: true,
                            text: 'Thrust Command'
                        },
                        min: 0,
                        max: 1
                    }
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top'
                    }
                }
            }
        });

        // Error Chart
        const errorCtx = document.getElementById('error-chart').getContext('2d');
        this.charts.error = new Chart(errorCtx, {
            type: 'line',
            data: {
                labels: [],
                datasets: [{
                    label: 'Control Error (m)',
                    data: [],
                    borderColor: '#ff9800',
                    backgroundColor: 'rgba(255, 152, 0, 0.1)',
                    borderWidth: 2,
                    fill: true,
                    tension: 0.4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Time (s)'
                        }
                    },
                    y: {
                        title: {
                            display: true,
                            text: 'Error (m)'
                        }
                    }
                },
                plugins: {
                    legend: {
                        display: true,
                        position: 'top'
                    }
                }
            }
        });
    }

    setupEventListeners() {
        // Parameter sliders
        const parameters = ['mass', 'kp', 'ki', 'kd', 'command', 'disturbance'];
        parameters.forEach(param => {
            const slider = document.getElementById(param);
            const valueDisplay = document.getElementById(`${param}-value`);
            
            slider.addEventListener('input', (e) => {
                valueDisplay.textContent = parseFloat(e.target.value).toFixed(2);
            });
        });

        // Simulation buttons
        document.getElementById('run-simulation').addEventListener('click', () => {
            this.runSimulation();
        });

        document.getElementById('reset-simulation').addEventListener('click', () => {
            this.resetSimulation();
        });

        // Tab switching
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', (e) => {
                this.switchTab(e.target.dataset.tab);
            });
        });
    }

    switchTab(tabName) {
        // Update tab buttons
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`[data-tab="${tabName}"]`).classList.add('active');

        // Update tab content
        document.querySelectorAll('.tab-pane').forEach(pane => {
            pane.classList.remove('active');
        });
        document.getElementById(`${tabName}-tab`).classList.add('active');
    }

    getParameters() {
        return {
            mass: parseFloat(document.getElementById('mass').value),
            kp: parseFloat(document.getElementById('kp').value),
            ki: parseFloat(document.getElementById('ki').value),
            kd: parseFloat(document.getElementById('kd').value),
            command: parseFloat(document.getElementById('command').value),
            disturbance: parseFloat(document.getElementById('disturbance').value)
        };
    }

    runSimulation() {
        if (this.isRunning) return;
        
        this.isRunning = true;
        this.resetSimulation();
        
        const params = this.getParameters();
        const runButton = document.getElementById('run-simulation');
        runButton.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Running...';
        runButton.disabled = true;

        // Simulate the quadcopter control system
        this.simulateQuadcopter(params);
        
        // Update charts
        this.updateCharts();
        
        // Calculate performance metrics
        this.calculatePerformanceMetrics();
        
        // Update quadcopter animation
        this.updateQuadcopterAnimation();

        this.isRunning = false;
        runButton.innerHTML = '<i class="fas fa-play"></i> Run Simulation';
        runButton.disabled = false;
    }

    simulateQuadcopter(params) {
        const { mass, kp, ki, kd, command, disturbance } = params;
        
        // System parameters
        const gravity = 9.81;
        const dragCoeff = 0.1;
        const thrustGain = 10.0;
        const actuatorTimeConstant = 0.1;
        
        // Initialize state variables
        let altitude = 0;
        let velocity = 0;
        let acceleration = 0;
        let thrustCommand = 0;
        let integralError = 0;
        let previousError = 0;
        let actuatorState = 0;
        
        // Time vector
        const time = [];
        const altitudeData = [];
        const commandData = [];
        const thrustData = [];
        const errorData = [];
        
        for (let t = 0; t <= this.simulationTime; t += this.timeStep) {
            time.push(t);
            
            // Calculate error
            const error = command - altitude;
            errorData.push(error);
            
            // PID Controller
            const proportional = kp * error;
            integralError += error * this.timeStep;
            const integral = ki * integralError;
            const derivative = kd * (error - previousError) / this.timeStep;
            
            thrustCommand = proportional + integral + derivative;
            
            // Apply saturation
            thrustCommand = Math.max(0, Math.min(1, thrustCommand));
            
            // Actuator dynamics (first-order lag)
            actuatorState += (thrustCommand - actuatorState) * this.timeStep / actuatorTimeConstant;
            
            // Calculate thrust force
            const thrustForce = thrustGain * actuatorState;
            
            // Add wind disturbance
            const windForce = disturbance * 0.1; // Simplified wind effect
            
            // Plant dynamics: m*ẍ = T - m*g - D(ẋ) + wind
            acceleration = (thrustForce - mass * gravity - dragCoeff * velocity + windForce) / mass;
            
            // Integrate to get velocity and position
            velocity += acceleration * this.timeStep;
            altitude += velocity * this.timeStep;
            
            // Store data
            altitudeData.push(altitude);
            commandData.push(command);
            thrustData.push(thrustCommand);
            
            previousError = error;
        }
        
        // Store simulation data
        this.data = {
            time: time,
            altitude: altitudeData,
            command: commandData,
            thrust: thrustData,
            error: errorData
        };
    }

    updateCharts() {
        // Update altitude chart
        this.charts.altitude.data.labels = this.data.time.map(t => t.toFixed(1));
        this.charts.altitude.data.datasets[0].data = this.data.altitude;
        this.charts.altitude.data.datasets[1].data = this.data.command;
        this.charts.altitude.update();

        // Update thrust chart
        this.charts.thrust.data.labels = this.data.time.map(t => t.toFixed(1));
        this.charts.thrust.data.datasets[0].data = this.data.thrust;
        this.charts.thrust.update();

        // Update error chart
        this.charts.error.data.labels = this.data.time.map(t => t.toFixed(1));
        this.charts.error.data.datasets[0].data = this.data.error;
        this.charts.error.update();
    }

    calculatePerformanceMetrics() {
        const { time, altitude, command, error } = this.data;
        
        // Find step response characteristics
        const commandValue = command[0];
        const finalValue = altitude[altitude.length - 1];
        
        // Calculate overshoot
        const maxAltitude = Math.max(...altitude);
        const overshoot = Math.max(0, (maxAltitude - commandValue) / commandValue * 100);
        
        // Calculate settling time (2% tolerance)
        const tolerance = 0.02 * commandValue;
        let settlingTime = time[time.length - 1];
        for (let i = time.length - 1; i >= 0; i--) {
            if (Math.abs(altitude[i] - commandValue) > tolerance) {
                settlingTime = time[i];
                break;
            }
        }
        
        // Calculate rise time (10% to 90%)
        const target10 = commandValue * 0.1;
        const target90 = commandValue * 0.9;
        let riseTime = 0;
        let t10 = 0, t90 = 0;
        
        for (let i = 0; i < altitude.length; i++) {
            if (altitude[i] >= target10 && t10 === 0) {
                t10 = time[i];
            }
            if (altitude[i] >= target90 && t90 === 0) {
                t90 = time[i];
                break;
            }
        }
        riseTime = t90 - t10;
        
        // Calculate steady state error
        const steadyStateError = Math.abs(finalValue - commandValue);
        
        // Update performance metrics display
        document.getElementById('overshoot-value').textContent = overshoot.toFixed(2) + '%';
        document.getElementById('settling-time-value').textContent = settlingTime.toFixed(2) + 's';
        document.getElementById('rise-time-value').textContent = riseTime.toFixed(2) + 's';
        document.getElementById('steady-state-error-value').textContent = steadyStateError.toFixed(3) + 'm';
    }

    updateQuadcopterAnimation() {
        const { altitude } = this.data;
        const maxAltitude = Math.max(...altitude);
        const currentAltitude = altitude[altitude.length - 1];
        
        // Update altitude display
        document.getElementById('altitude-display').textContent = currentAltitude.toFixed(1) + ' m';
        
        // Update altitude bar
        const altitudeBar = document.getElementById('altitude-bar');
        const percentage = Math.min(100, (currentAltitude / maxAltitude) * 100);
        altitudeBar.style.width = percentage + '%';
    }

    resetSimulation() {
        this.data = {
            time: [],
            altitude: [],
            command: [],
            thrust: [],
            error: []
        };
        
        // Clear charts
        Object.values(this.charts).forEach(chart => {
            chart.data.labels = [];
            chart.data.datasets.forEach(dataset => {
                dataset.data = [];
            });
            chart.update();
        });
        
        // Reset performance metrics
        document.getElementById('overshoot-value').textContent = '0.0%';
        document.getElementById('settling-time-value').textContent = '0.0s';
        document.getElementById('rise-time-value').textContent = '0.0s';
        document.getElementById('steady-state-error-value').textContent = '0.0m';
        
        // Reset quadcopter animation
        document.getElementById('altitude-display').textContent = '0.0 m';
        document.getElementById('altitude-bar').style.width = '0%';
    }
}

// Initialize simulation when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.simulationEngine = new SimulationEngine();
});
