import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "calculateRetailPriceSection",
    "calculateCostPriceSection",
    "selectCalculateMethodSection",
    "usesProductPricing",
    "priceCalcMethod",
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
    // used for determining whether a variant should use the product details or not
    if (this.usesProductPricingTarget.value == '1') {
      this.show(this.selectCalculateMethodSectionTarget)
    } else {
      this.hide(this.selectCalculateMethodSectionTarget)
    }

    var registeredForTax = (this.registeredForSalesTaxTarget.innerText === 'true')

    if (this.priceCalcMethodTarget.value == '0') {
      this.show(this.calculateCostPriceSectionTarget)
      this.hide(this.calculateRetailPriceSectionTarget)

      // run the calculations if the values are populated on load
      if (this.percentageTarget.value && this.costPriceTarget.value) {
        this.calculateAmountsForGivenCostPrice(registeredForTax)
      }
    }

    if (this.priceCalcMethodTarget.value == '1') {
      this.hide(this.calculateCostPriceSectionTarget)
      this.show(this.calculateRetailPriceSectionTarget)

      // run the calculations if the values are populated on load
      if (this.retailPercentageTarget.value && this.retailPriceTarget.value) {
        this.calculateAmountsForGivenRetailPrice(registeredForTax)
      }
    }
  }

  useProductPricing(e) {
    var useProductData = e.explicitOriginalTarget.selectedOptions[0].value;
    if (useProductData == "1") {
      this.show(this.selectCalculateMethodSectionTarget)
    } else {
      this.hide(this.selectCalculateMethodSectionTarget)
    }
  }

  selectSection(e) {
    var selectedOption = e.explicitOriginalTarget.selectedOptions[0].value;

    if (selectedOption == "1") {
      this.hide(this.calculateCostPriceSectionTarget)
      this.show(this.calculateRetailPriceSectionTarget)
    }

    if (selectedOption == '0') {
      this.show(this.calculateCostPriceSectionTarget)
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

    // var costPrice = parseFloat(retailPrice / total_percent).toFixed(2)

    var costPrice = (Math.round( parseFloat(retailPrice / total_percent) * 100 ) / 100).toFixed(2);
    var costPriceTax = parseFloat(costPrice * 0.1).toFixed(2)
    var costPriceTotal = (parseFloat(costPrice) + parseFloat(costPriceTax)).toFixed(2)

    // var markUpAmount = parseFloat(costPrice * percent).toFixed(2)
    var markUpAmount = (parseFloat(retailPrice) - parseFloat(costPrice)).toFixed(2)

    // var adjustedretailPrice = (parseFloat(costPrice) + parseFloat(markUpAmount)).toFixed(2)

    // var retailPriceTax = parseFloat(adjustedretailPrice * 0.1).toFixed(2)
    // var retailPriceTotal = (parseFloat(adjustedretailPrice) + parseFloat(retailPriceTax)).toFixed(2)

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
    // this.retailCalculatedRetailPriceTarget.innerText = "$" + adjustedretailPrice
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
    this.percentageTarget.value = this.retailPercentageTarget.value
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

  show(target) {
    target.classList.remove("d-none")
  }

  hide(target) {
    target.classList.add("d-none")
  }
}
