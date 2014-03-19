package com.rockdot.project.view.screen {


	import com.rockdot.project.view.element.RockdotBlobTracker;
	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class BookWithKinectDepth extends Book {
		private var _blobTracker : RockdotBlobTracker;

		public function BookWithKinectDepth(id : String)
		{
				super(id);
				_fireInit = false;
		}
		
		
		override public function init(data : * = null) : void {
			super.init(data);

			var showTracker : Boolean = true;
			_blobTracker = new RockdotBlobTracker( showTracker );
			_blobTracker.submitCallback = _blobTrackerHandler;
			addChild(_blobTracker);
			
			//notify State
			_didInit();
		}

		private function _blobTrackerHandler(idx : int) : void {
			switch(idx){
				case 8 :
					_log.debug("right");
					_book.nextPage();
				break;
				case 9 :
					_log.debug("left");
					_book.prevPage();
				break;
				default:
//					_log.debug("fail");
				break;
			}
		}
		
		override public function render() : void {
			super.render();
			
			_blobTracker.x = _width - _blobTracker.width - 5;
			_blobTracker.y = _height - _blobTracker.height - 5;
		}
		
		override public function destroy() : void {
			/* _blobTracker gets destroyed automatically because it's a Component */

			super.destroy();
		}
		
	}
}
