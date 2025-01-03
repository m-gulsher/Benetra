import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];
  static values = { index: Number };

  connect() {
    if (!this.indexValue) {
      this.indexValue = this.containerTarget.children.length;
    }
  }

  addPolicy(event) {
    event.preventDefault();

    const template = `
      <div class="flex items-center space-x-4 bg-gray-50 p-4 rounded-md shadow" data-nested-policy="policy">
        <div class="flex-1">
          <label class="block text-gray-700 font-medium" for="company_policies_attributes_${this.indexValue}_title">Policy Title</label>
          <input type="text" name="company[policies_attributes][${this.indexValue}][name]" id="company_policies_attributes_${this.indexValue}_title" class="mt-1 block w-full p-2 border border-gray-300 rounded-md">
        </div>
        <div class="flex-1">
          <label class="block text-gray-700 font-medium" for="company_policies_attributes_${this.indexValue}_description">Policy Description</label>
          <textarea name="company[policies_attributes][${this.indexValue}][description]" id="company_policies_attributes_${this.indexValue}_description" class="mt-1 block w-full p-2 border border-gray-300 rounded-md"></textarea>
        </div>
        <div>
          <input type="hidden" name="company[policies_attributes][${this.indexValue}][_destroy]" value="0" id="company_policies_attributes_${this.indexValue}__destroy">
          <label
            data-action="click->nested-policies#removePolicy"
            for="company_policies_attributes_${this.indexValue}__destroy"
            class="cursor-pointer text-red-500">
            <i class="bi bi-trash text-xl"></i>
          </label>
        </div>
      </div>
    `;

    this.containerTarget.insertAdjacentHTML("beforeend", template);
    this.indexValue++;
  }

  removePolicy(event) {
    event.preventDefault();
    const destroyInput = event.target.closest("[data-nested-policy='policy']").querySelector("input[type='hidden']");
    destroyInput.value = "1";
    event.target.closest("[data-nested-policy='policy']").style.display = "none";
  }
}
