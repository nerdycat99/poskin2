import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // this.element.textContent = "Hello World!"
  }

  testMe() {
    alert('Naughty Nerdy you have to build this!!')
  }
}
