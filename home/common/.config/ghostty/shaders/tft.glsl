/** Simulated TFT pixel pitch, in screen pixels. */
const float PIXEL_SIZE = 4.0;

/** Darkening amount, from 0.0 to 1.0. */
const float STRENGTH = 0.333;

float tftMask(vec2 fragCoord)
{
    vec2 cell = step(vec2(1.2), mod(fragCoord, PIXEL_SIZE));
    return mix(1.0 - STRENGTH, 1.0, cell.x * cell.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord / iResolution.xy;
    vec3 color = texture(iChannel0, uv).rgb;

    fragColor = vec4(color * tftMask(fragCoord), 1.0);
}
