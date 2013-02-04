(function() {
  var App,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  $(function() {
    if (!Detector.webgl) Detector.addGetWebGLMessage();
    return window.app = new App();
  });

  App = (function() {

    App.prototype.app = App;

    App.prototype.animFPS = 25;

    App.prototype.container = null;

    App.prototype.stats = null;

    App.prototype.camera = null;

    App.prototype.scene = null;

    App.prototype.renderer = null;

    App.prototype.materialDepth = null;

    App.prototype.composer = null;

    App.prototype.renderTarget = null;

    App.prototype.renderPass = null;

    App.prototype.fxaa = null;

    App.prototype.colorCorr = null;

    App.prototype.bloom = null;

    App.prototype.film = null;

    App.prototype.bleach = null;

    App.prototype.hblur = null;

    App.prototype.vblur = null;

    App.prototype.renderToScreenPass = null;

    App.prototype.creatureMesh = null;

    App.prototype.skyCube = null;

    App.prototype.skyCubeTexture = null;

    App.prototype.creatureShaderUniforms = null;

    App.prototype.currentAnimation = null;

    App.prototype.lastKeyFrame = null;

    App.prototype.wingMesh = null;

    App.prototype.wingMesh2 = null;

    App.prototype.wingAnim = 0;

    App.prototype.pickMouse = null;

    App.prototype.dandelionMeshes = null;

    App.prototype.projector = new THREE.Projector;

    App.prototype.sunLight = null;

    App.prototype.ambientLight = null;

    App.prototype.screenSpacePosition = new THREE.Vector3;

    App.prototype.mouseX = 0;

    App.prototype.mouseY = 0;

    App.prototype.SCREEN_WIDTH = window.innerWidth;

    App.prototype.SCREEN_HEIGHT = window.innerHeight;

    App.prototype.windowHalfX = App.SCREEN_WIDTH / 2;

    App.prototype.windowHalfY = App.SCREEN_HEIGHT / 2;

    App.prototype.postprocessing = null;

    App.prototype.params = {
      animated: true,
      enableFXAA: false,
      enableBloom: true,
      bloomIntensity: 0.9,
      enableFilmEffect: true,
      filmEffectScanlinesIntensity: 0.8,
      filmEffectNoiseIntensity: 0.4,
      enableGodRays: true,
      enableColorCorrection: false,
      godRaysColor: [255, 249, 230],
      godRaysIntensity: 0.7,
      enableShadows: true,
      sunColor: [255, 242, 204],
      sunIntensity: 1.2,
      ambientColor: [255, 242, 204],
      enableAmbientOcclusion: true,
      enableNormalMap: true,
      normalMapScale: 7,
      enableSpecular: false,
      enableReflection: true,
      reflectionStrength: 0.05
    };

    App.prototype.clock = new THREE.Clock;

    function App() {
      this.render = __bind(this.render, this);
      this.animate = __bind(this.animate, this);
      this.onDocumentMouseMove = __bind(this.onDocumentMouseMove, this);
      this.onDocumentMouseClick = __bind(this.onDocumentMouseClick, this);
      this.getFairyMaterial = __bind(this.getFairyMaterial, this);
      this.initWings = __bind(this.initWings, this);
      this.initCreature = __bind(this.initCreature, this);      this.postprocessing = {};
      this.pickMouse = {
        x: 0,
        y: 0
      };
      this.init();
      this;
    }

    App.prototype.init = function() {
      var loader;
      this.container = document.createElement('div');
      document.body.appendChild(this.container);
      this.camera = new THREE.PerspectiveCamera(50, this.SCREEN_WIDTH / this.SCREEN_HEIGHT, 1, 5000);
      this.camera.position.z = 300;
      this.scene = new THREE.Scene();
      this.initSky();
      this.materialDepth = new THREE.MeshDepthMaterial;
      this.materialDepth.morphTargets = this.params.animated;
      this.renderer = new THREE.WebGLRenderer({
        antialias: false
      });
      this.renderer.setSize(this.SCREEN_WIDTH, this.SCREEN_HEIGHT);
      this.renderer.sortObjects = true;
      this.renderer.autoClear = false;
      this.renderer.setClearColorHex(this.params.bgColor, 1);
      this.renderer.domElement.style.position = 'absolute';
      this.renderer.domElement.style.top = "0px";
      this.renderer.domElement.style.left = "0px";
      this.renderer.shadowMapEnabled = this.params.enableShadows;
      this.renderer.shadowMapSoft = true;
      this.renderer.shadowMapSoft = true;
      this.renderer.gammaInput = true;
      this.renderer.gammaOutput = true;
      this.container.appendChild(this.renderer.domElement);
      this.stats = new Stats();
      this.stats.domElement.style.position = 'absolute';
      this.stats.domElement.style.top = '0px';
      this.container.appendChild(this.stats.domElement);
      this.stats.domElement.children[0].children[0].style.color = "#888";
      this.stats.domElement.children[0].style.background = "transparent";
      this.stats.domElement.children[0].children[1].style.display = "none";
      document.addEventListener('mousemove', this.onDocumentMouseMove, false);
      document.addEventListener('mousedown', this.onDocumentMouseClick, false);
      document.addEventListener('touchstart', this.onDocumentTouchStart, false);
      document.addEventListener('touchmove', this.onDocumentTouchMove, false);
      window.addEventListener('resize', this.onWindowResize, false);
      this.initLights();
      this.initPostprocessing();
      this.initRenderPasses();
      this.initComposer(null);
      this.initGUI();
      this.initDandelions();
      loader = new THREE.GeometryLoader;
      loader.addEventListener('load', this.initCreature);
      loader.load("sophie/sophie_anim3.js");
      return this;
    };

    App.prototype.initGUI = function() {
      var controller, creatureFolder, gui, postProcFolder;
      ({
        onEnableShadowsChange: function(value) {
          this.renderer.shadowMapEnabled = this.sunLight.castShadow = this.creatureMesh.castShadow = this.creatureMesh.receiveShadow = value;
          return this.creatureShaderUniforms["shadowMap"].value = [];
        },
        onSunColorChange: function(value) {
          return this.sunLight.color.setRGB(this.params.sunColor[0] / 255, this.params.sunColor[1] / 255, this.params.sunColor[2] / 255);
        },
        onSunIntensityChange: function(value) {
          return this.sunLight.intensity = value;
        },
        onAmbientColorChange: function(value) {
          return this.ambientLight.color.setRGB(this.params.ambientColor[0] / 255, this.params.ambientColor[1] / 255, this.params.ambientColor[2] / 255);
        },
        onBloomIntensityChange: function(value) {
          return this.bloom.strength = bloom.screenUniforms["opacity"].value = value;
        },
        onFilmEffectScanLinesIntensityChange: function(value) {
          return this.film.uniforms['sIntensity'].value = value;
        },
        onFilmEffectNoiseIntensityChange: function(value) {
          return this.film.uniforms['nIntensity'].value = value;
        }
      });
      controller = null;
      gui = new dat.GUI({
        width: 400
      });
      postProcFolder = gui.addFolder("Post Processing");
      controller = postProcFolder.add(this.params, 'enableFXAA').name('Enable Antialiasing');
      controller.onChange(this.initComposer);
      controller = postProcFolder.add(this.params, 'enableBloom').name('Enable Bloom');
      controller.onChange(this.initComposer);
      controller = postProcFolder.add(this.params, 'bloomIntensity', 0, 2).name('Bloom Intensity');
      controller.onChange(this.onBloomIntensityChange);
      controller = postProcFolder.add(this.params, 'enableFilmEffect').name('Enable Film Effect');
      controller.onChange(this.initComposer);
      controller = postProcFolder.add(this.params, 'filmEffectScanlinesIntensity', 0, 5).name('Film Scanlines Intensity');
      controller.onChange(this.onFilmEffectScanLinesIntensityChange);
      controller = postProcFolder.add(this.params, 'filmEffectNoiseIntensity', 0, 5).name('Film Noise Intensity');
      controller.onChange(this.onFilmEffectNoiseIntensityChange);
      controller = postProcFolder.add(this.params, 'enableGodRays').name('Enable Fog');
      controller.onChange(this.initComposer);
      controller = postProcFolder.addColor(this.params, 'godRaysColor').name('Fog Color');
      controller = postProcFolder.add(this.params, 'godRaysIntensity', 0, 2).name('Fog Intensity');
      creatureFolder = gui.addFolder("Lighting");
      controller = creatureFolder.add(this.params, 'enableShadows').name('Enable Shadows');
      controller.onChange(this.onEnableShadowsChange);
      controller = creatureFolder.addColor(this.params, 'sunColor').name('Sun Color');
      controller.onChange(this.onSunColorChange);
      controller = creatureFolder.add(this.params, 'sunIntensity', 0, 10).name('Sun Intensity');
      controller.onChange(this.onSunIntensityChange);
      controller = creatureFolder.addColor(this.params, 'ambientColor').name('Ambient Color');
      controller.onChange(this.onAmbientColorChange);
      controller = creatureFolder.add(this.params, 'normalMapScale', 0, 50).name('Normal Mapping Intensity');
      controller.onChange(this.onCreatureShaderChange);
      controller = creatureFolder.add(this.params, 'enableAmbientOcclusion').name('Enable Ambient Occlusion');
      controller.onChange(this.onCreatureShaderChange);
      controller = creatureFolder.add(this.params, 'enableSpecular').name('Enable Specular');
      controller.onChange(this.onCreatureShaderChange);
      controller = creatureFolder.add(this.params, 'enableReflection').name('Enable Reflection');
      controller.onChange(this.onCreatureShaderChange);
      controller = creatureFolder.add(this.params, 'reflectionStrength', 0, 1).name('Reflection Strength');
      controller.onChange(this.onCreatureShaderChange);
      return this;
    };

    App.prototype.initDandelions = function() {
      var dandelion, geom, i;
      this.dandelionTexture = THREE.ImageUtils.loadTexture("textures/dandelion.png");
      geom = new THREE.PlaneGeometry(10, 10);
      if (this.params.animated) {
        geom.morphTargets[0] = {
          name: "fake",
          vertices: geom.vertices
        };
      }
      this.mat = new THREE.MeshBasicMaterial({
        map: this.dandelionTexture,
        transparent: true,
        wireframe: false,
        wireframeLinewidth: 10
      });
      this.dandelionMeshes = [];
      for (i = 0; i <= 400; i++) {
        dandelion = new THREE.Mesh(geom, this.mat);
        dandelion.name = "dandelion" + i;
        dandelion.position.x = Math.random() * 1000 - 500;
        dandelion.position.y = Math.random() * 1000 - 500;
        dandelion.position.z = this.camera.position.z - 20 - (Math.random() * 1000);
        dandelion.CCW = Math.random() > 0.5;
        dandelion.speed = 1 + Math.random() * 10;
        this.dandelionMeshes.push(dandelion);
        this.scene.add(dandelion);
      }
      return this;
    };

    App.prototype.onCreatureShaderChange = function(value) {
      this.creatureShaderUniforms["enableAO"].value = this.params.enableAmbientOcclusion;
      this.creatureShaderUniforms["enableSpecular"].value = this.params.enableSpecular;
      this.creatureShaderUniforms["enableReflection"].value = this.params.enableReflection;
      this.creatureShaderUniforms["uNormalScale"].value.set(this.params.normalMapScale, this.params.normalMapScale);
      this.creatureShaderUniforms["uReflectivity"].value = this.params.reflectionStrength;
      return this;
    };

    App.prototype.initLights = function() {
      this.sunLight = new THREE.DirectionalLight;
      this.sunLight.color.setRGB(this.params.sunColor[0] / 255, this.params.sunColor[1] / 255, this.params.sunColor[2] / 255);
      this.sunLight.position.set(0, 400, -400);
      this.sunLight.intensity = this.params.sunIntensity;
      this.sunLight.castShadow = true;
      this.sunLight.shadowCameraNear = 1;
      this.sunLight.shadowCameraFov = 70;
      this.sunLight.shadowMapWidth = 1024;
      this.sunLight.shadowMapHeight = 1024;
      this.sunLight.shadowCameraLeft = 150;
      this.sunLight.shadowCameraRight = -150;
      this.sunLight.shadowCameraTop = 250;
      this.sunLight.shadowCameraBottom = -250;
      this.scene.add(this.sunLight);
      this.ambientLight = new THREE.AmbientLight();
      this.ambientLight.color.setRGB(this.params.ambientColor[0] / 255, this.params.ambientColor[1] / 255, this.params.ambientColor[2] / 255);
      this.scene.add(this.ambientLight);
      return this;
    };

    App.prototype.initCreature = function(event) {
      var faceMaterial, geometry, loader, sc;
      geometry = event.content;
      geometry.computeTangents();
      faceMaterial = this.getFairyMaterial();
      faceMaterial.morphTargets = this.params.animated;
      this.creatureMesh = new THREE.MorphAnimMesh(geometry, faceMaterial);
      this.creatureMesh.name = "creature";
      this.creatureMesh.setAnimationLabel("idle", 0, 10);
      this.creatureMesh.setAnimationLabel("fly", 11, 29);
      this.creatureMesh.setAnimationLabel("interact", 30, 38);
      this.creatureMesh.castShadow = true;
      this.creatureMesh.receiveShadow = true;
      this.creatureMesh.duration = 1000;
      this.creatureMesh.position.set(100, 1000, -2500);
      sc = 1;
      this.creatureMesh.scale.set(sc, sc, sc);
      this.creatureMesh.matrixAutoUpdate = false;
      this.creatureMesh.updateMatrix();
      loader = new THREE.GeometryLoader();
      loader.addEventListener('load', this.initWings);
      loader.load("sophie/wing.js");
      return this;
    };

    App.prototype.initWings = function(event) {
      var geometry, mat, morphTargetsFake, tween,
        _this = this;
      geometry = event.content;
      geometry.computeTangents();
      mat = geometry.materials[0];
      mat.reflectivity = 1;
      mat.morphTargets = true;
      morphTargetsFake = [
        {
          name: "fake",
          vertices: geometry.vertices
        }
      ];
      geometry.morphTargets = morphTargetsFake;
      this.wingMesh = new THREE.Mesh(geometry, mat);
      this.creatureMesh.add(this.wingMesh);
      this.wingMesh2 = new THREE.Mesh(geometry, mat);
      this.wingMesh2.position.x -= 20;
      this.creatureMesh.add(this.wingMesh2);
      this.scene.add(this.creatureMesh);
      this.creatureMesh.add(this.sunLight);
      tween = new TWEEN.Tween(this.creatureMesh.position).to(new THREE.Vector3(0, -130, 0), 5000);
      tween.easing(TWEEN.Easing.Cubic.InOut);
      tween.onUpdate(function() {
        return _this.creatureMesh.updateMatrix();
      });
      tween.onComplete(function() {
        _this.creatureMesh.playAnimation("idle", _this.animFPS);
        return _this.currentAnimation = "idle";
      });
      tween.start();
      this.animate();
      return this;
    };

    App.prototype.initSky = function() {
      var format, geom, path, urls;
      path = "textures/cube/forest/";
      format = '.jpg';
      urls = [path + 'posx' + format, path + 'negx' + format, path + 'posy' + format, path + 'negy' + format, path + 'posz' + format, path + 'negz' + format];
      this.skyCubeTexture = THREE.ImageUtils.loadTextureCube(urls);
      this.skyCubeTexture.format = THREE.RGBFormat;
      geom = new THREE.CubeGeometry(3000, 3000, 3000);
      if (this.params.animated) {
        geom.morphTargets[0] = {
          name: "fake",
          vertices: geom.vertices
        };
      }
      this.skyCube = new THREE.Mesh(geom, this.getCubeMaterial());
      this.skyCube.name = "skyCube";
      this.scene.add(this.skyCube);
      return this;
    };

    App.prototype.initRenderPasses = function() {
      var bluriness;
      this.renderPass = new THREE.RenderPass(this.scene, this.camera, null, false, false);
      bluriness = 1;
      this.hblur = new THREE.ShaderPass(THREE.ShaderExtras["horizontalTiltShift"]);
      this.hblur.uniforms['h'].value = bluriness / this.SCREEN_WIDTH;
      this.hblur.renderToScreen = false;
      this.vblur = new THREE.ShaderPass(THREE.ShaderExtras["verticalTiltShift"]);
      this.vblur.uniforms['v'].value = bluriness / this.SCREEN_HEIGHT;
      this.vblur.renderToScreen = false;
      this.hblur.uniforms['r'].value = this.vblur.uniforms['r'].value = 0.5;
      this.colorCorr = new THREE.ShaderPass(THREE.ShaderExtras["colorCorrection"]);
      this.colorCorr.uniforms['powRGB'].value = new THREE.Vector3(2, 2, 2);
      this.colorCorr.uniforms['mulRGB'].value = new THREE.Vector3(1, 1, 1);
      this.colorCorr.renderToScreen = false;
      this.fxaa = new THREE.ShaderPass(THREE.ShaderExtras["fxaa"]);
      this.fxaa.uniforms['resolution'].value = new THREE.Vector2(1 / this.SCREEN_WIDTH, 1 / this.SCREEN_HEIGHT);
      this.fxaa.renderToScreen = false;
      this.bleach = new THREE.ShaderPass(THREE.ShaderExtras["bleachbypass"]);
      this.bleach.renderToScreen = false;
      this.bloom = new THREE.BloomPass(this.params.bloomIntensity);
      this.bloom.renderToScreen = false;
      this.film = new THREE.FilmPass(0.35, 0.95, this.SCREEN_HEIGHT * 2, false);
      this.film.uniforms['sCount'].value = this.SCREEN_HEIGHT * 2;
      this.film.uniforms['sIntensity'].value = this.params.filmEffectScanlinesIntensity;
      this.film.uniforms['nIntensity'].value = this.params.filmEffectNoiseIntensity;
      this.film.renderToScreen = false;
      this.renderToScreenPass = new THREE.ShaderPass(THREE.ShaderExtras["screen"]);
      return this;
    };

    App.prototype.initComposer = function(event) {
      var lastEffect;
      if (this.params.enableGodRays) {
        this.renderTarget = this.postprocessing.rtTextureColors;
      } else {
        this.renderTargetParameters = {
          minFilter: THREE.LinearFilter,
          magFilter: THREE.LinearFilter,
          format: THREE.RGBFormat
        };
        this.renderTarget = new THREE.WebGLRenderTarget(this.SCREEN_WIDTH, this.SCREEN_HEIGHT, this.renderTargetParameters);
      }
      this.composer = new THREE.EffectComposer(this.renderer, this.renderTarget);
      this.composer.addPass(this.renderPass);
      lastEffect = false;
      if (this.params.enableBloom != null) this.composer.addPass(this.bloom);
      if (this.params.enableFXAA) {
        this.composer.addPass(this.fxaa);
        this.fxaa.renderToScreen = false;
        lastEffect = this.fxaa;
      }
      if (this.params.enableFilmEffect) {
        this.composer.addPass(this.film);
        this.film.renderToScreen = false;
        lastEffect = this.film;
      }
      if (!lastEffect) {
        this.renderToScreenPass.renderToScreen = !this.params.enableGodRays;
        this.composer.addPass(this.renderToScreenPass);
      } else {
        lastEffect.renderToScreen = !this.params.enableGodRays;
      }
      return this;
    };

    App.prototype.getCubeMaterial = function() {
      var cubeShader, material;
      cubeShader = THREE.ShaderUtils.lib["cube"];
      cubeShader.uniforms["tCube"].value = this.skyCubeTexture;
      material = new THREE.ShaderMaterial({
        fragmentShader: cubeShader.fragmentShader,
        vertexShader: cubeShader.vertexShader,
        uniforms: cubeShader.uniforms,
        depthWrite: false,
        side: THREE.BackSide
      });
      return material;
    };

    App.prototype.getFairyMaterial = function() {
      var ambient, diffuse, material, shader, shininess, specular;
      ambient = 0x505050;
      diffuse = 0xbbbbbb;
      specular = 0x111111;
      shininess = 0.1;
      shader = THREE.ShaderUtils.lib["normal"];
      this.creatureShaderUniforms = THREE.UniformsUtils.clone(shader.uniforms);
      this.creatureShaderUniforms["tDiffuse"].value = THREE.ImageUtils.loadTexture("sophie/texturemapfairy.jpg");
      this.creatureShaderUniforms["enableDiffuse"].value = true;
      this.creatureShaderUniforms["tSpecular"].value = THREE.ImageUtils.loadTexture("sophie/specularfairy.jpg");
      this.creatureShaderUniforms["tAO"].value = THREE.ImageUtils.loadTexture("sophie/ao.png");
      this.creatureShaderUniforms["tNormal"].value = THREE.ImageUtils.loadTexture("sophie/normal-tangent-last.jpg");
      this.onCreatureShaderChange();
      this.creatureShaderUniforms["tCube"].value = this.skyCubeTexture;
      this.creatureShaderUniforms["uDiffuseColor"].value.setHex(diffuse);
      this.creatureShaderUniforms["uSpecularColor"].value.setHex(specular);
      this.creatureShaderUniforms["uAmbientColor"].value.setHex(ambient);
      this.creatureShaderUniforms["uShininess"].value = shininess;
      this.creatureShaderUniforms["wrapRGB"].value.set(0.575, 0.5, 0.5);
      material = new THREE.ShaderMaterial({
        fragmentShader: shader.fragmentShader,
        vertexShader: shader.vertexShader,
        uniforms: this.creatureShaderUniforms,
        lights: true,
        morphTargets: this.params.animated
      });
      material.wrapAround = true;
      return material;
    };

    App.prototype.onDocumentMouseClick = function(event) {
      console.log(this.mouseOverCreature);
      if (this.mouseOverCreature && this.params.animated && this.currentAnimation === "idle") {
        this.creatureMesh.playAnimation("interact", this.animFPS);
        return this.currentAnimation = "interact";
      }
    };

    App.prototype.onDocumentMouseMove = function(event) {
      console.log('mousemove');
      return;
      this.mouseX = event.clientX - this.windowHalfX;
      this.mouseY = event.clientY - this.windowHalfY;
      this.pickMouse.x = (event.clientX / window.innerWidth) * 2 - 1;
      return this.pickMouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
    };

    App.prototype.onDocumentTouchStart = function(event) {
      var mouseX, mouseY;
      if (event.touches.length === 1) {
        event.preventDefault();
        mouseX = event.touches[0].pageX - this.windowHalfX;
        return mouseY = event.touches[0].pageY - this.windowHalfY;
      }
    };

    App.prototype.onDocumentTouchMove = function(event) {
      if (event.touches.length === 1) {
        event.preventDefault();
        this.mouseX = event.touches[0].pageX - this.windowHalfX;
        return this.mouseY = event.touches[0].pageY - this.windowHalfY;
      }
    };

    App.prototype.onWindowResize = function(event) {
      this.SCREEN_WIDTH = window.innerWidth;
      this.SCREEN_HEIGHT = window.innerHeight;
      this.windowHalfX = this.SCREEN_WIDTH >> 1;
      this.windowHalfY = this.SCREEN_HEIGHT >> 1;
      this.renderer.setSize(this.SCREEN_WIDTH, this.SCREEN_HEIGHT);
      this.camera.aspect = this.postprocessing.camera.aspect = this.SCREEN_WIDTH / this.SCREEN_HEIGHT;
      this.camera.updateProjectionMatrix();
      this.postprocessing.camera.updateProjectionMatrix();
      this.fxaa.uniforms['resolution'].value = new THREE.Vector2(1 / this.SCREEN_WIDTH, 1 / this.SCREEN_HEIGHT);
      this.film.uniforms['sCount'].value = this.SCREEN_HEIGHT * 2;
      this.initPostprocessingRenderTargets();
      this.initComposer();
      return this;
    };

    App.prototype.initPostprocessing = function() {
      var godraysCombineShader, godraysGenShader;
      this.postprocessing.scene = new THREE.Scene();
      this.postprocessing.camera = new THREE.OrthographicCamera(this.SCREEN_WIDTH / -2, this.SCREEN_WIDTH / 2, this.SCREEN_HEIGHT / 2, this.SCREEN_HEIGHT / -2, -10000, 10000);
      this.postprocessing.camera.position.z = 1000;
      this.postprocessing.scene.add(this.postprocessing.camera);
      this.initPostprocessingRenderTargets();
      godraysGenShader = THREE.ShaderGodRays["godrays_generate"];
      this.postprocessing.godrayGenUniforms = THREE.UniformsUtils.clone(godraysGenShader.uniforms);
      this.postprocessing.materialGodraysGenerate = new THREE.ShaderMaterial({
        uniforms: this.postprocessing.godrayGenUniforms,
        vertexShader: godraysGenShader.vertexShader,
        fragmentShader: godraysGenShader.fragmentShader
      });
      godraysCombineShader = THREE.ShaderGodRays["godrays_combine"];
      this.postprocessing.godrayCombineUniforms = THREE.UniformsUtils.clone(godraysCombineShader.uniforms);
      this.postprocessing.materialGodraysCombine = new THREE.ShaderMaterial({
        uniforms: this.postprocessing.godrayCombineUniforms,
        vertexShader: godraysCombineShader.vertexShader,
        fragmentShader: godraysCombineShader.fragmentShader
      });
      this.postprocessing.quad = new THREE.Mesh(new THREE.PlaneGeometry(this.SCREEN_WIDTH, this.SCREEN_HEIGHT), this.postprocessing.materialGodraysGenerate);
      this.postprocessing.scene.add(this.postprocessing.quad);
      return this;
    };

    App.prototype.initPostprocessingRenderTargets = function() {
      var h, pars, w;
      pars = {
        minFilter: THREE.LinearFilter,
        magFilter: THREE.LinearFilter,
        format: THREE.RGBFormat
      };
      this.postprocessing.rtTextureColors = new THREE.WebGLRenderTarget(this.SCREEN_WIDTH, this.SCREEN_HEIGHT, pars);
      w = this.SCREEN_WIDTH / 4.0;
      h = this.SCREEN_HEIGHT / 4.0;
      this.postprocessing.rtTextureDepth = new THREE.WebGLRenderTarget(w, h, pars);
      this.postprocessing.rtTextureGodRays1 = new THREE.WebGLRenderTarget(w, h, pars);
      this.postprocessing.rtTextureGodRays2 = new THREE.WebGLRenderTarget(w, h, pars);
      return this;
    };

    App.prototype.animate = function() {
      var currKey, delta;
      window.requestAnimationFrame(this.animate);
      TWEEN.update();
      delta = this.clock.getDelta();
      if (this.creatureMesh && this.params.animated) {
        this.creatureMesh.updateAnimation(delta * 200);
        currKey = this.creatureMesh.currentKeyframe;
        if (!this.currentAnimation) {
          this.creatureMesh.playAnimation("fly", this.animFPS);
          this.currentAnimation = "fly";
        }
        if (this.currentAnimation === "interact") {
          if (this.lastKeyFrame > currKey) {
            this.creatureMesh.playAnimation("idle", this.animFPS);
            this.currentAnimation = "idle";
          }
        }
        this.lastKeyFrame = currKey;
      }
      this.render();
      return this.stats.update();
    };

    App.prototype.render = function() {
      var TAPS_PER_PASS, dandelion, distance, filterLen, i, intersects, over, pass, ray, stepLen, time, vector, _ref, _ref2;
      time = Date.now() / 4000;
      this.sunLight.position.x = 50 * Math.cos(time * 5);
      this.sunLight.position.y = 50 * Math.sin(time * 3) + 200;
      this.sunLight.updateMatrix();
      if (this.wingMesh && this.wingMesh2) {
        this.wingAnim++;
        if (this.wingAnim % 4 === 0) {
          this.wingMesh.rotation.y = (Math.PI / 4) + (Math.random() * .1);
          this.wingMesh2.rotation.y = -(Math.PI / 4) - (Math.random() * .1);
        } else {
          this.wingMesh.rotation.y = Math.random() * .1;
          this.wingMesh2.rotation.y = -(Math.random() * .1);
        }
      }
      for (i = 0, _ref = this.dandelionMeshes.length - 1; 0 <= _ref ? i <= _ref : i >= _ref; 0 <= _ref ? i++ : i--) {
        dandelion = this.dandelionMeshes[i];
        distance = dandelion.position.distanceTo(this.scene.position);
        if (!dandelion.CCW) {
          dandelion.position.x += Math.cos(time) / dandelion.speed;
          dandelion.position.y += Math.sin(time) / dandelion.speed;
        } else {
          dandelion.position.x -= Math.cos(time) / dandelion.speed;
          dandelion.position.y -= Math.sin(time) / dandelion.speed;
        }
        dandelion.lookAt(this.camera.position);
        dandelion.rotation.z = (Math.PI / 4) * Math.sin(time * dandelion.speed);
        dandelion.updateMatrix();
      }
      this.camera.position.x += (this.mouseX - this.camera.position.x) * 0.016;
      this.camera.position.y += (-this.mouseY - this.camera.position.y) * 0.016;
      this.camera.position.x = Math.max(-200, Math.min(200, this.camera.position.x));
      this.camera.position.y = Math.max(-60, Math.min(60, this.camera.position.y));
      this.camera.lookAt(this.scene.position);
      vector = new THREE.Vector3(this.pickMouse.x, this.pickMouse.y, 1);
      this.projector.unprojectVector(vector, this.camera);
      ray = new THREE.Ray(this.camera.position, vector.subSelf(this.camera.position).normalize());
      intersects = ray.intersectObjects(this.scene.children);
      over = false;
      for (i = 0, _ref2 = intersects.length - 1; 0 <= _ref2 ? i <= _ref2 : i >= _ref2; 0 <= _ref2 ? i++ : i--) {
        if (intersects[i].object === this.creatureMesh) over = true;
      }
      this.mouseOverCreature = over;
      if (this.params.enableGodRays) {
        this.postprocessing.godrayCombineUniforms.fGodRayIntensity.value = this.params.godRaysIntensity;
        this.postprocessing.godrayCombineUniforms.vRayColors.value.x = this.params.godRaysColor[0] / 255;
        this.postprocessing.godrayCombineUniforms.vRayColors.value.y = this.params.godRaysColor[1] / 255;
        this.postprocessing.godrayCombineUniforms.vRayColors.value.z = this.params.godRaysColor[2] / 255;
        this.screenSpacePosition.copy(this.sunLight.position);
        this.projector.projectVector(this.screenSpacePosition, this.camera);
        this.screenSpacePosition.x = (this.screenSpacePosition.x + 1) / 2;
        this.screenSpacePosition.y = (this.screenSpacePosition.y + 1) / 2;
        this.postprocessing.godrayGenUniforms["vSunPositionScreenSpace"].value.x = this.screenSpacePosition.x;
        this.postprocessing.godrayGenUniforms["vSunPositionScreenSpace"].value.y = this.screenSpacePosition.y;
        this.renderer.clearTarget(this.postprocessing.rtTextureColors, true, true, false);
        this.scene.overrideMaterial = null;
        this.composer.render(0.1);
        this.scene.overrideMaterial = this.materialDepth;
        this.renderer.render(this.scene, this.camera, this.postprocessing.rtTextureDepth, true);
        filterLen = 1.0;
        TAPS_PER_PASS = 6.0;
        pass = 1.0;
        stepLen = filterLen * Math.pow(TAPS_PER_PASS, -pass);
        this.postprocessing.godrayGenUniforms["fStepSize"].value = stepLen;
        this.postprocessing.godrayGenUniforms["tInput"].value = this.postprocessing.rtTextureDepth;
        this.postprocessing.scene.overrideMaterial = this.postprocessing.materialGodraysGenerate;
        this.renderer.render(this.postprocessing.scene, this.postprocessing.camera, this.postprocessing.rtTextureGodRays2);
        pass = 2.0;
        stepLen = filterLen * Math.pow(TAPS_PER_PASS, -pass);
        this.postprocessing.godrayGenUniforms["fStepSize"].value = stepLen;
        this.postprocessing.godrayGenUniforms["tInput"].value = this.postprocessing.rtTextureGodRays2;
        this.renderer.render(this.postprocessing.scene, this.postprocessing.camera, this.postprocessing.rtTextureGodRays1);
        pass = 3.0;
        stepLen = filterLen * Math.pow(TAPS_PER_PASS, -pass);
        this.postprocessing.godrayGenUniforms["fStepSize"].value = stepLen;
        this.postprocessing.godrayGenUniforms["tInput"].value = this.postprocessing.rtTextureGodRays1;
        this.renderer.render(this.postprocessing.scene, this.postprocessing.camera, this.postprocessing.rtTextureGodRays2);
        this.postprocessing.godrayCombineUniforms["tColors"].value = this.postprocessing.rtTextureColors;
        this.postprocessing.godrayCombineUniforms["tGodRays"].value = this.postprocessing.rtTextureGodRays2;
        this.postprocessing.scene.overrideMaterial = this.postprocessing.materialGodraysCombine;
        this.renderer.render(this.postprocessing.scene, this.postprocessing.camera);
        return this.postprocessing.scene.overrideMaterial = null;
      } else {
        this.renderer.clear();
        return this.composer.render(0.1);
      }
    };

    App;

    return App;

  })();

}).call(this);
