include(vcpkg_common_functions)

if (EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/googletest
    REF 90a443f9c2437ca8a682a1ac625eba64e1d74a8a
    SHA512 fc874a7977f11be58dc63993b520b4ae6ca43654fb5250c8b56df62a21f4dca8fcbdc81dfa106374b2bb7c59bc88952fbfc0e3ae4c7d63fdb502afbaeb39c822
    HEAD_REF master
    PATCHES
        0002-Fix-z7-override.patch
        fix-main-lib-path.patch
        fix-gmock-cmake.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "dynamic" GTEST_FORCE_SHARED_CRT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_GMOCK=ON
        -DBUILD_GTEST=ON
        -DCMAKE_DEBUG_POSTFIX=d
        -Dgtest_force_shared_crt=${GTEST_FORCE_SHARED_CRT}
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/GTest)
vcpkg_fixup_cmake_targets(CONFIG_PATH share/GMock)

file(
    INSTALL
        "${SOURCE_PATH}/googletest/src/gtest.cc"
        "${SOURCE_PATH}/googletest/src/gtest_main.cc"
        "${SOURCE_PATH}/googletest/src/gtest-all.cc"
        "${SOURCE_PATH}/googletest/src/gtest-death-test.cc"
        "${SOURCE_PATH}/googletest/src/gtest-filepath.cc"
        "${SOURCE_PATH}/googletest/src/gtest-internal-inl.h"
        "${SOURCE_PATH}/googletest/src/gtest-matchers.cc"
        "${SOURCE_PATH}/googletest/src/gtest-port.cc"
        "${SOURCE_PATH}/googletest/src/gtest-printers.cc"
        "${SOURCE_PATH}/googletest/src/gtest-test-part.cc"
        "${SOURCE_PATH}/googletest/src/gtest-typed-test.cc"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/src
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/googletest/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gtest RENAME copyright)

# Install gmock cmake files.
file(GLOB GMOCK_CMAKE_FILES ${CURRENT_PACKAGES_DIR}/share/gtest/GMock*.cmake)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/gmock)
file(COPY ${GMOCK_CMAKE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/share/gmock)
file(REMOVE ${GMOCK_CMAKE_FILES})

if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/gtest_maind.lib)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gtest_maind.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/gtest_maind.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gmock_maind.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/gmock_maind.lib)

    file(READ ${CURRENT_PACKAGES_DIR}/share/gtest/GTestTargets-debug.cmake DEBUG_CONFIG)
    string(REPLACE "\${_IMPORT_PREFIX}/debug/lib/gtest_maind.lib"
                   "\${_IMPORT_PREFIX}/debug/lib/manual-link/gtest_maind.lib" DEBUG_CONFIG "${DEBUG_CONFIG}")
    string(REPLACE "\${_IMPORT_PREFIX}/debug/lib/gmock_maind.lib"
                   "\${_IMPORT_PREFIX}/debug/lib/manual-link/gmock_maind.lib" DEBUG_CONFIG "${DEBUG_CONFIG}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/gtest/GTestTargets-debug.cmake "${DEBUG_CONFIG}")
endif()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/gtest_main.lib)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gtest_main.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/gtest_main.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gmock_main.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/gmock_main.lib)

    file(READ ${CURRENT_PACKAGES_DIR}/share/gtest/GTestTargets-release.cmake RELEASE_CONFIG)
    string(REPLACE "\${_IMPORT_PREFIX}/lib/gtest_main.lib"
                   "\${_IMPORT_PREFIX}/lib/manual-link/gtest_main.lib" RELEASE_CONFIG "${RELEASE_CONFIG}")
    string(REPLACE "\${_IMPORT_PREFIX}/lib/gmock_main.lib"
                   "\${_IMPORT_PREFIX}/lib/manual-link/gmock_main.lib" RELEASE_CONFIG "${RELEASE_CONFIG}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/gtest/GTestTargets-release.cmake "${RELEASE_CONFIG}")
endif()

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
