package utils 
{
	import org.flixel.FlxObject;
	import org.flixel.FlxState;
	import org.flixel.FlxG;
	
	/**
	 *		NOTE - Se a funcao a ser chamada pelo timer tambem chamar uma funcao 
	 *	de TWTimer, quebra o array de timers?
	 *		
	 * 		Alteracoes:
	 * 		- As chamadas a splice(TWTimer.arrayObject) quebravam o array de 
	 * 	timers. Substitui' por splice(<indice>,1) [Brizo]
	 * 
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
			//FlxG.log("entering timerUpdate()...");
			for (var i:int = 0; i < arrayTimer.length; ++i) {
				//FlxG.log("timerUpdate()... 1...");
				//if (arrayTimer[i] == null)
				//	FlxG.log("timerUpdate()... hmmmm...");				
				
				TWTimer.arrayObject = arrayTimer[i];
				
				TWTimer.arrayObject.counter -= FlxG.elapsed;
					
				if (TWTimer.arrayTimer[i].counter <= 0 && TWTimer.arrayTimer[i].type == "setTimeout") {
					//FlxG.log("timerUpdate()... if .. TWTimer.arrayObject.execute()");
					TWTimer.arrayObject.execute();
					//TWTimer.arrayTimer.splice(TWTimer.arrayObject);
					TWTimer.arrayTimer.splice(i,1);
					
				}else if (TWTimer.arrayTimer[i].counter <= 0 && TWTimer.arrayTimer[i].type == "setInterval") {
					//FlxG.log("timerUpdate()... else .. TWTimer.arrayObject.execute()");
					TWTimer.arrayObject.execute();
					TWTimer.arrayObject.counter = TWTimer.arrayTimer[i].totalTime;
					
					if (TWTimer.arrayObject.loop != 0) {
						TWTimer.arrayObject.loop--;
						if (TWTimer.arrayObject.loop == 0) 
						{
							//TWTimer.arrayTimer.splice(TWTimer.arrayObject);
							TWTimer.arrayTimer.splice(i,1);
						}
					}
				}
			}
			//FlxG.log("exiting timerUpdate()...");
		}
		
		/**
		 * Executa a função escolhida depois de X segundos.
		 *
		 * @param	closure		A funcao a ser executada.
		 * @param	time		Tempo em segundos ate o executar da funcao.
		 * @param	name		Nome caso queira destrui-la futuramente.
		 * 
		 */
		public static function setTimeout(closure:Function,time:Number,name:String = null):void {
			TWTimer.arrayTimer.push( { callName:name, execute:closure, counter:time, totalTime:time, type:"setTimeout" } );
		}
		
		/**
		 * Executa a funcao escolhida a cada X segundos.
		 *
		 * @param	closure		A funcao a ser executada.
		 * @param	time		Tempo em segundos ate o executar da funcao.
		 * @param	name		Nome caso queira destrui-la futuramente.
		 * @param	loops		(Opcional) numero de loops antes de remover o intervalo (0 = infinitos).
		 * 
		 */
		public static function setInterval(closure:Function,time:Number,name:String = null,loops:Number = 0):void {
			TWTimer.arrayTimer.push( { callName:name, execute:closure, counter:time, totalTime:time, type:"setInterval",loop:loops } );
		}
		
		/**
		 * Elimina a funcao de nome escolhido.
		 *
		 * @param	name		Nome da funcao a ser eliminada.
		 * 
		 */
		public static function clearTimeout(name:String):void {
			//FlxG.log("Clearing timer " + name + ". We have " + TWTimer.arrayTimer.length + " timers at this moment:");

			for (var i:int = 0; i < TWTimer.arrayTimer.length; ++i) {
				//if(i>0)	FlxG.log(TWTimer.arrayTimer[i].callName);	//	o 1o e' sempre nulo...
				if (TWTimer.arrayTimer[i].callName == name) {
					//TWTimer.arrayTimer.splice(TWTimer.arrayTimer[i]);
					TWTimer.arrayTimer.splice(i,1);
				}
			}

			//FlxG.log("After clearing timer " + name + ", we have " + TWTimer.arrayTimer.length + " timers.");
		}
		
		/// Limpa todos os timers criados (util para mudanca de estado)
		public static function clearAllTimes():void {
			TWTimer.arrayTimer = [];
		}
	}

}