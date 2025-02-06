module Search
  class SearchService
    attr_reader :params

    def initialize(params = {})
      @params = params
    end

    def search_experiences
      experiences = Experience.active
      experiences = apply_text_search(experiences)
      experiences = apply_location_filter(experiences)
      experiences = apply_category_filter(experiences)
      experiences = apply_price_filter(experiences)
      experiences = apply_date_filter(experiences)
      experiences = apply_participants_filter(experiences)
      experiences = apply_sorting(experiences)
      experiences
    end

    private

    def apply_text_search(scope)
      return scope unless params[:query].present?

      scope.search_by_text(params[:query])
    end

    def apply_location_filter(scope)
      if params[:latitude].present? && params[:longitude].present?
        scope.near(
          [ params[:latitude], params[:longitude] ],
          params[:distance] || 20,
          units: :km
        )
      elsif params[:location].present?
        scope.search_by_location(params[:location])
      else
        scope
      end
    end

    def apply_category_filter(scope)
      return scope unless params[:category_id].present?

      scope.where(category_id: params[:category_id])
    end

    def apply_price_filter(scope)
      scope = scope.where("price >= ?", params[:min_price]) if params[:min_price].present?
      scope = scope.where("price <= ?", params[:max_price]) if params[:max_price].present?
      scope
    end

    def apply_date_filter(scope)
      return scope unless params[:date].present?

      scope.available_on(Date.parse(params[:date]))
    end

    def apply_participants_filter(scope)
      return scope unless params[:participants].present?

      scope.where("max_participants >= ?", params[:participants])
    end

    def apply_sorting(scope)
      case params[:sort]
      when "price_asc"
        scope.order(price: :asc)
      when "price_desc"
        scope.order(price: :desc)
      when "rating"
        scope.order(average_rating: :desc)
      else
        scope.order(created_at: :desc)
      end
    end
  end
end
