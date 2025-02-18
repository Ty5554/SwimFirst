// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
Turbo.session.drive = false
import "./controllers"
import "./modal"
import "./modal_control"
import "./record_input";