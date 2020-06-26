package org.flixel 
{
	/**
	 * 
	 * 	Versoes adaptadas pela TW de funcionalidades da FlxG.as
	 * 
	 * @author Alegre Correa
	 */
	public class TWFlxG_utils
	{
		
		public function TWFlxG_utils() 
		{

		}
		
		/**	
		 * 	Modificacao de FlxG.play
		 * 	- Utiliza TWFlxSound para poder dar um ganho maior que 1 no volume
		 *  - Parametro Survive para setar o survive do FlxSound a ser tocado
		 * 
		 * Creates a new sound object from an embedded <code>Class</code> object.
		 * 
		 * @param	EmbeddedSound	The sound you want to play.
		 * @param	Volume			How loud to play it (0 to 1). <-- MODIFICACAO: nao ha limites
		 * @param	Looped			Whether or not to loop this sound.
		 * 
		 * @return	A <code>FlxSound</code> object.
		 */
		static public function playAtAnyVolume(EmbeddedSound:Class,Volume:Number=1.0,Looped:Boolean=false,Survive:Boolean=false):TWFlxSound
		{
			/**/var i:uint = 0;
			var sl:uint = FlxG.sounds.length;
			while(i < sl)
			{
				if (FlxG.sounds[i] is FlxSound)	//	aqui so' queremos TWFlxSound's
				{
					i++;
					continue;
				}
				if(!(FlxG.sounds[i]).active)
					break;
				i++;
			}
			if(FlxG.sounds[i] == null)
				FlxG.sounds[i] = new TWFlxSound();
			var s:TWFlxSound = FlxG.sounds[i];/**/
			s.loadEmbedded(EmbeddedSound,Looped);
			s.volume_noBounds = Volume;
			s.survive = Survive;
			s.play();
			return s;
		}
		
	}

}