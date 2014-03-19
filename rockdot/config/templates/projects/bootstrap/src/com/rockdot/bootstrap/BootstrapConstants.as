package com.rockdot.bootstrap {
	import com.rockdot.core.model.RockdotConstants;

	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;

	public class BootstrapConstants 
	{
		public static const COMPETITION_ACTIVE : int = 0;
		
		public static const SPACER : Number = 10;
		
		public static const X_PAGES : uint = 10;
		public static const Y_PAGES : uint = 2 * BootstrapConstants.HEIGHT_RASTER + 2 * SPACER;
		
		public static const WIDTH_MIN : uint =  400;
		public static const HEIGHT_MIN : uint = 768;

		public static const WIDTH_MAX : uint =  1024;
		public static const HEIGHT_MAX : uint = 1024;
		
		public static function get WIDTH_CONTENT() : uint { return Math.min(BootstrapConstants.WIDTH_STAGE - 2 * X_PAGES, WIDTH_MAX - 2 * X_PAGES);}
		public static function get HEIGHT_CONTENT() : uint { return BootstrapConstants.HEIGHT_STAGE - Y_PAGES - BootstrapConstants.SPACER;}
		 
		public static function get WIDTH_STAGE_REAL() : uint { 
			return RockdotConstants.getStage().stageWidth; 
		};
		public static function get HEIGHT_STAGE_REAL() : uint { return RockdotConstants.getStage().stageHeight; };

		public static function get WIDTH_STAGE() : uint { return Math.min(WIDTH_MAX, Math.max(WIDTH_MIN, RockdotConstants.getStage().stageWidth)); }
		public static function get HEIGHT_STAGE() : uint { return Math.min(HEIGHT_MAX, Math.max(HEIGHT_MIN, RockdotConstants.getStage().stageHeight));}
		
		
		public static const HEIGHT_RASTER : uint = 75;
		public static const HEIGHT_TEASER : uint = 4 * HEIGHT_RASTER;
		
		private static var _stageRef : Stage;

		public static function init(stage : Stage) : void {
			_stageRef = stage;

			// Stage settings
			_stageRef.quality = StageQuality.HIGH;
			_stageRef.align = StageAlign.TOP_LEFT;
			_stageRef.scaleMode = StageScaleMode.NO_SCALE;
			_stageRef.stageFocusRect = false; 
			_stageRef.frameRate = 60;

		}


		public static function get stageRef() : Stage {
			return _stageRef;
		}
		
		
	}
}