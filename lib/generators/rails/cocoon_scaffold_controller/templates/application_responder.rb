module NestedXMLResponder
  def to_xml
    require 'json'

    if (nested = JSON.parse(
        resource.active_model_serializer.new(resource).to_json
    )).is_a? Hash
      root = nested.keys[0]
      nested = nested[root]
    else
      root = resource.table_name
    end

    render :text => nested.to_xml(root: root)
  end
end

class ApplicationResponder < ActionController::Responder
  include NestedXMLResponder
end

