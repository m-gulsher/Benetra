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

// You can initialize Bootstrap components like this:
document.addEventListener('turbo:load', () => {
  const modals = document.querySelectorAll('[data-bs-toggle="modal"]');
  modals.forEach(modal => {
    new Modal(modal);
  });
})
