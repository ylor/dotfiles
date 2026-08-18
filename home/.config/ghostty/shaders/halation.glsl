// Simulates red halation from light that reflects behind a film emulsion.
// This shader is complete and does not depend on bloom.glsl.

/** Brightness where halation starts. */
const float HALATION_THRESHOLD = 0.05;

/** Width of the transition around the brightness threshold. */
const float HALATION_SOFT_KNEE = 0.20;

/** Radius and intensity of the reflected light. */
const float HALATION_SIGMA = 2.75;
const float HALATION_STRENGTH = 0.52;

/** Red film layers receive most of the reflected light. */
const vec3 HALATION_TINT = vec3(1.0, 0.18, 0.04);

const int KERNEL_RADIUS = 5;

float luminance(vec3 color)
{
    return dot(color, vec3(0.299, 0.587, 0.114));
}

float gaussianWeight(float distanceSquared)
{
    float variance = HALATION_SIGMA * HALATION_SIGMA;
    return exp(-distanceSquared / (2.0 * variance));
}

vec3 halationEmission(vec3 color)
{
    float brightness = luminance(color);
    float emission = smoothstep(
            HALATION_THRESHOLD - HALATION_SOFT_KNEE,
            HALATION_THRESHOLD + HALATION_SOFT_KNEE,
            brightness
        );
    return color * emission;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy;
    vec4 source = texture(iChannel0, uv);

    vec3 reflectedLight = vec3(0.0);
    float weightSum = 0.0;

    for (int y = -KERNEL_RADIUS; y <= KERNEL_RADIUS; y++)
    {
        for (int x = -KERNEL_RADIUS; x <= KERNEL_RADIUS; x++)
        {
            vec2 offset = vec2(float(x), float(y));
            float distanceSquared = dot(offset, offset);
            float weight = gaussianWeight(distanceSquared);
            vec3 sampleColor = texture(iChannel0, uv + offset * texel).rgb;

            reflectedLight += halationEmission(sampleColor) * weight;
            weightSum += weight;
        }
    }

    reflectedLight /= weightSum;

    // Keep the source center clear and place the red halo near its edges.
    float sourceBrightness = luminance(source.rgb);
    float edgeMask = 1.0 - smoothstep(
                HALATION_THRESHOLD * 0.5,
                HALATION_THRESHOLD,
                sourceBrightness
            );
    float reflectedBrightness = luminance(reflectedLight);
    vec3 halo = reflectedBrightness * HALATION_TINT;
    vec3 color = source.rgb + halo * edgeMask * HALATION_STRENGTH;

    fragColor = vec4(color, source.a);
}
