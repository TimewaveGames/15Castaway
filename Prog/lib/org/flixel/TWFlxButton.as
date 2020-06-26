package org.flixel
{
	//import core.globais;
	import flash.events.MouseEvent;
	
	/**
	 * A simple button class that calls a function when clicked by the mouse.
	 * Supports labels, highlight states, and parallax scrolling.
	 * 
	 * MODIFICATIONS (TimeWave):
	 * - update() changed for giving the supposed checkbox behavior when _onToggle = true (wasn't working)
	 * - text hint
	 * - Getter and setter for _pressed
	 * - Setter for _callback
	 * - Holds a third sprite (attribute _disabled), for 'disabled state' (active = false)
	 * 	- implements setActive, changing sprite to _disabled if active is setted to false (* NOTE - FIXME * still doesn't
	 * 	work if you didn't load _disabled sprite)
	 * - New property <code>m_mousePressedHere</code> and a event listener to mouse down. To assure that the mouseUp callback
	 * will be triggered just if the user *clicked* *this* button
	 */
	public class TWFlxButton extends FlxGroup
	{
		/**
		 * Set this to true if you want this button to function even while the game is paused.
		 */
		public var pauseProof:Boolean;
		/**
		 * Used for checkbox-style behavior.
		 */
		protected var _onToggle:Boolean;
		/**
		 * Stores the 'off' or normal button state graphic.
		 */
		protected var _off:FlxSprite;
		/**
		 * Stores the 'on' or highlighted button state graphic.
		 */
		protected var _on:FlxSprite;
		/**
		 * ADDED - TimeWave
		 * Stores the 'disabled' button state graphic
		 */
		protected var _disabled:FlxSprite;
		/**
		 * ADDED - TimeWave
		 * Text hint to be shown on mouseover
		 */
		protected var _hint:String;
		/**
		 * Stores the 'off' or normal button state label.
		 */
		protected var _offT:FlxText;
		/**
		 * Stores the 'on' or highlighted button state label.
		 */
		protected var _onT:FlxText;
		/**
		 * This function is called when the button is clicked.
		 */
		protected var _callback:Function;
		/**
		 * Tracks whether or not the button is currently pressed.
		 */
		protected var _pressed:Boolean;
		/**
		 * Whether or not the button has initialized itself yet.
		 */
		protected var _initialized:Boolean;
		/**
		 * Helper variable for correcting its members' <code>scrollFactor</code> objects.
		 */
		protected var _sf:FlxPoint;
		
		/**
		 *	Controlling if mouse was pressed *in this button* and not in another place. This assures we're gonna
		 * get a callback only if we have a click here, not just a mouseUp
		 */
		protected var m_mousePressedHere:Boolean = false;
		
		/**
		 * ADDED - TIMEWAVE
		 * 
		 */
		protected var m_highlightOnMouseOver:Boolean = false;
	
		/**
		 * Creates a new <code>FlxButton</code> object with a gray background
		 * and a callback function on the UI thread.
		 * 
		 * MODIFIED - TimeWave
		 * 
		 * @param	X			The X position of the button.
		 * @param	Y			The Y position of the button.
		 * @param	Callback	The function to call whenever the button is clicked.
		 */
		public function TWFlxButton(X:int,Y:int,Callback:Function,hintText:String="")
		{
			super();
			x = X;
			y = Y;
			//----- TimeWave - now we have a hint text
			_hint = hintText;
			//-----
			width = 100;
			height = 20;
			_off = new FlxSprite().createGraphic(width,height,0xff7f7f7f);
			_off.solid = false;
			add(_off,true);
			_on  = new FlxSprite().createGraphic(width,height,0xffffffff);
			_on.solid = false;
			add(_on, true);
			//----- TimeWave - initializing sprite of the 'disabled' state
			_disabled = new FlxSprite().createGraphic(width, height, 0xff000000);
			_disabled.solid = false;
			add(_disabled, true);
			//-----
			_offT = null;
			_onT = null;
			_callback = Callback;
			_onToggle = false;
			_pressed = false;
			_initialized = false;
			_sf = null;
			pauseProof = false;
		}
		
		/**
		 * Called by the game loop automatically, handles mouseover and click detection.
		 * 
		 * MODIFIED - TimeWave:
		 * 	- _onToggle was supposed to give a checkbox behavior. Now it does.
		 * 	- added onMouseDown
		 */
		override public function update():void
		{
			/*if (_callback == globais.alternateMuteStatus)
			{
				FlxG.log("..");
				if (_onToggle)
					FlxG.log("onToggle");
			}
			else
				FlxG.log("--");*/
			
			if(!_initialized)
			{
				if(FlxG.stage != null)
				{
					FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					FlxG.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);	//	ADDED - TimeWave
					_initialized = true;
				}
			}
			
			super.update();
			
			/*	old code:
			if(overlapsPoint(FlxG.mouse.x,FlxG.mouse.y))
			{
				if(!FlxG.mouse.pressed())
					_pressed = false;
				else if(!_pressed)
					_pressed = true;
				visibility(!_pressed);
			}
			if(_onToggle) visibility(_off.visible);*/
			
			/* new code (TimeWave)*/
			visibility(false);
			var overlaps:Boolean = false;
			if(overlapsPoint(FlxG.mouse.x,FlxG.mouse.y))
			{
				if (!_onToggle)	//	normal button
				{
					if(!FlxG.mouse.pressed())
						_pressed = false;
					else if(!_pressed)
						_pressed = true;
						
					visibility(!_pressed);
				}
				else //	button with checkbox behavior
				{
					if (FlxG.mouse.justReleased())
					{
						_pressed = !_pressed;
					}
				}
				overlaps = true;
			}
			if (_onToggle)
			{
				if (overlaps)
				{
					if(!m_highlightOnMouseOver)
						visibility(_pressed);
					else
						visibility(true);
				}
				else
					visibility(_pressed);
			}
			/*----------------------*/
		}
		
		/**
		 * 	ADDED (TimeWave) - Useful when we have a checkbox behavior (_onToggle = true)
		 */
		public function get pressed():Boolean
		{
			return _pressed;
		}
		
		/**
		 * 	ADDED (TimeWave) - Useful when we have a checkbox behavior (_onToggle = true)
		 */
		public function set pressed(p:Boolean):void
		{
			_pressed = p;
		}
		
		/**
		 * 	ADDED (TimeWave)
		 */
		public function set callback(aCallback:Function):void
		{
			_callback = aCallback;
		}
		
		/**
		 * 	ADDED (TimeWave)
		 */
		public function set hint(txt:String):void
		{
			_hint = txt;
		}
		
		/**
		 * 	ADDED (TimeWave)
		 */
		public function getHint():String
		{
			if (active)
				return _hint;
			else
				return "";
		}
		 
		/**
		 * Set your own image as the button background.
		 * 
		 * MODIFIED - TimeWave
		 * 
		 * @param	Image				A FlxSprite object to use for the button background.
		 * @param	ImageHighlight		A FlxSprite object to use for the button background when highlighted (optional).
		 * @param	ImageDisabled		A FlxSprite object to use for the button background when disabled (optional). <- TimeWave
		 * 
		 * @return	This FlxButton instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadGraphic(Image:FlxSprite,ImageHighlight:FlxSprite=null,ImageDisabled:FlxSprite=null):TWFlxButton
		{
			_off = replace(_off, Image) as FlxSprite;
			//	original code:
			/**/if(ImageHighlight == null)
			{
				if (_on != _off)
					remove(_on);
				_on = _off;	//	NOTE - TimeWave - sure this will not cause bugs when just one FlxSprite is provided
			}
			else
				_on = replace(_on, ImageHighlight) as FlxSprite;/**/
				
			//--- TimeWave: now we have a third sprite, the one to be used when active = false
			//	FIXME - in fact, if ImageDisabled == null, _disabled cannot be shown in visible(..) method... we made
			//a workaround there...
			if(ImageDisabled == null)
			{
				if (_disabled != _off)
					if (_disabled != _on)
						remove(_disabled);
				//_disabled = _off;	//	See previous FIXME
				_disabled.pixels = _off.pixels.clone();	//	//	See previous FIXME
				//	Setting _disabled appearance as the same as _off but greyed
				//_disabled.color = 0xff888888;
			}
			else
				_disabled = replace(_disabled, ImageDisabled) as FlxSprite;
			//--------
				
			//	original code:
			/*_on.solid = _off.solid = false;
			_off.scrollFactor = scrollFactor;
			_on.scrollFactor = scrollFactor;*/
			
			//---- TimeWave:
			_on.solid = _off.solid = _disabled.solid = false;
			_off.scrollFactor = scrollFactor;
			_on.scrollFactor = scrollFactor;
			_disabled.scrollFactor = scrollFactor;
			//-----
			
			width = _off.width;
			height = _off.height;
			refreshHulls();
			return this;
		}

		/**
		 * Add a text label to the button.
		 * 
		 * @param	Text				A FlxText object to use to display text on this button (optional).
		 * @param	TextHighlight		A FlxText object that is used when the button is highlighted (optional).
		 * 
		 * @return	This FlxButton instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadText(Text:FlxText,TextHighlight:FlxText=null):TWFlxButton
		{
			if(Text != null)
			{
				if(_offT == null)
				{
					_offT = Text;
					add(_offT);
				}
				else
					_offT = replace(_offT,Text) as FlxText;
			}
			if(TextHighlight == null)
				_onT = _offT;
			else
			{
				if(_onT == null)
				{
					_onT = TextHighlight;
					add(_onT);
				}
				else
					_onT = replace(_onT,TextHighlight) as FlxText;
			}
			_offT.scrollFactor = scrollFactor;
			_onT.scrollFactor = scrollFactor;
			return this;
		}
		
		/**
		 * Use this to toggle checkbox-style behavior.
		 */
		public function get on():Boolean
		{
			return _onToggle;
			//_onToggle = On;	que raios e' essa linha?
		}
		
		/**
		 * MODIFIED - TIMEWAVE
		 * @private
		 */
		public function set on(On:Boolean):void
		{
			_onToggle = On;
			
			//	Ajusta valor padrao de m_highlightOnMouseOver (se botao se comporta como 
			//checkBox - onToggle == true- , o mouseOver nao mostra o sprite de highlight)
			m_highlightOnMouseOver = !_onToggle;
		}
		
		/**
		 * Para colocar um comportamento diferente do padrao
		 */
		public function set highlightOnMouseOver(h:Boolean):void
		{
			m_highlightOnMouseOver = h;
		}
		
		/**
		 * Called by the game state when state is changed (if this object belongs to the state)
		 */
		override public function destroy():void
		{
			if (FlxG.stage != null)
			{
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			}
		}
		
		/**
		 * Internal function for handling the visibility of the off and on graphics.
		 * 
		 * MODIFIED (TimeWave)
		 * 
		 * @param	On		Whether the button should be on or off.
		 */
		protected function visibility(On:Boolean):void
		{
			//	TimeWave: if button is inactive, shows _disabled sprite (and hides _on and _off)
			if (!active)
			{
				//	OK, dangerous code... if no FlxSprite has been passed to _disabled, don't show it
				//	FIXME - In fact, we shouldn't need this if(..), but, _disabled is not showing in this case... =(
				if (members[2] != null)
				{
					_disabled.visible = true;
					_on.visible = false;
					if(_onT != null) _onT.visible = false;
					_off.visible = false;
					if (_offT != null) _offT.visible = false;
					return;
				}
				
			}
			//-----
			
			if(On)
			{
				_off.visible = false;
				if (_offT != null) _offT.visible = false;
				_on.visible = true;
				if (_onT != null) _onT.visible = true;
				//-----	TimeWave
				_disabled.visible = false;				
				//-----
			}
			else
			{
				_on.visible = false;
				if (_onT != null) _onT.visible = false;
				_off.visible = true;
				if (_offT != null) _offT.visible = true;
				//-----	TimeWave
				_disabled.visible = false;				
				//-----
			}
		}
		
		/**
		 * ADDED by TimeWave
		 * 	As FlxObject's  property 'active' is public, we can't create or override a 'set active' method. We needed
		 * it so we could change the aspect of the button on the (created by ours) 'disabled' state. Because we don't 
		 * want to change FlxObject (it's a very fundamental class), we created this setActive so you set the 'active' 
		 * property and change the appearance accordingly. And - no, we can't make it on update(), because update() is 
		 * skipped for inactive FlxObjects
		 */
		public function setActive(actv:Boolean):void
		{
			this.active = actv;
			
			//	In fact the parameter doesn't matter, the sprite chosen will be the correspondent to de 'disabled state'
			visibility(_on.visible);
		}
		
		/**
		 * ADDED by TimeWave
		 * Internal function for flagging mouseDown. onMouseUp will only trigger the callback if we have mouseDown flagged.
		 * This prevents this button form getting clicked just by a mouseUp (this leads to bugs)
		 */
		protected function onMouseDown(event:MouseEvent):void
		{
			if (!active)
				return;
				
			if (overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
				m_mousePressedHere = true;
			else
				m_mousePressedHere = false;
		}
		
		/**
		 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
		 * MODIFIED - TimeWave - mouseUp isn't sufficient. Now we ask for a real click: mouse down *here* and then mouse up here
		 */
		protected function onMouseUp(event:MouseEvent):void
		{
			//----- TimeWave
			if (!m_mousePressedHere)	
				return;
			
			m_mousePressedHere = false;
			//-----
			
			if (!exists || !visible || !active || !FlxG.mouse.justReleased() || (FlxG.pause && !pauseProof) || (_callback == null)) 
				return;
			
			if (overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
				_callback();
		}
		
	}
}
