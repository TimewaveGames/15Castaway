package utils 
{
	import org.flixel.FlxObject;
	import org.flixel.FlxState;
	import org.flixel.FlxG;
	
	/**
	 * ...
	 * @author Wolff
	 */
	public class TWTimer
	{
		private static var arrayTimer:Array = [];
		private static var arrayObject:Object;
		
		public function TWTimer() 
		{
			
		}
		
		/// Colocar no update do state atual
		public static function timerUpdate():void 
		{

			for (var i:int = 0; i < arrayTimer.length; ++i) {
				TWTimer.arrayObject = arrayTimer[i];
				
				TWTimer.arrayObject.counter -= FlxG.elapsed;
				
				if (TWTimer.arrayTimer[i].counter <= 0 && TWTimer.arrayTimer[i].type == "setTimeout") {

					TWTimer.arrayObject.execute();
					TWTimer.arrayTimer.splice(TWTimer.arrayObject);
					
				}else if (TWTimer.arrayTimer[i].counter <= 0 && TWTimer.arrayTimer[i].type == "setInterval") {
					
					TWTimer.arrayObject.execute();
					TWTimer.arrayObject.counter = TWTimer.arrayTimer[i].totalTime;
					
					if (TWTimer.arrayObject.loop != 0) {
						TWTimer.arrayObject.loop--;
						if (TWTimer.arrayObject.loop == 0) TWTimer.arrayTimer.splice(TWTimer.arrayObject);
					}
				}
			}
		}
		
		/**
		 * Executa a função escolhida depois de X segundos.
		 *
		 * @param	closure		A função a ser executada.
		 * @param	time		Tempo em segundos até o executar da função.
		 * @param	name		Nome caso queira destrui-la futuramente.
		 * 
		 */
		public static function setTimeout(closure:Function,time:Number,name:String = null):void {
			TWTimer.arrayTimer.push( { callName:name, execute:closure, counter:time, totalTime:time, type:"setTimeout" } );
		}
		
		/**
		 * Executa a função escolhida a cada X segundos.
		 *
		 * @param	closure		A função a ser executada.
		 * @param	time		Tempo em segundos até o executar da função.
		 * @param	name		Nome caso queira destrui-la futuramente.
		 * @param	loops		(Opcional) numero de loops antes de remover o intervalo (0 = infinitos).
		 * 
		 */
		public static function setInterval(closure:Function,time:Number,name:String = null,loops:Number = 0):void {
			TWTimer.arrayTimer.push( { callName:name, execute:closure, counter:time, totalTime:time, type:"setInterval",loop:loops } );
		}
		
		/**
		 * Elimina a função de nome escolhido.
		 *
		 * @param	name		Nome da função a ser eliminada.
		 * 
		 */
		public static function clearTimeout(name:String):void {
			for (var i:int = 0; i < TWTimer.arrayTimer.length; ++i) {
				if (TWTimer.arrayTimer[i].callName == name) {
					//TWTimer.arrayTimer.splice(TWTimer.arrayTimer[i]);
					TWTimer.arrayTimer.splice(i,1);
				}
			}
		}
		
		/// Limpa todos os timers criados (util para mudança de estado)
		public static function clearAllTimes():void {
			TWTimer.arrayTimer = [];
		}
	}

}