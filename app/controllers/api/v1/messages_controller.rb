module Api
  module V1
    class MessagesController < Api::V1::ApiController
      load_and_authorize_resource :message, parent: false

      resource_description do
        short "List, show, create and mark_read a message."
        formats ["json"]
        error 401, "Unauthorized"
        error 404, "Not Found"
        error 422, "Validation Error"
        error 500, "Internal Server Error"
      end

      def_param_group :message do
        param :message, Hash, require: true do
          param :body, String, desc: "Message body", allow_nil: true
          param :sender, String, desc: "Message sent by"
          param :is_private, [true, false], desc: "Message Type e.g. [public, private]"
          param :offer_id, String, desc: "Offer for which message has been posted", allow_nil: true
          param :item_id, String, desc: "Item for which message has been posted", allow_nil: true
          param :state, String, desc: "Current User's Subscription State e.g. unread, read "
        end
      end

      api :GET, "/v1/messages", "List all messages"
      param :ids, Array, of: Integer, desc: "Filter by message ids e.g. ids = [1,2,3,4]"
      param :offer_id, String, desc: "Return messages for offer id."
      param :item_id, String, desc: "Return messages for item id."
      def index
        @messages = @messages.where(id: params[:ids].split(",")) if params[:ids].present?
        @messages = @messages.where(offer_id: params[:offer_id]) if params[:offer_id].present?
        @messages = @messages.where(item_id: params[:item_id]) if params[:item_id].present?
        render json: @messages, each_serializer: serializer
      end

      api :GET, "/v1/messages/1", "List a message"
      def show
        render json: @message, serializer: serializer
      end

      api :POST, "/v1/messages", "Create an message"
      param_group :message
      def create
        @message.sender_id = current_user.id
        save_and_render_object(@message)
      end

      api :PUT, "/v1/messages/:id/mark_read", "Mark message as read"
      def mark_read
        @message.mark_read!(current_user.id)
        render json: @message, serializer: serializer
      end

      private

      def serializer
        Api::V1::MessageSerializer
      end

      def message_params
        params.require(:message).permit(:body, :is_private,
          :offer_id, :item_id)
      end
    end
  end
end
