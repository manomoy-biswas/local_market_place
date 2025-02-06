module Api
  module V1
    class BookingsController < BaseController
      before_action :authenticate_user!
      before_action :set_booking, only: [:show, :update, :cancel]
      before_action :check_availability, only: [:create]

      def index
        @bookings = current_user.bookings
                              .includes(:experience)
                              .order(booking_date: :desc)
                              .page(params[:page])

        render json: @bookings, 
               each_serializer: BookingSerializer,
               meta: pagination_dict(@bookings)
      end

      def show
        render json: @booking, serializer: BookingSerializer
      end

      def create
        @booking = current_user.bookings.build(booking_params)

        if @booking.save
          PaymentProcessingJob.perform_later(@booking)
          render json: @booking, 
                 status: :created, 
                 serializer: BookingSerializer
        else
          render json: { errors: @booking.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      def cancel
        if @booking.cancel(params[:reason])
          render json: @booking, serializer: BookingSerializer
        else
          render json: { errors: @booking.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      private

      def set_booking
        @booking = current_user.bookings.find(params[:id])
      end

      def booking_params
        params.require(:booking).permit(
          :experience_id,
          :booking_date,
          :participants,
          :special_requests
        )
      end

      def check_availability
        experience = Experience.find(booking_params[:experience_id])
        unless experience.available?(
          booking_params[:booking_date],
          booking_params[:participants]
        )
          render json: { error: "No availability for selected date/participants" },
                 status: :unprocessable_entity
        end
      end
    end
  end
end
