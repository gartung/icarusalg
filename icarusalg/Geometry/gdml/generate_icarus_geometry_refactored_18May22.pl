#!/usr/bin/perl


# Each subroutine generates a fragment GDML file, and the last subroutine
# creates an XML file that make_gdml.pl will use to appropriately arrange
# the fragment GDML files to create the final desired ICARUS GDML file, 
# to be named by make_gdml output command
# If you are playing with different geometries, you can use the
# suffix command to help organize your work.

#ICARUS geometry
#Base structure of the detector and building (September 2017) - M.Torti
#CRT - C. Hilgenberg
#Race Tracks - D. Gibin
#Steel Mechanical structure,  "split wire" plane - A.Menegolli 
#Update of building (September 2020) -  M.Torti
#Flipping of U and V plane by 180 degrees about z axis (March 2021) - A. Menegolli

use Math::Trig;
use Getopt::Long;
use Math::BigFloat;
Math::BigFloat->precision(-16);

GetOptions( "help|h" => \$help,
	    "suffix|s:s" => \$suffix,
	    "output|o:s" => \$output,
	    "wires|w:s" => \$wires);

if ( defined $help )
{
    # If the user requested help, print the usage notes and exit.
    usage();
    exit;
}

if ( ! defined $suffix )
{
    # The user didn't supply a suffix, so append nothing to the file
    # names.
    $suffix = "";
}
else
{
    # Otherwise, stick a "-" before the suffix, so that a suffix of
    # "test" applied to filename.gdml becomes "filename-test.gdml".
    $suffix = "-" . $suffix;
}

#++++++++++++++++++++++++ Begin defining variables +++++++++++++++++++++++++

# set wires on to be the default, unless given an input by the user:  1=on, 0=off
if (defined $wires)
{
    $wires_on = $wires;

}

else { $wires_on = 1;}   # 1=on, 0=off


#-------Definitions of all variables: unit= cm

$inch = 2.54;

##################################################################
##################### wire plane parameters ######################

$YWirePitch             =   0.3;
$UWirePitch             =   0.3;
$VWirePitch             =   0.3;

#respect to the z axes
#$YAngle                 =   0;
$UAngle                 =   60;
$VAngle			=   60;

$SinUAngle              =   sin( deg2rad($UAngle) );
$CosUAngle              =   cos( deg2rad($UAngle) );
$TanUAngle              =   tan( deg2rad($UAngle) );

$SinVAngle              =   sin( deg2rad($VAngle) );
$CosVAngle              =   cos( deg2rad($VAngle) );
$TanVAngle              =   tan( deg2rad($VAngle) );

#$UWireCornerInt_y       =   $UWirePitch * $CosUAngle;
#$UWireCornerInt_z       =   $UWirePitch * $SinUAngle;
$UWire_ypitch           =   $UWirePitch / $CosUAngle;
$UWire_zpitch           =   $UWirePitch / $SinUAngle;

#$VWireCornerInt_y       =   $VWirePitch * $CosVAngle;
#$VWireCornerInt_z       =   $VWirePitch * $SinVAngle;
$VWire_ypitch           =   $VWirePitch / $CosVAngle;
$VWire_zpitch           =   $VWirePitch / $SinVAngle;


$TPCWireThickness       =   0.015; #wire diameter
$TPCWireRadius = $TPCWireThickness /2;  #wire radius

$CommonWireLength       =   (1056 * $YWirePitch) / $SinUAngle; #365.809;
#print("CommonWireLength: $CommonWireLength \n");

###########################################################################
########################### spacing parameters ############################


$CPA_x                 =     0.15;  #cathode plane 1.5 mm
$WirePlaneSpacing      =     0.3;   # center to center
$MaxDrift              =     148.2; #drift length in LAr at cryogenic temperature
 
#Cryostat space with LAr outside of entire fiducial volume
$SpaceWirePlToWall     =     31.8; 
$SpaceWirePlToWirePl   =     85; # edge to edge, like all of these (it was in the original perl script)
#$SpaceTPCToFloor       =     37; # from the article
#$SpaceTPCToTopLAr      =     30.5;  
$SpaceTPCToFloor       =     36; # from the article
$SpaceTPCToTopLAr      =     29.5; 
#$UpstreamLArPadding    =     82.50; # from the article
#$DownstreamLArPadding  =     82.50; # from the article
$UpstreamLArPadding    =     90.0; # from the drawings
$DownstreamLArPadding  =     90.0; # from the drawings

##########################################################
######## Other Cathode relevant parameters ###############

$CPA_epsi   = 0.001; #to avoid overlaps
$CPA_y      = 320; #Cathode height.
$CPA_z      = 1800; #Cathode length.
$CPAStrip_x = $CPA_x-$CPA_epsi; #Cathode strip thickness.
$CPAStrip_y = 2.1; #Cathode strip height.
$CPAStrip_pitch = 5; #Cathode strip pitch.

##############################################################
############## Cryo and TPC relevant dimensions  #############

#Active LAr volume
$TPCActive_x    =     $MaxDrift;
$TPCActive_y    =     $CommonWireLength * $SinUAngle + 0.02; #316.0; 
#$TPCActive_z    =     1795.5;

#print("TPCActive_x: $TPCActive_x, TPCActive_y: $TPCActive_y, TPCActive_z: $TPCActive_z ");

    #Reset the active length and the common wire length
$TPCActive_z        =    $CommonWireLength * $CosUAngle + (4640 - 1) * $UWire_zpitch - 0.000000000002;
$TPCActiveHalf_z    =    $TPCActive_z/2; 

#print(" - change with wire pitch: $UWire_zpitch to $TPCActive_z \n");

# TPCWirePlane dimensions
$TPCWirePlane_x     =       2*$TPCWireThickness; 
$TPCWirePlane_y     =       $TPCActive_y; 
$TPCWirePlane_z     =       $TPCActive_z;
$TPCWirePlaneHalf_z =       $TPCActiveHalf_z;

#print("TPCWirePlane_x: $TPCWirePlane_x, TPCWirePlane_y: $TPCWirePlane_y, TPCWirePlane_z: $TPCWirePlane_z \n");

##################################################################
#Dimension of the TPC (active+passive volume)
$TPC_x    =     $MaxDrift+ 6*$TPCWireThickness + 3*$WirePlaneSpacing + $CPA_x;
#$TPC_x    =     150.0;

$DeltaLUCorner = $UWirePitch/($SinUAngle*$CosUAngle); #this is the Delta L for the corner wire length
$DeltaLVCorner = $VWirePitch/($SinVAngle*$CosVAngle);

#print(" ******** DELTA CORENR ***** \n");
#print(" $DeltaLUCorner  $DeltaLVCorner \n");

$LAr_x    =     $CPA_x 
              + 2*($TPC_x + $SpaceWirePlToWall);
$LAr_y    =     $TPCActive_y 
              + $SpaceTPCToFloor 
              + $SpaceTPCToTopLAr;
$LAr_z    =     $TPCActive_z
              + $UpstreamLArPadding 
              + $DownstreamLArPadding;
$LArHalf_z    = $TPCActiveHalf_z + $UpstreamLArPadding; 

#$TPC_y    =     388.0; #From official drawings
#$TPC_z    =     1969.9; #From official drawings
$TPC_y     =     $LAr_y;
$TPC_z     =     $LAr_z;
$TPCHalf_z =     $LArHalf_z;

$AlumThickness		=	19;    
$GaseousAr_y            =       6.5;
$CryoDist 		=	20;
$CryoInsDist_x          =       19;

$Cryostat_x = $LAr_x + 2*$AlumThickness ; 
$Cryostat_y = $TPC_y + $GaseousAr_y + 2*$AlumThickness ;
$Cryostat_z = $TPC_z + 2*$AlumThickness ;

$LAr_x_orig = 2*$LAr_x + 2*$AlumThickness + $CryoDist ;	    #for total positioning

$Cryostat_x_orig = $LAr_x_orig + 2*$AlumThickness ;               #for total positioning


$TPCinCryo_x[0]     =      - $TPC_x/2 - $CPA_x/2;
#$TPCinCryo_x[1]     =      - $LAr_x/2 + $SpaceWirePlToWall + 1.5*($TPC_x) + $CPA_x ;
#$TPCinCryo_x[2]     =        $LAr_x/2 - $SpaceWirePlToWall - 1.5*($TPC_x) - $CPA_x ;
$TPCinCryo_x[1]     =        $TPC_x/2 + $CPA_x/2;

$posCat_x      =      0;


#$TPCinCryo_y        =      - $Cryostat_y/2 + $TPC_y/2 + $SpaceTPCToFloor;  
#$TPCinCryo_z        =      - $Cryostat_z/2 + $TPC_z/2 + $UpstreamLArPadding;  
#$TPCinCryo_y        =      0.;    
$TPCinCryo_y        =      -$GaseousAr_y/2;
$TPCinCryo_z        =      0.; 
#$TPCinCryo_zneg     =      (-$TPCHalf_z/2 + $UpstreamLArPadding/2);
#$TPCinCryo_zpos     =      ( $TPCHalf_z/2 - $UpstreamLArPadding/2);

$TPCinCryo_zneg     =      (-$TPCHalf_z/2);
$TPCinCryo_zpos     =      ( $TPCHalf_z/2);

$posTPCActive0_x     = 0.570000000000007;
#$posTPCActive1_x     = -0.570000000000007;
$posTPCActive_y     = 0;
$posTPCActive_z     = $UpstreamLArPadding/2;

##################################################################
#am ##########  Steel Mechanical Structure Parameters ############
##################################################################

  $struct_width = 10.;     # width of the structure box segment;
  $ext_struct_x = $struct_width;   # external width of structure segment;
  $ext_struct_y = 341.8;   # external heigh of structure segment;
  $ext_struct_z = 199.532; # external length of structure segment;
  $int_struct_x = $ext_struct_x;  # internal width of structure segment;
  $int_struct_y = $ext_struct_y - 2*$struct_width;   # internal heigh of structure segment;
  $int_struct_z = $ext_struct_z - 2*$struct_width;   # internal length of structure segment;

##################################################################
############## PMTs relevant parameters  #########################

$NumberPMT = 90;
$PMTthickness = 0.5;
$PMTradius = 4*$inch;
$PMTradiusOuter = 4*$inch; #10.16 cm
$PMTradiusInner = $PMTradiusOuter - $PMTthickness;
$PMTGrid_offset = 2; # from GLR communication
$PMTx = 0.557*$PMTradiusOuter; # x semi-axis of PMT
#$PMTtube_x = 10.3; #length of the glass tube
$PMTtubeRmax = 4.225; #outer radius of PMT glass tube;
$PMTtubeRmin = 3.725; #inner radius of PMT glass tube;$PMTtube_x = 2*$PMTtubeRmax;
$PMTtube_x = 2*$PMTtubeRmax ;
#$PMTxCut = ($PMTx*$PMTx - $PMTtubeRmax*$PMTtubeRmax)^0.5;
$PMTPlane_x = 2*$PMTradius+$PMTGrid_offset+$PMTtube_x;
#$PMTPlane_y = $TPCActive_y ; 
$PMTPlane_y = $ext_struct_y + 6.;
#$PMTPlane_z = $TPCActive_z ; 
$PMTPlane_z = 9*$ext_struct_z + 2*$struct_width + 6.;
$PMTWiresOffset = 0.5 ; # space between PMTs and wire planes 

##################################################################
######################### CRT parameters  ########################

#defined in seperate python script "gen_crt_frags.py"
#N.B. warm vessel origin, size currently hardcoded - changes
# in these values here need to be copied over (will fix eventually..)

##################################################################
############## DetEnc and World relevant parameters  #############

#Thickness of volumes surrounding the cryostats.
$FoamPadding            =        60.0;
$FoamPaddingTop         =        45.4;
$WarmVesselThickness    =        27.4;
$WarmVesselThickness_x  =        21.8;
$SpaceTop               =        21.4; #Space between cryostat and top thermal insulation
$SpaceUpstream          =       64.55; #Space between cryostat and upstream thermal insulation
$SpaceDownstream        =       14.55; #Space between cryostat and downstream thermal insulation
$SpaceBottom            =        17.0; #Space between cryostat and bottom thermal insulation 
$PlywoodThickness       =         1.0; #Thickness of the plywood shell between thermal insulation and warm vessel
$ShieldThickness        =         1.0; #Thickness of the aluminum shell between cryostats and thermal insulation

############## Crosses and chimneys ##############################

$CrossExtR              =       20;
$CrossIntR              =       17.96;
$CrossHeight            =       40.4;
#$ChimneyExtR            =       $CrossExtR; 
#$ChimneyIntR            =       $CrossIntR;
#$ChimneyHeight          =       $SpaceTop - $ShieldThickness;

############## Miniracks ##############################

$Rack_x                 =       50.8;
$Rack_y                 =       $CrossHeight;
$Rack_z                 =       58.0;

#Cold shields surrounding the two cryostats
$Shield_x               =       2*$Cryostat_x+2*$ShieldThickness+$CryoDist;
$Shield_y	        =         $Cryostat_y+2*$ShieldThickness; 
$Shield_z               =         $Cryostat_z+2*$ShieldThickness;

#Thermal insulation surrounding the two cryostats
$ThermIns_x             =       2*$Cryostat_x+2*$FoamPadding + $CryoDist + 2*$CryoInsDist_x;
$ThermIns_y	        =	$Cryostat_y+$FoamPadding+$FoamPaddingTop+$SpaceTop+$SpaceBottom; 
$ThermIns_z             =       $Cryostat_z+2*$FoamPadding+$SpaceUpstream+$SpaceDownstream;


#Shift of volumes sourrinding the cryostats to consider the actua cryostats position
$ShiftRespectCryo_y = 18; #shift of volumes considering the actual cryostats position in y
$ShiftRespectCryo_z = 25; #shift of volumes considering the actual cryostats position in z

$ShieldInDetEncl_x      =       0;
$ShieldInDetEncl_z      =	0;

$ThermInsInDetEncl_x    =       0;
$ThermInsInDetEncl_z    =	$ShiftRespectCryo_z;

#Plywood shell between thermal insulation and warm vessel
$Plywood_x              =       $ThermIns_x + 2*$PlywoodThickness;
$Plywood_y	        =	$ThermIns_y + 2*$PlywoodThickness;
$Plywood_z              =       $ThermIns_z + 2*$PlywoodThickness;

$PlywoodInDetEncl_x     =       0;
$PlywoodInDetEncl_z     =	$ShiftRespectCryo_z;

#Warm Vessel surrounding the thermal insulation
$WarmVessel_x	        =	$Plywood_x+2*$WarmVesselThickness_x;
$WarmVessel_y	        =	$Plywood_y+2*$WarmVesselThickness; 
$WarmVessel_z           =       $Plywood_z+2*$WarmVesselThickness;

$WarmVesselInDetEncl_x  =	0;
$WarmVesselInDetEncl_z  =	$ShiftRespectCryo_z;

#Volume containg the crosses
$CrossPlane_x           =       $ThermIns_x;
$CrossPlane_y           =       $CrossHeight;
$CrossPlane_z           =       $ThermIns_z;

$CrossesInDetEncl_x  =	0;
$CrossesInDetEncl_z  =	0;

#$MoreDetEnc_y = 60.0; # More space in height to cope with few extrusions
#Big detector Enclosure to contain detector + CRT.
#$DetEnc_x = 1235.96;#$WarmVessel_x + $CRT_tot_x; 
#$DetEnc_y = 963.37 + $MoreDetEnc_y;#$WarmVessel_y + $CRT_tot_y; 
#$DetEnc_z = 2709.56;#$WarmVessel_z + $CRT_tot_z; 


