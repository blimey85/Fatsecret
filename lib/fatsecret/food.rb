class FatSecret
  module Food

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      def autocomplete_food(expression, max_results=4)
        query = {
          :method => 'foods.autocomplete',
          :expression => expression.esc,
          :max_results => max_results
        }
        get(query)
      end

      def food_id_for_barcode(barcode)
        query = {
          :method => 'food.find_id_for_barcode',
          :barcode => barcode
        }
        get(query)
      end

      def search_food(expression, page_number=0, max_results=20)
        query = {
          :method => 'foods.search',
          :search_expression => expression.esc,
          :page_number => page_number,
          :max_results => max_results
        }
        get(query)
      end

      def food(id)
        query = {
          :method => 'food.get',
          :food_id => id
        }
        get(query)
      end

      def carbs_per_cup_food(id)
        f = food(id)["food"]
        s = f["servings"]["serving"]

        s = [s] unless s.kind_of? Array

        carbs_per_cup = nil

        cups_servings = s.select do |serving|
          serving["serving_description"].include?("1 cup") ||
          serving["serving_description"].include?("1/2 cup") ||
          serving["serving_description"].include?("1/4 cup")
        end

        if cups_servings.any? && cups_servings.first["serving_description"].include?("1 cup")
          carbs_per_cup = cups_servings.first["carbohydrate"].to_i
        end

        if cups_servings.any? && cups_servings.first["serving_description"].include?("1/2 cup")
          carbs_per_cup = cups_servings.first["carbohydrate"].to_i * 2
        end

        if cups_servings.any? && cups_servings.first["serving_description"].include?("1/4 cup")
          carbs_per_cup = cups_servings.first["carbohydrate"].to_i * 4
        end

        {
          "food" => {
            "food_id" => f["food_id"],
            "food_name" => f["food_name"],
            "carbohydrate" => carbs_per_cup,
            "measurement" => "1 cup"
          }
        }

      end

      # Returns an array of servings and related carbs
      def carbs_per_servings(id)
        f = food(id)["food"]
        s = f["servings"]["serving"]

        s = [s] unless s.kind_of? Array

        servings = s.map do |serving|
          {
            "serving_description" => serving["serving_description"],
            "carbohydrate" => serving["carbohydrate"]
          }
        end

        {
          "food" => {
            "food_id"     => f["food_id"],
            "food_name"   => f["food_name"],
            "servings"    => servings
          }
        }
      end
    end

  end
end
