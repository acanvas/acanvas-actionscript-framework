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
			if(item.itemType == "sound")
			{	
				var linkid = item.name;
				if (linkid.indexOf("/") > -1)
				{
					var arra = linkid.split("/");
					linkid = arra[arra.length - 1 ];
				}
				if (linkid.indexOf(".wav") > -1 || linkid.indexOf(".aif") > -1)
				{
					linkid = "SWC" + linkid.slice(0, linkid.length - 4);
				}
				fl.trace("setting ("+item.name+") linkage id: "+linkid);
				
				item.linkageExportForAS = true;
				item.linkageExportInFirstFrame = true;	
				item.linkageIdentifier = linkid;
				item.linkageBaseClass = "flash.media.Sound";
				
				item.compressionType = "MP3";
				item.bitrate = "112 kbps";
				
			}
		}
	}
}
//else
{
//	fl.trace("Changes cancelled.");
}
