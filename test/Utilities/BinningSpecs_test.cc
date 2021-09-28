/**
 * @file BinningSpecs_test.cc
 * @brief Unit test for `icarus::ns::util::BinningSpecs` class and utilities.
 * @author Gianluca Petrillo (petrillo@slac.stanford.edu)
 * @date September 21, 2021
 * @see icarusalg/Utilities/BinningSpecs.h
 */


// Boost libraries
#define BOOST_TEST_MODULE BinningSpecs
#include <cetlib/quiet_unit_test.hpp> // BOOST_AUTO_TEST_CASE()
#include <boost/test/test_tools.hpp> // BOOST_TEST()

// ICARUS libraries
#include "icarusalg/Utilities/BinningSpecs.h"


// -----------------------------------------------------------------------------
void BinningSpecs_NBinsFor_test() {
  
  using icarus::ns::util::BinningSpecs;
  
  BOOST_TEST(BinningSpecs::NBinsFor(-5.0, 8.0, 2.0) == 7UL);
  BOOST_TEST(BinningSpecs::NBinsFor(-5.0, 8.0, 0.1) == 130UL);
  BOOST_TEST(BinningSpecs::NBinsFor(-5.0, -5.0, 0.1) == 0UL);
  
} // BinningSpecs_test()


void BinningSpecs_test() {
  
  using icarus::ns::util::BinningSpecs;
  using boost::test_tools::tolerance;
  
  BinningSpecs const binning { -5.0, 8.0, 2.0 }; // range 13 split into 7 bins
  
  BOOST_TEST(binning.lower()    == -5.0, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  9.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    == 14.0, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    ==  7UL);
  BOOST_TEST(binning.binWidth() ==  2.0, 0.001% tolerance());
  
  BOOST_TEST(binning.binWith( -7.0) == -1);
  BOOST_TEST(binning.binWith( -6.0) == -1);
  BOOST_TEST(binning.binWith( -5.0) ==  0);
  BOOST_TEST(binning.binWith( -4.0) ==  0);
  BOOST_TEST(binning.binWith( -3.0) ==  1);
  BOOST_TEST(binning.binWith( -2.0) ==  1);
  BOOST_TEST(binning.binWith( -1.0) ==  2);
  BOOST_TEST(binning.binWith(  0.0) ==  2);
  BOOST_TEST(binning.binWith( +1.0) ==  3);
  BOOST_TEST(binning.binWith( +2.0) ==  3);
  BOOST_TEST(binning.binWith( +3.0) ==  4);
  BOOST_TEST(binning.binWith( +4.0) ==  4);
  BOOST_TEST(binning.binWith( +5.0) ==  5);
  BOOST_TEST(binning.binWith( +6.0) ==  5);
  BOOST_TEST(binning.binWith( +7.0) ==  6);
  BOOST_TEST(binning.binWith( +8.0) ==  6);
  BOOST_TEST(binning.binWith( +9.0) ==  7);
  BOOST_TEST(binning.binWith(+10.0) ==  7);
  BOOST_TEST(binning.binWith(+11.0) ==  8);
  BOOST_TEST(binning.binWith(+12.0) ==  8);
  BOOST_TEST(binning.binWith(+13.0) ==  9);
  
  BOOST_TEST(binning.binBorders(-1).first  ==  -7.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders(-1).second ==  -5.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 0).first  ==  -5.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 0).second ==  -3.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 1).first  ==  -3.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 1).second ==  -1.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 2).first  ==  -1.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 2).second ==  +1.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 3).first  ==  +1.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 3).second ==  +3.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 4).first  ==  +3.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 4).second ==  +5.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 5).first  ==  +5.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 5).second ==  +7.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 6).first  ==  +7.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 6).second ==  +9.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 7).first  ==  +9.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 7).second == +11.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 8).first  == +11.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 8).second == +13.0, 0.001% tolerance());
  BOOST_TEST(binning.binBorders( 9).first  == +13.0, 0.001% tolerance());
  
} // BinningSpecs_test()


// -----------------------------------------------------------------------------
void makeBinningFromBinWidth_alignment_test() {
  
  using boost::test_tools::tolerance;
  
  auto const binning
    = icarus::ns::util::makeBinningFromBinWidth(-5.0, 8.0, 2.0);
  
  BOOST_TEST(binning.lower()    == -6.0, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  8.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    == 14.0, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    ==  7UL);
  BOOST_TEST(binning.binWidth() ==  2.0, 0.001% tolerance());
  
} // makeBinningFromBinWidth_alignment_test()


