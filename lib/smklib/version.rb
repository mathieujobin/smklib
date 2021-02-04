module SMKLib #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 1
    MINOR = 1
    TINY = 2

    def self.to_s
      [MAJOR, MINOR, TINY].join('.')
    end
  end
end
