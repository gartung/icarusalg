
cet_make(
  SUBDIRS "details"
  LIBRARIES
          larcorealg::Geometry
          larcorealg::CoreUtils
          larcoreobj::SimpleTypesAndConstants
          messagefacility::MF_MessageLogger
          fhiclcpp::fhiclcpp
          cetlib::cetlib
          cetlib_except::cetlib_except
          ROOT::Core
          ROOT::Physics
          ROOT::Geom
          ROOT::GenVector
          CLHEP::CLHEP
        )


add_subdirectory(gdml)

install_headers(SUBDIRS "details")
install_fhicl(SUBDIRS "details")
install_source(SUBDIRS "details")


