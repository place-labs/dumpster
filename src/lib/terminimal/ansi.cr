# ANSI control sequences.
module Terminimal::ANSI
  # Cursor movement
  CURSOR_UP      = "\e[A"
  CURSOR_DOWN    = "\e[B"
  CURSOR_FORWARD = "\e[C"
  CURSOR_BACK    = "\e[D"

  # Cursor visibility
  SHOW_CURSOR = "\e[?25h"
  HIDE_CURSOR = "\e[?25l"
end
