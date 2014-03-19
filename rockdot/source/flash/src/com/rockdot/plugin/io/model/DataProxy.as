package com.rockdot.plugin.io.model {
	import com.rockdot.core.mvc.RockdotEvent;

	import org.as3commons.async.command.IAsyncCommand;
	import org.as3commons.async.operation.event.OperationEvent;


	/**
	 * @author nilsdoehring
	 */
	public class DataProxy {
		
		private var _dataPageSize : Number;
		
		private var _cursor : Number;
		private var _chunkIndex : int;
		private var _chunkSize : int;

		protected var _dataCache : *;
		public function set dataCache(dataCache : *) : void {
			_dataCache = dataCache;
		}
		public function get dataCache() : * {
			return _dataCache;
		}

		protected var _dataFilterVO : Object;
		public function set dataFilterVO(dataFilterVO : Object) : void {
			_dataFilterVO = dataFilterVO;
		}
		public function get dataFilterVO() : Object {
			return _dataFilterVO;
		}
		
		protected var _dataTotalSize : Number;
		public function set dataTotalSize(dataTotalSize : Number) : void {
			_dataTotalSize = dataTotalSize;
		}
		public function get dataTotalSize() : Number {
			return _dataTotalSize;
		}

		protected var _onDataCallback : Function;
		public function set onDataCallback(onDataCallback : Function) : void {
			_onDataCallback = onDataCallback;
		}
		
		protected var _dataRetrieveCommand : IAsyncCommand;
		public function set dataRetrieveCommand(dataRetrieveCommand : IAsyncCommand) : void {
			_dataRetrieveCommand = dataRetrieveCommand;
		}

		public function DataProxy() {
			_dataFilterVO  = new Object();
			reset();
		}
		

		public function reset() : void {
			_dataTotalSize = 0;
			_dataCache = [];
			_dataPageSize = 100;
			_cursor = 0;
		}

		public function hasChunk(chunkIndex : Number, chunkSize : int) : int {
			
			if(chunkIndex<0){
				return 0;
			}
			if(chunkIndex < _dataTotalSize){
				if(chunkIndex + chunkSize < _dataTotalSize){
					return chunkSize;
				}
				else{
					return _dataTotalSize - chunkIndex;
				}
			}
			return 0;
		}

		public function requestChunk(callBack : Function, chunkIndex : int = -1, chunkSize : int = -1) : void {
			_onDataCallback = callBack;
			
			if(chunkIndex == -1){
				callBack.call(null, _dataCache);
			}
			else if(chunkSize == -1){
				_chunkSize = chunkSize;
				_chunkIndex = chunkIndex;
				_dataRetrieveCommand.addCompleteListener(_onData);
				_dataRetrieveCommand.execute();
			}
			else if(chunkIndex < _cursor){
				 if(chunkIndex + chunkSize >= _cursor){
				 	chunkSize = _cursor - chunkIndex;
				 }
				_onDataCallback.call(null, _dataCache.slice(chunkIndex, chunkIndex+chunkSize));
			}
			else{
				if(dataFilterVO.hasOwnProperty("limit")){
					dataFilterVO.limit = _dataPageSize;
				}
				if(dataFilterVO.hasOwnProperty("limitindex")){
				dataFilterVO.limitindex = _cursor;
				}				
				_cursor += _dataPageSize;

				_chunkIndex = chunkIndex;
				_chunkSize = chunkSize;
//				
				_dataRetrieveCommand.addCompleteListener(_onData);
				_dataRetrieveCommand.execute(new RockdotEvent("data", dataFilterVO));
			}
		}


		private function _onData( event : OperationEvent) : void {
			_dataRetrieveCommand.removeCompleteListener(_onData);
			if(event.result.length == 0){
				_dataTotalSize = 0;
				_onDataCallback.call(this, event.result);
			}
			else{
				if(event.result[0].totalrows){
					_dataTotalSize = event.result[0].totalrows;
					if(_cursor>_dataTotalSize){
						_cursor = _dataTotalSize;
					}
				}
				else{
					//_totalSize = event.result.length;
				}
				_dataCache = _dataCache.concat( event.result);
				if(_chunkIndex != -1){
					_onDataCallback.call(this, _dataCache.slice(_chunkIndex, _chunkIndex+_chunkSize));
				}
				else{
					_onDataCallback.call(this, _dataCache);
				}
			}
		}
	}
}
