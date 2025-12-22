        uniform float time;
        uniform vec2 resolution;
        
        // Colors
        const vec3 color1 = vec3(0.451, 0.875, 0.949);
        const vec3 color2 = vec3(0.271, 0.525, 0.569); // Darker version
        
        vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
            vec2 uv = sc / resolution;
            
            // Create multiple wave layers
            float wave1 = sin(uv.x * 10.0 - time * 2.0) * 0.05;
            float wave2 = sin(uv.x * 15.0 - time * 2.5 + 1.0) * 0.03;
            float wave3 = sin(uv.x * 24.0 - time * 1.8 + 2.0) * 0.04;
            
            // Combine waves
            float combinedWave = wave1 + wave2 + wave3;
            
            // Create moving pattern
            float pattern = sin((uv.y + time * 0.3 + combinedWave) * 20.0);
            
            // Alternate between two colors
            vec3 finalColor = mix(color1, color2, step(0.0, pattern));
            
            return vec4(finalColor, 1.0);
        }