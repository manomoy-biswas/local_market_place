
class Api::V1::MessagesController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_conversation_user, only: [:conversation]

  def index
    @messages = current_user.received_messages
                          .includes(:sender)
                          .order(created_at: :desc)
                          .page(params[:page])

    render json: @messages, 
            each_serializer: MessageSerializer
  end

  def conversation
    @messages = Message.between_users(current_user.id, @recipient.id)
                      .includes(:sender, :recipient)
                      .order(created_at: :desc)
                      .page(params[:page])

    render json: @messages, 
            each_serializer: MessageSerializer
  end

  def create
    @message = current_user.sent_messages.build(message_params)

    if @message.save
      render json: @message, 
              status: :created, 
              serializer: MessageSerializer
    else
      render json: { errors: @message.errors.full_messages }, 
              status: :unprocessable_entity
    end
  end

  def mark_as_read
    @message = current_user.received_messages.find(params[:id])
    @message.mark_as_read!
    head :no_content
  end

  private

  def set_conversation_user
    @recipient = User.find(params[:user_id])
  end

  def message_params
    params.require(:message).permit(:recipient_id, :content, :booking_id)
  end
end
