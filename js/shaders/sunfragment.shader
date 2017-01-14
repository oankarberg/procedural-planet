 
uniform vec3 glowColor;
varying float intensity;
void main() 
{
  vec3 color_atmosphere = vec3(1.0,1.0,0.0);
  vec3 glow = color_atmosphere * intensity;
  gl_FragColor = vec4( glow, 1.0 );
}
