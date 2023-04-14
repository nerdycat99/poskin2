import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="product"
export default class extends Controller {
    static targets = [
    "calculateRetailPriceSection",
    "calculateCostPriceSection",
    "registeredForSalesTax",
    "calculatedRetailTaxLiability",
    "calculatedProfitAmount",
    "calculatedMarkupAmount",
    "calculatedRetailPriceTotal",
    "calculatedRetailPriceTax",
    "calculatedRetailPrice",
    "calculatedCostPriceTotal",
    "calculatedCostPriceTax",
    "calculatedCostPrice",
    "costPrice",
    "percentage",
    "retailPrice",
    "retailPercentage"
  ]
  connect() {
  }

  selectSection(e) {
    var selectedOption = e.explicitOriginalTarget.selectedOptions[0].value;

    if (selectedOption == "1") {
      this.hide(this.calculateCostPriceSectionTarget)
      this.show(this.calculateRetailPriceSectionTarget)
    }

    if (selectedOption == '2') {
      this.show(this.calculateCostPriceSectionTarget)
      this.hide(this.calculateRetailPriceSectionTarget)
    }

    if (selectedOption == '0') {
      this.hide(this.calculateCostPriceSectionTarget.innerText)
      this.hide(this.calculateRetailPriceSectionTarget)
    }
  }

  costPriceDataEntered() {
    var registeredForTax = (this.registeredForSalesTaxTarget.innerText === 'true')
    if (this.percentageTarget.value && this.costPriceTarget.value) {
      this.calculateAmountsForGivenCostPrice(registeredForTax)
    }
  }

  retailPriceDataEntered() {
    // console.log(typeof this.registeredForSalesTaxTarget.innerText === 'string')
    // console.log(this.registeredForSalesTaxTarget)
  }

  calculateAmountsForGivenCostPrice(registeredForTax) {
    var costPrice = parseFloat(this.costPriceTarget.value.replace('$','')).toFixed(2)
    var percentage = parseFloat(this.percentageTarget.value.replace('%','')).toFixed(2)
    var percent = percentage / 100.0

    var costPriceTax = parseFloat(costPrice * 0.1).toFixed(2)
    var costPriceTotal = (parseFloat(costPrice) + parseFloat(costPriceTax)).toFixed(2)
    var markUpAmount = parseFloat((costPrice * percent).toFixed(2))

    var retailPrice = markUpAmount + parseFloat(costPrice)
    var retailPriceTax = parseFloat(retailPrice * 0.1).toFixed(2)
    var retailPriceTotal = (retailPrice + parseFloat(retailPriceTax)).toFixed(2)

    var totalCostsForSale = 0.0
    var retailTaxLiability = 0.0

    if (registeredForTax) {
      totalCostsForSale = retailTaxLiability + parseFloat(costPriceTotal)
      retailTaxLiability = retailPriceTax - costPriceTax
    } else {
      totalCostsForSale = retailTaxLiability + parseFloat(costPrice)
      retailTaxLiability = retailPriceTax
    }

    var profit = retailPriceTotal - totalCostsForSale

    this.calculatedCostPriceTarget.innerText = "$" + costPrice
    if (registeredForTax) {
      this.calculatedCostPriceTaxTarget.innerText = "$" + costPriceTax
      this.calculatedCostPriceTotalTarget.innerText = "$" + costPriceTotal
    } else {
      this.calculatedCostPriceTaxTarget.innerText = "n/a"
      this.calculatedCostPriceTotalTarget.innerText = "n/a"
    }
    // this.calculatedCostPriceTaxTarget.innerText = "$" + costPriceTax
    // this.calculatedCostPriceTotalTarget.innerText = "$" + costPriceTotal

    this.calculatedMarkupAmountTarget.innerText = "$" + parseFloat(markUpAmount).toFixed(2)

    this.calculatedRetailPriceTarget.innerText = "$" + parseFloat(retailPrice).toFixed(2)
    this.calculatedRetailPriceTaxTarget.innerText = "$" + retailPriceTax
    this.calculatedRetailPriceTotalTarget.innerText = "$" + retailPriceTotal
    this.calculatedRetailTaxLiabilityTarget.innerText = "$" + parseFloat(retailTaxLiability).toFixed(2)
    this.calculatedProfitAmountTarget.innerText = "$" + parseFloat(profit).toFixed(2)
  }

  show(target) {
    target.classList.remove("d-none")
  }

  hide(target) {
    target.classList.add("d-none")
  }




}
