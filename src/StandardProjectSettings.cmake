# Set a default build type if none was specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  message(STATUS "Setting build type to 'RelWithDebInfo' as none was specified.")
  set(CMAKE_BUILD_TYPE
      RelWithDebInfo
      CACHE STRING "Choose the type of build." FORCE)
  # Set the possible values of build type for cmake-gui, ccmake
  set_property(
    CACHE CMAKE_BUILD_TYPE
    PROPERTY STRINGS
             "Debug"
             "Release"
             "MinSizeRel"
             "RelWithDebInfo")
endif()

# Generate compile_commands.json to make it easier to work with clang based tools
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Enhance error reporting and compiler messages
if(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
  if(WIN32)
    # On Windows cuda nvcc uses cl and not clang
    add_compile_options($<$<COMPILE_LANGUAGE:C>:-fcolor-diagnostics> $<$<COMPILE_LANGUAGE:CXX>:-fcolor-diagnostics>)
  else()
    add_compile_options(-fcolor-diagnostics)
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  if(WIN32)
    # On Windows cuda nvcc uses cl and not gcc
    add_compile_options($<$<COMPILE_LANGUAGE:C>:-fdiagnostics-color=always>
                        $<$<COMPILE_LANGUAGE:CXX>:-fdiagnostics-color=always>)
  else()
    add_compile_options(-fdiagnostics-color=always)
  endif()
elseif(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND MSVC_VERSION GREATER 1900)
  add_compile_options(/diagnostics:column)
else()
  message(STATUS "No colored compiler diagnostic set for '${CMAKE_CXX_COMPILER_ID}' compiler.")
endif()

# if the default CMAKE_CXX_STANDARD is not set detect the latest CXX standard supported by the compiler and use it
# this is needed for the tools like clang-tidy, cppcheck, etc.
# Ideally, the user should read the warning and set a default CMAKE_CXX_STANDARD for their project
# Like not having compiler warnings on by default, this fixes another `bad` default for the compilers
if("${CMAKE_CXX_STANDARD}" STREQUAL "")
  if(DEFINED CMAKE_CXX20_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_CXX20_EXTENSION_COMPILE_OPTION)
    set(CXX_LATEST_STANDARD 20)
  elseif(DEFINED CMAKE_CXX17_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_CXX17_EXTENSION_COMPILE_OPTION)
    set(CXX_LATEST_STANDARD 17)
  elseif(DEFINED CMAKE_CXX14_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_CXX14_EXTENSION_COMPILE_OPTION)
    set(CXX_LATEST_STANDARD 14)
  else()
    set(CXX_LATEST_STANDARD 11)
  endif()
  message(
    STATUS
      "The default CMAKE_CXX_STANDARD used by external targets and tools is not set yet. Using the latest supported C++ standard that is ${CXX_LATEST_STANDARD}"
  )
  set(CMAKE_CXX_STANDARD ${CXX_LATEST_STANDARD})
endif()

if("{CMAKE_C_STANDARD}" STREQUAL "")
  if(DEFINED CMAKE_C17_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_C17_EXTENSION_COMPILE_OPTION)
    set(C_LATEST_STANDARD 17)
  elseif(DEFINED CMAKE_C11_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_C11_EXTENSION_COMPILE_OPTION)
    set(C_LATEST_STANDARD 11)
  elseif(DEFINED CMAKE_C99_STANDARD_COMPILE_OPTION OR DEFINED CMAKE_C99_EXTENSION_COMPILE_OPTION)
    set(C_LATEST_STANDARD 99)
  else()
    set(C_LATEST_STANDARD 90)
  endif()
  message(
    STATUS
      "The default CMAKE_C_STANDARD used by external targets and tools is not set yet. Using the latest supported C standard that is ${C_LATEST_STANDARD}"
  )
  set(CMAKE_C_STANDARD ${C_LATEST_STANDARD})
endif()

# strongly encouraged to enable this globally to avoid conflicts between
# -Wpedantic being enabled and -std=c++xx and -std=gnu++xx when compiling with PCH enabled
if("${CMAKE_CXX_EXTENSIONS}" STREQUAL "")
  set(CMAKE_CXX_EXTENSIONS OFF)
endif()

if("${CMAKE_C_EXTENSIONS}" STREQUAL "")
  set(CMAKE_C_EXTENSIONS OFF)
endif()

# run vcvarsall when msvc is used
include("${ProjectOptions_SRC_DIR}/VCEnvironment.cmake")
run_vcvarsall()
