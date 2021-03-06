module Coltrane
  module Cli
    class Text < Representation
      def render
        case @flavor
        when :marks, :notes, :degrees then @notes.pretty_names.join(' ')
        when :intervals then @notes.map {|n| (@notes.first - n).name}.join(' ')
        else raise WrongFlavorError.new
        end
      end
    end
  end
end