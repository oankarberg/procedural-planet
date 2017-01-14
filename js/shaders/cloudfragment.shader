

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

//uniform DirectionalLight directionalLights[ NUM_DIR_LIGHTS ];

uniform float time;

uniform float cloudConstant;
uniform float cloudFactor;
uniform float humidityFactor;




varying vec3 vPos;
varying vec3 localPosition;






float signednoise(vec3 p, out vec3 grad){
  float val = 2.0 * snoise(p, grad) - 1.0;
  grad *= 2.0;
  return val;
}

vec3 vsnoise(vec3 p, out vec3 grad){
  vec3 val =  2.0 * (vec3(snoise(p, grad))) - vec3(1.0);
  grad *= 2.0; 
  return val;
} 
float filteredsnoise(vec3 p,float width, out vec3 grad) {
  return signednoise(p, grad) * (1.0 - smoothstep(0.2,0.6,width));
} 
vec3 filteredvsnoise(vec3 p,float width, out vec3 grad) {
  return vsnoise(p, grad) * (1.0 - smoothstep(0.2,0.6,width));
} 


/* A vector-valued antialiased fBm. */ 
vec3 vfBm(vec3 p,float filtwidth, float lacunarity, float gain, out vec3 grad) {

  float amp = 1.0; 
  vec3 pp = p;
  const int octaves = 9;

  vec3 sum = vec3(0.0); 
  float fw = filtwidth;
  for(int i = 0; i < octaves; i++) { 
    if(fw < 1.0){
      sum += amp * filteredvsnoise(pp, fw,grad);
      amp *= gain;
      pp *= lacunarity;
      grad *= lacunarity;
      fw *= lacunarity; 
    }
    
  }

 return sum; 
}

float fbm(vec3 p,float filtwidth, float lacunarity, float gain, out vec3 grad) {

  float amp = 1.0; 
  vec3 pp = p;
  const int octaves = 9;
  float sum = 0.0; 
  float fw = filtwidth;
  for(int i = 0; i < 9; i++) { 
    if(fw < 1.0){
      sum += amp * filteredsnoise(pp, fw,grad);
      amp *= gain;
      pp *= lacunarity;
      grad *= lacunarity;
      fw *= lacunarity; 
    }
    
  }

 return sum; 
}
mat4 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}
varying vec3 pNormal;
varying vec3 vNormal;
float generateCyclone(vec3 localPosition, float multiplier, float cloudFactor, float cloudConstant, float time, out vec3 grad){
  // IMPLEMENTING REAL CLOUDS 

  float H =  0.7 / multiplier;



  vec3 gradTemp = vec3(0.0);


  float max_radius = 1.0;
  float twist = 0.9;
  float scale = 0.6;
  float offset = 0.5; 
  float octaves = 4.0;

  float radius;
  float dist;
  float angle;
  float eye_weight;
  float value;

  vec3 Pt;
  vec3 PN;
  vec3 PP;
  float filtwidth;
  float a;

  // Pt = vec2((atan(localPosition.z / multiplier , localPosition.x / multiplier ) / 3.1415926 + 1.0) * 0.5, ( -(asin(localPosition.y / multiplier ) / 3.1415926) + 0.5));
  Pt =  localPosition * cloudConstant / multiplier + time * 2.0; 
  filtwidth = 0.1;// filterwidthp(Pt);


/* Rotate hit point to “cyclone space” */
  PN = normalize(Pt);
  radius = sqrt(PN.x*PN.x + PN.y * PN.y + PN.z * PN.z);

  if (radius < max_radius) { 
    /* inside of cyclone */
     //invert distance from center 
    dist = pow(max_radius-radius, 3.0);
    //More angle the lower radius we have ( closer to eye )
    angle = 3.1415926 + twist *  3.1415926 * 2.0 * (max_radius-dist) / max_radius; 
    

    PP = (rotationMatrix(pNormal,angle ) * vec4(Pt,1.0)).xyz;
    /* Subtract out “eye” of storm */
    if (radius < 0.05*max_radius) { 
    //   /* if in “eye” */
    //   /* normalize */ 
      eye_weight = (0.1*max_radius - radius)* 10.0; 
    
    /* invert and make nonlinear */
      eye_weight = pow(1.0 - eye_weight, 4.0);
    }else{
      eye_weight = 1.0; 
    }
  }else { 
    /* outside of cyclone */ 
    PP = Pt;
    eye_weight = 0.0; 
  }

  // float Theta = 2.0*3.1415926*PP.x;
  // float Phi = 3.1415926*(PP.y-0.5);
  // float x =  1.0 * sin(Theta)*cos(Phi);
  // float y =  1.0 * sin(Phi);
  // float z =  1.0 * cos(Theta)*cos(Phi);
  // vec3 point = vec3(x,y,z);
  if (eye_weight > 0.0) { 
    /* if in “storm” area */
    /* Compute clouds */
    // fbm(vec3 p,float filtwidth, float lacunarity, float gain, out vec3 grad)
    a = fbm(PP, filtwidth, 2.0, H,grad); 
    value = abs(eye_weight * (offset + scale * a));
  }else{
    value = 0.0;
  }
  return value;


}



