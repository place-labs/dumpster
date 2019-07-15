require "./terminimal/ansi"
require "colorize"

# A small CLI toolkit for building termninal apps designed for humans.
module Terminimal
  extend self

  # Hides the cursor until instructed to re-display it with `#show_cursor` or the
  # application exits.
  def hide_cursor
    hide_cursor!
    at_exit { show_cursor }
    Signal::INT.trap do
      show_cursor
      exit 125
    end
  end

  # Hides the current cursor position.
  #
  # If using this, it is crucial to ensure you call `#show_cursor` prior to
  # exiting.
  def hide_cursor!
    print ANSI::HIDE_CURSOR
  end

  # Unhides the cursor.
  def show_cursor
    print ANSI::SHOW_CURSOR
  end

  # Moves the cursor in the specified *direction*.
  def move_cursor(direction)
    case direction
    when :up
      print ANSI::CURSOR_UP
    when :down
      print ANSI::CURSOR_DOWN
    when :forward, :right
      print ANSI::CURSOR_FORWARD
    when :back, :left
      print ANSI::CURSOR_BACK
    else
      raise "Unsupported direction: #{direction}"
    end
  end

  # Clears the current line of STDOUT up to *max_chars*.
  def clear_line(max_chars = 80)
    print "\e[#{max_chars}D"
  end

  # Prints to STDERR and exits
  def exit_with_error(message, exit_code) : NoReturn
    STDERR.puts "#{"error:".colorize.bright.red} #{message}"
    exit exit_code
  end
end
