# official shared software
add_subdirectory(helpers)

# examples
foreach(ExampleDir IN ITEMS galleryAnalysis DetectorActivityRatePlots )
  
  # take *all* the files from the listed directory
  file(GLOB_RECURSE GalleryExamples RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${ExampleDir}/* )
  
  # cet_install_files() will reproduce the intermediate subdirectories from the
  # source list into the destination directory
## FIXME:  replace with install() as cet_install_files is no longer available
##  cet_install_files(
##    LIST ${GalleryExamples}
##    DIRNAME examples/gallery/${ExampleDir}
##    )
  
endforeach()

# other stuff
add_subdirectory(MCTruthBase)

