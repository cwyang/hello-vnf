# Copyright (c) 2024 Chul-Woong Yang
message(STATUS "**************************")
message(STATUS "*** BUILD DEBUG BINARY ***")
message(STATUS "**************************")
set(CMAKE_BUILD_TYPE Debug)

cmake_minimum_required(VERSION 3.5)

project(HELLOAPP)

set(MY_PROGNAME "hello")
set(VERSION_MAJOR "1")
set(VERSION_MINOR "1")
set(VERSION_PATCH "1")
set(VERSION "${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}")

configure_file(${CMAKE_CURRENT_SOURCE_DIR}/version.h.in ${CMAKE_CURRENT_SOURCE_DIR}/include/version.h)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

set(CMAKE_C_STANDARD 11)
set(ARTIFACT_DIR "${CMAKE_BINARY_DIR}/bundle")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${ARTIFACT_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_MOUDLE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/modules")
set(CMAKE_INSTALL_PREFIX "/opt/${MY_PROGNAME}")
set(CMAKE_INSTALL_RPATH	"${CMAKE_INSTALL_PREFIX}/lib" "/usr/local/lib")
set(CMAKE_BUILD_WITH_INSTALL_RPATH ON)

#
# flags
#

SET(CC_WARNING_FLAGS "-Wall -Wno-unused-value -Wno-unused-function")
IF ("${CMAKE_C_COMPILER_ID}" STREQUAL "GNU")
    IF (NOT ("${CMAKE_C_COMPILER_VERSION}" VERSION_LESS "4.6"))
        SET(CC_WARNING_FLAGS "${CC_WARNING_FLAGS} -Wno-unused-but-set-variable")
    ENDIF ()
    IF (NOT ("${CMAKE_C_COMPILER_VERSION}" VERSION_LESS "4.5"))
        SET(CC_WARNING_FLAGS "${CC_WARNING_FLAGS} -Wno-unused-result")
    ENDIF ()
ENDIF ()

# CMake defaults to a Debug build, whereas we defaults to an optimized build
IF(NOT CMAKE_BUILD_TYPE)
    SET(CMAKE_BUILD_TYPE Release)
ENDIF(NOT CMAKE_BUILD_TYPE)
SET(CMAKE_C_FLAGS_DEBUG  "-O0")
SET(CMAKE_C_FLAGS_RELEASE  "-O2")

#
# build main
#
SET(CMAKE_C_FLAGS "-g ${CC_WARNING_FLAGS} ${CMAKE_C_FLAGS} \
                  -DHELLO_ROOT=\"${CMAKE_INSTALL_PREFIX}\"\
                  -DHELLO_CONFIG_PATH=\"${CMAKE_INSTALL_SYSCONFDIR}/${MY_PROGNAME}.conf\"")
SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -pthread -D_GNU_SOURCE")

add_subdirectory(misc)
