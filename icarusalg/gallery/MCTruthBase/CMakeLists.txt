file(GLOB src_files *.cxx *.cpp)
cet_enable_asserts()
cet_make_library(
  SOURCE ${src_files}
  LIBRARIES
          dk2nu::Tree
          lardataobj::RecoBase
          larcorealg::Geometry
          larcoreobj::SimpleTypesAndConstants
          lardataalg::DetectorInfo
          nusimdata::SimulationBase
          canvas::canvas
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

install_headers()
install_source()
install_fhicl()
