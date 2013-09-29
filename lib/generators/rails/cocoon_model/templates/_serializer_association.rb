<%= assoc %> :<%= ref %><%= ref =~ /_/ ? ", key: #{ref.camelize(:lower)}" : '' %>
