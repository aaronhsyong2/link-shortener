import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const isDark = document.documentElement.classList.contains("dark");
    this.element.setAttribute("aria-pressed", isDark.toString());
  }

  toggle() {
    const isDark = document.documentElement.classList.toggle("dark");
    this.element.setAttribute("aria-pressed", isDark.toString());
    try {
      localStorage.setItem("theme", isDark ? "dark" : "light");
    } catch (e) {}
  }
}
