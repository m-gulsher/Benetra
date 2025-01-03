import { Turbo } from "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import { Modal } from 'bootstrap'
import Rails from "rails-ujs"
import "./controllers"

// Initialize Turbo
Turbo.session.drive = false  // Turbo's behavior can be customized

// Stimulus setup
const application = Application.start()


// Rails UJS (not necessary if you're using Hotwire alone)
Rails.start()

document.addEventListener('turbo:load', () => {
  const modals = document.querySelectorAll('[data-bs-toggle="modal"]');
  modals.forEach(modal => {
    new Modal(modal);
  });
})
function toggleSidebar() {
  const sidebar = document.getElementById("sidebar");
  sidebar.classList.toggle("hidden");
}

function closeFlashMessage(button) {
  const flashMessage = button.closest("#flash-message");
  flashMessage.remove();
  location.reload();
}

window.toggleSidebar = toggleSidebar;
window.closeFlashMessage = closeFlashMessage;
