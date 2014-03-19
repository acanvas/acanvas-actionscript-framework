/** * <p>Original Author: Daniel Freeman</p> * * <p>Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions:</p> * * <p>The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software.</p> * * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS' OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE.</p> * * <p>Licensed under The MIT License</p> * <p>Redistributions of files must retain the above copyright notice.</p> */package asfiles {	import flash.display.Sprite;	import flash.text.TextFormat;	public class MyTextMenu extends MyPopUp {	public static const SELECTED:String='selected';		protected var mnu:MyMenu;		public var txt:PrintAt;		protected var showop:Boolean;		protected var val:int;				public function MyTextMenu(screen:Sprite,xx:int,yy:int,options:Array,init:String="",hint:String=null,frmt:TextFormat=null,mfrmt:TextFormat=null,showop:Boolean=true,dontmove:Boolean=true) {			this.showop=showop;			buttonMode=useHandCursor=true;			mnu=new MyMenu(options,mfrmt);			txt=new PrintAt(this,0,0,(init!="" || options.length==0) ? init : options[0],null,frmt);			super(screen,xx,yy,mnu,hint,dontmove);			mnu.addEventListener(MyMenu.SELECTED,mnuselected);		}						override public function redraw(colour:uint = 0):void {		}						public function get value():int {			return val;		}						public function get text():String		{			return txt.text;		}						public function enable(idx:int,onoff:Boolean,newlabel:String=''):void {			if (idx<0) visible=onoff;			else mnu.enable(idx,onoff,newlabel);		}						public function update(what:String):void {			if (what==null) txt.text='----'; else txt.text=what;		}						public function set options(value:Array):void		{			mnu.options=value;		}		protected function mnuselected(ev:MyEvent):void {			if (showop) txt.text=ev.parameters[1];			dispatchEvent(new MyEvent(SELECTED,val=ev.parameters[0],ev.parameters[1]));		}	}}