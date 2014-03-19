/** * <p>Original Author: Daniel Freeman</p> * * <p>Permission is hereby granted, free of charge, to any person obtaining a copy * of this software and associated documentation files (the "Software"), to deal * in the Software without restriction, including without limitation the rights * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell * copies of the Software, and to permit persons to whom the Software is * furnished to do so, subject to the following conditions:</p> * * <p>The above copyright notice and this permission notice shall be included in * all copies or substantial portions of the Software.</p> * * <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE * AUTHORS' OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN * THE SOFTWARE.</p> * * <p>Licensed under The MIT License</p> * <p>Redistributions of files must retain the above copyright notice.</p> */package asfiles {	import flash.display.Sprite;		public class ScatterGraph extends GraphPalette {				private var bars:Array = [];			public function ScatterGraph(screen:Sprite,xx:int,yy:int,select:Packet,ss:*=null,stack:Boolean=false) {		iam=4;		super(screen,xx,yy,select,ss);	//	controls=new GraphControls(this,frame/2,frame/2,'scatter graph',false,false,swap=datai>1 && dataj>1);		resize(wdth,hght);	//	controls.addEventListener(MouseEvent.CLICK,controlsclick);		}						public function plotcross(screen:Sprite,wdth:Number, hght:Number, soffset:Number, cell:Cell, i:int, xx:int, c:uint, top:Boolean):void {		if (bars[i]==null) bars[i]=new Cross(screen);		bars[i].drawcross(wdth,hght,cell,soffset,xx,c,threed,stack,top);		}						override public function bgredraw():void {			var x0:int;			var wdth:Number;			if (dataj>1)				if (swap) wdth = mywidth/(dataj*(datai+1)-1);				else wdth = mywidth/(datai*(dataj+1)-1);			else if (swap) wdth = mywidth/dataj;				else wdth = mywidth/datai;		//	bw=0.7;			for (var i:int = 0; i<datai; i++)				for (var j:int = 0; j<dataj; j++) {					if (swap) x0=(datai>1) ? i+(datai+1)*j : j; else x0=(dataj>1) ? j+(dataj+1)*i : i;					plotcross(grph, wdth, shght, soffset, readcell(i,j), (dataj==1) ? i : i*dataj+j, x0, colour(i,j), true);				}		}	}}