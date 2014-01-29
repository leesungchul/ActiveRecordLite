require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    @attributes = []
    new_attributes.each do |attribute|
      @attributes << attribute.to_sym
    end
    @attributes
  end

  def self.attributes
    if self == MassObject
      raise "must not call #attributes on MassObject directly"
    end
    @attributes ||= []
  end

  def initialize(params = {})
    params.each do |attr_name, attr_val|
      attr_name = attr_name.to_sym
      if self.class.attributes.include?(attr_name)
        self.send("#{attr_name}=", attr_val)
      else
        raise "mass assignment to unregistered attribute '#{attr_name}'"
      end
    end
  end
end
