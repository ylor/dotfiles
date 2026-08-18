// Simulates the neutral bloom of a high-brightness P1 or P3 CRT.

const float BLOOM_THRESHOLD = 0.01;
const float BLOOM_KNEE = 0.08;
const float BLOOM_STRENGTH = 0.20;

// Each sample contains its pixel offset and inverse-distance weight.
const vec3[32] BLOOM_SAMPLES = vec3[32](
        vec3(0.22648431, 0.58252026, 1.60000000),
        vec3(-0.97079588, -0.47898889, 0.92376043),
        vec3(1.34184287, -0.39061838, 0.71554175),
        vec3(-0.85851102, 1.41327061, 0.60474316),
        vec3(-0.36467290, -1.83919512, 0.53333333),
        vec3(1.67075737, 1.22696570, 0.48241815),
        vec3(-2.24029090, 0.24335503, 0.44376016),
        vec3(1.59787088, -1.81829141, 0.41311822),
        vec3(0.05324817, 2.57639082, 0.38805700),
        vec3(-1.88136225, -1.97036826, 0.36706517),
        vec3(2.85770811, 0.19138799, 0.34914862),
        vec3(-2.34054245, 1.87249460, 0.33362306),
        vec3(0.48061658, -3.08782006, 0.32000000),
        vec3(1.79932446, 2.70357291, 0.30792014),
        vec3(-3.26769503, -0.80640821, 0.29711254),
        vec3(3.05438881, -1.66735839, 0.28736848),
        vec3(-1.16167942, 3.39722327, 0.27852425),
        vec3(-1.48114602, -3.38793174, 0.27044936),
        vec3(3.47591465, 1.53985140, 0.26303838),
        vec3(-3.69928779, 1.24484733, 0.25620505),
        vec3(1.93463350, -3.50325823, 0.24987802),
        vec3(0.96252932, 3.98376861, 0.24399771),
        vec3(-3.47892425, -2.33991689, 0.23851392),
        vec3(4.23696990, -0.63832674, 0.23338399),
        vec3(-2.74972774, 3.40288442, 0.22857143),
        vec3(-0.27652809, -4.45481843, 0.22404481),
        vec3(3.27548574, 3.15821440, 0.21977690),
        vec3(-4.63361204, -0.11838253, 0.21574396),
        vec3(3.55965529, -3.09749564, 0.21192518),
        vec3(-0.54171150, 4.77005489, 0.20830226),
        vec3(-2.87012798, -3.94847950, 0.20485901),
        vec3(4.86128826, 0.98856029, 0.20158105)
    );

float luminance(vec3 color)
{
    return dot(color, vec3(0.2126, 0.7152, 0.0722));
}

vec3 phosphorEmission(vec3 color)
{
    float brightness = luminance(color);
    float bloomDrive = smoothstep(
            BLOOM_THRESHOLD,
            BLOOM_THRESHOLD + BLOOM_KNEE,
            brightness
        );

    return color * bloomDrive;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec2 texel = 1.0 / iResolution.xy;
    vec4 source = texture(iChannel0, uv);

    vec3 glow = vec3(0.0);
    float weightSum = 0.0;

    for (int i = 0; i < 32; i++)
    {
        vec3 samplePoint = BLOOM_SAMPLES[i];
        vec3 sampleColor = texture(
                iChannel0,
                uv + samplePoint.xy * texel
            ).rgb;

        glow += phosphorEmission(sampleColor) * samplePoint.z;
        weightSum += samplePoint.z;
    }

    glow /= weightSum;

    // Suppress bloom on glyph centers to retain sharp text.
    float sourceBrightness = luminance(source.rgb);
    float centerMask = 1.0 - 0.95 * smoothstep(0.02, 0.30, sourceBrightness);
    vec3 color = source.rgb + glow * centerMask * BLOOM_STRENGTH;

    fragColor = vec4(color, source.a);
}
