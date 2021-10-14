/**
 * @file icarusalg/Utilities/FixedBins.h
 * @brief Class with extensible fix-sized binning.
 * @author Gianluca Petrillo (petrillo@slac.stanford.edu)
 * @date March 28, 2021
 */

#ifndef ICARUSALG_UTILITIES_FIXEDBINS_H
#define ICARUSALG_UTILITIES_FIXEDBINS_H


// C/C++ standard libraries
#include <algorithm> // std::copy(), std::fill()
#include <vector>
#include <iterator> // std::next()
#include <utility> // std::declval(), std::move()
#include <cmath> // std::floor()
#include <cstddef> // std::size_t, std::ptrdiff_t
#include <cassert>


// -----------------------------------------------------------------------------
namespace icarus::ns::util {
  
  template <typename T, typename C = unsigned int> class FixedBins;
  
  template <typename T, typename C>
  bool empty(FixedBins<T, C> const&) noexcept;
  template <typename T, typename C>
  std::size_t size(FixedBins<T, C> const&) noexcept;
  template <typename T, typename C>
  auto cbegin(FixedBins<T, C> const&) noexcept;
  template <typename T, typename C>
  auto begin(FixedBins<T, C> const&) noexcept;
  template <typename T, typename C>
  auto cend(FixedBins<T, C> const&) noexcept;
  template <typename T, typename C>
  auto end(FixedBins<T, C> const&) noexcept;
  
} // namespace icarus::ns::util

/**
 * @brief Binned counts of data.
 * @param T type of data on the binning axis
 * @param C (default: `unsigned int`) data type for the bin count
 * 
 * A `FixedBin` object holds binned counts with a binning of a fixed size and
 * alignment. For example, an object set to have `2`-wide bins aligned to `-1`
 * will hold counts with bins `-3` to `-1`, `-1` to `1`, `1` to 3` etc.
 * The lower edge of the bin is included in it, while the upper edge is not.
 * 
 * The lowest and highest limits of the binning are not fixed.
 * As data is`add()`-ed to the object, new bins are allocated if needed, and
 * the storage of counts is contiguous.
 * For example, in the example above if the first added datum is `+2`, the bin
 * `1` to `3` is allocated and given a count of `1`. At this point there is
 * only one bin with storage. If `6` is added next, the storage is extended to
 * cover also bins `3` to `5` and `5` to `7`, and they will be assigned counts
 * of `0` and `1` respectively. At this point, there is storage for three bins,
 * one of them being empty.
 * 
 * The query interface does report which is the first bin with storage
 * (supposedly the first non-empty bin) and which is the last one.
 * Bin content can be asked for any value and any bin.
 * 
 * Currently the modification interface is very limited: the only way to add
 * entries to the bins is one by one by value (`add()`), and the only other
 * supported modifying action is to empty all the content (`clear()`).
 * 
 * The bin index is of type `ptrdiff_t`.
 * 
 * 
 * @note It is possible to access the counters by a bin index. That index
 *       should be provided by `FixedBins` itself (`binWith()`, `minBin()`,
 *       etc.), since its specific value is an implementation detail that may
 *       change.
 * 
 */
template <typename T, typename C /* = unsigned int */>
class icarus::ns::util::FixedBins {
  
    public:
  
  using Data_t = T; ///< Type on the bin axis.
  
  using Count_t = C; ///< Type on the bin content.
  
  /// Type of interval in on the bin axis.
  using Interval_t = decltype(std::declval<T>() - std::declval<T>());
  
  using BinIndex_t = std::ptrdiff_t; ///< Type of bin index.
  
  
  /**
   * @brief Constructor: initializes the binning.
   * @param width the bin width
   * @param offset (default: 0) the border of one of the bins
   * 
   * This constructor prepares the object to host counts in bins of the
   * specified `width`.
   * Optionally, the bins are aligned to the `offset` value instead than to `0`
   * (or, more precisely, the value of a default-constructed `Data_t`).
   * 
   * No memory is allocated just yet.
   */
  explicit FixedBins(Interval_t width, Data_t offset = Data_t{}) noexcept;
  
  
  // --- BEGIN -- Content modification -----------------------------------------
  /// @name Content modification
  /// @{
  
  /**
   * @brief Increases by a unit the count at the bin including `value`.
   * @param value the value to be accounted for
   * @return the index of the bin including the `value`.
   */
  BinIndex_t add(Data_t value);
  
