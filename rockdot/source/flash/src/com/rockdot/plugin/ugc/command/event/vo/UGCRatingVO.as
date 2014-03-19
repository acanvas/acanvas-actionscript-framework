package com.rockdot.plugin.ugc.command.event.vo {

	/**
	 * @author nilsdoehring
	 */
	public class UGCRatingVO {


		public var id : Number;
		public var rating : Number;

		public function UGCRatingVO(id : Number, rating : Number = -1) {
			this.id = id;
			this.rating = rating;
		}
	}
}
