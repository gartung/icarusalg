/**
 * @file   icarusalg/Utilities/PassCounter.h
 * @brief  Class to keep count of a pass/fail result.
 * @author Gianluca Petrillo (petrillo@slac.stanford.edu)
 * @date   February 10, 2021
 * 
 * This library is header-only.
 */

#ifndef ICARUSALG_UTILITIES_PASSCOUNTER_H
#define ICARUSALG_UTILITIES_PASSCOUNTER_H

// -----------------------------------------------------------------------------
namespace icarus::ns::util { template <typename Count> class PassCounter; }
/**
 * @brief Class counting pass/fail events.
 * @tparam Count (default: `unsigned int`) type of counter
 * 
 * The class keeps track of events which may fall in one of two categories,
 * called "passed" and "failed".
 * Example of usage:
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{.cpp}
 * icarus::ns::util::PassCounter<> OddCounter;
 * 
 * for (int i = 0; i < 15; ++i) OddCounter.add(i % 2 == 1);
 * 
 * std::cout << "Counted " << OddCounter.passed() << " odd entries and "
 *  << OddCounter.failed() << " even entries, "
 *  << OddCounter.total() << " in total." << std::endl;
 * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 * will print: `Counted 7 odd entries and 8 even entries, 15 in total.`.
 * 
 * The type `Count` must support:
 *  * increment `operator++()`
 *  * default construction which initializes to a "zero" value
 *  * usual copy and assignment
 *  * difference `operator-(Count)`
 * 
 */
template <typename Count = unsigned int>
class icarus::ns::util::PassCounter {
  
    public:
  using Count_t = Count; ///< Type used for counters.
  
  // constructors are all default
  
  // --- BEGIN -- Access -------------------------------------------------------
  /// @name Access
  /// @{
  
  /// Returns the number of events which "passed".
  Count_t passed() const { return fPassed; }
  
  /// Returns the number of events which "failed".
  Count_t failed() const { return total() - passed(); }
  
  /// Returns the total number of registered events.
  Count_t total() const { return fTotal; }
  
  /// Returns whether there is no event recorded yet.
  bool empty() const { return total() == Count_t{}; }
  
  /// @}
  // --- END ---- Access -------------------------------------------------------
  
  // --- BEGIN -- Registration and reset ---------------------------------------
  /// @name Registration and reset
  /// @{
  
  /// Adds a single event, specifying whether it "passes" or not.
  void add(bool pass);
  
  /// Adds a single event which did not "pass".
  void addFailed() { add(false); }
  
  /// Adds a single event which did "pass".
  void addPassed() { add(true); }
  
  /// Resets all counts.
  void reset();
  
  /// @}
  // --- END ---- Registration and reset ---------------------------------------
  
    private:
  
  // --- BEGIN -- Data members -------------------------------------------------
  
  Count_t fTotal{};  ///< Total entries.
  Count_t fPassed{}; ///< Entries which "passed".
  
  // --- END ---- Data members -------------------------------------------------
  
}; // icarus::ns::util::PassCounter<>



// -----------------------------------------------------------------------------
// ---  template implementation
// -----------------------------------------------------------------------------
template <typename Count>
void icarus::ns::util::PassCounter<Count>::add(bool pass) {
  
  ++fTotal;
  if (pass) ++fPassed;
  
} // icarus::ns::util::PassCounter<>::add()


// -----------------------------------------------------------------------------
template <typename Count>
void icarus::ns::util::PassCounter<Count>::reset() {
  
  fTotal = Count_t{};
  fPassed = Count_t{};
  
} // icarus::ns::util::PassCounter<>::reset()


// -----------------------------------------------------------------------------

#endif // ICARUSALG_UTILITIES_PASSCOUNTER_H
