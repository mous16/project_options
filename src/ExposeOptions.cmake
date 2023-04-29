include_guard()

function(expose_dynamic_option option_exposed)
  set(options
      "WARNINGS_AS_ERRORS\;0\;Treat warnings as Errors"
      "ENABLE_COVERAGE\;0\;Analyze and report on coverage"
      "ENABLE_CPPCHECK\;0\;Enable cppcheck analysis during compilation"
      "ENABLE_CLANG_TIDY\;0\;Enable clang-tidy analysis during compilation"
      "ENABLE_VS_ANALYSIS\;0\;Enable Visual Studio IDE code analysis if the generator is Visual Studio."
      "ENABLE_INCLUDE_WHAT_YOU_USE\;0\;Enable include-what-you-use analysis during compilation"
      "ENABLE_CACHE\;0\;Enable ccache on Unix"
      "ENABLE_PCH\;0\;Enable pre-compiled-headers support"
      "ENABLE_CONAN\;0\;Automatically integrate Conan for package management"
      "ENABLE_VCPKG\;0\;Automatically integrate vcpkg for package management"
      "ENABLE_DOXYGEN\;0\;Build documentation with Doxygen"
      "ENABLE_INTERPROCEDURAL_OPTIMIZATION\;0\;Enable whole-program optimization (e.g. LTO)"
      "ENABLE_NATIVE_OPTIMIZATION\;0\;Enable the optimizations specific to the build machine (e.g. SSE4_1, AVX2, etc.)."
      "DISABLE_EXCEPTIONS\;0\;Disable Exceptions (no-exceptions and no-unwind-tables flag)"
      "DISABLE_RTTI\;0\;Disable RTTI (no-rtti flag)"
      "ENABLE_BUILD_WITH_TIME_TRACE\;0\;Generates report of where compile-time is spent"
      "ENABLE_UNITY\;0\;Merge C++ files into larger C++ files, can speed up compilation sometimes"
      "ENABLE_SANITIZER_ADDRESS\;0\;Make memory errors into hard runtime errors (windows/linux/macos)"
      "ENABLE_SANITIZER_LEAK\;0\;Make memory leaks into hard runtime errors"
      "ENABLE_SANITIZER_UNDEFINED_BEHAVIOR\;0\;Make certain types (numeric mostly) of undefined behavior into runtime errors"
      "ENABLE_SANITIZER_THREAD\;0\;Make thread race conditions into hard runtime errors"
      "ENABLE_SANITIZER_MEMORY\;0\;Make other memory errors into runtime errors"
      "LINKER\;1\;Choose a specific linker"
      "VS_ANALYSIS_RULESET\;1\;Override the defaults for the code analysis rule set in Visual Studio"
      "CONAN_PROFILE\;1\;Use specific Conan profile"
      "CONAN_HOST_PROFILE\;1\;Use specific Conan host profile"
      "CONAN_BUILD_PROFILE\;1\;Use specific Conan build profile"
      "DOXYGEN_THEME\;2\;Name of the Doxygen theme to use"
      "MSVC_WARNINGS\;2\;Override the defaults for the MSVC warnings"
      "CLANG_WARNINGS\;2\;Override the defaults for the CLANG warnings"
      "GCC_WARNINGS\;2\;Override the defaults for the GCC warnings"
      "CUDA_WARNINGS\;2\;Override the defaults for the CUDA warnings"
      "CPPCHECK_OPTIONS\;2\;Override the defaults for the options passed to cppcheck"
      "CLANG_TIDY_EXTRA_ARGUMENTS\;2\;Additiona arguments to use for clang-tidy invokation"
      "PCH_HEADERS\;2\;List of the headers to precompile"
      "CONAN_OPTIONS\;2\;Extra Conan options")

  set(option_found false)
  foreach(option ${options})
    list(
      GET
      option
      0
      option_name)

    string(
      COMPARE EQUAL
              "${option_exposed}"
              "${option_name}"
              option_found)
    if(NOT option_found)
      continue()
    endif()

    list(
      GET
      option
      1
      option_type)
    list(
      GET
      option
      2
      option_description)
    break()
  endforeach()

  if(NOT option_found)
    message(SEND_ERROR "Invalid option given to expose_dynamic_option: \"${option_exposed}\"")
    return()
  endif()

  set(noArgs)
  set(defaultsArgs DEFAULT)
  if(option_type EQUAL 2)
    cmake_parse_arguments(
      EXPOSED
      "${noArgs}"
      "${noArgs}"
      "${defaultsArgs}"
      ${ARGN})
  else()
    cmake_parse_arguments(
      EXPOSED
      "${noArgs}"
      "${defaultsArgs}"
      "${noArgs}"
      ${ARGN})
  endif()

  if(option_type EQUAL 0)
    if(EXPOSED_DEFAULT)
      set(option_default TRUE)
    else()
      set(option_default FALSE)
    endif()
  else()
    set(option_default "${EXPOSED_DEFAULT}")
  endif()

  option("OPT_${option_name}" "${option_description}" "${option_default}")
endfunction()
