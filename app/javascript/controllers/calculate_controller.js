import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // this.element.textContent = "Hello World!"
  }

  testMe() {
    alert('It works in here too!!')
  }

  showTaxesAndTotals() {
    console.log('i ran!!!')
    // alert('This should populate the taxes and totals')
  }
}
