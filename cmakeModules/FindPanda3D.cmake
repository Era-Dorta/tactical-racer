#------------------------------------------------------------------------------
# CMake Module for finding Panda3D
#------------------------------------------------------------------------------

# We need Python's headers
find_package(PythonLibs REQUIRED)

# Find the path of the Panda includes
find_path(PANDA3D_INCLUDE_DIR pandaFramework.h
	/opt/local/include/panda3d
	/usr/local/include/panda3d
	/usr/include/panda3d
)

# Find the path of the panda library
find_library(PANDA3D_LIBPANDA_LIBRARY
	NAMES panda
	PATHS
	/usr/local/lib/panda3d
	/usr/lib/panda3d
)

# Get just the path
get_filename_component(PANDA3D_LIBS_DIR ${PANDA3D_LIBPANDA_LIBRARY} PATH)

# Add our python to the build system
include_directories(${PYTHON_INCLUDE_DIR})

set(PANDA3D_LIBS
	p3framework
	panda
	pandafx
	pandaexpress
	p3dtoolconfig
	p3dtool
	p3pystub
	p3direct	
	#pandaphysics
	#pandaegg
	#p3vision
	#pandaskel
	#p3openal_audio
	#p3tinydisplay
	#p3ptloader
	#pandagl
)
