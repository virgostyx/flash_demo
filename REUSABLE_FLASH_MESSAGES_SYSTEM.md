### Flash Messages System: Instructions Manual

This document provides a comprehensive guide on how to use the standardized flash message system in any Ruby on Rails application.

---

### 1. System Overview
The system is built using **ViewComponent**, **Tailwind CSS** for styling, **Stimulus JS** for interactivity, and **Turbo Streams** for dynamic updates. 
It supports standard Rails flash types, customizable widths, auto-dismiss functionality, and seamless integration with both traditional HTML redirects and modern Turbo Stream responses.

### 2. Initial Setup

#### A. Controller Integration
Include the `FlashMessages` concern in your `ApplicationController` to make the helper methods available globally.

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include FlashMessages
end
```

#### B. Layout Integration
Render the main flash container in your application layout, usually right inside the `<body>` tag.

```erb
<%# app/views/layouts/application.html.erb %>
<body class="...">
  <%= render "shared/flash" %>
  <%= yield %>
</body>
```

---

### 3. Usage in Controllers

The system provides several helper methods to simplify flash message handling.

#### A. Traditional HTML Redirects
Use `flash_and_redirect` to set a message and redirect in one line.

```ruby
def create
  @post = Post.new(post_params)
  if @post.save
    flash_and_redirect(:success, "Post created successfully!", @post)
  else
    render :new
  end
end
```

#### B. HTML Rendering (Form Validation)
Use `flash_and_render` for displaying errors on the current page.

```ruby
def update
  if @post.update(post_params)
    flash_and_redirect(:success, "Updated!", @post)
  else
    flash_and_render(:error, "Please fix the errors below.", :edit)
  end
end
```

#### C. Turbo Stream Responses
Use `flash_turbo_stream` to return a flash message as a Turbo Stream tag.

```ruby
def destroy
  @post.destroy
  render turbo_stream: [
    turbo_stream.remove(@post),
    flash_turbo_stream(:info, "Post deleted successfully")
  ]
end
```

#### D. Unified Response Helper (`flash_response`)
This is the most powerful helper for standard CRUD actions. It handles both HTML and Turbo Stream formats automatically.

```ruby
def create
  @post = Post.new(post_params)
  
  flash_response(
    success: @post.save,
    success_message: "Post created!",
    error_message: "Unable to create post",
    success_path: @post,
    error_template: :new,
    turbo_success: -> {
      render turbo_stream: [
        turbo_stream.prepend("posts", @post),
        flash_turbo_stream(:success, "Post created!")
      ]
    }
  )
