package com.rockdot.library.util.blobtracker.ui {
	import com.as3nui.nativeExtensions.air.kinect.Kinect;
	import com.rockdot.library.util.blobtracker.data.KinectBmdProvider;
	import com.rockdot.library.util.tracker.ui.MeanshiftSetupTool;
	
	
	//==================================================================
	/**
	 * interface stuff - pretty messy :)
	 */
	public class MeanshiftKinectSetupTool extends MeanshiftSetupTool {
		
		
		//==================================================================
		override protected function initBmd():void {

			if(Kinect.isSupported())
			{
				bmdProvider = new KinectBmdProvider();
			}
			else 
			{
				super.initBmd();
			}
		}
	}
	
}