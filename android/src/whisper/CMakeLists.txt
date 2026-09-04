# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(whisper_flutter_library LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(W ${CMAKE_CURRENT_SOURCE_DIR}/whisper.cpp)

# Vendored whisper.cpp v1.9.3, CPU backend only.
file(GLOB GGML_SRC
    ${W}/ggml/src/*.c
    ${W}/ggml/src/*.cpp
    ${W}/ggml/src/ggml-cpu/*.c
    ${W}/ggml/src/ggml-cpu/*.cpp
    ${W}/ggml/src/ggml-cpu/amx/*.cpp
)

if(CMAKE_ANDROID_ARCH_ABI MATCHES "arm64-v8a|armeabi-v7a")
    file(GLOB GGML_ARCH_SRC
        ${W}/ggml/src/ggml-cpu/arch/arm/*.c
        ${W}/ggml/src/ggml-cpu/arch/arm/*.cpp
    )
elseif(CMAKE_ANDROID_ARCH_ABI MATCHES "x86|x86_64")
    file(GLOB GGML_ARCH_SRC
        ${W}/ggml/src/ggml-cpu/arch/x86/*.c
        ${W}/ggml/src/ggml-cpu/arch/x86/*.cpp
    )
else()
    message(FATAL_ERROR "Unsupported Android ABI: ${CMAKE_ANDROID_ARCH_ABI}")
endif()
list(APPEND GGML_SRC ${GGML_ARCH_SRC})

add_library(whisper STATIC ${GGML_SRC} ${W}/src/whisper.cpp)
target_include_directories(whisper PUBLIC
    ${W}/include
    ${W}/ggml/include
    ${W}/ggml/src
    ${W}/ggml/src/ggml-cpu
    ${W}/src
)
target_compile_definitions(whisper PUBLIC GGML_USE_CPU)
# Android's bionic headers expose CPU affinity APIs only with GNU extensions.
target_compile_definitions(whisper PRIVATE _GNU_SOURCE)
# Upstream generates these from git; we vendor a fixed release.
target_compile_definitions(whisper PRIVATE
    GGML_VERSION="1.9.3"
    GGML_COMMIT="whisper.cpp-v1.9.3"
    WHISPER_VERSION="1.9.3"
)
# No -march override: the previous armv8.2-a+fp16 flags SIGILLed on
# armv8.0 devices (issue #15). Baseline armv8-a runs everywhere.
target_compile_options(whisper PRIVATE -O3 -ffunction-sections -fdata-sections)

add_library(whisper_flutter SHARED main.cpp)
set_target_properties(whisper_flutter PROPERTIES OUTPUT_NAME "whisper")
target_compile_definitions(whisper_flutter PUBLIC DART_SHARED_LIB)
target_compile_options(whisper_flutter PRIVATE -O3 -ffunction-sections -fdata-sections)
target_link_options(whisper_flutter PRIVATE -Wl,--gc-sections)
target_link_libraries(whisper_flutter PRIVATE whisper ${CMAKE_THREAD_LIBS_INIT})