float generateClouds(vec3 localPosition, float multiplier, float cloudFactor, float cloudConstant, float time, out vec3 grad){
  //Clouds "spreadiness"
  float distortionscale = 1.0; 
  float H =  0.7 / multiplier;
  float lacunarity = 2.0;  //Seperation
  float offset = 1.2 * cloudFactor;

  vec3 gradTemp = vec3(0.0);


  vec3 Pdistortion; /* The “distortion” vector */ 
  vec3 PP; /* Point after distortion */ 
  float result; /* Fractal sum is stored here */ 
  float filtwidth;

  /* Transform to texture coordinates */ 
  // PP = vec2((atan(vPos.z, vPos.x) / 3.1415926 + 1.0) * 0.5, ( -(asin(vPos.y) / 3.1415926) + 0.5));
  PP = localPosition * cloudConstant / multiplier + time * 2.0; //vPos;
  filtwidth = 0.1; // FIX!! max(sqrt(area(PP)), 0.0000002);
  // filtwidth = filterwidthp(PP);
  /* Get “distortion” vector */
  Pdistortion = distortionscale * vfBm(PP, filtwidth, lacunarity, H, gradTemp);
  grad = gradTemp;
  /* Create distorted clouds */ 
  PP = PP + Pdistortion; 
  filtwidth = 0.1;
  /* Compute fBm */
  gradTemp = vec3(0.0);
  result = fbm(PP, filtwidth, lacunarity, H, gradTemp);
  grad += gradTemp;
  /* Adjust zero crossing (where the clouds disappear) */ 
  float humidityInAtmosphere = clamp((humidityFactor - 1.0),0.0, 0.5);
  result = clamp(result+offset , 0.0, 1.0);

  /* Scale density */ 
  result /= (1.0 + offset);
  return result;
}


void calculateLight(vec3 surfaceNormal, vec3 lightDirection, vec3 worldPos, float shiny, vec4 specularMaterial,vec4 diffuseMaterial,
              inout vec4 diffuseColor, inout vec4 specularColor){
    
    vec3 E = normalize(-worldPos);
    vec3 R = vec3(0.0);   
    float intensity = max(dot(surfaceNormal,lightDirection), 0.0);
    diffuseColor += clamp( diffuseMaterial * intensity  , 0.0, 1.0 ) ; 
    //If object has lights on 
    if(intensity > 0.0){
      R = normalize(reflect(-lightDirection,surfaceNormal));  
      specularColor += clamp ( specularMaterial * pow(max(dot(R,E),0.0),shiny) , 0.0, 1.0 );
    }
}



void main() {

  vec4 color_green =  vec4(0.5,1.0,0.0,1.0);
  vec4 color_grey =   vec4(0.7,0.7,0.7,1.0);
  vec4 color_yellow = vec4(1.0,1.0,0.0, 1.0) ;
  vec4 color_blue =   vec4(100.0/255.0,119.0/255.0,255.0/255.0,1.0);
  vec4 color_white =  vec4(1.0,1.0,1.0,1.0);
  vec4 Cland = vec4(0.0);  



  vec4 ambientMaterial = vec4(vec3(0.5),1.0);
  vec4 diffuseMaterial = vec4(vec3(0.75),1.0);
  vec4 specularMaterial  = vec4(vec3(0.0),0.0);
  float specPow   = 0.0; 
  vec4 ambientColor = vec4(0.0);
  vec4 diffuseColor = vec4(0.0); 
  vec4 specularColor = vec4(0.0);


  vec3 grad = vec3(0.0);
  vec3 gradTemp = vec3(0.0);

  float multiplier = 10000.0;

 
  // Surface Opacity 
  float opacity = generateClouds(localPosition, multiplier, cloudFactor, cloudConstant, time, grad);
  // float opacity = generateCyclone(localPosition, multiplier, cloudFactor, cloudConstant, time, grad);
  

  vec3 surfaceNormal = vNormal;
  float humidityInAtmosphere =  0.0;
  //To show humidityFactor 
  if(opacity > 0.0){
    float bumpamount = 0.01;
    vec3 perturbation = grad - dot(grad, vNormal) * vNormal;
    surfaceNormal = vNormal - bumpamount * perturbation;
    surfaceNormal = normalize(surfaceNormal); 
  }else{
    diffuseMaterial = vec4(vec3(0.2),1.0);
  }
  humidityInAtmosphere = clamp((humidityFactor - 1.0),0.0, 0.2);


  // vec3 surfaceNormal = vNormal;
  for(int i = 0; i < NUM_POINT_LIGHTS; i++) {
    vec3 lightDir = normalize(pointLights[i].position.xyz - vPos);
    ambientColor = ambientMaterial;
    calculateLight(surfaceNormal,lightDir, vPos,specPow, specularMaterial, diffuseMaterial, diffuseColor, specularColor);
  }
  
  


  
  //humidityFactor will increaese the opacity of the clouds
  gl_FragColor = vec4(color_white.rgb  ,clamp(opacity + humidityInAtmosphere,0.0,0.5) ) * (ambientColor + diffuseColor + specularColor);
  // gl_FragColor = vec4(  color_white.rgb  ,0.5) * (ambientColor + diffuseColor + specularColor);
}


