defmodule LumberWeb.FormHelpers do
  alias LumberWeb.FormView

  def form_text_field(form, field, label, assigns \\ []) do
    assigns = Keyword.merge([form: form, field: field, label: label], assigns)
    FormView.render("_text_field.html", assigns)
  end

  def form_select(form, field, label, options, assigns \\ []) do
    assigns = Keyword.merge([form: form, field: field, label: label, options: options], assigns)
    FormView.render("_select.html", assigns)
  end

  def form_checkbox(form, field, label, assigns \\ []) do
    assigns = Keyword.merge([form: form, field: field, label: label], assigns)
    FormView.render("_checkbox.html", assigns)
  end
end
