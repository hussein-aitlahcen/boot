cmake_minimum_required(VERSION 3.30)

# Find clang++ executable and set it as compiler
find_program(Clang_P clang++ REQUIRED True)
set(CMAKE_CXX_COMPILER ${Clang_P})
set(CMAKE_C_COMPILER_FORCED TRUE)
set(CMAKE_CXX_COMPILER_FORCED TRUE)

# Find clang executable and set it as compiler
find_program(Clang_C clang REQUIRED True)
set(CMAKE_C_COMPILER ${Clang_C})
# lots of warnings and all warnings as errors
add_compile_options(-Wall -Wextra -pedantic -Werror -Wno-unused-variable)

# Disable cmakes compiler test
# because of this cross compilation chain
# the normal compile test would fail
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

add_compile_options(--target=x86_64-pc-win32-coff)
add_compile_options(-nostdlibinc)
add_compile_options(-fno-stack-protector)
add_compile_options(-ffreestanding)
add_compile_options(-fshort-wchar) # Make L strings two bytes wide
add_compile_options(-mno-red-zone) # Disable dangerous optimization
add_compile_options(-masm=intel) # Enable intel asm syntax

# Ignore errors to get EDK2 headers to work
add_compile_options(-Wno-unused-command-line-argument)
add_compile_options(-Wno-c11-extensions)
add_compile_options(-Wno-c99-extensions)
add_compile_options(-Wno-language-extension-token)
add_compile_options(-Wno-microsoft-enum-value)
add_compile_options(-Wno-writable-strings)

set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} --target=x86_64-unknown-windows")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -nostdlib")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-entry:efi_main")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,-subsystem:efi_application")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=lld-link")

project(BOOTX64.EFI)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED True)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Get num cores & set num threads for build
include(ProcessorCount)
ProcessorCount(N)
if(NOT N EQUAL 0)
    set(CMAKE_BUILD_PARALLEL_LEVEL ${N})
endif()

add_executable(${PROJECT_NAME} src/main.c)

target_include_directories(
  ${PROJECT_NAME}
  PUBLIC
  include
  edk2/MdePkg/Include
  edk2/MdePkg/Include/X64
  edk2/CryptoPkg/Library
  edk2/CryptoPkg/Library/Include
)
