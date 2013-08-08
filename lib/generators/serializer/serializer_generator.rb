# Overwrite the std SerializerGenerator
module Rails
  module Generators
    class SerializerGenerator < NamedBase
      def create_serializer_file
        false
      end
    end
  end
end
