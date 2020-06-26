package org.flixel
{
	/*import flash.display.Bitmap;*/
	import flash.display.BitmapData;
	/*import flash.display.Graphics;*/
	import flash.display.Sprite;
	/*import flash.geom.ColorTransform;*/
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	//import utils.Vector2D
	import org.flixel.FlxSprite;
	/*import org.flixel.data.FlxAnim;*/
	
	/**
	 * 		Esta classe substitui o FlxSprite (The main "game object" class, handles basic physics 
	 * 	and animation) para contemplar modificacoes da TimeWave
	 * 
	 * 		NOTE - Sempre atualizar com a versao corrente da Flixel
	 * 
	 * 		Modificacoes:
	 * 		
	 * 		- velocity: agora e' um Vector2D (classe nossa)
	 * 		- facingCos e facingSin: nossas versoes de facing. facingCos vale -1 para a 
	 * 	esquerda e 1 para a direita, coincidindo assim com o cosseno do angulo. facingSin
	 * 	vale 1 para cima e -1 para baixo, coincidindo com o seno
	 * 
	 * Criacao: 21/7/10
	 * 
	 * @author Bohm-Aharonov
	 */
	public class TWFlxSprite extends FlxSprite
	{
		/**
		 * 	TW
		 * 	Para utilizar com facingCos e facingSin, nossas versoes de facing. Mais abaixo
		 * ha uma funcao para converter entre facing e (facingCos, facingSin)
		 */
		static public const FACING_COS_LEFT:int 	= -1;
		static public const FACING_COS_RIGHT:int 	= 1;
		static public const FACING_COS_UPorDOWN:int = 0;
		
		static public const FACING_SIN_LEFTorRIGHT:int 	= 0;
		static public const FACING_SIN_UP:int 		= 1;
		static public const FACING_SIN_DOWN:int 	= -1;
		
		//TW
		protected var _facingCos:uint;
		protected var _facingSin:uint;
		
		/**
		 * Creates a white 8x8 square <code>FlxSprite</code> at the specified position.
		 * Optionally can load a simple, one-frame graphic instead.
		 * 
		 * @param	X				The initial X position of the sprite.
		 * @param	Y				The initial Y position of the sprite.
		 * @param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
		 */
		public function TWFlxSprite(X:Number=0,Y:Number=0,SimpleGraphic:Class=null)
		{
			super(X, Y, SimpleGraphic);
			/*
			super();
			
			x = X;
			y = Y;

			_flashRect = new Rectangle();
			_flashRect2 = new Rectangle();
			_flashPointZero = new Point();
			offset = new FlxPoint();
			
			scale = new FlxPoint(1,1);
			_alpha = 1;
			_color = 0x00ffffff;
			blend = null;
			antialiasing = false;
			
			finished = false;
			_facing = RIGHT;
			_animations = new Array();
			_flipped = 0;
			_curAnim = null;
			_curFrame = 0;
			_caf = 0;
			_frameTimer = 0;

			_mtx = new Matrix();
			_callback = null;
			if(_gfxSprite == null)
			{
				_gfxSprite = new Sprite();
				_gfx = _gfxSprite.graphics;
			}
			
			if(SimpleGraphic == null)
				createGraphic2(8,8);
			else
				loadGraphic2(SimpleGraphic);*/
		}
		
		/**
		 * Load an image from an embedded graphic file.
		 * 
		 * @param	Graphic		The image you want to use.
		 * @param	Animated	Whether the Graphic parameter is a single sprite or a row of sprites.
		 * @param	Reverse		Whether you need this class to generate horizontally flipped versions of the animation frames.
		 * @param	Width		OPTIONAL - Specify the width of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
		 * @param	Height		OPTIONAL - Specify the height of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
		 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.
		 * 
		 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
		 */
		/*public function loadGraphic2(Graphic:Class,Animated:Boolean=false,Reverse:Boolean=false,Width:uint=0,Height:uint=0,Unique:Boolean=false):TWFlxSprite
		{
			_bakedRotation = 0;
			_pixels = FlxG.addBitmap(Graphic,Reverse,Unique);
			if(Reverse)
				_flipped = _pixels.width>>1;
			else
				_flipped = 0;
			if(Width == 0)
			{
				if(Animated)
					Width = _pixels.height;
				else if(_flipped > 0)
					Width = _pixels.width*0.5;
				else
					Width = _pixels.width;
			}
			width = frameWidth = Width;
			if(Height == 0)
			{
				if(Animated)
					Height = width;
				else
					Height = _pixels.height;
			}
			height = frameHeight = Height;
			resetHelpers();
			return this;
		}*/
		
		/**
		 * Create a pre-rotated sprite sheet from a simple sprite.
		 * This can make a huge difference in graphical performance!
		 * 
		 * @param	Graphic			The image you want to rotate & stamp.
		 * @param	Frames			The number of frames you want to use (more == smoother rotations).
		 * @param	Offset			Use this to select a specific frame to draw from the graphic.
		 * @param	AntiAliasing	Whether to use high quality rotations when creating the graphic.
		 * @param	AutoBuffer		Whether to automatically increase the image size to accomodate rotated corners.
		 * 
		 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
		 */
		/*public function loadRotatedGraphic2(Graphic:Class, Rotations:uint=16, Frame:int=-1, AntiAliasing:Boolean=false, AutoBuffer:Boolean=false):TWFlxSprite
		{
			//Create the brush and canvas
			var rows:uint = Math.sqrt(Rotations);
			var brush:BitmapData = FlxG.addBitmap(Graphic);
			if(Frame >= 0)
			{
				//Using just a segment of the graphic - find the right bit here
				var full:BitmapData = brush;
				brush = new BitmapData(full.height,full.height);
				var rx:uint = Frame*brush.width;
				var ry:uint = 0;
				var fw:uint = full.width;
				if(rx >= fw)
				{
					ry = uint(rx/fw)*brush.height;
					rx %= fw;
				}
				_flashRect.x = rx;
				_flashRect.y = ry;
				_flashRect.width = brush.width;
				_flashRect.height = brush.height;
				brush.copyPixels(full,_flashRect,_flashPointZero);
			}
			
			var max:uint = brush.width;
			if(brush.height > max)
				max = brush.height;
			if(AutoBuffer)
				max *= 1.5;
			var cols:uint = FlxU.ceil(Rotations/rows);
			width = max*cols;
			height = max*rows;
			var key:String = String(Graphic) + ":" + Frame + ":" + width + "x" + height;
			var skipGen:Boolean = FlxG.checkBitmapCache(key);
			_pixels = FlxG.createBitmap(width, height, 0, true, key);
			width = frameWidth = _pixels.width;
			height = frameHeight = _pixels.height;
			_bakedRotation = 360/Rotations;
			
			//Generate a new sheet if necessary, then fix up the width & height
			if(!skipGen)
			{
				var r:uint = 0;
				var c:uint;
				var ba:Number = 0;
				var bw2:uint = brush.width*0.5;
				var bh2:uint = brush.height*0.5;
				var gxc:uint = max*0.5;
				var gyc:uint = max*0.5;
				while(r < rows)
				{
					c = 0;
					while(c < cols)
					{
						_mtx.identity();
						_mtx.translate(-bw2,-bh2);
						_mtx.rotate(ba*0.017453293);
						_mtx.translate(max*c+gxc, gyc);
						ba += _bakedRotation;
						_pixels.draw(brush,_mtx,null,null,null,AntiAliasing);
						c++;
					}
					gyc += max;
					r++;
				}
			}
			frameWidth = frameHeight = width = height = max;
			resetHelpers();
			return this;
		}*/
		
		/**
		 * This function creates a flat colored square image dynamically.
		 * 
		 * @param	Width		The width of the sprite you want to generate.
		 * @param	Height		The height of the sprite you want to generate.
		 * @param	Color		Specifies the color of the generated block.
		 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.
		 * @param	Key			Optional parameter - specify a string key to identify this graphic in the cache.  Trumps Unique flag.
		 * 
		 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
		 */
		/*public function createGraphic2(Width:uint,Height:uint,Color:uint=0xffffffff,Unique:Boolean=false,Key:String=null):TWFlxSprite
		{
			_bakedRotation = 0;
			_pixels = FlxG.createBitmap(Width,Height,Color,Unique,Key);
			width = frameWidth = _pixels.width;
			height = frameHeight = _pixels.height;
			resetHelpers();
			return this;
		}*/
		
		/**
		 * MODIFICADO - Agora seta tambem facingCos e facingSin
		 * @private
		 */
		override public function set facing(Direction:uint):void
		{
			var changed:Boolean = _facing != Direction;
			_facing = Direction;
			if (changed) {
				calcFrame();
				updateFacingsCosAndSin();
			}
		}
		
		/**
		 * TW
		 */
		public function updateFacingsCosAndSin():void
		{
			_facingCos = facingToFacingCos();
			_facingSin = facingToFacingSin();
		}
		
		
		/**
		 * 	TW
		 * @return o valor facingCos correspondente ao facing atual
		 */
		private function facingToFacingCos():int
		{
			var valor:int;
			switch(facing)
			{
				case LEFT:	valor =	FACING_COS_LEFT;	break;
				case RIGHT:	valor =	FACING_COS_RIGHT;	break;
				case UP:	valor =	FACING_COS_UPorDOWN;	break;
				case DOWN:	valor =	FACING_COS_UPorDOWN;	break;
			}
			return valor;
		}
		
		/**
		 * 	TW
		 * @return o valor facingSin correspondente ao facing atual
		 */
		private function facingToFacingSin():int
		{
			var valor:int;
			switch(facing)
			{
				case LEFT:	valor =	FACING_SIN_LEFTorRIGHT;	break;
				case RIGHT:	valor =	FACING_SIN_LEFTorRIGHT;	break;
				case UP:	valor =	FACING_SIN_UP;	break;
				case DOWN:	valor =	FACING_SIN_DOWN;	break;
			}
			return valor;
		}
		
		/**
		 * TW
		 */
		public function get facingCos():int
		{
			return _facingCos;
		}
		
		/**
		 * TW
		 */
		public function get facingSin():int
		{
			return _facingSin;
		}
		
		/*public function draw(Brush:FlxSprite,X:int=0,Y:int=0):void
		{
			var b:BitmapData = Brush._framePixels;
			
			//Simple draw
			if(((Brush.angle == 0) || (Brush._bakedRotation > 0)) && (Brush.scale.x == 1) && (Brush.scale.y == 1) && (Brush.blend == null))
			{
				_flashPoint.x = X;
				_flashPoint.y = Y;
				_flashRect2.width = b.width;
				_flashRect2.height = b.height;
				_pixels.copyPixels(b,_flashRect2,_flashPoint,null,null,true);
				_flashRect2.width = _pixels.width;
				_flashRect2.height = _pixels.height;
				calcFrame();
				return;
			}

			//Advanced draw
			_mtx.identity();
			_mtx.translate(-Brush.origin.x,-Brush.origin.y);
			_mtx.scale(Brush.scale.x,Brush.scale.y);
			if(Brush.angle != 0)
				_mtx.rotate(Brush.angle * 0.017453293);
			_mtx.translate(X+Brush.origin.x,Y+Brush.origin.y);
			_pixels.draw(b,_mtx,null,Brush.blend,null,Brush.antialiasing);
			calcFrame();
		}*/
	}
}