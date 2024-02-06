import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "name" ]

  // connect() {
  //   // console.log("Hello, Stimulus!", this.element)
  // }

  // greet() {
  //   const element = this.nameTarget
  //   const name = element.value
  //   console.log(`Hello, ${name}!`)
  // }

  testMe(e) {
    // 1 is Yes and 0 is No
    // var selectedOption = e.srcElement.selectedOptions[0].value;
    // var selectedOption = e.explicitOriginalTarget.selectedOptions[0].value;
    // console.log(selectedOption)
    // alert('Naughty Nerdy you have to build this!!')
  }
}
