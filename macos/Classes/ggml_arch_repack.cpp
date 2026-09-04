#if defined(__aarch64__) || defined(__arm64__) || defined(_M_ARM64)
#include "whisper/ggml/src/ggml-cpu/arch/arm/repack.cpp"
#elif defined(__x86_64__) || defined(_M_X64)
#include "whisper/ggml/src/ggml-cpu/arch/x86/repack.cpp"
#else
#error Unsupported Apple architecture
#endif
