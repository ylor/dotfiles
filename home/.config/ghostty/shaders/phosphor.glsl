// Simulates phosphor light spread through a display faceplate.
// This shader is complete and does not depend on bloom.glsl.

/** Brightness where phosphor emission starts to produce visible glow. */
const float GLOW_THRESHOLD = 0.04;

/** Width of the transition from no glow to full glow. */
const float GLOW_SOFT_KNEE = 0.14;

/** Width and strength of light spread through the display faceplate. */
const float OUTER_SIGMA = 2.00;
const float OUTER_STRENGTH = 0.20;

/** A seven-pixel kernel keeps the halo continuous and local. */
const int KERNEL_RADIUS = 3;

float luminance(vec3 color)
{
    return dot(color, vec3(0.299, 0.587, 0.114));
}

vec3 phosphorEmission(vec3 color)
{
    float brightness = luminance(color);
    float glow = smoothstep(
            GLOW_THRESHOLD,
            GLOW_THRESHOLD + GLOW_SOFT_KNEE,
            brightness
        );
    return color * glow;
}

float gaussianWeight(float distanceSquared, float sigma)
{
    return exp(-distanceSquared / (2.0 * sigma * sigma));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy;
    vec4 source = texture(iChannel0, uv);

    vec3 outerGlow = vec3(0.0);
    float outerWeightSum = 0.0;

    for (int y = -KERNEL_RADIUS; y <= KERNEL_RADIUS; y++)
    {
        for (int x = -KERNEL_RADIUS; x <= KERNEL_RADIUS; x++)
        {
            vec2 offset = vec2(float(x), float(y));
            float distanceSquared = dot(offset, offset);
            float outerWeight = gaussianWeight(distanceSquared, OUTER_SIGMA);
            vec3 sampleColor = texture(iChannel0, uv + offset * texel).rgb;
            vec3 emission = phosphorEmission(sampleColor);

            outerGlow += emission * outerWeight;
            outerWeightSum += outerWeight;
        }
    }

    outerGlow /= outerWeightSum;

    // Put the halo only behind empty pixels so glyph edges remain unchanged.
    float sourceBrightness = luminance(source.rgb);
    float haloMask = 1.0 - step(0.01, sourceBrightness);
    vec3 halo = outerGlow * OUTER_STRENGTH;

    vec3 color = source.rgb + halo * haloMask;
    fragColor = vec4(color, source.a);
}
