module Documents
  class Shipment
    def initialize(shipment, config)
      @shipment = shipment
      @config   = config
    end

    def to_xml
      builder = Nokogiri::XML::Builder.new do |xml|
        xml.UnitycartOrderPost('xml:lang' => 'en-US') {
          xml.ClientCode(@config['client_code'])
          xml.Test('Y') if test?
          xml.TransactionID(SecureRandom.hex(15))
          xml.Order {
            xml.ShippingMethod(@shipment['shipping_method'])
            xml.Subtotal(0)
            xml.Total(0)
            xml.ExternalID("#{@shipment['id']}")
            xml.AdCode(@shipment['adcode'] || @config['adcode'])
            xml.Prepaid('Y')
            xml.ShipFirstname truncate_name
            xml.ShipLastname(@shipment['shipping_address']['lastname'])
            xml.ShipAddress1(@shipment['shipping_address']['address1'])
            xml.ShipAddress2(@shipment['shipping_address']['address2'])
            xml.ShipCity(truncate_city)

            # Use "ShipStateOther" field for international orders
            if (@shipment['shipping_address']['country'] !== 'US') {
              xml.ShipState('')
              xml.ShipStateOther(ship_state)
            } else {
              xml.ShipState(ship_state)
            }

            xml.ShipZip(@shipment['shipping_address']['zipcode'])
            xml.ShipPhone(@shipment['shipping_address']['phone'])
            xml.Email(@shipment['email'])
            xml.Code(@shipment['shipping_method_code'])

            # check if all Custom1 through Custom5
            # are present and include in the xml
            #
            (1..5).each do |i|
              next unless @shipment.key? "custom#{i}"
              xml.send("Custom#{i}", @shipment["custom#{i}"])
            end

            xml.Items {
              @shipment['items'].each_with_index do |item, index|
                xml.Item {
                  xml.Inv item['product_id']
                  xml.Qty item['quantity']
                  xml.PricePer 0
                }
              end
            }
          }
        }
      end

      builder.to_xml
    end

    private
    def truncate_name
      name = @shipment['shipping_address']['firstname']

      if name.length > 15
        name.slice 0..15
      else
        name
      end
    end

    def test?
      case @config['test'].to_i
      when 1
        true
      else
        false
      end
    end

    def truncate_city
      city = @shipment['shipping_address']['city']

      if city.length > 12
        city.slice 0..12
      else
        city
      end
    end

    def ship_state
      state = @shipment['shipping_address']['state']

      case state
      when 'U.S. Armed Forces – Americas'
        'AA'
      when 'U.S. Armed Forces – Europe'
        'AE'
      when 'U.S. Armed Forces – Pacific'
        'AP'
      else
        ModelUN.convert_state_name state
      end
    end
  end
end
