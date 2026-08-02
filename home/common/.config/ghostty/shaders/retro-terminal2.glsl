// Original shader:
// https://www.shadertoy.com/view/WsVSzV
//
// Original work licensed under CC BY-NC-SA 3.0.
// Modified to approximate the yellow-orange P3 CRT phosphor.

float warp = 0.00; // CRT face curvature
float scan = 0.00; // scanline darkness

// Practical sRGB approximation of broad-spectrum P3 phosphor,
// centered around its reported 602 nm emission peak.
//
// #FF9F00
const vec3 P3_AMBER_SRGB = vec3(1.0000, 0.333, 0.0000);

vec3 srgbToLinear(vec3 color)
{
    vec3 low  = color / 12.92;
    vec3 high = pow((color + 0.055) / 1.055, vec3(2.4));

    return mix(
        low,
        high,
        step(vec3(0.04045), color)
    );
}

vec3 linearToSrgb(vec3 color)
{
    color = max(color, vec3(0.0));

    vec3 low  = color * 12.92;
    vec3 high = 1.055 * pow(color, vec3(1.0 / 2.4)) - 0.055;

    return mix(
        low,
        high,
        step(vec3(0.0031308), color)
    );
}

float luminance(vec3 linearColor)
{
    return dot(
        linearColor,
        vec3(0.2126, 0.7152, 0.0722)
    );
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;

    // Squared distance from the center of the CRT.
    vec2 dc = abs(0.5 - uv);
    dc *= dc;

    // Simulate the curvature of the CRT face.
    uv -= 0.5;
    uv.x *= 1.0 + dc.y * (0.3 * warp);
    uv.y *= 1.0 + dc.x * (0.4 * warp);
    uv += 0.5;

    // Outside the curved display area.
    if (
        uv.x < 0.0 || uv.x > 1.0 ||
        uv.y < 0.0 || uv.y > 1.0
    )
    {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
        return;
    }

    // Convert the source to linear-light luminance. A monochrome CRT
    // varies phosphor intensity, not phosphor hue, so retaining the
    // original RGB channels would produce inaccurate coloration.
    vec3 sourceLinear = srgbToLinear(texture(iChannel0, uv).rgb);
    float beamIntensity = clamp(luminance(sourceLinear), 0.0, 1.0);

    // Three physical pixels per simulated raster line. This avoids
    // the irregular 2π-pixel spacing produced by sin(fragCoord.y).
    const float scanPitch = 3.0;
    const float tau = 6.28318530718;

    float scanWave =
        0.5 +
        0.5 * cos(tau * (fragCoord.y + 0.5) / scanPitch);

    float scanMask = 1.0 - scan * scanWave;

    // Apply the phosphor hue in linear light so its chromaticity
    // remains stable as character brightness changes.
    vec3 phosphorLinear = srgbToLinear(P3_AMBER_SRGB);
    vec3 colorLinear = phosphorLinear * beamIntensity * scanMask;

    fragColor = vec4(linearToSrgb(colorLinear), 1.0);
}
