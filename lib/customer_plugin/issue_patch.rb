module CustomerPlugin
  module IssuePatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        unloadable

        has_and_belongs_to_many :customers
      end
    end

    module ClassMethods
    end

    module InstanceMethods
    end
  end
end
