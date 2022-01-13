# ======================================================================
#  icaruscode main build file
#
#  cd .../path/to/build/directory
#  source .../path/to/larsoft/ups/setup_for_development <-d|-p>
#  cmake [-DCMAKE_INSTALL_PREFIX=/install/path]
#        -DCMAKE_BUILD_TYPE=$CETPKG_TYPE
#        $CETPKG_SOURCE
#  make
#  make test
#  make install
#  make package (builds distribution tarfile)
# ======================================================================
# use cmake 3.12-3.14
cmake_minimum_required(VERSION 3.19 FATAL_ERROR)
cmake_policy(VERSION 3.14)



find_package(cetmodules 2.25.05 REQUIRED)
project(icarusalg VERSION 09.34.00 LANGUAGES CXX)

message(STATUS
  "\n-- ============================================================================="
  "\n-- === *** Start of configuration of ${PROJECT_NAME} ***"
  "\n-- ===")


include(CetCMakeEnv)
cet_cmake_env()

cet_set_compiler_flags(DIAGS CAUTIOUS
  WERROR
  NO_UNDEFINED
  EXTRA_FLAGS -pedantic -I $ENV{CLANG_FQ_DIR}/include/c++/v1
)

cet_report_compiler_flags(REPORT_THRESHOLD VERBOSE)

# these are minimum required versions, not the actual product versions
find_package( larcorealg )
find_package( larcoreobj )
find_package( lardataalg )
find_package( lardataobj )
find_package( nusimdata  )
find_package( celib )
find_package( cetlib_except )
find_package( canvas     )
find_package( canvas_root_io )
find_package( messagefacility )
find_package( guideline_sl )
find_package( ROOT )
find_package( Boost COMPONENTS unit_test_framework)
find_package( CLHEP )

include(ArtDictionary)
include(CetMake)
include(BasicPlugin)

# ADD SOURCE CODE SUBDIRECTORIES HERE
add_subdirectory(icarusalg)

# subdirectory for test code
add_subdirectory(test)

# Top level fcl files.
add_subdirectory(fcl)

# ups - table and config files

# packaging utility

message(STATUS
  "\n-- ==="
  "\n-- === *** End of configuration of ${PROJECT_NAME} ***"
  "\n-- ============================================================================="
  "\n-- "
  )

cet_cmake_config()
