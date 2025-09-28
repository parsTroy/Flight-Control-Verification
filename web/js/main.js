// Main Application Controller
class AppController {
    constructor() {
        this.currentSection = 'home';
        this.setupEventListeners();
        this.initializeApp();
    }

    setupEventListeners() {
        // Navigation
        document.querySelectorAll('.nav-link').forEach(link => {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                const targetSection = e.target.getAttribute('href').substring(1);
                this.navigateToSection(targetSection);
            });
        });

        // Mobile menu toggle
        const hamburger = document.querySelector('.hamburger');
        const navMenu = document.querySelector('.nav-menu');
        
        if (hamburger && navMenu) {
            hamburger.addEventListener('click', () => {
                hamburger.classList.toggle('active');
                navMenu.classList.toggle('active');
            });
        }

        // Smooth scrolling for anchor links
        document.querySelectorAll('a[href^="#"]').forEach(anchor => {
            anchor.addEventListener('click', (e) => {
                e.preventDefault();
                const target = document.querySelector(anchor.getAttribute('href'));
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            });
        });

        // Scroll spy for navigation highlighting
        window.addEventListener('scroll', () => {
            this.updateActiveNavigation();
        });

        // Window resize handler
        window.addEventListener('resize', () => {
            this.handleResize();
        });
    }

    initializeApp() {
        // Initialize any required components
        this.setupAnimations();
        this.setupIntersectionObserver();
        this.loadInitialData();
    }

    navigateToSection(sectionId) {
        // Update navigation
        document.querySelectorAll('.nav-link').forEach(link => {
            link.classList.remove('active');
        });
        document.querySelector(`[href="#${sectionId}"]`).classList.add('active');

        // Update current section
        this.currentSection = sectionId;

        // Close mobile menu if open
        const hamburger = document.querySelector('.hamburger');
        const navMenu = document.querySelector('.nav-menu');
        if (hamburger && navMenu) {
            hamburger.classList.remove('active');
            navMenu.classList.remove('active');
        }

        // Scroll to section
        const targetElement = document.getElementById(sectionId);
        if (targetElement) {
            const offsetTop = targetElement.offsetTop - 70; // Account for fixed navbar
            window.scrollTo({
                top: offsetTop,
                behavior: 'smooth'
            });
        }
    }

    updateActiveNavigation() {
        const sections = ['home', 'simulation', 'testing', 'documentation', 'about'];
        const scrollPosition = window.scrollY + 100;

        sections.forEach(sectionId => {
            const section = document.getElementById(sectionId);
            if (section) {
                const sectionTop = section.offsetTop;
                const sectionBottom = sectionTop + section.offsetHeight;
                
                if (scrollPosition >= sectionTop && scrollPosition < sectionBottom) {
                    // Update navigation
                    document.querySelectorAll('.nav-link').forEach(link => {
                        link.classList.remove('active');
                    });
                    const activeLink = document.querySelector(`[href="#${sectionId}"]`);
                    if (activeLink) {
                        activeLink.classList.add('active');
                    }
                    
                    this.currentSection = sectionId;
                }
            }
        });
    }

    setupAnimations() {
        // Add CSS for animations
        const style = document.createElement('style');
        style.textContent = `
            .fade-in {
                opacity: 0;
                transform: translateY(30px);
                transition: opacity 0.6s ease, transform 0.6s ease;
            }
            
            .fade-in.visible {
                opacity: 1;
                transform: translateY(0);
            }
            
            .slide-in-left {
                opacity: 0;
                transform: translateX(-50px);
                transition: opacity 0.6s ease, transform 0.6s ease;
            }
            
            .slide-in-left.visible {
                opacity: 1;
                transform: translateX(0);
            }
            
            .slide-in-right {
                opacity: 0;
                transform: translateX(50px);
                transition: opacity 0.6s ease, transform 0.6s ease;
            }
            
            .slide-in-right.visible {
                opacity: 1;
                transform: translateX(0);
            }
            
            .scale-in {
                opacity: 0;
                transform: scale(0.8);
                transition: opacity 0.6s ease, transform 0.6s ease;
            }
            
            .scale-in.visible {
                opacity: 1;
                transform: scale(1);
            }
        `;
        document.head.appendChild(style);
    }

    setupIntersectionObserver() {
        const observerOptions = {
            threshold: 0.1,
            rootMargin: '0px 0px -50px 0px'
        };

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visible');
                }
            });
        }, observerOptions);

        // Observe elements for animation
        const animatedElements = document.querySelectorAll('.hero-content, .hero-visual, .control-panel, .simulation-results, .test-controls, .test-results, .doc-card, .about-text, .about-stats');
        animatedElements.forEach(el => {
            el.classList.add('fade-in');
            observer.observe(el);
        });
    }

    loadInitialData() {
        // Load any initial data needed for the application
        this.loadProjectStats();
        this.loadDocumentationLinks();
    }

    loadProjectStats() {
        // Update project statistics
        const stats = {
            totalTests: 1000,
            passRate: 95.2,
            requirements: 15,
            files: 25,
            linesOfCode: 10000,
            phases: 5
        };

        // Update stat cards if they exist
        Object.entries(stats).forEach(([key, value]) => {
            const element = document.getElementById(`${key.replace(/([A-Z])/g, '-$1').toLowerCase()}-value`);
            if (element) {
                element.textContent = value;
            }
        });
    }

    loadDocumentationLinks() {
        // Verify documentation links exist
        const docLinks = [
            'docs/final_vv_report.html',
            'docs/requirements_traceability_matrix.csv',
            'docs/test_procedures.html',
            'docs/test_results.html',
            'docs/user_guide.html',
            'docs/maintenance_guide.html'
        ];

        // Add click handlers for documentation links
        document.querySelectorAll('.doc-card a').forEach(link => {
            link.addEventListener('click', (e) => {
                const href = e.target.getAttribute('href');
                if (href && href.includes('docs/')) {
                    // Check if file exists (simplified check)
                    this.checkDocumentationFile(href);
                }
            });
        });
    }

    checkDocumentationFile(filePath) {
        // Simulate file existence check
        // In a real implementation, this would make an actual HTTP request
        console.log(`Checking documentation file: ${filePath}`);
        
        // For demo purposes, show a message
        if (filePath.includes('.html')) {
            this.showNotification('Opening documentation...', 'info');
        } else if (filePath.includes('.csv')) {
            this.showNotification('Downloading file...', 'info');
        }
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification notification-${type}`;
        notification.textContent = message;
        
        // Style the notification
        Object.assign(notification.style, {
            position: 'fixed',
            top: '20px',
            right: '20px',
            padding: '15px 20px',
            borderRadius: '5px',
            color: 'white',
            fontWeight: 'bold',
            zIndex: '10000',
            opacity: '0',
            transform: 'translateX(100%)',
            transition: 'all 0.3s ease'
        });

        // Set background color based on type
        const colors = {
            info: '#667eea',
            success: '#4CAF50',
            warning: '#ff9800',
            error: '#f44336'
        };
        notification.style.backgroundColor = colors[type] || colors.info;

        // Add to DOM
        document.body.appendChild(notification);

        // Animate in
        setTimeout(() => {
            notification.style.opacity = '1';
            notification.style.transform = 'translateX(0)';
        }, 100);

        // Remove after 3 seconds
        setTimeout(() => {
            notification.style.opacity = '0';
            notification.style.transform = 'translateX(100%)';
            setTimeout(() => {
                if (notification.parentNode) {
                    notification.parentNode.removeChild(notification);
                }
            }, 300);
        }, 3000);
    }

    handleResize() {
        // Handle window resize events
        const isMobile = window.innerWidth <= 768;
        
        // Update mobile-specific behaviors
        if (isMobile) {
            // Close mobile menu if open
            const hamburger = document.querySelector('.hamburger');
            const navMenu = document.querySelector('.nav-menu');
            if (hamburger && navMenu) {
                hamburger.classList.remove('active');
                navMenu.classList.remove('active');
            }
        }

        // Update chart sizes if they exist
        if (window.simulationEngine && window.simulationEngine.charts) {
            Object.values(window.simulationEngine.charts).forEach(chart => {
                chart.resize();
            });
        }
    }

    // Utility methods
    formatNumber(num, decimals = 0) {
        return num.toLocaleString(undefined, {
            minimumFractionDigits: decimals,
            maximumFractionDigits: decimals
        });
    }

    formatTime(seconds) {
        if (seconds < 60) {
            return `${seconds.toFixed(1)}s`;
        } else if (seconds < 3600) {
            const minutes = Math.floor(seconds / 60);
            const remainingSeconds = seconds % 60;
            return `${minutes}m ${remainingSeconds.toFixed(1)}s`;
        } else {
            const hours = Math.floor(seconds / 3600);
            const minutes = Math.floor((seconds % 3600) / 60);
            return `${hours}h ${minutes}m`;
        }
    }

    // Export data functionality
    exportData(data, filename, type = 'json') {
        let content, mimeType;
        
        switch (type) {
            case 'json':
                content = JSON.stringify(data, null, 2);
                mimeType = 'application/json';
                break;
            case 'csv':
                content = this.convertToCSV(data);
                mimeType = 'text/csv';
                break;
            default:
                content = JSON.stringify(data, null, 2);
                mimeType = 'application/json';
        }

        const blob = new Blob([content], { type: mimeType });
        const url = URL.createObjectURL(blob);
        
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        URL.revokeObjectURL(url);
    }

    convertToCSV(data) {
        if (!Array.isArray(data) || data.length === 0) {
            return '';
        }

        const headers = Object.keys(data[0]);
        const csvContent = [
            headers.join(','),
            ...data.map(row => headers.map(header => JSON.stringify(row[header] || '')).join(','))
        ].join('\n');

        return csvContent;
    }
}

// Initialize application when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.appController = new AppController();
});

// Add some additional CSS for animations and notifications
const additionalStyles = `
    .notification {
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        border-radius: 8px;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    .test-item {
        background: white;
        border-radius: 8px;
        padding: 15px;
        margin-bottom: 10px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        border-left: 4px solid #ddd;
    }

    .test-item.pass {
        border-left-color: #4CAF50;
    }

    .test-item.fail {
        border-left-color: #f44336;
    }

    .test-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 8px;
    }

    .test-name {
        font-weight: 600;
        color: #333;
    }

    .test-status {
        padding: 4px 8px;
        border-radius: 4px;
        font-size: 0.8rem;
        font-weight: bold;
        text-transform: uppercase;
    }

    .test-status.pass {
        background: #e8f5e8;
        color: #4CAF50;
    }

    .test-status.fail {
        background: #ffebee;
        color: #f44336;
    }

    .test-info {
        display: flex;
        justify-content: space-between;
        margin-bottom: 8px;
        font-size: 0.9rem;
        color: #666;
    }

    .test-metrics {
        font-size: 0.8rem;
        color: #888;
    }

    .metric {
        margin-right: 15px;
    }

    .no-metrics {
        font-style: italic;
        color: #999;
    }
`;

// Add the additional styles to the document
const styleSheet = document.createElement('style');
styleSheet.textContent = additionalStyles;
document.head.appendChild(styleSheet);
