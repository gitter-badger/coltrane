module Coltrane
  # It describes a musical note, independent of octave

  class Note
    include Multiton

    attr_reader :name, :number
    alias_method :id, :number

    NOTES = {
      'C'  => 0,
      'C#' => 1,
      'Db' => 1,
      'D'  => 2,
      'D#' => 3,
      'Eb' => 3,
      'E'  => 4,
      'F'  => 5,
      'F#' => 6,
      'Gb' => 6,
      'G'  => 7,
      'G#' => 8,
      'Ab' => 8,
      'A'  => 9,
      'A#' => 10,
      'Bb' => 10,
      'B'  => 11
    }.freeze

    def initialize(name)
      @name, @number = name, NOTES[name]
    end

    private_class_method :new

    def self.[](arg)
      name =
        case arg
        when Note then return arg
        when String then find_note(arg)
        when Numeric then NOTES.key(arg % 12)
        else raise InvalidNote.new("Wrong type: #{arg.class}")
        end

      new(name) || (raise InvalidNote.new("#{arg}"))
    end

    def self.all
      %w[C C# D D# E F F# G G# A A# B].map { |n| Note[n] }
    end

    def self.find_note(str)
      NOTES.each { |k, v| return k if str.casecmp?(k) }
      nil
    end

    def pretty_name
      @name.gsub('b',"\u266D").gsub('#',"\u266F")
    end

    alias_method :to_s, :name

    def accident?
      [1,3,6,8,10].include?(number)
    end

    def +(n)
      case n
        when Interval then Note[number + n.semitones]
        when Numeric  then Note[number + n]
        when Note     then Chord.new(number + n.number)
      end
    end

    def -(n)
      case n
        when Numeric then Note.new(n - number)
        when Note    then Interval.new(n.number - number)
      end
    end

    def valid_note?(note_name)
      find_note(note_name)
    end

    def interval_to(note_name)
      Note[note_name] - self
    end

    def transpose_by(semitones)
      self + semitones
    end

    def guitar_notes
      Guitar.strings.reduce([]) do |memo, guitar_string|
        memo + in_guitar_string(guitar_string)
      end
    end

    def on_guitar
      GuitarNoteSet.new(guitar_notes).render
    end

    def in_guitar_string(guitar_string)
      guitar_string.guitar_notes_for_note(self)
    end

    def in_guitar_string_region(guitar_string, region)
      guitar_string.guitar_notes_for_note_in_region(self, region)
    end
  end
end