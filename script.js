
// Mobile menu toggle
const menuBtn = document.querySelector('.menu-btn');
const nav = document.querySelector('header nav');
menuBtn.addEventListener('click', () => {
  nav.classList.toggle('active');
});
