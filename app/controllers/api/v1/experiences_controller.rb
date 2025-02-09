
class Api::V1::ExperiencesController < Api::BaseController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_experience, only: %i[show update destroy]
  before_action :authorize_host!, only: %i[create update destroy]

  def index
    @experiences = Experience.includes(:host, :category)
                             .active
                             .search(search_params)
                             .filter_record(filter_params)
                             .page(params[:page])
                             .per(params[:per_page])

    render json: {
            experiences: ActiveModel::SerializableResource.new(@experiences),
            meta: pagination_meta(@experiences)
    }, each_serializer: ExperienceSerializer
  end

  def show
    render json: @experience,
           serializer: ExperienceSerializer,
           include: %w[category host reviews]
  end

  def create
    @experience = current_user.host.experiences.build(experience_params)

    if @experience.save
      render json: @experience,
             status: :created,
             serializer: ExperienceSerializer
    else
      render json: { errors: @experience.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def update
    if @experience.update(experience_params)
      render json: @experience, serializer: ExperienceSerializer
    else
      render json: { errors: @experience.errors.full_messages }, 
              status: :unprocessable_entity
    end
  end

  def destroy
    @experience.destroy
    head :no_content
  end

  def host_experiences
    @experiences = current_user.host
                               .experiences
                               .includes(:category)
                               .page(params[:page])

    render json: {
             experiences: @experiences,
             meta: pagination_meta(@experiences)
           },
           each_serializer: ExperienceSerializer
  end

  def check_availability
    @experience = Experience.find(params[:id])
    date = Date.parse(params[:date])
    available_slots = @experience.available_slots(date)

    render json: { available_slots: available_slots }
  end

  private

  def set_experience
    @experience = Experience.find(params[:id])
  end

  def experience_params
    params.require(:experience).permit(
      :title,
      :description,
      :category_id,
      :price,
      :currency,
      :duration_minutes,
      :min_participants,
      :max_participants,
      :address,
      :city,
      :state,
      :country,
      :postal_code,
      :status,
      :cover_image,
      images: [],
      tags: []
    )
  end

  def search_params
    params.permit(:query, :location, :category_id)
  end

  def filter_params
    params.permit(:min_price, :max_price, :min_rating, :date)
  end

  def authorize_host!
    unless current_user.host?
      render json: { error: "Only hosts can perform this action" }, 
              status: :forbidden
    end
  end
end