end
```

---

### 4. Configuration Options

#### Flash Types
The system supports the following types, each with its own color scheme and icon:
- `:success` (Alias: `:notice`) -> Green
- `:error` (Alias: `:danger`) -> Red
- `:warning` (Alias: `:alert`) -> Yellow
- `:info` (Default) -> Blue

#### Advanced Parameters
You can pass additional options to customize the appearance and behavior:

- `message`: The text to display.
- `width`: Width in pixels (default: `448` - equivalent to `max-w-md`).
- `duration`: Auto-dismiss time in milliseconds (default: `5000`).

Example of passing options via standard flash hash:
```ruby
flash[:success] = { message: "Task completed!", width: 600 }
```

---

### 5. Frontend Behavior (Stimulus)

The `flash_controller.js` manages the following features:
1.  **Entrance Animation**: Messages fade in and slide down from the top.
2.  **Auto-Dismiss**: Messages disappear after the specified `duration`.
3.  **Pause on Hover**: If a user hovers over a message, the auto-dismiss timer pauses.
4.  **Manual Close**: A "Close" (X) button is available on every message.
5.  **Stacking**: Multiple messages will stack vertically with proper spacing.

---

### 6. Component Reference

- **`app/controllers/concerns/flash_messages.rb`**: Core logic and helpers.
- **`app/components/flash_message_component.rb`**: ViewComponent class for individual messages.
- **`app/components/flash_message_component.html.erb`**: ViewComponent template for individual messages.
- **`app/views/shared/_flash.html.erb`**: Main container for initial page load.
- **`app/javascript/controllers/flash_controller.js`**: Client-side interactivity.

---

### 7. Implementation Code

Below is the full implementation code for each component of the system.

#### A. Controller Concern
`app/controllers/concerns/flash_messages.rb`

```ruby
# app/controllers/concerns/flash_messages.rb
module FlashMessages
  extend ActiveSupport::Concern

  def set_flash(type, message, width: 448, duration: 5000)
    respond_to do |format|
      format.html do
        flash[type] = { message: message, width: width }
        yield format if block_given?
      end

      format.turbo_stream do
        @_flash_stream = flash_turbo_stream(type, message, width: width, duration: duration)
        yield format if block_given?
      end
    end
  end

  def flash_and_redirect(type, message, path, width: 448)
    flash[type] = { message: message, width: width }
    redirect_to path
  end

  def flash_and_render(type, message, template, width: 448, status: :unprocessable_entity)
    flash.now[type] = { message: message, width: width }
    render template, status: status
  end

  def flash_turbo_stream(type, message, width: 448, duration: 5000)
    turbo_stream.append(
      "flash-messages",
      FlashMessageComponent.new(
        type: type,
        message: message,
        width_px: width,
        duration: duration
      )
    )
  end

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
```

#### B. ViewComponent Class
`app/components/flash_message_component.rb`

```ruby
class FlashMessageComponent < ViewComponent::Base
  def initialize(type:, message:, width_px: nil, duration: 5000)
    @type = type.to_sym
    @duration = duration

    if message.is_a?(Hash)
      @message = message[:message] || message["message"]
      @width_px = message[:width] || message["width"] || width_px || 448
    else
      @message = message
      @width_px = width_px || 448
    end

    @config = flash_message_config(@type)
  end

  private

  attr_reader :type, :message, :width_px, :duration, :config

  def flash_message_config(type)
    case type
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
```

#### C. ViewComponent Template
`app/components/flash_message_component.html.erb`

```erb
<div
  data-controller="flash"
  data-flash-duration-value="<%= duration %>"
  data-action="mouseenter->flash#pause mouseleave->flash#resume"
  style="max-width: <%= width_px %>px;margin: 0 auto;"
  class="w-full <%= config[:bg] %> <%= config[:border] %> <%= config[:text] %> border rounded-lg shadow-lg p-4 flex items-start gap-3 opacity-0 translate-y-[-1rem] transition-all duration-500 ease-out"
>
  <!-- Icon -->
  <div class="<%= config[:icon_bg] %> rounded-lg p-2 flex-shrink-0">
    <svg class="w-5 h-5 <%= config[:icon_color] %>" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="<%= config[:icon_path] %>"/>
    </svg>
  </div>

  <!-- Message -->
  <div class="flex-1 pt-0.5">
    <p class="text-sm font-medium"><%= message %></p>
  </div>

  <!-- Close button -->
  <button
    data-action="click->flash#close"
    class="flex-shrink-0 <%= config[:text] %> hover:opacity-70 transition-opacity"
    type="button"
  >
    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
    </svg>
  </button>
</div>
```

#### D. Main Flash Container
`app/views/shared/_flash.html.erb`

```erb
<div id="flash-messages" class="fixed top-4 left-1/2 transform -translate-x-1/2 z-50 w-full px-4 space-y-2">
  <% flash.each do |type, message| %>
    <%= render FlashMessageComponent.new(type: type, message: message) %>
  <% end %>
</div>
```

#### E. Stimulus Controller
`app/javascript/controllers/flash_controller.js`

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static values = {
        duration: { type: Number, default: 5000 },
        removeDelay: { type: Number, default: 500 }
    }

    connect() {
        this.element.classList.remove('opacity-0', 'translate-y-[-1rem]')
        this.element.classList.add('opacity-100', 'translate-y-0')

        this.timeoutId = setTimeout(() => {
            this.close()
        }, this.durationValue)
    }

    disconnect() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
        }
    }

    close() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
            this.timeoutId = null
        }

        this.element.classList.remove('opacity-100', 'translate-y-0')
        this.element.classList.add('opacity-0', 'translate-y-[-1rem]')

        setTimeout(() => {
            this.element.remove()
        }, this.removeDelayValue)
    }

    pause() {
        if (this.timeoutId) {
            clearTimeout(this.timeoutId)
            this.timeoutId = null
        }
    }

    resume() {
        if (!this.timeoutId) {
            this.timeoutId = setTimeout(() => {
                this.close()
            }, this.durationValue)
        }
    }
}
```