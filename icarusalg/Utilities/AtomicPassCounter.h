/**
 * @file   icarusalg/Utilities/AtomicPassCounter.h
 * @brief  Class to keep count of a pass/fail result (thread-safe).
 * @author Gianluca Petrillo (petrillo@slac.stanford.edu)
 * @date   September 17, 2021
 * 
 * This library is header-only.
 */

#ifndef ICARUSALG_UTILITIES_ATOMICPASSCOUNTER_H
#define ICARUSALG_UTILITIES_ATOMICPASSCOUNTER_H

// ICARUS libraries
#include "icarusalg/Utilities/PassCounter.h"

// C/C++ standard libraries
#include <atomic>


// -----------------------------------------------------------------------------
namespace icarus::ns::util {
  template <typename Count> class AtomicPassCounter;
}
/**
 * @brief Class counting pass/fail events.
 * @tparam Count (default: `unsigned int`) type of counter
 * @see icarus::ns::util::PassCounter
 * 
 * This is an implementation of `icarus::ns::util::PassCounter` using atomic
 * counters, inherently thread-safe.
 * Only `Count` types that are lock-free (``) are supported.
 * 
 * This class exposes an interface equivalent to `PassCounter`: see its
 * documentation for usage details.
 * 
 */
template <typename Count = unsigned int>
class icarus::ns::util::AtomicPassCounter
  : public icarus::ns::util::PassCounter<std::atomic<Count>>
{
  static_assert(std::atomic<Count>::is_always_lock_free,
    "Only types whose atomic type is non-blocking are supported."
    );
  
  using Base_t = icarus::ns::util::PassCounter<std::atomic<Count>>;
  
    public:
  using Count_t = Count; ///< Type used for counters.
  
  // constructors are all default
  
  // --- BEGIN -- Access -------------------------------------------------------
  /// @name Access
  /// @{
  
  /// Returns the number of events which "passed".
  Count_t passed() const { return Base_t::passedRef().load(); }
  
  /// Returns the number of events which "failed".
  Count_t failed() const { return total() - passed(); }
  
  /// Returns the total number of registered events.
  Count_t total() const { return Base_t::totalRef().load(); }
  
  /// Returns whether there is no event recorded yet.
  bool empty() const { return total() == Count_t{}; }
  
  /// @}
  // --- END ---- Access -------------------------------------------------------
  
}; // icarus::ns::util::AtomicPassCounter<>


// -----------------------------------------------------------------------------

#endif // ICARUSALG_UTILITIES_ATOMICPASSCOUNTER_H
