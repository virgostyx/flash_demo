# app/controllers/concerns/flash_messages.rb
# Include this in ApplicationController to use simplified flash methods

module FlashMessages
  extend ActiveSupport::Concern

  # Set a flash message and handle both HTML and Turbo Stream responses
  #
  # For HTML: Sets flash and executes the block
  # For Turbo Stream: Returns turbo stream for the flash, you must combine it with other streams
  #
  # @param type [Symbol] Flash type (:success, :error, :warning, :info)
  # @param message [String] The message text
  # @param width [Integer] Width in pixels (default: 448)
  # @param duration [Integer] Auto-dismiss duration in milliseconds (default: 5000)
  #
  # Usage:
  #   # HTML redirect
  #   set_flash(:success, "Post created!") do |format|
  #     format.html { redirect_to @post }
  #     format.turbo_stream { render turbo_stream: turbo_stream.replace(...) }
  #   end
  #
  # Note: For Turbo Stream, you need to manually render with the flash stream
  def set_flash(type, message, width: 448, duration: 5000, &block)
    respond_to do |format|
      # HTML format - set flash and execute the block
      format.html do
        flash[type] = { message: message, width: width }
        yield format if block_given?
      end

      # Turbo Stream format - store flash info for later use
      format.turbo_stream do
        # Store flash info in instance variable for use in block
        @_flash_stream = flash_turbo_stream(type, message, width: width, duration: duration)
        yield format if block_given?
      end
    end
  end

  # Set flash and redirect (for HTML only)
  #
  # @param type [Symbol] Flash type
  # @param message [String] The message text
  # @param path [String/Object] Redirect path or object
  # @param width [Integer] Width in pixels (default: 448)
  #
  # Usage:
  #   flash_and_redirect(:success, "Post created!", @post)
  #   flash_and_redirect(:error, "Not found", root_path, width: 672)
  def flash_and_redirect(type, message, path, width: 448)
    flash[type] = { message: message, width: width }
    redirect_to path
  end

  # Set flash and render (for HTML only)
  #
  # @param type [Symbol] Flash type
  # @param message [String] The message text
  # @param template [Symbol/String] Template to render
  # @param width [Integer] Width in pixels (default: 448)
  # @param status [Symbol] HTTP status (default: :unprocessable_entity)
  #
  # Usage:
  #   flash_and_render(:error, "Invalid input", :new)
  #   flash_and_render(:warning, "Check form", :edit, status: :bad_request)
  def flash_and_render(type, message, template, width: 448, status: :unprocessable_entity)
    flash.now[type] = { message: message, width: width }
    render template, status: status
  end

  # Append a Turbo Stream flash message to an existing response
  #
  # @param type [Symbol] Flash type
  # @param message [String] The message text
  # @param width [Integer] Width in pixels (default: 448)
  # @param duration [Integer] Auto-dismiss duration in milliseconds (default: 5000)
  # @return [Turbo::Streams::TagBuilder] Turbo stream for chaining
  #
  # Usage:
  #   render turbo_stream: [
  #     turbo_stream.update("post", partial: "post"),
  #     flash_turbo_stream(:success, "Updated!")
  #   ]
  def flash_turbo_stream(type, message, width: 448, duration: 5000)
    turbo_stream.append(
      "flash-messages",
      partial: "shared/flash_message",
      locals: {
        type: type,
        message: message,
        width_px: width,
        duration: duration
      }
    )
  end

  # NEW: Simplified method for create/update actions with both HTML and Turbo Stream
  # Automatically handles common patterns
  #
  # @param success [Boolean] Whether the operation succeeded
  # @param success_message [String] Message to show on success
  # @param error_message [String] Message to show on error
  # @param success_path [String/Object] Where to redirect on success (HTML only)
  # @param error_template [Symbol] Template to render on error (HTML only)
  # @param turbo_success [Proc] Block to execute for Turbo Stream success
  # @param turbo_error [Proc] Block to execute for Turbo Stream error (optional)
  # @param success_width [Integer] Width for success message (default: 384)
  # @param error_width [Integer] Width for error message (default: 672)
  #
  # Usage:
  #   flash_response(
  #     success: @post.save,
  #     success_message: "Post created!",
  #     error_message: "Unable to create post",
  #     success_path: @post,
  #     error_template: :new,
  #     turbo_success: -> {
  #       render turbo_stream: [
  #         turbo_stream.prepend("posts", partial: "posts/post", locals: { post: @post }),
  #         flash_turbo_stream(:success, "Post created!", width: 384)
  #       ]
  #     }
  #   )
  def flash_response(success:, success_message:, error_message:, success_path: nil, error_template: nil, turbo_success: nil, turbo_error: nil, success_width: 384, error_width: 672)
    if success
      respond_to do |format|
        format.html do
          flash[:success] = { message: success_message, width: success_width }
          redirect_to success_path if success_path
        end

        format.turbo_stream do
          if turbo_success
            turbo_success.call
          else
            render turbo_stream: flash_turbo_stream(:success, success_message, width: success_width)
          end
        end
      end
    else
      respond_to do |format|
        format.html do
          flash.now[:error] = { message: error_message, width: error_width }
          render error_template, status: :unprocessable_entity if error_template
        end

        format.turbo_stream do
          if turbo_error
            turbo_error.call
          else
            render turbo_stream: flash_turbo_stream(:error, error_message, width: error_width)
          end
        end
      end
    end
  end
end
