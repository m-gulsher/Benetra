// app/javascript/controllers/import_progress_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["progressBar", "messages"];

  connect() {
    this.updateProgress();
  }

  async updateProgress() {
    const response = await fetch("/employees/import_progress");
    const { progress } = await response.json();

    // Update progress bar
    this.progressBarTarget.style.width = `${progress}%`;

    if (progress < 100) {
      // Continue polling if not complete
      setTimeout(() => this.updateProgress(), 500);
    } else {
      // Turn progress bar green
      this.progressBarTarget.classList.replace("bg-blue-500", "bg-green-500");
      this.fetchResults(); // Fetch and display messages
    }
  }

  async fetchResults() {
    const response = await fetch("/employees/import_results");
    const { results } = await response.json();

    this.messagesTarget.innerHTML = ""; // Clear old messages if any

    results.forEach((result) => {
      const listItem = document.createElement("li");
      if (result.success) {
        listItem.textContent = `Row ${result.row}: Successful`;
        listItem.classList.add("text-green-500");
      } else {
        listItem.textContent = `Row ${result.row}: Error - ${result.error}`;
        listItem.classList.add("text-red-500");
      }
      this.messagesTarget.appendChild(listItem);
    });
  }
}
