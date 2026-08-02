// VT320-style amber monochrome CRT shader.
//
// Designed for Ghostty/Shadertoy-compatible custom shaders.
// Uses a P3-like yellow-orange phosphor appearance.
//
// The VT320 had a comparatively flat antiglare CRT, so curvature,
// chromatic aberration, RGB masks, noise, and exaggerated flicker
// are intentionally omitted.

const float TAU = 6.28318530718;

// CRT characteristics.
float warp        = 0.00;  // VT320 screen was relatively flat
float scan        = 0.16;  // subtle raster modulation
float softness    = 0.16;  // electron-beam spot width
float bloom       = 0.075; // phosphor/glass halation
float vignette    = 0.08;  // edge luminance falloff
float drive       = 1.90;  // electron-beam intensity
float rasterLines = 500.0; // reported VT320 display raster

vec3 srgbToLinear(vec3 color)
{
    return pow(max(color, vec3(0.0)), vec3(2.2));
}

vec3 linearToSrgb(vec3 color)
{
    return pow(max(color, vec3(0.0)), vec3(1.0 / 2.2));
}

bool outsideScreen(vec2 uv)
{
    return any(lessThan(uv, vec2(0.0))) ||
           any(greaterThan(uv, vec2(1.0)));
}

// Convert the modern RGB terminal image into a monochrome video signal.
//
// Maximum-channel intensity is deliberate: a monochrome terminal has no
// notion of source hue. Red, green, blue, and white terminal text should
// excite the same amber phosphor when their intensity is equivalent.
float sampleSignal(vec2 uv)
{
    if (outsideScreen(uv))
        return 0.0;

    vec3 color = srgbToLinear(texture(iChannel0, uv).rgb);
    float signal = max(color.r, max(color.g, color.b));

    // Preserve font antialiasing while suppressing nearly-black residue.
    signal = max(signal - 0.0015, 0.0) / 0.9985;

    return pow(clamp(signal, 0.0, 1.0), 0.95);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    // Symmetrical barrel distortion. Zero is most appropriate for a VT320.
    vec2 position = uv - 0.5;
    position *= 1.0 + warp * dot(position, position);
    uv = position + 0.5;

    if (outsideScreen(uv))
    {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    vec2 pixel = 1.0 / iResolution.xy;

    float center = sampleSignal(uv);

    // Compact approximation of the slightly unfocused electron-beam spot.
    float cardinal =
        sampleSignal(uv + vec2( pixel.x, 0.0)) +
        sampleSignal(uv + vec2(-pixel.x, 0.0)) +
        sampleSignal(uv + vec2(0.0,  pixel.y)) +
        sampleSignal(uv + vec2(0.0, -pixel.y));

    float diagonal =
        sampleSignal(uv + pixel * vec2( 1.0,  1.0)) +
        sampleSignal(uv + pixel * vec2(-1.0,  1.0)) +
        sampleSignal(uv + pixel * vec2( 1.0, -1.0)) +
        sampleSignal(uv + pixel * vec2(-1.0, -1.0));

    float nearBeam =
        (cardinal + diagonal * 0.70710678) /
        (4.0 + 4.0 * 0.70710678);

    // Wider, low-energy halo caused by phosphor and faceplate scattering.
    vec2 haloOffset = pixel * 3.0;

    float farBeam =
        sampleSignal(uv + vec2( haloOffset.x, 0.0)) +
        sampleSignal(uv + vec2(-haloOffset.x, 0.0)) +
        sampleSignal(uv + vec2(0.0,  haloOffset.y)) +
        sampleSignal(uv + vec2(0.0, -haloOffset.y));

    farBeam *= 0.25;

    float focusedSignal = mix(center, nearBeam, softness);

    // Reconstruct the original CRT raster rather than darkening arbitrary
    // groups of output pixels.
    float rasterPosition = uv.y * rasterLines;
    float rasterWave =
        0.5 + 0.5 * cos(TAU * (rasterPosition - 0.5));

    // Fade the raster modulation when there are too few output pixels to
    // represent it cleanly, preventing severe moire and aliasing.
    float rasterFootprint = fwidth(rasterPosition);
    float rasterAliasing =
        smoothstep(0.45, 0.90, rasterFootprint);

    rasterWave = mix(rasterWave, 0.5, rasterAliasing);

    // Energy-balanced modulation: bright beam centers and darker gaps.
    float rasterMask = 1.0 + scan * (rasterWave - 0.5);

    // Halation is strongest around high-intensity phosphor regions.
    float emission =
        focusedSignal * rasterMask +
        bloom * farBeam * farBeam;

    // Subtle loss of luminance toward the edges of the tube.
    vec2 edgePosition = (uv - 0.5) * 2.0;
    float edgeDistance = dot(edgePosition, edgePosition);

    float edgeMask =
        1.0 -
        vignette * smoothstep(0.25, 1.65, edgeDistance);

    emission *= edgeMask;

    // Soft saturation models increased beam current without clipping every
    // bright glyph to the same flat value.
    float intensity =
        1.0 - exp(-drive * max(emission, 0.0));

    /*
     * P3-like amber approximation:
     *
     *   dim halo:    burnt orange
     *   normal beam: #FFB700
     *   hot center:  pale yellow-amber
     *
     * A real phosphor has a broad spectrum, so one fixed RGB triplet cannot
     * represent its appearance at every brightness level.
     */
    vec3 dimAmber  = vec3(0.84, 0.36, 0.00);
    vec3 mainAmber = vec3(1.00, 0.718, 0.00); // #FFB700
    vec3 hotAmber  = vec3(1.00, 0.83, 0.42);

    vec3 phosphorColor =
        mix(dimAmber, mainAmber,
            smoothstep(0.02, 0.42, intensity));

    phosphorColor =
        mix(phosphorColor, hotAmber,
            0.50 * smoothstep(0.68, 0.98, intensity));

    vec3 finalColor =
        srgbToLinear(phosphorColor) * intensity;

    fragColor = vec4(linearToSrgb(finalColor), 1.0);
}
