set -ex

# On conda-forge cross-compilation environments, CMAKE_CROSSCOMPILING is set to TRUE
# by the injected toolchain file, which causes UHDR_ENABLE_INSTALL to be automatically
# overridden to FALSE inside CMakeLists.txt. Explicitly setting it to FALSE here ensures
# that the install targets remain enabled.
if [[ "${build_platform}" != "${target_platform}" ]]; then
    EXTRA_CMAKE_ARGS="-DCMAKE_CROSSCOMPILING=FALSE"
fi

# ppc64le is not a recognized architecture in libultrahdr's intrinsics detection
if [[ "${target_platform}" == "linux-ppc64le" ]]; then
    UHDR_ENABLE_INTRINSICS=OFF
    # CMakeLists.txt:68 issues FATAL_ERROR for unknown architectures.
    # Downgrade to STATUS so cmake continues with ARCH unset (no intrinsics needed).
    sed -i.bak 's|FATAL_ERROR "Architecture:|STATUS "Architecture:|' CMakeLists.txt
else
    UHDR_ENABLE_INTRINSICS=ON
fi

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_CXX_FLAGS="${CXXFLAGS} -include cstdint" \
    -DBUILD_SHARED_LIBS=ON \
    -DUHDR_BUILD_EXAMPLES=OFF \
    -DUHDR_BUILD_TESTS=OFF \
    -DUHDR_BUILD_BENCHMARK=OFF \
    -DUHDR_BUILD_FUZZERS=OFF \
    -DUHDR_BUILD_DEPS=OFF \
    -DUHDR_BUILD_JAVA=OFF \
    -DUHDR_BUILD_PACKAGING=OFF \
    -DUHDR_ENABLE_INSTALL=ON \
    -DUHDR_ENABLE_LOGS=OFF \
    -DUHDR_ENABLE_GLES=OFF \
    -DUHDR_ENABLE_WERROR=OFF \
    -DUHDR_WRITE_ISO=ON \
    -DUHDR_WRITE_XMP=OFF \
    -DUHDR_ENABLE_INTRINSICS=${UHDR_ENABLE_INTRINSICS} \
    ${EXTRA_CMAKE_ARGS}

cmake --build build --parallel ${CPU_COUNT}
cmake --install build
