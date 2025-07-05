
// Mobile menu toggle
// if (!localStorage.getItem('hasRedirected')) {
//     localStorage.setItem('hasRedirected', 'true');
//     window.location.href = "https://mr-srinu.github.io/chhaatra/bday.html"; // replace with your page
//   }
const menuBtn = document.querySelector('.menu-btn');
const nav = document.querySelector('header nav');
menuBtn.addEventListener('click', () => {
  nav.classList.toggle('active');
});
