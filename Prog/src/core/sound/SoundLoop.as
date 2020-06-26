package core.sound
{
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.ByteArray;
	import org.flixel.*;
	import flash.display.MovieClip;
	import caurina.transitions.Tweener;

	/**
	 * Playback MP3-Loop (gapless)
	 *
	 * This source code enable sample exact looping of MP3.
	 * 
	 * http://blog.andre-michelle.com/2010/playback-mp3-loop-gapless/
	 *
	 * Tested with samplingrate 44.1 KHz
	 *
	 * <code>MAGIC_DELAY</code> does not change on different bitrates.
	 * Value was found by comparision of encoded and original audio file.
	 *
	 * @author andre.michelle@audiotool.com (04/2010)
	 */
	
	public class SoundLoop extends FlxSound
	{
		private const MAGIC_DELAY:Number = 2257.0; // LAME 3.98.2 + flash.media.Sound Delay

		private const bufferSize: int = 4096; // Stable playback
		
		private const samplesTotal: int = 1539487; // original amount of sample before encoding (change it to your loop)

		private var mp3: Sound = new Sound(); // Use for decoding
		private const out: Sound = new Sound(); // Use for output stream
		private var chan: SoundChannel = new SoundChannel();

		private var samplesPosition: int = 0;

		public  var enabled: Boolean = false;
		private var ultimoVolume: Number = FlxG.volume;
		
		[Embed(source = "../../../../Audio/Release/15c ingame1539486virgula9.mp3")] 	private var SndInGame:Class;

		public function SoundLoop():void
		{
			loadMp3();
		}

			
		private function loadMp3(): void
		{
			mp3 = new SndInGame() as Sound;
			startPlayback();
		}

		private function mp3Complete( event:Event ):void
		{
			play();
		}

		public function startPlayback():void
		{
			out.addEventListener( SampleDataEvent.SAMPLE_DATA, sampleData );
		}

		private function sampleData( event:SampleDataEvent ):void
		{
			if( enabled )
			{
				extract( event.data, bufferSize );
			}
			else
			{
				silent( event.data, bufferSize );
			}
		}

		/**
		 * This methods extracts audio data from the mp3 and wraps it automatically with respect to encoder delay
		 *
		 * @param target The ByteArray where to write the audio data
		 * @param length The amount of samples to be read
		 */
		private function extract( target: ByteArray, length:int ):void
		{
			while( 0 < length )
			{
				if( samplesPosition + length > samplesTotal )
				{
					var read: int = samplesTotal - samplesPosition;

					mp3.extract( target, read, samplesPosition + MAGIC_DELAY );

					samplesPosition += read;

					length -= read;
				}
				else
				{
					mp3.extract( target, length, samplesPosition + MAGIC_DELAY );

					samplesPosition += length;

					length = 0;
				}

				if( samplesPosition == samplesTotal ) // END OF LOOP > WRAP
				{
					samplesPosition = 0;
				}
			}
		}

		private function silent( target:ByteArray, length:int ):void
		{
			target.position = 0;

			while( length-- )
			{
				target.writeFloat( 0.0 );
				target.writeFloat( 0.0 );
			}
		}
		
		public function returnSound():Sound {
			return out;
		}
		
		
		public function volup(volume:Number):void
		{
			chan.soundTransform = new SoundTransform(volume, 0);
		}
	
		public function voldown(volume:Number):void
		{
			chan.soundTransform = new SoundTransform(volume, 0);
		}

		
		
		public function checkSoundEvents() : void
		{
			switch(FlxG.pause)
			{
				case true	:
				
					pause();
				
				break;
				
				case false	:
				
					play();
				
				break;
				
			}
			
		
		}
		
		override public function play():void {
			
			if (!enabled)
			{
				enabled = true;
				out.addEventListener(SampleDataEvent.SAMPLE_DATA, sampleData );
				chan = out.play();
				chan.soundTransform = new SoundTransform(FlxG.volume, 0);
			}
			else
			{
				
				if (FlxG.mute)
				{
					chan.soundTransform = new SoundTransform(0, 0);	
				}
				else
				{
					if (FlxG.volume != ultimoVolume)
					{
						ultimoVolume = FlxG.volume;
						chan.soundTransform = new SoundTransform(ultimoVolume, 0);	
					}
					else
					{
						chan.soundTransform = new SoundTransform(FlxG.volume, 0);
					}
				}
				
			}
		}
		
		override public function pause():void {
			enabled = false;
			out.removeEventListener(SampleDataEvent.SAMPLE_DATA, sampleData );
			chan.soundTransform = new SoundTransform(FlxG.volume, 0);
		}
		
		override public function destroy():void {
			enabled = false;
			out.removeEventListener(SampleDataEvent.SAMPLE_DATA, sampleData );
			chan.soundTransform = new SoundTransform(0, 0);
			chan.stop();
			FlxG.sounds = [];
		}
		
		public function fadeOutSound(timeFade:Number):void {
			Tweener.addTween(chan.soundTransform, { volume:0, time:timeFade });
		}
		
		override public function get volume():Number { return super.volume; }
		
		override public function set volume(value:Number):void 
		{
			chan.soundTransform = new SoundTransform(value, 0);
		}
		
		override protected function updateSound():void 
		{
			chan.soundTransform = new SoundTransform(FlxG.getMuteValue()*FlxG.volume, 0);
		}
	}
}