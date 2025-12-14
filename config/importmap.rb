pin "application"

# Hotwire (Turbo + Stimulus)
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true

# Stimulus controllers (map under the logical namespace "controllers")
pin_all_from "app/javascript/controllers", under: "controllers"
