defmodule LiqenCore.CMS.EntryContent do
  @moduledoc """
  Definitions of different "content" fields in `LiqenCore.CMS.entry`.
  """

  @typedoc """
  Union of all other types
  """
  @type t :: medium_content | external_html_content

  @typedoc """
  Link to a Medium article

  ```
  %{
    uri: "https://medium.com/@withinsight1/the-front-end-spectrum-c0f30998c9f0"
  }
  ```
  """
  @type medium_content :: %{
    uri: String.t
  }

  @typedoc """
  Link to an external HTML file

  ```
  %{
    uri: "http://www.bancomundial.org/es/news/feature/2013/11/06/fuga-cerebros-latinoamerica"
  }
  ```
  """
  @type external_html_content :: %{
    uri: String.t
  }
end
