class OrdersController < ApplicationController

  require 'bjond-api'
  skip_before_filter :verify_authenticity_token, :only => [:creation]

  def creation
    config = BjondApi::BjondAppConfig.instance

    customer_city = params['billing_address']['city']
    customer_last_name = params['billing_address']['last_name']
    customer_first_name = params['billing_address']['first_name']
    event_data = {
      :customerLastName => customer_last_name,
      :customerFirstName => customer_first_name,
      :customerCity => customer_city
    }
    BjondRegistration.all.each do |r|
      ap r
      shopifyConfig = ShopifyConfiguration.find_by_bjond_registration_id(r.id)
      if (shopifyConfig.nil?)
        puts "No shopify configuration found with registration with id #{r.id}. Skipping..."
        next
      elsif (shopifyConfig.sample_person_id.nil?)
        puts "No shopify person ID found for shopify config with id #{shopifyConfig.id}. You can add one as a tenant admin in the Bjond admin settings, on the Integration tab. Skipping..."
      else
        puts "Found shopify configuration #{shopifyConfig.id} with registration #{r.id}. Using sample person #{shopifyConfig.sample_person_id}"
      end
      event_data[:bjondPersonId]     = shopifyConfig.sample_person_id
      puts event_data.to_json
      puts "firing now!"

      ### Make web requests to Bjond on a separate thread to reduce callback time.
      Thread.new do 
        begin
          BjondApi::fire_event(r, event_data.to_json, config.active_definition.integrationEvent.first.id)
        rescue StandardError => bang
          puts "Encountered an error when firing event associated with BjondRegistration with id: "
          puts r.id
          puts bang
        end
      end
    end
    render :json => {
      :status => 'OK'
    }
  end

end
