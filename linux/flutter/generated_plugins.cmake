add_library(flutter_plugin_registrant SHARED
  generate_plugins.cc
)

apply_standard_settings(flutter_plugin_registrant)
set_target_properties(flutter_plugin_registrant PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib"
)
