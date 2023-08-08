/**
 * @file   icarusalg/Utilities/TimeIntervalConfig.h
 * @brief  Helper for specifying a time interval parameter in FHiCL.
 * @author Gianluca Petrillo (petrillo@slac.stanford.edu)
 * @date   August 4, 2023
 * 
 * This library is header only.
 */

#ifndef ICARUSALG_UTILITIES_TIMEINTERVALCONFIG_H
#define ICARUSALG_UTILITIES_TIMEINTERVALCONFIG_H


// ICARUS libraries
#include "icarusalg/Utilities/TimeInterval.h"

// framework libraries
#include "fhiclcpp/types/OptionalTable.h"
#include "fhiclcpp/types/Table.h"
#include "fhiclcpp/types/OptionalAtom.h"
#include "fhiclcpp/types/Atom.h"

// C/C++ standard libraries
#include <optional>


//--------------------------------------------------------------------------
namespace icarus::ns::fhicl {
  
  template <typename Time> struct TimeIntervalConfig;
  
  template <typename Time>
  icarus::ns::util::TimeInterval<Time> makeTimeInterval
    (TimeIntervalConfig<Time> const& config);
  
  template <typename Time>
  std::optional<icarus::ns::util::TimeInterval<Time>> makeTimeInterval
    (std::optional<TimeIntervalConfig<Time>> const& config);
  
  /**
   * @brief FHiCL optional configuration object for specification of a (time)
   *        interval.
   * @tparam Time the type of the time point being read by the configuration
   * @see `icarus::ns::fhicl::TimeIntervalConfig`
   * 
   * This is a handy alias for a FHiCL configuration with an optional
   * `icarus::ns::fhicl::TimeIntervalConfig` entry.
   * Note that since FHiCL tables do not support default values, this is the
   * way to have one (see `icarus::ns::fhicl::TimeIntervalConfig` example).
   * 
   * Use it like in the FHiCL configuration object of an algorithm or module:
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{.cpp}
   * using electronics_time = detinfo::timescales::electronics_time;
   * 
   * struct Config {
   *   
   *   using Name = fhicl::Name;
   *   using Comment = fhicl::Comment;
   *   
   *   TimeIntervalTable<electronics_time> Interval{
   *     Name{ "Interval" },
   *     Comment{ "specify the selection time interval" }
   *     };
   *   
   *   // ...
   *   
   * };
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   */
  template <typename Time>
  using TimeIntervalTable = ::fhicl::Table<TimeIntervalConfig<Time>> ;
  
  /**
   * @brief FHiCL optional configuration object for specification of a (time)
   *        interval.
   * @tparam Time the type of the time point being read by the configuration
   * @see `icarus::ns::fhicl::TimeIntervalConfig`
   * 
   * This is a handy alias for a FHiCL configuration with an optional
   * `icarus::ns::fhicl::TimeIntervalConfig` entry.
   * Note that since FHiCL tables do not support default values, this is the
   * way to have one (see `icarus::ns::fhicl::TimeIntervalConfig` example).
   * 
   * Use it like in the FHiCL configuration object of an algorithm or module:
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{.cpp}
   * using nanosecond = util::quantities::points::nanosecond;
   * 
   * struct Config {
   *   
   *   using Name = fhicl::Name;
   *   using Comment = fhicl::Comment;
   *   
   *   TimeIntervalOptionalTable<nanosecond> Interval{
   *     Name{ "Interval" },
   *     Comment{ "override the selection time interval" }
   *     };
   *   
   *   // ...
   *   
   * };
   * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   */
  template <typename Time>
  using TimeIntervalOptionalTable
    = ::fhicl::OptionalTable<TimeIntervalConfig<Time>>;
    
} // namespace icarus::ns::fhicl


// -----------------------------------------------------------------------------
/**
 * @brief FHiCL configuration object for specification of a (time) interval.
 * @tparam Time the type of the time point being read by the configuration
 * 
 * 
 * 
 */
template <typename Time> 
struct icarus::ns::fhicl::TimeIntervalConfig {
  
  using Name = ::fhicl::Name;
  using Comment = ::fhicl::Comment;
  
  using TimeQuantity_t = Time; ///< Type of time being read.
  
  /// Type of time difference.
  using Duration_t
    = decltype(std::declval<TimeQuantity_t>() - std::declval<TimeQuantity_t>());
  
  
  ::fhicl::OptionalAtom<TimeQuantity_t> Start{
    Name{ "Start" },
    Comment{ "start time [default: since forever]" }
    };
  
  ::fhicl::OptionalAtom<TimeQuantity_t> End{
    Name{ "End" },
    Comment{ "end time [default: to forever]" }
    };
  
  ::fhicl::OptionalAtom<Duration_t> Duration{
    Name{ "Duration" },
    Comment{ "interval duration [default: forever]" }
    };
  
}; // icarus::ns::fhicl::TimeIntervalConfig


//--------------------------------------------------------------------------
// --- template implementation
//--------------------------------------------------------------------------
template <typename Time>
icarus::ns::util::TimeInterval<Time> icarus::ns::fhicl::makeTimeInterval
  (TimeIntervalConfig<Time> const& config)
{
  // start with default: -0 / +0 (empty):
  icarus::ns::util::TimeInterval<Time> interval;
  
  if (config.Start()) {
    interval.start = *(config.Start());
    if (config.End()) {
      interval.stop = *(config.End());
      if (config.Duration()) {
        throw cet::exception{ "makeTimeInterval" }
          << "Only up to two among '" << config.Start.name() << "', '"
          << config.End.name() << "' and '" << config.Duration.name()
          << "' parameters must be specified for a time interval.\n";
      }
    }
    else if (config.Duration()) {
      interval.stop = interval.start + *(config.Duration());
    }
  }
  else if (config.End()) {
    interval.stop = *(config.End());
    if (config.Duration())
      interval.start = interval.stop - *(config.Duration());
  }
  else if (config.Duration()) {
    interval.stop = interval.start + *(config.Duration());
  }
  
  return interval;
} // icarus::ns::fhicl::makeTimeInterval()


//--------------------------------------------------------------------------
template <typename Time>
std::optional<icarus::ns::util::TimeInterval<Time>>
icarus::ns::fhicl::makeTimeInterval
  (std::optional<TimeIntervalConfig<Time>> const& config)
  { return config? std::optional{ makeTimeInterval(*config) }: std::nullopt; }


//--------------------------------------------------------------------------


#endif // ICARUSALG_UTILITIES_TIMEINTERVALCONFIG_H
