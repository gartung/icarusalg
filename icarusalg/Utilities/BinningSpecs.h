/**
 * @file   icarusalg/Utilities/BinningSpecs.h
 * @brief  Simple utility for human-friendly binning.
 * @author Gianluca Petrillo (petrillo@slac.stanford.edu)
 * @date   September 21, 2021
 * 
 * 
 */

#ifndef ICARUSALG_UTILITIES_BINNINGSPECS_H
#define ICARUSALG_UTILITIES_BINNINGSPECS_H


// C/C++ standard libraries
#include <initializer_list>
#include <utility> // std::pair


// -----------------------------------------------------------------------------
namespace icarus::ns::util {
  
  class BinningSpecs;
  
  // --- BEGIN -- Algorithms for binning ---------------------------------------
  /**
   * @name Algorithms for binning.
   * 
   * The `BinningSpecs` class collects the usual characteristics of a binning:
   * full range boundaries, number of bins, bin width.
   * 
   * A few functions are provided that create a binning with "human-friendly"
   * characteristics for pleasant plots: given a selection of bin width hints,
   * the functions try to create a binning accommodating those hints.
   * 
   * These functions always require the full range of the binning to be
   * specified, and can take either a desired number of bins, or their width.
   * 
   */
  /// @{
  
  /// Set of bin sizes to be considered by the binning algorithms.
  inline constexpr std::initializer_list<double> DefaultBinningHints
    { 1.0, 0.8, 2.0, 0.5, 4.0, 5.0, 10.0, 20.0 };

  
  /// Stretch factor on the requested binning range an algorithm is allowed.
  inline constexpr double DefaultAllowedBinningStretch { 0.5 };
  
  /**
   * @brief Returns the "optimal" binning for the requested parameters.
   * @param lower desired lower limit of the binning
   * @param upper desired upper limit of the binning
   * @param width desired bin width
   * @param hints set of bin sizes to consider
   *              (not including the order of magnitude)
   * @param allowedStretch how much the resulting range can differ from the
   *        desired one (`upper - lower`), as a factor
   * @return the optimal binning
   * 
   * Bin width is used as returned by `chooseBinningWidth()` function, which
   * chooses it so that it is multiple (within its order of magnitude)
   * of any of the hinted factors and the total range is not "too far"
   * (the stretching factor is no larger than `allowedStretch`).
   * 
   * Lower and upper limit are then aligned with that bin width (so that `0`
   * would appear as a bin limit).
   * Lower and upper limits are guaranteed to be included in the binning.
   * 
   * @note The final bin width will likely differ from the requested one.
   */
  BinningSpecs makeBinningFromBinWidth(
    double lower, double upper, double width,
    std::initializer_list<double> hints = DefaultBinningHints,
    double allowedStretch = DefaultAllowedBinningStretch
    );
  
