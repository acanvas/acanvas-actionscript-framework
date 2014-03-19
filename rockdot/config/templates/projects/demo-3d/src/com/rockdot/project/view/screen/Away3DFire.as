package com.rockdot.project.view.screen {
	import away3d.animators.ParticleAnimationSet;
	import away3d.animators.ParticleAnimator;
	import away3d.animators.data.ParticleProperties;
	import away3d.animators.data.ParticlePropertiesMode;
	import away3d.animators.nodes.ParticleAccelerationNode;
	import away3d.animators.nodes.ParticleBillboardNode;
	import away3d.animators.nodes.ParticleColorNode;
	import away3d.animators.nodes.ParticleFollowNode;
	import away3d.animators.nodes.ParticlePositionNode;
	import away3d.animators.nodes.ParticleScaleNode;
	import away3d.animators.nodes.ParticleVelocityNode;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.ObjectContainer3D;
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.core.base.Geometry;
	import away3d.core.base.ParticleGeometry;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.Stage3DEvent;
	import away3d.lights.DirectionalLight;
	import away3d.lights.PointLight;
	import away3d.materials.TextureMaterial;
	import away3d.materials.TextureMultiPassMaterial;
	import away3d.materials.lightpickers.StaticLightPicker;
	import away3d.materials.methods.FogMethod;
	import away3d.primitives.PlaneGeometry;
	import away3d.tools.helpers.ParticleGeometryHelper;
	import away3d.utils.Cast;

	import awayphysics.collision.shapes.AWPBoxShape;
	import awayphysics.collision.shapes.AWPSphereShape;
	import awayphysics.dynamics.AWPDynamicsWorld;
	import awayphysics.dynamics.AWPRigidBody;

	import com.rockdot.plugin.screen.displaylist3d.view.RockdotManagedSpriteComponent3D;

	import flash.display.BlendMode;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Vector3D;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;

	public class Away3DFire extends RockdotManagedSpriteComponent3D
	{

		//----------------------------------------------------------
		//
		//   Static Property 
		//
		//----------------------------------------------------------

		//fire texture
		[Embed(source = "/../resources/away3d/fire/bluelight.png")]
		public static var FireTexture:Class;

		//plane textures
		[Embed(source = "/../resources/away3d/fire/floor_diffuse.jpg")]
		public static var FloorDiffuse:Class;
		[Embed(source = "/../resources/away3d/fire/floor_specular.jpg")]
		public static var FloorSpecular:Class;
		[Embed(source = "/../resources/away3d/fire/floor_normal.jpg")]
		public static var FloorNormals:Class;

		private static const NUM_FIRES:uint = 20;

		//----------------------------------------------------------
		//
		//   Constructor 
		//
		//----------------------------------------------------------
		public function Away3DFire(id : String)
		{
				super(id);
		}

		//----------------------------------------------------------
		//
		//   Property 
		//
		//----------------------------------------------------------

		private var cameraController:HoverController;
		private var collisions:Vector.<AWPRigidBody>;
		private var countFrame:int = 0;
		private var countStep:int = 0;
		private var easeDistance:Number = 2000;
		private var fireAnimationSet:ParticleAnimationSet;
		private var fireObjects:Vector.<FireVO> = new Vector.<FireVO>();
		private var lastMouseX:Number;
		private var lastMouseY:Number;
		private var lastPanAngle:Number;
		private var lastTiltAngle:Number;
		private var lightDirectional:DirectionalLight;
		private var lightPicker:StaticLightPicker;
		private var move:Boolean = false;
		private var particleAccelerationNode:ParticleAccelerationNode;
		private var particleFollowNode:ParticleFollowNode;
		private var particleGeometry:ParticleGeometry;
		private var particleMaterial:TextureMaterial;
		private var particleScaleNode:ParticleScaleNode;
		private var physicsWorld:AWPDynamicsWorld;
		private var planeMaterial:TextureMultiPassMaterial;
		private var timeStep:Number = 1.0 / 60;
		private var view:View3D;

		//----------------------------------------------------------
		//
		//   Function 
		//
		//----------------------------------------------------------

		override public function init(data : * = null) : void {
			super.init(data);

			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.LOW;
		}
		override protected function _onContextCreated(event : Stage3DEvent) : void {
			super._onContextCreated(event);
			
			view = new View3D();
			view.antiAlias = 0;
			view.camera.lens.far = 20000;
			(view.camera.lens as PerspectiveLens).fieldOfView = 70;
			this.addChild(view);
			this.addChild(new AwayStats(view, true, false));

			//setup controller to be used on the camera
			cameraController = new HoverController(view.camera);
			cameraController.distance = easeDistance;
			cameraController.minTiltAngle = -3;
			cameraController.maxTiltAngle = 40;
			cameraController.panAngle = 45;
			cameraController.tiltAngle = 5;
			cameraController.steps = 20;

			// init the physics world
			physicsWorld = AWPDynamicsWorld.getInstance();
			physicsWorld.initWithDbvtBroadphase();
			physicsWorld.gravity = new Vector3D(0, -75, 0);

			reset();
			initLights();
			initMaterials();
			initParticles();
			initObjects();
			_initListeners();
			Mouse.cursor = MouseCursor.HAND;
			
			
			_didInit();
		}

		/**
		 * Initialise the listeners
		 */
		override protected function _initListeners() : void {
			super._initListeners();
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, stage_mouseWheelHandler);
		}
		
		
		override public function destroy() : void {
			_removeListeners();			
			
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, stage_keyDownHandler);
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, stage_mouseWheelHandler);
			
			view.parent.removeChild(view);
