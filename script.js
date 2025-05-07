document.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 20,
                    behavior: 'smooth'
                });
                
                history.pushState(null, null, targetId);
            }
        });
    });
    
    const sections = document.querySelectorAll('section');
    const navLinks = document.querySelectorAll('.sidebar-menu a');
    
    window.addEventListener('scroll', function() {
        let current = '';
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop;
            const sectionHeight = section.clientHeight;
            
            if (pageYOffset >= sectionTop - 200) {
                current = '#' + section.getAttribute('id');
            }
        });
        
        navLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href') === current) {
                link.classList.add('active');
            }
        });
    });
    
    document.querySelectorAll('pre').forEach(pre => {
        const button = document.createElement('button');
        button.className = 'copy-button';
        button.innerHTML = '<i class="far fa-copy"></i>';
        button.title = 'Copy to clipboard';
    
        
        button.addEventListener('click', function () {
            const code = pre.querySelector('code');
            navigator.clipboard.writeText(code.textContent).then(() => {
                button.innerHTML = '<i class="fas fa-check"></i>';
                button.title = 'Copied!';
                setTimeout(() => {
                    button.innerHTML = '<i class="far fa-copy"></i>';
                    button.title = 'Copy to clipboard';
                }, 2000);
            });
        });
        
        const wrapper = document.createElement('div');
    wrapper.className = 'code-block';
    pre.parentNode.insertBefore(wrapper, pre);
    wrapper.appendChild(button);
    wrapper.appendChild(pre);
    });
    
    const themeSwitcher = document.createElement('div');
    themeSwitcher.className = 'theme-switcher';
    themeSwitcher.innerHTML = `
        <button class="theme-btn dark active" data-theme="dark"><i class="fas fa-moon"></i></button>
        <button class="theme-btn light" data-theme="light"><i class="fas fa-sun"></i></button>
    `;
    document.body.appendChild(themeSwitcher);
    
    document.querySelectorAll('.theme-btn').forEach(btn => {
        btn.addEventListener('click', function() {
            document.querySelector('.theme-btn.active').classList.remove('active');
            this.classList.add('active');
            
            if (this.dataset.theme === 'light') {
                document.documentElement.style.setProperty('--primary-color', '#f5f5f5');
                document.documentElement.style.setProperty('--secondary-color', '#e0e0e0');
                document.documentElement.style.setProperty('--text-color', '#333333');
                document.documentElement.style.setProperty('--background-color', '#ffffff');
            } else {
                document.documentElement.style.setProperty('--primary-color', '#2d2d2d');
                document.documentElement.style.setProperty('--secondary-color', '#232323');
                document.documentElement.style.setProperty('--text-color', '#f0f0f0');
                document.documentElement.style.setProperty('--background-color', '#191919');
            }
        });
    });

    const mobileMenuToggle = document.createElement('button');
    mobileMenuToggle.className = 'mobile-menu-toggle';
    mobileMenuToggle.innerHTML = '<i class="fas fa-bars"></i>';
    document.body.appendChild(mobileMenuToggle);
    
    mobileMenuToggle.addEventListener('click', function() {
        document.querySelector('.sidebar').classList.toggle('active');
    });
});

const style = document.createElement('style');
style.textContent = `
.copy-button {
    position: absolute;
    top: 10px;
    right: 10px;
    background: rgba(255, 255, 255, 0.1);
    border: none;
    color: var(--text-color);
    padding: 5px 10px;
    border-radius: 4px;
    cursor: pointer;
    transition: var(--transition);
}

.copy-button:hover {
    background: rgba(100, 180, 255, 0.2);
    color: var(--accent-color);
}

.theme-switcher {
    position: fixed;
    bottom: 20px;
    right: 20px;
    display: flex;
    background: var(--secondary-color);
    border-radius: 30px;
    padding: 5px;
    box-shadow: var(--shadow);
    z-index: 100;
}

.theme-btn {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    border: none;
    background: transparent;
    color: var(--text-color);
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: var(--transition);
}

.theme-btn.active {
    background: var(--accent-color);
    color: white;
}

.mobile-menu-toggle {
    display: none;
    position: fixed;
    top: 20px;
    right: 20px;
    width: 50px;
    height: 50px;
    background: var(--accent-color);
    color: white;
    border: none;
    border-radius: 50%;
    font-size: 1.2rem;
    z-index: 100;
    box-shadow: var(--shadow);
}

.sidebar-menu a.active {
    background-color: rgba(100, 180, 255, 0.2);
    color: var(--accent-color);
}

@media (max-width: 768px) {
    .mobile-menu-toggle {
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .sidebar {
        position: fixed;
        top: 0;
        left: -100%;
        width: 80%;
        height: 100vh;
        z-index: 90;
        transition: left 0.3s ease;
    }
    
    .sidebar.active {
        left: 0;
    }
}
`;
document.head.appendChild(style);



