// Testing Engine
class TestingEngine {
    constructor() {
        this.isRunning = false;
        this.testResults = [];
        this.setupEventListeners();
    }

    setupEventListeners() {
        document.getElementById('run-tests').addEventListener('click', () => {
            this.runSelectedTests();
        });

        document.getElementById('run-all-tests').addEventListener('click', () => {
            this.runAllTests();
        });
    }

    async runSelectedTests() {
        if (this.isRunning) return;
        
        this.isRunning = true;
        this.resetTestResults();
        
        const selectedTests = this.getSelectedTests();
        if (selectedTests.length === 0) {
            alert('Please select at least one test to run.');
            this.isRunning = false;
            return;
        }

        await this.executeTests(selectedTests);
        this.isRunning = false;
    }

    async runAllTests() {
        if (this.isRunning) return;
        
        this.isRunning = true;
        this.resetTestResults();
        
        const allTests = [
            'nominal-tests',
            'disturbance-tests',
            'noise-tests',
            'failure-tests',
            'parameter-tests',
            'monte-carlo-tests'
        ];

        await this.executeTests(allTests);
        this.isRunning = false;
    }

    getSelectedTests() {
        const testCheckboxes = [
            'nominal-tests',
            'disturbance-tests',
            'noise-tests',
            'failure-tests',
            'parameter-tests',
            'monte-carlo-tests'
        ];

        return testCheckboxes.filter(testId => {
            return document.getElementById(testId).checked;
        });
    }

    async executeTests(testTypes) {
        const totalTests = this.calculateTotalTests(testTypes);
        let completedTests = 0;
        
        this.updateProgress(0, `Starting test execution...`);
        
        for (const testType of testTypes) {
            await this.runTestSuite(testType, (progress) => {
                const overallProgress = ((completedTests + progress) / totalTests) * 100;
                this.updateProgress(overallProgress, `Running ${testType.replace('-', ' ')}...`);
            });
            completedTests += this.getTestCount(testType);
        }
        
        this.updateProgress(100, 'Test execution completed!');
        this.displayTestResults();
    }

    calculateTotalTests(testTypes) {
        const testCounts = {
            'nominal-tests': 3,
            'disturbance-tests': 4,
            'noise-tests': 4,
            'failure-tests': 3,
            'parameter-tests': 15,
            'monte-carlo-tests': 1
        };

        return testTypes.reduce((total, testType) => {
            return total + testCounts[testType];
        }, 0);
    }

    getTestCount(testType) {
        const testCounts = {
            'nominal-tests': 3,
            'disturbance-tests': 4,
            'noise-tests': 4,
            'failure-tests': 3,
            'parameter-tests': 15,
            'monte-carlo-tests': 1
        };
        return testCounts[testType] || 0;
    }

    async runTestSuite(testType, progressCallback) {
        const testCount = this.getTestCount(testType);
        
        for (let i = 0; i < testCount; i++) {
            // Simulate test execution delay
            await this.delay(200 + Math.random() * 300);
            
            const testResult = await this.executeSingleTest(testType, i);
            this.testResults.push(testResult);
            
            const progress = ((i + 1) / testCount) * 100;
            progressCallback(progress);
        }
    }

    async executeSingleTest(testType, testIndex) {
        // Simulate test execution with realistic results
        const testConfig = this.getTestConfig(testType, testIndex);
        const result = this.simulateTestExecution(testConfig);
        
        return {
            id: `${testType}-${testIndex + 1}`,
            name: testConfig.name,
            type: testConfig.type,
            status: result.status,
            executionTime: result.executionTime,
            metrics: result.metrics,
            timestamp: new Date().toISOString()
        };
    }

    getTestConfig(testType, testIndex) {
        const configs = {
            'nominal-tests': [
                { name: 'Step Response Test', type: 'Functional' },
                { name: 'Steady State Accuracy Test', type: 'Functional' },
                { name: 'Thrust Variation Test', type: 'Performance' }
            ],
            'disturbance-tests': [
                { name: 'Wind Gust 1.0 m/s', type: 'Functional' },
                { name: 'Wind Gust 2.0 m/s', type: 'Functional' },
                { name: 'Wind Gust 3.0 m/s', type: 'Functional' },
                { name: 'Wind Gust 5.0 m/s', type: 'Functional' }
            ],
            'noise-tests': [
                { name: 'Noise 0.001 m²', type: 'Robustness' },
                { name: 'Noise 0.01 m²', type: 'Robustness' },
                { name: 'Noise 0.05 m²', type: 'Robustness' },
                { name: 'Noise 0.1 m²', type: 'Robustness' }
            ],
            'failure-tests': [
                { name: 'Reduced Thrust Failure', type: 'Safety' },
                { name: 'Partial Actuator Failure', type: 'Safety' },
                { name: 'Complete Actuator Failure', type: 'Safety' }
            ],
            'parameter-tests': Array.from({ length: 15 }, (_, i) => ({
                name: `Parameter Variation ${i + 1}`, type: 'Robustness'
            })),
            'monte-carlo-tests': [
                { name: 'Monte Carlo Analysis (1000 runs)', type: 'Statistical' }
            ]
        };

        return configs[testType][testIndex] || { name: 'Unknown Test', type: 'Unknown' };
    }

