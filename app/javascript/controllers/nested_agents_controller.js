import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];
  static values = { index: Number };

  connect() {
    if (!this.indexValue) {
      this.indexValue = this.containerTarget.children.length;
    }
  }

  addAgent(event) {
    event.preventDefault();

    const template = `
      <div class="flex items-center space-x-4 bg-gray-50 p-4 rounded-md shadow" data-nested-agent="agent">
        <div class="flex-1">
          <label class="block text-gray-700 font-medium" for="agency_agents_attributes_${this.indexValue}_name">Agent Name</label>
          <input type="text" name="agency[agents_attributes][${this.indexValue}][name]" id="agency_agents_attributes_${this.indexValue}_name" class="mt-1 block w-full p-2 border border-gray-300 rounded-md">
        </div>
        <div class="flex-1">
          <label class="block text-gray-700 font-medium" for="agency_agents_attributes_${this.indexValue}_email">Agent Email</label>
          <input type="email" name="agency[agents_attributes][${this.indexValue}][email]" id="agency_agents_attributes_${this.indexValue}_email" class="mt-1 block w-full p-2 border border-gray-300 rounded-md">
        </div>
        <div>
          <input type="hidden" name="agency[agents_attributes][${this.indexValue}][_destroy]" value="0" id="agency_agents_attributes_${this.indexValue}__destroy">
          <label
            data-action="click->nested-agents#removeAgent"
            for="agency_agents_attributes_${this.indexValue}__destroy"
            class="cursor-pointer text-red-500">
            <i class="bi bi-trash text-xl"></i>
          </label>
        </div>
      </div>
    `;

    this.containerTarget.insertAdjacentHTML("beforeend", template);
    this.indexValue++;
  }

  removeAgent(event) {
    event.preventDefault();
    const destroyInput = event.target.closest("[data-nested-agent='agent']").querySelector("input[type='hidden']");
    destroyInput.value = "1";
    event.target.closest("[data-nested-agent='agent']").style.display = "none";
  }
}
