include_guard()

#[[.rst:

.. include:: ../../docs/src/dynamic_project_options.md
   :parser: myst_parser.sphinx_

#]]
macro(dynamic_project_options)
  option(ENABLE_DEVELOPER_MODE "Set up defaults for a developer of the project, and let developer change options" OFF)
  if(NOT ${ENABLE_DEVELOPER_MODE})
    message(
      STATUS
        "Developer mode is OFF. For developement, use `-DENABLE_DEVELOPER_MODE:BOOL=ON`. Building the project for the end-user..."
    )
  else()
    message(
      STATUS
        "Developer mode is ON. For production, use `-DENABLE_DEVELOPER_MODE:BOOL=OFF`. Building the project for the developer..."
    )
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND NOT WIN32)
    set(SUPPORTS_UBSAN ON)
  else()
    set(SUPPORTS_UBSAN OFF)
  endif()

  if((CMAKE_CXX_COMPILER_ID MATCHES ".*Clang.*" OR CMAKE_CXX_COMPILER_ID MATCHES ".*GNU.*") AND WIN32)
    set(SUPPORTS_ASAN OFF)
  else()
    set(SUPPORTS_ASAN ON)
  endif()

  # ccache, clang-tidy, cppcheck are only supported with Ninja and Makefile based generators
  # note that it is possible to use Ninja with cl, so this still allows clang-tidy on Windows
  # with CL.
  #
  # We are only setting the default options here. If the user attempts to enable
  # these tools on a platform with unknown support, they are on their own.
  #
  # Also note, cppcheck has an option to be run on VCproj files, so we should investigate that
  # Further note: MSVC2022 has builtin support for clang-tidy, but I can find
  # no way to enable that via CMake
  if(CMAKE_GENERATOR MATCHES ".*Makefile*." OR CMAKE_GENERATOR MATCHES ".*Ninja*")
    set(MAKEFILE_OR_NINJA ON)
  else()
    set(MAKEFILE_OR_NINJA OFF)
  endif()

  include(CMakeDependentOption)

  # <option name>;<user mode default>;<developer mode default>;<description>
  set(options
      "ENABLE_CACHE\;${MAKEFILE_OR_NINJA}\;${MAKEFILE_OR_NINJA}\;Enable ccache on Unix"
      "WARNINGS_AS_ERRORS\;OFF\;ON\;Treat warnings as Errors"
      "ENABLE_CLANG_TIDY\;OFF\;${MAKEFILE_OR_NINJA}\;Enable clang-tidy analysis during compilation"
      "ENABLE_VS_ANALYSIS\;ON\;ON\;Enable Visual Studio IDE code analysis if the generator is Visual Studio."
      "ENABLE_CONAN\;OFF\;OFF\;Automatically integrate Conan for package management"
      "ENABLE_COVERAGE\;OFF\;OFF\;Analyze and report on coverage"
      "ENABLE_SANITIZER_ADDRESS\;OFF\;${SUPPORTS_ASAN}\;Make memory errors into hard runtime errors (windows/linux/macos)"
      "ENABLE_SANITIZER_UNDEFINED_BEHAVIOR\;OFF\;${SUPPORTS_UBSAN}\;Make certain types (numeric mostly) of undefined behavior into runtime errors"
      "ENABLE_CPPCHECK\;OFF\;${MAKEFILE_OR_NINJA}\;Enable cppcheck analysis during compilation"
      "ENABLE_INTERPROCEDURAL_OPTIMIZATION\;OFF\;OFF\;Enable whole-program optimization (e.g. LTO)"
      "ENABLE_NATIVE_OPTIMIZATION\;OFF\;OFF\;Enable the optimizations specific to the build machine (e.g. SSE4_1, AVX2, etc.)."
      "DISABLE_EXCEPTIONS\;OFF\;OFF\;Disable Exceptions (no-exceptions and no-unwind-tables flag)"
      "DISABLE_RTTI\;OFF\;OFF\;Disable RTTI (no-rtti flag)"
      "ENABLE_INCLUDE_WHAT_YOU_USE\;OFF\;OFF\;Enable include-what-you-use analysis during compilation"
      "ENABLE_PCH\;OFF\;OFF\;Enable pre-compiled-headers support"
      "ENABLE_DOXYGEN\;OFF\;OFF\;Build documentation with Doxygen"
      "ENABLE_BUILD_WITH_TIME_TRACE\;OFF\;OFF\;Generates report of where compile-time is spent"
      "ENABLE_UNITY\;OFF\;OFF\;Merge C++ files into larger C++ files, can speed up compilation sometimes"
      "ENABLE_SANITIZER_LEAK\;OFF\;OFF\;Make memory leaks into hard runtime errors"
      "ENABLE_SANITIZER_THREAD\;OFF\;OFF\;Make thread race conditions into hard runtime errors"
      "ENABLE_SANITIZER_MEMORY\;OFF\;OFF\;Make other memory errors into runtime errors")

  foreach(option ${options})
    list(
      GET
      option
      0
      option_name)
    list(
      GET
      option
      1
      option_user_default)
    list(
      GET
      option
      2
      option_developer_default)
    list(
      GET
      option
      3
      option_description)

    if(DEFINED ${option_name}_DEFAULT)
      if(DEFINED ${option_name}_DEVELOPER_DEFAULT OR DEFINED ${option_name}_USER_DEFAULT)
        message(
          SEND_ERROR
            "You have separately defined user/developer defaults and general defaults for ${option_name}. Please either provide a general default OR separate developer/user overrides"
        )
      endif()

      set(option_user_default ${${option_name}_DEFAULT})
      set(option_developer_default ${${option_name}_DEFAULT})
    endif()

    if(DEFINED ${option_name}_USER_DEFAULT)
      set(option_user_default ${${option_name}_USER_DEFAULT})
    endif()

    if(DEFINED ${option_name}_DEVELOPER_DEFAULT)
      set(option_developer_default ${${option_name}_DEVELOPER_DEFAULT})
    endif()

    if(OPT_${option_name})
      if(ENABLE_DEVELOPER_MODE)
        set(option_implicit_default ${option_developer_default})
      else()
        set(option_implicit_default ${option_user_default})
      endif()
      option(OPT_${option_name} "${option_description}" ${option_implicit_default})
    else()
      cmake_dependent_option(
        OPT_${option_name}
        "${option_description}"
        ${option_developer_default}
        ENABLE_DEVELOPER_MODE
        ${option_user_default})
    endif()

    if(OPT_${option_name})
      set(${option_name}_VALUE ${option_name})
    else()
      unset(${option_name}_VALUE)
    endif()
  endforeach()

  project_options(
    ${ENABLE_CONAN_VALUE}
    ${ENABLE_CACHE_VALUE}
    ${WARNINGS_AS_ERRORS_VALUE}
    ${ENABLE_CPPCHECK_VALUE}
    ${ENABLE_CLANG_TIDY_VALUE}
    ${ENABLE_VS_ANALYSIS_VALUE}
    ${ENABLE_COVERAGE_VALUE}
    ${ENABLE_INTERPROCEDURAL_OPTIMIZATION_VALUE}
    ${ENABLE_NATIVE_OPTIMIZATION_VALUE}
    ${DISABLE_EXCEPTIONS_VALUE}
    ${DISABLE_RTTI_VALUE}
    ${ENABLE_INCLUDE_WHAT_YOU_USE_VALUE}
    ${ENABLE_PCH_VALUE}
    ${ENABLE_DOXYGEN_VALUE}
    ${ENABLE_BUILD_WITH_TIME_TRACE_VALUE}
    ${ENABLE_UNITY_VALUE}
    ${ENABLE_SANITIZER_ADDRESS_VALUE}
    ${ENABLE_SANITIZER_LEAK_VALUE}
    ${ENABLE_SANITIZER_UNDEFINED_BEHAVIOR_VALUE}
    ${ENABLE_SANITIZER_THREAD_VALUE}
    ${ENABLE_SANITIZER_MEMORY_VALUE}
    ${ARGN})
endmacro()
