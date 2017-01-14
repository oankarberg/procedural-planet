


function ShaderInput(sApp){
  var parameterWrapper = document.getElementById("parameter-wrapper");


  this.updateCloudNoise = function(val){
    //Convert 0-100 to 0-2
    sApp.sceneMaterials[sApp.CLOUD_INDEX].uniforms['cloudConstant'].value = 2.0 * val * 0.01;
  }

  this.updateLandNoise = function(val){
    sApp.sceneMaterials[sApp.LAND_INDEX].uniforms['landConstant'].value = 2.0 * val * 0.01;
  }

  this.updateWaterLevel = function(val){
    //Increase expontentially
    var increaseVal =  2.0 * val * 0.01;
    sApp.sceneMaterials[sApp.WATER_INDEX].uniforms['waterHeightConstant'].value = increaseVal; //Math.pow(increaseVal,4.0);
  }

  this.updateBeachFactor = function(val){
    var increaseVal =  2.0 * val * 0.01;
    sApp.sceneMaterials[sApp.LAND_INDEX].uniforms['beachFactor'].value = Math.pow(increaseVal , 2.0);//(increaseVal <= 1.0)  ? increaseVal : increaseVal * increaseVal;
  }

  this.updateSnowFactor = function(val){
    var increaseVal =  2.0 * val * 0.01;
    sApp.sceneMaterials[sApp.LAND_INDEX].uniforms['snowFactor'].value = (4.0 - Math.pow(increaseVal,2.0));
  }
  this.updateDroughtFactor = function(val){
    var increaseVal =   val * 0.01;
    sApp.sceneMaterials[sApp.LAND_INDEX].uniforms['droughtFactor'].value = (1.0 - increaseVal);
  }
  this.updateHumidityFactor = function(val){
    //0.5 - 1.5 and increase cloud speed
    var increaseVal =  ( 2.0 * val * 0.01 + 1.0 )/ 2.0;
    sApp.CLOUD_ANIMATION_SPEED = increaseVal;
    sApp.sceneMaterials[sApp.LAND_INDEX].uniforms['humidityFactor'].value = increaseVal;
    sApp.sceneMaterials[sApp.CLOUD_INDEX].uniforms['humidityFactor'].value = increaseVal;
  }
  this.updateCloudFactor = function(val){
    var increaseVal =  2.0 * val * 0.01;
    sApp.sceneMaterials[sApp.CLOUD_INDEX].uniforms['cloudFactor'].value = increaseVal;
  }

  this.toggleAnimateSun = function(val){
    sApp.ANIMATE_SUN = val.checked;
  }
  this.toggleAnimateEarth = function(val){
    sApp.ANIMATE_EARTH = val.checked;
  }
  this.toggleClouds = function(val){
    // CLOUDS_ACTIVE = val.checked;
    var object = sApp.scene.getObjectByName("cloud");
    object.visible = val.checked;
  }
  this.toggleMovingClouds = function(val){
    // CLOUDS_ACTIVE = val.checked;
    var increaseVal =  ( 2.0 * document.getElementById("humidityFactor").value * 0.01 + 1.0 )/ 2.0;
    sApp.CLOUD_ANIMATION_SPEED = val.checked ? increaseVal : 0.0;
  }
  this.toggleAtmosphere = function(val){
    var object = sApp.scene.getObjectByName("atmosphere");
    object.visible = val.checked;
  }
}
