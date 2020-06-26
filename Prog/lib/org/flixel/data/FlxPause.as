package org.flixel.data
{
	import org.flixel.*;

	/**
	 * This is the default flixel pause screen.
	 * It can be overridden with your own <code>FlxLayer</code> object.
	 */
	public class FlxPause extends FlxGroup
	{
		/*[Embed(source="key_minus.png")] private var ImgKeyMinus:Class;
		[Embed(source="key_plus.png")] private var ImgKeyPlus:Class;
		[Embed(source="key_0.png")] private var ImgKey0:Class;
		[Embed(source="key_p.png")] private var ImgKeyP:Class;*/

		/**
		 * Constructor.
		 */
		public function FlxPause()
		{
			super();
			scrollFactor.x = 0;
			scrollFactor.y = 0;
			var w:uint = FlxG.width;//80;
			var h:uint = (FlxG.height)/6//92;
			/**/x = 0;
			/**/y = (FlxG.height-h)/2;
			
			var s:FlxSprite;
			s = new FlxSprite().createGraphic(w,h,0xaa000000,true);
			s.solid = false;
			add(s,true);
			
			var txtPause:FlxText = new FlxText(0, 0, w, "Music stopped. Click anywhere to resume.");
			(add(txtPause, true) as FlxText).alignment = "center";
			txtPause.y = (h - txtPause.height) / 2;
			//add((new FlxText(0,10,w,"PAUSED")).setFormat(null,16,0xffffff,"center"),true);
			
			/*s = new FlxSprite(4,36,ImgKeyP);
			s.solid = false;
			add(s,true);
			
			add(new FlxText(16,36,w-16,"Pause Game"),true);
			
			s = new FlxSprite(4,50,ImgKey0);
			s.solid = false;
			add(s,true);
			
			add(new FlxText(16,50,w-16,"Mute Sound"),true);
			
			s = new FlxSprite(4,64,ImgKeyMinus);
			s.solid = false;
			add(s,true);
			
			add(new FlxText(16,64,w-16,"Sound Down"),true);
			
			s = new FlxSprite(4,78,ImgKeyPlus);
			s.solid = false;
			add(s,true);
			
			add(new FlxText(16,78,w-16,"Sound Up"),true);*/
		}
	}
}