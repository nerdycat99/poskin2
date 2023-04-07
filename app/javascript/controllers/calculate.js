import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // this.element.textContent = "Hello World!"
  }

  showTaxesAndTotals() {
    alert('This should populate the taxes and totals')
  }
}
