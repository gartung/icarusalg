cet_find_library( DK2NU_TREE NAMES dk2nuTree PATHS ENV DK2NUDATA_LIB NO_DEFAULT_PATH ) ### MIGRATE-ACTION-RECOMMENDED: use of ENV ... may be UPS-dependent ### MIGRATE-ACTION-RECOMMENDED: use cet_find_package() with target semantics for linking
include_directories( $ENV{DK2NUDATA_INC} ) ### MIGRATE-ACTION-RECOMMENDED: use target_link_directories() with target semantics

cet_enable_asserts()
cet_make( ### MIGRATE-ACTION-RECOMMENDED: use cet_make_library(), build_dictionary(), basic_plugin() with explicit source lists
  LIBRARIES
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
