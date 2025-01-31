include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/include/thundersvm
    ${CMAKE_CURRENT_BINARY_DIR}
)

# Update source file paths if needed
file(GLOB SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/model/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/solver/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/util/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/util/*.h
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/kernel/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/kernel/*.h
)

if (USE_CUDA)
    file(GLOB SRC_KERNEL kernel/*.cu)
    list(APPEND SRC ${SRC_KERNEL})
    cuda_add_library(thundersvm ${SRC})
    target_link_libraries(thundersvm ${CUDA_cusparse_LIBRARY} OpenMP::OpenMP_CXX)
else ()
    file(GLOB SRC_CPU_KERNEL ${CMAKE_CURRENT_SOURCE_DIR}/kernel/*.cpp)
    list(APPEND SRC ${SRC_CPU_KERNEL})
    add_library(thundersvm ${SRC})
    target_link_libraries(thundersvm OpenMP::OpenMP_CXX)
endif ()

# Only install the library binary
install(TARGETS thundersvm LIBRARY DESTINATION thundersvm/lib)