#Cryostat respect to the warm vessel (check if this is correct or better use $CryoDist/2)
$Cryo1InWarmVessel_x     =     -$Cryostat_x/2 - $CryoDist/2;  #-$Cryostat_x/2 - $CryoDist/2 ;
$Cryo2InWarmVessel_x     =      $Cryostat_x/2 + $CryoDist/2;  #$Cryostat_x/2 + $CryoDist/2 ;
#$CryoInWarmVessel_y     =       -$WarmVessel_y/2 + $ConcretePadding + $Cryostat_y/2; #in original way
#$CryoInWarmVessel_y     =       -$WarmVessel_y/2 + $FoamPadding + $WarmVesselThickness + $Cryostat_y/2 -154.995; #(-$WarmVessel_y/2 + $TotalPadding + $Cryostat_y/2)- ($WarmVessel_y)/6 ;
$CryoInWarmVessel_z     =       0;


#Marta: I would like that the origin is in the middle of the two cryostats. It corresponds to the world center. It do not correspond to the experimental hall centre.
$OriginXSet = 0;
$OriginYSet = 0; 
$OriginZSet = 0;


#Experimental hall from SBN-docDB 276 
$Building_y = 1040.0 ; #part of the building outside
$ExpHall_y = 1191.4;   #part of the building underground, where the detector is. #Originally 1170.0 + 80;  #building underground was set by Chris

$Hall_x = 1890.0; #taking into account the wall thickness
$Hall_y = $Building_y + $ExpHall_y ;
$Hall_z = 3870.0;
 
$HallWallThickness = 60; #from docdb-10564-v6
$BuildingWallThickness = 7.62; #from SBN-docDB 276 
$Pit_Floor_y = 74.12; #91.4; #from docdb-10564-v6 and private mail from P.Wilson
$ReinforcedPitFloor_y= 27.44; #10.16; #part under the pit floor poured to reinforce the building, from P.Wilson mail.

$Hall_shift_z = 0.5*($Hall_z-$HallWallThickness) - 0.5*$WarmVessel_z - (335 + $HallWallThickness/2) + $ShiftRespectCryo_z - 5.0;  #from docdb-2011, shift in z of the hall and the building respect to the center of the detector 335 cm 

#Building Wall made by 3 layers, from SBN-docDB 276 and private mail from M. Del Tutto
$BuildingAlSkin = 0.0873; #2 layers
$BuildingInsSkin = 7.4454; #interior insulating layer


#Complete Roof parameters from SBN-docDB 276
$Roof_x = $Hall_x - 2*$BuildingWallThickness;
$Roof_y = 15.54;
$Roof_z = $Hall_z - 2*$BuildingWallThickness ;

#Roof made by 4 layers from SBN-docDB 276 and private mail from M. Del Tutto
$RoofMembrane_y = 0.952;
$RoofTopIns_y = 1.27;
$RoofBottomIns_y = 13.208;
$RoofMetalDeck_y = 0.09119;


#Overburden dimensions from SBN-docDB 10564-v6 
$Overburden_x	    =	1198.9; 
$Overburden_y	    =   284.5; #300 originally
$Overburden_z 	    =	2758.5;
$Gap_overburden_BuildingFloor   =  15.24; #air gap only in the south side, between the overburden the the BuildingFloor (from docdb-10564-v6)


#Overburden positions
$posOverburden_x 	= 	$OriginXSet ;
$posOverburden_y	=       100.0; #distance between ground level and overburden bottom; number given by Claudio M.  Originally:  $Ground_y + $Overburden_y/3  ;
$posOverburden_z 	=     259.1 ; #distance of the overburden from south wall from docdb 10564-v6


#BuildingFloor dimensions from docdb 10564-v6 and docdb-276. It is made of 4 sub-boxes in roder to have a concrete frame with dirt in the middle
#FloorBox1 - concrete
$FloorBox1_x = $Hall_x - 2*$HallWallThickness;
$FloorBox1_y = 121.92; 
$FloorBox1_z = $Hall_z - 2*$HallWallThickness;

#Open a hole in the FloorBox1 to host the overburden from docdb 10564-v6 and docdb-276
$FloorBox1air_x = $Overburden_x + 0.1;
$FloorBox1air_y = $FloorBox1_y; 
$FloorBox1air_z = $Overburden_z + $Gap_overburden_BuildingFloor;


#FloorBox2 - dirt
$FloorBox2_x = $FloorBox1_x;   
$FloorBox2_y = 213.36; 
$FloorBox2_z = $FloorBox1_z;

#Open a hole in the FloorBox2 to host the overburden from docdb 10564-v6 and docdb-276
$FloorBox2air_x = $Overburden_x + 0.1 + 2*45.72; #consider also the floorbox 3
$FloorBox2air_y = $FloorBox2_y; 
$FloorBox2air_z = $Overburden_z + $Gap_overburden_BuildingFloor + 2*45.72; #consider also the floorbox 3


#FloorBox3 - concrete
$FloorBox3_x = $Overburden_x + 0.1 + 2*45.72; #Gap Air + 45.72 cm for each side of concrete frame   
$FloorBox3_y = $FloorBox2_y; 
$FloorBox3_z = $Overburden_z + $Gap_overburden_BuildingFloor + 2*45.72; #Gap Air + 45.72 cm for each side of concrete frame

#Open a hole in the FloorBox3 to host the overburden from docdb 10564-v6 and docdb-276
$FloorBox3air_x = $Overburden_x + 0.1;
$FloorBox3air_y = $FloorBox3_y; 
$FloorBox3air_z = $Overburden_z + $Gap_overburden_BuildingFloor;


#FloorBox4 - concrete
$FloorBox4_x = $FloorBox1_x;
$FloorBox4_y = 20; 
$FloorBox4_z = $FloorBox1_z;

#Open a hole in the FloorBox4 to host the overburden from docdb 10564-v6 and docdb-276
$FloorBox4air_x = $Overburden_x + 0.1;
$FloorBox4air_y = $FloorBox4_y; 
$FloorBox4air_z = $Overburden_z + $Gap_overburden_BuildingFloor;

$posOpenBuildingFloor = -0.5*$FloorBox1_z + 0.5*$FloorBox1air_z + $posOverburden_z; #position of the open space from the overburden in the BuildingFloor


#DetectorEnclosure (centered between expHall walls, between expHall floor and bottom of overburden)
#Numbers set by Chris
$ExpHall_VertSpace = $ExpHall_y - $HallWallThickness - $Overburden_y/3;
$DetEnc_pad = 0.1;
$DetEnc_x = 1143.1; #tuned from x of CRT_shell #Orignal: 1245; 
$DetEnc_y = 971.1; #tuned from x of CRT_shell #Original: $ExpHall_VertSpace - 2*$DetEnc_pad;
$DetEnc_z = 2753.24; #tuned from z of the CRT shell #Original: 3200; 
$WarmVessel_FootHeight = 6.0; # heigth of support feet from bottom of support structure
$WarmVessel_FloorSpace = 10.16; # space between WV feet and concrete floor due to concrete islands, grout, padding
$WarmVessel_CenterToFloor = $WarmVessel_FootHeight + $WarmVessel_FloorSpace + $WarmVessel_y/2;
#$DetEncl_yOffset = $ExpHall_VertSpace/2 - $WarmVessel_CenterToFloor;
#$ThermInsInDetEncl_y = -1*$DetEncl_yOffset;
#$WarmVesselInDetEncl_y = $ThermInsInDetEncl_y;

#World
$World_x            =       1e4;	
$World_y            =       1e4;	
$World_z            =       1e4;	


$CRTSHELL_WV_OFFSET_Y = 15;
$CRTSHELL_WV_OFFSET_Z = 164.5865;
$Shift_CRT_y = 23; #introduce a shift in the CRT shell in order to cover entirely the detector side and to have the correct distance between bottom CRT and pit floor

$Shift_DetEnc_z = 189.583; #introduce a shift to keep the fix cryo positioning
$Shift_DetEnc_y = 26; #introduce a shift to keep the fix cryo positioning


#Ground Level
#$Ground_y = -$World_y/4+$ExpHall_y/2-$Overburden_y/6 + 0.5*($World_y/2 + $ExpHall_y - $Overburden_y/3);
#$Ground_y = $ExpHall_y - $Overburden_y/3 ;
$Ground_y = 780.0;  #from detector building drawing (SBN-docDB 276) : distance between beamline and ground level (main level)
$DetEncl_yOffset = $Ground_y - $Overburden_y/3 - $ExpHall_VertSpace/2 -$DetEnc_pad;
$ThermInsInDetEncl_y   = -1*$DetEncl_yOffset;
$ShieldInDetEncl_y     = $ThermInsInDetEncl_y + 5.1;
$PlywoodInDetEncl_y    = $ThermInsInDetEncl_y;
$WarmVesselInDetEncl_y = $ThermInsInDetEncl_y;
$CrossesInDetEncl_y    = 149.127; #Obtained by fine tuning, better find a physical parameter.
$CryoInWarmVessel_y    = $WarmVesselInDetEncl_y -$WarmVessel_y/2 + $FoamPadding + $WarmVesselThickness + $Cryostat_y/2;
$Cryo_shift_y = 7.3; #shift to leave the cryostats in the reference positions


#+++++++++++++++++++++++++ End defining variables ++++++++++++++++++++++++++

# run the sub routines that generate the fragments

gen_Define(); 	 # generates definitions at beginning of GDML
gen_Materials(); # generates materials to be used

gen_RaceTracks(); # generates the geometry of race-tracks

gen_TPC();	 # generates wires, wire planes, and puts them in volTPC
	         # This is the bulk of the code, and has zero wires option


gen_PMT();	 #generates PMTs

gen_Mech_Structure(); # generates the geometry of the TPC mechanical structure

gen_Cryostat();	 # places  volTPC,
		 # half rotated 180 about Y
gen_CRT();	 # places CRT: CERN modules top, eves; MINOS modules sides, DC bottom

gen_flanges(); #generates the geometry of CF200 crosses

gen_Enclosure(); # places two cryostats and warm vessel

gen_Floor();	 # places the building floor

gen_World();	 # places the enclosure in the experimental hall


write_fragments(); # writes the XML input for make_gdml.pl
			# which zips together the final GDML
exit;

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++ usage +++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub usage()
{
    print "Usage: $0 [-h|--help] [-o|--output <fragments-file>] [-s|--suffix <string>]";
    print "          [-w|--wires <wire or no wire geometry>] \n";
    print "       if -o is omitted, output goes to STDOUT; <fragments-file.xml> is input to make_gdml.pl\n";
    print "       -s <string> appends the string to the file names; useful for multiple detector versions\n";
    print "       -w <1> geometry with wires, <0> geometry with no wires\n";
    print "       -h prints this message, then quits\n";
    print "Remind: the file without wires has to be <filename_nowires.gdml> \n";
}



