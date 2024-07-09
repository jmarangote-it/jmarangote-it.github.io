document.addEventListener('DOMContentLoaded', () => {
    const elements = document.querySelectorAll('h1, h2, h3, h4, p, li');
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate');
            } else {
                entry.target.classList.remove('animate');
            }
        });
    }, { threshold: 0.1 });
    
    elements.forEach(element => {
        observer.observe(element);
    });
});

document.addEventListener('DOMContentLoaded', () => {
    const collapsibles = document.querySelectorAll('.collapsible');
    collapsibles.forEach(collapsible => {
        collapsible.addEventListener('click', () => {
            const content = collapsible.nextElementSibling;
            collapsible.classList.toggle('active');
            if (collapsible.classList.contains('active')) {
                content.style.maxHeight = content.scrollHeight + 'px';
                content.style.opacity = 1;
            } else {
                content.style.maxHeight = null;
                content.style.opacity = 0;
            }
        });
    });
});