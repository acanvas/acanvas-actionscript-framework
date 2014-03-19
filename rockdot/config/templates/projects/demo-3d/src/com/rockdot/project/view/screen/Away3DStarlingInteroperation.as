package com.rockdot.project.view.screen {
	import away3d.containers.View3D;
	import away3d.controllers.HoverController;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.events.Stage3DEvent;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.WireframePlane;
	import away3d.textures.BitmapTexture;

	import starling.core.Starling;

	import com.rockdot.plugin.screen.displaylist3d.view.RockdotManagedSpriteComponent3D;
	import com.rockdot.project.view.element.StarlingCheckerboardSprite;
	import com.rockdot.project.view.element.StarlingStarsSprite;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;


	public class Away3DStarlingInteroperation extends RockdotManagedSpriteComponent3D
	{

		[Embed(source = "/../resources/starling/button.png")]
		private static const ButtonBitmap:Class;
		
		// Away3D view instances
		private var away3dView : View3D;
		
		// Camera controllers 
		private var hoverController : HoverController;
				
		// Materials
		private var cubeMaterial : TextureMaterial;

		// Objects
		private var cube1 : Mesh;
		private var cube2 : Mesh;
		private var cube3 : Mesh;
		private var cube4 : Mesh;
		private var cube5 : Mesh;
		
		// Runtime variables
		private var lastPanAngle : Number = 0;
		private var lastTiltAngle : Number = 0;
		private var lastMouseX : Number = 0;
		private var lastMouseY : Number = 0;
		private var mouseDown : Boolean;
		private var renderOrderDesc : TextField;
		private var renderOrder : int = 0;
		
		// Starling instances
		private var starlingStars:Starling;
		private var starlingCheckerboard:Starling;
				
		// Constants
		private const CHECKERS_CUBES_STARS:int = 0;
		private const STARS_CHECKERS_CUBES:int = 1;
		private const CUBES_STARS_CHECKERS : int = 2;
		private var awayStats : AwayStats;
		
		/**
		 * Constructor
		 */

		public function Away3DStarlingInteroperation(id : String)
		{
				super(id);
		}
		
		/**
		 * Global initialise function
		 */
		override public function init(data : * = null) : void {
			super.init(data);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
		}
		
		override protected function _onContextCreated(event : Stage3DEvent) : void {
			super._onContextCreated(event);
			
			initAway3D();
			initStarling();
			initMaterials();
			initObjects();
			initButton();
			_initListeners();

			_didInit();
		}

		
		override public function destroy() : void {
			_removeListeners();

//			removeChild(awayStats);
//			awayStats=null;
			starlingStars.stop();
			starlingCheckerboard.stop();
			away3dView.parent.removeChild(away3dView);
//			away3dView.dispose();
			_stageProxy.dispose();
			
			super.destroy();
		}
	
		/**
		 * Initialise the Away3D views
		 */
		private function initAway3D() : void
		{
			// Create the first Away3D view which holds the cube objects.
			away3dView = new View3D();
			away3dView.stage3DProxy = _stageProxy;
			away3dView.shareContext = true;

			hoverController = new HoverController(away3dView.camera, null, 45, 30, 1200, 5, 89.999);
			
			addChild(away3dView);
			
			awayStats = new AwayStats(away3dView);
			addChild(awayStats);
		}
		
		/**
		 * Initialise the Starling sprites
		 */
		private function initStarling() : void
		{
			// Create the Starling scene to add the checkerboard-background
			starlingCheckerboard = new Starling(StarlingCheckerboardSprite, stage, _stageProxy.viewPort, _stageProxy.stage3D);
		
			// Create the Starling scene to add the particle effect
			starlingStars = new Starling(StarlingStarsSprite, stage, _stageProxy.viewPort, _stageProxy.stage3D);
		}

		/**
		 * Initialise the materials
		 */
		private function initMaterials() : void {
			//Create a material for the cubes
			var cubeBmd:BitmapData = new BitmapData(128, 128, false, 0x0);
			cubeBmd.perlinNoise(7, 7, 5, 12345, true, true, 7, true);
			cubeMaterial = new TextureMaterial(new BitmapTexture(cubeBmd));
			cubeMaterial.gloss = 20;
			cubeMaterial.ambientColor = 0x808080;
			cubeMaterial.ambient = 1;
		}
		
		private function initObjects() : void {
			// Build the cubes for view 1
			var cG:CubeGeometry = new CubeGeometry(300, 300, 300);
			cube1 = new Mesh(cG, cubeMaterial);
			cube2 = new Mesh(cG, cubeMaterial);
			cube3 = new Mesh(cG, cubeMaterial);
			cube4 = new Mesh(cG, cubeMaterial);
			cube5 = new Mesh(cG, cubeMaterial);
			
			// Arrange them in a circle with one on the center
			cube1.x = -750; 
			cube2.z = -750;
			cube3.x = 750;
			cube4.z = 750;
			cube1.y = cube2.y = cube3.y = cube4.y = cube5.y = 150;
			
			// Add the cubes to view 1
			away3dView.scene.addChild(cube1);
			away3dView.scene.addChild(cube2);
			away3dView.scene.addChild(cube3);
			away3dView.scene.addChild(cube4);
			away3dView.scene.addChild(cube5);
			away3dView.scene.addChild(new WireframePlane(2500, 2500, 20, 20, 0xbbbb00, 1.5, WireframePlane.ORIENTATION_XZ));
		}
		
		/**
		 * Initialise the button to swap the rendering orders
		 */
		private function initButton() : void {
			this.graphics.beginFill(0x0, 0.7);
			this.graphics.drawRect(0, 0, stage.stageWidth, 100);
			this.graphics.endFill();

			var button:Sprite = new Sprite();
			button.x = 130;
			button.y = 5;
			button.addChild(new ButtonBitmap());
			button.addEventListener(MouseEvent.CLICK, onChangeRenderOrder);
			addChild(button);
			
			renderOrderDesc = new TextField();
			renderOrderDesc.defaultTextFormat = new TextFormat("_sans", 11, 0xffff00);
			renderOrderDesc.width = stage.stageWidth;
			renderOrderDesc.x = 300;
			renderOrderDesc.y = 5;
			addChild(renderOrderDesc);
			
			updateRenderDesc();
		}
		

		/**
		 * Set up the rendering processing event listeners
		 */
		 
		override protected function _initListeners() : void {
			super._initListeners();
			addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		
		override protected function _removeListeners() : void {
			super._removeListeners();
			removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}


		/**
		 * The main rendering loop
		 */
		override protected function _onEnterFrame(e:Event) : void {
			// Update the hovercontroller for view 1
			if (mouseDown) {
				hoverController.panAngle = 0.3 * (stage.mouseX - lastMouseX) + lastPanAngle;
				hoverController.tiltAngle = 0.3 * (stage.mouseY - lastMouseY) + lastTiltAngle;
			}

			// Update the scenes
			var starlingCheckerboardSprite:StarlingCheckerboardSprite = StarlingCheckerboardSprite.getInstance();
			if (starlingCheckerboardSprite)
				starlingCheckerboardSprite.update();
			
			// Use the selected rendering order
			if (renderOrder == CHECKERS_CUBES_STARS) {

				// Render the Starling animation layer
				starlingCheckerboard.nextFrame();
				
				// Render the Away3D layer
//				away3dView.render();

				// Render the Starling stars layer
				starlingStars.nextFrame();

			} else if (renderOrder == STARS_CHECKERS_CUBES) {

				// Render the Starling stars layer
				starlingStars.nextFrame();
				
				// Render the Starling animation layer
				starlingCheckerboard.nextFrame();

				// Render the Away3D layer
				away3dView.render();

			} else {

				// Render the Away3D layer
				away3dView.render();

				// Render the Starling stars layer
				starlingStars.nextFrame();
				
				// Render the Starling animation layer
				starlingCheckerboard.nextFrame();
			}
		}

		/**
		 * Handle the mouse down event and remember details for hovercontroller
		 */
		private function onMouseDown(event : MouseEvent) : void {
			mouseDown = true;
			lastPanAngle = hoverController.panAngle;
			lastTiltAngle = hoverController.tiltAngle;
			lastMouseX = stage.mouseX;
			lastMouseY = stage.mouseY;
		}

		/**
		 * Clear the mouse down flag to stop the hovercontroller
		 */
		private function onMouseUp(event : MouseEvent) : void {
			mouseDown = false; 
		}

		/**
		 * Swap the rendering order 
		 */
		private function onChangeRenderOrder(event : MouseEvent) : void {
			if (renderOrder == CHECKERS_CUBES_STARS) {
				renderOrder = STARS_CHECKERS_CUBES;
			} else if (renderOrder == STARS_CHECKERS_CUBES) {
				renderOrder = CUBES_STARS_CHECKERS;
			} else {
				renderOrder = CHECKERS_CUBES_STARS;
			}
 			
			updateRenderDesc();
		}		

		/**
		 * Change the text describing the rendering order
		 */
		private function updateRenderDesc() : void {
			var txt:String = "Demo of integrating three framework layers onto a stage3D instance. One Away3D layer is\n";
			txt += "combined with two Starling layers. Click the button to the left to swap the layers around.\n";
			txt += "EnterFrame is attached to the Stage3DProxy - clear()/present() are handled automatically\n";
			txt += "Mouse down and drag to rotate the Away3D scene.\n\n";
			switch (renderOrder) {
				case CHECKERS_CUBES_STARS : txt += "Render Order (first:behind to last:in-front) : Checkers > Cubes > Stars"; break;
				case STARS_CHECKERS_CUBES : txt += "Render Order (first:behind to last:in-front) : Stars > Checkers > Cubes"; break;
				case CUBES_STARS_CHECKERS : txt += "Render Order (first:behind to last:in-front) : Cubes > Stars > Checkers"; break;
			}
			renderOrderDesc.text = txt;
		}

	}
}
