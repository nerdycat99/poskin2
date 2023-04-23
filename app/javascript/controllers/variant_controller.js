import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="variant"
export default class extends Controller {
  static targets = [
    "usesProductPricing"
  ]

  connect() {
  }

  useProductPricing(e) {
    console.log("hello to you")
    // var selectedOption = e.explicitOriginalTarget.selectedOptions[0].value;

    // if (selectedOption == "1") {
    //   this.hide(this.calculateCostPriceSectionTarget)
    //   this.show(this.calculateRetailPriceSectionTarget)
    // }

    // if (selectedOption == '0') {
    //   this.show(this.calculateCostPriceSectionTarget)
    //   this.hide(this.calculateRetailPriceSectionTarget)
    // }
  }
}
