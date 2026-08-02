// Original shader collected from: https://www.shadertoy.com/view/WsVSzV
// Licensed under Shadertoy's default since the original creator didn't provide any license. (CC BY NC SA 3.0)
// Modified to approximate the amber P3 phosphor used in monochrome CRT terminals.

float warp = 0.00; // simulate curvature of CRT monitor
float scan = 0.00; // simulate darkness between scanlines

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    // squared distance from center
    vec2 uv = fragCoord / iResolution.xy;
    vec2 dc = abs(0.5 - uv);
    dc *= dc;

    // warp the fragment coordinates
    uv.x -= 0.5;
    uv.x *= 1.0 + (dc.y * (0.3 * warp));
    uv.x += 0.5;

    uv.y -= 0.5;
    uv.y *= 1.0 + (dc.x * (0.4 * warp));
    uv.y += 0.5;

    // sample inside boundaries, otherwise set to black
    if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0)
    {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    }
    else
    {
        // determine if we are drawing in a scanline
        float apply = abs(sin(fragCoord.y) * 0.5 * scan);

        // sample the texture and apply a P3 amber phosphor tint
        vec3 color = texture(iChannel0, uv).rgb;
        vec3 amberTint = vec3(1.0, 0.25, 0.0); // #FFB000

        // mix the tinted image with black based on scanline intensity
        fragColor = vec4(
            mix(color * amberTint, vec3(0.0), apply),
            1.0
        );
    }
}
