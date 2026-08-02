// Near-monochrome teal/green phosphor grading for Ghostty.

const vec3 LUMA_WEIGHTS = vec3(0.2126, 0.7152, 0.0722);
// const vec3 PHOSPHOR_COLOR = vec3(0.10, 1.00, 0.62); // green
// const vec3 PHOSPHOR_COLOR = vec3(0.0, 1.0, 0.0); // GREEN
const vec3 PHOSPHOR_COLOR = vec3(1.0, 0.4, 0.0); // amber

// Amount of original color retained for saturated colors.
const float COLOR_PRESERVATION = 0.10;

// Raises the visibility of saturated red, blue, and magenta.
// 0.0 gives standard luminance conversion.
// Around 0.15–0.25 works well for terminal colors.
const float SATURATED_COLOR_LIFT = 0.20;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec4 src = texture(iChannel0, uv);

    float highest = max(src.r, max(src.g, src.b));
    float lowest = min(src.r, min(src.g, src.b));
    float chroma = highest - lowest;

    float luminance = dot(src.rgb, LUMA_WEIGHTS);

    // Prevent saturated terminal colors—especially blue—from becoming
    // excessively dark after monochrome conversion.
    float signal = mix(
            luminance,
            highest,
            SATURATED_COLOR_LIFT
        );

    vec3 phosphor = signal * PHOSPHOR_COLOR;

    // Neutral colors are fully monochrome. Saturated colors retain up
    // to 10% of their original color, matching your current settings.
    float saturationAmount = smoothstep(0.06, 0.30, chroma);
    float originalAmount = saturationAmount * COLOR_PRESERVATION;

    vec3 color = mix(phosphor, src.rgb, originalAmount);

    fragColor = vec4(clamp(color, 0.0, 1.0), src.a);
}
