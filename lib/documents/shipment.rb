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

            if (@shipment['has_gift_message'].present? && @shipment['has_gift_message'])
              xml.AdCode('NOURCARD')
              xml.Custom_Gift_To( @shipment['gift_to'] )
              xml.Custom_Gift_From( @shipment['gift_from'] )
              xml.Custom_Gift_Message( @shipment['gift_message'] )
            else
              xml.AdCode(@shipment['adcode'] || @config['adcode'])
            end

            xml.Prepaid('Y')
            xml.ShipFirstname(truncate_name( @shipment['shipping_address']['firstname']) )
            xml.ShipLastname(truncate_name( @shipment['shipping_address']['lastname']) )

            if (@shipment['shipping_address']['company'].present?)
              xml.ShipAddress1( truncate_address(@shipment['shipping_address']['company']) )
              xml.ShipAddress2( truncate_address(@shipment['shipping_address']['address1']) )
              xml.ShipAddress3( truncate_address(@shipment['shipping_address']['address2']) )
            else
              xml.ShipAddress1(truncate_address(@shipment['shipping_address']['address1']))
              xml.ShipAddress2(truncate_address(@shipment['shipping_address']['address2']))
            end

            xml.ShipCity( truncate_city(@shipment['shipping_address']['city']) )

            # Use "ShipStateOther" field for international orders
            if (@shipment['shipping_address']['country'] != 'US')
              xml.ShipStateOther( ship_state(@shipment['shipping_address']['state']) )
            else
              xml.ShipState( ship_state(@shipment['shipping_address']['state']) )
            end

            xml.ShipZip(@shipment['shipping_address']['zipcode'])
            xml.ShipCountry(@shipment['shipping_address']['country'])
            xml.ShipPhone(@shipment['shipping_address']['phone'])

            xml.BillFirstname(truncate_name( @shipment['billing_address']['firstname']) )
            xml.BillLastname(truncate_name( @shipment['billing_address']['lastname']) )

            if (@shipment['billing_address']['company'].present?)
              xml.BillAddress1( truncate_address(@shipment['billing_address']['company']) )
              xml.BillAddress2( truncate_address(@shipment['billing_address']['address1']) )
              xml.BillAddress3( truncate_address(@shipment['billing_address']['address2']) )
            else
              xml.BillAddress1( truncate_address(@shipment['billing_address']['address1']) )
              xml.BillAddress2( truncate_address(@shipment['billing_address']['address2']) )
            end

            xml.BillCity( truncate_city(@shipment['billing_address']['city']) )

            # Use "BillStateOther" field for international orders
            if (@shipment['billing_address']['country'] != 'US')
              xml.BillStateOther( ship_state(@shipment['billing_address']['state'] ))
            else
              xml.BillState( ship_state(@shipment['billing_address']['state']) )
            end

            xml.BillZip(@shipment['billing_address']['zipcode'])
            xml.BillCountry(@shipment['billing_address']['country'])
            xml.BillPhone(@shipment['billing_address']['phone'])


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
    def truncate_name(name)
      if name.length > 11
        name.slice 0..11
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

    def truncate_city(city)
      if city.length > 12
        city.slice 0..12
      else
        city
      end
    end

    def truncate_address(address)
      if address.length > 30
        address.slice 0..30
      else
        address
      end
    end

    def ship_state(state)
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
