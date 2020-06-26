package utils 
{
	/**
	 * Usar Rects para guardar margens pode levar a confusoes...
	 * @author Supji
	 */
	public class TWMargin
	{
		protected var m_left: Number;
		protected var m_top: Number;
		protected var m_right: Number;
		protected var m_bottom: Number;
		
		public function TWMargin(l:Number=0, t:Number=0, r:Number=0, b:Number=0) : void
		{
			m_left 	= l;
			m_top 	= t;
			m_right = r;
			m_bottom 	= b;
		}
		
		public function set left(l:Number):void
		{
			m_left = l;
		}
		
		public function set right(r:Number):void
		{
			m_right = r;
		}
		
		public function set top(t:Number):void
		{
			m_top = t;
		}
		
		public function set bottom(b:Number):void
		{
			m_bottom = b;
		}
		
		public function get left():Number
		{
			return m_left;
		}
		
		public function get right():Number
		{
			return m_right;
		}
		
		public function get top():Number
		{
			return m_top;
		}
		
		public function get bottom():Number
		{
			return m_bottom;
		}
		
	}

}