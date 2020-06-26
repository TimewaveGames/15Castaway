package utils 
{
	import org.flixel.FlxG;
	import org.flixel.TWFlxButton;
	/**
	 * Botao de mute/unmute. E' um botao com comportamento de checkBox.
	 * No update, seu estado obedece FlxG.mute.
	 * Ao clique, alterna FlxG.mute
	 * @author TimeWave
	 */
	public class TWMuteBtn extends TWFlxButton
	{
		
		public function TWMuteBtn(X:int,Y:int,hintText:String="") 
		{
			super(X , Y, null, hintText);
			_callback = alternateMuteStatus;
			//this.active = true;
			this.pressed = true;	//	nao esta' muted
			obeyFlxGMuteStatus();
		}
		
		/**
		 * 	- Sincroniza estado do botao com o estado de FlxG.mute
		 * 	- Atualiza hint se ha' mouseOver
		 */
		override public function update():void 
		{
			super.update();
			
			//	Primeiramente, sincronizando o estado do botao com o estado do mute da flixel
			//	(o usuario pode mutar e desmutar teclando "0" ao inves de clicar no botao)
			this.obeyFlxGMuteStatus();
			
			//	Atualizando hint se ha mouseOver
			if (this.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
			{
				if (FlxG.mute)
					this.hint = "Click to unmute";
				else
					this.hint = "Click to mute";
			}
		}
		
		/**
		 *	Sincroniza o estado do botao com o estado do mute da flixel	(o usuario pode mutar e desmutar teclando "0" 
		 * ao inves de clicar no botao)
		 */
		private function obeyFlxGMuteStatus():void
		{
			if (FlxG.mute)
			{
				this.pressed = true;
			}
			else
			{
				this.pressed = false;
			}
		}
		
		/**
		 * Alterna FlxG.mute e atualiza o botao de acordo
		 */
		private function alternateMuteStatus():void
		{
			FlxG.mute = !FlxG.mute;
			this.obeyFlxGMuteStatus();
		}
		
	}

}