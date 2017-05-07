Rake::DeprecatedObjectDSL.private_instance_methods.each do |method_name|
  Object.send(:undef_method, method_name)
end if defined?(Rake::DeprecatedObjectDSL)
