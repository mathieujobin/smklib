module SMKLib #:nodoc:
  module VERSION #:nodoc:
    MAJOR = 1
    MINOR = 0
    TINY = 1

    def self.to_s
      [MAJOR, MINOR, TINY].join('.')
    end
  end
end
