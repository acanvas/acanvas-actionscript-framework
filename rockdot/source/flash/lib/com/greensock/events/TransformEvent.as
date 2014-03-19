/**
 * VERSION: 2.2
 * DATE: 2010-05-28
 * AS3 
 * UPDATES AND DOCUMENTATION AT: http://www.greensock.com/transformmanageras3/
 **/
package com.greensock.events {
	import flash.events.Event;
	import flash.events.MouseEvent;
/**
 * Event related to actions performed by TransformManager
 * 
 * <b>Copyright 2010, GreenSock. All rights reserved.</b> This work is subject to the terms in <a href="http://www.greensock.com/eula.html">http://www.greensock.com/eula.html</a> or for corporate Club GreenSock members, the software agreement that was issued with the corporate membership.
 * 
 * @author Jack Doyle, jack@greensock.com
 */
	public class TransformEvent extends Event {
		/** Dispatched constantly while an item is moved by TransformManager (each time the mouse moves). To discern when an interactive move operation is finished (when the user releases the mouse after moving an item), listen for the the <code>FINISH_INTERACTIVE_MOVE</code> event. **/
		public static const MOVE:String = "tmMove";
		/** Dispatched constantly while an item is scaled by TransformManager (each time the mouse moves). To discern when an interactive scale operation is finished (when the user releases the mouse after scaling an item), listen for the the <code>FINISH_INTERACTIVE_SCALE</code> event. **/
		public static const SCALE:String = "tmScale";
		/** Dispatched constantly while an item is rotated by TransformManager (each time the mouse moves). To discern when an interactive rotation is finished (when the user releases the mouse after rotating an item), listen for the the <code>FINISH_INTERACTIVE_ROTATE</code> event. **/
		public static const ROTATE:String = "tmRotate";
		/** Dispatched by TransformItems when they are selected (the <code>SELECT</code> event is <strong>NOT</code> dispatched by a TransformManager instance). **/
		public static const SELECT:String = "tmSelect";
		/** Dispatched by TransformItems when they are selected (the <code>SELECT</code> event is <strong>NOT</code> dispatched by a TransformManager instance). **/
		public static const DESELECT:String = "tmDeselect";
		/** @private only used internally in TransformManager **/
		public static const MOUSE_DOWN:String = "tmMouseDown";
		/** @private only used internally in TransformManager **/
		public static const SELECT_MOUSE_DOWN:String = "tmSelectMouseDown";
		/** @private only used internally in TransformManager **/
		public static const SELECT_MOUSE_UP:String = "tmSelectMouseUp";
		/** @private only used internally in TransformManager **/
		public static const ROLL_OVER_SELECTED:String = "tmRollOverSelected";
		/** @private only used internally in TransformManager **/
		public static const ROLL_OUT_SELECTED:String = "tmRollOutSelected";
		/** Dispatched when an item is deleted. **/
		public static const DELETE:String = "tmDelete";
		/** Dispatched by TransformManager whenever its selection changes, like when an item is added to the selection or removed from the selection or everything is deselected, etc. **/
		public static const SELECTION_CHANGE:String = "tmSelectionChange";
		/** Dispatched when the mouse is clicked off of the selection, and <strong>ONLY</strong> when <code>autoDeselect</code> is <code>false</code>. **/
		public static const CLICK_OFF:String = "tmClickOff";
		/** @private Dispatched when an item is updated in some manner **/
		public static const UPDATE:String = "tmUpdate";
		/** Dispatched when TransformManager changes an item's depth. **/
		public static const DEPTH_CHANGE:String = "tmDepthChange";
		/** Dispatched when a TransformManager is destroyed. **/
		public static const DESTROY:String = "tmDestroy";
		/** Dispatched when the user releases the mouse after having interactively moved the selection by dragging it with their mouse. To listen for every move (which typically happens many, many times during a single interactive mouse drag), listen for the <code>MOVE</code> event instead. **/
		public static const FINISH_INTERACTIVE_MOVE:String = "tmFinishInteractiveMove";
		/** Dispatched when the user releases the mouse after having interactively scaled the selection by dragging one of the scaling handles. To listen for every scale (which typically happens many, many times during a single interactive mouse drag), listen for the <code>SCALE</code> event instead. **/
		public static const FINISH_INTERACTIVE_SCALE:String = "tmFinishInteractiveScale";
		/** Dispatched when the user releases the mouse after having interactively rotated the selection by dragging one of the rotation handles. To listen for every rotation (which typically happens many, many times during a single interactive mouse drag), listen for the <code>ROTATE</code> event instead. **/
		public static const FINISH_INTERACTIVE_ROTATE:String = "tmFinishInteractiveRotate";
		/** Dispatched when the user mouses down to begin interactively moving a TransformManager selection. To listen for every move (which typically happens many, many times during a single interactive mouse drag), listen for the <code>MOVE</code> event instead. **/
		public static const START_INTERACTIVE_MOVE:String = "tmStartInteractiveMove";
		/** Dispatched when the user mouses down on a scale handle to begin interactively scaling a TransformManager selection. To listen for every scale (which typically happens many, many times during a single interactive mouse drag), listen for the <code>SCALE</code> event instead. **/
		public static const START_INTERACTIVE_SCALE:String = "tmStartInteractiveScale";
		/** Dispatched when the user mouses down on a rotation handle to begin interactively rotating a TransformManager selection. To listen for every rotation (which typically happens many, many times during a single interactive mouse drag), listen for the <code>ROTATE</code> event instead. **/
		public static const START_INTERACTIVE_ROTATE:String = "tmStartInteractiveRotate";
		/** Dispatched when the mouse is double-clicked quickly. **/
		public static const DOUBLE_CLICK:String = "tmDoubleClick";
		/** Dispatched when TransformManager takes control of the visual design of the mouse cursor (like an icon that indicates scale, move, or rotation). This is <strong>NOT</strong> dispatched every time the cursor changes - for example, it will be dispatched as the user moves their mouse over the selection, but it will not be dispatched again as they move over the scale handle and it changes from the "move" icon to the "scale" icon (or "rotation"). This event simply indicates when TransformManager changes the cursor from the normal mouse one to any of TransformManager's custom cursors. **/
		public static const SEIZE_CURSOR:String = "tmSeizeCursor";
		/** Dispatched when TransformManager releases control of the visual design of the mouse cursor, swapping its custom one out for the normal mouse cursor. **/
		public static const RELEASE_CURSOR:String = "tmReleaseCursor";
		
		/** TransformItems that were affected by the event **/
		public var items:Array;
		/** MouseEvent associated with the TransformEvent (if any) **/
		public var mouseEvent:MouseEvent;
		
		public function TransformEvent($type:String, $items:Array, $mouseEvent:MouseEvent = null, $bubbles:Boolean = false, $cancelable:Boolean = false){
			super($type, $bubbles, $cancelable);
			this.items = $items;
			this.mouseEvent = $mouseEvent;
		}
		
		public override function clone():Event{
			return new TransformEvent(this.type, this.items, this.mouseEvent, this.bubbles, this.cancelable);
		}
	
	}
	
}