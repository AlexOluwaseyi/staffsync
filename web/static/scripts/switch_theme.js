document.addEventListener('DOMContentLoaded', (event) => {
    const themeToggle = document.getElementById('theme-toggle');
    const dropdown = document.getElementById('dropdown-menu');
    // const themeLabel = document.getElementById('theme-label');

    // Load user preference from localStorage
    const currentTheme = localStorage.getItem('theme');
    if (currentTheme) {
        document.body.classList.toggle('dark-theme', currentTheme === 'dark');
        themeToggle.checked = currentTheme === 'dark';
        // themeLabel.textContent = currentTheme === 'dark' ? 'Dark Mode' : 'Light Mode';
    }

    themeToggle.addEventListener('change', () => {
        if (themeToggle.checked) {
            document.body.classList.remove('light-theme');
            document.body.classList.add('dark-theme');
            dropdown.classList.remove('dropdown-menu-light')
            dropdown.classList.add('dropdown-menu-dark')
            localStorage.setItem('theme', 'dark');
            // themeLabel.textContent = 'Dark Mode';
        } else {
            document.body.classList.remove('dark-theme');
            document.body.classList.add('light-theme');
            dropdown.classList.add('dropdown-menu-light')
            dropdown.classList.remove('dropdown-menu-dark')
            localStorage.setItem('theme', 'light');
            // themeLabel.textContent = 'Light Mode';
        }
    });
});