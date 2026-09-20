// Ghostty — typing-only white cursor trail
//
// Shows a short white trail when the cursor moves one character
// cell to the RIGHT.
//
// Designed to avoid:
//   - Backspace
//   - Left arrow
//   - Up/down movement
//   - Large cursor jumps

float easeOut(float x)
{
    x = clamp(x, 0.0, 1.0);

    float t = 1.0 - x;

    return 1.0 - t * t * t;
}

float sdBox(
    vec2 p,
    vec2 center,
    vec2 halfSize
)
{
    vec2 d = abs(p - center) - halfSize;

    return length(max(d, 0.0))
         + min(max(d.x, d.y), 0.0);
}

void mainImage(
    out vec4 fragColor,
    in vec2 fragCoord
)
{
    vec2 uv = fragCoord / iResolution.xy;

    vec4 original =
        texture(iChannel0, uv);

    fragColor = original;

    // ------------------------------------------------------------
    // Cursor coordinates
    // ------------------------------------------------------------

    vec2 scale =
        vec2(
            2.0 / iResolution.y,
            2.0 / iResolution.y
        );

    vec2 offset =
        vec2(
            iResolution.x / iResolution.y,
            1.0
        );

    vec2 currentPos =
        iCurrentCursor.xy * scale - offset;

    vec2 previousPos =
        iPreviousCursor.xy * scale - offset;

    vec2 currentSize =
        iCurrentCursor.zw * scale;

    vec2 previousSize =
        iPreviousCursor.zw * scale;

    // Cursor centers
    vec2 currentCenter =
        currentPos +
        vec2(
            currentSize.x * 0.5,
            -currentSize.y * 0.5
        );

    vec2 previousCenter =
        previousPos +
        vec2(
            previousSize.x * 0.5,
            -previousSize.y * 0.5
        );

    vec2 pixel =
        fragCoord * scale - offset;

    // ------------------------------------------------------------
    // Movement
    // ------------------------------------------------------------

    vec2 movement =
        currentCenter - previousCenter;

    float dx = movement.x;
    float dy = abs(movement.y);

    float distanceMoved =
        length(movement);

    // ------------------------------------------------------------
    // Detect typing
    // ------------------------------------------------------------

    // A normal character typed into a terminal moves the cursor
    // approximately one cell to the RIGHT.
    //
    // Backspace moves LEFT, so it is automatically excluded.
    //
    // Up/down movement is excluded with dy.
    //
    // Large jumps are excluded with distanceMoved.

    float cellWidth =
        currentSize.x;

    bool movedRight =
        dx > cellWidth * 0.25;

    bool stayedOnLine =
        dy < currentSize.y * 0.25;

    bool movedOneCell =
        distanceMoved < cellWidth * 1.5;

    bool isTyping =
        movedRight &&
        stayedOnLine &&
        movedOneCell;

    if (!isTyping)
    {
        return;
    }

    // ------------------------------------------------------------
    // Animation
    // ------------------------------------------------------------

    const float DURATION = 0.16;

    float progress =
        clamp(
            (iTime - iTimeCursorChange) /
            DURATION,
            0.0,
            1.0
        );

    float fade =
        1.0 - easeOut(progress);

    // ------------------------------------------------------------
    // Trail
    // ------------------------------------------------------------

    // Trail extends backwards from current cursor.
    vec2 trailEnd =
        currentCenter;

    vec2 trailStart =
        currentCenter -
        vec2(
            cellWidth * 0.9,
            0.0
        );

    vec2 segment =
        trailEnd - trailStart;

    float segmentLengthSq =
        max(
            dot(segment, segment),
            0.000001
        );

    float t =
        clamp(
            dot(
                pixel - trailStart,
                segment
            ) / segmentLengthSq,
            0.0,
            1.0
        );

    vec2 nearest =
        trailStart +
        segment * t;

    // Thin typing trail
    vec2 halfSize =
        vec2(
            cellWidth * 0.42,
            currentSize.y * 0.30
        );

    float distance =
        sdBox(
            pixel,
            nearest,
            halfSize
        );

    float aa =
        2.0 / iResolution.y;

    float alpha =
        1.0 -
        smoothstep(
            -aa,
            aa,
            distance
        );

    // Fade from the old cursor position toward the new cursor.
    float trailFade =
        mix(
            0.05,
            1.0,
            t
        );

    alpha *=
        fade *
        trailFade;

    // ------------------------------------------------------------
    // White
    // ------------------------------------------------------------

    vec3 trailColor =
        vec3(1.0);

    fragColor.rgb =
        mix(
            original.rgb,
            trailColor,
            alpha
        );
}
