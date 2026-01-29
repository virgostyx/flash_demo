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