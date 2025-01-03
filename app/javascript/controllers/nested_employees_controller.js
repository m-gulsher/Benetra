import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];
  static values = { index: Number };

  connect() {
    if (!this.indexValue) {
      this.indexValue = this.containerTarget.children.length;
    }
  }

  addEmployee(event) {
    event.preventDefault();

    const template = `
      <div class="flex items-center space-x-4 bg-gray-50 p-4 rounded-md shadow" data-nested-employee="employee">
        <div class="flex-1">
          <label class="block text-gray-700 font-medium" for="company_employees_attributes_${this.indexValue}_name">Employee Name</label>
          <input type="text" name="company[employees_attributes][${this.indexValue}][name]" id="company_employees_attributes_${this.indexValue}_name" class="mt-1 block w-full p-2 border border-gray-300 rounded-md">
        </div>
        <div class="flex-1">
          <label class="block text-gray-700 font-medium" for="company_employees_attributes_${this.indexValue}_email">Employee Email</label>
          <input type="email" name="company[employees_attributes][${this.indexValue}][email]" id="company_employees_attributes_${this.indexValue}_email" class="mt-1 block w-full p-2 border border-gray-300 rounded-md">
        </div>
        <div>
          <input type="hidden" name="company[employees_attributes][${this.indexValue}][_destroy]" value="0" id="company_employees_attributes_${this.indexValue}__destroy">
          <label
            data-action="click->nested-employees#removeAgent"
            for="company_employees_attributes_${this.indexValue}__destroy"
            class="cursor-pointer text-red-500">
            <i class="bi bi-trash text-xl"></i>
          </label>
        </div>
      </div>
    `;

    this.containerTarget.insertAdjacentHTML("beforeend", template);
    this.indexValue++;
  }

  removeEmployee(event) {
    event.preventDefault();
    const destroyInput = event.target.closest("[data-nested-employee='employee']").querySelector("input[type='hidden']");
    destroyInput.value = "1";
    event.target.closest("[data-nested-employee='employee']").style.display = "none";
  }
}
