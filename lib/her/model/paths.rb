module Her
  module Model
    module Paths
      extend ActiveSupport::Concern
      # Return a path based on the collection path and a resource data
      #
      # @example
      #   class User
      #     include Her::Model
      #     collection_path "/utilisateurs"
      #   end
      #
      #   User.find(1) # Fetched via GET /utilisateurs/1
      def request_path
        self.class.build_request_path(@data.dup)
      end

      module ClassMethods

        # Defines a custom collection path for the resource
        #
        # @example
        #  class User
        #    include Her::Model
        #    collection_path "/users"
        #  end
        def collection_path(path=nil)
          @her_collection_path ||= begin
            superclass.collection_path.dup if superclass.respond_to?(:collection_path)
          end

          return @her_collection_path unless path
          @her_resource_path = "#{path}/:id"
          @her_collection_path = path
        end

        # Defines a custom resource path for the resource
        #
        # @example
        #  class User
        #    include Her::Model
        #    resource_path "/users/:id"
        #  end
        def resource_path(path=nil)
          @her_resource_path ||= begin
            superclass.resource_path.dup if superclass.respond_to?(:resource_path)
          end

          return @her_resource_path unless path
          @her_resource_path = path
        end

        # Return a custom path based on the collection path and variable parameters
        #
        # @example
        #   class User
        #     include Her::Model
        #     collection_path "/utilisateurs"
        #   end
        #
        #   User.all # Fetched via GET /utilisateurs
        def build_request_path(path=nil, parameters={})
          unless path.is_a?(String)
            parameters = path || {}
            path = parameters.include?(:id) && !parameters[:id].nil? ? resource_path : collection_path
          end

          path.gsub(/:([\w_]+)/) do
            # Look for :key or :_key, otherwise raise an exception
            parameters.delete($1.to_sym) || parameters.delete("_#{$1}".to_sym) || raise(Her::Errors::PathError.new("Missing :_#{$1} parameter to build the request path (#{path})."))
          end
        end

        # Return or change the value of `include_root_in_json`
        def include_root_in_json(value=nil)
          return @include_root_in_json if value.nil?
          @include_root_in_json = value
        end

        # Return or change the value of `root_element`
        def root_element(value=nil)
          return @root_element if value.nil?
          @root_element = value
        end
      end
    end
  end
end