  /**
   * @brief Resets all counts to `0`.
   *
   * All the storage is removed from the object (although depending on the
   * STL implementation its memory might still be allocated).
   */
  void clear() noexcept;
  
  /// @}
  // --- END ---- Content modification -----------------------------------------
  
  
  // --- BEGIN -- Query --------------------------------------------------------
  /// @name Query interface
  /// @{
  
  /// Returns how many bins currently have storage.
  std::size_t nBins() const noexcept;
  
  /// Returns whether there is no storage at all.
  bool empty() const noexcept;
  
  /// Returns the width of the bins.
  Interval_t binWidth() const noexcept;
  
  /**
   * @brief Returns the alignment offset of the bins.
   * @return the alignment offset of the bins
   * 
   * One bin is guaranteed to have its `lowerEdge()` at the value returned by
   * `offset()`.
   */
  Data_t offset() const noexcept;
  
  /**
   * @return the value of the lower edge of the bin with the specified `index`
   * 
   * This value always belongs to the bin `index`.
   */
  Data_t lowerEdge(BinIndex_t index) const noexcept;
  
  /**
   * @return the value of the upper edge of the bin with the specified `index`
   * 
   * Note that this value always belongs to the bin `index + 1`.
   */
  Data_t upperEdge(BinIndex_t index) const noexcept;
  
  /**
   * @brief Returns the index of the bin including the specified `value`.
   * @param value the value that the queried bin must contain
   * @return the index of the bin including the specified value
   * @see `count()`, `countFor()`
   */
  BinIndex_t binWith(Data_t value) const noexcept;
  
  /**
   * @return the span covered by the bins currently with storage
   * 
   * Equivalent to `max() - min()` and `nBins() * binWidth()`.
   */
  Interval_t range() const noexcept;
  
  /**
   * @return the index of the lowest bin with storage
   * 
   * The return value is undefined if `empty()` is `true` (i.e. if no storage is
   * allocated yet).
   */
  BinIndex_t minBin() const noexcept;
  
  /**
   * @return the index of the highest bin with storage
   * 
   * This value can be the same as `minBin()` if only one bin is stored.
   * 
   * The return value is undefined if `empty()` is `true` (i.e. if no storage is
   * allocated yet).
   */
  BinIndex_t maxBin() const noexcept;
  
  /**
   * @return the lower limit of the lowest bin with storage
   * 
   * The return value is undefined if `empty()` is `true` (i.e. if no storage is
   * allocated yet).
   */
  Data_t min() const noexcept;
  
  /**
   * @return the upper limit of the highest bin with storage
   * 
   * The return value is undefined if `empty()` is `true` (i.e. if no storage is
   * allocated yet).
   */
  Data_t max() const noexcept;
  
  /**
   * @brief Returns the count of the bin with the specified `index`.
   * @param index the index of the bin to be queried
   * @return the count of the bin with the specified `index`
   * @see `operator[]()`, `countFor()`
   * 
   * If the specified bin has no storage, the returned count is `0`.
   */
  Count_t count(BinIndex_t index) const noexcept;
  
  /**
   * @brief Returns the count of the bin including the specified `value`.
   * @param value the value that the queried bin must contain
   * @return the count of the bin including the specified value
   * @see `operator[]()`, `count()`, `binWith()`
   * 
   * If the bin with the specified value has no storage, the returned count is
   * `0`.
   */
  Count_t countFor(Data_t value) const noexcept;
  
  /**
   * @brief Returns the count of the bin with the specified `index`.
   * @param index the index of the bin to be queried
   * @return the count of the bin with the specified `index`
   * @see `count()`
   * 
   * If the specified bin has no storage, the returned count is `0`.
   */
  Count_t operator[](BinIndex_t index) const noexcept;
  
  /// Returns the number of bins with storage.
  std::size_t size() const noexcept;
  
  /// Returns an iterator pointing to the content of the first bin with storage.
  auto cbegin() const noexcept;
  
  /// Returns an iterator pointing to the content of the first bin with storage.
  auto begin() const noexcept;
  
  /// Returns an iterator pointing to the content of the first bin with storage.
  auto cend() const noexcept;
  
  /// Returns an iterator pointing to the content of the first bin with storage.
  auto end() const noexcept;
  
  /// @}
  // --- END ---- Query --------------------------------------------------------
  
  
    private:
  
