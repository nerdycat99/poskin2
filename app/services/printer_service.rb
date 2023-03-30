# frozen_string_literal: true

require 'cupsffi'

class PrinterService
  # attr_accessor :layer, :layer_uid, :responses, :assessment

  def initialize

  end

  def printers
    @printers ||= CupsPrinter.get_all_printer_names
  end

  def printer
    @printer ||= CupsPrinter.new(printers.first)
  end

  def print
    printer.print_data(text, "text/plain", options)
  end

  def print_file
    printer.print_file('./tmp/tester.pdf', options)
  end

  def options
    # cpi=10 and lpi=6.


    {
      'ColorModel': 'Gray',
      'cupsPrintQuality': 'Normal',
      'PageSize': 'A4'
    }
    # CupsPPD.new(printers.first, nil).options
  end

  def text
    "Australian Glass\r\n\r\nFancy Glass Vase $900\r\nGlass Teapot $250\r\n\r\nItem Total $1,150\r\nGST $115\r\nTotal $1,265\r\n\r\nwww.australian-glass.com.au\r\nABN: 123456789\r\n 29 July 22:30".encode(
      "ascii",
      invalid: :replace,
      undef: :replace,
      replace: ''
    )
  end
end