void makeBinningFromBinWidth_extension_test() {
  
  using boost::test_tools::tolerance;
  
  auto const binning
    = icarus::ns::util::makeBinningFromBinWidth(-5.0, 7.5, 2.0);
  
  BOOST_TEST(binning.lower()    == -6.0, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  8.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    == 14.0, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    ==  7UL);
  BOOST_TEST(binning.binWidth() ==  2.0, 0.001% tolerance());
  
} // makeBinningFromBinWidth_extension_test()


void makeBinningFromBinWidth_defhints_test() {
  
  using boost::test_tools::tolerance;
  
  // this has bin width order of magnitude 0.1
  auto const binning
    = icarus::ns::util::makeBinningFromBinWidth(-1.0, 3.0, 0.25 );
  
  BOOST_TEST(binning.lower()    == -1.0, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  3.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    ==  4.0, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    == 20UL);
  BOOST_TEST(binning.binWidth() ==  0.2, 0.001% tolerance());
  
} // makeBinningFromBinWidth_defhints_test()


void makeBinningFromBinWidth_hints_test() {
  
  using boost::test_tools::tolerance;
  
  // this has bin width order of magnitude 0.1, so hints are 0.3 and 0.4:
  auto const binning
    = icarus::ns::util::makeBinningFromBinWidth(-1.0, 3.0, 0.25, { 3, 4 } );
  
  BOOST_TEST(binning.lower()    == -1.2, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  3.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    ==  4.2, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    == 14UL);
  BOOST_TEST(binning.binWidth() ==  0.3, 0.001% tolerance());
  
} // makeBinningFromBinWidth_hints_test()


void makeBinningFromBinWidth_stretch_test() {
  
  using boost::test_tools::tolerance;
  
  /*
   * this has bin width order of magnitude 0.1 (0.1 <= 0.25 < 1.0),
   * so the hint { 0.1, 0.3 } translates into bin width hints 0.01 and 0.03;
   * the starting number of bins is 16 (range of 4.0 divided by 0.25).
   * So the candidate ranges are 0.16 and 0.48, with stretch factors from
   * the original 4.0 of about 25 and ~0.87, both larger than the allowed
   * default (0.5). So the original proposal is kept.
   */
  auto const binning
    = icarus::ns::util::makeBinningFromBinWidth(-1.0, 3.0, 0.25, { 0.1, 0.3 } );
  
  BOOST_TEST(binning.lower()    == -1.0, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  3.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    ==  4.0, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    == 16UL);
  BOOST_TEST(binning.binWidth() ==  0.25, 0.001% tolerance());
  
} // makeBinningFromBinWidth_hints_test()


void makeBinningFromBinWidth_nohint_test() {
  
  using boost::test_tools::tolerance;
  
  // the original proposal is kept
  auto const binning
    = icarus::ns::util::makeBinningFromBinWidth(-1.0, 3.0, 0.25, {});
  
  BOOST_TEST(binning.lower()    == -1.0, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  3.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    ==  4.0, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    == 16UL);
  BOOST_TEST(binning.binWidth() ==  0.25, 0.001% tolerance());
  
} // makeBinningFromBinWidth_nohint_test()


//------------------------------------------------------------------------------
void makeBinningFromNBins_alignment_test() {
  
  using boost::test_tools::tolerance;
  
  // bin width = 13/7, order 1
  auto const binning
    = icarus::ns::util::makeBinningFromNBins(-5.0, 8.0, 7UL);
  
  BOOST_TEST(binning.lower()    == -6.0, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  8.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    == 14.0, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    ==  7UL);
  BOOST_TEST(binning.binWidth() ==  2.0, 0.001% tolerance());
  
} // makeBinningFromNBins_alignment_test()


void makeBinningFromNBins_extension_test() {
  
  using boost::test_tools::tolerance;
  
  auto const binning
    = icarus::ns::util::makeBinningFromNBins(-5.0, 7.5, 7UL);
  
  BOOST_TEST(binning.lower()    == -6.0, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  8.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    == 14.0, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    ==  7UL);
  BOOST_TEST(binning.binWidth() ==  2.0, 0.001% tolerance());
  
} // makeBinningFromNBins_extension_test()


