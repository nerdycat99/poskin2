import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "deliveryAmount",
    "discountAmount",
    "totalAmount",
    "totalWithoutDeliveryOrDiscount"
  ]

  connect() {
    // this.element.textContent = "Hello World!"
  }

  testMe() {
    alert('this is sales')
  }

  discountAmountEntered() {
    this.adjustTotalShown()
  }

  deliveryAmountEntered() {
    this.adjustTotalShown()
  }

  adjustTotalShown() {
    var currenttotalAmountUnsanitized = this.totalWithoutDeliveryOrDiscountTarget.innerText.replace('$','')
    var currenttotalAmount = currenttotalAmountUnsanitized.replace(',','')
    // var currenttotalAmount = parseFloat(currenttotalAmountUnsanitized.replace(',','')).toFixed(2)

    var enteredDiscountAmountUnsanitized = this.discountAmountTarget.value.replace('$','')
    var enteredDiscountAmount = enteredDiscountAmountUnsanitized.replace(',','')
    // var enteredDiscountAmount = parseFloat(enteredDiscountAmountUnsanitized.replace(',','')).toFixed(2)

    var enteredDeliveryAmountUnsanitized = this.deliveryAmountTarget.value.replace('$','')
    var enteredDeliveryAmount = enteredDeliveryAmountUnsanitized.replace(',','')
    // var enteredDeliveryAmount = parseFloat(enteredDeliveryAmountUnsanitized.replace(',','')).toFixed(2)



    console.log(+currenttotalAmount)
    console.log(+enteredDiscountAmount)
    console.log(+enteredDeliveryAmount)
    var newtotalAmount = ((+currenttotalAmount) + (+enteredDeliveryAmount)) - (+enteredDiscountAmount)
    console.log(newtotalAmount)
    // var newtotalAmount = parseFloat(currenttotalAmount - enteredDiscountAmount + enteredDeliveryAmount).toFixed(2)
    this.totalAmountTarget.value = "$" + parseFloat(newtotalAmount).toFixed(2)
  }

}

