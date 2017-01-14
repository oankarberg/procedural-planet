

varying vec3 vNormal;
varying vec3 pNormal;
varying vec3 vPos;
varying vec3 localPosition;

uniform float time;

void main(){

  gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0 );
  localPosition = position;
  pNormal = normal;

  // For the fragmentshader
  vPos = (viewMatrix * vec4(position, 1.0 )).xyz;
  vNormal = normalMatrix * normal;
}