void makeBinningFromNBins_defhints_test() {
  
  using boost::test_tools::tolerance;
  
  // this has bin width (4/9) of order of magnitude 0.1
  auto const binning
    = icarus::ns::util::makeBinningFromNBins(-1.0, 3.0, 9UL );
  
  BOOST_TEST(binning.lower()    == -1.2, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  3.2, 0.001% tolerance());
  BOOST_TEST(binning.range()    ==  4.4, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    == 11UL);
  BOOST_TEST(binning.binWidth() ==  0.4, 0.001% tolerance());
  
} // makeBinningFromNBins_defhints_test()


void makeBinningFromNBins_hints_test() {
  
  using boost::test_tools::tolerance;
  
  // this has bin width order of magnitude 1, so hints are 3 and 4:
  auto const binning
    = icarus::ns::util::makeBinningFromNBins(-1.0, 3.0, 3UL, { 1.0, 1.5 } );
  
  BOOST_TEST(binning.lower()    == -1.5, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  3.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    ==  4.5, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    ==  3UL);
  BOOST_TEST(binning.binWidth() ==  1.5, 0.001% tolerance());
  
} // makeBinningFromNBins()


void makeBinningFromNBins_stretch_test() {
  
  using boost::test_tools::tolerance;
  
  /*
   * this has bin width order of magnitude 0.1 (0.1 <= 4/9 < 1.0),
   * so the hint { 0.1, 0.3 } translates into bin width hints 0.01 and 0.03;
   * the starting number of bins is 9.
   * So the candidate ranges are 0.09 and 0.27, with stretch factors from
   * the original 4.0 of about ~44 and ~15, both larger than the allowed
   * default (0.5). So the original proposal is kept.
   */
  auto const binning
    = icarus::ns::util::makeBinningFromNBins(-1.0, 3.0, 9UL, { 0.1, 0.3 } );
  
  BOOST_TEST(binning.lower()    == -12.0/9.0, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  28.0/9.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    ==  40.0/9.0, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    ==  10UL);
  BOOST_TEST(binning.binWidth() ==   4.0/9.0, 0.001% tolerance());
  
} // makeBinningFromNBins_stretch_test()


void makeBinningFromNBins_nohint_test() {
  
  using boost::test_tools::tolerance;
  
  // the original proposal is kept
  auto const binning = icarus::ns::util::makeBinningFromNBins(-1.0, 3.0, 2, {});
  
  BOOST_TEST(binning.lower()    == -2.0, 0.001% tolerance());
  BOOST_TEST(binning.upper()    ==  4.0, 0.001% tolerance());
  BOOST_TEST(binning.range()    ==  6.0, 0.001% tolerance());
  BOOST_TEST(binning.nBins()    ==  3UL);
  BOOST_TEST(binning.binWidth() ==  2.0, 0.001% tolerance());
  
} // makeBinningFromNBins_nohint_test()


//------------------------------------------------------------------------------
//---  The tests
//---
BOOST_AUTO_TEST_CASE( BinningSpecs_testCase ) {
  
  BinningSpecs_NBinsFor_test();
  BinningSpecs_test();
  
} // BOOST_AUTO_TEST_CASE( BinningSpecs_testCase )


BOOST_AUTO_TEST_CASE( makeBinningFromBinWidth_testCase ) {
  
  makeBinningFromBinWidth_alignment_test();
  makeBinningFromBinWidth_extension_test();
  makeBinningFromBinWidth_defhints_test();
  makeBinningFromBinWidth_hints_test();
  makeBinningFromBinWidth_stretch_test();
  makeBinningFromBinWidth_nohint_test();
  
} // BOOST_AUTO_TEST_CASE( makeBinningFromBinWidth_testCase )


BOOST_AUTO_TEST_CASE( makeBinningFromNBins_testCase ) {
  
  makeBinningFromNBins_alignment_test();
  makeBinningFromNBins_extension_test();
  makeBinningFromNBins_defhints_test();
  makeBinningFromNBins_hints_test();
  makeBinningFromNBins_stretch_test();
  makeBinningFromNBins_nohint_test();
  
} // BOOST_AUTO_TEST_CASE( makeBinningFromNBins_testCase )


//------------------------------------------------------------------------------
