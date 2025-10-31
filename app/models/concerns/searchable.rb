module Searchable
  extend ActiveSupport::Concern

  module ClassMethods
    def search_by(search_term, *fields)
      return all if search_term.blank?

      search_pattern = "%#{search_term}%"
      conditions = fields.map { |field| "#{table_name}.#{field} ILIKE ?" }.join(" OR ")
      values = [search_pattern] * fields.length

      where(conditions, *values)
    end

    def filter_by(attribute, value)
      return all if value.blank?

      where(attribute => value)
    end

    def search_and_filter(search_term, filter_params, *search_fields)
      results = all

      results = results.search_by(search_term, *search_fields) if search_term.present?

      filter_params.each do |key, value|
        next if value.blank?
        results = results.filter_by(key, value)
      end

      results
    end

    def paginated(page: 1, per_page: 20)
      page = page.to_i
      per_page = per_page.to_i
      page = 1 if page < 1
      per_page = 20 if per_page < 1 || per_page > 100

      limit(per_page).offset((page - 1) * per_page)
    end

    def total_pages(per_page: 20)
      per_page = per_page.to_i
      per_page = 20 if per_page < 1 || per_page > 100

      (count.to_f / per_page).ceil
    end
  end
end
