module SMKLib #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 1
    MINOR = 2
    TINY = 0

    def self.to_s
      [MAJOR, MINOR, TINY].join('.')
    end
  end
end
