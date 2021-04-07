/**
 * @file FixedBins_test.cc
 * @brief Unit test for `FixedBins` class.
 * @author Gianluca Petrillo (petrillo@slac.stanford.edu)
 * @date March 28, 2021
 * @see icarusalg/Utilities/FixedBins.h
 */


// Boost libraries
#define BOOST_TEST_MODULE FixedBins
#include <cetlib/quiet_unit_test.hpp> // BOOST_AUTO_TEST_CASE()
#include <boost/test/test_tools.hpp> // BOOST_CHECK(), BOOST_CHECK_EQUAL(), ...

// ICARUS libraries
#include "icarusalg/Utilities/FixedBins.h"


// -----------------------------------------------------------------------------
void BasicTest() {
  
  icarus::ns::util::FixedBins bins { 2.0, -1.0 }; // initializes doubles
  std::vector<unsigned int> expectedContent;
  
  BOOST_CHECK_EQUAL(bins.binWidth(), 2.0);
  BOOST_CHECK_EQUAL(bins.offset(), -1.0);
  
  BOOST_CHECK(bins.empty());
  BOOST_CHECK(empty(bins));
  BOOST_CHECK_EQUAL(bins.size(), 0U);
  BOOST_CHECK_EQUAL(size(bins), 0U);
  BOOST_CHECK(bins.cbegin() == bins.cend());
  BOOST_CHECK(bins.begin() == bins.end());
  BOOST_CHECK_EQUAL(bins.nBins(), 0U);
  BOOST_CHECK_EQUAL(bins.range(), 0.0);
  BOOST_CHECK_EQUAL(bins.count(-2), 0U);
  BOOST_CHECK_EQUAL(bins.count(-1), 0U);
  BOOST_CHECK_EQUAL(bins.count( 0), 0U);
  BOOST_CHECK_EQUAL(bins.count( 1), 0U);
  BOOST_CHECK_EQUAL(bins.count( 2), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-5.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-4.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-3.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-2.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-1.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-0.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+0.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+1.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+2.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+3.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+4.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+5.0), 0U);
  BOOST_CHECK_EQUAL(bins[-2], 0U);
  BOOST_CHECK_EQUAL(bins[-1], 0U);
  BOOST_CHECK_EQUAL(bins[ 0], 0U);
  BOOST_CHECK_EQUAL(bins[ 1], 0U);
  BOOST_CHECK_EQUAL(bins[ 2], 0U);
  
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  bins.add(3.5);
  expectedContent = { 1 };
  BOOST_CHECK(!bins.empty());
  BOOST_CHECK(!empty(bins));
  BOOST_CHECK_EQUAL(bins.size(), 1U);
  BOOST_CHECK_EQUAL(size(bins), 1U);
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.begin(), bins.end(), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.cbegin(), bins.cend(), expectedContent.cbegin(), expectedContent.cend());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (begin(bins), end(bins), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (cbegin(bins), cend(bins), expectedContent.cbegin(), expectedContent.cend());
  BOOST_CHECK_EQUAL(bins.nBins(), 1U);
  BOOST_CHECK_EQUAL(bins.range(), 2.0);
  BOOST_CHECK_EQUAL(bins.minBin(), 0);
  BOOST_CHECK_EQUAL(bins.maxBin(), 0);
  BOOST_CHECK_EQUAL(bins.min(), +3.0);
  BOOST_CHECK_EQUAL(bins.max(), +5.0);
  BOOST_CHECK_EQUAL(bins.count(-2), 0U);
  BOOST_CHECK_EQUAL(bins.count(-1), 0U);
  BOOST_CHECK_EQUAL(bins.count( 0), 1U);
  BOOST_CHECK_EQUAL(bins.count( 1), 0U);
  BOOST_CHECK_EQUAL(bins.count( 2), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-5.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-4.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-3.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-2.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-1.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-0.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+0.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+1.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+2.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+3.0), 1U);
  BOOST_CHECK_EQUAL(bins.countFor(+4.0), 1U);
  BOOST_CHECK_EQUAL(bins.countFor(+5.0), 0U);
  BOOST_CHECK_EQUAL(bins[-2], 0U);
  BOOST_CHECK_EQUAL(bins[-1], 0U);
  BOOST_CHECK_EQUAL(bins[ 0], 1U);
  BOOST_CHECK_EQUAL(bins[ 1], 0U);
  BOOST_CHECK_EQUAL(bins[ 2], 0U);
  
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  bins.add(-4.0);
  expectedContent = { 1U, 0U, 0U, 0U, 1U };
  BOOST_CHECK(!bins.empty());
  BOOST_CHECK(!empty(bins));
  BOOST_CHECK_EQUAL(bins.size(), 5U);
  BOOST_CHECK_EQUAL(size(bins), 5U);
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.begin(), bins.end(), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.cbegin(), bins.cend(), expectedContent.cbegin(), expectedContent.cend());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (begin(bins), end(bins), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (cbegin(bins), cend(bins), expectedContent.cbegin(), expectedContent.cend());
  BOOST_CHECK_EQUAL(bins.nBins(), 5U);
  BOOST_CHECK_EQUAL(bins.range(), 10.0);
  BOOST_CHECK_EQUAL(bins.minBin(), -4);
  BOOST_CHECK_EQUAL(bins.maxBin(),  0);
  BOOST_CHECK_EQUAL(bins.min(), -5.0);
  BOOST_CHECK_EQUAL(bins.max(), +5.0);
  BOOST_CHECK_EQUAL(bins.count(-5), 0U);
  BOOST_CHECK_EQUAL(bins.count(-4), 1U);
  BOOST_CHECK_EQUAL(bins.count(-3), 0U);
  BOOST_CHECK_EQUAL(bins.count(-2), 0U);
  BOOST_CHECK_EQUAL(bins.count(-1), 0U);
  BOOST_CHECK_EQUAL(bins.count( 0), 1U);
  BOOST_CHECK_EQUAL(bins.count( 1), 0U);
  BOOST_CHECK_EQUAL(bins.count( 2), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-5.0), 1U);
  BOOST_CHECK_EQUAL(bins.countFor(-4.0), 1U);
  BOOST_CHECK_EQUAL(bins.countFor(-3.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-2.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-1.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-0.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+0.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+1.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+2.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+3.0), 1U);
  BOOST_CHECK_EQUAL(bins.countFor(+4.0), 1U);
  BOOST_CHECK_EQUAL(bins.countFor(+5.0), 0U);
  BOOST_CHECK_EQUAL(bins[-5], 0U);
  BOOST_CHECK_EQUAL(bins[-4], 1U);
  BOOST_CHECK_EQUAL(bins[-3], 0U);
  BOOST_CHECK_EQUAL(bins[-2], 0U);
  BOOST_CHECK_EQUAL(bins[-1], 0U);
  BOOST_CHECK_EQUAL(bins[ 0], 1U);
  BOOST_CHECK_EQUAL(bins[ 1], 0U);
  BOOST_CHECK_EQUAL(bins[ 2], 0U);
  
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  bins.add(-4.5);
  expectedContent = { 2U, 0U, 0U, 0U, 1U };
  BOOST_CHECK(!bins.empty());
  BOOST_CHECK(!empty(bins));
  BOOST_CHECK_EQUAL(bins.size(), 5U);
  BOOST_CHECK_EQUAL(size(bins), 5U);
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.begin(), bins.end(), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.cbegin(), bins.cend(), expectedContent.cbegin(), expectedContent.cend());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (begin(bins), end(bins), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (cbegin(bins), cend(bins), expectedContent.cbegin(), expectedContent.cend());
  BOOST_CHECK_EQUAL(bins.nBins(), 5U);
  BOOST_CHECK_EQUAL(bins.range(), 10.0);
  BOOST_CHECK_EQUAL(bins.minBin(), -4);
  BOOST_CHECK_EQUAL(bins.maxBin(),  0);
  BOOST_CHECK_EQUAL(bins.min(), -5.0);
  BOOST_CHECK_EQUAL(bins.max(), +5.0);
  BOOST_CHECK_EQUAL(bins.count(-5), 0U);
  BOOST_CHECK_EQUAL(bins.count(-4), 2U);
  BOOST_CHECK_EQUAL(bins.count(-3), 0U);
  BOOST_CHECK_EQUAL(bins.count(-2), 0U);
  BOOST_CHECK_EQUAL(bins.count(-1), 0U);
  BOOST_CHECK_EQUAL(bins.count( 0), 1U);
  BOOST_CHECK_EQUAL(bins.count( 1), 0U);
  BOOST_CHECK_EQUAL(bins.count( 2), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-5.0), 2U);
  BOOST_CHECK_EQUAL(bins.countFor(-4.0), 2U);
  BOOST_CHECK_EQUAL(bins.countFor(-3.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-2.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-1.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-0.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+0.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+1.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+2.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+3.0), 1U);
  BOOST_CHECK_EQUAL(bins.countFor(+4.0), 1U);
  BOOST_CHECK_EQUAL(bins.countFor(+5.0), 0U);
  BOOST_CHECK_EQUAL(bins[-5], 0U);
  BOOST_CHECK_EQUAL(bins[-4], 2U);
  BOOST_CHECK_EQUAL(bins[-3], 0U);
  BOOST_CHECK_EQUAL(bins[-2], 0U);
  BOOST_CHECK_EQUAL(bins[-1], 0U);
  BOOST_CHECK_EQUAL(bins[ 0], 1U);
  BOOST_CHECK_EQUAL(bins[ 1], 0U);
  BOOST_CHECK_EQUAL(bins[ 2], 0U);
  
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  bins.clear();
  BOOST_CHECK_EQUAL(bins.binWidth(), 2.0);
  BOOST_CHECK_EQUAL(bins.offset(), -1.0);
  
  BOOST_CHECK(bins.empty());
  BOOST_CHECK(empty(bins));
  BOOST_CHECK_EQUAL(bins.size(), 0U);
  BOOST_CHECK_EQUAL(size(bins), 0U);
  BOOST_CHECK(bins.cbegin() == bins.cend());
  BOOST_CHECK(bins.begin() == bins.end());
  BOOST_CHECK_EQUAL(bins.nBins(), 0U);
  BOOST_CHECK_EQUAL(bins.range(), 0.0);
  BOOST_CHECK_EQUAL(bins.count(-2), 0U);
  BOOST_CHECK_EQUAL(bins.count(-1), 0U);
  BOOST_CHECK_EQUAL(bins.count( 0), 0U);
  BOOST_CHECK_EQUAL(bins.count( 1), 0U);
  BOOST_CHECK_EQUAL(bins.count( 2), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-5.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-4.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-3.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-2.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-1.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(-0.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+0.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+1.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+2.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+3.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+4.0), 0U);
  BOOST_CHECK_EQUAL(bins.countFor(+5.0), 0U);
  BOOST_CHECK_EQUAL(bins[-2], 0U);
  BOOST_CHECK_EQUAL(bins[-1], 0U);
  BOOST_CHECK_EQUAL(bins[ 0], 0U);
  BOOST_CHECK_EQUAL(bins[ 1], 0U);
  BOOST_CHECK_EQUAL(bins[ 2], 0U);
  
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
} // BasicTest()


//------------------------------------------------------------------------------
//---  The tests
//---
BOOST_AUTO_TEST_CASE( TestCase ) {
  
  BasicTest();
  
} // BOOST_AUTO_TEST_CASE( TestCase )


//------------------------------------------------------------------------------
