import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="variant"
export default class extends Controller {
  static targets = [
    "usesProductPricing",
    "priceCalcMethodSelector",
    "registeredForSalesTax",
    "costPrice",
    "markup",
    "retailPrice",
    "calculateCostPriceSection",
    "calculateRetailPriceSection",
    "calculatedRetailTaxLiability",
    "calculatedProfitAmount",
    "calculatedMarkupAmount",
    "calculatedRetailPriceTotal",
    "calculatedRetailPriceTax",
    "calculatedRetailPrice",
    "calculatedCostPriceTotal",
    "calculatedCostPriceTax",
    "calculatedCostPrice",
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
    var submitBtn = document.getElementsByClassName("btn btn-primary")
    submitBtn[0].disabled = true

    // run the calculations on load
    var registeredForTax = (this.registeredForSalesTaxTarget.innerText === 'true')

    if (this.markupTarget.value && this.costPriceTarget.value) {
      this.calculateAmountsForGivenCostPrice(registeredForTax)
    }
    if (this.retailPercentageTarget.value && this.retailPriceTarget.value) {
      this.calculateAmountsForGivenRetailPrice(registeredForTax)
    }
  }

  enableSubmitButton(title) {
    var submitBtn = document.getElementsByClassName("btn btn-primary")
    submitBtn[0].disabled = false
    submitBtn[0].innerText = title
  }

  disableSubmitButton(title) {
    var submitBtn = document.getElementsByClassName("btn btn-primary")
    submitBtn[0].disabled = true
    submitBtn[0].innerText = title
  }

  // NB: retail is 1 and cost price is 0
  selectPriceCalcMethod(e) {
    this.enableSubmitButton('Create Variant')
    var selectedOption = e.srcElement.selectedOptions[0].value;

    if (selectedOption == '1') {
      console.log('show retail')
      this.calculateCostPriceSectionTarget.hidden = true
      this.calculateRetailPriceSectionTarget.hidden = false
    }
    else if (selectedOption == '0') {
      console.log('show cost price')
      this.calculateCostPriceSectionTarget.hidden = false
      this.calculateRetailPriceSectionTarget.hidden = true
    }
    else {
      this.disableSubmitButton('Create Variant')
      this.calculateCostPriceSectionTarget.hidden = true
      this.calculateRetailPriceSectionTarget.hidden = true
    }
  }

  // NB: 1 is Yes, 0 No
  useProductPricing(e) {
    var selectedOption = e.srcElement.selectedOptions[0].value;
    if (selectedOption == '1') {
      this.enableSubmitButton('Create Variant')
    }
    if (selectedOption == '0') {
      this.enableSubmitButton('Next')
    }
  }

  costPriceDataEntered() {
    var registeredForTax = (this.registeredForSalesTaxTarget.innerText === 'true')
    if (this.markupTarget.value && this.costPriceTarget.value) {
      this.calculateAmountsForGivenCostPrice(registeredForTax)
    }
  }

  retailPriceDataEntered() {
    var registeredForTax = (this.registeredForSalesTaxTarget.innerText === 'true')
    if (this.retailPercentageTarget.value && this.retailPriceTarget.value) {
      this.calculateAmountsForGivenRetailPrice(registeredForTax)
    }
  }

  // TO DO: we need to pass in the applicable sales tax for product NOT hardcode as 10%!!
  calculateAmountsForGivenRetailPrice(registeredForTax) {
    var retailPriceTotalUnsanitized = this.retailPriceTarget.value.replace('$','')
    var retailPriceTotal = parseFloat(retailPriceTotalUnsanitized.replace(',','')).toFixed(2)
    var percentage = parseFloat(this.retailPercentageTarget.value.replace('%','')).toFixed(2)
    var percent = (percentage / 100.0)
    var total_percent =  percent + 1

    var retailPrice = parseFloat(retailPriceTotal / 1.1).toFixed(2)
    var retailPriceTax = (parseFloat(retailPriceTotal) - parseFloat(retailPrice)).toFixed(2)

    var costPrice = (Math.round( parseFloat(retailPrice / total_percent) * 100 ) / 100).toFixed(2);
    var costPriceTax = parseFloat(costPrice * 0.1).toFixed(2)
    var costPriceTotal = (parseFloat(costPrice) + parseFloat(costPriceTax)).toFixed(2)

    var markUpAmount = (parseFloat(retailPrice) - parseFloat(costPrice)).toFixed(2)

    var totalCostsForSale = 0.0
    var retailTaxLiability = 0.0

    if (registeredForTax) {
      retailTaxLiability = retailPriceTax - costPriceTax
      totalCostsForSale = parseFloat(retailTaxLiability) + parseFloat(costPriceTotal)
    } else {
      retailTaxLiability = retailPriceTax
      totalCostsForSale = parseFloat(retailTaxLiability) + parseFloat(costPrice)
    }
    var profit = retailPriceTotal - totalCostsForSale

    this.retailCalculatedRetailPriceTarget.innerText = "$" + retailPrice

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
    this.markupTarget.value = this.retailPercentageTarget.value
  }

  calculateAmountsForGivenCostPrice(registeredForTax) {
    var costPrice = parseFloat(this.costPriceTarget.value.replace('$','')).toFixed(2)
    var percentage = parseFloat(this.markupTarget.value.replace('%','')).toFixed(2)
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
      retailTaxLiability = retailPriceTax - costPriceTax
      totalCostsForSale = retailTaxLiability + parseFloat(costPriceTotal)
    } else {
      retailTaxLiability = retailPriceTax
      totalCostsForSale = parseFloat(retailTaxLiability) + parseFloat(costPrice)
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
}
