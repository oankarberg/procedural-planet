








function PlanetSystem(){

    var self = this;
    //Public
    self.scene; 
    self.sceneMaterials = [];
    self.ANIMATE_EARTH = false;
    self.ANIMATE_SUN = true;
    self.CLOUD_ANIMATION_SPEED = 1.0;
    
    self.LAND_INDEX  = 0;
    self.WATER_INDEX = 1;
    self.CLOUD_INDEX = 2;
    self.ATMOSPHERE_INDEX = 3;
    self.SUN_INDEX = 4;

    //Private
    var container, stats;
    var camera, renderer;

    var earth_vertex_shader;
    var earth_fragment_shader;
    var cloud_vertex_shader;
    var cloud_fragment_shader;
    var atmosphere_vertex_shader;
    var atmosphere_fragment_shader;
    var sun_vertex_shader;
    var sun_fragment_shader;

    var water_vertex_shader;
    var water_fragment_shader;
    var uniforms_earth, uniforms_cloud, uniforms_water, uniforms_atmosphere,uniforms_sun;
    var controls;

    var sunLight, directionalLight;
    
    var SUN_ROTATION = 0;
    var EARTH_MOVEMENT = 0;
    
    var ANIMATE_WATER_SURFACE = 1.0;
    var WATER_ANIMATION_DIR = 0.0001;
    var ANIMATION_MOVEMENT = 0.0;

    

    var clock = new THREE.Clock();
    

    self.initialize = function(shaderTexts){
        earth_vertex_shader = shaderTexts[0];
        earth_fragment_shader = shaderTexts[1];

        cloud_vertex_shader = shaderTexts[2];
        cloud_fragment_shader = shaderTexts[3];

        water_vertex_shader = shaderTexts[4];
        water_fragment_shader = shaderTexts[5];

        atmosphere_vertex_shader = shaderTexts[6];
        atmosphere_fragment_shader = shaderTexts[7];
        
        sun_vertex_shader = shaderTexts[8];
        sun_fragment_shader = shaderTexts[9];


        init();
        animate();
    }
    
    THREE.PointLight.prototype.addRepresentation = function(object){
        this.object = object;
        this.add(this.object);
    }

    function init() {

        container = document.getElementById( 'container' );

        camera = new THREE.PerspectiveCamera( 40, window.innerWidth / window.innerHeight, 100.0, 2000000);
        camera.position.z = 80000;

        self.scene = new THREE.Scene();
        sunLight = new THREE.PointLight(0xffe54c);
        sunLight.position.set(40000.0,20000.0,0.0);
    

        var imagePrefix = "images/skybox2/";
        var directions  = ["xpos", "xneg", "ypos", "yneg", "zpos", "zneg"];
        var imageSuffix = ".png";
        var skyGeometry = new THREE.CubeGeometry( 1000000, 1000000 ,1000000 ); 

        var materialArray = [];
        for (var i = 0; i < 6; i++)
            materialArray.push( new THREE.MeshBasicMaterial({
                map: new THREE.TextureLoader().load( imagePrefix + directions[i] + imageSuffix ),
                side: THREE.BackSide
            }));

        var skyMaterial = new THREE.MeshFaceMaterial( materialArray );
        var skyBox = new THREE.Mesh( skyGeometry, skyMaterial );
        self.scene.add( skyBox );

        controls = new THREE.OrbitControls( camera );
        controls.minDistance = 40000;
        
        controls.addEventListener( 'change', render );


        var geometry_earth1 = new THREE.IcosahedronGeometry(10000, 5);
        var geometry_earth2 = new THREE.IcosahedronGeometry(10000, 2 );
        var geometry_earth3 = new THREE.IcosahedronGeometry(10000, 5  );
        
        
        var resolutions_earth = [[geometry_earth1,30000]]//,[geometry_earth2,25000],[geometry_earth3,20000]];


        var geometry_water1 = new THREE.IcosahedronGeometry(10000, 4 );
        var geometry_water2 = new THREE.IcosahedronGeometry(10000, 1 );
        var resolutions_water = [[geometry_water1,30000]]//, [geometry_water2,20000]];
        var geometry_cloud = new THREE.IcosahedronGeometry(10500, 3);
        var geometry_clouds = [[geometry_cloud, 30000]];
        var geometry_atmosphere = new THREE.IcosahedronGeometry(10500, 3 );
        var geometry_atmospheres =[[geometry_atmosphere, 30000]]
        var geometry_sun = new THREE.IcosahedronGeometry(10000, 3);
        var geometry_suns =[[geometry_sun, 30000]]
        geometry_earth1.name = "earth";
        geometry_cloud.name = "cloud";
        geometry_water1.name = "water";
        geometry_atmosphere.name = "atmosphere";
        geometry_sun.name = "sun";

        uniforms_earth = THREE.UniformsUtils.merge([
            THREE.UniformsLib['lights'],{
            time: { type: "f", value: 0 },
            weight: { type: "f", value: 0 },
            landConstant: { type: "f", value: 1.0 },
            beachFactor: { type: "f", value: 1.0 },
            snowFactor: { type: "f", value: 1.0 },
            droughtFactor: { type: "f", value: 1.0 },
            humidityFactor: { type: "f", value: 1.0 },
            waterHeightConstant: { type: "f", value: 1.0 },
            resolution: { value: new THREE.Vector2() },
        }]);
        uniforms_cloud = THREE.UniformsUtils.merge([
            THREE.UniformsLib['lights'],{
            time: { type: "f", value: 0 },
            cloudConstant: { type: "f", value: 1.0 },
            cloudFactor: { type: "f", value: 1.0 },
            humidityFactor: { type: "f", value: 1.0 },
            resolution: { value: new THREE.Vector2() }
        }]);

        uniforms_water = THREE.UniformsUtils.merge([
            THREE.UniformsLib['lights'],{
            time: { type: "f", value: 0 },
            waterHeightConstant: { type: "f", value: 1.0 },
            resolution: { value: new THREE.Vector2() }
        }]);

        uniforms_atmosphere = THREE.UniformsUtils.merge([
            THREE.UniformsLib['lights'],{
            time: { type: "f", value: 0 },
            resolution: { value: new THREE.Vector2()},
            viewVector: { type: "v3", value: camera.position} 
        }]);

        uniforms_sun = THREE.UniformsUtils.merge([
            THREE.UniformsLib['lights'],{
            time: { type: "f", value: 0 },
            resolution: { value: new THREE.Vector2()},
            viewVector: { type: "v3", value: camera.position} 
        }]);



        var params = [
            //EARTH
            {'shader_uniform': uniforms_earth, 'geometry': resolutions_earth, 
            'vertex_shader':earth_vertex_shader,'fragment_shader':earth_fragment_shader, 'side':THREE.FrontSide,
            'blending':THREE.NormalBlending},
            //WATER
            {'shader_uniform': uniforms_water, 'geometry': resolutions_water,
             'vertex_shader':water_vertex_shader,'fragment_shader':water_fragment_shader, 'side':THREE.FrontSide,
            'blending':THREE.NormalBlending},
            //CLOUDS
            {'shader_uniform': uniforms_cloud, 'geometry': geometry_clouds,
             'vertex_shader':cloud_vertex_shader,'fragment_shader':cloud_fragment_shader, 'side':THREE.DoubleSide,
            'blending':THREE.NormalBlending},
            //ATMOSPHERE
             {'shader_uniform': uniforms_atmosphere, 'geometry': geometry_atmospheres,
             'vertex_shader':atmosphere_vertex_shader,'fragment_shader':atmosphere_fragment_shader, 'side':THREE.FrontSide,
            'blending':THREE.AdditiveBlending},
            //SUN
            {'shader_uniform': uniforms_sun, 'geometry': geometry_suns,
             'vertex_shader':sun_vertex_shader,'fragment_shader':sun_fragment_shader, 'side':THREE.FrontSide,
            'blending':THREE.AdditiveBlending}
        ];

        //ADD ALL OBJECTS TO SCENE
        for( var i = 0; i < params.length; i++ ) {
            lod = new THREE.LOD();

            var material = new THREE.ShaderMaterial( {
                uniforms: params[ i ]['shader_uniform'],
                vertexShader: params[ i ]['vertex_shader'],
                fragmentShader: params[ i ]['fragment_shader'],
                lights: true,
                transparent: true,
                blending: params[i]['blending'],
                side: params[ i ]['side']
            });
            var resolutions = params[ i ]['geometry']
            for(var k = 0; k < resolutions.length; k++){
                var mesh = new THREE.Mesh( resolutions[k][0], material );
                mesh.updateMatrix();
                mesh.matrixAutoUpdate = false;
                console.log("mesh ",resolutions)
                lod.addLevel( mesh, resolutions[k][1] );
                lod.name = resolutions[k][0].name;
            }
            lod.updateMatrix();
            lod.matrixAutoUpdate = false;
            self.sceneMaterials.push(material);
            if(lod.name == "sun"){
                sunLight.addRepresentation(lod);
            }else{
                self.scene.add(lod);
            }
            
        }
        self.scene.add(sunLight);

        renderer = new THREE.WebGLRenderer();
        renderer.setPixelRatio( window.devicePixelRatio );
        container.appendChild( renderer.domElement );

        stats = new Stats();
        container.appendChild( stats.dom );

        onWindowResize();
        // normalLoc = renderer.getAttribLocation(progID, "inputNormal");
        window.addEventListener( 'resize', onWindowResize, false );
    }

    function onWindowResize( event ) {

        uniforms_earth.resolution.value.x = window.innerWidth;
        uniforms_earth.resolution.value.y = window.innerHeight;
        //uniforms2.resolution.value.x = window.innerWidth;
        //uniforms2.resolution.value.y = window.innerHeight;
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize( window.innerWidth, window.innerHeight );
    }

    function animationLogics(){

        var delta = clock.getDelta();
        if(self.ANIMATE_SUN){
            SUN_ROTATION += delta * 0.05;
            sunLight.position.x =   Math.cos(SUN_ROTATION ) * 40000;
            sunLight.position.z =   Math.sin(SUN_ROTATION) * 40000;
        }
        
        //Increase animation timer
        ANIMATE_WATER_SURFACE += WATER_ANIMATION_DIR;
        //Invert direction of noise pattern generation
        if(ANIMATE_WATER_SURFACE > 1.2){
            ANIMATE_WATER_SURFACE = 1.2;
            WATER_ANIMATION_DIR = -WATER_ANIMATION_DIR;
        }
        if(ANIMATE_WATER_SURFACE < 1.0){
            ANIMATE_WATER_SURFACE = 1.0;
            WATER_ANIMATION_DIR = -WATER_ANIMATION_DIR;
        }
        //ANIMATE WATER
        self.sceneMaterials[self.WATER_INDEX].uniforms['time'].value = ANIMATE_WATER_SURFACE;
        //ANIMATE EARTH
        if(self.ANIMATE_EARTH){
            EARTH_MOVEMENT += clock.getDelta() * 5.0;
            self.sceneMaterials[self.LAND_INDEX].uniforms['time'].value = EARTH_MOVEMENT;
        }
        //ANIMATE CLOUDS 
        ANIMATION_MOVEMENT += delta * self.CLOUD_ANIMATION_SPEED * 0.01;
        self.sceneMaterials[self.CLOUD_INDEX].uniforms['time'].value = ANIMATION_MOVEMENT;
        
        var radiusFromOrigo = Math.sqrt(Math.pow(controls.object.position.x,2.0) + Math.pow(controls.object.position.y,2.0) + Math.pow(controls.object.position.z,2.0));
        controls.zoomSpeed = 1.0;
        controls.rotateSpeed = 1.0;
    }


    function animate() {

        requestAnimationFrame( animate );
        
        animationLogics();
        
        render();
        stats.update();
        controls.update();

    }


    function render() {

        //ATMOSPHERE GLOW EFFECT
        self.sceneMaterials[self.ATMOSPHERE_INDEX].uniforms['viewVector'].value = camera.position;
        //SUN GLOW EFFECT
        self.sceneMaterials[self.SUN_INDEX].uniforms['viewVector'].value = new THREE.Vector3().subVectors( camera.position, sunLight.position );

        self.scene.updateMatrixWorld();
        self.scene.traverse( function ( object ) {

          if ( object instanceof THREE.LOD ) {

            object.update( camera );

          }

        } );
    
        
        renderer.render( self.scene, camera );

    }

}






    