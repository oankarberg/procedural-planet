if ( ! Detector.webgl ) Detector.addGetWebGLMessage();

var fileFetcher = new FileFetcher();
var planetSystem = new PlanetSystem();
var shaderInput = new ShaderInput(planetSystem);
fileFetcher.loadFiles(["js/shaders/earthvertex.shader","js/shaders/earthfragment.shader",
            "js/shaders/cloudvertex.shader","js/shaders/cloudfragment.shader",
            "js/shaders/watervertex.shader","js/shaders/waterfragment.shader",
            "js/shaders/atmospherevertex.shader","js/shaders/atmospherefragment.shader",
            "js/shaders/sunvertex.shader","js/shaders/sunfragment.shader"], function(shadersText){
    
    
    planetSystem.initialize(shadersText);
    
},function(err){
    throw "errror loading files " + err;
});