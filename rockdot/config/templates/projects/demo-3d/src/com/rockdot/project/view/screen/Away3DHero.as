package com.rockdot.project.view.screen {
	import away3d.animators.SkeletonAnimationSet;
	import away3d.animators.SkeletonAnimator;
	import away3d.animators.data.Skeleton;
	import away3d.animators.nodes.SkeletonClipNode;
	import away3d.animators.transitions.CrossfadeTransition;
	import away3d.cameras.Camera3D;
	import away3d.containers.Scene3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.AssetEvent;
	import away3d.events.LoaderEvent;
	import away3d.events.Stage3DEvent;
	import away3d.library.AssetLibrary;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.loaders.parsers.AWD2Parser;
	import away3d.materials.ColorMaterial;
	import away3d.materials.TextureMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.DitheredShadowMapMethod;
	import away3d.materials.methods.FogMethod;
	import away3d.materials.methods.FresnelSpecularMethod;
	import away3d.materials.methods.RimLightMethod;
	import away3d.primitives.PlaneGeometry;
	import away3d.textures.BitmapTexture;

	import com.jvm.utils.DeviceDetector;
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.core.mvc.RockdotEvent;
	import com.rockdot.library.view.component.common.box.VBox;
	import com.rockdot.plugin.screen.displaylist3d.view.RockdotManagedSpriteComponent3D;
	import com.rockdot.plugin.state.command.event.StateEvents;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.element.SimpleButton;
	import com.rockdot.project.view.helper.HeroMapper;
	import com.rockdot.project.view.text.Copy;
	import com.rockdot.project.view.text.Headline;

	import flash.display.Bitmap;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.ui.Keyboard;






	
	/**
	 * Taken from http://away3d.com/example/3ds_Max_workflow
	 * Optimized a bit.
	 */
	public class Away3DHero extends RockdotManagedSpriteComponent3D
	{
		
		private var modelTexture:BitmapTexture;
		private const DemoColor:Array = [0xffffff, 0x99AAff, 0x222233];
		
		//engine variables
		private var scene:Scene3D;
		private var camera:Camera3D;
		private var view:View3D;
		private var awayStats:AwayStats;
		
		//animation variables
		private var skeleton:Skeleton;
		private var animationSet:SkeletonAnimationSet;
		private var animator:SkeletonAnimator;
		private var breatheState:SkeletonClipNode;
		private var walkState:SkeletonClipNode;
		private var runState:SkeletonClipNode;
		private var crossfadeTransition:CrossfadeTransition;
		private var isRunning:Boolean;
		private var isMoving:Boolean;
		private var movementDirection:Number;
		private var currentAnim:String;
		private var currentRotationInc:Number = 0;
		
		//animation constants
		private const ANIM_BREATHE:String = "Breathe";
		private const ANIM_WALK:String = "Walk";
		private const ANIM_RUN:String = "Run";
		private const XFADE_TIME:Number = 0.5;
		private const ROTATION_SPEED:Number = 3;
		private const RUN_SPEED:Number = 2;
		private const WALK_SPEED:Number = 1;
		private const BREATHE_SPEED:Number = 1;
		
		//light objects
		private var sunLight:DirectionalLight;
		private var skyLight:PointLight;
		private var lightPicker:StaticLightPicker;
		
		//material objects
		private var groundMaterial:ColorMaterial;
		
		//scene objects
		private var hero:Mesh;
		private var ground:Mesh;
		
		private var hoverController:HoverController;
		private var _prevMouseX:Number;
		private var _prevMouseY:Number;
		
		
		[Embed(source="/../resources/away3d/hero/MaxAWDWorkflow.awd", mimeType="application/octet-stream")] 
		private var AWD_MESH:Class; 

		[Embed(source="/../resources/away3d/hero/onkba_256.jpg")] 
		private var TEXTURE:Class; 
		
		private var assetsThatAreloaded:int = 0;
		private var assetsToLoad : int = 1;
		private var _copy : Copy;
		private var _btnToggle : SimpleButton;
		private var _enterFrameCounter : int = 0;
		private var _vbox : VBox;
		
		/**
		 * Constructor
		 */
		public function Away3DHero(id : String) {
			super(id);
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);
			
			_vbox = new VBox(BootstrapConstants.SPACER);
			_vbox.ignoreCallSetSize = true;
			addChild(_vbox);
			
			var head : Headline = new Headline(getProperty("headline"), 24, Colors.BLACK);
			_vbox.addChild(head);
			
			_copy = new Copy(getProperty("copy"), 24, Colors.BLACK);
			_copy.filters = [new DropShadowFilter(1, 45, 0x0, 1, 0, 0)];
			_vbox.addChild(_copy);
			

			var button : SimpleButton;
			button = new SimpleButton(getProperty("button.back"), _width, BootstrapConstants.HEIGHT_RASTER);
			button .submitEvent = new RockdotEvent(StateEvents.ADDRESS_SET, getProperty("page.home.url", true));
			button .ignoreCallSetSize = false;
			_vbox.addChild(button);

			_btnToggle = new SimpleButton(getProperty("button.toggle"), _width, BootstrapConstants.HEIGHT_RASTER);
			_btnToggle .submitCallback = _toggleCycle;
			_btnToggle .ignoreCallSetSize = false;
			_btnToggle .ignoreSetEnabled = true;
			_btnToggle .enabled = false;
			_vbox.addChild(_btnToggle);
		}

		override protected function _onContextCreated(event : Stage3DEvent) : void {
			initEngine();
			initLights();
			initLoading();
		}

		private function _toggleCycle() : void {
			isRunning = !isRunning;
			updateMovement(movementDirection = 1);
		}
		
		
		override public function render() : void {
			super.render();
			
			_vbox.setSize(_width - 2*BootstrapConstants.SPACER, _height - 2*BootstrapConstants.SPACER);
			_vbox.update();
			
			_vbox.x = BootstrapConstants.SPACER;
			_vbox.y = BootstrapConstants.SPACER;
			
			
			if(view){
				awayStats.x = _width - awayStats.width;
				awayStats.y = view.y = _vbox.height + _vbox.y + BootstrapConstants.SPACER;
				view.width = _width;
				
				var hgt : Number = _height - _vbox.height - 2 * BootstrapConstants.SPACER;
				view.height = hgt;
				_btnToggle.enabled = true;
			}
			
		}
		
		override public function destroy() : void {
			
			_removeListeners();
			
			// unlisten key presses
			stage.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);

			view.parent.removeChild(view);
//			view.dispose();
			camera.dispose();
			scene = null;
			AssetLibrary.removeAllAssets(true);
			
			_stageProxy.dispose();
			
			super.destroy();
		}
		
		/**
		 * Initialise the engine
		 */
		private function initEngine():void
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			scene = new Scene3D();
			
			camera = new Camera3D();
			camera.lens.far = 5000;
			camera.lens.near = 20;
			
			view = new View3D();
			view.stage3DProxy = _stageProxy;
			view.shareContext = true;
			view.backgroundColor = DemoColor[2];
			view.scene = scene;
			view.camera = camera;
			
			hoverController = new HoverController(camera);
			hoverController.tiltAngle = 0;
			hoverController.panAngle = 180;
			hoverController.minTiltAngle = -60;
			hoverController.maxTiltAngle = 60;
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onStageMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onStageMouseWheel);
			
			stage.addChild(view);
			
			awayStats = new AwayStats(view);
			addChild(awayStats);
			
			//create the ground plane
			groundMaterial = new ColorMaterial(0x333333);
			groundMaterial.addMethod(new FogMethod(1000, 3000, DemoColor[2]));
			groundMaterial.ambient = 0.25;
			ground = new Mesh(new PlaneGeometry(50000, 50000), groundMaterial);
			ground.geometry.scaleUV(50, 50);
			ground.y = -380;
			scene.addChild(ground);
		}
		
		private function showError(t:String):void
		{
			_copy.appendText(t);
			_log.debug("ERROR: " + t);
		}
		
		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			//create a light for shadows that mimics the sun's position in the skybox
			sunLight = new DirectionalLight(-1, -0.4, 1);
			sunLight.color = DemoColor[0];
			sunLight.castsShadows = true;
			sunLight.ambient = 1;
			sunLight.diffuse = 1;
			sunLight.specular = 1;
			scene.addChild(sunLight);
			
			//create a light for ambient effect that mimics the sky
			skyLight = new PointLight();
			skyLight.y = 500;
			skyLight.color = DemoColor[1];
			skyLight.diffuse = 1;
			skyLight.specular = 0.5;
			skyLight.radius = 2000;
			skyLight.fallOff = 2500;
			scene.addChild(skyLight);
			
			lightPicker = new StaticLightPicker([sunLight, skyLight]);
			
			// apply the lighting effects to the ground material
			groundMaterial.lightPicker = lightPicker;
			groundMaterial.shadowMethod = new DitheredShadowMapMethod(sunLight);
		}
		
		/**
		 * Initialise the scene objects
		 */
		private function initLoading():void
		{
			AssetLibrary.enableParser(AWD2Parser);
			AssetLibrary.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetComplete);
			AssetLibrary.addEventListener(LoaderEvent.RESOURCE_COMPLETE, onResourceComplete);
			AssetLibrary.addEventListener(LoaderEvent.LOAD_ERROR, onLoadError);
			
			AssetLibrary.loadData(new AWD_MESH());
		}
		
		protected function onLoadError(event:LoaderEvent):void
		{
			showError("Error loading: " + event.url);
		}
		
		/**
		 * Listener function for asset complete event on loader
		 */
		private function onAssetComplete(event:AssetEvent):void
		{
			// To not see these names output in the console, comment the
			// line below with two slash'es, just as you see on this line
			trace("Loaded " + event.asset.name + " Name: " + event.asset.name);
		}
		
		private function onResourceComplete(ev:LoaderEvent):void
		{
			assetsThatAreloaded++;
			// check to see if we have all we need
			if (assetsThatAreloaded == assetsToLoad) {
				setupScene();
			}
		}
		
		private function setupScene():void
		{
			// request all the things we loaded into the AssetLibrary
			skeleton = Skeleton(AssetLibrary.getAsset("Bone001"));
			breatheState = SkeletonClipNode(AssetLibrary.getAsset("Breathe"));
			walkState = SkeletonClipNode(AssetLibrary.getAsset("Walk"));
			runState = SkeletonClipNode(AssetLibrary.getAsset("Run"));
			var tex : Bitmap = new TEXTURE() as Bitmap;
			modelTexture = new BitmapTexture(tex.bitmapData);
			
			hero = Mesh(AssetLibrary.getAsset("ONKBA-Corps-lnew"));
			
			// prepare the model's texture material
			
			var material:TextureMaterial = new TextureMaterial(modelTexture);
			
			if(!DeviceDetector.IS_MOBILE){
				var autoMap:HeroMapper = new HeroMapper(modelTexture.bitmapData);
				var specularMethod:FresnelSpecularMethod = new FresnelSpecularMethod();
				specularMethod.normalReflectance = .4;
				
				material.normalMap = new BitmapTexture(autoMap.bitdata[1]);
				material.specularMap = new BitmapTexture(autoMap.bitdata[2]);
				material.specularMethod = specularMethod;
			}
			
			
			material.lightPicker = lightPicker;
			material.gloss = 40;
			material.specular = 0.5;
			material.ambientColor = 0xAAAAFF;
			material.ambient = 0.25;
			if(!DeviceDetector.IS_MOBILE){
				material.addMethod(new RimLightMethod(DemoColor[1], .4, 3, RimLightMethod.ADD));
			}
			
			// put our hero center stage and assign our material object
			hero.scale(8);
			hero.material = material;
			if(!DeviceDetector.IS_MOBILE){
				hero.castsShadows = true;
			}
			else{
				hero.castsShadows = false;
			}
			hero.z = 1000;
			hero.rotationY = -45;
			scene.addChild(hero);
			
			// Create an animation set object and add our state objects
			animationSet = new SkeletonAnimationSet(3);
			animationSet.addAnimation( breatheState);
			animationSet.addAnimation( walkState);
			animationSet.addAnimation( runState);
			
			//couple our animation set with our skeleton and wrap in an animator object and apply to our mesh object
			animator = new SkeletonAnimator(animationSet, skeleton);
//			animator.updateRootPosition = false;
			hero.animator = animator;
			
			//create our crossfade transition object
			crossfadeTransition = new CrossfadeTransition(XFADE_TIME);
			
			if (animationSet.hasAnimation("Breathe") && animationSet.hasAnimation("Walk") && animationSet.hasAnimation("Run")) {
				hoverController.lookAtObject = hero; // point the camera at the hero
				goToPauseState(); // starts the "breathe" animation
				_initListeners(); // get ready for user input
				_didInit();
			} else {
				showError("Animation error");
			}
		}
		
		
		
		/**
		 * Initialise the listeners
		 */
		override protected function _initListeners() : void {
			super._initListeners();
			// start calling the
			// Listen for key presses
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}

		override protected function _onEnterFrame(event : Event) : void {
			//half render rate on mobile
			if(DeviceDetector.IS_MOBILE && ++_enterFrameCounter%2){
				return;
			}
			
			//update character animation
			if (hero) hero.rotationY += currentRotationInc;
			
			skyLight.x = camera.x;
			skyLight.y = camera.y;
			skyLight.z = camera.z;
			view.render();
		}
		
		/**
		 * Key down listener for animation
		 */
		private function onKeyDown(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.SHIFT:
					isRunning = true;
					if (isMoving)
						updateMovement(movementDirection);
					break;
				case Keyboard.UP:
				case Keyboard.W:
					updateMovement(movementDirection = 1);
					break;
				case Keyboard.DOWN:
				case Keyboard.S:
					updateMovement(movementDirection = -1);
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
					currentRotationInc = -ROTATION_SPEED;
					break;
				case Keyboard.RIGHT:
				case Keyboard.D:
					currentRotationInc = ROTATION_SPEED;
					break;
			}
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			switch (event.keyCode) {
				case Keyboard.SHIFT:
					isRunning = false;
					if (isMoving)
						updateMovement(movementDirection);
					break;
				case Keyboard.UP:
				case Keyboard.W:
				case Keyboard.DOWN:
				case Keyboard.S:
					goToPauseState();
					break;
				case Keyboard.LEFT:
				case Keyboard.A:
				case Keyboard.RIGHT:
				case Keyboard.D:
					currentRotationInc = 0;
					break;
			}
		}
		
		private function updateMovement(dir:Number):void
		{
			isMoving = true;
			
			//update animator speed
			animator.playbackSpeed = dir * (isRunning ? RUN_SPEED : WALK_SPEED);
			
			//update animator sequence
			var anim:String = isRunning ? ANIM_RUN : ANIM_WALK;
			if (currentAnim == anim)
				return;
			
			currentAnim = anim;
			
			animator.play(currentAnim, crossfadeTransition);
		}
		
		private function goToPauseState():void
		{
			isMoving = false;
			
			//update animator speed
			animator.playbackSpeed = BREATHE_SPEED;
			
			//update animator sequence
			if (currentAnim == ANIM_BREATHE)
				return;
			
			currentAnim = ANIM_BREATHE;
			
			animator.play(currentAnim, crossfadeTransition);
		}
		
		private function onStageMouseDown(ev:MouseEvent):void
		{
			_prevMouseX = ev.stageX;
			_prevMouseY = ev.stageY;
		}
		
		private function onStageMouseMove(ev:MouseEvent):void
		{
			if (ev.buttonDown) {
				hoverController.panAngle += (ev.stageX - _prevMouseX);
				hoverController.tiltAngle += (ev.stageY - _prevMouseY);
			}
			
			_prevMouseX = ev.stageX;
			_prevMouseY = ev.stageY;
		}
		
		private function onStageMouseWheel(ev:MouseEvent):void
		{
			hoverController.distance -= ev.delta * 5;
			
			if (hoverController.distance < 100)
				hoverController.distance = 100;
			else if (hoverController.distance > 2000)
				hoverController.distance = 2000;
		}

		
	}
}
