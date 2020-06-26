package utils
{
	import flash.geom.Point;
	/**
	 * ...
	 * @author Wolff
	 * 
	 * Alteracoes:
	 * - constantes _PIper180 e _180perPI [Brizo] 22/7/10
	 * - getDistanceSqr corrigida [Brizo] 22/7/10
	 */

	 
	public class TWMath
	{
		
		public static const _PIper180	: Number = Math.PI / 180;
		public static const _180perPI	: Number = 180 / Math.PI;
		
		public function TWMath() 
		{
			
		}
		
		public static function areEqual(num1:Number, num2:Number, tolerancy:Number=(Number.MIN_VALUE / 2)):Boolean
		{
			return Math.abs(num1 - num2) < tolerancy;
		}
		
		///	public
		
		/// converte radianos para graus
		public static function radToDeg(radians:Number):Number {
			return radians * _180perPI;
		}
		
		/// converte graus para radianos
		public static function degToRad(degrees:Number):Number {
			return degrees * _PIper180;
		}
		
		///	Retorna o quadrado da distancia entre dois pontos
		public static function getDistanceSqr(point1:Point, point2:Point):Number {
			var diffX:Number = point2.x - point1.x;
			var diffY:Number = point2.y - point1.y;
			var newDiff:Number = Math.abs(diffX * diffX  + diffY * diffY);
			return newDiff;
		}
		
	}

}