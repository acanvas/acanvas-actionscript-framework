/*
 * A simple "Hello, World" example that demonstrates use of an
 * application-modal dialog to prompt for the user's name and
 * echo it in a greeting.
 */

package
{
	
	//1024x600
	//90x90
	
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.StageOrientationEvent;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import qnx.dialog.DialogButtonProperty;
	import qnx.dialog.PromptDialog;
	import qnx.display.IowWindow;
	import qnx.ui.buttons.LabelButton;
	import qnx.ui.text.Label;
	
	[SWF(height="600", width="1024", frameRate="30", backgroundColor="#BBBBBB")]
	public class HelloWorld extends Sprite
	{
		private var helloLabel:Label;
		private var helloButton:LabelButton;
		private var nameDialog:PromptDialog;
		
		public function HelloWorld()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			/* A button to request a greeting. */
			helloButton = new LabelButton();
			helloButton.label = "Push Me";
			
			/* A label in which to show the hello greeting. */
			helloLabel = new Label();
			
			var format:TextFormat = new TextFormat();
			format = new TextFormat();
			format.align = TextFormatAlign.CENTER;
			format.font = "Arial";
			format.color = 0x103f10;
			format.size = 24;
			helloLabel.format = format;
			addChild(helloLabel);
			
			/* Listen for a touch on the dialog. */
			helloButton.addEventListener(MouseEvent.CLICK, sayHello);
			addChild(helloButton);
		}
		
		private function onAdded(event:Event):void
		{
			trace("[Hello World]", "added to stage");
			
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			// configure the stage so that it does not scale to fit the orientation
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			layoutUI();
			stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGE, onOrientation);
		}
		
		private function onOrientation(event:Event):void
		{
			trace("[Hello World]", "orientation changed: ", stage.deviceOrientation);
			layoutUI();
		}
		
		private function layoutUI():void
		{
			// position the button
			helloButton.x = (stage.stageWidth - helloButton.width) / 2;
			helloButton.y = (stage.stageHeight - helloButton.height) / 2;
			
			// size and position the greeting label
			helloLabel.height = 30;
			switch (stage.deviceOrientation)
			{
				case StageOrientation.ROTATED_LEFT:
				case StageOrientation.ROTATED_RIGHT:
					// portrait
					helloLabel.width = 500;
					break;
				default:
					// landscape
					helloLabel.width = 800;
					break;
			}
			helloLabel.x = (stage.stageWidth - helloLabel.width) / 2;
			helloLabel.y = helloButton.y - 60;
		}
		
		private function sayHello(event:MouseEvent):void
		{
			if (nameDialog)
			{
				trace("[Hello World]", "name dialog already showing");
			}
			else
			{
				/* Disable the button while the dialog is showing. */
				helloButton.enabled = false;
				
				trace("[Hello World]", "showing dialog");
				
				nameDialog = new PromptDialog();
				nameDialog.message = "What is your name?";
				nameDialog.prompt = "your name";
				
				// add buttons and associate semantic context tags to them
				nameDialog.addButton("OK");
				nameDialog.setButtonPropertyAt(DialogButtonProperty.CONTEXT, "sayHello", 0);
				nameDialog.addButton("Later");
				nameDialog.setButtonPropertyAt(DialogButtonProperty.CONTEXT, "cancel", 1);
				
				/* Register a listener for the dialog buttons. */
				nameDialog.addEventListener(Event.SELECT, onDialogButton);
				
				/*
				 * Assign my group ID to the dialog so that it is modal to my application
				 * only, not system-wide.  This ensures that the user can switch to and
				 * interact with other applications while the dialog is open.
				 */
				nameDialog.show(IowWindow.getAirWindow().group);
			}
		}
		
		private function onDialogButton(event:Event):void
		{
			if (nameDialog)
			{
				trace("[Hello World]", "dialog dismissed");
				
				/* Respond to the user's input. */
				if ("sayHello" == nameDialog.getButtonPropertyAt(DialogButtonProperty.CONTEXT, nameDialog.selectedIndex))
				{
					helloLabel.text = "Hello, " + nameDialog.text;
				}
				else
				{
					helloLabel.text = "Maybe later, then.";
				}
				
				/* Clean up the dialog and re-enable the button. */
				nameDialog.removeEventListener(Event.SELECT, onDialogButton);
				nameDialog = null;
				helloButton.enabled = true;
			}
		}
	}
}