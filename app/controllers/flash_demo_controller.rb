# Demo controller to test all flash message features
# Save as: app/controllers/flash_demo_controller.rb

class FlashDemoController < ApplicationController
  # GET /flash_demo
  def index
    # This renders the demo page
  end

  # POST /flash_demo/success
  def success
    flash_and_redirect(:success, "✅ Success! Your action completed successfully.", flash_demo_path, width: 600)
  end

  # POST /flash_demo/error
  def error
    respond_to do |format|
      format.html do
        flash_and_render(:error, "❌ Error! Something went wrong with your request.", :index, width: 800)
      end

      format.turbo_stream do
        render turbo_stream: [ flash_turbo_stream(:error, "❌ Error! Something went wrong with your request.") ]
      end
    end
  end

  # POST /flash_demo/warning
  def warning
    respond_to do |format|
      format.html do
        flash_and_redirect(:warning, "⚠️ Warning! Please review your input carefully.", flash_demo_path, width: 600)
      end

      format.turbo_stream do
        render turbo_stream: [ flash_turbo_stream(:warning, "⚠️ Warning! Please review your input carefully.", width: 600) ]
      end
    end
  end

  # POST /flash_demo/info
  def info
    respond_to do |format|
      format.html do
        flash[:info] = "ℹ️ Info: This is an informational message for your reference."
        redirect_to flash_demo_path
      end

      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "flash-messages",
          partial: "shared/flash_message",
          locals: {
            type: :info,
            message: "ℹ️ Info (via Turbo Stream)"
          }
        )
      end
    end
  end

  # POST /flash_demo/notice
  def notice
    respond_to do |format|
      format.html do
        flash[:notice] = "Notice: Using Rails standard :notice type (renders as success)"
        redirect_to flash_demo_path
      end

      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "flash-messages",
          partial: "shared/flash_message",
          locals: {
            type: :notice,
            message: "Notice: Standard Rails :notice (via Turbo Stream)"
          }
        )
      end
    end
  end

  # POST /flash_demo/alert
  def alert
    respond_to do |format|
      format.html do
        flash[:alert] = "Alert: Using Rails standard :alert type (renders as warning)"
        redirect_to flash_demo_path
      end

      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "flash-messages",
          partial: "shared/flash_message",
          locals: {
            type: :alert,
            message: "Alert: Standard Rails :alert (via Turbo Stream)"
          }
        )
      end
    end
  end

  # POST /flash_demo/multiple
  def multiple
    flash[:success] = "First message: Operation completed!"
    flash[:info] = "Second message: Here's some additional information."
    flash[:warning] = "Third message: Don't forget to save your changes."

    redirect_to flash_demo_path
  end

  # POST /flash_demo/custom_duration
  def custom_duration
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "flash-messages",
          partial: "shared/flash_message",
          locals: {
            type: :info,
            message: "⏱️ This message will stay for 10 seconds!",
            duration: 10000
          }
        )
      end
    end
  end

  # POST /flash_demo/quick_dismiss
  def quick_dismiss
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "flash-messages",
          partial: "shared/flash_message",
          locals: {
            type: :warning,
            message: "⚡ Quick! This disappears in 2 seconds!",
            duration: 2000
          }
        )
      end
    end
  end

  # POST /flash_demo/long_message
  def long_message
    respond_to do |format|
      format.html do
        flash[:info] = "This is a longer message to demonstrate how the flash component handles text that spans multiple lines. It should still look great and be fully readable with proper spacing and formatting."
        redirect_to flash_demo_path
      end

      format.turbo_stream do
        render turbo_stream: turbo_stream.append(
          "flash-messages",
          partial: "shared/flash_message",
          locals: {
            type: :info,
            message: "This is a longer message to demonstrate how the flash component handles text that spans multiple lines. It should still look great and be fully readable with proper spacing and formatting."
          }
        )
      end
    end
  end
end
