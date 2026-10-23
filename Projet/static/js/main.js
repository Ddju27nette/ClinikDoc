// ClinikDoc - Script global
document.addEventListener("DOMContentLoaded", () => {
  const toggleBtn = document.getElementById("nav-toggle");
  const mainNav = document.getElementById("main-nav");

  if (toggleBtn && mainNav) {
    toggleBtn.addEventListener("click", () => {
      mainNav.classList.toggle("ouvert");
    });
  }
});