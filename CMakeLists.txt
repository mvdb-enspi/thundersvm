cmake_minimum_required(VERSION 3.15)

cmake_policy(SET CMP0048 NEW)
cmake_policy(SET CMP0042 NEW)

option(USE_CUDA "Compile with CUDA" ON)

set(PROJECT_LANGUAGES CXX)
if(USE_CUDA)
    list(APPEND PROJECT_LANGUAGES CUDA)
endif()

project(thundersvm
    LANGUAGES ${PROJECT_LANGUAGES}
    VERSION ${PROJECT_VERSION}
)

# CUDA configuration
if(USE_CUDA)
    find_package(CUDAToolkit REQUIRED)
    # Replace with architectures supported by your GPU
    set(CMAKE_CUDA_ARCHITECTURES "75;80;86")  # Example for Turing/Ampere GPUs
endif()

if(MSVC)
    set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
    set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
endif()

option(BUILD_TESTS "Build test executables" OFF)
option(USE_DOUBLE "Use double as kernel_type" OFF)

if(USE_DOUBLE)
    message("Use double as kernel_type")
endif()
if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif ()
if (MSVC AND BUILD_SHARED_LIBS)
    set (CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif ()

find_package(Threads)
find_package(OpenMP REQUIRED)
add_definitions("-DELPP_NO_LOG_TO_FILE")

if (USE_CUDA)
    message("Compile with CUDA")
    if (CUDA_VERSION VERSION_LESS "11.0")
      set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} -std=c++11 -Wno-deprecated-gpu-targets)
    else ()
      set(CUDA_NVCC_FLAGS ${CUDA_NVCC_FLAGS} -std=c++14 -Wno-deprecated-gpu-targets)
    endif ()
    list(APPEND LINK_LIBRARY ${CUDA_cusparse_LIBRARY})

    # Correct error for GCC 5 and CUDA 7.5
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_MWAITXINTRIN_H_INCLUDED -D_FORCE_INLINES")
else ()
    message("Compile without CUDA")
    find_package (Eigen3 3.3 NO_MODULE)
    if (Eigen3_FOUND)
        message("using external Eigen3 for acceleration")
        include_directories(${EIGEN3_INCLUDE_DIR})
        list(APPEND LINK_LIBRARY Eigen3::Eigen)
    else ()
        message("using internal Eigen3 for acceleration")
        include_directories(${PROJECT_SOURCE_DIR}/eigen)
    endif ()
    if (NOT CMAKE_CXX_FLAGS MATCHES "-march")
        add_compile_options("-march=native")
    endif ()
endif ()

if (CMAKE_VERSION VERSION_LESS "3.1")
    add_compile_options("-std=c++11")
else ()
    set(CMAKE_CXX_STANDARD 14)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif ()

set(COMMON_INCLUDES
    ${PROJECT_SOURCE_DIR}/src/thundersvm/cpp/include
    ${CMAKE_CURRENT_BINARY_DIR}
)


set(DATASET_DIR ${PROJECT_SOURCE_DIR}/dataset/)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/thundersvm/cpp/include/thundersvm/config.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/src/thundersvm/cpp/include/thundersvm/config.h
)

set(PROJECT_LIB_NAME ${PROJECT_NAME})
include_directories(${COMMON_INCLUDES})
include_directories(${CMAKE_CURRENT_BINARY_DIR}/src/thundersvm/cpp/include)
add_subdirectory(${PROJECT_SOURCE_DIR}/src/thundersvm/cpp)

# Installation
install(TARGETS thundersvm
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION thundersvm/lib
    INCLUDES DESTINATION include
)

install(
  FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/thundersvm/__init__.py
    ${CMAKE_CURRENT_SOURCE_DIR}/src/thundersvm/thundersvm.py
  DESTINATION thundersvm
)


if (BUILD_TESTS)
    include(FetchContent)
    FetchContent_Declare(
    googletest
        URL https://github.com/google/googletest/archive/03597a01ee50ed33e9dfd640b249b4be3799d395.zip
    )

    FetchContent_MakeAvailable(googletest)
    enable_testing()

    add_executable(thundersvm_test
        src/thundersvm/cpp/test/test_dataset.cpp
        src/thundersvm/cpp/test/test_cross_validation.cpp
        src/thundersvm/cpp/test/test_svr.cpp
        src/thundersvm/cpp/test/test_svc.cpp
        src/thundersvm/cpp/test/test_kernelmatrix.cpp
        src/thundersvm/cpp/test/test_nusvc.cpp
        src/thundersvm/cpp/test/test_nusvr.cpp
        src/thundersvm/cpp/test/test_oneclass_svc.cpp
        src/thundersvm/cpp/test/test_syncarray.cpp
        src/thundersvm/cpp/test/test_syncmem.cpp
    )

    # Common includes for all builds
    target_include_directories(thundersvm_test PRIVATE
        ${COMMON_INCLUDES}
    )

    # Conditional CUDA dependencies
    if(USE_CUDA)
        target_include_directories(thundersvm_test PRIVATE
            ${CUDAToolkit_INCLUDE_DIRS}
        )
        target_link_libraries(thundersvm_test PRIVATE
            ${CUDAToolkit_LIBRARIES}
        )
        target_compile_options(thundersvm_test PRIVATE
            $<$<COMPILE_LANGUAGE:CUDA>:${CUDA_NVCC_FLAGS}>
        )
        target_compile_definitions(thundersvm_test PRIVATE
            -D_MWAITXINTRIN_H_INCLUDED
            -D_FORCE_INLINES
        )
    endif()

    # Core dependencies for all builds
    target_link_libraries(thundersvm_test
        PRIVATE
        thundersvm
        GTest::gtest_main
        GTest::gmock_main
    )

    include(GoogleTest)
    gtest_discover_tests(thundersvm_test)

    # Add this after the test configuration
    add_custom_target(run_tests
        DEPENDS thundersvm_test  # Ensure test executable is built
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
        COMMENT "Running tests..."
    )
endif()
