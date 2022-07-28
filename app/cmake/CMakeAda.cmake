# Based on https://github.com/mosteo/ada4cmake/blob/master/CMakeAda.cmake
# version f0ff4c61078e40dfa4a3637293f45c858d67becc

cmake_minimum_required(VERSION 3.5)

# Builds the project and creates a lib variable to be used in linking named TARGETLib
# LIBFILE must not have prefix nor suffix, and is expected to be static: libadatest.a -> adatest
function(add_ada_library TARGET GPRFILE OUTPUT_REL_DIR)

# Actual library file
set(_result ${CMAKE_CURRENT_BINARY_DIR}/${OUTPUT_REL_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${TARGET}${CMAKE_STATIC_LIBRARY_SUFFIX})

# Build and leave Ada dependencies to gprbuild
    add_custom_target(${TARGET}_build
        COMMAND gprbuild -p -P${CMAKE_SOURCE_DIR}/${GPRFILE} --relocate-build-tree=${CMAKE_CURRENT_BINARY_DIR} -cargs ${TOOLCHAIN_C_FLAGS}
        COMMENT "Building library ${TARGET}..."
        BYPRODUCTS ${_result}
    )

    # Fake library target that depends on gprbuild result
    add_library(${TARGET} STATIC IMPORTED GLOBAL)
    add_dependencies(${TARGET} ${TARGET}_build)

    # Connect the library object with the library target (that share the name!)
    set_target_properties(${TARGET}
            PROPERTIES
            IMPORTED_LOCATION ${_result})

endfunction(add_ada_library)
