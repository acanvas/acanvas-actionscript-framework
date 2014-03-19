package com.danielfreeman.stage3Dacceleration {
	import com.danielfreeman.madcomponents.IContainerUI;

	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	
	public class GridPageQuarter extends GridPage {	
		
		protected static const DEPTH:Number = 0.0;
		
		protected var _midColumn:int;
		protected var _midRow:int;
		protected var _midU:Number;
		protected var _midV:Number;
		
		protected var _topLeftIndices:Vector.<uint>;
		protected var _topLeftVertices:Vector.<Number>;
		protected var _topLeftUV:Vector.<Number>;
		protected var _topLeftIndexBuffer:IndexBuffer3D;
		protected var _topLeftVertexBuffer:VertexBuffer3D;
		protected var _topLeftUVBuffer:VertexBuffer3D;
		
		protected var _topRightIndices:Vector.<uint>;
		protected var _topRightVertices:Vector.<Number>;
		protected var _topRightUV:Vector.<Number>;
		protected var _topRightIndexBuffer:IndexBuffer3D;
		protected var _topRightVertexBuffer:VertexBuffer3D;
		protected var _topRightUVBuffer:VertexBuffer3D;
		
		protected var _bottomLeftIndices:Vector.<uint>;
		protected var _bottomLeftVertices:Vector.<Number>;
		protected var _bottomLeftUV:Vector.<Number>;
		protected var _bottomLeftIndexBuffer:IndexBuffer3D;
		protected var _bottomLeftVertexBuffer:VertexBuffer3D;
		protected var _bottomLeftUVBuffer:VertexBuffer3D;
		
		protected var _bottomRightIndices:Vector.<uint>;
		protected var _bottomRightVertices:Vector.<Number>;
		protected var _bottomRightUV:Vector.<Number>;
		protected var _bottomRightIndexBuffer:IndexBuffer3D;
		protected var _bottomRightVertexBuffer:VertexBuffer3D;
		protected var _bottomRightUVBuffer:VertexBuffer3D;


		public function GridPageQuarter(page : IContainerUI, backgroundColour : uint = 0xffffffff) {
			super(page, backgroundColour);
		}
		
		
		protected function pushVertices(vertexVector:Vector.<Number>, leftGrid:Number, rightGrid:Number, topGrid:Number, bottomGrid:Number):void {
			vertexVector.push(
				graphX(leftGrid), 		-graphY(bottomGrid), 	DEPTH,
				graphX(rightGrid),		-graphY(bottomGrid),	DEPTH,
				graphX(rightGrid),		-graphY(topGrid),		DEPTH,
				graphX(leftGrid),		-graphY(topGrid),		DEPTH
			);
		}
		
		
		protected function pushUV(uvVector:Vector.<Number>, u0:Number, v0:Number, u1:Number, v1:Number):void {
			uvVector.push(
				u0, 	v1,
				u1,		v1,
				u1,		v0,
				u0,		v0
			);
		}
		
		
		protected function initialiseTopLeft():void {
			_topLeftIndices = new Vector.<uint>();
			_topLeftVertices = new Vector.<Number>();
			_topLeftUV = new Vector.<Number>();
			var count:int = 0;
			for (var i:int = 0; i <= _midColumn; i++) {
				for (var j:int = 0; j <= _midRow; j++) {
					_topLeftIndices.push(count, count+1, count+2,	count, count+2, count+3);
					var u:Number = (i < _midColumn) ? 1.0 : _midU;
					var v:Number = (j < _midRow) ? 1.0 : _midV;
					pushVertices(_topLeftVertices, i * GRID_SIZE, (i + u) * GRID_SIZE,
													j * GRID_SIZE, (j + v) * GRID_SIZE
					);
					pushUV(_topLeftUV, 0, 0, u, v);
					count += 4;
				}
			}
		}
		
		
		protected function initialiseTopRight():void {
			_topRightIndices = new Vector.<uint>();
			_topRightVertices = new Vector.<Number>();
			_topRightUV = new Vector.<Number>();
			var count:int = 0;
			for (var i:int = _midColumn; i < _columns; i++) {
				for (var j:int = 0; j <= _midRow; j++) {
					_topRightIndices.push(count, count+1, count+2,	count, count+2, count+3);
					var u0:Number = (i > _midColumn) ? 0.0 : _midU;
					var u:Number = (i < _columns - 1) ? 1.0 : (_lastWidth / GRID_SIZE);
					var v:Number = (j < _midRow) ? 1.0 : _midV;
					pushVertices(_topRightVertices, (i + u0) * GRID_SIZE, (i + u) * GRID_SIZE,
													j * GRID_SIZE, (j + v) * GRID_SIZE
					);
					pushUV(_topRightUV, u0, 0, u, v);
					count += 4;
				}
			}
		}
		
		
		protected function initialiseBottomLeft():void {
			_bottomLeftIndices = new Vector.<uint>();
			_bottomLeftVertices = new Vector.<Number>();
			_bottomLeftUV = new Vector.<Number>();
			var count:int = 0;
			for (var i:int = 0; i <= _midColumn; i++) {
				for (var j:int = _midRow; j < _rows ; j++) {
					_bottomLeftIndices.push(count, count+1, count+2,	count, count+2, count+3);
					var v0:Number = (j > _midRow) ? 0.0 : _midV;
					var u:Number = (i < _midColumn) ? 1.0 : _midU;
					var v:Number = (j < _rows - 1) ? 1.0 :  (_lastHeight / GRID_SIZE);
					pushVertices(_bottomLeftVertices, i * GRID_SIZE, (i + u) * GRID_SIZE,
													(j + v0) * GRID_SIZE, (j + v) * GRID_SIZE
					);
					pushUV(_bottomLeftUV, 0, v0, u, v);
					count += 4;
				}
			}
		}
		
		
		protected function initialiseBottomRight():void {
			_bottomRightIndices = new Vector.<uint>();
			_bottomRightVertices = new Vector.<Number>();
			_bottomRightUV = new Vector.<Number>();
			var count:int = 0;
			for (var i:int = _midColumn; i < _columns; i++) {
				for (var j:int = _midRow; j < _rows ; j++) {
					_bottomRightIndices.push(count, count+1, count+2,	count, count+2, count+3);
					var u0:Number = (i > _midColumn) ? 0.0 : _midU;
					var v0:Number = (j > _midRow) ? 0.0 : _midV;
					var u:Number = (i < _columns - 1) ? 1.0 : (_lastWidth / GRID_SIZE);
					var v:Number = (j < _rows - 1) ? 1.0 :  (_lastHeight / GRID_SIZE);
					pushVertices(_bottomRightVertices, (i + u0) * GRID_SIZE, (i + u) * GRID_SIZE,
													(j + v0) * GRID_SIZE, (j + v) * GRID_SIZE
					);
					pushUV(_bottomRightUV, u0, v0, u, v);
					count += 4;
				}
			}
		}
		

		override public function pageTexture(page:IContainerUI, backgroundColour:uint = 0xFFFFFFFF):void {
			super.pageTexture(page, backgroundColour);
			_midColumn = Math.floor((_pageWidth / 2) / GRID_SIZE);
			_midRow = Math.floor((_pageHeight / 2) / GRID_SIZE);
			_midU = (_pageWidth / 2) / GRID_SIZE - _midColumn;
			_midV = (_pageHeight / 2) / GRID_SIZE - _midRow;
			
			initialiseTopLeft();
			initialiseTopRight();
			initialiseBottomLeft();
			initialiseBottomRight();
			contextResumedQuarters();
		}
		
		
		protected function contextResumedQuarters():void {
			_topLeftIndexBuffer = _context3D.createIndexBuffer( _topLeftIndices.length );
			_topLeftIndexBuffer.uploadFromVector(_topLeftIndices, 0, _topLeftIndices.length );
			_topLeftVertexBuffer = _context3D.createVertexBuffer(_topLeftVertices.length / 3, 3);
			_topLeftVertexBuffer.uploadFromVector(_topLeftVertices, 0, _topLeftVertices.length / 3);
			_topLeftUVBuffer = _context3D.createVertexBuffer(_topLeftUV.length / 2, 2);
			_topLeftUVBuffer.uploadFromVector(_topLeftUV, 0, _topLeftUV.length / 2);
			
			_topRightIndexBuffer = _context3D.createIndexBuffer( _topRightIndices.length );
			_topRightIndexBuffer.uploadFromVector(_topRightIndices, 0, _topRightIndices.length );
			_topRightVertexBuffer = _context3D.createVertexBuffer(_topRightVertices.length / 3, 3);
			_topRightVertexBuffer.uploadFromVector(_topRightVertices, 0, _topRightVertices.length / 3);
			_topRightUVBuffer = _context3D.createVertexBuffer(_topRightUV.length / 2, 2);
			_topRightUVBuffer.uploadFromVector(_topRightUV, 0, _topRightUV.length / 2);
			
			_bottomLeftIndexBuffer = _context3D.createIndexBuffer( _bottomLeftIndices.length );
			_bottomLeftIndexBuffer.uploadFromVector(_bottomLeftIndices, 0, _bottomLeftIndices.length );
			_bottomLeftVertexBuffer = _context3D.createVertexBuffer(_bottomLeftVertices.length / 3, 3);
			_bottomLeftVertexBuffer.uploadFromVector(_bottomLeftVertices, 0, _bottomLeftVertices.length / 3);
			_bottomLeftUVBuffer = _context3D.createVertexBuffer(_bottomLeftUV.length / 2, 2);
			_bottomLeftUVBuffer.uploadFromVector(_bottomLeftUV, 0, _bottomLeftUV.length / 2);
			
			_bottomRightIndexBuffer = _context3D.createIndexBuffer( _bottomRightIndices.length );
			_bottomRightIndexBuffer.uploadFromVector(_bottomRightIndices, 0, _bottomRightIndices.length );
			_bottomRightVertexBuffer = _context3D.createVertexBuffer(_bottomRightVertices.length / 3, 3);
			_bottomRightVertexBuffer.uploadFromVector(_bottomRightVertices, 0, _bottomRightVertices.length / 3);
			_bottomRightUVBuffer = _context3D.createVertexBuffer(_bottomRightUV.length / 2, 2);
			_bottomRightUVBuffer.uploadFromVector(_bottomRightUV, 0, _bottomRightUV.length / 2);
		}
		
		
		override public function contextResumed(running:Boolean):void {
			super.contextResumed(running);
			contextResumedQuarters();
		}
		
		
		protected function displayQuarter(fromColumn:int, toColumn:int, fromRow:int, toRow:int, indexBuffer:IndexBuffer3D, vertexBuffer:VertexBuffer3D, uvBuffer:VertexBuffer3D):void {
			_context3D.setVertexBufferAt( 0, vertexBuffer,  0, Context3DVertexBufferFormat.FLOAT_3 ); //va0
			_context3D.setVertexBufferAt( 1, uvBuffer,  0, Context3DVertexBufferFormat.FLOAT_2 ); //va1
			
			var count:int = 0;
			for (var i:int = fromColumn; i < toColumn; i++) {
				for (var j:int = fromRow; j < toRow; j++) {
					_context3D.setTextureAt(0, _gridTexture[i][j]);
					_context3D.drawTriangles(indexBuffer, count, 2);
					count += 6;
				}
			}
		}
		
		
		public function displayTopLeft():void {	
			displayQuarter(0, _midColumn + 1, 0, _midRow + 1, _topLeftIndexBuffer, _topLeftVertexBuffer, _topLeftUVBuffer);
		}
		
		
		public function displayTopRight():void {
			displayQuarter(_midColumn, _columns, 0, _midRow + 1, _topRightIndexBuffer, _topRightVertexBuffer, _topRightUVBuffer);
		}
		
		
		public function displayBottomLeft():void {
			displayQuarter(0, _midColumn + 1, _midRow, _rows, _bottomLeftIndexBuffer, _bottomLeftVertexBuffer, _bottomLeftUVBuffer);
		}
		
		
		public function displayBottomRight():void {
			displayQuarter(_midColumn, _columns, _midRow, _rows, _bottomRightIndexBuffer, _bottomRightVertexBuffer, _bottomRightUVBuffer);
		}
		
		
/**
 * Convert Stage x-coordinate to Stage3D x-coordinate
 */
		protected function graphX(value:Number):Number {
			return 2.0 * value / _pageWidth - 1.0;
		}
		
/**
 * Convert Stage y-coordinate to Stage3D y-coordinate
 */
		protected function graphY(value:Number):Number {
			return 2.0 * value / _pageHeight - 1.0;
		}
	}
}
