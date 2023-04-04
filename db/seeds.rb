# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Default Country codes
Country.find_or_create_by({ country: "Australia", code: "AUD" })
Country.find_or_create_by({ country: "New Zealand", code: "NZL" })

# Default Tax Rates for GST
TaxRate.find_or_create_by({ rate: "10", name: "standard" })
TaxRate.find_or_create_by({ rate: "0", name: "none" })

# Default Accounting Codes
AccountingCode.find_or_create_by({ name: "CONS001", enabled: true, description: "Consignment" })

# Default Product Attribute Types
ProductAttributeType.find_or_create_by({ name: "size" })
ProductAttributeType.find_or_create_by({ name: "colour" })
ProductAttributeType.find_or_create_by({ name: "artists_code" })