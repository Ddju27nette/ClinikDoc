// ClinikDoc - Script de réservation dynamique (Projet 1)
document.addEventListener("DOMContentLoaded", () => {
  const form = document.getElementById("form-reservation");
  const medecinSelect = document.getElementById("medecin_id");
  const dateInput = document.getElementById("date");
  const creneauxContainer = document.getElementById("creneaux-container");
  const heureInput = document.getElementById("heure");
  const erreurDiv = document.getElementById("js-erreur");

  // Fixer la date minimale sélectionnable à demain
  const aujourdhui = new Date();
  const demain = new Date(aujourdhui);
  demain.setDate(demain.getDate() + 1);
  dateInput.min = demain.toISOString().split("T")[0];

  // 1. Appel Fetch asynchrone pour charger les créneaux libres
  async function chargerCreneaux() {
    const medecinId = medecinSelect.value;
    const dateVal = dateInput.value;

    if (!medecinId || !dateVal) {
      creneauxContainer.innerHTML = '<p style="color: var(--text-muted); font-size: 0.9rem; font-style: italic;">Sélectionnez un médecin et une date pour afficher les créneaux libres.</p>';
      heureInput.value = "";
      return;
    }

    creneauxContainer.innerHTML = '<p style="color: var(--secondary); font-size: 0.9rem;">Chargement des disponibilités...</p>';

    try {
      const response = await fetch(`/api/creneaux?medecin_id=${encodeURIComponent(medecinId)}&date=${encodeURIComponent(dateVal)}`);
      if (!response.ok) {
        throw new Error("Erreur de communication avec le serveur.");
      }
      
      const data = await response.json();

      if (data.message) {
        creneauxContainer.innerHTML = `<p style="color: var(--danger); font-size: 0.9rem;">⚠️ ${data.message}</p>`;
        heureInput.value = "";
        return;
      }

      if (!data.creneaux || data.creneaux.length === 0) {
        creneauxContainer.innerHTML = '<p style="color: var(--danger); font-size: 0.9rem;">Complet : aucun créneau disponible pour ce médecin à cette date.</p>';
        heureInput.value = "";
        return;
      }

      // Construction de la grille des créneaux libres
      let html = '<div class="creneaux-grid">';
      data.creneaux.forEach(heure => {
        const isSelected = heureInput.value === heure ? "selected" : "";
        html += `<button type="button" class="creneau-btn ${isSelected}" data-heure="${heure}">${heure}</button>`;
      });
      html += '</div>';
      creneauxContainer.innerHTML = html;

      // Écouteurs sur chaque bouton de créneau horaire
      const boutons = creneauxContainer.querySelectorAll(".creneau-btn");
      boutons.forEach(btn => {
        btn.addEventListener("click", () => {
          boutons.forEach(b => b.classList.remove("selected"));
          btn.classList.add("selected");
          heureInput.value = btn.dataset.heure;
          erreurDiv.style.display = "none";
        });
      });

    } catch (err) {
      creneauxContainer.innerHTML = '<p style="color: var(--danger); font-size: 0.9rem;">Impossible de charger les créneaux. Veuillez réessayer.</p>';
      console.error(err);
    }
  }

  // Écouter les changements sur le médecin et la date
  medecinSelect.addEventListener("change", chargerCreneaux);
  dateInput.addEventListener("change", chargerCreneaux);

  // Si des valeurs sont déjà présentes au chargement
  if (medecinSelect.value && dateInput.value) {
    chargerCreneaux();
  }

  // 2. Validation du formulaire avant l'envoi
  form.addEventListener("submit", (e) => {
    const tel = form.telephone.value.trim().replace(/\s/g, "");
    const dateVal = form.date.value;
    const heureVal = heureInput.value;

    let messageErreur = "";

    // Contrôle du numéro de téléphone camerounais (exactement 9 chiffres débutant par 6)
    if (!/^6\d{8}$/.test(tel)) {
      messageErreur = "Le numéro de téléphone est invalide. Il doit comporter 9 chiffres et commencer par un 6 (ex: 699123456).";
    } else if (!dateVal) {
      messageErreur = "Veuillez sélectionner une date de consultation.";
    } else if (new Date(dateVal) <= new Date()) {
      messageErreur = "La date du rendez-vous doit être dans le futur.";
    } else if (!heureVal) {
      messageErreur = "Veuillez cliquer sur un créneau horaire disponible.";
    }

    if (messageErreur) {
      e.preventDefault(); // Bloquer l'envoi du formulaire
      erreurDiv.textContent = messageErreur;
      erreurDiv.style.display = "block";
      window.scrollTo({ top: 0, behavior: "smooth" });
    }
  });
});