class Object
  def self.const_missing(name)
    if Scruber::Helpers.const_defined?(name)
      Scruber::Helpers.const_get(name)
    else
      super
    end
  end
end