  /**
   * @brief Returns the "optimal" binning for the requested parameters.
   * @param lower desired lower limit of the binning
   * @param upper desired upper limit of the binning
   * @param nBins desired number of bins
   * @param hints set of bin sizes to consider
   *              (not including the order of magnitude)
   * @param allowedStretch how much the resulting range can differ from the
   *        desired one (`upper - lower`), as a factor
   * @return the optimal binning
   * 
   * Bin width is used as returned by `chooseBinningWidth()` function, which
   * chooses it so that it is multiple (within its order of magnitude)
   * of any of the hinted factors and the total range is not "too far"
   * (the stretching factor is no larger than `allowedStretch`).
   * 
   * Lower and upper limit are then aligned with that bin width (so that `0`
   * would appear as a bin limit).
   * Lower and upper limits are guaranteed to be included in the binning.
   * 
   * @note The final number of bins may differ from the requested one.
   */
  BinningSpecs makeBinningFromNBins(
    double lower, double upper, unsigned long nBins,
    std::initializer_list<double> hints = DefaultBinningHints,
    double allowedStretch = DefaultAllowedBinningStretch
    );
  
  
  /**
   * @brief Returns a binning shifted to align with the specified `boundary`.
   * @param binning the binning to be aligned
   * @param boundary the point to align the binning with
   * @param extendCoverage (default: `true`) increase number of bins if needed
   * @return a new, aligned binning
   * 
   * The binning lower and upper boundaries are moved so that one of the bins
   * has `boundary` as a border.
   * The shift is the minimal to achieve the goal.
   * If `extendCoverage` is `true`, if the boundaries are shifted a single bin
   * is also added to the binning to preserve (and extend) the original coverage
   * region; otherwise, the size of the binning stays the same but part of the
   * original range may not be covered by the returned binning.
   */
  BinningSpecs alignBinningTo
    (BinningSpecs const& binning, double boundary, bool extendCoverage = true);
  
  
  /**
   * @brief Returns the "optimal" bin width for the requested parameters.
   * @param lower desired lower limit of the binning
   * @param upper desired upper limit of the binning
   * @param width desired bin width
   * @param nBins desired number of bins
   * @param hints set of bin sizes to consider
   *              (not including the order of magnitude)
   * @param allowedStretch how much the resulting range can differ from the
   *        desired one (`upper - lower`), as a factor
   * @return the recommended bin width
   * 
   * This is the core algorithm for determining a binning.
   * Bin width is chosen so that it is multiple (within its order of magnitude)
   * of any of the hinted factors and the total range is not "too far"
   * (the stretching factor is no larger than `allowedStretch`).
   * 
   * The hint is chosen that yields the lower stretch. On tie, priority is given
   * to the earlier hint in the list.
   * If no hint is good enough, `width` is returned unchanged.
   */ 
  double chooseBinningWidth(
    double lower, double upper, double width, unsigned long nBins,
    std::initializer_list<double> hints = DefaultBinningHints,
    double allowedStretch = DefaultAllowedBinningStretch
    );
  
  // --- END ---- Algorithms ---------------------------------------------------
  
  
} // namespace icarus::ns::util


// -----------------------------------------------------------------------------
/**
 * @brief Data structure holding binning information.
 * 
 * The binning is at fixed bin size.
 * 
 * Nothing fancy so far.
 * 
 * Functions like `icarus::ns::util::makeBinningFromBinWidth()` and
 * `icarus::ns::util::makeBinningFromNBins()` are the recommended way to create
 * a `BinningSpecs` object.
 */
class icarus::ns::util::BinningSpecs {
  
  double fLower       { 0.0 }; ///< Lower range limit.
  double fWidth       { 0.0 }; ///< Width of all bins.
  unsigned long fNBins{ 0UL }; ///< Number of bins.
  double fUpper       { 0.0 }; ///< Upper range limit.
  
    public:
  
  /// Constructor: all fields specified, no adjustment performed.
  BinningSpecs(double lower, double upper, double width);
  
  // --- BEGIN -- Access to binning specifications -----------------------------
  /// @name Access to binning specifications
  /// @{
  
  /// Returns the value of the lower end of the first bin.
  double lower() const { return fLower; }
  
  /// Returns the value of the upper end of the last bin.
  double upper() const { return fUpper; }
  
  /// Returns the full range covered by the binning.
  double range() const { return upper() - lower(); }
  
  /// Returns the number of bins.
  unsigned long nBins() const { return fNBins; }
  
  /// Returns the width of the bins (all bins have the same width).
  double binWidth() const { return fWidth; }
  
  /// @}
  // --- END ---- Access to binning specifications -----------------------------
  
  
  // --- BEGIN -- Access to binning specifications -----------------------------
  /// @name Access to bins
  /// @{
  
  // very incomplete interface; add freely!
  
  /// Returns the index of the bin with the specified value
  /// (bin of `lower()` is `0`, bin of `upper()` is `nBins()`).
  int binWith(double value) const;
  
  /// Returns the lower and upper borders of the bin with the specified index.
  std::pair<double, double> binBorders(int iBin) const;
  
  /// @}
  // --- END ---- Access to binning specifications -----------------------------
  
  
  /// Returns a number of bins large enough to cover the specified range.
  static unsigned long NBinsFor(double lower, double upper, double width);
  
}; // class icarus::ns::util::BinningSpecs


// -----------------------------------------------------------------------------

#endif // ICARUSALG_UTILITIES_BINNINGSPECS_H
