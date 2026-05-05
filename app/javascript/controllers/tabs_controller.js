import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = { active: { type: String, default: "overview" } }

  connect() {
    const hash = window.location.hash.slice(1)
    if (hash && this.panelTargets.some(p => p.dataset.tab === hash)) {
      this.activeValue = hash
    }
    this.showActive()
  }

  switch(event) {
    event.preventDefault()
    this.activeValue = event.currentTarget.dataset.tab
    window.location.hash = this.activeValue
    this.showActive()
  }

  showActive() {
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.tab === this.activeValue
      tab.classList.toggle("tab-active", isActive)
      tab.classList.toggle("tab-inactive", !isActive)
    })
    this.panelTargets.forEach(panel => {
      panel.hidden = panel.dataset.tab !== this.activeValue
    })
  }
}
