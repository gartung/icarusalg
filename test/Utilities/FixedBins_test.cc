/**
 * @file FixedBins_test.cc
 * @brief Unit test for `FixedBins` class.
 * @author Gianluca Petrillo (petrillo@slac.stanford.edu)
 * @date March 28, 2021
 * @see icarusalg/Utilities/FixedBins.h
 */


// Boost libraries
#define BOOST_TEST_MODULE FixedBins
#include <boost/test/unit_test.hpp>

// ICARUS libraries
#include "icarusalg/Utilities/FixedBins.h"


// -----------------------------------------------------------------------------
void BasicTest() {
  
  icarus::ns::util::FixedBins bins { 2.0, -1.0 }; // initializes doubles
  std::vector<unsigned int> expectedContent;
  
  BOOST_TEST((bins.binWidth() ==  2.0));
  BOOST_TEST((bins.offset() ==  -1.0));
  
  BOOST_CHECK((bins.empty()));
  BOOST_CHECK((empty(bins)));
  BOOST_TEST((bins.size() ==  0U));
  BOOST_TEST((size(bins) ==  0U));
  BOOST_TEST((bins.cbegin() == bins.cend()));
  BOOST_TEST((bins.begin() == bins.end()));
  BOOST_TEST((bins.nBins() ==  0U));
  BOOST_TEST((bins.range() ==  0.0));
  BOOST_TEST((bins.count(-2) ==  0U));
  BOOST_TEST((bins.count(-1) ==  0U));
  BOOST_TEST((bins.count( 0) ==  0U));
  BOOST_TEST((bins.count( 1) ==  0U));
  BOOST_TEST((bins.count( 2) ==  0U));
  BOOST_TEST((bins.countFor(-5.0) ==  0U));
  BOOST_TEST((bins.countFor(-4.0) ==  0U));
  BOOST_TEST((bins.countFor(-3.0) ==  0U));
  BOOST_TEST((bins.countFor(-2.0) ==  0U));
  BOOST_TEST((bins.countFor(-1.0) ==  0U));
  BOOST_TEST((bins.countFor(-0.0) ==  0U));
  BOOST_TEST((bins.countFor(+0.0) ==  0U));
  BOOST_TEST((bins.countFor(+1.0) ==  0U));
  BOOST_TEST((bins.countFor(+2.0) ==  0U));
  BOOST_TEST((bins.countFor(+3.0) ==  0U));
  BOOST_TEST((bins.countFor(+4.0) ==  0U));
  BOOST_TEST((bins.countFor(+5.0) ==  0U));
  BOOST_TEST((bins[-2] ==  0U));
  BOOST_TEST((bins[-1] ==  0U));
  BOOST_TEST((bins[ 0] ==  0U));
  BOOST_TEST((bins[ 1] ==  0U));
  BOOST_TEST((bins[ 2] ==  0U));
  
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  bins.add(3.5);
  expectedContent = { 1 };
  BOOST_CHECK((!bins.empty()));
  BOOST_CHECK((!empty(bins)));
  BOOST_TEST((bins.size() ==  1U));
  BOOST_TEST((size(bins) ==  1U));
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.begin(), bins.end(), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.cbegin(), bins.cend(), expectedContent.cbegin(), expectedContent.cend());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (begin(bins), end(bins), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (cbegin(bins), cend(bins), expectedContent.cbegin(), expectedContent.cend());
  BOOST_TEST((bins.nBins() ==  1U));
  BOOST_TEST((bins.range() ==  2.0));
  BOOST_TEST((bins.minBin() ==  0));
  BOOST_TEST((bins.maxBin() ==  0));
  BOOST_TEST((bins.min() ==  +3.0));
  BOOST_TEST((bins.max() ==  +5.0));
  BOOST_TEST((bins.count(-2) ==  0U));
  BOOST_TEST((bins.count(-1) ==  0U));
  BOOST_TEST((bins.count( 0) ==  1U));
  BOOST_TEST((bins.count( 1) ==  0U));
  BOOST_TEST((bins.count( 2) ==  0U));
  BOOST_TEST((bins.countFor(-5.0) ==  0U));
  BOOST_TEST((bins.countFor(-4.0) ==  0U));
  BOOST_TEST((bins.countFor(-3.0) ==  0U));
  BOOST_TEST((bins.countFor(-2.0) ==  0U));
  BOOST_TEST((bins.countFor(-1.0) ==  0U));
  BOOST_TEST((bins.countFor(-0.0) ==  0U));
  BOOST_TEST((bins.countFor(+0.0) ==  0U));
  BOOST_TEST((bins.countFor(+1.0) ==  0U));
  BOOST_TEST((bins.countFor(+2.0) ==  0U));
  BOOST_TEST((bins.countFor(+3.0) ==  1U));
  BOOST_TEST((bins.countFor(+4.0) ==  1U));
  BOOST_TEST((bins.countFor(+5.0) ==  0U));
  BOOST_TEST((bins[-2] ==  0U));
  BOOST_TEST((bins[-1] ==  0U));
  BOOST_TEST((bins[ 0] ==  1U));
  BOOST_TEST((bins[ 1] ==  0U));
  BOOST_TEST((bins[ 2] ==  0U));
  
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  bins.add(-4.0);
  expectedContent = { 1U, 0U, 0U, 0U, 1U };
  BOOST_CHECK((!bins.empty()));
  BOOST_CHECK((!empty(bins)));
  BOOST_TEST((bins.size() ==  5U));
  BOOST_TEST((size(bins) ==  5U));
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.begin(), bins.end(), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.cbegin(), bins.cend(), expectedContent.cbegin(), expectedContent.cend());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (begin(bins), end(bins), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (cbegin(bins), cend(bins), expectedContent.cbegin(), expectedContent.cend());
  BOOST_TEST((bins.nBins() ==  5U));
  BOOST_TEST((bins.range() ==  10.0));
  BOOST_TEST((bins.minBin() ==  -4));
  BOOST_TEST((bins.maxBin() ==   0));
  BOOST_TEST((bins.min() ==  -5.0));
  BOOST_TEST((bins.max() ==  +5.0));
  BOOST_TEST((bins.count(-5) ==  0U));
  BOOST_TEST((bins.count(-4) ==  1U));
  BOOST_TEST((bins.count(-3) ==  0U));
  BOOST_TEST((bins.count(-2) ==  0U));
  BOOST_TEST((bins.count(-1) ==  0U));
  BOOST_TEST((bins.count( 0) ==  1U));
  BOOST_TEST((bins.count( 1) ==  0U));
  BOOST_TEST((bins.count( 2) ==  0U));
  BOOST_TEST((bins.countFor(-5.0) ==  1U));
  BOOST_TEST((bins.countFor(-4.0) ==  1U));
  BOOST_TEST((bins.countFor(-3.0) ==  0U));
  BOOST_TEST((bins.countFor(-2.0) ==  0U));
  BOOST_TEST((bins.countFor(-1.0) ==  0U));
  BOOST_TEST((bins.countFor(-0.0) ==  0U));
  BOOST_TEST((bins.countFor(+0.0) ==  0U));
  BOOST_TEST((bins.countFor(+1.0) ==  0U));
  BOOST_TEST((bins.countFor(+2.0) ==  0U));
  BOOST_TEST((bins.countFor(+3.0) ==  1U));
  BOOST_TEST((bins.countFor(+4.0) ==  1U));
  BOOST_TEST((bins.countFor(+5.0) ==  0U));
  BOOST_TEST((bins[-5] ==  0U));
  BOOST_TEST((bins[-4] ==  1U));
  BOOST_TEST((bins[-3] ==  0U));
  BOOST_TEST((bins[-2] ==  0U));
  BOOST_TEST((bins[-1] ==  0U));
  BOOST_TEST((bins[ 0] ==  1U));
  BOOST_TEST((bins[ 1] ==  0U));
  BOOST_TEST((bins[ 2] ==  0U));
  
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  bins.add(-4.5);
  expectedContent = { 2U, 0U, 0U, 0U, 1U };
  BOOST_CHECK((!bins.empty()));
  BOOST_CHECK((!empty(bins)));
  BOOST_TEST((bins.size() ==  5U));
  BOOST_TEST((size(bins) ==  5U));
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.begin(), bins.end(), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (bins.cbegin(), bins.cend(), expectedContent.cbegin(), expectedContent.cend());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (begin(bins), end(bins), expectedContent.begin(), expectedContent.end());
  BOOST_CHECK_EQUAL_COLLECTIONS
    (cbegin(bins), cend(bins), expectedContent.cbegin(), expectedContent.cend());
  BOOST_TEST((bins.nBins() ==  5U));
  BOOST_TEST((bins.range() ==  10.0));
  BOOST_TEST((bins.minBin() ==  -4));
  BOOST_TEST((bins.maxBin() ==   0));
  BOOST_TEST((bins.min() ==  -5.0));
  BOOST_TEST((bins.max() ==  +5.0));
  BOOST_TEST((bins.count(-5) ==  0U));
  BOOST_TEST((bins.count(-4) ==  2U));
  BOOST_TEST((bins.count(-3) ==  0U));
  BOOST_TEST((bins.count(-2) ==  0U));
  BOOST_TEST((bins.count(-1) ==  0U));
  BOOST_TEST((bins.count( 0) ==  1U));
  BOOST_TEST((bins.count( 1) ==  0U));
  BOOST_TEST((bins.count( 2) ==  0U));
  BOOST_TEST((bins.countFor(-5.0) ==  2U));
  BOOST_TEST((bins.countFor(-4.0) ==  2U));
  BOOST_TEST((bins.countFor(-3.0) ==  0U));
  BOOST_TEST((bins.countFor(-2.0) ==  0U));
  BOOST_TEST((bins.countFor(-1.0) ==  0U));
  BOOST_TEST((bins.countFor(-0.0) ==  0U));
  BOOST_TEST((bins.countFor(+0.0) ==  0U));
  BOOST_TEST((bins.countFor(+1.0) ==  0U));
  BOOST_TEST((bins.countFor(+2.0) ==  0U));
  BOOST_TEST((bins.countFor(+3.0) ==  1U));
  BOOST_TEST((bins.countFor(+4.0) ==  1U));
  BOOST_TEST((bins.countFor(+5.0) ==  0U));
  BOOST_TEST((bins[-5] ==  0U));
  BOOST_TEST((bins[-4] ==  2U));
  BOOST_TEST((bins[-3] ==  0U));
  BOOST_TEST((bins[-2] ==  0U));
  BOOST_TEST((bins[-1] ==  0U));
  BOOST_TEST((bins[ 0] ==  1U));
  BOOST_TEST((bins[ 1] ==  0U));
  BOOST_TEST((bins[ 2] ==  0U));
  
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  bins.clear();
  BOOST_TEST((bins.binWidth() ==  2.0));
  BOOST_TEST((bins.offset() ==  -1.0));
  
  BOOST_CHECK((bins.empty()));
  BOOST_CHECK((empty(bins)));
  BOOST_TEST((bins.size() ==  0U));
  BOOST_TEST((size(bins) ==  0U));
  BOOST_TEST((bins.cbegin() == bins.cend()));
  BOOST_TEST((bins.begin() == bins.end()));
  BOOST_TEST((bins.nBins() ==  0U));
  BOOST_TEST((bins.range() ==  0.0));
  BOOST_TEST((bins.count(-2) ==  0U));
  BOOST_TEST((bins.count(-1) ==  0U));
  BOOST_TEST((bins.count( 0) ==  0U));
  BOOST_TEST((bins.count( 1) ==  0U));
  BOOST_TEST((bins.count( 2) ==  0U));
  BOOST_TEST((bins.countFor(-5.0) ==  0U));
  BOOST_TEST((bins.countFor(-4.0) ==  0U));
  BOOST_TEST((bins.countFor(-3.0) ==  0U));
  BOOST_TEST((bins.countFor(-2.0) ==  0U));
  BOOST_TEST((bins.countFor(-1.0) ==  0U));
  BOOST_TEST((bins.countFor(-0.0) ==  0U));
  BOOST_TEST((bins.countFor(+0.0) ==  0U));
  BOOST_TEST((bins.countFor(+1.0) ==  0U));
  BOOST_TEST((bins.countFor(+2.0) ==  0U));
  BOOST_TEST((bins.countFor(+3.0) ==  0U));
  BOOST_TEST((bins.countFor(+4.0) ==  0U));
  BOOST_TEST((bins.countFor(+5.0) ==  0U));
  BOOST_TEST((bins[-2] ==  0U));
  BOOST_TEST((bins[-1] ==  0U));
  BOOST_TEST((bins[ 0] ==  0U));
  BOOST_TEST((bins[ 1] ==  0U));
  BOOST_TEST((bins[ 2] ==  0U));
  
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
} // BasicTest()


//------------------------------------------------------------------------------
//---  The tests
//---
BOOST_AUTO_TEST_CASE( TestCase ) {
  
  BasicTest();
  
} // BOOST_AUTO_TEST_CASE( TestCase )


//------------------------------------------------------------------------------
