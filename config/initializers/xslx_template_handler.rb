require 'action_view'
require 'action_view/template/handlers/xlsx_template_handler'

ActionView::Template.register_template_handler :wx, ActionView::Template::Handlers::XLSXTemplateHandler
