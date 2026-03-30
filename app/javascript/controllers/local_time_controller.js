import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const iso = this.element.getAttribute("datetime");
    if (!iso) return;

    const date = new Date(iso);
    this.element.textContent = date.toLocaleString();
  }
}