//			view.dispose();
			
			_stageProxy.dispose();
			
			super.destroy();
		}

		/**
		 * Initialise the lights
		 */
		private function initLights():void
		{
			lightDirectional = new DirectionalLight(0, -1, 0.1);
			lightDirectional.castsShadows = false;
			lightDirectional.color = 0x993300;
			lightDirectional.diffuse = 1;
			lightDirectional.ambient = .0;
			lightDirectional.specular = 0.25;
			lightDirectional.ambientColor = 0x0;
			view.scene.addChild(lightDirectional);

			lightPicker = new StaticLightPicker([lightDirectional]);
		}

		/**
		 * Initialise the materials
		 */
		private function initMaterials():void
		{
			var fog:FogMethod = new FogMethod(3000, 4500, 0x0);

			planeMaterial = new TextureMultiPassMaterial(Cast.bitmapTexture(FloorDiffuse));
			planeMaterial.specularMap = Cast.bitmapTexture(FloorSpecular);
			planeMaterial.normalMap = Cast.bitmapTexture(FloorNormals);
			planeMaterial.lightPicker = lightPicker;
			planeMaterial.repeat = true;
			planeMaterial.smooth = false;
			planeMaterial.mipmap = false;
			planeMaterial.specular = 15;
			planeMaterial.addMethod(fog);

			particleMaterial = new TextureMaterial(Cast.bitmapTexture(FireTexture));
			particleMaterial.blendMode = BlendMode.ADD;
			particleMaterial.smooth = false;
			particleMaterial.mipmap = false;
			particleMaterial.alphaBlending = false;
		}

		/**
		 * Initialise the particles
		 */
		private function initParticles():void
		{
			//create the particle animation set
			fireAnimationSet = new ParticleAnimationSet(true, true);

			//add some animations which can control the particles:
			//the global animations can be set directly, because they influence all the particles with the same factor
			fireAnimationSet.addAnimation(new ParticleBillboardNode());
			fireAnimationSet.addAnimation(new ParticlePositionNode(ParticlePropertiesMode.LOCAL_STATIC));

			fireAnimationSet.addAnimation(particleScaleNode = new ParticleScaleNode(ParticlePropertiesMode.GLOBAL, false, false, 2, 0.5));

			fireAnimationSet.addAnimation(particleFollowNode = new ParticleFollowNode(true, false));

			fireAnimationSet.addAnimation(particleAccelerationNode = new ParticleAccelerationNode(0, new Vector3D(0, 1000, 0)));
			fireAnimationSet.addAnimation(new ParticleColorNode(ParticlePropertiesMode.GLOBAL, true, true, false, false, new ColorTransform(0, 0, 0, 1, 0xFF, 0x66, 0x22), new ColorTransform(0, 0, 0, 1, 0x99)));

			//no need to set the local animations here, because they influence all the particle with different factors.
			fireAnimationSet.addAnimation(new ParticleVelocityNode(ParticlePropertiesMode.LOCAL_STATIC));

			//set the initParticleFunc. It will be invoked for the local static property initialization of every particle
			fireAnimationSet.initParticleFunc = initParticleFunc;

			//create the original particle geometry
			var particle:Geometry = new PlaneGeometry(50, 50, 1, 1, false);

			//combine them into a list
			var geometrySet:Vector.<Geometry> = new Vector.<Geometry>;
			for (var i:int = 0; i < 50; i++)
				geometrySet.push(particle);

			particleGeometry = ParticleGeometryHelper.generateGeometry(geometrySet);
		}

		/**
		 * Initialise the scene objects
		 */
		private function initObjects():void
		{
			// create the terrain mesh
			var plane:Mesh = new Mesh(new PlaneGeometry(6000, 6000), planeMaterial);
			plane.geometry.scaleUV(6, 6);
			plane.y = 200;
			view.scene.addChild(plane);

			// create the terrain shape and rigidbody
			var earthShape:AWPBoxShape = new AWPBoxShape(50000, 200, 50000); // å¤§ãã‚ã®ã‚µã‚¤ã‚ºã§ç”¨æ„
			var earthBody:AWPRigidBody = new AWPRigidBody(earthShape, plane, 0);
			earthBody.friction = 0.9;
			earthBody.restitution = 0.5;
			earthBody.y = -500;
			physicsWorld.addRigidBody(earthBody);

			//create fire object meshes from geomtry and material, and apply particle animators to each
			for (var i:int = 0; i < NUM_FIRES; i++)
			{
				var particleMesh:Mesh = new Mesh(particleGeometry, particleMaterial);
				var animator:ParticleAnimator = new ParticleAnimator(fireAnimationSet);
				particleMesh.animator = animator;
				particleFollowNode.getAnimationState(animator).followTarget = collisions[i].skin;

				//create a fire object and add it to the fire object vector
				var fireObject:FireVO = new FireVO(particleMesh, animator);
				fireObjects.push(fireObject);
				view.scene.addChild(particleMesh);
				createFireLight(fireObject);
			}

			var particleMain:Mesh = new Mesh(particleGeometry, particleMaterial);
			particleMain.y = -300;
			var animatorMain:ParticleAnimator = new ParticleAnimator(fireAnimationSet);
			particleScaleNode.getAnimationState(animatorMain).maxScale = 15;
			particleAccelerationNode.getAnimationState(animatorMain).acceleration = new Vector3D(0, 10000, 0);
			particleMain.animator = animatorMain;
			animatorMain.start();
			view.scene.addChild(particleMain);
		}

		/**
		 * Returns an array of active lights in the scene
		 */
		private function getAllLights():Array
		{
			var lights:Array = [];

			lights.push(lightDirectional);

			for each (var fireVO:FireVO in fireObjects)
			{
				if (fireVO.light)
					lights.push(fireVO.light);
			}

			return lights;
		}

		/**
		 * Timer event handler
		 */
		private function createFireLight(fireObject:FireVO):void
		{
			//start the animator
			fireObject.animator.start();

			//create the lightsource
			var light:PointLight = new PointLight();
			light.color = 0xFF6622;
			light.diffuse = 0;
			light.specular = 0;
			light.position = fireObject.mesh.position;

			//add the lightsource to the fire object
			fireObject.light = light;

			//update the lightpicker
			lightPicker.lights = getAllLights();
		}

		/**
		 * Initialiser function for particle properties
		 */
		private function initParticleFunc(prop:ParticleProperties):void
		{
			prop.startTime = Math.random() * 2;
			prop.duration = Math.random() * 0.6 + 0.1;

			var r:Number = 600;
			prop[ParticleVelocityNode.VELOCITY_VECTOR3D] = new Vector3D(
				r * (Math.random() - 0.5),
				r * (Math.random() - 0.5),
				r * (Math.random() - 0.5));

			r = 10;
			prop[ParticlePositionNode.POSITION_VECTOR3D] = new Vector3D(
				r * (Math.random() - 0.5),
				r * (Math.random() - 0.5),
				r * (Math.random() - 0.5));
		}

		override protected function _onEnterFrame(e : Event) : void {
			if (move)
			{
				cameraController.panAngle = 0.4 * (stage.mouseX - lastMouseX) + lastPanAngle;
				cameraController.tiltAngle = 0.4 * (stage.mouseY - lastMouseY) + lastTiltAngle;
			}

			if (countFrame++ % 5 == 0)
			{
				var index:int = countStep % collisions.length;
				resetObject(collisions[index]);

				countStep++;
			}

			try
			{
				physicsWorld.step(timeStep);
			}
			catch (error:Error)
			{
				// ãŸã¾ã«ã‚¨ãƒ©ãƒ¼ãŒèµ·ãã‚‹ã®ã§å°å°
			}

			//animate lights
			var fireVO:FireVO;
			for (var i:int = 0; i < fireObjects.length; i++)
			{
				fireVO = fireObjects[i];
				//update flame light
				var light:PointLight = fireVO.light;

				if (fireVO.strength < 1)
					fireVO.strength += 0.1;

				if (light == null)
					continue;

				light.fallOff = 1080 + Math.random() * 20;
				light.radius = 1;
				light.diffuse = light.specular = fireVO.strength + Math.random() * .2;
				light.position = collisions[i].position;
			}

			view.render();
		}

		private function reset():void
		{
			var i:int;
			var body:AWPRigidBody;

			if (collisions == null)
			{
				// create rigidbody shapes
				var sphereShape:AWPSphereShape = new AWPSphereShape(30);

				collisions = new Vector.<AWPRigidBody>();

				for (i = 0; i < NUM_FIRES; i++)
				{
					// create cylinders
					var skin:ObjectContainer3D = new ObjectContainer3D();
					view.scene.addChild(skin);
					body = new AWPRigidBody(sphereShape, skin, 1);
					body.restitution = 0.75;
					physicsWorld.addRigidBody(body);
					collisions.push(body);
				}

				collisions.fixed = true;
			}

			for (i = 0; i < collisions.length; i++)
			{
				// create cylinders
				body = collisions[i];
				resetObject(body);
			}
		}

		private function resetObject(body:AWPRigidBody):void
		{
			body.position = resetPosition();
			body.clearForces();
			body.applyCentralForce(new Vector3D());
			body.applyImpulse(new Vector3D(
				5 * (Math.random() - 0.5),
				15 + 30 * Math.random(),
				5 * (Math.random() - 0.5)), new Vector3D(0, 0, 0));
		}

		private function resetPosition():Vector3D
		{
			const ROUND:int = 300;
			return new Vector3D(ROUND * (Math.random() - 0.5), -300, ROUND * (Math.random() - 0.5));
		}

		/**
		 * Mouse down listener for navigation
		 */
		private function onMouseDown(event:MouseEvent):void
		{
			lastPanAngle = cameraController.panAngle;
			lastTiltAngle = cameraController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
			move = true;
			stage.addEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}

		/**
		 * Mouse up listener for navigation
		 */
		private function onMouseUp(event:MouseEvent):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}

		/**
		 * Mouse stage leave listener for navigation
		 */
		private function onStageMouseLeave(event:Event):void
		{
			move = false;
			stage.removeEventListener(Event.MOUSE_LEAVE, onStageMouseLeave);
		}

		private function stage_mouseWheelHandler(event:MouseEvent):void
		{
			easeDistance -= event.delta * 5;

			if (easeDistance < 400)
				easeDistance = 400;
			else if (easeDistance > 3000)
				easeDistance = 3000;

			cameraController.distance = easeDistance;
		}

		private function stage_keyDownHandler(event:KeyboardEvent):void
		{
			if (event.keyCode == "F".charCodeAt())
			{
				if (stage.displayState == StageDisplayState.FULL_SCREEN)
					stage.displayState = StageDisplayState.NORMAL;
				else
					stage.displayState = StageDisplayState.FULL_SCREEN;
			}
		}

		override public function render() : void {
			super.render();
		
			view.width = _width;
			view.height = _height;
		}
	}
}

import away3d.animators.ParticleAnimator;
import away3d.entities.Mesh;
import away3d.lights.PointLight;

/**
 * Data class for the fire objects
 */
internal class FireVO
{

	//----------------------------------------------------------
	//
	//   Constructor 
	//
	//----------------------------------------------------------

	public function FireVO(mesh:Mesh, animator:ParticleAnimator):void
	{
		this.mesh = mesh;
		this.animator = animator;
	}

	//----------------------------------------------------------
	//
	//   Property 
	//
	//----------------------------------------------------------

	public var animator:ParticleAnimator;
	public var light:PointLight;
	public var mesh:Mesh;
	public var strength:Number = 0;
}