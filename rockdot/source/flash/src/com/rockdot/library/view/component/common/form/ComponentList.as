package com.rockdot.library.view.component.common.form {
	import com.greensock.TweenMax;
	import com.jvm.components.Orientation;
	import com.rockdot.library.view.component.common.ComponentScrollable;
	import com.rockdot.library.view.component.common.form.list.Cell;
	import com.rockdot.library.view.component.common.scrollable.event.SliderEvent;
	import com.rockdot.plugin.screen.displaylist.view.SpriteComponent;

	import flash.events.MouseEvent;

	/**
	 * @author Nils Doehring (nilsdoehring@gmail.com)
	 */
	public class ComponentList extends ComponentScrollable {
		//
		protected var _cellClass : Class;
		protected var _constantCellSize : Boolean;
		protected var _cellSize : Number;
		protected var _bufferSize : uint = 20;
		protected var _mouseDownCell : Cell;
		protected var _cellMoved : Boolean;
		protected var _cellSelectedLookup : Array;
		protected var _reusableCellPool : Array;
		protected var _cellsLoaded : int;
		protected var _padding : int;
		protected var _scrollPos : int;
		protected var _totalViewSize : uint;
		protected var _oldVScrollbarValue : int;
		
		private var _data : Array;
		private var _originX : Number = 0;
		private var _originY : Number = 0;

		public function ComponentList(orientation : String, cellClass : Class, scrollbarClass : Class, constantCellSize : Boolean) {
			_cellClass = cellClass;
			_reusableCellPool = [];
			_constantCellSize = constantCellSize;

			
			super(orientation, new SpriteComponent(), scrollbarClass);
		}

		override public function render() : void {
			var i : int;
			var n : uint = cellContainer.numChildren;
			var cell : Cell;

			for (i = 0; i < n; i++) {
				cell = Cell(cellContainer.getChildAt(i));
				cell.setSize(_width, _height);
			}
			
			super.render();
			_updateCells();
		}
		
		public function setData(data : Array) : void {
			_data = data;
			init();
		}

		public function init() : void {
			_totalViewSize = 0;
			_cellSelectedLookup = [];
			_cellsLoaded = 0;
			var numDataEntries : int = _data.length;
			var cell : Cell;
			var fromIndex : uint = _cellsLoaded;
			var i : int;

			// Constant cell height
			if (_constantCellSize) {
				cell = _getCell();
				cell.id = 0;
				cell.data = _data[0];
				cellContainer.addChild(cell);
				_cellSelectedLookup[0] = false;

				_cellSize = cell[SIZE] + _padding;
				_totalViewSize = numDataEntries * _cellSize - _padding;
				_cellsLoaded = numDataEntries;
				var cellsInFrame : uint = Math.ceil(_frame[SIZE] / _cellSize);
				for (i = 1; i < numDataEntries; i++) {
					if (i < cellsInFrame) {
						cell = _getCell();
						cell.id = i;
						cell.data = _data[i];
						cell[POS] = i * _cellSize;
						cellContainer.addChild(cell);
					}
					_cellSelectedLookup[i] = false;
				}
			} else {
				// Variable cell height
				for (i = fromIndex; i < _bufferSize; i++) {
					if (i < numDataEntries) {
						if (i == fromIndex) _scrollPos = -_totalViewSize;
						cell = _getCell();
						cell.id = i;
						cell.data = _data[i];
						if (_totalViewSize < _frame[SIZE]) {
							// Show cell
							cell[POS] = _totalViewSize;
							_totalViewSize += Math.round(cell[SIZE]) + _padding;
							cellContainer.addChild(cell);
						} else {
							// Only precalculate cell height
							_totalViewSize += Math.round(cell[SIZE]) + _padding;
							_putCellInPool(cell);
						}
						_cellSelectedLookup[i] = false;
						_cellsLoaded++;
					}
				}
				_totalViewSize -= _padding;
			}
			render();
			if (this[SCROLLER].enabled) this[SCROLLER].value = -_scrollPos;
		}
		
		
		override public function destroy() : void {
			
			stage.removeEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove);
			
			super.destroy();
		}


		private function _calcNextCells() : void {
			if(!_data){
				return;
			}
			
			var numDataEntries : int = _data.length;
			var cell : Cell;
			var fromIndex : uint = _cellsLoaded;
			var n : uint = _cellsLoaded + _bufferSize;
			for (var i : int = fromIndex; i < n; i++) {
				if (i < numDataEntries) {
					cell = _getCell();
					cell.id = i;
					cell.data = _data[i];

					// Only precalculate cell height
					_totalViewSize += Math.round(cell[SIZE]) + _padding;
					_putCellInPool(cell);
					_cellSelectedLookup[i] = false;
					_cellsLoaded++;
				}
			}
			updateScrollbars();
		}


		public function jumpToCell(nr : uint) : void {
			_vScrollbar.killPageTween();
			clearMomentum();
			this[SCROLLER].interactionStart();
			if (_constantCellSize) {
				if (this[SCROLLER].enabled) this[SCROLLER].value = nr * _cellSize;
			} else {
				if (this[SCROLLER].enabled) {
					var cell : Cell;
					var targetPos : uint;
					cell = _getCell();
					for (var i : int = 0; i < nr; i++) {
						cell.id = i;
						cell.data = _data[i];
						targetPos += Math.round(cell[SIZE] + _padding);
					}

					var safetyFlag : int = -1;
					while (this[SCROLLER].value != targetPos) {
						if (safetyFlag != this[SCROLLER].value) {
							safetyFlag = this[SCROLLER].value;
							this[SCROLLER].value = targetPos;
						} else {
							break;
						}
					}
				}
			}
			this[SCROLLER].interactionEnd();
		}


		override public function updateScrollbars() : void {
			if (_orientation == Orientation.HORIZONTAL) {
				_hScrollbar.enabled = _totalViewSize > _width;
				_hScrollbar.max = Math.max(0, _totalViewSize - _width);
				_vScrollbar.enabled = _view.height > _height;
				_vScrollbar.max = Math.max(0, _view.height - _height);
			} else {
				_hScrollbar.enabled = _view.width > _width;
				_hScrollbar.max = Math.max(0, _view.width - _width);
				_vScrollbar.enabled = _totalViewSize > _height;
				_vScrollbar.max = Math.max(0, _totalViewSize - _height);
			}
			_updateThumbs();
		}


		override protected function _updateThumbs() : void {
			if (_orientation == Orientation.HORIZONTAL) {
				_hScrollbar.pages = _totalViewSize / _width;
				_vScrollbar.pages = _view.height / _height;
			} else {
				_hScrollbar.pages = _view.width / _width;
				_vScrollbar.pages = _totalViewSize / _height;
			}
		}


		override protected function _onHScrollbarChange(event : SliderEvent) : void {
			if (_orientation == Orientation.VERTICAL) super._onHScrollbarChange(event);
			else _onScrollbarChange(event);
		}


		override protected function _onVScrollbarChange(event : SliderEvent) : void {
			if (_orientation == Orientation.HORIZONTAL) super._onVScrollbarChange(event);
			else _onScrollbarChange(event);
		}


		private function _onScrollbarChange(event : SliderEvent) : void {
			if (_data) {
				_scrollPos = _oldVScrollbarValue - event.value;
				_oldVScrollbarValue = event.value;
				_updateCells();  
			}
		}


		private function _updateCells() : void {
			var n : uint = cellContainer.numChildren;
			var cell : Cell;
			var cellsToPool : Array = [];
			// Push not visible cells to "cellsToPool"
			for (var i : int = 0; i < n; i++) {
				cell = Cell(cellContainer.getChildAt(i));
				cell[POS] += _scrollPos;
				if (cell[POS] + cell[SIZE] < 0 || cell[POS] > _frame[SIZE]) cellsToPool.push(cell);
			}

			// Put collected cells in pool
			n = cellsToPool.length;
			for (i = 0; i < n; i++) {
				_putCellInPool(cellsToPool[i]);
			}

			// Check, if scrolling up or down
			var firstLoop : Boolean;
			if (_scrollPos > 0) {
				// Scrolling up
				cell = cellContainer.numChildren != 0 ? Cell(cellContainer.getChildAt(0)) : _getCell(true);
				firstLoop = true;
				while (cell[POS] > 0) {
					if (firstLoop) {
						if (!cell.parent) _putCellInPool(cell);
						firstLoop = false;
					}
					cell = _unshiftNewCell(cell);
					if (!cell) break;
					cell[POS] > _frame[SIZE] ? _putCellInPool(cell) : cellContainer.addChildAt(cell, 0);
				}
			} else if (_scrollPos < 0) {
				// Scrolling down
				cell = cellContainer.numChildren != 0 ? Cell(cellContainer.getChildAt(cellContainer.numChildren - 1)) : _getCell(true);
				firstLoop = true;
				while (cell[POS] + cell[SIZE] < _frame[SIZE]) {
					if (firstLoop) {
						if (!cell.parent) _putCellInPool(cell);
						firstLoop = false;
					}
					cell = _pushNewCell(cell);
					if (!cell) break;
					cell[POS] + cell[SIZE] < 0 ? _putCellInPool(cell) : cellContainer.addChild(cell);
				}
			} else {
				
				// TODO: FIXME: Schaune, ob nach unten oder oben angebaut werden muss
				
				// Just update (e.g. render())
				cell = cellContainer.numChildren != 0 ? Cell(cellContainer.getChildAt(0)) : _getCell(true);
				firstLoop = true;
				while (cell[POS] > 0) {
					if (firstLoop) {
						if (!cell.parent) _putCellInPool(cell);
						firstLoop = false;
					}
					cell = _unshiftNewCell(cell);
					if (!cell) break;
					cell[POS] > _frame[SIZE] ? _putCellInPool(cell) : cellContainer.addChildAt(cell, 0);
				}				
				cell = cellContainer.numChildren != 0 ? Cell(cellContainer.getChildAt(cellContainer.numChildren - 1)) : _getCell(true);
				firstLoop = true;
				while (cell[POS] + cell[SIZE] < _frame[SIZE]) {
					if (firstLoop) {
						if (!cell.parent) _putCellInPool(cell);
						firstLoop = false;
					}
					cell = _pushNewCell(cell);
					if (!cell) break;
					cell[POS] + cell[SIZE] < 0 ? _putCellInPool(cell) : cellContainer.addChild(cell);
				}
			}

			if (_oldVScrollbarValue >= this[SCROLLER].max){
				_calcNextCells();
			}
		}


		override protected function _addScrollbars() : void {
			super._addScrollbars();
			
			// H
			if (_hScrollbar)  {
				_hScrollbar.max = _totalViewSize - _width;
			}

			// V
			if (_vScrollbar) {
				_vScrollbar.max = _totalViewSize - _height;
			}
		}


		private function _pushNewCell(oldCell : Cell) : Cell {
			var newCell : Cell = _getCell();
			newCell.id = oldCell.id + 1;
			newCell.data = _data[newCell.id];
			newCell.visible = newCell.data != null;
			_cellSelectedLookup[newCell.id] ? newCell.select() : newCell.deselect();
			newCell[POS] = Math.round(oldCell[POS] + oldCell[SIZE]) + _padding;
			return newCell;

			// if (_data[oldCell.id + 1] == undefined) return null;
			// var newCell : Cell = _getCell();
			// newCell.id = oldCell.id + 1;
			// newCell.data = _data[newCell.id];
			// _cellSelectedLookup[newCell.id] ? newCell.select() : newCell.deselect();
			// newCell[POS] = Math.round(oldCell[POS] + oldCell[SIZE]) + _padding;
			// return newCell;
		}


		private function _unshiftNewCell(oldCell : Cell) : Cell {
			var newCell : Cell = _getCell();
			newCell.id = oldCell.id - 1;
			newCell.data = _data[newCell.id];
			newCell.visible = newCell.data != null;
			_cellSelectedLookup[newCell.id] ? newCell.select() : newCell.deselect();
			newCell[POS] = Math.round(oldCell[POS] - newCell[SIZE]) - _padding;
			return newCell;

			// if (_data[oldCell.id - 1] == undefined) return null;
			// var newCell : Cell = _getCell();
			// newCell.id = oldCell.id - 1;
			// newCell.data = _data[newCell.id];
			// _cellSelectedLookup[newCell.id] ? newCell.select() : newCell.deselect();
			// newCell[POS] = Math.round(oldCell[POS] - newCell[SIZE]) - _padding;
			// return newCell;
		}


		private function _getCell(pop : Boolean = false) : Cell {
			var cell : Cell;
			if (_reusableCellPool.length == 0) {
				cell = new _cellClass(_width);
				cell.setSize(_width, _height);
				cell.mouseChildren = false;
				cell.addEventListener(MouseEvent.MOUSE_DOWN, _onCellMouseDown, false, 0, true);
				cell.addEventListener(MouseEvent.MOUSE_UP, _onCellMouseUp, false, 0, true);
				cell.submitCallback = _onCellSelected;
				return cell;
			}
			cell = pop ? _reusableCellPool.pop() : _reusableCellPool.shift();
			cell.setSize(_width, _height);
			return cell;
		}


		private function _onCellMouseDown(event : MouseEvent) : void {
			_cellMoved = false;
			
			_originX = stage.mouseX;
			_originY = stage.mouseY;
			
			_mouseDownCell = Cell(event.currentTarget);
			TweenMax.delayedCall(0.1, _onDelayedCellMouseDown);
		}


		private function _onDelayedCellMouseDown() : void {
			if (_mouseDownCell) _mouseDownCell.select();
		}


		private function _onCellMouseUp(event : MouseEvent) : void {
			if (!_cellMoved && _mouseDownCell) {
				_mouseDownCell.select();
				_submitCallback.call(null, _mouseDownCell);
			}
			_mouseDownCell = null;
		}


		private function _putCellInPool(cell : Cell) : void {
			if (cell.parent) cell.parent.removeChild(cell);
			_reusableCellPool.push(cell);
			_cellSelectedLookup[cell.id] = cell.isSelected;
		}


		public function deselectAllCells(exception : int = -1) : void {
			var n : uint = cellContainer.numChildren;
			var cell : Cell;
			for (var i : int = 0; i < n; i++) {
				cell = Cell(cellContainer.getChildAt(i));
				if (cell.id != exception) cell.deselect();
			}

			n = _cellSelectedLookup.length;
			for (i = 0; i < n; i++) {
				_cellSelectedLookup[i] = false;
			}
		}


		override protected function _onViewMouseDown(event : MouseEvent) : void {
			_touching = true;
			if (_hScrollbar.enabled) {
				_hScrollbar.interactionStart(false, false);
				_mouseOffsetX = stage.mouseX + _hScrollbar.value;
			} else {
				_mouseOffsetX = stage.mouseX;
			}

			if (_vScrollbar.enabled) {
				_vScrollbar.interactionStart(false, false);
				_mouseOffsetY = stage.mouseY + _vScrollbar.value;
			} else {
				_mouseOffsetY = stage.mouseY;
			}

			stage.addEventListener(MouseEvent.MOUSE_UP, _onStageMouseUp, false, 0, true);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, _onStageMouseMove, false, 0, true);
		}


		override protected function _onStageMouseMove(event : MouseEvent) : void {
			super._onStageMouseMove(event);
			
			if(Math.abs(_originX - stage.mouseX) > 3 || Math.abs(_originY - stage.mouseY) > 3){
				_cellMoved = true;
				TweenMax.killDelayedCallsTo(_onDelayedCellMouseDown);
				if (_mouseDownCell) _mouseDownCell.deselect();
			}
			
		}


		protected function _onCellSelected(cell : Cell) : void {
			deselectAllCells(cell.id);
		}


		public function get cellContainer() : SpriteComponent {
			return _view;
		}


		public function get padding() : int {
			return _padding;
		}


		public function set padding(padding : int) : void {
			_padding = padding;
		}


		public function get bufferSize() : uint {
			return _bufferSize;
		}


		public function set bufferSize(bufferSize : uint) : void {
			_bufferSize = bufferSize;
		}
		
		override public function get width():Number{
			return _width;
		}

		
	}
}
