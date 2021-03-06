/*
 * Copyright 2017 Google Inc.
 *
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 */

in uniform sampler2D image;
in uniform colorSpaceXform colorXform;
in float4x4 matrix;

@constructorParams {
    GrSamplerState samplerParams
}

@coordTransform(image) {
    matrix
}

@samplerParams(image) {
    samplerParams
}

@make {
    static std::unique_ptr<GrFragmentProcessor> Make(sk_sp<GrTextureProxy> proxy,
                                                     sk_sp<GrColorSpaceXform> colorSpaceXform,
                                                     const SkMatrix& matrix) {
        return std::unique_ptr<GrFragmentProcessor>(
            new GrSimpleTextureEffect(std::move(proxy), std::move(colorSpaceXform), matrix,
                    GrSamplerState(GrSamplerState::WrapMode::kClamp, GrSamplerState::Filter::kNearest)));
    }

    /* clamp mode */
    static std::unique_ptr<GrFragmentProcessor> Make(sk_sp<GrTextureProxy> proxy,
                                                     sk_sp<GrColorSpaceXform> colorSpaceXform,
                                                     const SkMatrix& matrix,
                                                     GrSamplerState::Filter filter) {
        return std::unique_ptr<GrFragmentProcessor>(
            new GrSimpleTextureEffect(std::move(proxy), std::move(colorSpaceXform), matrix,
                                      GrSamplerState(GrSamplerState::WrapMode::kClamp, filter)));
     }

    static std::unique_ptr<GrFragmentProcessor> Make(sk_sp<GrTextureProxy> proxy,
                                                     sk_sp<GrColorSpaceXform> colorSpaceXform,
                                                     const SkMatrix& matrix,
                                                     const GrSamplerState& p) {
        return std::unique_ptr<GrFragmentProcessor>(
            new GrSimpleTextureEffect(std::move(proxy), std::move(colorSpaceXform), matrix, p));
    }
}

@optimizationFlags {
    kCompatibleWithCoverageAsAlpha_OptimizationFlag |
    (GrPixelConfigIsOpaque(image->config()) ? kPreservesOpaqueInput_OptimizationFlag :
                                              kNone_OptimizationFlags)
}

void main() {
    sk_OutColor = sk_InColor * texture(image, sk_TransformedCoords2D[0], colorXform);
}

@test(testData) {
    int texIdx = testData->fRandom->nextBool() ? GrProcessorUnitTest::kSkiaPMTextureIdx
                                               : GrProcessorUnitTest::kAlphaTextureIdx;
    GrSamplerState::WrapMode wrapModes[2];
    GrTest::TestWrapModes(testData->fRandom, wrapModes);
    GrSamplerState params(wrapModes, testData->fRandom->nextBool()
                                                               ? GrSamplerState::Filter::kBilerp
                                                               : GrSamplerState::Filter::kNearest);

    const SkMatrix& matrix = GrTest::TestMatrix(testData->fRandom);
    sk_sp<GrColorSpaceXform> colorSpaceXform = GrTest::TestColorXform(testData->fRandom);
    return GrSimpleTextureEffect::Make(testData->textureProxy(texIdx), std::move(colorSpaceXform),
                                       matrix);
}
