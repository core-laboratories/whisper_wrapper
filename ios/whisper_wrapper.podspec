Pod::Spec.new do |s|
  s.name             = 'whisper_wrapper'
  s.version          = '3.0.0'
  s.summary          = 'Offline speech recognition for Flutter using whisper.cpp.'
  s.description      = <<-DESC
Offline, on-device speech recognition for Flutter using whisper.cpp.
                       DESC
  s.homepage         = 'https://github.com/core-laboratories/whisper_wrapper'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Core Laboratories' => 'https://github.com/core-laboratories' }

  # This will ensure the source files in Classes/ are included in the native
  # builds of apps using this FFI plugin. Podspec does not support relative
  # paths, so Classes contains a forwarder C file that relatively imports
  # `../src/*` so that the C sources can be shared among all target platforms.
  s.dependency 'Flutter'
  s.source           = {
    :git => 'https://github.com/core-laboratories/whisper_wrapper'
  }
  s.source_files = 'Classes/**/*.{cpp,c,h,hpp}'
  s.exclude_files = 'Classes/whisper/ggml/src/ggml-cpu/arch/**/*'
  # Only whisper.h is public; the ggml tree has duplicate header basenames
  # (common.h, quants.h) that collide when flattened into the framework.
  s.public_header_files = 'Classes/whisper/include/whisper.h'
  s.platform = :ios, '15.6'
  s.ios.deployment_target  = '15.6'

  # Flutter.framework does not contain a i386 slice.
  s.xcconfig = {
    'IPHONEOS_DEPLOYMENT_TARGET' => '15.6',
    'CLANG_CXX_LANGUAGE_STANDARD' => 'c++20',
  }
  s.library = 'c++'
  s.frameworks = 'Accelerate'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    # whisper.cpp v1.9.3 (CPU backend) include roots
    'HEADER_SEARCH_PATHS' => [
      '"$(PODS_TARGET_SRCROOT)/Classes/whisper/include"',
      '"$(PODS_TARGET_SRCROOT)/Classes/whisper/ggml/include"',
      '"$(PODS_TARGET_SRCROOT)/Classes/whisper/ggml/src"',
      '"$(PODS_TARGET_SRCROOT)/Classes/whisper/ggml/src/ggml-cpu"',
      '"$(PODS_TARGET_SRCROOT)/Classes/whisper/src"',
    ].join(' '),
    'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GGML_USE_CPU=1 GGML_USE_ACCELERATE=1 ACCELERATE_NEW_LAPACK=1 ACCELERATE_LAPACK_ILP64=1 GGML_VERSION=\"1.9.3\" GGML_COMMIT=\"whisper.cpp-v1.9.3\" WHISPER_VERSION=\"1.9.3\"',
    # keep inference usable in debug builds
    'GCC_OPTIMIZATION_LEVEL' => '3',
  }
  s.swift_version = '5.0'
end
