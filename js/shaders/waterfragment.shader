 

 //
// Description : Array and textureless GLSL 2D/3D/4D simplex 
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
// 

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v, out vec3 gradient)
{
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i); 
  vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  vec4 m2 = m * m;
  vec4 m4 = m2 * m2;
  vec4 pdotx = vec4(dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3));

// Determine noise gradient
  vec4 temp = m2 * m * pdotx;
  gradient = -8.0 * (temp.x * x0 + temp.y * x1 + temp.z * x2 + temp.w * x3);
  gradient += m4.x * p0 + m4.y * p1 + m4.z * p2 + m4.w * p3;
  gradient *= 42.0;

  return 42.0 * dot(m4, pdotx);
}
struct PointLight {
  vec3 position;
  vec3 color;
};
struct DirectionalLight {
  vec3 direction;
  float intensity;
  vec3 color;
};
uniform PointLight pointLights[ NUM_POINT_LIGHTS ];

// uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];

uniform float time;


void calculateLight(vec3 surfaceNormal, vec3 lightDirection, vec3 worldPos, float shiny, vec4 specMat,vec4 diffuseMat,
              inout vec4 diffuseColor, inout vec4 specularColor){
    
    vec3 E = normalize(-worldPos);
    vec3 R = vec3(0.0);   
    float intensity = max(dot(surfaceNormal,lightDirection), 0.0);
    diffuseColor += clamp( diffuseMat * intensity  , 0.0, 1.0 ) ; 
    //If object has lights on 
    if(intensity > 0.0){
      R = normalize(reflect(-lightDirection,surfaceNormal));  
      specularColor += clamp ( specMat * pow(max(dot(R,E),0.0),shiny) , 0.0, 1.0 );
    }
}



varying vec3 vNormal;
varying vec3 nNormal;
varying vec2 vUv;
varying vec3 vPos;
varying vec3 localPosition;


void main() {

  vec4 color_green =  vec4(0.5,1.0,0.0,1.0);
  vec4 color_grey =   vec4(0.7,0.7,0.7,1.0);
  vec4 color_yellow = vec4(1.0,1.0,0.0, 1.0) ;
  vec4 color_blue =   vec4(70.0/255.0,119.0/255.0,255.0/255.0,1.0);
  vec4 color_white =  vec4(1.0,1.0,1.0,1.0);
  vec4 Cland = vec4(0.0);  


  vec4 ambientMat = vec4(vec3(0.4),1.0);
  vec4 diffuseMat = vec4(vec3(0.3),1.0);
  vec4 specMat    = vec4(vec3(1.0),1.0);
  float specularShiny   = 100.0; 


  vec3 grad = vec3(0.0);
  vec3 gradTemp = vec3(0.0);

  float multiplier = 10000.0;
  vec3 aniPosition = 50.0*localPosition * time / multiplier + cos(time)*80.0;

  float elevation = 0.001  * multiplier * ( snoise(aniPosition, grad)) ;
  grad *= 0.001 * 50.0 * time;
    

  float bumpamount = 0.5;
  vec3 perturbation = grad - dot(grad, vNormal) * vNormal;
  vec3 surfaceNormal = vNormal - bumpamount * perturbation;
  surfaceNormal = normalize(surfaceNormal); 


  vec4 ambientColor;
  vec4 diffuseColor = vec4(0.0); 
  vec4 specularColor = vec4(0.0);

  for(int i = 0; i < NUM_POINT_LIGHTS; i++) {
    vec3 lightDir = normalize(pointLights[i].position.xyz - vPos);
    ambientColor = ambientMat;
    calculateLight(surfaceNormal,lightDir, vPos,specularShiny, specMat, diffuseMat, diffuseColor, specularColor);
 
  }


 
  

  color_blue.a = 1.0;
  gl_FragColor =   vec4(color_blue.rgb,0.6) * (ambientColor + diffuseColor + specularColor); // vec4(  color_white.rgb  , 1.0);
}


