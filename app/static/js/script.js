// script.js

function showSection(sectionId) {
  const sections = document.querySelectorAll('section');
  sections.forEach(section => {
      section.classList.remove('active');
  });
  
  document.getElementById(sectionId).classList.add('active');

  const navLinks = document.querySelectorAll('.nav-link');
  navLinks.forEach(link => {
      link.classList.remove('active');
  });

  document.querySelector(`a[href="#${sectionId}"]`).classList.add('active');
}

// Show the home section by default
document.addEventListener('DOMContentLoaded', () => {
  showSection('home');
});
