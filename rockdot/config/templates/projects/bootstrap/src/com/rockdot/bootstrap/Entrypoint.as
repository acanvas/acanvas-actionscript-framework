package com.rockdot.bootstrap {
	import com.greensock.TweenLite;
	import com.jvm.utils.ClassUtils;
	import com.rockdot.plugin.screen.displaylist.view.ManagedSpriteComponentEvent;

	import flash.display.Sprite;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.getDefinitionByName;



	/**
	 * @author Nils Doehring (nilsdoehring(at)gmail.com)
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class Entrypoint extends Sprite {
		private var _strBootstrapClassname : String = "com.rockdot.bootstrap.Bootstrap";
		private var _sprPreloader : LoadScreen;
		private var _appDelegate : Sprite;

		public function Entrypoint() {
			
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			
			var s : String;
			s += "............................................................... MM$............\n";
			s += "..............................................................MMMO.......8 ....\n";
			s += "............................................................MMMMMM ...,MM .....\n";
			s += "...........................................................MMMMMMM~....~.......\n";
			s += ".........................................................MMMMMMMMMM............\n";
			s += ".......................................................:MMMMMMMMMMM ...........\n";
			s += ".....................................................+MMMMMMMMMMMM~...........\n";
			s += ".....................................................MMMMMMMMMMMMMMM...........\n";
			s += "....................................................MMMMMMMMMMMMMMMM,..........\n";
			s += "..................................................,MMMMMMMMMMMMMMMMMM..........\n";
			s += "................................................. MMMMMMMMMMMMMMMMMMM .........\n";
			s += "................................................8MMMMMMMMMMMMMMMMMMMMM.........\n";
			s += "...............................................MMMMMMMMMMMMMMMMMMMMMMM.........\n";
			s += "..............................................=MMMMMMMMMMMMMMMMMMMMMMM ........\n";
			s += ".............................................OMMMMMMMMMMMMMM MMMMMMMMMM........\n";
			s += "............................................ MMMMMMMMMMMMMMO..NMMMMMMMM .......\n";
			s += "............................................MMMMMMMMMMMMMMM.....MMMMMMMZ.......\n";
			s += ".......................................... MMMMMMMMMMMMMMM ......MMMMMMN.......\n";
			s += "..........................................MMMMMMMMMMMMMMM.........,MMM ........\n";
			s += "..........................................MMMMMMMMMMMMMMM.......... ,..........\n";
			s += "........................................ MMMMMMMMMMMMMMM,......................\n";
			s += "........................................MMMMMMMMMMMMMMMM.......................\n";
			s += ".......................................,MMMMMMMMMMMMMMM:.......................\n";
			s += "...................................... MMMMMMMMMMMMMMMM........................\n";
			s += "......................................MMMMMMMMMMMMMMMMM........................\n";
			s += ".....................................7MMMMMMM =MMMMMMM$........................\n";
			s += ".....................................MMMMMMMM..... MMM ........................\n";
			s += "....................................OMMMMMMMM..... MMM.........................\n";
			s += "................................... MMMMMMMMM......MMM.........................\n";
			s += "...................................MMMMMMMMMM......$M+.........................\n";
			s += ".................................MMMMMMMMMMMM......,M..........................\n";
			s += "...............................MMMMMMMMMMMMMM...... M .........................\n";
			s += "............................ZMMMMMMMMMMMMMMMM.......M..........................\n";
			s += "..........................7MMMMMMMMMMMMMMMMMM.......M..........................\n";
			s += "........................IMMMMMMMMMMMMMMMMMMMM.......D..........................\n";
			s += "..................... MMMMMMMMMMMMMMMMMMMMMMM.......?..........................\n";
			s += "................... MMMMMMMMMMMMMMMMMMMMMMMMM..................................\n";
			s += "..................MMMMMMMMMMMMMMMMMMMMMMMMMMM..................................\n";
			s += ".................MMMMMMMMMMMMMMMMMMMMMMMMMMMM..................................\n";
			s += ".................MMMMMMMMMMMMMMMMMMMMMMMMMMMM..................................\n";
			s += "................ MMMMMMMMMMMMMMMMMMMMMMMMMMMM..................................\n";
			s += "................NMMMMMMMMMMMMMMMMMMMMMMMMMMMM..................................\n";
			s += "................MMMMMMMMMMMMMMMMMMMMMMMMMMMMM..................................\n";
			s += "...............+MMMMMMMMMMMMMMMMMMMMMMMMMMMMM..................................\n";
			s += "...............MMMMMMMMMMMMMMMMMMMMMMMMMMMMMM..................................\n";
			s += "...............MMMMMMMMMMMMMMMMMMMMMMMMMMMMMM..................................\n";
			s += "..............:MMMMMMMMMMMMMMMMMMMMMMMMMMMMMM .................................\n";
			s += "..............MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM .................................\n";
			s += "............. MMMMMMMMMMMMMMMMMMMMM$.~MMMMMMM .................................\n";
			s += ".............8MMMMMMMMMMMMMMMMMM~ ... MMMMMMM ..................... ?..........\n";
			s += "............ MMMMMMMMMMMMMMM$.........MMMMMMM .................7MMMMM .........\n";
			s += "............+MMMMMMMMMMMM~ ...........MMMMMMM .................NMMMMMI.........\n";
			s += "............MMMMMMMMMM ...............MMMMMMM ................. MMMMMM.........\n";
			s += "........... MMMMMM: ..................ZMMMMMM ..................OMMMMM.........\n";
			s += "...........:MMMMM.....................~MMMMMM .................. MMMMM.........\n";
			s += "...........MMMMMI......................MMMMMM ...................MMMMMD........\n";
			s += ".......... MMMMM................. ~... MMMMMM ...................,MMMMM .......\n";
			s += "..........8MMMM:..............ZMMMI....MMMMMM ....................MMMMM~.......\n";
			s += "..........MMMMM...............MMMM?....MMMMMM ....................,MMMMM.......\n";
			s += "......... MMMM8...............NMMM=....OMMMMM .....................MMMMM.......\n";
			s += ".........7MMMM................OMMM=....=MMMMM......................OMMMM ......\n";
			s += ".........MMMMO................?MMM=.....MMMMM...................... MMMMZ......\n";
			s += "........:MMMM ................:MMM~.... MMMMM,......................7MMMM .....\n";
			s += "........MMMM?..................MMM:.....MMMMM,...................... MMMM,.....\n";
			s += "....... MMMM ................. MMM:.....MMMMM:.......................7MMMN.....\n";
			s += ".......8MMMM.................. MMM:.....MMMMM~........................MMMM ....\n";
			s += ".......MMMM .................. MMM:.....MMMMM~........................MMMM?....\n";
			s += "...... MMMN....................MMM,.....DMMMM~.........................MMMM....\n";
			s += "......7MMM ....................MMM,.....+MMMM+.........................NMMM....\n";
			s += "......MMMM.....................DMM,......MMMM?......................... MMM....\n";
			s += "......MMM~.....................ZMM...... MMMM?..........................MMM8...\n";
			s += ".....MMMM......................+MM...... MMMM7..........................+MMM...\n";
			s += ".....MMM...................DMMM..........MMMM$........................ .~MMM~..\n";
			s += ".... MMM..................~MMMMM......~IDMM: ..........................=MMMMM..\n";
			s += ".. = ,: ............  .=$NMMMMMMN.....?MMMM~...................................\n";
			s += "..MMM.... ~7DMMMMMMMMMMMMMMMMMMMM .... MMMM~...................................\n";
			s += ".OMMM ...MMMMMMMMMMMMMMMMMMMMMMMM .....MMMM~...................................\n";
			s += ".MMMM7...?MMMMMMMMMMMMMMMMMMMMMMM .....MMMM~...................................\n";
			s += ".MMMM$...=MMMMMMMMMMMMMMMMMMMMMMM .....MMMM~...................................\n";
			s += ".MMMM:...OMMMMMMMMMMMMMMMMMMMMMMM..... MMMM~...................................\n";
			s += ". MMM.....................MMMMMM.......................................IMMMMMMM\n";
			s += "..ZM.......................MMMMM........................................?MMMMM.\n";
			s += "............................MM ................................................\n";
			s += "\n";
			s += "\n";
			s += "JUNG VON MATT/NECKAR";
			s += "\n";

			// Show off
			trace(s);
			
			
		}

		protected function _onAddedToStage(event : Event) : void {
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			// Init Preload Screen
			_sprPreloader = new LoadScreen();
			_sprPreloader.addEventListener(ManagedSpriteComponentEvent.LOAD_COMPLETE, _initBootstrap, false, 0, true);
			stage.addChild(_sprPreloader);
		}

		private function _initBootstrap(event : ManagedSpriteComponentEvent) : void {
			var validClassDef : Boolean;

			try {
				var BootstrapClass : Class = getDefinitionByName(_strBootstrapClassname) as Class;
				validClassDef = true;
			} catch(error : Error) {
				validClassDef = false;
				trace("Could not instantiate: " + _strBootstrapClassname + "\nAre you sure that this class is compiled? \nOriginal Error: " + error);
				_enableContextMenuErrorReport();
			}

			if (validClassDef) {
				trace("Instantiating Bootstrap Class: " + _strBootstrapClassname);
				_appDelegate = new BootstrapClass();
				_appDelegate.addEventListener(ManagedSpriteComponentEvent.LOAD_COMPLETE, _onBootstrapLoad, false, 0, true);
				_appDelegate.addEventListener(ManagedSpriteComponentEvent.LOAD_ERROR, _onBootstrapLoadError, false, 0, true);
				(_appDelegate["init"] as Function).call(this, stage);
				(_appDelegate["load"] as Function).call();
			}
		}

		private function _onBootstrapLoad(event : ManagedSpriteComponentEvent) : void {
			trace("Bootstrap finished loading.");
			TweenLite.to(_sprPreloader, .5, {alpha:0, delay:.3, onComplete: _onPreloaderDisappear});
		}

		private function _onPreloaderDisappear() : void {
			stage.removeChild(_sprPreloader);
			_sprPreloader = null;
		}

		/**
		 * 
		 * Error log
		 * 
		 */
		private function _onBootstrapLoadError(event : ManagedSpriteComponentEvent) : void {
			trace(_strBootstrapClassname + " could not be loaded completely.\n" + event.data);
			_enableContextMenuErrorReport();
		}

		private function _enableContextMenuErrorReport() : void {
			// TODO compiler throws an error. seems to be airglobal.swc's fault.
			/*
			 */
			if (!contextMenu && ContextMenu.isSupported) {
			var menu : ContextMenu = new ContextMenu();
			contextMenu = menu;

			var errorReportItem : ContextMenuItem = new ContextMenuItem("Copy Error Report To Clipboard");
			contextMenu.addItem(errorReportItem); //<-- FDT marks this as Error, as it assumes AIR 3.1 to be in effect.
//            contextMenu.customItems.push(errorReportItem);

			errorReportItem.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, _onMenuSelected);
			}
			 
		}

		private function _onMenuSelected(event : ContextMenuEvent) : void {
			// TODO configure as3commons-logging to keep a history 
			
			// FP 10
			// Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, HistoryLogger.logHistory);
		}

	}
}
