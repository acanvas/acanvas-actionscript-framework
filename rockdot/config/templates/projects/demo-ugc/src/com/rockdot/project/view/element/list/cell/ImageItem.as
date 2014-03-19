package com.rockdot.project.view.element.list.cell {
	import com.rockdot.core.model.RockdotConstants;
	import com.rockdot.library.view.component.common.ComponentImageLoader;
	import com.rockdot.plugin.screen.displaylist.view.RockdotSpriteComponent;
	import com.rockdot.project.model.Colors;
	import com.rockdot.project.view.text.Copy;




	/**
	 * Copyright (c) 2011, Jung von Matt/Neckar
	 * All rights reserved.
	 *
	 * @author 	Nils Doehring (nilsdoehring@gmail.com)
	 * @since	29.04.2011
	 */
	public class ImageItem extends RockdotSpriteComponent{
		public function ImageItem(w : int, h : int, data : *)
		{
			super();
			
			// user profile pic
			var creator_pic : ComponentImageLoader = new ComponentImageLoader(data.creator_pic, BootstrapConstants.HEIGHT_RASTER, BootstrapConstants.HEIGHT_RASTER);
			creator_pic.x = BootstrapConstants.HEIGHT_RASTER;
			creator_pic.y = BootstrapConstants.SPACER;
			
			// user name
			var userName : Copy = new Copy(getProperty("ugc.detail.uploaded_by", true) + "<br><b>" + data.creator_name + "</b>", 16, Colors.GREY);
			userName.width = 135;
			userName.x = creator_pic.x + BootstrapConstants.HEIGHT_RASTER;
			userName.y = BootstrapConstants.SPACER;
			
			// user contributed image
			var image : ComponentImageLoader = new ComponentImageLoader(data.href_big, w, h - BootstrapConstants.HEIGHT_RASTER - BootstrapConstants.SPACER);
			image.y = BootstrapConstants.HEIGHT_RASTER + 3*BootstrapConstants.SPACER;

			addChild(creator_pic);
			addChild(userName);
			addChild(image);
		}

	}
}
