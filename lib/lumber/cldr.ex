defmodule Lumber.Cldr do
  #
  # The "Least Wanted" from https://clublog.org/mostwanted.php
  # Codes from here https://unicode-org.github.io/cldr-staging/charts/37/summary/root.html
  #
  use Cldr,
    locales: ["en", "it", "de", "ru", "fr", "es", "uk", "pl", "hu", "sl", "cs", "nl", "hr"],
    default_locale: "en"
end
