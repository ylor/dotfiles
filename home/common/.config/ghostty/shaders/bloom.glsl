
const float BLOOM_RADIUS_PX = sqrt(2.0); // spacing between samples; outer halo is ~4.9x this
const float BLOOM_SOFT_KNEE = 0.50; // smoothness around threshold
const float BLOOM_STRENGTH = 0.25; // amount added to the terminal image
const float BLOOM_THRESHOLD = 0.02; // hard threshold; soft knee begins below this

const vec3 LUMA = vec3(0.2126, 0.7152, 0.0722);

// Golden-spiral positions with normalized Gaussian weights.
// The positions are distributed uniformly by area; the weights shape them
// into a Gaussian-like blur.
const vec3 samples[24] = vec3[24](
        vec3(0.169376173, 0.985551476, 0.107125838),
        vec3(-1.333070831, 0.472146333, 0.096611561),
        vec3(-0.846439491, -1.511138706, 0.087129248),
        vec3(1.554155681, -1.258809009, 0.078577613),
        vec3(1.681364378, 1.474114592, 0.070865312),
        vec3(-1.279515769, 2.088741103, 0.063909963),
        vec3(-2.457584753, -0.979937336, 0.057637275),
        vec3(0.587464144, -2.766746443, 0.051980243),
        vec3(2.997715703, 0.117049399, 0.046878442),
        vec3(0.413608425, 3.135112131, 0.042277377),
        vec3(-3.167149934, 0.984459901, 0.038127902),
        vec3(-1.573671385, -3.086026308, 0.034385692),
        vec3(2.888202648, -2.158306156, 0.031010777),
        vec3(2.715077898, 2.574558604, 0.027967105),
        vec3(-2.150406997, 3.221141063, 0.025222166),
        vec3(-3.654885879, -1.625364331, 0.022746640),
        vec3(1.013077599, -3.996707868, 0.020514083),
        vec3(4.229723674, 0.330813611, 0.018500650),
        vec3(0.401077903, 4.340407414, 0.016684832),
        vec3(-4.319124570, 1.159811600, 0.015047235),
        vec3(-1.920904480, -4.160543952, 0.013570367),
        vec3(3.863912229, -2.658981438, 0.012238451),
        vec3(3.348622840, 3.433180023, 0.011037261),
        vec3(-2.876973364, 3.965226886, 0.009953967)
    );

float luminance(vec3 color) {
    return dot(color, LUMA);
}

vec3 extractBloom(vec3 color) {
    float brightness = luminance(color);
    float knee = max(BLOOM_THRESHOLD * BLOOM_SOFT_KNEE, 0.00001);

    float soft = clamp(
            brightness - BLOOM_THRESHOLD + knee,
            0.0,
            2.0 * knee
        );

    soft = (soft * soft) / (4.0 * knee + 0.00001);

    float contribution = max(
            brightness - BLOOM_THRESHOLD,
            soft
        );

    contribution /= max(brightness, 0.00001);

    return color * contribution;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 resolution = iResolution.xy;
    vec2 uv = fragCoord / resolution;
    vec2 texel = 1.0 / resolution;

    vec4 base = texture(iChannel0, uv);
    vec3 bloom = vec3(0.0);

    for (int i = 0; i < 24; ++i) {
        vec3 sampleData = samples[i];

        vec2 sampleUV = uv
                + sampleData.xy * texel * BLOOM_RADIUS_PX;

        // Avoid depending on the sampler's wrap mode near window edges.
        sampleUV = clamp(
                sampleUV,
                texel * 0.5,
                vec2(1.0) - texel * 0.5
            );

        vec3 sampleColor = texture(iChannel0, sampleUV).rgb;
        bloom += extractBloom(sampleColor) * sampleData.z;
    }

    // Additive composition is appropriate when the shader operates in
    // linear light. The output framebuffer will clamp values above 1.0.
    vec3 result = base.rgb + bloom * BLOOM_STRENGTH;

    fragColor = vec4(result, base.a);
}
