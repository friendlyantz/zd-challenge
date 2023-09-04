# frozen_string_literal: true

class Renderers::Printer
  attr_reader :output

  def initialize(output = $stdout)
    @output = output
  end

  def puts(input)
    case input
    in Array then input.each { |value| puts(value) }
    in _     then output.puts input
    end
  end
end
