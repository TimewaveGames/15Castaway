package org.flixel 
{
	/**
	 * ...
	 * @author Supji
	 */
	public class TWFlxSound extends FlxSound
	{
		
		public function TWFlxSound() 
		{
			super();
		}
		
		/**
		 * TW 23/jan/11 - Identico ao set volume, porem, sem restricoes
		 * @private
		 */
		public function set volume_noBounds(Volume:Number):void
		{
			_volume = Volume;
			updateTransform();
		}
	}

}