  using Storage_t = std::vector<Count_t>; ///< Type of storage for bin counts.
  
  /// Starting value of a counter, and ending value of a trilogy.
  static constexpr Count_t CountZero = 0;
  
  
  Data_t fWidth;  ///< Bin width.
  Data_t fOffset; ///< Bin offset from `0`.
  
  Storage_t fCounters; ///< Bin counters.
  Data_t fMin; ///< The lower edge of the bin with storage index 0.
  BinIndex_t fMinBin; ///< The index of bin `fCounters[0]`.
  
  
  /// Returns the index in the data storage corresponding to bin `index`.
  std::ptrdiff_t storageIndex(BinIndex_t index) const noexcept;

  /// Returns whether the specified stotage index is available.
  bool hasStorageIndex(std::ptrdiff_t stIndex) const noexcept;

  /// Returns the number of bins passing from `ref` to `value`.
  BinIndex_t relativeBinIndex(Data_t value, Data_t ref) const noexcept;

  /// Initializes the storage to host a single bin including `value`.
  /// @return the storage index of the new bin (that is: `0`)
  std::size_t initializeWith(Data_t value);
  
  /// Ensures the bin with the specified `index` exists and returns its storage
  /// index. Requires some storage to exist already.
  std::size_t allocateBin(BinIndex_t index);
  
}; // icarus::ns::util::FixedBins

// deduction guide:
namespace icarus::ns::util {
  template <typename T> FixedBins(T) -> FixedBins<T>;
}


/* -----------------------------------------------------------------------------
 * --- template implementation
 * -----------------------------------------------------------------------------
 * 
 * Implementation details
 * -----------------------
 * 
 * The value of `fMin` is always from the lowest non-empty bin ([20210925] there
 * is no way to make a bin empty after it has been filled; but future changes
 * may make this become the lowest bin which has been non-empty).
 * Data is stored in a STL vector, so the storage index always starts with `0`.
 * The "bin index" is defined relative to a reference bin, which is the first
 * bin being added. The purpose of this index is to give the user something that
 * does not move when values are added (storage indices are shifted whenever a
 * bin is added before the current minimum).
 * To track these indices, `fMinBin` is the bin index of the first bin in the
 * storage.
 * 
 */
