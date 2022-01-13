include_directories(${CPPGSL_INC})
cet_make( ### MIGRATE-ACTION-RECOMMENDED: use cet_make_library(), build_dictionary(), basic_plugin() with explicit source lists
  LIBRARIES
    cetlib_except::cetlib_except
    CLHEP::CLHEP
    larcorealg::CoreUtils
  )

install_headers()
install_source()
install_fhicl()
