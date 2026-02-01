defmodule LumberWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.
  """
  use LumberWeb, :html

  import LumberWeb.WwsacSubmissionHTML, only: [upload_form: 1]

  embed_templates "page_html/*"
end
