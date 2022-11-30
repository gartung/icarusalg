////////////////////////////////////////////////////////////////////////
/// \file  GeoObjectSorterICARUS.cxx
/// \brief Interface to algorithm class for sorting standard geo::XXXGeo objects
///
/// \version $Id:  $
/// \author  brebel@fnal.gov
////////////////////////////////////////////////////////////////////////

#include "icarusalg/Geometry/GeoObjectSorterICARUS.h"
#include "icarusalg/Geometry/details/AuxDetSorting.h"

#include "larcorealg/Geometry/AuxDetGeo.h"
#include "larcorealg/Geometry/AuxDetSensitiveGeo.h"
#include "larcorealg/Geometry/CryostatGeo.h"
#include "larcorealg/Geometry/TPCGeo.h"
#include "larcorealg/Geometry/PlaneGeo.h"
#include "larcorealg/Geometry/WireGeo.h"

namespace geo{

  //----------------------------------------------------------------------------
  // Define sort order for cryostats in standard configuration
  static bool sortCryoStandard(const CryostatGeo& c1, const CryostatGeo& c2)
  {
    auto const xyz1 = c1.GetCenter();
    auto const xyz2 = c2.GetCenter();

    return xyz1.X() < xyz2.X();
  }


  //----------------------------------------------------------------------------
  // Define sort order for tpcs in standard configuration.
  static bool sortTPCStandard(const TPCGeo& t1, const TPCGeo& t2)
  {
    auto const xyz1 = t1.GetCenter();
    auto const xyz2 = t2.GetCenter();

    // sort TPCs according to x
    return xyz1.X() < xyz2.X();
  }

  const double EPSILON = 0.000001;

  //----------------------------------------------------------------------------
  // Define sort order for planes in standard configuration
  static bool sortPlaneStandard(const PlaneGeo& p1, const PlaneGeo& p2)
  {
    auto const xyz1 = p1.GetBoxCenter();
    auto const xyz2 = p2.GetBoxCenter();

    //if the planes are in the same drift coordinate, lower Z is first plane
    if( std::abs(xyz1.X() - xyz2.X()) < EPSILON)
      return xyz1.Z() < xyz2.Z();

    //else
    // drift direction is negative, plane number increases in drift direction
    return xyz1.X() > xyz2.X();
  }


  //----------------------------------------------------------------------------
  static bool sortWireStandard(WireGeo const& w1, WireGeo const& w2){
    auto const [xyz1, xyz2] = std::pair{w1.GetCenter(), w2.GetCenter()};

    //we have horizontal wires...
    if( std::abs(xyz1.Z()-xyz2.Z()) < EPSILON)
      return xyz1.Y() < xyz2.Y();

    //in the other cases...
    return xyz1.Z() < xyz2.Z();
  }

  //----------------------------------------------------------------------------
  GeoObjectSorterICARUS::GeoObjectSorterICARUS(fhicl::ParameterSet const& p)
  {
  }

  //----------------------------------------------------------------------------
  void GeoObjectSorterICARUS::SortAuxDets(std::vector<geo::AuxDetGeo> & adgeo) const
  {
    icarus::SortAuxDetsStandard(adgeo);
  }

  //----------------------------------------------------------------------------
  void GeoObjectSorterICARUS::SortAuxDetSensitive(std::vector<geo::AuxDetSensitiveGeo> & adsgeo) const
  {
    icarus::SortAuxDetSensitiveStandard(adsgeo);
  }

  //----------------------------------------------------------------------------
  void GeoObjectSorterICARUS::SortCryostats(std::vector<geo::CryostatGeo> & cgeo) const
  {
    std::sort(cgeo.begin(), cgeo.end(), sortCryoStandard);
  }

  //----------------------------------------------------------------------------
  void GeoObjectSorterICARUS::SortTPCs(std::vector<geo::TPCGeo>  & tgeo) const
  {
    std::sort(tgeo.begin(), tgeo.end(), sortTPCStandard);
  }

  //----------------------------------------------------------------------------
  void GeoObjectSorterICARUS::SortPlanes(std::vector<geo::PlaneGeo> & pgeo,
                                           geo::DriftDirection_t  const driftDir) const
  {
    // sort the planes to increase in drift direction
    // The drift direction has to be set before this method is called.  It is set when
    // the CryostatGeo objects are sorted by the CryostatGeo::SortSubVolumes method
    if     (driftDir == geo::kPosX) std::sort(pgeo.rbegin(), pgeo.rend(), sortPlaneStandard);
    else if(driftDir == geo::kNegX) std::sort(pgeo.begin(),  pgeo.end(),  sortPlaneStandard);
    else if(driftDir == geo::kUnknownDrift)
      throw cet::exception("TPCGeo") << "Drift direction is unknown, can't sort the planes\n";
  }

  //----------------------------------------------------------------------------
  void GeoObjectSorterICARUS::SortWires(std::vector<geo::WireGeo> & wgeo) const
  {
    std::sort(wgeo.begin(), wgeo.end(), sortWireStandard);
  }

}
