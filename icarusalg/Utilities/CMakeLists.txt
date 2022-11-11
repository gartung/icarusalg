
file(GLOB src_files *.cxx)
cet_make_library(
  SOURCE ${src_files}
  LIBRARIES
    cetlib_except::cetlib_except
    CLHEP::CLHEP
    larcorealg::CoreUtils
    Microsoft.GSL::GSL
  )

install_headers()
install_source()
install_fhicl()
