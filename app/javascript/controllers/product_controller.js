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
    "retailPercentage",
    "retailCalculatedCostPrice",
    "retailCalculatedCostPriceTax",
    "retailCalculatedCostPriceTotal",
    "retailCalculatedRetailPrice",
    "retailCalculatedRetailPriceTax",
    "retailCalculatedRetailPriceTotal",
    "retailCalculatedMarkupAmount",
    "retailCalculatedProfitAmount",
    "retailCalculatedRetailTaxLiability"
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
      this.hide(this.calculateCostPriceSectionTarget)
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
    console.log('in here')
    var registeredForTax = (this.registeredForSalesTaxTarget.innerText === 'true')
    if (this.retailPercentageTarget.value && this.retailPriceTarget.value) {
      this.calculateAmountsForGivenRetailPrice(registeredForTax)
    }
  }

  calculateAmountsForGivenRetailPrice(registeredForTax) {
    var retailPrice = parseFloat(this.retailPriceTarget.value.replace('$','')).toFixed(2)
    var percentage = parseFloat(this.retailPercentageTarget.value.replace('%','')).toFixed(2)
    var percent = (percentage / 100.0)
    var total_percent =  percent + 1

    var costPrice = parseFloat(retailPrice / total_percent).toFixed(2)
    var costPriceTax = parseFloat(costPrice * 0.1).toFixed(2)
    var costPriceTotal = (parseFloat(costPrice) + parseFloat(costPriceTax)).toFixed(2)
    var markUpAmount = parseFloat(costPrice * percent).toFixed(2)
    var adjustedretailPrice = (parseFloat(costPrice) + parseFloat(markUpAmount)).toFixed(2)
    var retailPriceTax = parseFloat(adjustedretailPrice * 0.1).toFixed(2)
    var retailPriceTotal = (parseFloat(adjustedretailPrice) + parseFloat(retailPriceTax)).toFixed(2)

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

    this.retailCalculatedRetailPriceTarget.innerText = "$" + adjustedretailPrice
    if (registeredForTax) {
      this.retailCalculatedCostPriceTaxTarget.innerText = "$" + costPriceTax
      this.retailCalculatedCostPriceTotalTarget.innerText = "$" + costPriceTotal
    } else {
      this.retailCalculatedRetailPriceTaxTarget.innerText = "n/a"
      this.retailCalculatedRetailPriceTotalTarget.innerText = "n/a"
    }
    this.retailCalculatedCostPriceTarget.innerText = "$" + costPrice
    this.retailCalculatedMarkupAmountTarget.innerText = "$" + markUpAmount
    this.retailCalculatedRetailPriceTaxTarget.innerText = "$" + retailPriceTax
    this.retailCalculatedRetailPriceTotalTarget.innerText = "$" + retailPriceTotal
    this.retailCalculatedRetailTaxLiabilityTarget.innerText = "$" + parseFloat(retailTaxLiability).toFixed(2)
    this.retailCalculatedProfitAmountTarget.innerText = "$" + parseFloat(profit).toFixed(2)
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
