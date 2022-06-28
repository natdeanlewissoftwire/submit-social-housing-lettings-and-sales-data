# Form Runner

The form runner is composed of:

Ruby Classes:
- A singleton form handler that instantiates an instances of each form definition (config file we have) combined with the "setup" section that is common to all forms. This is created at rails boot time. (`app/models/form_handler.rb`)
- A Form class that is the entry point for parsing a form definition and handles most of the associated logic (`app/models/form.rb`)
- Section, Subsection, Page and Question classes (`app/models/form/`)
- Setup subsection specific instances (subclasses) of Section, Subsection, Pages and Questions (`app/form/setup/`)

ERB Templates:
- The page view which is the main view for each form page (`app/views/form/page.html.erb`)
- Partials for each question type (radio, checkbox, select, text, numeric, date) (`app/views/form/`)
- Partials for specific question guidance (`app/views/form/guidance`)
- The check answers page which is the view for the answer summary page of each section (`app/views/form/check_answers.html.erb`)

Routes for each form page are generated by looping over each Page instance in each Form instance held by the Form Handler and defining a "Get" path. The corresponding controller method is also auto-generated with meta-programming via the same looping in `app/controllers/form_controller.rb`

All form pages submit to the same controller method (`app/controllers/form_controller.rb#submit_form`) which validates and persists the data, and then redirects to the next form page that identifies as "routed_to" given the current case log state.