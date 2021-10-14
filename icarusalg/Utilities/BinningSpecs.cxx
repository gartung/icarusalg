/**
 * @file   icarusalg/Utilities/BinningSpecs.cxx
 * @brief  Simple utility for human-friendly binning.
 * @author Gianluca Petrillo (petrillo@slac.stanford.edu)
 * @date   September 21, 2021
 * @see    icarusalg/Utilities/BinningSpecs.h
 * 
 * 
 */

// library header
#include "icarusalg/Utilities/BinningSpecs.h"

// C/C++ standard libraries
#include <utility> // std::move(), std::pair
#include <cmath>
#include <cassert>


// -----------------------------------------------------------------------------
// --- Implementation
// -----------------------------------------------------------------------------
namespace {
  
  /// Returns the smallest multiple of `factor` not larger than `value`.
  double floorMult(double value, double factor)
    { return factor * std::floor(value / factor); }
  
  /// Returns a binning with boundaries aligned to `0`.
  icarus::ns::util::BinningSpecs makeBinningAlignedTo0
    (double lower, double upper, double width)
  {
    return icarus::ns::util::BinningSpecs
      { floorMult(lower, width), upper, width };
  }
  
} // local namespace


// -----------------------------------------------------------------------------
// ---  icarus::ns::util::BinningSpecs
// -----------------------------------------------------------------------------
icarus::ns::util::BinningSpecs::BinningSpecs
  (double lower, double upper, double width)
  : fLower{ lower }
  , fWidth{ width }
  , fNBins{ NBinsFor(fLower, upper, fWidth) }
  , fUpper{ fLower + fNBins * fWidth }
{
  assert(lower <= upper);
  assert(width >= 0.0);
  assert(fLower <= lower);
  assert(fUpper >= upper);
}


// -----------------------------------------------------------------------------
int icarus::ns::util::BinningSpecs::binWith(double value) const
  { return static_cast<int>(std::floor((value - lower()) / binWidth())); }


// -----------------------------------------------------------------------------
std::pair<double, double> icarus::ns::util::BinningSpecs::binBorders
  (int iBin) const
{
  double const low = lower() + binWidth() * iBin;
  return { low, low + binWidth() };
} // icarus::ns::util::BinningSpecs::binBorders()


// -----------------------------------------------------------------------------
unsigned long icarus::ns::util::BinningSpecs::NBinsFor
  (double lower, double upper, double width)
  { return static_cast<unsigned long>(std::ceil((upper - lower) / width)); }


// -----------------------------------------------------------------------------
// ---  functions
// -----------------------------------------------------------------------------
auto icarus::ns::util::makeBinningFromBinWidth(
  double lower, double upper, double width,
  std::initializer_list<double> hints /* = DefaultBinningHints */,
  double allowedStretch /* = DefaultAllowedBinningStretch */
) -> BinningSpecs {
  
  double const finalWidth = chooseBinningWidth(
    lower, upper, width, BinningSpecs::NBinsFor(lower, upper, width),
    std::move(hints), allowedStretch
    );
  return makeBinningAlignedTo0(lower, upper, finalWidth);
  
} // icarus::ns::util::makeBinningFromBinWidth()


// -----------------------------------------------------------------------------
auto icarus::ns::util::makeBinningFromNBins(
  double lower, double upper, unsigned long nBins,
  std::initializer_list<double> hints /* = DefaultBinningHints */,
  double allowedStretch /* = DefaultAllowedBinningStretch */
) -> BinningSpecs {

  double const finalWidth = chooseBinningWidth(
    lower, upper, (upper - lower) / nBins, nBins,
    std::move(hints), allowedStretch
    );
  return makeBinningAlignedTo0(lower, upper, finalWidth);
  
} // icarus::ns::util::makeBinningFromNBins()


// -----------------------------------------------------------------------------
auto icarus::ns::util::alignBinningTo(
  BinningSpecs const& binning, double boundary, bool extendCoverage /* = true */
) -> BinningSpecs {
  
  int const iBin = binning.binWith(boundary);
  std::pair<double, double> const binBorders = binning.binBorders(iBin);
  
  double const shift { boundary - (
      ((boundary - binBorders.first) <= (binBorders.second - boundary))
      ? binBorders.first
      : boundary - binBorders.second
      )
    };
  
  double const width = binning.binWidth();
  double lower = binning.lower() + shift;
  double upper = binning.upper() + shift;
  if (extendCoverage && (shift != 0.0)) { // rounding may be trouble here...
    if (shift > 0.0) lower -= width;
    else             upper += width;
  }
  
  return BinningSpecs{ lower, upper, width };
  
} // icarus::ns::util::alignBinningTo()


// -----------------------------------------------------------------------------
double icarus::ns::util::chooseBinningWidth(
  double lower, double upper,
  double width, unsigned long nBins,
  std::initializer_list<double> hints /* = DefaultBinningHints */,
  double allowedStretch /* = DefaultAllowedBinningStretch */
) {
  
  assert(allowedStretch > 0.0);
  assert(width > 0.0);
  assert(lower <= upper);
  
  // order of magnitude of the bins: width will be chosen as this power-of-ten
  // multiplied by one of the hinted values
  double const order = std::pow(10.0, std::floor(std::log10(width)));
  
  double span = upper - lower;
  
  // don't consider binnings stretching the range more than allowed;
  // if no hinted binning is good enough, exact `width` will be used
  using Quality_t = std::pair<double, double>; // stretch/distance from request
  
  double best_w = width;
  Quality_t best_d { allowedStretch, 0.0 };
  for (double const factor: hints) {
    double const w = order * factor;
    Quality_t const d {
      std::abs((w * nBins / span) - 1.0),
      std::abs(w - width)
    };
    if (d >= best_d) continue;
    best_d = d;
    best_w = w;
  } // for
  
  return best_w;
  
} // icarus::ns::util::chooseBinningWidth()


// -----------------------------------------------------------------------------
