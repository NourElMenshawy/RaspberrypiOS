cmake_minimum_required( VERSION 2.8 )

# Mark the language as C so that CMake doesn't try to test the C++
# cross-compiler's ability to compile a simple program because that will fail
project( PIOs.elf C ASM )

# We had to adjust the CMAKE_C_FLAGS variable in the toolchain file to make sure
# the compiler would work with CMake's simple program compilation test. So unset
# it explicitly before re-setting it correctly for our system
set( CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O0 -g -nostartfiles -nostdlib -march=armv8-a -ffreestanding" )

#Ordering files is imporant as .map file will put boot.S first which will
#result of correct behavior running QEMU
add_executable( ${PROJECT_NAME}
    boot.S
    mm.S
    hello.c
    )

set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "-Wl,--build-id=none,-Map,${CMAKE_BINARY_DIR}/${PROJECT_NAME}-${${PROJECT_NAME}_version}.map -T ${PROJECT_SOURCE_DIR}/linker.ld -nostdlib -nostartfiles -gc-sections")

# Run QEMU command
add_custom_target(run
  COMMAND qemu-system-aarch64 -machine virt -cpu cortex-a57 -smp 4 -m 4096 -nographic -serial mon:stdio  --kernel ${PROJECT_NAME}
  )