    simulateTestExecution(config) {
        // Simulate realistic test results based on test type
        const executionTime = 0.5 + Math.random() * 2.0;
        let status, metrics;

        switch (config.type) {
            case 'Functional':
                status = Math.random() > 0.1 ? 'PASS' : 'FAIL';
                metrics = {
                    overshoot: 2.0 + Math.random() * 3.0,
                    settlingTime: 3.0 + Math.random() * 2.0,
                    steadyStateError: 0.05 + Math.random() * 0.05
                };
                break;
            case 'Performance':
                status = Math.random() > 0.05 ? 'PASS' : 'FAIL';
                metrics = {
                    thrustVariation: 0.05 + Math.random() * 0.05,
                    maxThrust: 0.8 + Math.random() * 0.2,
                    minThrust: 0.1 + Math.random() * 0.1
                };
                break;
            case 'Robustness':
                status = Math.random() > 0.15 ? 'PASS' : 'FAIL';
                metrics = {
                    rmsError: 0.2 + Math.random() * 0.3,
                    maxError: 0.5 + Math.random() * 0.5,
                    stability: Math.random() > 0.1
                };
                break;
            case 'Safety':
                status = Math.random() > 0.2 ? 'PASS' : 'FAIL';
                metrics = {
                    maxError: 1.0 + Math.random() * 1.0,
                    stability: Math.random() > 0.15,
                    recoveryTime: 2.0 + Math.random() * 3.0
                };
                break;
            case 'Statistical':
                status = Math.random() > 0.05 ? 'PASS' : 'FAIL';
                metrics = {
                    passRate: 90 + Math.random() * 10,
                    overshootMean: 2.5 + Math.random() * 2.0,
                    settlingTimeMean: 3.5 + Math.random() * 2.0,
                    stabilityRate: 95 + Math.random() * 5
                };
                break;
            default:
                status = 'PASS';
                metrics = {};
        }

        return { status, executionTime, metrics };
    }

    updateProgress(percentage, message) {
        const progressBar = document.getElementById('test-progress');
        const progressText = document.getElementById('progress-text');
        
        progressBar.style.width = percentage + '%';
        progressText.textContent = message;
    }

    displayTestResults() {
        const totalTests = this.testResults.length;
        const passedTests = this.testResults.filter(r => r.status === 'PASS').length;
        const failedTests = totalTests - passedTests;
        const passRate = (passedTests / totalTests) * 100;

        // Update summary
        document.getElementById('total-tests').textContent = totalTests;
        document.getElementById('passed-tests').textContent = passedTests;
        document.getElementById('failed-tests').textContent = failedTests;
        document.getElementById('pass-rate').textContent = passRate.toFixed(1) + '%';

        // Show summary
        document.getElementById('test-summary').style.display = 'block';

        // Update test details
        this.updateTestDetails();
    }

    updateTestDetails() {
        const testDetails = document.getElementById('test-details');
        testDetails.innerHTML = '';

        this.testResults.forEach(result => {
            const testItem = document.createElement('div');
            testItem.className = `test-item ${result.status.toLowerCase()}`;
            
            testItem.innerHTML = `
                <div class="test-header">
                    <span class="test-name">${result.name}</span>
                    <span class="test-status ${result.status.toLowerCase()}">${result.status}</span>
                </div>
                <div class="test-info">
                    <span class="test-type">${result.type}</span>
                    <span class="test-time">${result.executionTime.toFixed(2)}s</span>
                </div>
                <div class="test-metrics">
                    ${this.formatMetrics(result.metrics)}
                </div>
            `;
            
            testDetails.appendChild(testItem);
        });
    }

    formatMetrics(metrics) {
        if (!metrics || Object.keys(metrics).length === 0) {
            return '<span class="no-metrics">No metrics available</span>';
        }

        return Object.entries(metrics)
            .map(([key, value]) => {
                const formattedKey = key.replace(/([A-Z])/g, ' $1').toLowerCase();
                const formattedValue = typeof value === 'boolean' 
                    ? (value ? 'Yes' : 'No')
                    : (typeof value === 'number' ? value.toFixed(3) : value);
                
                return `<span class="metric">${formattedKey}: ${formattedValue}</span>`;
            })
            .join(' | ');
    }

    resetTestResults() {
        this.testResults = [];
        document.getElementById('test-summary').style.display = 'none';
        document.getElementById('test-details').innerHTML = '';
        this.updateProgress(0, 'Ready to run tests');
    }

    delay(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}

// Initialize testing when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.testingEngine = new TestingEngine();
});
