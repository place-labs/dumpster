require "./ansi"

class Terminimal::Cursor
  def self.instance : self
    @@instance ||= new
  end

  private def initialize(@io = STDOUT)
    @hidden = false
  end

  private getter io : IO

  # Hides the cursor until instructed to re-display it with `#show` or the
  # application exits.
  def hide
    hide!
    at_exit { show }
    Signal::INT.trap do
      show
      exit 125
    end
  end

  # Hides the current cursor position.
  #
  # Using the method directly is not recommended, however if you do, it is
  # important to ensure you call `#show` prior to exiting.
  def hide!
    io << ANSI::CURSOR_HIDE
    @hidden = true
    self
  end

  # Show the cursor.
  def show
    io << ANSI::CURSOR_SHOW
    @hidden = false
    self
  end

  # Get the last known cursor visibility.
  def hidden?
    @hidden
  end

  # Move the cursor position *cells* spots in *direction*.
  def move(direction, cells = 1)
    ansi = case direction
           when :up then ANSI::CURSOR_UP
           when :down then ANSI::CURSOR_DOWN
           when :forward, :right then ANSI::CURSOR_FORWARD
           when :back, :left then ANSI::CURSOR_BACK
           when :next_line, :line_down then ANSI::CURSOR_NEXT_LINE
           when :prev_line, :line_up then ANSI::CURSOR_PREV_LINE
           else raise "Unsupported direction: #{direction}"
           end

    if cells > 1
      ansi = "\e[#{cells}#{ansi[-1]}"
    elsif cells < 1
      raise "cells must be positive"
    end

    io << ansi
    self
  end
end