template <typename T, typename C /* = unsigned int */>
icarus::ns::util::FixedBins<T, C>::FixedBins
  (Interval_t width, Data_t offset /* = Data_t{} */) noexcept
  : fWidth{ width }, fOffset{ offset }, fMinBin{}
{
  assert(fWidth != Interval_t{0}); // yep, we even accept negative
}


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::add(Data_t value) -> BinIndex_t {
  
  std::size_t const stIndex
    = empty()? initializeWith(value): allocateBin(binWith(value));
  ++fCounters[stIndex];
  return stIndex;
} // icarus::ns::util::FixedBins<>::add()


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
void icarus::ns::util::FixedBins<T, C>::clear() noexcept { fCounters.clear(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
std::size_t icarus::ns::util::FixedBins<T, C>::nBins() const noexcept
  { return fCounters.size(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
bool icarus::ns::util::FixedBins<T, C>::empty() const noexcept
  { return fCounters.empty(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::binWidth() const noexcept -> Interval_t
  { return fWidth; }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::offset() const noexcept -> Data_t
  { return fOffset; }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::lowerEdge
  (BinIndex_t index) const noexcept -> Data_t
  { return offset() + (minBin() + index) * binWidth(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::upperEdge
  (BinIndex_t index) const noexcept -> Data_t
  { return lowerEdge(index + 1); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::binWith(Data_t value) const noexcept
  -> BinIndex_t
  { return empty()? 0: minBin() + relativeBinIndex(value, min()); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::range() const noexcept -> Interval_t
  { return binWidth() * nBins(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::minBin() const noexcept -> BinIndex_t
  { return fMinBin; }

// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::maxBin() const noexcept -> BinIndex_t
  { return minBin() + nBins() - 1; }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::min() const noexcept -> Data_t
  { return fMin; }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::max() const noexcept -> Data_t
  { return min() + range(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::count(BinIndex_t index) const noexcept
  -> Count_t
{
  auto const stIndex = storageIndex(index);
  return hasStorageIndex(stIndex)? fCounters[stIndex]: CountZero;
} // icarus::ns::util::FixedBins<>::count()


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::countFor(Data_t value) const noexcept
  -> Count_t
  { return count(binWith(value)); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::operator[]
  (BinIndex_t index) const noexcept -> Count_t
  { return count(index); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
std::size_t icarus::ns::util::FixedBins<T, C>::size() const noexcept
  { return nBins(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::cbegin() const noexcept
  { return fCounters.begin(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::begin() const noexcept
  { return cbegin(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::cend() const noexcept
  { return fCounters.end(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::end() const noexcept
  { return cend(); }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
std::ptrdiff_t icarus::ns::util::FixedBins<T, C>::storageIndex
  (BinIndex_t index) const noexcept
  { return index - fMinBin; }


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
bool icarus::ns::util::FixedBins<T, C>::hasStorageIndex
  (std::ptrdiff_t stIndex) const noexcept
{
  return 
    (stIndex >= 0) && (static_cast<std::size_t>(stIndex) < fCounters.size()); 
} // icarus::ns::util::FixedBins<>::hasStorageIndex()


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
auto icarus::ns::util::FixedBins<T, C>::relativeBinIndex
  (Data_t value, Data_t ref) const noexcept -> BinIndex_t
{
  using std::floor;
  return static_cast<BinIndex_t>(floor((value - ref) / binWidth()));
} // icarus::ns::util::FixedBins<>::relativeBinIndex()


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
std::size_t icarus::ns::util::FixedBins<T, C>::initializeWith(Data_t value) {
  assert(empty());
  
  fMinBin = 0;
  fMin = offset() + binWidth() * relativeBinIndex(value, offset());
  fCounters.push_back(CountZero);
  return static_cast<std::size_t>(0);
  
} // icarus::ns::util::FixedBins<>::initializeWith()


// -----------------------------------------------------------------------------
template <typename T, typename C /* = unsigned int */>
std::size_t icarus::ns::util::FixedBins<T, C>::allocateBin(BinIndex_t index) {
  assert(!empty());
  
  BinIndex_t stIndex = storageIndex(index);
  if (stIndex < 0) {
    // (changes the first index)
    
    // extend the data storage on the left, filling with zeroes
    std::size_t const nExtend = static_cast<std::size_t>(-stIndex);
    Storage_t data(nExtend + fCounters.size()); // uninitialized
    auto const itOldFirst = std::next(data.begin(), nExtend);
    std::fill(data.begin(), itOldFirst, CountZero);
    std::copy(fCounters.cbegin(), fCounters.cend(), itOldFirst);
    fCounters = std::move(data);
    
    fMinBin = index;
    fMin -= nExtend * binWidth(); // numerically not the best choice...
    stIndex = 0;
  }
  else if (static_cast<std::size_t>(stIndex) >= fCounters.size()) {
    // (does not change the first index -- nor `stIndex`)
    fCounters.resize(static_cast<std::size_t>(stIndex) + 1, CountZero);
  }
  assert(hasStorageIndex(stIndex));
  return static_cast<std::size_t>(stIndex);

} // icarus::ns::util::FixedBins<>::allocateBin()


// -----------------------------------------------------------------------------
// ---  free function implementation
// -----------------------------------------------------------------------------
template <typename T, typename C>
bool icarus::ns::util::empty(FixedBins<T, C> const& bins) noexcept
  { return bins.empty(); }


// -----------------------------------------------------------------------------
template <typename T, typename C>
std::size_t icarus::ns::util::size(FixedBins<T, C> const& bins) noexcept
  { return bins.size(); }


// -----------------------------------------------------------------------------
template <typename T, typename C>
auto icarus::ns::util::cbegin(FixedBins<T, C> const& bins) noexcept
  { return bins.cbegin(); }


// -----------------------------------------------------------------------------
template <typename T, typename C>
auto icarus::ns::util::begin(FixedBins<T, C> const& bins) noexcept
  { return bins.begin(); }


// -----------------------------------------------------------------------------
template <typename T, typename C>
auto icarus::ns::util::cend(FixedBins<T, C> const& bins) noexcept
  { return bins.cend(); }


// -----------------------------------------------------------------------------
template <typename T, typename C>
auto icarus::ns::util::end(FixedBins<T, C> const& bins) noexcept
  { return bins.end(); }


// -----------------------------------------------------------------------------

#endif // ICARUSALG_UTILITIES_FIXEDBINS_H
