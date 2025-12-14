module FlashHelper
  # Generates a flash message that can be used in Turbo Stream responses
  # 
  # Usage in controller:
  #   respond_to do |format|
  #     format.turbo_stream do
  #       render turbo_stream: turbo_stream.append("flash-messages", partial: "shared/flash_message",
  #         locals: { type: :success, message: "Record saved successfully!" })
  #     end
  #   end
  def flash_message_config(type)
    case type.to_sym
    when :notice, :success
      {
        bg: "bg-green-50",
        border: "border-green-200",
        text: "text-green-800",
        icon_bg: "bg-green-100",
        icon_color: "text-green-600",
        icon_path: "M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      }
    when :alert, :warning
      {
        bg: "bg-yellow-50",
        border: "border-yellow-200",
        text: "text-yellow-800",
        icon_bg: "bg-yellow-100",
        icon_color: "text-yellow-600",
        icon_path: "M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z"
      }
    when :error, :danger
      {
        bg: "bg-red-50",
        border: "border-red-200",
        text: "text-red-800",
        icon_bg: "bg-red-100",
        icon_color: "text-red-600",
        icon_path: "M9.75 9.75l4.5 4.5m0-4.5l-4.5 4.5M21 12a9 9 0 11-18 0 9 9 0 0118 0z"
      }
    else # info or default
      {
        bg: "bg-blue-50",
        border: "border-blue-200",
        text: "text-blue-800",
        icon_bg: "bg-blue-100",
        icon_color: "text-blue-600",
        icon_path: "M11.25 11.25l.041-.02a.75.75 0 011.063.852l-.708 2.836a.75.75 0 001.063.853l.041-.021M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9-3.75h.008v.008H12V8.25z"
      }
    end
  end
end
