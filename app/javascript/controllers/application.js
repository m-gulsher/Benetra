import { Application } from "@hotwired/stimulus"

class StoringApplication extends Application {
  storedControllers = {}

  register(identifier, controllerConstructor) {
    super.register(identifier, controllerConstructor)
    this.storedControllers[identifier] = controllerConstructor
  }
}

const application = StoringApplication.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }