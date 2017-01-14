
uniform vec3 viewVector;

varying float intensity;
void main() 
{
  // Parameters for glow effect
  float c = 0.0;
  float p = 6.0;
  vec3 vPos = (viewMatrix * vec4(position, 1.0 )).xyz;
  vec3 vNormal = normalize( normalMatrix * normal );
  vec3 viewNormal = normalize( normalMatrix * normalize(viewVector)  );
  intensity = pow( c - dot(vNormal, viewNormal),p );

  gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );
}
