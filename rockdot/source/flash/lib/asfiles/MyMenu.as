/** * <p>Original Author: Daniel Freeman</p> * * <p>Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions:</p> * * <p>The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software.</p> * * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS' OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE.</p> * * <p>Licensed under The MIT License</p> * <p>Redistributions of files must retain the above copyright notice.</p> */package asfiles {	import flash.display.GradientType;	import flash.display.SpreadMethod;	import flash.display.Sprite;	import flash.events.MouseEvent;	import flash.filters.DropShadowFilter;	import flash.geom.Matrix;	import flash.geom.Point;	import flash.text.TextFormat;			public class MyMenu extends Sprite {				public static const SELECTED:String='MyMenu.selected';				protected static const THRESHOLD:Number=16;		protected const kfrmt:TextFormat=new TextFormat('Arial',14,textcolour);		protected const xgap:int=12;		protected const bordercolour:uint=0xcccccc;		private const fillcolour0:uint=0xffffff;		private const fillcolour1:uint=0xfcfcfc;		private const dimcolour:uint=0x999999;		private const hitextcolour:uint=0xffffff;		private const stripe:int=6;		public const margin:int=6;		public const ymargin:int=4;				protected var ygap:int=24;				public var hilitecolour:uint=0x326fcb;		protected var textcolour:uint=0x333333;		protected var noptions:int=0;		protected var optns:Vector.<PrintAt>;		protected var format:TextFormat;		protected var hilite:Sprite=new Sprite();		protected var index:int=-1;				public function MyMenu(options:Array=null,frmt:TextFormat=null) {			var myfilters:Array=new Array();			if (frmt!=null) {format=frmt;textcolour=uint(frmt.color);} else format=kfrmt;			addChild(hilite);hilite.x=hilite.y=0;hilite.mouseEnabled=false;			if (options!=null) {noptions=options.length;redraw(options);}			addEventListener(MouseEvent.MOUSE_OVER,mouseover);			addEventListener(MouseEvent.MOUSE_OUT,mouseout);			addEventListener(MouseEvent.MOUSE_UP,mouseup);			myfilters.push(new DropShadowFilter(2.0,45,0,0.4));            filters=myfilters;		}						public function set options(opt:Array):void {			if (optns!=null) for (var i:int=0;i<optns.length;i++) removeChild(optns[i]);			noptions=opt.length;			redraw(opt);		}						public function enable(idx:int,onoff:Boolean,newlabel:String=''):void {			optns[idx].textColor=onoff ? textcolour : dimcolour;			if (newlabel!='') optns[idx].text=newlabel;		}						protected function mouseover(ev:MouseEvent):void {			addEventListener(MouseEvent.MOUSE_MOVE,mousemove);		}						protected function mouseout(ev:MouseEvent):void {			removeEventListener(MouseEvent.MOUSE_MOVE,mousemove);			hilite.graphics.clear();			if (index>=0 && optns[index].textColor!=dimcolour) optns[index].textColor=textcolour;			index=-1;		}						protected function mousemove(ev:MouseEvent):void {			hilite.graphics.clear();			if (index>=0 && optns[index].textColor!=dimcolour) optns[index].textColor=textcolour;			index=Math.floor(mouseY/ygap);			if (index<0) index=0; else if (index>=noptions) index=noptions-1;			if (index<0) return;			if (optns[index].textColor==dimcolour) index=-1;			else {				hilite.graphics.beginFill(hilitecolour);				hilite.graphics.drawRect(0,ymargin/2+index*ygap,width/scaleY,ygap);				optns[index].textColor=hitextcolour;			}						var global:Point=localToGlobal(new Point(0,mouseY));			if (global.y<THRESHOLD) y=-global.y+THRESHOLD;			else if (global.y>stage.stageHeight-THRESHOLD) y=(stage.stageHeight-height)-(global.y-stage.stageHeight)-THRESHOLD;		}						protected function mouseup(ev:MouseEvent):void {			if (index>=0) dispatchEvent(new MyEvent(SELECTED,index,optns[index].text));		}						public function redraw(options:Array):void {			var matr:Matrix=new Matrix();			optns=new Vector.<PrintAt>();			for (var i:int=0;i<options.length;i++) optns[i]=new PrintAt(this,margin+xgap,ymargin+i*ygap,options[i],null,format);			matr.createGradientBox(99,stripe, Math.PI/2, 0, 0);			graphics.clear();			graphics.lineStyle(0,bordercolour);			graphics.beginGradientFill(GradientType.LINEAR,[fillcolour0,fillcolour0,fillcolour1],[0.9,0.9,0.9],[0x00,0x60,0x61],matr,SpreadMethod.REPEAT);			graphics.drawRect(0,0,xgap+width+3*margin,height+2*ymargin);		}			}	}