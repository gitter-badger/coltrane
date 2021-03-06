module Coltrane
  module ClassicScales

    SCALES = {
      'Major'            => [2,2,1,2,2,2,1],
      'Pentatonic Major' => [2,2,3,2,3],
      'Blues Major'      => [2,1,1,3,2,3],
      'Natural Minor'    => [2,1,2,2,1,2,2],
      'Harmonic Minor'   => [2,1,2,2,1,3,1],
      'Hungarian Minor'  => [2,1,2,1,1,3,1],
      'Pentatonic Minor' => [3,2,2,3,2],
      'Blues Minor'      => [3,2,1,1,3,2],
      'Whole Tone'       => [2,2,2,2,2,2],
      'Flamenco'         => [1,3,1,2,1,2,2]
    }

    MODES = {
      'Major' => %w[Ionian Dorian Phrygian Lydian Mixolydian Aeolian Locrian]
    }

    private

    # A little helper to build method names
    # just make the code more clear
    def self.methodize(string)
      string.downcase.gsub(' ', '_')
    end

    public

    # Creates factories for scales
    SCALES.each do |name, distances|
      define_method methodize(name) do |tone='C', mode=1|
        new(*distances, tone: tone, mode: mode, name: name)
      end
    end

    # Creates factories for Greek Modes and possibly others
    MODES.each do |scale, modes|
      modes.each_with_index do |mode, index|
        scale_method = methodize(scale)
        mode_name = mode
        mode_n = index + 1
        define_method methodize(mode) do |tone='C'|
          new(*SCALES[scale], tone: tone, mode: mode_n, name: mode_name)
        end
      end
    end

    alias_method :minor,      :natural_minor
    alias_method :pentatonic, :pentatonic_major
    alias_method :blues,      :blues_major

    def known_scales
      SCALES.keys
    end

    def fetch(name, tone=nil)
      Coltrane::Scale.public_send(name, tone)
    end

    def from_key(key)
      scale = key.delete!('m') ? :minor : :major
      note  = key
      Scale.public_send(scale.nil? || scale == 'M' ? :major : :minor, note)
    end


    # Will output a OpenStruct like the following:
    # {
    #   scales: [array of scales]
    #   results: {
    #     scale_name: {
    #       note_number => found_notes
    #     }
    #   }
    # }

    def having_notes(notes)

      format = { scales: [], results: {} }
      OpenStruct.new(
        SCALES.each_with_object(format) do |(name, intervals), output|
          Note.all.each.map do |tone|
            scale = new(*intervals, tone: tone, name: scale)
            output[:results][name] ||= {}
            if output[:results][name].has_key?(tone.number)
              next
            else
              output[:scales] << scale if scale.include?(notes)
              output[:results][name][tone.number] = scale.notes & notes
            end
          end
        end
      )
    end

    def having_chords(*chords)
      should_create = !chords.first.is_a?(Chord)
      notes = chords.reduce(NoteSet[]) do |memo, c|
        memo + (should_create ? Chord.new(name: c) : c).notes
      end
      having_notes(notes)
    end

    alias_method :having_chord, :having_chords
  end
end