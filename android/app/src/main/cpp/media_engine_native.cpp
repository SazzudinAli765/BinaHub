#include <jni.h>
#include <android/log.h>
#include "enhancement_pipeline.hpp"

#define LOG_TAG "BinaMediaEngineNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

#if defined(_WIN32)
#define DART_EXPORT __declspec(dllexport)
#else
#define DART_EXPORT __attribute__((visibility("default"))) __attribute__((used))
#endif

static std::unique_ptr<binahub::EnhancementPipeline> g_pipeline = nullptr;

extern "C" {

JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void* reserved) {
    LOGI("BinaHub Native Media Engine JNI_OnLoad initialized.");
    g_pipeline = std::make_unique<binahub::EnhancementPipeline>();
    return JNI_VERSION_1_6;
}

// Dart FFI Direct Binding Exports (ARCH-01)

DART_EXPORT void bina_native_init_pipeline() {
    if (!g_pipeline) {
        g_pipeline = std::make_unique<binahub::EnhancementPipeline>();
    }
}

DART_EXPORT void bina_native_set_denoise(int32_t enabled, float intensity) {
    if (g_pipeline) {
        g_pipeline->setDenoise(enabled != 0, intensity);
    }
}

DART_EXPORT void bina_native_set_deblur(int32_t enabled, float intensity) {
    if (g_pipeline) {
        g_pipeline->setDeblur(enabled != 0, intensity);
    }
}

DART_EXPORT void bina_native_set_scaler(int32_t scalerType, float intensity) {
    if (g_pipeline) {
        g_pipeline->setScaler(static_cast<binahub::ScalerType>(scalerType), intensity);
    }
}

DART_EXPORT void bina_native_set_sharpening(int32_t enabled, float intensity) {
    if (g_pipeline) {
        g_pipeline->setSharpening(enabled != 0, intensity);
    }
}

DART_EXPORT void bina_native_set_hdr(int32_t enabled) {
    if (g_pipeline) {
        g_pipeline->setHdrToneMapping(enabled != 0);
    }
}

DART_EXPORT void bina_native_set_comparison(int32_t mode, float splitPosition) {
    if (g_pipeline) {
        g_pipeline->setComparisonMode(static_cast<binahub::ComparisonMode>(mode), splitPosition);
    }
}

DART_EXPORT void bina_native_set_thermal_throttled(int32_t throttled) {
    if (g_pipeline) {
        g_pipeline->setThermalThrottled(throttled != 0);
    }
}

DART_EXPORT void bina_native_process_frame(
    const uint8_t* inRgba,
    int32_t inW,
    int32_t inH,
    uint8_t* outRgba,
    int32_t outW,
    int32_t outH
) {
    if (g_pipeline) {
        g_pipeline->processFrame(inRgba, inW, inH, outRgba, outW, outH);
    }
}

} // extern "C"
