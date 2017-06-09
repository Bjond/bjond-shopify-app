class CreateShopifyConfigurations < ActiveRecord::Migration
  def change
    create_table :shopify_configurations do |t|
      t.string :api_key
      t.string :api_secret
      t.string :bjond_registration_id
      t.string :group_id
      t.string :sample_person_id

      t.timestamps null: false
    end
  end
end
