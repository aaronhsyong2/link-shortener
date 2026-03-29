import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { shortUrl: String };

  copy() {
    navigator.clipboard.writeText(this.shortUrlValue).then(() => {
      const original = this.element.textContent;
      this.element.textContent = "Copied!";
      setTimeout(() => {
        this.element.textContent = original;
      }, 2000);
    });
  }
}
