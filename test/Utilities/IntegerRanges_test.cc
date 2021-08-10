/**
 * @file   IntegerRanges_test.cc
 * @brief  Unit test for `IntegerRanges` class.
 * @author Gianluca Petrillo (petrillo@slac.stanford.edu)
 * @date   May 18, 2021
 * @see    icarusalg/Utilities/IntegerRanges.h
 */


// Boost libraries
#define BOOST_TEST_MODULE IntegerRanges
#include <boost/test/unit_test.hpp>

// ICARUS libraries
#include "icarusalg/Utilities/IntegerRanges.h"

// LArSoft libraries
#include "larcorealg/CoreUtils/enumerate.h"

// C/C++ standard libraries
#include <iostream>
#include <utility> // std::pair<>
#include <array>
#include <type_traits> // std::is_same_v, std::remove_reference_t


// -----------------------------------------------------------------------------
template <typename Cont>
std::size_t count(Cont const& cont)
  { return std::distance(begin(cont), end(cont)); }


// -----------------------------------------------------------------------------
void TestConstDefaultConstructed() {
  
  icarus::IntegerRanges<int> const ranges;
  
  BOOST_CHECK(ranges.empty());
  BOOST_CHECK_EQUAL(ranges.size(), 0U);
  BOOST_CHECK_EQUAL(ranges.nRanges(), 0U);
  BOOST_CHECK_EQUAL(count(ranges.ranges()), 0U);
  
} // TestConstDefaultConstructed()


// -----------------------------------------------------------------------------
void TestDefaultConstructed() {
  
  icarus::IntegerRanges<int> ranges;
  
  BOOST_CHECK(ranges.empty());
  BOOST_CHECK_EQUAL(ranges.size(), 0U);
  BOOST_CHECK_EQUAL(ranges.nRanges(), 0U);
  BOOST_CHECK_EQUAL(count(ranges.ranges()), 0U);
  
  ranges.clear();
  BOOST_CHECK(ranges.empty());
  BOOST_CHECK_EQUAL(ranges.size(), 0U);
  BOOST_CHECK_EQUAL(ranges.nRanges(), 0U);
  BOOST_CHECK_EQUAL(count(ranges.ranges()), 0U);
  
} // TestDefaultConstructed()


// -----------------------------------------------------------------------------
void TestInitializerList() {
  
  
  std::array const test { 1, 2, 3, 4, 6, 7, 8, 10, 11 };
  std::array<std::pair<int, int>, 3U> const groups = {
    std::pair{ 1, 5 },
    std::pair{ 6, 9 },
    std::pair{ 10, 12 }
  };
  
  
  icarus::IntegerRanges ranges { 1, 2, 3, 4, 6, 7, 8, 10, 11 };
  std::cout << "Testing: " << ranges << std::endl;
  
  BOOST_CHECK_EQUAL(ranges.empty(), test.empty());
  BOOST_CHECK_EQUAL(ranges.size(), test.size());
  BOOST_CHECK_EQUAL(ranges.nRanges(), groups.size());
  
  auto const& rangeContent = ranges.ranges();
  for (auto const& [ i, r, e ]: util::enumerate(rangeContent, groups)) {
    BOOST_TEST_MESSAGE("[" << i << "]");
    BOOST_CHECK_EQUAL(r.lower, e.first);
    BOOST_CHECK_EQUAL(r.upper, e.second);
  } // for
  
} // TestInitializerList()


// -----------------------------------------------------------------------------
void TestCollection() {
  
  
  std::array const test { 1, 2, 3, 4, 6, 7, 8, 10, 11 };
  std::array<std::pair<int, int>, 3U> const groups = {
    std::pair{ 1, 5 },
    std::pair{ 6, 9 },
    std::pair{ 10, 12 }
  };
  
  
  auto const ranges = icarus::makeIntegerRanges(test);
  static_assert(std::is_same_v<
    std::remove_reference_t<decltype(ranges)>,
    icarus::IntegerRanges<int, true> const
    >);
  std::cout << "Testing: " << ranges << std::endl;
  
  BOOST_CHECK_EQUAL(ranges.empty(), test.empty());
  BOOST_CHECK_EQUAL(ranges.size(), test.size());
  BOOST_CHECK_EQUAL(ranges.nRanges(), groups.size());
  
  auto const& rangeContent = ranges.ranges();
  for (auto const& [ i, r, e ]: util::enumerate(rangeContent, groups)) {
    BOOST_TEST_MESSAGE("[" << i << "]");
    BOOST_CHECK_EQUAL(r.lower, e.first);
    BOOST_CHECK_EQUAL(r.upper, e.second);
  } // for
  
} // TestCollection()


