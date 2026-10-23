// ClinikDoc - Script global
document.addEventListener("DOMContentLoaded", () => {
  const toggleBtn = document.getElementById("nav-toggle");
  const mainNav = document.getElementById("main-nav");

  if (toggleBtn && mainNav) {
    toggleBtn.addEventListener("click", () => {
      const estOuvert = mainNav.classList.toggle("ouvert");
      toggleBtn.setAttribute("aria-expanded", String(estOuvert));
    });
  }
});