require 'bjond-api'



config = BjondApi::BjondAppConfig.instance

config.group_configuration_schema = {
  :id => 'urn:jsonschema:com:bjond:persistence:bjondservice:GroupConfiguration',
  :title => 'bjond-shopify-app-schema',
  :type  => 'object',
  :properties => {
    :api_key => {
      :type => 'string',
      :description => 'Shopify API Key',
      :title => 'Shopify API Key'
    },
    :sample_person_id => {
      :type => 'string',
      :description => 'Bjönd Person ID. This can be any person ID in the tenant.',
      :title => 'Bjönd Person ID'
    }
  },
  :required => ['sample_field']
}.to_json

config.encryption_key_name = 'SHOPIFY_ENCRYPTION_KEY'

def config.configure_group(result, bjond_registration, groupid)
  shopify_config = ShopifyConfiguration.find_or_initialize_by(:bjond_registration_id => bjond_registration.id, :group_id => groupid)
  if (shopify_config.api_key != result['api_key'] || shopify_config.api_secret != result['api_secret'] || shopify_config.sample_person_id != result['sample_person_id'])
    shopify_config.api_key = result['api_key'] 
    shopify_config.api_secret = result['api_secret']
    shopify_config.sample_person_id = result['sample_person_id']
    shopify_config.save
  end
  return shopify_config
end

def config.get_group_configuration(bjond_registration, group_id)
  shopify_config = ShopifyConfiguration.find_by_bjond_registration_id_and_group_id(bjond_registration.id, group_id)
  if (shopify_config.nil?)
    puts 'No configuration has been saved yet.'
    return {:api_secret => '', :sample_person_id => '', :api_key => ''}
  else
    return shopify_config
  end
end

### The integration app definition is sent to Bjond-Server core during registration.
config.active_definition = BjondApi::BjondAppDefinition.new.tap do |app_def|
  app_def.id           = 'b93dc2ef-f791-48d1-b34c-cfdf11abcba7'
  app_def.author       = 'Bjönd, Inc.'
  app_def.name         = 'Bjönd Shopify App'
  app_def.description  = 'Bjönd interface with Shopify API.'
  app_def.iconURL      = 'https://cdn.shopify.com/assets/images/logos/shopify-bag.png'
  app_def.integrationEvent = [
    BjondApi::BjondEvent.new.tap do |e|
      e.id = '01e30e93-c7c6-4f74-af93-88bf26ef8da0'
      e.jsonKey = 'orderCreatedEvent'
      e.name = 'Order Created'
      e.description = 'Shopify order has been created'
      e.serviceId = app_def.id
      e.fields = [
        BjondApi::BjondField.new.tap do |f|
          f.id = '43bd9d37-4ccf-466b-8adc-ae1d65778c97'
          f.jsonKey = 'bjondPersonId'
          f.name = 'Person'
          f.description = 'The person identifier'
          f.fieldType = 'Person'
          f.event = e.id
        end,
        BjondApi::BjondField.new.tap do |f|
          f.id = 'efcb95f2-ee96-46e6-9463-1075e98e9910'
          f.jsonKey = 'customerLastName'
          f.name = 'Customer Last Name'
          f.description = 'Billing last name'
          f.fieldType = 'String'
          f.event = e.id
        end,
        BjondApi::BjondField.new.tap do |f|
          f.id = '4b3052d4-0cec-42f4-9bdb-9056d52ead97'
          f.jsonKey = 'customerFirstName'
          f.name = 'String'
          f.description = 'Customer first name'
          f.fieldType = 'String'
          f.event = e.id
        end,
        BjondApi::BjondField.new.tap do |f|
          f.id = 'db2d515c-4eab-4aee-a2b6-47bfcc888e1f'
          f.jsonKey = 'customerCity'
          f.name = 'String'
          f.description = 'Customer city'
          f.fieldType = 'String'
          f.event = e.id
        end
      ]
    end,
    

  ]
end
