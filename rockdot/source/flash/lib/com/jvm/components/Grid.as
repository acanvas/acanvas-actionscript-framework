package com.jvm.components {
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.display.DisplayObject;


	/**
	 * @author Simon Schmid (contact(at)sschmid.com)
	 */
	public class Grid extends SpriteComponent {
		public function Grid(tiles : Array, columns : uint, spacingH : uint, spacingV : uint) {
			var xPos : uint;
			var yPos : uint;
			var gridWidth : uint = Math.round(tiles[0].width + spacingH);
			var gridHeight : uint = Math.round(tiles[0].height + spacingV);

			var tile : DisplayObject;
			var n : int = tiles.length;
			for (var i : int = 0; i < n; i++) {
				tile = tiles[i];
				tile.x = xPos;
				tile.y = yPos;
				xPos += gridWidth;
				addChild(tile);
				if ((i + 1) % columns == 0) {
					xPos = 0;
					yPos += gridHeight;
				}
			}
		}
	}
}
