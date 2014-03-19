//****************************************************************************
// Copyright (C) 2007 flashextension.net. All Rights Reserved.
// The following is Sample Code and is subject to all restrictions on
// such code as contained in the End User License Agreement accompanying
// this product.
//****************************************************************************

// Multiple Library Renamer.jsfl
// This script is designed to go through all selected items and rename the library
// item.


var doc = fl.getDocumentDOM();
var selected_lib_items = doc.library.getSelectedItems();

//if (ui.dismiss == "accept")
{
	if (selected_lib_items.length == 0)
	{
		alert("Please select at least one item in the library.");
	}
	else
	{
		
		for (var i = 0; i < selected_lib_items.length; i++)
		{
					
			var item = selected_lib_items[i];
			var linkid = item.name;
			fl.trace(linkid);
			if (linkid.indexOf("/") > -1)
			{
				var arra = linkid.split("/");
				linkid = arra[arra.length - 1 ];
			}
			
			if(item.itemType == "movie clip")
			{	
				if(linkid.indexOf("swc_") == -1){
					linkid = "swc_mc_" + linkid;
				}				
				fl.trace("[MC] setting ("+item.name+") linkage id: "+linkid);
				item.linkageExportForAS = true;
				item.linkageExportInFirstFrame = true;	
				item.linkageIdentifier = linkid;
				item.linkageBaseClass = "flash.display.Sprite";
				
			}
			if(item.itemType == "bitmap")
			{	
				//item.compressionType = "lossless";				
				item.compressionType = "photo";
				item.quality = 80;
				
				if(linkid.indexOf("swc_") == -1){
					linkid = "swc_bmd_" + linkid;
				}
				else{
					linkid = "swc_start_" + linkid.substr(4);
				}
				
				fl.trace("[BITMAPDATA] setting ("+item.name+") linkage id: "+linkid);
				item.linkageExportForAS = true;
				item.linkageExportInFirstFrame = true;
				item.linkageClassName = linkid;
				item.linkageBaseClass = "flash.display.BitmapData";
				
			}
		}
	}
}

