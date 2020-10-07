
# geometry test on ICARUS geometries

#
# the following are tests equivalent to the module ones, but with no framework
#
# unit test (use the hard-coded channel mapping for ICARUS geometry)
cet_test(geometry_icarus_test
  SOURCES geometry_icarus_test.cxx
  TEST_ARGS test_geometry_icarus.fcl
  LIBRARIES icarusalg_Geometry
            larcorealg_Geometry
            GeometryTestLib
            ${MF_MESSAGELOGGER}
            ${MF_UTILITIES}
            ${FHICLCPP}
            cetlib_except
	    ${ROOT_CORE}
#  OPTIONAL_GROUPS Broken
)


# unit test (use the hard-coded configuration for ICARUS geometry)
# this uses BOOST for the test
cet_test(geometry_iterator_icarus_test
  SOURCES geometry_iterator_icarus_test.cxx
  DATAFILES ./test_geometry_iterators_icarus.fcl
  TEST_ARGS ./test_geometry_iterators_icarus.fcl
  LIBRARIES icarusalg_Geometry
            larcorealg_Geometry
            GeometryTestLib
            ${MF_MESSAGELOGGER}
            ${MF_UTILITIES}
            ${FHICLCPP}
            cetlib_except
	    ${ROOT_CORE}
  USE_BOOST_UNIT
)


# unit test (use the hard-coded configuration for ICARUS geometry)
cet_test(geometry_iterator_loop_icarus_test
  SOURCES geometry_iterator_loop_icarus_test.cxx
  DATAFILES ./test_geometry_iterators_icarus.fcl
  TEST_ARGS ./test_geometry_iterators_icarus.fcl
  LIBRARIES icarusalg_Geometry
            larcorealg_Geometry
            GeometryTestLib
            ${MF_MESSAGELOGGER}
            ${MF_UTILITIES}
            ${FHICLCPP}
            cetlib_except
	    ${ROOT_CORE}
)



install_headers()
install_fhicl()
install_source()
