import { Turbo } from "@hotwired/turbo-rails";
import { Application } from "stimulus";
import { definitionsFromContext } from "stimulus/webpack-helpers";
import { start } from "@hotwired/stimulus-loading";

Turbo.session.drive = true;


const application = Application.start();

const context = require.context("controllers", true, /\.js$/);
application.load(definitionsFromContext(context));

start(application);