#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++ gen_Define +++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_Define()
{

# Create the <define> fragment file name, 
# add file to list of fragments,
# and open it
    $DEF = "icarus_Def" . $suffix . ".gdml";
    push (@gdmlFiles, $DEF);
    $DEF = ">" . $DEF;
    open(DEF) or die("Could not open file $DEF for writing");


print DEF <<EOF;
<?xml version='1.0'?>
<gdml>
<define>

   <position name="posPMTtube" unit="cm" x="0" y="0" z="@{[1.5*$PMTtube_x + 0.4]}"/>
   <position name="posPMTInnertube" unit="cm" x="0" y="0" z="@{[1.5*$PMTtube_x]}"/>
   <position name="posPMTEndcap" unit="cm" x="0" y="0" z="@{[2.*$PMTtube_x + 0.05]}"/>
   <position name="posActiveInTPC0"   unit="cm" x="$posTPCActive0_x" y="$posTPCActive_y" z="$posTPCActive_z"/>
   <position name="posTPC00inCryo"    unit="cm" x="$TPCinCryo_x[0]" y="$TPCinCryo_y"    z="$TPCinCryo_zneg" />
   <position name="posTPC01inCryo"    unit="cm" x="$TPCinCryo_x[0]" y="$TPCinCryo_y"    z="$TPCinCryo_zpos" />
   <position name="posTPC10inCryo"    unit="cm" x="$TPCinCryo_x[1]" y="$TPCinCryo_y"    z="$TPCinCryo_zneg" />
   <position name="posTPC11inCryo"    unit="cm" x="$TPCinCryo_x[1]" y="$TPCinCryo_y"    z="$TPCinCryo_zpos" />
   <position name="posCathode"  unit="cm" x="$posCat_x"  y="$TPCinCryo_y"    z="$TPCinCryo_z" />
   <position name="posCryo1InWarmVessel"  unit="cm" x="$Cryo1InWarmVessel_x" y="@{[$CryoInWarmVessel_y + $Shift_DetEnc_y]} " z="@{[$CryoInWarmVessel_z - $Shift_DetEnc_z]}" />
   <position name="posCryo2InWarmVessel"  unit="cm" x="$Cryo2InWarmVessel_x" y="@{[$CryoInWarmVessel_y + $Shift_DetEnc_y]}" z="@{[$CryoInWarmVessel_z - $Shift_DetEnc_z]}" />
   <position name="posDetEncInWorld" unit="cm" x="$OriginXSet"     y="@{[$DetEncl_yOffset - $Cryo_shift_y - $Shift_DetEnc_y]}"     z="@{[$OriginZSet + $Shift_DetEnc_z]}"/>
   <position name="posCenter"           unit="cm" x="0" y="0" z="0"/>
   <position name="posThermInsInterior" unit="cm" x="0" y="@{[($FoamPadding-$FoamPaddingTop)/2]}" z="0"/>
   
   <position name="posShieldInDetEncl" unit="cm" x="$ShieldInDetEncl_x" y="@{[$ShieldInDetEncl_y - $ShiftRespectCryo_y + $Shift_DetEnc_y]}" z="@{[$ShieldInDetEncl_z - $Shift_DetEnc_z]}"/>
   <position name="posThermInsInDetEncl" unit="cm" x="$ThermInsInDetEncl_x" y="@{[$ThermInsInDetEncl_y - $ShiftRespectCryo_y + $Shift_DetEnc_y]}" z="@{[$ThermInsInDetEncl_z - $Shift_DetEnc_z]}"/>
   <position name="posPlywoodInDetEncl" unit="cm" x="$PlywoodInDetEncl_x" y="@{[$PlywoodInDetEncl_y - $ShiftRespectCryo_y + $Shift_DetEnc_y]}" z="@{[$PlywoodInDetEncl_z - $Shift_DetEnc_z]}"/>
   <position name="posWarmVesselInDetEncl" unit="cm" x="$WarmVesselInDetEncl_x" y="@{[$WarmVesselInDetEncl_y- $ShiftRespectCryo_y + $Shift_DetEnc_y]}" z="@{[$WarmVesselInDetEncl_z - $Shift_DetEnc_z]}"/>
   <position name="posCrossPlaneInDetEncl" unit="cm" x="$CrossesInDetEncl_x" y="@{[$CrossesInDetEncl_y + $Shift_DetEnc_y]}" z="@{[$CrossesInDetEncl_z - $Shift_DetEnc_z]}"/>
   <position name="posCRTShellInDetEncl" unit="cm" x="0" y="@{[$CRTSHELL_WV_OFFSET_Y - $ShiftRespectCryo_y - $Shift_CRT_y + $Shift_DetEnc_y]}" z="@{[$CRTSHELL_WV_OFFSET_Z + $ShiftRespectCryo_z -$Shift_DetEnc_z]}"/>   
   
   <position name="posBuildingAlExtInWorld" unit="cm" x="0" y="@{[$Ground_y + $Building_y/2 - $ShiftRespectCryo_y]}" z="$Hall_shift_z"/>
   <position name="posBuildingInsInWorld" unit="cm" x="0" y="@{[$Ground_y + $Building_y/2 - $ShiftRespectCryo_y]}" z="$Hall_shift_z"/>
   <position name="posBuildingAlIntInWorld" unit="cm" x="0" y="@{[$Ground_y + $Building_y/2 - $ShiftRespectCryo_y ]}" z="$Hall_shift_z"/>      
   <position name="posExpHallInWorld" unit="cm" x="0" y="@{[$Ground_y - $ExpHall_y/2 - $ShiftRespectCryo_y]}" z="$Hall_shift_z"/>      
   <position name="posRoofMembraneinWorld" unit="cm" x="$OriginXSet" y="@{[$Ground_y + $Building_y - $ShiftRespectCryo_y + $RoofMetalDeck_y + $RoofBottomIns_y + $RoofTopIns_y + $RoofMembrane_y/2]}" z="$Hall_shift_z"/>      
   <position name="posRoofTopInsinWorld" unit="cm" x="$OriginXSet" y="@{[$Ground_y + $Building_y - $ShiftRespectCryo_y + $RoofMetalDeck_y + $RoofBottomIns_y + $RoofTopIns_y/2]}" z="$Hall_shift_z"/>                
   <position name="posRoofBottomInsinWorld" unit="cm" x="$OriginXSet" y="@{[$Ground_y + $Building_y - $ShiftRespectCryo_y + $RoofMetalDeck_y + $RoofBottomIns_y/2]}" z="$Hall_shift_z"/>                   
   <position name="posRoofMetalDeckinWorld" unit="cm" x="$OriginXSet" y="@{[$Ground_y + $Building_y - $ShiftRespectCryo_y + $RoofMetalDeck_y/2]}" z="$Hall_shift_z"/>                                   
   <rotation name="rPlus90AboutZPlus90AboutY"  unit="deg" x="0" y="90" z="90"/>
   <rotation name="rPlus90AboutX"       unit="deg" x="90" y="0" z="0"/>
   <rotation name="rMinus90AboutX"      unit="deg" x="-90" y="0" z="0"/>
   <rotation name="rPlus90AboutY"	unit="deg" x="0" y="90"   z="0"/>
   <rotation name="rPlus90AboutZ"	unit="deg" x="0" y="0"   z="90"/>
   <rotation name="rMinus90AboutZ"	unit="deg" x="0" y="0"   z="-90"/>
   <rotation name="rMinus90AboutY"      unit="deg" x="0" y="270" z="0"/>
   <rotation name="rMinus90AboutYMinus90AboutX"       unit="deg" x="270" y="270" z="0"/>
   <rotation name="rPlus90VAngleAboutX"	unit="deg" x="@{[90-$VAngle]}" y="0"   z="0"/>  
   <rotation name="rPlus90UAngleAboutX"	unit="deg" x="@{[90+$UAngle]}" y="0"   z="0"/>
   <rotation name="rPlus180AboutX"	unit="deg" x="180" y="0"   z="0"/>
   <rotation name="rPlus180AboutY"	unit="deg" x="0" y="180"   z="0"/>
   <rotation name="rPlus180AboutZ"	unit="deg" x="0" y="0"   z="180"/>
   <rotation name="rPlus180AboutXZ"	unit="deg" x="180" y="0"   z="180"/>
   <rotation name="rIdentity"		unit="deg" x="0" y="0"   z="0"/>
   <rotation name="rPlusUAngleAboutX" 	unit="deg" x="$UAngle" y="0" z="0"/>
   <rotation name="rMinusVAngleAboutX" 	unit="deg" x="300" y="0" z="0"/>
   
</define>
</gdml>
EOF
    close (DEF);
}

 
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++ gen_Materials +++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_Materials() 
{

# Create the <materials> fragment file name,
# add file to list of output GDML fragments,
# and open it
    $MAT = "icarus_Materials" . $suffix . ".gdml";
    push (@gdmlFiles, $MAT);
    $MAT = ">" . $MAT;
    open(MAT) or die("Could not open file $MAT for writing");


  print MAT <<EOF;
<materials>
  <element name="videRef" formula="VACUUM" Z="1">  <atom value="1"/> </element>
  <element name="bromine" formula="Br" Z="35"> <atom value="79.904"/> </element>
  <element name="hydrogen" formula="H" Z="1">  <atom value="1.0079"/> </element>
  <element name="nitrogen" formula="N" Z="7">  <atom value="14.0067"/> </element>
  <element name="oxygen" formula="O" Z="8">  <atom value="15.999"/> </element>
  <element name="aluminum" formula="Al" Z="13"> <atom value="26.9815"/>  </element>
  <element name="silicon" formula="Si" Z="14"> <atom value="28.0855"/>  </element>
  <element name="carbon" formula="C" Z="6">  <atom value="12.0107"/>  </element>
  <element name="potassium" formula="K" Z="19"> <atom value="39.0983"/>  </element>
  <element name="chromium" formula="Cr" Z="24"> <atom value="51.9961"/>  </element>
  <element name="iron" formula="Fe" Z="26"> <atom value="55.8450"/>  </element>
  <element name="nickel" formula="Ni" Z="28"> <atom value="58.6934"/>  </element>
  <element name="calcium" formula="Ca" Z="20"> <atom value="40.078"/>   </element>
  <element name="magnesium" formula="Mg" Z="12"> <atom value="24.305"/>   </element>
  <element name="sodium" formula="Na" Z="11"> <atom value="22.99"/>    </element>
  <element name="titanium" formula="Ti" Z="22"> <atom value="47.867"/>   </element>
  <element name="argon" formula="Ar" Z="18"> <atom value="39.9480"/>  </element>
  <element name="sulphur" formula="S" Z="16"> <atom value="32.065"/>  </element>
  <element name="phosphorus" formula="P" Z="15"> <atom value="30.973"/>  </element>
  <element name="copper" formula="Cu" Z="29"> <atom value="63.5463"/>  </element>
  <element name="manganese" formula="Mn" Z="25"> <atom value="54.938043"/>  </element>
  <element name="vanadium" formula="V" Z="23"> <atom value="50.94151"/>  </element>

  <material name="Vacuum" formula="Vacuum">
   <D value="1.e-25" unit="g/cm3"/>
   <fraction n="1.0" ref="videRef"/>
  </material>

  <material name="ALUMINUM_Al" formula="ALUMINUM_Al">
   <D value="2.6990" unit="g/cm3"/>
   <fraction n="1.0000" ref="aluminum"/>
  </material>

  <material name="ALUMINUM_CRYO" formula="ALUMINUM_CRYO">
   <D value="0.5991" unit="g/cm3"/>
   <fraction n="1.0000" ref="aluminum"/>
    </material>
    
  <material name="ALUMINUM_PMT" formula="ALUMINUM_PMT">
   <D value="2.74351" unit="g/cm3"/>
   <fraction n="1.0000" ref="aluminum"/>
  </material>
    
  <material name="SILICON_Si" formula="SILICON_Si">
   <D value="2.3300" unit="g/cm3"/>
   <fraction n="1.0000" ref="silicon"/>
  </material>

  <material name="epoxy_resin" formula="C38H40O6Br4">
   <D value="1.1250" unit="g/cm3"/>
   <composite n="38" ref="carbon"/>
   <composite n="40" ref="hydrogen"/>
   <composite n="6" ref="oxygen"/>
   <composite n="4" ref="bromine"/>
  </material>

  <material name="SiO2" formula="SiO2">
   <D value="2.2" unit="g/cm3"/>
   <composite n="1" ref="silicon"/>
   <composite n="2" ref="oxygen"/>
  </material>

  <material name="Al2O3" formula="Al2O3">
   <D value="3.97" unit="g/cm3"/>
   <composite n="2" ref="aluminum"/>
   <composite n="3" ref="oxygen"/>
  </material>

  <material name="Fe2O3" formula="Fe2O3">
   <D value="5.24" unit="g/cm3"/>
   <composite n="2" ref="iron"/>
   <composite n="3" ref="oxygen"/>
  </material>

  <material name="CaO" formula="CaO">
   <D value="3.35" unit="g/cm3"/>
   <composite n="1" ref="calcium"/>
   <composite n="1" ref="oxygen"/>
  </material>

  <material name="MgO" formula="MgO">
   <D value="3.58" unit="g/cm3"/>
   <composite n="1" ref="magnesium"/>
   <composite n="1" ref="oxygen"/>
  </material>

  <material name="Na2O" formula="Na2O">
   <D value="2.27" unit="g/cm3"/>
   <composite n="2" ref="sodium"/>
   <composite n="1" ref="oxygen"/>
  </material>

  <material name="TiO2" formula="TiO2">
   <D value="4.23" unit="g/cm3"/>
   <composite n="1" ref="titanium"/>
   <composite n="2" ref="oxygen"/>
  </material>

  <material name="FeO" formula="FeO">
   <D value="5.745" unit="g/cm3"/>
   <composite n="1" ref="iron"/>
   <composite n="1" ref="oxygen"/>
  </material>

  <material name="CO2" formula="CO2">
   <D value="1.562" unit="g/cm3"/>
   <composite n="1" ref="iron"/>
   <composite n="2" ref="oxygen"/>
  </material>

  <material name="P2O5" formula="P2O5">
   <D value="1.562" unit="g/cm3"/>
   <composite n="2" ref="phosphorus"/>
   <composite n="5" ref="oxygen"/>
  </material>
  
  <material name="SO3" formula="SO3">
   <D value="1.92" unit="g/cm3"/>
   <composite n="1" ref="sulphur"/>
   <composite n="3" ref="oxygen"/>
  </material>
  
  <material name="K2O" formula="K2O">
   <D value="2.35" unit="g/cm3"/>
   <composite n="2" ref="potassium"/>
   <composite n="1" ref="oxygen"/>
  </material>
  
  <material name="MnO" formula="MnO">
   <D value="5.37" unit="g/cm3"/>
   <composite n="1" ref="manganese"/>
   <composite n="1" ref="oxygen"/>
  </material>  
  
 <material name="V2O5" formula="V2O5">
   <D value="3.36" unit="g/cm3"/>
   <composite n="2" ref="vanadium"/>
   <composite n="5" ref="oxygen"/>
  </material> 

  <material formula=" " name="DUSEL_Rock">
    <D value="2.82" unit="g/cm3"/>
    <fraction n="0.5267" ref="SiO2"/>
    <fraction n="0.1174" ref="FeO"/>
    <fraction n="0.1025" ref="Al2O3"/>
    <fraction n="0.0473" ref="MgO"/>
    <fraction n="0.0422" ref="CO2"/>
    <fraction n="0.0382" ref="CaO"/>
    <fraction n="0.0240" ref="carbon"/>
    <fraction n="0.0186" ref="sulphur"/>
    <fraction n="0.0053" ref="Na2O"/>
    <fraction n="0.00070" ref="P2O5"/>
    <fraction n="0.0771" ref="oxygen"/>
  </material> 

  <material name="fibrous_glass">
   <D value="2.74351" unit="g/cm3"/>
   <fraction n="0.600" ref="SiO2"/>
   <fraction n="0.118" ref="Al2O3"/>
   <fraction n="0.001" ref="Fe2O3"/>
   <fraction n="0.224" ref="CaO"/>
   <fraction n="0.034" ref="MgO"/>
   <fraction n="0.010" ref="Na2O"/>
   <fraction n="0.013" ref="TiO2"/>
  </material>

  <material name="FR4">
   <D value="1.98281" unit="g/cm3"/>
   <fraction n="0.47" ref="epoxy_resin"/>
   <fraction n="0.53" ref="fibrous_glass"/>
  </material>

  <material name="STEEL_STAINLESS_Fe7Cr2Ni" formula="STEEL_STAINLESS_Fe7Cr2Ni">
   <D value="7.9300" unit="g/cm3"/>
   <fraction n="0.0010" ref="carbon"/>
   <fraction n="0.1792" ref="chromium"/>
   <fraction n="0.7298" ref="iron"/>
   <fraction n="0.0900" ref="nickel"/>
  </material>

  <material name="STEEL_STAINLESS_Fe7Cr2Ni_WV" formula="STEEL_STAINLESS_Fe7Cr2Ni_WV">
   <D value="0.38897" unit="g/cm3"/>
   <fraction n="0.0010" ref="carbon"/>
   <fraction n="0.1792" ref="chromium"/>
   <fraction n="0.7298" ref="iron"/>
   <fraction n="0.0900" ref="nickel"/>
  </material>
    
  <material name="STEEL_STAINLESS_Fe7Cr2Ni_Rack" formula="STEEL_STAINLESS_Fe7Cr2Ni_Rack">
   <D value="0.3811" unit="g/cm3"/>
   <fraction n="0.0010" ref="carbon"/>
   <fraction n="0.1792" ref="chromium"/>
   <fraction n="0.7298" ref="iron"/>
   <fraction n="0.0900" ref="nickel"/>
  </material>

  <material name="LAr" formula="LAr">
   <D value="1.39" unit="g/cm3"/>
   <fraction n="1.0000" ref="argon"/>
  </material>

  <material name="ArGas" formula="ArGas">
   <D value="0.00166" unit="g/cm3"/>
   <fraction n="1.0" ref="argon"/>
  </material>

  <material formula=" " name="Air">
   <D value="0.001205" unit="g/cm3"/>
   <fraction n="0.781154" ref="nitrogen"/>
   <fraction n="0.209476" ref="oxygen"/>
   <fraction n="0.00934" ref="argon"/>
  </material>

  <material formula=" " name="G10">
   <D value="1.7" unit="g/cm3"/>
   <fraction n="0.2805" ref="silicon"/>
   <fraction n="0.3954" ref="oxygen"/>
   <fraction n="0.2990" ref="carbon"/>
   <fraction n="0.0251" ref="hydrogen"/>
  </material>

  <material formula=" " name="Granite">
   <D value="2.7" unit="g/cm3"/>
   <fraction n="0.438" ref="oxygen"/>
   <fraction n="0.257" ref="silicon"/>
   <fraction n="0.222" ref="sodium"/>
   <fraction n="0.049" ref="aluminum"/>
   <fraction n="0.019" ref="iron"/>
   <fraction n="0.015" ref="potassium"/>
  </material>

  <material formula=" " name="ShotRock">
   <D value="@{[2.7*0.6]}" unit="g/cm3"/>
   <fraction n="0.438" ref="oxygen"/>
   <fraction n="0.257" ref="silicon"/>
   <fraction n="0.222" ref="sodium"/>
   <fraction n="0.049" ref="aluminum"/>
   <fraction n="0.019" ref="iron"/>
   <fraction n="0.015" ref="potassium"/>
  </material>

  <material formula=" " name="Dirt">
   <D value="1.7" unit="g/cm3"/>
   <fraction n="0.438" ref="oxygen"/>
   <fraction n="0.257" ref="silicon"/>
   <fraction n="0.222" ref="sodium"/>
   <fraction n="0.049" ref="aluminum"/>
   <fraction n="0.019" ref="iron"/>
   <fraction n="0.015" ref="potassium"/>
  </material>

  <material formula=" " name="Concrete">
   <D value="2.3" unit="g/cm3"/>
   <fraction n="0.530" ref="oxygen"/>
   <fraction n="0.335" ref="silicon"/>
   <fraction n="0.060" ref="calcium"/>
   <fraction n="0.015" ref="sodium"/>
   <fraction n="0.020" ref="iron"/>
   <fraction n="0.040" ref="aluminum"/>
  </material>
  

  <material formula="H2O" name="Water">
   <D value="1.0" unit="g/cm3"/>
   <fraction n="0.1119" ref="hydrogen"/>
   <fraction n="0.8881" ref="oxygen"/>
  </material>

  <material formula="Ti" name="Titanium">
   <D value="4.506" unit="g/cm3"/>
   <fraction n="1." ref="titanium"/>
  </material>

  <material name="TPB" formula="TPB">
   <D value="1.40" unit="g/cm3"/>
   <fraction n="1.0000" ref="argon"/>
  </material>

  <material name="Glass">
   <D value="2.74351" unit="g/cm3"/>
   <fraction n="0.600" ref="SiO2"/>
   <fraction n="0.118" ref="Al2O3"/>
   <fraction n="0.001" ref="Fe2O3"/>
   <fraction n="0.224" ref="CaO"/>
   <fraction n="0.034" ref="MgO"/>
   <fraction n="0.010" ref="Na2O"/>
   <fraction n="0.013" ref="TiO2"/>
  </material>

  <material name="Acrylic">
   <D value="1.19" unit="g/cm3"/>
   <fraction n="0.600" ref="carbon"/>
   <fraction n="0.320" ref="oxygen"/>
   <fraction n="0.080" ref="hydrogen"/>
  </material>

  <material name="Polystyrene">
   <D unit="g/cm3" value="1.06"/>
   <fraction n="0.077418" ref="hydrogen"/>
   <fraction n="0.922582" ref="carbon"/>
  </material>

  <material name="Polyurethane" formula="C27H36N2O10" >
   <D value="0.073" unit="g/cm3"/>
   <composite n="27" ref="carbon"/>
   <composite n="36" ref="hydrogen"/>
   <composite n="2" ref="nitrogen"/>
   <composite n="10" ref="oxygen"/>
    </material>
    
  <material name="matPlywood" formula="wood">
   <D value="0.67" unit="g/cm3"/>
    <fraction n="0.495" ref="carbon"/>
    <fraction n="0.063" ref="hydrogen"/>
    <fraction n="0.442" ref="oxygen"/>
  </material>
    
  <material name="STEEL_A992">
   <D unit="g/cm3" value="7.85"/>
   <fraction n="0.0022"  ref="carbon"/>
   <fraction n="0.005"   ref="copper"/>
   <fraction n="0.01"    ref="manganese"/>
   <fraction n="0.0044"  ref="nickel"/>
   <fraction n="0.00034" ref="phosphorus"/>
   <fraction n="0.0039"  ref="silicon"/>
   <fraction n="0.00044" ref="sulphur"/>
   <fraction n="0.001"   ref="vanadium"/>
   <fraction n="0.97272" ref="iron" />
  </material>
  
 
<material name="Polyisocyanurate" formula="C3H3N3O3" >
   <D value="0.128" unit="g/cm3"/>
   <composite n="3" ref="carbon"/>
   <composite n="3" ref="hydrogen"/>
   <composite n="3" ref="nitrogen"/>
   <composite n="3" ref="oxygen"/>
  </material>

  <material name="Perlite" formula="Al2CaFe2K2MgNa2O12Si" >
   <D value="0.232" unit="g/cm3"/>
   <composite n="2" ref="aluminum"/>
   <composite n="1" ref="calcium"/>
   <composite n="2" ref="iron"/>
   <composite n="2" ref="potassium"/>
   <composite n="1" ref="magnesium"/>
   <composite n="2" ref="sodium"/>
   <composite n="12" ref="oxygen"/>
   <composite n="1" ref="silicon"/>
  </material>

  <material name="asphalt" formula=" " >
    <D value="2.323" unit="g/cm3"/>
    <fraction n="0.8677"  ref="carbon"/>
    <fraction n="0.1094"  ref="hydrogen"/>
    <fraction n="0.0100"  ref="nitrogen"/>
    <fraction n="0.0099"  ref="sulphur"/>
    <fraction n="0.0030"  ref="oxygen"/>
  </material>

 <material formula=" " name="WallPanel">
   <D value="0.22" unit="g/cm3"/>
   <fraction n="0.811" ref="STEEL_STAINLESS_Fe7Cr2Ni"/>
   <fraction n="0.189" ref="Polyurethane"/>
  </material>

  <material formula=" " name="RoofLayers">
    <D value="0.317" unit="g/cm3"/>
    <fraction n="0.450" ref="asphalt"/>
    <fraction n="0.060" ref="Perlite"/>
    <fraction n="0.344" ref="Polyisocyanurate"/>
    <fraction n="0.146" ref="STEEL_STAINLESS_Fe7Cr2Ni"/>
  </material>  
  
  <material formula=" " name="CA6_Floor">
   <D value="1.698" unit="g/cm3"/>
   <fraction n="0.0030" ref="Na2O"/>
   <fraction n="0.1084" ref="MgO"/>   
   <fraction n="0.0757" ref="Al2O3"/>
   <fraction n="0.3707" ref="SiO2"/>
   <fraction n="0.0010" ref="P2O5"/>
   <fraction n="0.0248" ref="SO3"/>
   <fraction n="0.0034" ref="K2O"/> 
   <fraction n="0.3865" ref="CaO"/>
   <fraction n="0.0044" ref="TiO2"/>
   <fraction n="0.0066" ref="MnO"/>
   <fraction n="0.0056" ref="Fe2O3"/>
   <fraction n="0.0001" ref="V2O5"/>
   <fraction n="0.0102" ref="sulphur"/>     
  </material> 
  
  <material formula=" " name="CA7_underground">
   <D value="1.362" unit="g/cm3"/>
   <fraction n="0.0030" ref="Na2O"/>
   <fraction n="0.1084" ref="MgO"/>   
   <fraction n="0.0757" ref="Al2O3"/>
   <fraction n="0.3707" ref="SiO2"/>
   <fraction n="0.0010" ref="P2O5"/>
   <fraction n="0.0248" ref="SO3"/>
   <fraction n="0.0034" ref="K2O"/> 
   <fraction n="0.3865" ref="CaO"/>
   <fraction n="0.0044" ref="TiO2"/>
   <fraction n="0.0066" ref="MnO"/>
   <fraction n="0.0056" ref="Fe2O3"/>
   <fraction n="0.0001" ref="V2O5"/>
   <fraction n="0.0102" ref="sulphur"/>     
  </material>
  
  
      
</materials>
EOF

close(MAT);
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++ gen_TPC ++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


sub gen_TPC()
{
# Create the TPC fragment file name,
# add file to list of output GDML fragments,
# and open it
    $TPC = "icarus_TPC" . $suffix . ".gdml";
    push (@gdmlFiles, $TPC);
    $TPC = ">" . $TPC;
    open(TPC) or die("Could not open file $TPC for writing");


# The standard XML prefix and starting the gdml
    print TPC <<EOF;
<?xml version='1.0'?>
<gdml>
EOF


# All the TPC solids save the wires.
print TPC <<EOF;
<solids>
    <box name="TPC" lunit="cm" 
      x="$TPC_x" 
      y="$TPC_y" 
      z="$TPCHalf_z"/>
    <box name="TPCPlane" lunit="cm" 
      x="$TPCWirePlane_x" 
      y="$TPCWirePlane_y" 
      z="$TPCWirePlaneHalf_z"/>
    <box name="TPCActive" lunit="cm"
      x="$TPCActive_x"
      y="$TPCActive_y"
      z="$TPCActiveHalf_z"/>
EOF


#++++++++++++++++++++++++++++ Wire Solids ++++++++++++++++++++++++++++++

# Set number of wires to default to zero, when $wires_on = 0, for a low memory 
# version. But if $wires_on = 1, calculate the number of wires on each side of each
# plane to be used in the for loops

my $NumberHorizontalWires = 0;
my $NumberCornerUWires = 0;
my $NumberCommonUWires = 0;
my $NumberCornerVWires = 0;
my $NumberCommonVWires = 0;


if ($wires_on == 1)
{
   # Number of wires in one corner
   #$NumberCornerVWires = int( $TPCWirePlane_y/$VWire_ypitch );
   #$NumberCornerWWires = int( $TPCWirePlane_y/$WWire_ypitch );
    $NumberCornerUWires = 480;
    $NumberCornerVWires = 480;

   # Number of wires in one corner + the number to cover the whole corner.
    $NumberCornerExtUWires = 528;
    $NumberCornerExtVWires = 528;

   # Total number of wires touching one vertical (longer) side
   # Note that the total number of wires per plane is this + another set of corner wires
   # $NumberSideUWires = int( $TPCWirePlane_z/$UWire_zpitch );
   # $NumberSideVWires = int( $TPCWirePlane_z/$VWire_zpitch );
   # $NumberSideWWires = int( $TPCWirePlane_z/$WWire_zpitch );

   # Number of wires per side that aren't cut off by the corner
   # $NumberCommonUWires = $NumberSideUWires - $NumberCornerUWires;
   # $NumberCommonVWires = $NumberSideVWires - $NumberCornerVWires;
    #$NumberCommonWWires = $NumberSideWWires - $NumberCornerWWires;
    #$NumberCommonUWires  = 4640;
    #$NumberCommonVWires  = 4640;
   $NumberCommonUWires  = 2056;
   $NumberCommonVWires  = 2056;

   # number of wires on the vertical plane
   #$NumberHorizontalWires = int( ($TPCWirePlane_y-$TPCWireThickness)/$UWirePitch );
   #Number of wires inthe Y plane-->Horizontal plane Induction I
    $NumberHorizontalWires = 1056;

}

# These XML comments throughout make the GDML file easier to navigate
print TPC <<EOF;

<!--+++++++++++++++++++ Y Wire Solids ++++++++++++++++++++++-->

EOF

if ($wires_on==1) 
{

#CommonWire = wires with same length

   print TPC <<EOF;
    <tube name="TPCWireYCommon"
      rmax="$TPCWireRadius"
      z="$TPCWirePlaneHalf_z"
      deltaphi="360"
      aunit="deg"
      lunit="cm"/>
EOF

} else { 

print TPC <<EOF;

        <!-- This GDML version has no wires and uses much less memory -->

EOF

}

print TPC <<EOF;


<!--+++++++++++++++++++ U Wire Solids ++++++++++++++++++++++-->


EOF

# The corner wires for the U plane
if ($wires_on==1) 
{
#FAKE CORNER 
    $length = $CommonWireLength + $DeltaLUCorner/2;

   for ($i = 0; $i < $NumberCornerExtUWires; ++$i)
    {
	 $length -= $DeltaLUCorner;

print TPC <<EOF;
    <tube name="TPCWireU$i"
      rmax="$TPCWireRadius"
      z="$length"
      deltaphi="360"
      aunit="deg"
      lunit="cm"/>
EOF

#print(" $i $length \n");

   } #ends FAKE CORNER

#REAL CORNER 
    $length = $CommonWireLength;

   for ($i = 0; $i < $NumberCornerUWires; ++$i)
    {
	 $length -= $DeltaLUCorner;

print TPC <<EOF;
    <tube name="TPCWireCornerU$i"
      rmax="$TPCWireRadius"
      z="$length"
      deltaphi="360"
      aunit="deg"
      lunit="cm"/>
EOF

#print(" $i $length \n");

    } #ends REAL CORNER
    
print TPC <<EOF;
    <tube name="TPCWireUCommon"
      rmax="$TPCWireRadius"
      z="$CommonWireLength"
      deltaphi="360"
      aunit="deg"
      lunit="cm"/>
EOF

} else { 

print TPC <<EOF;

                   <!-- no wires in this GDML -->

EOF

}


print TPC <<EOF;


<!--+++++++++++++++++++ V Wire Solids ++++++++++++++++++++++-->


EOF

# The corner wires for the V plane
if ($wires_on==1) 
{
# FAKE CORNER
   $length = $CommonWireLength + $DeltaLVCorner/2;

    for ($i = 0; $i < $NumberCornerExtVWires; ++$i)
   {

	$length -= $DeltaLVCorner;

   print TPC <<EOF;
    <tube name="TPCWireV$i"
      rmax="$TPCWireRadius"
      z="$length"
      deltaphi="360"
      aunit="deg"
      lunit="cm"/>
EOF

#print(" $i $length \n");

    } #ends FAKE CORNER

# REAL CORNER
   $length = $CommonWireLength;

    for ($i = 0; $i < $NumberCornerVWires; ++$i)
   {

	$length -= $DeltaLVCorner;

   print TPC <<EOF;
    <tube name="TPCWireCornerV$i"
      rmax="$TPCWireRadius"
      z="$length"
      deltaphi="360"
      aunit="deg"
      lunit="cm"/>
EOF

#print(" $i $length \n");

    } #ends REAL CORNER


   print TPC <<EOF;
    <tube name="TPCWireVCommon"
      rmax="$TPCWireRadius"
      z="$CommonWireLength"
      deltaphi="360"
      aunit="deg"
      lunit="cm"/>
EOF

} else { 

print TPC <<EOF;

                   <!-- no wires in this GDML -->

EOF

}

# Begin structure and create the vertical wire logical volume
print TPC <<EOF;
</solids>
<structure>
    <volume name="volTPCActive">
      <materialref ref="LAr"/>
      <solidref ref="TPCActive"/>
      <auxiliary auxtype="SensDet" auxvalue="SimEnergyDeposit"/>
      <auxiliary auxtype="StepLimit" auxvalue="0.3" auxunit="mm"/>
    </volume>

<!--+++++++++++++++++ Wire Logical Volumes ++++++++++++++++++++-->

EOF


if ($wires_on==1) 
{ 

  # Common Y wire logical volume, referenced many times
  print TPC <<EOF;
    <volume name="volTPCWireYCommon">
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni" />
      <solidref ref="TPCWireYCommon" />
    </volume>
EOF

  # Fake Corner U wires logical volumes
  for ($i = 0; $i < $NumberCornerExtUWires; ++$i)
  {
  print TPC <<EOF;
    <volume name="volTPCWireU$i">
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni" />
      <solidref ref="TPCWireU$i" />
    </volume>
EOF

  }
  
  # Real Corner U wires logical volumes
  for ($i = 0; $i < $NumberCornerUWires; ++$i)
  {
  print TPC <<EOF;
    <volume name="volTPCWireCornerU$i">
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni" />
      <solidref ref="TPCWireCornerU$i" />
    </volume>
EOF

  }
  
  # Common U wire logical volume, referenced many times
  print TPC <<EOF;
    <volume name="volTPCWireUCommon">
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni" />
      <solidref ref="TPCWireUCommon" />
    </volume>
EOF

  # Fake Corner V wires logical volumes
  for ($i = 0; $i < $NumberCornerExtVWires; ++$i)
  {
  print TPC <<EOF;
    <volume name="volTPCWireV$i">
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni" />
      <solidref ref="TPCWireV$i" />
    </volume>
EOF

  }
  
  # Real Corner V wires logical volumes
  for ($i = 0; $i < $NumberCornerVWires; ++$i)
  {
  print TPC <<EOF;
    <volume name="volTPCWireCornerV$i">
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni" />
      <solidref ref="TPCWireCornerV$i" />
    </volume>
EOF

  }
  # Common V wire logical volume, referenced many times
  print TPC <<EOF;
    <volume name="volTPCWireVCommon">
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni" />
      <solidref ref="TPCWireVCommon" />
    </volume>
EOF

} else { 


print TPC <<EOF;

        <!-- This GDML version has no wires and uses much less memory -->

EOF

}


#+++++++++++++++++++++++++ Position physical wires ++++++++++++++++++++++++++

#            ++++++++++++++++++++++  Y Plane  +++++++++++++++++++++++

# Create Y plane logical volume
print TPC <<EOF;


<!--+++++++++++++++++++++ Y Plane ++++++++++++++++++++++++-->


    <volume name="volTPCPlaneY">
      <materialref ref="LAr"/>
      <solidref ref="TPCPlane"/>
      <auxiliary auxtype="SensDet" auxvalue="SimEnergyDeposit"/>
      <auxiliary auxtype="StepLimit" auxvalue="0.3" auxunit="mm"/>
EOF

if ($wires_on==0)
{
print TPC <<EOF;

           <!-- no wires -->

EOF

} else {

    $ypos = ($NumberHorizontalWires+1)*$YWirePitch/2;

    for ($i = 0; $i < $NumberHorizontalWires; ++$i)
    {
	$ypos -= $YWirePitch;


print TPC <<EOF;
      <physvol>
        <volumeref ref="volTPCWireYCommon"/>
        <position name="posTPCWireY$i" unit="cm" x="0" y="$ypos " z="0"/>
        <rotationref ref="rIdentity"/>
      </physvol>
EOF

	#print("0 $ypos \n");

	#$ypos -= $YWirePitch;

    }

} #ends else


#            ++++++++++++++++++++++  U Plane  +++++++++++++++++++++++

# End U plane and create U plane logical volume
print TPC <<EOF;
    </volume>


<!--+++++++++++++++++++++ U Plane ++++++++++++++++++++++++-->


    <volume name="volTPCPlaneU">
      <materialref ref="LAr"/>
      <solidref ref="TPCPlane"/>
      <auxiliary auxtype="SensDet" auxvalue="SimEnergyDeposit"/>
      <auxiliary auxtype="StepLimit" auxvalue="0.3" auxunit="mm"/>
EOF

if ($wires_on==0)
{
print TPC <<EOF;

           <!-- no wires -->

EOF

} else {

#CORNERS

    $ypos1 = $TPCActive_y/2;
    $zpos1 = -$TPCActiveHalf_z/2 + $CommonWireLength * $CosUAngle + $UWire_zpitch - $UWire_zpitch/2 - $UWire_zpitch/2;

    $ypos2 = -$TPCActive_y/2;
    $zpos2 = -$TPCActiveHalf_z/2;

   #Positioning of 480 real U corner wires.
   for ($i = 0; $i < $NumberCornerUWires; ++$i)
    {
	 $ypos1 += $UWire_ypitch  ;
	 $zpos2 -= $UWire_zpitch  ;

	 $ypos = ($ypos1+$ypos2)/2;
         $zpos = ($zpos1+$zpos2)/2;

	#print("U Corner wires: $i $zpos $ypos , ");
	
print TPC <<EOF;
      <physvol>
        <volumeref ref="volTPCWireCornerU$i"/>
        <position name="posTPCWireU$i" unit="cm" x="0" y="$ypos " z="$zpos"/>
        <rotationref ref="rPlusUAngleAboutX"/>
      </physvol>
EOF
    }

    $ypos1 = $TPCActive_y/2 - $UWire_ypitch + $UWire_ypitch/2;
    $zpos1 = -$TPCActiveHalf_z/2 + $CommonWireLength * $CosUAngle + $UWire_zpitch - $UWire_zpitch/2;

    $ypos2 = - $TPCActive_y/2;
    $zpos2 = -$TPCActiveHalf_z/2;
    
    #Positioning of 528 fake U corners wires.
    for ($i = 0; $i < $NumberCornerExtUWires; ++$i)
    {
      $ypos1 += $UWire_ypitch;
      $zpos2 -= $UWire_zpitch;

      $ypos = ($ypos1+$ypos2)/2;
      $zpos = ($zpos1+$zpos2)/2;

      $ypos = - $ypos;
      $zpos = - $zpos;

print TPC <<EOF;
      <physvol>
        <volumeref ref="volTPCWireU$i"/>
        <position name="posTPCWireU@{[$i+$NumberCommonUWires+$NumberCornerUWires]}" unit="cm" x="0" y="$ypos " z="$zpos"/>
        <rotationref ref="rPlusUAngleAboutX"/>
      </physvol>
EOF
    } #ends CORNER


#Common Wires
    
   $zpos = (-$TPCActiveHalf_z +  $CommonWireLength * $CosUAngle + $UWire_zpitch)/2. - $UWire_zpitch/2;
   #print("common wires $zpos \n");

    for ($i = 0; $i < $NumberCommonUWires; ++$i)
    {

print TPC <<EOF;
      <physvol>
        <volumeref ref="volTPCWireUCommon"/>
        <position name="posTPCWireU@{[$i+$NumberCornerUWires]}" unit="cm" x="0" y="0 " z="$zpos"/>
        <rotationref ref="rPlusUAngleAboutX"/>
      </physvol>
EOF

    #print("U wires $i $zpos 0 \n");
	$zpos += $UWire_zpitch;

    }


} #ends else

#            ++++++++++++++++++++++  V Plane  +++++++++++++++++++++++

# End V plane and create V plane logical volume
print TPC <<EOF;
    </volume>

<!--+++++++++++++++++++++ V Plane ++++++++++++++++++++++++-->


    <volume name="volTPCPlaneV">
      <materialref ref="LAr"/>
      <solidref ref="TPCPlane"/>
      <auxiliary auxtype="SensDet" auxvalue="SimEnergyDeposit"/>
      <auxiliary auxtype="StepLimit" auxvalue="0.3" auxunit="mm"/>
EOF

if ($wires_on==0)
{
print TPC <<EOF;

           <!-- no wires -->

EOF

} else {

#CORNERS

    $ypos1 = $TPCActive_y/2;
    $zpos1 = -$TPCActiveHalf_z/2;

    $ypos2 = -$TPCActive_y/2;
    $zpos2 = -$TPCActiveHalf_z/2 + $CommonWireLength * $CosVAngle + $VWire_zpitch - $VWire_zpitch/2 - $VWire_zpitch/2 ;

   #Positioning of 480 real V corners wires.

   for ($i = 0; $i < $NumberCornerVWires; ++$i)
    {
	 $ypos1 -= $VWire_ypitch  ;
	 $zpos2 -= $VWire_zpitch  ;

	 $ypos = ($ypos1+$ypos2)/2;
         $zpos = ($zpos1+$zpos2)/2;

	#print("V Corner wires: $i $zpos $ypos , ");


print TPC <<EOF;
      <physvol>
        <volumeref ref="volTPCWireCornerV$i"/>
        <position name="posTPCWireV$i" unit="cm" x="0" y="$ypos " z="$zpos"/>
        <rotationref ref="rMinusVAngleAboutX"/>
      </physvol>
EOF
    }
    
    $ypos1 = $TPCActive_y/2 + $VWire_ypitch - $VWire_ypitch/2;
    $zpos1 = -$TPCActiveHalf_z/2 + $VWire_zpitch - $VWire_zpitch/2;
    
    $ypos2 = -$TPCActive_y/2;
    $zpos2 = -$TPCActiveHalf_z/2 + $CommonWireLength * $CosVAngle;

    #Positioning of 528 fake V corners wires.
    for ($i = 0; $i < $NumberCornerExtVWires; ++$i)
    {
       $ypos1 -= $VWire_ypitch;
       $zpos2 -= $VWire_zpitch;

       $ypos = ($ypos1+$ypos2)/2;
       $zpos = ($zpos1+$zpos2)/2;

       $ypos = - $ypos;
       $zpos = - $zpos;

print TPC <<EOF;
      <physvol>
        <volumeref ref="volTPCWireV$i"/>
        <position name="posTPCWireV@{[$i+$NumberCommonVWires+$NumberCornerVWires]}" unit="cm" x="0" y="$ypos " z="$zpos"/>
        <rotationref ref="rMinusVAngleAboutX"/>
      </physvol>
EOF

	#print(" $zpos $ypos \n");

    } #ends CORNERS

   #Common Wires

   $zpos = (-$TPCActiveHalf_z +  $CommonWireLength * $CosVAngle + $VWire_zpitch) / 2. - $VWire_zpitch/2;

    for ($i = 0; $i < $NumberCommonVWires; ++$i)
    {

print TPC <<EOF;
      <physvol>
        <volumeref ref="volTPCWireVCommon"/>
        <position name="posTPCWireV@{[$i+$NumberCornerVWires]}" unit="cm" x="0" y="0 " z="$zpos"/>
        <rotationref ref="rMinusVAngleAboutX"/>
      </physvol>
EOF

        #print("V wires: $i $zpos  0 \n");
	$zpos += $VWire_zpitch;

    }


} #ends else

print TPC <<EOF;
    </volume>
EOF

#+++++++++++++++++++++ Position physical wires Above +++++++++++++++++++++

my $VolY_x = (-$TPC_x/2) + 3*$WirePlaneSpacing; #+ $TPCWirePlane_x/2;    
my $VolU_x = (-$TPC_x/2) + 2*$WirePlaneSpacing; #+ $TPCWirePlane_x/2;    
my $VolV_x = (-$TPC_x/2) + 1*$WirePlaneSpacing; #+ $TPCWirePlane_x/2;  


#wrap up the TPC file
#March 2021: flipping of U and V planes by 180 degrees about z axis - A. Menegolli
print TPC <<EOF;

    <volume name="volTPC0">
      <materialref ref="LAr" />
      <solidref ref="TPC" />
      <auxiliary auxtype="SensDet" auxvalue="SimEnergyDeposit"/>
      <auxiliary auxtype="StepLimit" auxvalue="0.3" auxunit="mm"/>
      <physvol>
       <volumeref ref="volTPCPlaneY" />
       <position name="posTPCPlaneY" unit="cm" x="$VolY_x" y="0" z="@{[$UpstreamLArPadding/2]}" />
     </physvol>
     <physvol>
       <volumeref ref="volTPCPlaneU" />
       <position name="posTPCPlaneU" unit="cm" x="$VolU_x" y="0" z="@{[$UpstreamLArPadding/2]}" />
       <rotationref ref="rPlus180AboutZ"/>
     </physvol>
     <physvol>
       <volumeref ref="volTPCPlaneV" />
       <position name="posTPCPlaneV" unit="cm" x="$VolV_x" y="0" z="@{[$UpstreamLArPadding/2]}" />
       <rotationref ref="rPlus180AboutZ"/>
     </physvol>
     <physvol>
     <volumeref ref="volTPCActive"/>
     <positionref ref="posActiveInTPC0"/>
     </physvol>	
     <physvol> 
       <volumeref ref="volRaceTrackTVolume"/>
       <positionref ref="posRaceTrackTInTPC"/>
       <rotationref ref="rIdentity"/>
     </physvol>
     <physvol> 
       <volumeref ref="volRaceTrackBVolume"/>
       <positionref ref="posRaceTrackBInTPC"/>
       <rotationref ref="rIdentity"/>
     </physvol>
     <physvol> 
       <volumeref ref="volRaceTrackUVolume"/>
       <positionref ref="posRaceTrackUInTPC"/>
       <rotationref ref="rPlus90AboutX"/>
     </physvol>
    </volume>

</structure>
</gdml>
EOF

    close(GDML);

} #end of sub gen_TPC

##################################################################
#dg ##########  Race Tracks Parameters ###########################
##################################################################
sub define_RaceTrack()
{
# from "Design, construction and tests of the ICARUS T600 detector",
# ICARUS Collaboration (S. Amerio et al.). Jul 2004. 82 pp. 
# Nucl.Instrum.Meth. A527 (2004) 329-410
#
#  4 parts: Top (T) Bottom (B) Upstream (U) Downstream (D)
  $RT_epsilon = .0001 ;# extra safety space;
  $RaceTrack_d = 3.4;  # cm race track tube diameter
  $RaceTrack_TubeThick = 0.08; #cm race track tube thick
#  $RaceTrack_lz = 1810.0; #cm length of race track structure
  $RaceTrack_lz = 905; #cm length of race track structure (half to accommodate for split wire TPC)
#  $RaceTrack_ly = 320.0 - 2*$RT_epsilon;  #cm length of race track tubes
  $RaceTrack_ly = 323.6201 ;  #cm height of race track structure (modified to be external to TPCActive_y
  $RaceTrack_number = 29; #number of race tracks
  $RaceTrack_pitch = 4.96; #distance between each race track tube
  $RaceTrack_ExternalRadius = $RaceTrack_d * 0.5;  # cm  external race track tube radius
  $RaceTrack_InnerRadius = $RaceTrack_d * 0.5-$RaceTrack_TubeThick;  # cm internal race track tube radius
  $RaceTrack_width = ($RaceTrack_pitch +$RT_epsilon) * $RaceTrack_number;
  $RaceTrackT_length = $RaceTrack_lz + $RT_epsilon; # guess about Horizontal length
  $RaceTrackTTube_length = $RaceTrackT_length - $RT_epsilon; # guess about Horizontal length
  $RaceTrackB_length = $RaceTrack_lz + $RT_epsilon; # guess about Horizontal length
  $RaceTrackBTube_length = $RaceTrackB_length - $RT_epsilon; # guess about Horizontal length
  $RaceTrackU_length  = $RaceTrack_ly - 2* $RaceTrack_d; # guess of vertical length
  $RaceTrackUTube_length  = $RaceTrackU_length - $RT_epsilon; # guess of vertical length
  $RaceTrack_thickness=$RaceTrack_d+2*$RT_epsilon; # 
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#dg +++++++++++++++++++++++++++++++++++ gen_RaceTracks +++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_RaceTracks{

#  4 parts: Top (T) Bottom (B) Upstream (U) Downstream (D)
# define the racetrack geometrical parameters
    define_RaceTrack();

    $RACETRACK= "icarus_racetracks" . $suffix . ".gdml";
    push (@gdmlFiles, $RACETRACK); # Add file to list of GDML fragments
    $RACETRACK = ">" . $RACETRACK;
    open(RACETRACK) or die("Could not open file $RACETRACK for writing");

# The standard XML prefix and starting the gdml
    print RACETRACK <<EOF;
    <?xml version='1.0'?>
<gdml>
EOF

#Create the RACETRACK volumes:
# positions 

$RTy_T= ($RaceTrack_ly - $RaceTrack_thickness )/2. + $RT_epsilon ; 
$RTy_B=-($RaceTrack_ly - $RaceTrack_thickness )/2. + $RT_epsilon ;
$RTx_T= ($TPC_x - $RaceTrack_pitch -$RaceTrack_width )/2. ;
$RTx_B= $RTx_T ;
$RTx_U= $RTx_T ;
$RTz_U= -($RaceTrackT_length - $RaceTrack_thickness)/2. - $RT_epsilon + 45 - ($RaceTrackT_length - $TPCActiveHalf_z)/2;   
$RTx_D= $RTx_T ;
$RTz_D= -$RTz_U ;
$RTz_T= 45 - ($RaceTrackT_length - $TPCActiveHalf_z)/2;
$RTz_B= 45 - ($RaceTrackT_length - $TPCActiveHalf_z)/2;

    
print RACETRACK <<EOF;
<define>

   <position name="posRaceTrackTInTPC" unit="cm" x="$RTx_T" y="$RTy_T" z="$RTz_T"/>
   <position name="posRaceTrackBInTPC" unit="cm" x="$RTx_B" y="$RTy_B" z="$RTz_B"/>
   <position name="posRaceTrackUInTPC" unit="cm" x="$RTx_U" y="0" z="$RTz_U"/>
   <position name="posRaceTrackDInTPC" unit="cm" x="$RTx_D" y="0" z="$RTz_D"/>

</define>   
<!--+++++++++++++++++++ RACETRACK Solids +++++++++++++++++++-->

EOF

print RACETRACK <<EOF;


<solids>
 <box name="RaceTrackTVolume"
  x="$RaceTrack_width"
  y="$RaceTrack_thickness"
  z="$RaceTrackT_length" 
  lunit="cm" />
 <box name="RaceTrackBVolume"
  x="$RaceTrack_width"
  y="$RaceTrack_thickness"
  z="$RaceTrackB_length" 
  lunit="cm"/>
 <box name="RaceTrackUVolume"
  x="$RaceTrack_width"
  y="$RaceTrack_thickness"
  z="$RaceTrackU_length" 
  lunit="cm"/>
 <tube name="RaceTrackTTubeVolume"
  rmax="$RaceTrack_ExternalRadius"
  rmin="$RaceTrack_InnerRadius"
  z="$RaceTrackTTube_length" 
  deltaphi="360"
  aunit="deg"
  lunit="cm"/>
 <tube name="RaceTrackBTubeVolume"
  rmax="$RaceTrack_ExternalRadius"
  rmin="$RaceTrack_InnerRadius"
  z="$RaceTrackBTube_length" 
  deltaphi="360"
  aunit="deg"
  lunit="cm"/>
 <tube name="RaceTrackUTubeVolume"
  rmax="$RaceTrack_ExternalRadius"
  rmin="$RaceTrack_InnerRadius"
  z="$RaceTrackUTube_length" 
  deltaphi="360"
  aunit="deg"
  lunit="cm"/>

</solids>
EOF


# assume Upstream identical to Downstream part
# First define RaceTrack tubes 

print RACETRACK <<EOF;
<structure>

<!--+++++++++++++++++ RACETRACK Logical Volumes ++++++++++++++++++++-->

    <volume name="volRaceTrackTTubeVolume"> 
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni"/>  
      <solidref ref="RaceTrackTTubeVolume"/>
    </volume>
    <volume name="volRaceTrackBTubeVolume"> 
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni"/>  
      <solidref ref="RaceTrackBTubeVolume"/>
    </volume>
    <volume name="volRaceTrackUTubeVolume"> 
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni"/>  
      <solidref ref="RaceTrackUTubeVolume"/>
    </volume>
EOF

# Define Upper part of RaceTrack
print RACETRACK <<EOF;

<!--+++++++++++++++++ RACETRACK Top Volume   ++++++++++++++++++++-->

    <volume name="volRaceTrackTVolume"> 
      <materialref ref="LAr"/>  
      <solidref ref="RaceTrackTVolume"/>


EOF


# Here it would be better to divide the volume into slices and then embedding tubes
# at the moment simply replicate each tube
$xTpos=-($RaceTrack_width - $RaceTrack_pitch - $RT_epsilon )/2.;
for ($it = 0; $it < $RaceTrack_number; $it++) 
{
  print RACETRACK <<EOF;
      <physvol>
        <volumeref ref="volRaceTrackTTubeVolume"/>
        <position name="posRTkTTube$it" unit="cm" x="$xTpos" y="0" z="0" />
        <rotationref ref="rIdentity" />
      </physvol>
EOF
  $xTpos+= $RaceTrack_pitch ;
}
print RACETRACK <<EOF;

    </volume>
EOF

# Define Lower part of RaceTrack
print RACETRACK <<EOF;

<!--+++++++++++++++++ RACETRACK Bottom Volume ++++++++++++++++++++-->

    <volume name="volRaceTrackBVolume"> 
      <materialref ref="LAr"/>  
      <solidref ref="RaceTrackBVolume"/>
EOF


# Here it would be better to divide the volume into slices and then embedding tubes
# at the moment simply replicate each tube
$xTpos=-($RaceTrack_width - $RaceTrack_pitch - $RT_epsilon )/2.;
for ($it = 0; $it < $RaceTrack_number; $it++) 
{
  print RACETRACK <<EOF;
      <physvol>
        <volumeref ref="volRaceTrackBTubeVolume"/>
        <position name="posRTkBTube$it" unit="cm" x="$xTpos" y="0" z="0" />
        <rotationref ref="rIdentity" />
      </physvol>
EOF
  $xTpos+= $RaceTrack_pitch ;
}
print RACETRACK <<EOF;

    </volume>
EOF

# Define Upstream part of RaceTrack
print RACETRACK <<EOF;

<!--+++++++++++++++++ RACETRACK Upstream Volume ++++++++++++++++++++-->

    <volume name="volRaceTrackUVolume"> 
      <materialref ref="LAr"/>  
      <solidref ref="RaceTrackUVolume"/>
EOF

# Here it would be better to divide the volume into slices and then embedding tubes
# at the moment simply replicate each tube
$xTpos=-($RaceTrack_width - $RaceTrack_pitch - $RT_epsilon )/2.;
for ($it = 0; $it < $RaceTrack_number; $it++) 
{
  print RACETRACK <<EOF;
      <physvol>
        <volumeref ref="volRaceTrackUTubeVolume"/>
        <position name="posRTkUTube$it" unit="cm" x="$xTpos" y="0" z="0" />
        <rotationref ref="rIdentity" />
      </physvol>
EOF
  $xTpos+= $RaceTrack_pitch ;
}
print RACETRACK <<EOF;

    </volume>
EOF

# close the RaceTrack structure 
print RACETRACK <<EOF;

<!--+++++++++++++++++ RACETRACK end structure +++++++++++++++++++-->
</structure>
EOF

#Close standard XML file
print RACETRACK <<EOF;
</gdml>
EOF

} 
#ends gen_RaceTracks

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++ gen_PMTs +++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_PMT {

    $PMT = "icarus_pmt" . $suffix . ".gdml";
    push (@gdmlFiles, $PMT); # Add file to list of GDML fragments
    $PMT = ">" . $PMT;
    open(PMT) or die("Could not open file $PMT for writing");

# The standard XML prefix and starting the gdml
    print PMT <<EOF;
<?xml version='1.0'?>
<gdml>
EOF

#Create the PMT volume original z=2.54
print PMT <<EOF;

<!--+++++++++++++++++++ PMT Solids ++++++++++++++++++++++-->

EOF
#<position name="PMTtube" unit="cm" x="30" y="0" z="0"/>
#was after print PMT <<EOF; line
#moved here to comment out for moving to position defs

print PMT <<EOF;
<solids>	
 <sphere name="PMTVolume"
  rmin="$PMTradiusInner"
  rmax="$PMTradiusOuter"
  deltaphi="360"
  deltatheta="90"
  aunit="deg"
  lunit="cm"/>
 <sphere name="PMTPassSphere"
  rmin="$PMTradiusInner"
  rmax="$PMTradiusOuter"
  deltaphi="360"
  starttheta="23"  
  deltatheta="67"
  aunit="deg"
  lunit="cm"/>
 <tube name="PMTPassTube"
  rmax="$PMTtubeRmax"
  rmin="$PMTtubeRmin"
  z="@{[$PMTtube_x-0.8]}" 
  deltaphi="360"
  aunit="deg"
  lunit="cm"/>
 <tube name="PMTPassEndcap"
  rmax="$PMTtubeRmax"
  rmin="0"
  z="0.1" 
  deltaphi="360"
  aunit="deg"
  lunit="cm"/> 
 <union name="PMTPassNocap">
  <first ref="PMTPassSphere"/>
  <second ref="PMTPassTube"/>
  <positionref ref="posPMTtube"/>
  <rotationref ref="rMinus90AboutZ"/>
 </union>
 <union name="PMTPassVolume">
  <first ref="PMTPassNocap"/>
  <second ref="PMTPassEndcap"/>
  <positionref ref="posPMTEndcap"/>
  <rotationref ref="rMinus90AboutZ"/>
 </union>
    
 <sphere name="PMTInnerVolume"
  rmin="0"
  rmax="$PMTradiusInner"
  deltaphi="360"
  deltatheta="90"
  aunit="deg"
  lunit="cm"/>
 <sphere name="PMTInnerPassSphere"
  rmin="0"
  rmax="$PMTradiusInner"
  deltaphi="360"
  deltatheta="90"
  aunit="deg"
  lunit="cm"/>
 <tube name="PMTInnerPassTube"
  rmax="$PMTtubeRmin"
  rmin="0"
  z="$PMTtube_x" 
  deltaphi="360"
  aunit="deg"
  lunit="cm"/>
 <union name="PMTInnerPassVolume">
  <first ref="PMTInnerPassSphere"/>
  <second ref="PMTInnerPassTube"/>
  <positionref ref="posPMTInnertube"/>
  <rotationref ref="rMinus90AboutZ"/>
 </union>  
</solids>   
EOF

#For some reasons, the Optical Sensitive Volume for PMT has to be LAr ... I found this info both in SBND and MicroBoone geometries
print PMT <<EOF;
<structure>

<!--+++++++++++++++++ PMT Logical Volumes ++++++++++++++++++++-->

    <volume name="volOpDetSensitive"> 
      <materialref ref="LAr"/>  
      <solidref ref="PMTVolume"/>
      <auxiliary auxtype="SensDet" auxvalue="PhotonDetector"/>
    </volume>
    <volume name="volNotOpDetSensitive"> 
      <materialref ref="ALUMINUM_PMT"/>  
      <solidref ref="PMTPassVolume"/>
    </volume>
    <volume name="volActiveInnerPMT"> 
      <materialref ref="Vacuum"/>  
      <solidref ref="PMTInnerVolume"/>
    </volume>
    <volume name="volPassiveInnerPMT"> 
      <materialref ref="Vacuum"/>  
      <solidref ref="PMTInnerPassVolume"/>
    </volume>
</structure>
EOF

#Close standard XML file
print PMT <<EOF;
</gdml>
EOF

} 
#ends gen PMTs

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#am+++++++++++++++++++++++ gen_structure +++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_Mech_Structure{

    $MECH = "icarus_Mech_Structure" . $suffix . ".gdml";
    push (@gdmlFiles, $MECH); # Add file to list of GDML fragments
    $MECH = ">" . $MECH;
    open(MECH) or die("Could not open file $MECH for writing");

# The standard XML prefix and starting the gdml
    print MECH <<EOF;
<?xml version='1.0'?>
<gdml>
EOF

#All the steel structure solids
print MECH <<EOF;

<!--+++++++++++++++++++ Structure Solids ++++++++++++++++++++++-->

EOF
print MECH <<EOF;
<solids> 
  <box name="LatExtMechBox"
  x="$ext_struct_x"
  y="$ext_struct_y"
  z="$ext_struct_z" 
  lunit="cm" />
  <box name="LatIntMechBox"
  x="@{[0.1+$int_struct_x]}"
  y="$int_struct_y"
  z="$int_struct_z" 
  lunit="cm" />
  <box name="Pillar"
  x="$int_struct_x"
  y="$int_struct_y"
  z="$int_struct_x" 
  lunit="cm" />
  <subtraction name="LatIntMechShell">
    <first ref="LatIntMechBox"/>
    <second ref="Pillar"/>
  </subtraction>
  <subtraction name="LatMechShell">
   <first ref="LatExtMechBox"/>
   <second ref="LatIntMechShell"/>
 </subtraction>
</solids>   
EOF

print MECH <<EOF;
<structure>

<!--+++++++++++++++++ Structure Logical Volumes ++++++++++++++++++++-->

<volume name="volLatMech"> 
  <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni"/>  
  <solidref ref="LatMechShell"/>
</volume>

</structure>
EOF

#Close standard XML file
print MECH <<EOF;
</gdml>
EOF

} 
#ends gen mechanical structure

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++ gen_Cryostat +++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_Cryostat()
{

# Create the cryostat fragment file name,
# add file to list of output GDML fragments,
# and open it
    $CRYO = "icarus_Cryostat" . $suffix . ".gdml";
    push (@gdmlFiles, $CRYO);
    $CRYO = ">" . $CRYO;
    open(CRYO) or die("Could not open file $CRYO for writing");


# The standard XML prefix and starting the gdml
    print CRYO <<EOF;
<?xml version='1.0'?>
<gdml>
EOF


# All the cryostat solids.
print CRYO <<EOF;
<solids>

    <box name="Cryostat" lunit="cm" 
      x="$Cryostat_x" 
      y="$Cryostat_y" 
      z="$Cryostat_z"/>
    <box name="ArgonInterior" lunit="cm" 
      x="$LAr_x"
      y="@{[$LAr_y + $GaseousAr_y]}"
      z="$TPC_z"/>
    <box name="GaseousArgon" lunit="cm" 
      x="$LAr_x"
      y="$GaseousAr_y"
      z="$LAr_z"/>
    <subtraction name="AlumShell">
      <first ref="Cryostat"/>
      <second ref="ArgonInterior"/>
    </subtraction>

    <box name="PMTPlane" lunit="cm" 
      x="$PMTPlane_x" 
      y="$PMTPlane_y" 
      z="$PMTPlane_z"/>

    <box name="Cathode" lunit="cm"
      x="$CPA_x"
      y="$CPA_y"
      z="$CPA_z"/>

    <box name="CathodeStrip" lunit="cm"
      x="$CPAStrip_x"
      y="$CPAStrip_y"
      z="$CPA_z"/>

</solids>
EOF

# Cryostat structure


print CRYO <<EOF;
<structure>
    <volume name="volAlumShell">
      <materialref ref="ALUMINUM_CRYO" />
      <solidref ref="AlumShell" />
    </volume>
    <volume name="volGaseousArgon">
      <materialref ref="ArGas"/>
      <solidref ref="GaseousArgon"/>
    </volume>
    <volume name="volCathodeStrip"> 
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni"/>  
      <solidref ref="CathodeStrip"/>
    </volume>
    <volume name="volCathode">
      <materialref ref="LAr" />
      <solidref ref="Cathode" />
EOF

############################################################################################
#Positioning 64 cathode strips, 2.1 cm high.

$Num_CStrips = 64;
$yCSpos = -($CPA_y-$CPAStrip_pitch)/2;

    for ( $j=0; $j<$Num_CStrips; ++$j ){
      print CRYO <<EOF;
  <physvol>
   <volumeref ref="volCathodeStrip"/>
   <position name="posCStrip$j" unit="cm"  x="0" y="$yCSpos" z="0"/>
  </physvol>
EOF
$yCSpos+= $CPAStrip_pitch;
}
print CRYO <<EOF;
    </volume>
EOF
############################################################################################
print CRYO <<EOF;	
    <volume name="volPMTPlane">
      <materialref ref="LAr"/>
      <solidref ref="PMTPlane"/>
EOF

############################################################################################
#Positioning PMTs: positions from a file

#$PMT_x0 = 0; 
$PMT_x0 = $PMTradiusOuter/2 - $PMTGrid_offset/2 - $PMTtube_x ; 
$PMT_x1 = $PMT_x0 ;
@pmt_pos0 = read_pmt_pos("dispositionPMT.txt", $PMT_x0);
@pmt_pos1 = read_pmt_pos("dispositionPMT.txt", $PMT_x1);
$Num_PMTs0 = @pmt_pos0;

  for ( $i=0; $i<$Num_PMTs0; ++$i ){
   print CRYO <<EOF;
  <physvol>
   <volumeref ref="volOpDetSensitive"/>
   <position name="posPMT0$i" unit="cm" @pmt_pos0[$i]/>
   <rotationref ref="rPlus90AboutY"/>
  </physvol>
  <physvol>
   <volumeref ref="volActiveInnerPMT"/>
   <position name="posPMT_Active0$i" unit="cm" @pmt_pos0[$i]/>
   <rotationref ref="rPlus90AboutY"/>
  </physvol>    
EOF
    }

    for ( $i=0; $i<$Num_PMTs0; ++$i ){
     print CRYO <<EOF;
    <physvol>
     <volumeref ref="volNotOpDetSensitive"/>
     <position name="posPMT1$i" unit="cm" @pmt_pos1[$i]/>
     <rotationref ref="rMinus90AboutY"/>
    </physvol>
    <physvol>
     <volumeref ref="volPassiveInnerPMT"/>
     <position name="posPMT_Passive1$i" unit="cm" @pmt_pos1[$i]/>
     <rotationref ref="rMinus90AboutY"/>
    </physvol> 
EOF
    }
    
############################################################################################
#Positioning Mechanical Structure elements:


$zMpos = -$TPCActive_z/2 + $ext_struct_z/2 ;
$mech_number = 9.; 
for ($im = 0; $im < $mech_number; $im++) 
{
  print CRYO <<EOF;
      <physvol>
        <volumeref ref="volLatMech"/>
        <position name="posLatMech$im" unit="cm" x="0" y="0" z="$zMpos" />
<!--       <rotationref ref="rIdentity" /> -->
      </physvol>
EOF
  $zMpos+= $ext_struct_z ;
}
print CRYO <<EOF;
    </volume>
EOF

############################################################################################
print CRYO <<EOF;
    <volume name="volCryostat">
      <materialref ref="LAr" />
      <solidref ref="Cryostat" />
      <physvol>
        <volumeref ref="volGaseousArgon"/>
    <position name="posGaseousArgon" unit="cm" x="0" y="@{[$LAr_y/2]}" z="0" />
      </physvol>
      <physvol>
        <volumeref ref="volAlumShell"/>
      <position name="posAlumShell" unit="cm" x="0" y="0" z="0"/>
      </physvol>

     <physvol>
       <volumeref ref="volPMTPlane" />
       <position name="posPMTPlane0" unit="cm" x="@{[-$TPC_x - $PMTPlane_x/2 - $PMTWiresOffset ]}" y="$TPCinCryo_y" z="0" />
       <rotationref ref="rPlus180AboutY"/>
     </physvol>

      <physvol>
       <volumeref ref="volTPC0"/>
       <positionref ref="posTPC00inCryo"/>
       <rotationref ref="rIdentity"/>
      </physvol>

      <physvol>
       <volumeref ref="volTPC0"/>
       <positionref ref="posTPC01inCryo"/>
       <rotationref ref="rPlus180AboutX"/>
      </physvol>

      <physvol>
       <volumeref ref="volCathode" />
       <positionref ref="posCathode"/>
      </physvol>

       <physvol>
       <volumeref ref="volTPC0"/>
       <positionref ref="posTPC10inCryo"/>
       <rotationref ref="rPlus180AboutZ"/>
      </physvol>
       
       <physvol>
       <volumeref ref="volTPC0"/>
       <positionref ref="posTPC11inCryo"/>
       <rotationref ref="rPlus180AboutXZ"/>
      </physvol>
      

     <physvol>
       <volumeref ref="volPMTPlane" />
       <position name="posPMTPlane1" unit="cm" x="@{[$TPC_x + $PMTPlane_x/2 + $PMTWiresOffset ]}" y="$TPCinCryo_y" z="0" />
     </physvol>
     
EOF

print CRYO <<EOF;
    </volume>
</structure>
</gdml>
EOF

close(CRYO);
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++ gen_CRT ++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_CRT()
{
# Create the CRT fragment file name,
# add file to list of output GDML fragments,
# and open it

# using a python script to generate the CRT geometry
    $CRTPYTHON="gen_crt_frags_refactored.py";
    my $ret=`python $CRTPYTHON `;
    

    $CRT = "icarus_crt" . $suffix . ".gdml";
    push (@gdmlFiles, $CRT);
# expecting the python script to generate a file "icarus_crt_test.gdml"
#    $CRT = ">" . $CRT;
#    open(CRT) or die("Could not open file $CRT for writing");


close(CRT);
}

#Here we can put sub gen_Crosses() with solids and volumes.
#Then add the box hosting Crosses in sub gen_Enclosure(), first as solids,
#then as volumes. Finally, positioning the crosses in the logical volumes as structures.

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#am+++++++++++++++++++++++ gen_flanges++ +++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_flanges{
    
    $FLAN = "icarus_flanges" . $suffix . ".gdml";
    push (@gdmlFiles, $FLAN); # Add file to list of GDML fragments
    $FLAN = ">" . $FLAN;
    open(FLAN) or die("Could not open file $FLAN for writing");
    

# The standard XML prefix and starting the gdml
print FLAN <<EOF;
<?xml version='1.0'?>
<gdml>
EOF

#All the flanges structure solids. Note: better make the boxes of the size (XZ) of one cryostat.
print FLAN <<EOF;

<!--+++++++++++++++++++ Structure Solids ++++++++++++++++++++++-->

EOF
print FLAN <<EOF;
<solids>
	
    <tube name="CrossCF200"
    rmax="$CrossExtR"
    rmin="$CrossIntR" 
    z="$CrossHeight"
    deltaphi="360"
    aunit="deg"
    lunit="cm"/>

    <box name="Rack" lunit="cm" 
      x="$Rack_x" 
      y="$Rack_y" 
      z="$Rack_z"/>

    <box name="CrossPlane" lunit="cm" 
      x="$CrossPlane_x" 
      y="$CrossPlane_y" 
      z="$CrossPlane_z"/>

</solids>   
EOF

print FLAN <<EOF;
<structure>

<!--+++++++++++++++++ Structure Logical Volumes ++++++++++++++++++++-->

<volume name="volCrossCF200"> 
  <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni"/>  
  <solidref ref="CrossCF200"/>
</volume>
<volume name="volRack"> 
  <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni_Rack"/>  
  <solidref ref="Rack"/>
</volume>    
EOF
    
#######################################################################
#Positioning Crosses and Miniracks

print FLAN <<EOF;   
    <volume name="volCrossPlane">
      <materialref ref="Air"/> 
      <solidref ref="CrossPlane"/>
EOF

$ChimneyInCryo1_x = -138;
$ChimneyInCryo2_x = +138;    
$xCpos1 = $Cryo1InWarmVessel_x + $ChimneyInCryo1_x;
$xCpos2 = $Cryo2InWarmVessel_x - $ChimneyInCryo2_x;
    
$zCpos = -940;
$chimney_row = 20;    
$chimney_col1 = 2;
$chimney_col2 = 4;
$rack_row = 10;
    
#Positioning of crosses on cryo1.
for ($ic = 0; $ic < $chimney_col1; $ic++) 
{
   for ($ir = 0; $ir < $chimney_row; $ir++)
    {
  print FLAN <<EOF;
  <physvol>
   <volumeref ref="volCrossCF200"/>
   <position name="posCrossCF200_$ic_$ir" unit="cm" x="$xCpos1" y="0" z="$zCpos" />
   <rotationref ref="rPlus90AboutX" />
  </physvol>
EOF
  $zCpos+= 100 ;
    }
  $zCpos = -940 ;
  $xCpos1+=  -2*$ChimneyInCryo1_x ;
}

#Positioning of crosses on cryo2.
for ($ic = 2; $ic < $chimney_col2; $ic++) 
{
   for ($ir = 0; $ir < $chimney_row; $ir++)
    {
  print FLAN <<EOF;
  <physvol>
   <volumeref ref="volCrossCF200"/>
   <position name="posCrossCF200_$ic_$ir" unit="cm" x="$xCpos2" y="0" z="$zCpos" />
   <rotationref ref="rPlus90AboutX" />
  </physvol>
EOF
  $zCpos+= 100 ;
    }
  $zCpos = -940 ;
  $xCpos2+=  2*$ChimneyInCryo2_x ;
}

$zCposRack = -890;
$xCpos1 = $Cryo1InWarmVessel_x + $ChimneyInCryo1_x;
$xCpos2 = $Cryo2InWarmVessel_x - $ChimneyInCryo2_x;
    
#Positioning of miniracks on cryo1.
for ($ic = 0; $ic < $chimney_col1; $ic++) 
{
   for ($ir = 0; $ir < $rack_row; $ir++)
    {
  print FLAN <<EOF;
  <physvol>
   <volumeref ref="volRack"/>
   <position name="posRack_$ic_$ir" unit="cm" x="$xCpos1" y="0" z="$zCposRack" />
  </physvol>
EOF
  $zCposRack+= 200 ;
    }
  $zCposRack = -890 ;
  $xCpos1+=  -2*$ChimneyInCryo1_x ;
}

#Positioning of miniracks on cryo2.
for ($ic = 2; $ic < $chimney_col2; $ic++) 
{
   for ($ir = 0; $ir < $rack_row; $ir++)
    {
  print FLAN <<EOF;
  <physvol>
   <volumeref ref="volRack"/>
   <position name="posRack_$ic_$ir" unit="cm" x="$xCpos2" y="0" z="$zCposRack" />
  </physvol>
EOF
  $zCposRack+= 200 ;
    }
  $zCposRack = -890 ;
  $xCpos2+=  2*$ChimneyInCryo2_x ;
}

print FLAN <<EOF;   
</volume>
EOF
############################################################################################
print FLAN <<EOF;
</structure>
EOF

#Close standard XML file
print FLAN <<EOF;
</gdml>
EOF
    
}
#ends gen flanges structure

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++ gen_Enclosure +++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_Enclosure()
{

# Create the detector enclosure fragment file name,
# add file to list of output GDML fragments,
# and open it
    $ENCL = "icarus_DetEnclosure" . $suffix . ".gdml";
    push (@gdmlFiles, $ENCL);
    $ENCL = ">" . $ENCL;
    open(ENCL) or die("Could not open file $ENCL for writing");


# The standard XML prefix and starting the gdml
    print ENCL <<EOF;
<?xml version='1.0'?>
<gdml>
EOF

# All the detector enclosure solids.
print ENCL <<EOF;
<solids>

    <box name="DetEnclosure" lunit="cm" 
      x="$DetEnc_x"
      y="$DetEnc_y"
      z="$DetEnc_z"/>
     
    <box name="Shield" lunit="cm" 
      x="$Shield_x"
      y="$Shield_y"
      z="$Shield_z"/>

    <box name="ThermIns" lunit="cm" 
      x="$ThermIns_x"
      y="$ThermIns_y"
      z="$ThermIns_z"/>

     <box name="Plywood" lunit="cm" 
      x="$Plywood_x"
      y="$Plywood_y"
      z="$Plywood_z"/>

    <box name="WarmVessel" lunit="cm" 
      x="$WarmVessel_x"
      y="$WarmVessel_y"
      z="$WarmVessel_z"/>

    <box name="ShieldInterior" lunit="cm" 
      x="@{[$Shield_x - 2*$ShieldThickness]}"
      y="@{[$Shield_y - 2*$ShieldThickness]}"
      z="@{[$Shield_z - 2*$ShieldThickness]}"/>

    <box name="ThermInsInterior" lunit="cm" 
      x="@{[$ThermIns_x - 2*$FoamPadding]}"
      y="@{[$ThermIns_y - $FoamPadding - $FoamPaddingTop]}"
      z="@{[$ThermIns_z - 2*$FoamPadding]}"/>

    <box name="PlywoodInterior" lunit="cm" 
      x="@{[$Plywood_x - 2*$PlywoodThickness]}"
      y="@{[$Plywood_y - 2*$PlywoodThickness]}"
      z="@{[$Plywood_z - 2*$PlywoodThickness]}"/>

    <box name="WarmVesselInterior" lunit="cm" 
      x="@{[$WarmVessel_x - 2*$WarmVesselThickness_x]}"
      y="@{[$WarmVessel_y - 2*$WarmVesselThickness]}"
      z="@{[$WarmVessel_z - 2*$WarmVesselThickness]}"/>

    <subtraction name="ShieldShell">
      <first ref="Shield"/>
      <second ref="ShieldInterior"/>
    </subtraction>
    
    <subtraction name="ThermInsShell">
      <first ref="ThermIns"/>
      <second ref="ThermInsInterior"/>
      <positionref ref="posThermInsInterior"/>
    </subtraction>

    <subtraction name="PlywoodShell">
      <first ref="Plywood"/>
      <second ref="PlywoodInterior"/>
    </subtraction>

    <subtraction name="WarmVesselShell">
      <first ref="WarmVessel"/>
      <second ref="WarmVesselInterior"/>
    </subtraction>

</solids>
EOF


# Detector enclosure structure    
    print ENCL <<EOF;
<structure>

    <volume name="volShield">
      <materialref ref="ALUMINUM_Al"/> 
      <solidref ref="ShieldShell"/>
    </volume>
    
    <volume name="volThermIns">
      <materialref ref="Polyurethane"/> 
      <solidref ref="ThermInsShell"/>
    </volume>

    <volume name="volPlywood">
      <materialref ref="matPlywood"/> 
      <solidref ref="PlywoodShell"/>
    </volume>
    
    <volume name="volWarmVessel">
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni_WV"/>
      <solidref ref="WarmVesselShell"/>
    </volume>

    <volume name="volDetEnclosure">
      <materialref ref="Air"/>
      <solidref ref="DetEnclosure"/>

    <physvol>
      <volumeref ref="volShield"/>
      <positionref ref="posShieldInDetEncl"/>
    </physvol>
    
    <physvol>
      <volumeref ref="volThermIns"/>
      <positionref ref="posThermInsInDetEncl"/>
    </physvol>

    <physvol>
      <volumeref ref="volPlywood"/>
      <positionref ref="posPlywoodInDetEncl"/>
    </physvol>
    
   <physvol>
      <volumeref ref="volCRT_Shell"/>
      <positionref ref="posCRTShellInDetEncl"/>
    </physvol>

    <physvol>
      <volumeref ref="volWarmVessel"/>
      <positionref ref="posWarmVesselInDetEncl"/>
    </physvol>

    <physvol>
      <volumeref ref="volCrossPlane"/>
      <positionref ref="posCrossPlaneInDetEncl"/>
    </physvol>

    <physvol>
      <volumeref ref="volCryostat"/>
      <positionref ref="posCryo1InWarmVessel"/>
    </physvol>

    <physvol>
      <volumeref ref="volCryostat"/>
      <positionref ref="posCryo2InWarmVessel"/>
    </physvol>

</volume>

</structure>
</gdml>
EOF

close(ENCL);
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++ gen_Floor +++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_Floor()
{

# Create the FLOOR fragment file name,
# add file to list of output GDML fragments,
# and open it
    $FLOOR = "icarus_Floor" . $suffix . ".gdml";
    push (@gdmlFiles, $FLOOR);
    $FLOOR = ">" . $FLOOR;
    open(FLOOR) or die("Could not open file $FLOOR for writing");


# The standard XML prefix and starting the gdml
    print FLOOR <<EOF;
<?xml version='1.0'?>
<gdml>
EOF


# All the Floor solids.
print FLOOR <<EOF;
<solids>

   <box name="FloorContainer" lunit="cm" 
      x="$FloorBox1_x " 
      y="@{[$FloorBox1_y + $FloorBox2_y + $FloorBox4_y ]}" 
      z="$FloorBox1_z"/>  
      
   <box name="FloorContainerAir" lunit="cm" 
      x="$FloorBox3air_x" 
      y="@{[$FloorBox1_y + $FloorBox2_y + $FloorBox4_y ]}" 
      z="$FloorBox3air_z"/>  
                          
   <box name="FloorBox1" lunit="cm" 
      x="$FloorBox1_x " 
      y="$FloorBox1_y" 
      z="$FloorBox1_z"/>
      
   <box name="FloorBox1air" lunit="cm" 
      x="$FloorBox1air_x " 
      y="$FloorBox1air_y" 
      z="$FloorBox1air_z"/>      
 
    <box name="FloorBox2" lunit="cm" 
      x="$FloorBox2_x " 
      y="$FloorBox2_y" 
      z="$FloorBox2_z"/>
      
   <box name="FloorBox2air" lunit="cm" 
      x="$FloorBox2air_x " 
      y="$FloorBox2air_y" 
      z="$FloorBox2air_z"/>       
      
    <box name="FloorBox3" lunit="cm" 
      x="$FloorBox3_x " 
      y="$FloorBox3_y" 
      z="$FloorBox3_z"/>
      
   <box name="FloorBox3air" lunit="cm" 
      x="$FloorBox3air_x " 
      y="$FloorBox3air_y" 
      z="$FloorBox3air_z"/>      
      
    <box name="FloorBox4" lunit="cm" 
      x="$FloorBox4_x " 
      y="$FloorBox4_y" 
      z="$FloorBox4_z"/>  
                   
   <box name="FloorBox4air" lunit="cm" 
      x="$FloorBox4air_x " 
      y="$FloorBox4air_y" 
      z="$FloorBox4air_z"/> 
           

    <subtraction name="FloorComplete">
     <first ref="FloorContainer"/>
     <second ref="FloorContainerAir"/>
     <position name="posFloorContainerAir" unit="cm" x="0" y="0" z="$posOpenBuildingFloor"/>
     </subtraction> 
                        
    <subtraction name="BuildingFloor_1final">
     <first ref="FloorBox1"/>
     <second ref="FloorBox1air"/>
     <position name="posFloorBox1Air" unit="cm" x="0" y="0" z="$posOpenBuildingFloor"/>
     </subtraction>   
                
    <subtraction name="BuildingFloor_2final">
     <first ref="FloorBox2"/>
     <second ref="FloorBox2air"/>
     <position name="posFloorBox2Air" unit="cm" x="0" y="0" z="$posOpenBuildingFloor"/>
     </subtraction>  
      
   <subtraction name="BuildingFloor_3final">
     <first ref="FloorBox3"/>
     <second ref="FloorBox3air"/>
     <position name="posFloorBox3Air" unit="cm" x="0" y="0" z="0"/>
     </subtraction> 
     
   <subtraction name="BuildingFloor_4final">
     <first ref="FloorBox4"/>
     <second ref="FloorBox4air"/>
     <position name="posFloorBox4Air" unit="cm" x="0" y="0" z="$posOpenBuildingFloor"/>
     </subtraction>           
                                                   
</solids>
EOF

# Floor structure
print FLOOR <<EOF;
<structure>
     
   <volume name="volBuildingFloor_1final" >
      <materialref ref="Concrete"/>
      <solidref ref="BuildingFloor_1final"/>     
    </volume>  
    
   <volume name="volBuildingFloor_2final" >
      <materialref ref="CA6_Floor"/>
      <solidref ref="BuildingFloor_2final"/>     
    </volume>
    
    <volume name="volBuildingFloor_3final" >
      <materialref ref="Concrete"/>
      <solidref ref="BuildingFloor_3final"/>     
    </volume>       
     
    <volume name="volBuildingFloor_4final" >
      <materialref ref="Concrete"/>
      <solidref ref="BuildingFloor_4final"/>            
EOF

#Complete Floor
print FLOOR <<EOF;
</volume>

 <volume name="volFloorComplete" >
      <materialref ref="Air"/>
      <solidref ref="FloorComplete"/>
                              
   <physvol>
    <volumeref ref="volBuildingFloor_4final"/>
    <position name="posBuildingFloor4InBuilding" unit="cm" x="0" y="@{[0.5 * ($FloorBox1_y + $FloorBox2_y + $FloorBox4_y) - 0.5*$FloorBox4_y]}" z="0" />
   </physvol>           
  
   <physvol>
    <volumeref ref="volBuildingFloor_2final"/>
    <position name="posBuildingFloor2InBuilding" unit="cm" x="0" y="@{[0.5 * ($FloorBox1_y + $FloorBox2_y + $FloorBox4_y) - $FloorBox4_y - 0.5*$FloorBox2_y]} " z="0" />
   </physvol>     
    
   <physvol>
    <volumeref ref="volBuildingFloor_3final"/>
    <position name="posBuildingFloor3InBuilding" unit="cm" x="0" y="@{[0.5 * ($FloorBox1_y + $FloorBox2_y + $FloorBox4_y) - $FloorBox4_y - 0.5*$FloorBox3_y]}" z="$posOpenBuildingFloor" />
   </physvol>        
                                   
   <physvol>
    <volumeref ref="volBuildingFloor_1final"/>
    <position name="posBuildingFloor1InBuilding" unit="cm" x="0" y="@{[0.5 * ($FloorBox1_y + $FloorBox2_y + $FloorBox4_y) - $FloorBox4_y - $FloorBox2_y - 0.5*$FloorBox1_y]}" z="0" />
   </physvol>            
                     
    </volume>
</structure>
</gdml>
EOF



close(FLOOR);
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++ gen_World +++++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

sub gen_World()
{

# Create the WORLD fragment file name,
# add file to list of output GDML fragments,
# and open it
    $WORLD = "icarus_World" . $suffix . ".gdml";
    push (@gdmlFiles, $WORLD);
    $WORLD = ">" . $WORLD;
    open(WORLD) or die("Could not open file $WORLD for writing");


# The standard XML prefix and starting the gdml
    print WORLD <<EOF;
<?xml version='1.0'?>
<gdml>
EOF


# All the World solids.
print WORLD <<EOF;
<solids>
    <box name="World" lunit="cm" 
      x="$World_x" 
      y="$World_y" 
      z="$World_z"/>

    <box name="Overburden" lunit="cm" 
      x="$Overburden_x" 
      y="$Overburden_y"   
      z="$Overburden_z"/>

    <box name="Building_ext" lunit="cm" 
      x="$Hall_x" 
      y="$Building_y" 
      z="$Hall_z"/>
      
    <box name="AirBuilding_ext" lunit="cm" 
      x="@{[$Hall_x - 2*$BuildingAlSkin ]}" 
      y="$Building_y  "
      z="@{[$Hall_z - 2*$BuildingAlSkin ]}"/>

    <subtraction name="WallBuildingAl_Ext">
     <first ref="Building_ext"/>
     <second ref="AirBuilding_ext"/>
    <position name="posAirBuildingExt" unit="cm" x="0" y="0" z="0"/> 
     </subtraction>

    <box name="Building_middle" lunit="cm" 
      x="@{[$Hall_x - 2*$BuildingAlSkin]}" 
      y="$Building_y" 
      z="@{[$Hall_z- 2*$BuildingAlSkin]}"/>
      
    <box name="AirBuilding_middle" lunit="cm" 
      x="@{[$Hall_x - 2*$BuildingAlSkin - 2*$BuildingInsSkin ]}" 
      y="$Building_y  "
      z="@{[$Hall_z - - 2*$BuildingAlSkin - 2*$BuildingInsSkin ]}"/>

    <subtraction name="WallBuildingInsulation">
     <first ref="Building_middle"/>
     <second ref="AirBuilding_middle"/>
    <position name="posAirBuildingMiddle" unit="cm" x="0" y="0" z="0"/> 
     </subtraction>
     
    <box name="Building_int" lunit="cm" 
      x="@{[$Hall_x - 2*$BuildingAlSkin - 2*$BuildingInsSkin ]}" 
      y="$Building_y" 
      z="@{[$Hall_z- 2*$BuildingAlSkin - 2*$BuildingInsSkin]}"/>
     
    <box name="AirBuilding_int" lunit="cm" 
      x="@{[$Hall_x - 4*$BuildingAlSkin - 2*$BuildingInsSkin]}" 
      y="$Building_y  "
      z="@{[$Hall_z - 4*$BuildingAlSkin - 2*$BuildingInsSkin]}"/>

    <subtraction name="WallBuildingAl_Int">
     <first ref="Building_int"/>
     <second ref="AirBuilding_int"/>
    <position name="posAirBuildingInt" unit="cm" x="0" y="0" z="0"/> 
     </subtraction>
     
    <box name="RoofMembrane" lunit="cm" 
      x="$Roof_x" 
      y="$RoofMembrane_y" 
      z="$Roof_z"/> 
      
    <box name="RoofTopIns" lunit="cm" 
      x="$Roof_x" 
      y="$RoofTopIns_y" 
      z="$Roof_z"/> 
      
    <box name="RoofBottomIns" lunit="cm" 
      x="$Roof_x" 
      y="$RoofBottomIns_y" 
      z="$Roof_z"/> 
      
    <box name="RoofMetalDeck" lunit="cm" 
      x="$Roof_x" 
      y="$RoofMetalDeck_y" 
      z="$Roof_z"/>                  
         
    <box name="ExpHall" lunit="cm" 
      x="$Hall_x" 
      y="$ExpHall_y" 
      z="$Hall_z"/>

    <box name="AirExpHall" lunit="cm" 
      x="@{[$Hall_x - 2*$HallWallThickness]}" 
      y="@{[$ExpHall_y - $Pit_Floor_y]}" 
      z="@{[$Hall_z - 2*$HallWallThickness]}"/>

    <subtraction name="WallExpHall_1">
     <first ref="ExpHall"/>
     <second ref="AirExpHall"/>
     <position name="posAirExpHall1" unit="cm" x="0" y="@{[$Pit_Floor_y/2]}" z="0"/>
     </subtraction>
     
   <box name="Reinforced_pitfloor" lunit="cm" 
      x="$Hall_x" 
      y="$ReinforcedPitFloor_y" 
      z="$Hall_z"/> 
      
 <union name="WallExpHall">
  <first ref="WallExpHall_1"/>
  <second ref="Reinforced_pitfloor"/>
   <position name="posReinforcedFloor_ExpHall" unit="cm" x="0" y="@{[-$ExpHall_y/2 - $ReinforcedPitFloor_y/2]}" z="0"/>
 </union>    
                                           
    <box name="BoxDirt" lunit="cm" 
      x="@{[$World_x]}" 
      y="@{[$World_y/2 + $Ground_y - $ShiftRespectCryo_y]}" 
      z="@{[$World_z]}"/>     
     
     <subtraction name="DirtUnderground1">
     <first  ref="BoxDirt"/>
     <second ref="ExpHall"/>
     <position name="posExpHallUnderground" unit="cm" x="0" y="@{[0.5*($World_y/2 + $Ground_y - $ShiftRespectCryo_y)- $ExpHall_y/2]}" z="$Hall_shift_z"/> 
     </subtraction>
     
     <subtraction name="DirtUnderground">
     <first  ref="DirtUnderground1"/>
     <second ref="Reinforced_pitfloor"/>
     <position name="posReinforcedFloorUnderground" unit="cm" x="0" y="@{[0.5*($World_y/2 + $Ground_y - $ShiftRespectCryo_y) - $ExpHall_y - $ReinforcedPitFloor_y/2]}" z="$Hall_shift_z"/> 
     </subtraction>     
     
</solids>
EOF

# World structure: Building + underground experimental hall + detector

print WORLD <<EOF;
<structure>
EOF

#Building: building + overburden

print WORLD <<EOF;
    <volume name="volOverburden" >
      <materialref ref="Concrete"/>
      <solidref ref="Overburden"/>
    </volume>


    <volume name="volWallBuildingAl_Ext" >
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni"/>
      <solidref ref="WallBuildingAl_Ext"/>
     </volume>
     
    <volume name="volWallBuildingInsulation" >
      <materialref ref="Polyurethane"/>
      <solidref ref="WallBuildingInsulation"/>
     </volume>

    <volume name="volWallBuildingAl_Int" >
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni"/>
      <solidref ref="WallBuildingAl_Int"/>
     </volume>     
     
    <volume name="volRoofMembrane" >
      <materialref ref="asphalt"/>
      <solidref ref="RoofMembrane"/>
     </volume>
     
    <volume name="volRoofTopIns" >
      <materialref ref="Perlite"/>
      <solidref ref="RoofTopIns"/>
     </volume>     

    <volume name="volRoofBottomIns" >
      <materialref ref="Polyisocyanurate"/>
      <solidref ref="RoofBottomIns"/>
     </volume>

    <volume name="volRoofMetalDeck" >
      <materialref ref="STEEL_STAINLESS_Fe7Cr2Ni"/>
      <solidref ref="RoofMetalDeck"/>
      
EOF


#Experimental hall: experimental hall + ground around it

print WORLD <<EOF; 
</volume>

    <volume name="volWallExpHall" >
      <materialref ref="Concrete"/>
      <solidref ref="WallExpHall"/>
   </volume>

    <volume name="volDirtUnderground" >
      <materialref ref="CA7_underground"/>
      <solidref ref="DirtUnderground"/>
    </volume>
        
EOF

#Complete world: building + underground parts + detector
print WORLD <<EOF;


    <volume name="volWorld" >
      <materialref ref="Air"/>
      <solidref ref="World"/>
    
   <physvol>
    <volumeref ref="volRoofMembrane"/> 
    <positionref ref="posRoofMembraneinWorld"/> 
    </physvol>
    
   <physvol>
    <volumeref ref="volRoofTopIns"/> 
    <positionref ref="posRoofTopInsinWorld"/> 
    </physvol>

   <physvol>
    <volumeref ref="volRoofBottomIns"/> 
    <positionref ref="posRoofBottomInsinWorld"/> 
    </physvol>     

   <physvol>
    <volumeref ref="volRoofMetalDeck"/> 
    <positionref ref="posRoofMetalDeckinWorld"/> 
    </physvol>
    
    <physvol>
    <volumeref ref="volWallBuildingAl_Ext"/> 
    <positionref ref="posBuildingAlExtInWorld"/>
    </physvol>
    
  <physvol>
    <volumeref ref="volWallBuildingInsulation"/> 
    <positionref ref="posBuildingInsInWorld"/>
    </physvol>
    
   <physvol>
    <volumeref ref="volWallBuildingAl_Int"/> 
    <positionref ref="posBuildingAlIntInWorld"/>
    </physvol>    
            
   <physvol>
    <volumeref ref="volOverburden"/>
    <position name="posOverburden" unit="cm" x="$posOverburden_x" y="@{[$Ground_y - $posOverburden_y + 0.5*$Overburden_y - $ShiftRespectCryo_y]}" z="@{[-0.5*$FloorBox1_z + $Hall_shift_z + 0.5*$Overburden_z + $posOverburden_z + $Gap_overburden_BuildingFloor]}" />            
    </physvol>   
    
   <physvol>
    <volumeref ref="volFloorComplete"/>
    <position name="posFloorCompleteInWorld" unit="cm" x="$posOverburden_x" y="@{[$Ground_y - 0.5*($FloorBox1_y + $FloorBox2_y + $FloorBox4_y) - $ShiftRespectCryo_y]}" z="$Hall_shift_z" />            
    </physvol>             
    
    <physvol>
    <volumeref ref="volWallExpHall"/>
    <positionref ref="posExpHallInWorld"/>
    </physvol>
        
   <physvol>
    <volumeref ref="volDetEnclosure"/>
    <positionref ref="posDetEncInWorld"/>
    </physvol>
        
    <physvol>
    <volumeref ref="volDirtUnderground"/>
    <position name="posBoxDirtinWorld" unit="cm" x="$OriginXSet" y="@{[-$World_y/2+0.5*($World_y/2 + $Ground_y - $ShiftRespectCryo_y)]}" z="$OriginZSet"/>
    </physvol>
         
    </volume>
</structure>
</gdml>
EOF


# make_gdml.pl will take care of <setup/>

close(WORLD);
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++ write_fragments ++++++++++++++++++++++++++++++++++++
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


sub write_fragments()
{
   # This subroutine creates an XML file that summarizes the the subfiles output
   # by the other sub routines - it is the input file for make_gdml.pl which will
   # give the final desired GDML file. Specify its name with the output option.
   # (you can change the name when running make_gdml)

   # This code is taken straigh from the similar MicroBooNE generate script, Thank you.

    if ( ! defined $output )
    {
	$output = "-"; # write to STDOUT 
    }

    # Set up the output file.
    $OUTPUT = ">" . $output;
    open(OUTPUT) or die("Could not open file $OUTPUT");

    print OUTPUT <<EOF;
<?xml version='1.0'?>

<!-- Input to Geometry/gdml/make_gdml.pl; define the GDML fragments
     that will be zipped together to create a detector description. 
     -->

<config>

   <constantfiles>

      <!-- These files contain GDML <constant></constant>
           blocks. They are read in separately, so they can be
           interpreted into the remaining GDML. See make_gdml.pl for
           more information. 
	   -->
	   
EOF

    foreach $filename (@defFiles)
    {
	print OUTPUT <<EOF;
      <filename> $filename </filename>
EOF
    }

    print OUTPUT <<EOF;

   </constantfiles>

   <gdmlfiles>

      <!-- The GDML file fragments to be zipped together. -->

EOF

    foreach $filename (@gdmlFiles)
    {
	print OUTPUT <<EOF;
      <filename> $filename </filename>
EOF
    }

    print OUTPUT <<EOF;

   </gdmlfiles>

</config>
EOF

    close(OUTPUT);
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
sub read_pmt_pos {

  $pmt_x = $_[1];

  $PMT_pos_file = $_[0];
  open(PMTPOS, $PMT_pos_file) or die("Could not open file $PMT_pos_file.");

  @pmt_pos = ();

  foreach $line (<PMTPOS>) {

    @coord = split(/\s/, $line);

    $string = " x=\" $pmt_x\" y=\"$coord[1]\" z=\"$coord[0]\"";
    push(@pmt_pos, $string);

  }

  close(PMTPOS);

  return @pmt_pos;
}