// -----------------------------------------------------------------------------
void TestSparse() {
  
  
  std::array const test { 1, 2, 3, 4, 6, 7, 8, 10, 11 };
  std::array<std::pair<int, int>, 3U> const groups = {
    std::pair{ 1, 5 },
    std::pair{ 6, 9 },
    std::pair{ 10, 12 }
  };
  
  
  icarus::IntegerRanges ranges { test.begin(), test.end() };
  std::cout << "Testing: " << ranges << std::endl;
  
  BOOST_CHECK_EQUAL(ranges.empty(), test.empty());
  BOOST_CHECK_EQUAL(ranges.size(), test.size());
  BOOST_CHECK_EQUAL(ranges.nRanges(), groups.size());
  
  auto const& rangeContent = ranges.ranges();
  for (auto const& [ i, r, e ]: util::enumerate(rangeContent, groups)) {
    BOOST_TEST_MESSAGE("[" << i << "]");
    BOOST_CHECK_EQUAL(r.lower, e.first);
    BOOST_CHECK_EQUAL(r.upper, e.second);
  } // for
  
} // TestSparse()


// -----------------------------------------------------------------------------
void TestSingles() {
  
  
  std::array const test { 1, 3, 6, 7, 8, 11 };
  std::array<std::pair<int, int>, 4U> const groups = {
    std::pair{ 1, 2 },
    std::pair{ 3, 4 },
    std::pair{ 6, 9 },
    std::pair{ 11, 12 }
  };
  
  
  icarus::IntegerRanges ranges { test.begin(), test.end() };
  std::cout << "Testing: " << ranges << std::endl;
  
  BOOST_CHECK_EQUAL(ranges.empty(), test.empty());
  BOOST_CHECK_EQUAL(ranges.size(), test.size());
  BOOST_CHECK_EQUAL(ranges.nRanges(), groups.size());
  
  auto const& rangeContent = ranges.ranges();
  for (auto const& [ i, r, e ]: util::enumerate(rangeContent, groups)) {
    BOOST_TEST_MESSAGE("[" << i << "]");
    BOOST_CHECK_EQUAL(r.lower, e.first);
    BOOST_CHECK_EQUAL(r.upper, e.second);
  } // for
  
} // TestSingles()


// -----------------------------------------------------------------------------
void TestDuplicates() {
  
  std::array const test { 1, 1, 3, 6, 6, 6, 7, 8, 11, 11 };
  std::array<std::pair<int, int>, 4U> const groups = {
    std::pair{ 1, 2 },
    std::pair{ 3, 4 },
    std::pair{ 6, 9 },
    std::pair{ 11, 12 }
  };
  
  
  icarus::IntegerRanges ranges { test.begin(), test.end() };
  std::cout << "Testing: " << ranges << std::endl;
  
  BOOST_CHECK_EQUAL(ranges.empty(), test.empty());
  BOOST_CHECK_EQUAL(ranges.size(), test.size() - 4U); // account for duplicates
  BOOST_CHECK_EQUAL(ranges.nRanges(), groups.size());
  
  auto const& rangeContent = ranges.ranges();
  for (auto const& [ i, r, e ]: util::enumerate(rangeContent, groups)) {
    BOOST_TEST_MESSAGE("[" << i << "]");
    BOOST_CHECK_EQUAL(r.lower, e.first);
    BOOST_CHECK_EQUAL(r.upper, e.second);
  } // for
  
} // TestDuplicates()


// -----------------------------------------------------------------------------
void TestUnsorted() {
  
  std::array const test { 1, 3, 7, 8, 8, 6, 11 };
  
  BOOST_CHECK_THROW(
    (icarus::IntegerRanges<int, true>{ test.begin(), test.end() }),
    std::runtime_error
    );
  
  // technically, the following is also allowed to throw (not guaranteed to)
  BOOST_CHECK_NO_THROW(
    (icarus::IntegerRanges<int, false>{ test.begin(), test.end() })
    );
  
} // TestDuplicates()


//------------------------------------------------------------------------------
void TestIntegerRangesDocumentation() {
  
  /*
   * The promise:
   * 
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   * std::array data { 1, 2, 4, 5, 6, 8, 10 };
   * 
   * IntegerRanges ranges { data };
   * std::cout << "Ranges: " << ranges << std::endl;
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   * will print something like `Ranges: 1 2 4--6 8 10`.
   */
   
  std::array data { 1, 2, 4, 5, 5, 6, 8, 10 };
  
  icarus::IntegerRanges ranges { icarus::makeIntegerRanges(data) };
  std::cout << "Ranges: " << ranges << std::endl;
  
  // ----------------------------------------------------------------------------
  std::stringstream sstr;
  sstr << "Ranges: " << ranges;
  BOOST_CHECK_EQUAL(sstr.str(), "Ranges: 1 2 4--6 8 10");
  
} // TestIntegerRangesDocumentation()


//------------------------------------------------------------------------------
//---  The tests
//---
BOOST_AUTO_TEST_CASE( BasicTestCase ) {
  
  TestConstDefaultConstructed();
  TestDefaultConstructed();
  TestInitializerList();
  TestCollection();
  TestSparse();
  TestSingles();
  TestDuplicates();
  TestUnsorted();
  
} // BOOST_AUTO_TEST_CASE( BasicTestCase )


BOOST_AUTO_TEST_CASE( DocumentationTestCase ) {
  
  TestIntegerRangesDocumentation();
  
} // BOOST_AUTO_TEST_CASE( DocumentationTestCase )


//------------------------------------------------------------------------------
