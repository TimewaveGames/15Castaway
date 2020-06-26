package GUI 
{
	import core.globais;
	import flash.geom.Point;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxG;
	import stages.stage;
	import towers.TowersAssets;
	/**
	 * ...
	 * @author ...
	 */
	public class Icon extends FlxSprite
	{
		[Embed(source = '../../../Art/Release/gufos/icons/gufoIcon1.png')] public static var gufo1:Class;
		[Embed(source = '../../../Art/Release/gufos/icons/gufoIcon2.png')] public static var gufo2:Class;
		[Embed(source = '../../../Art/Release/gufos/icons/gufoIcon3.png')] public static var gufo3:Class;
		
		private var name:String;
		private var posOnMenuX:Number;
		private var posOnMenuY:Number;
		/** Coringa... no caso de icones de torre, estamos usando para guardar o indice da torre correspondente
		 * em globais.towers*/
		//private var _tag:int;
		
		/** Funcao chamada ao fim de clique sobre este icone */
		public var function_OnRelease:Function = null;
		
		public static const arrayIconsGufos:Array = [
			Icon.gufo1, 
			Icon.gufo2, 
			Icon.gufo3
		];
		
		//	NOTE - Imagino que esse array deva ser preenchido no construtor, de acordo com as torres
		//permitidas no stage atual. Idem para o array acima, de icones de gufos	[Brizo] 12/8/10
		public static const arrayIconsTowers:Array = [
			TowersAssets.TowerIconCobble,
			TowersAssets.TowerIconMortar,
			TowersAssets.TowerIconRocket_Launcher,
			TowersAssets.TowerIconPhaserGunMk1,
			TowersAssets.TowerIconFlameThrower,
			TowersAssets.TowerIconQuick,
			TowersAssets.TowerIconFreezy,
			TowersAssets.TowerIconToxic,
			TowersAssets.TowerIconBoulder,
			TowersAssets.TowerIconBarrack_Buster,
			TowersAssets.TowerIconHeavy_Rocket_Launcher,
			TowersAssets.TowerIconPhaser_Gun_Mk2,
			TowersAssets.TowerIconFlameThrower2,
			TowersAssets.TowerIconMurder,
			TowersAssets.TowerIconFreeeezy,
			TowersAssets.TowerIconPoisonous
		];
		
		public static const arrayIconsTowerSeeks:Array = [
			TowersAssets.TowerSeekIconStock,
			TowersAssets.TowerSeekIconHurry,
			TowersAssets.TowerSeekIconLastHope,
			TowersAssets.TowerSeekIconMercy
		];
		
		public static const arrayIconsTowersModifiers:Array = [
			TowersAssets.TowerIconSell,
			TowersAssets.TowerIconUpgrade
		];
		
		public static const arrayIconsTowersInfos:Array = new Array;	//	por enquanto, a GUI de info de torres nao tem icones...
		
		//public static const IconTowerSmart:Class = TowersAssets.TowerIconSmart;
		
		public static const ICON_GUFO:				uint = 0;
		public static const ICON_TOWER:				uint = 1;
		public static const ICON_TOWER_SEEK:		uint = 2;
		public static const ICON_TOWER_SMARTNESS:	uint = 3;
		public static const ICON_TOWER_MODIFY:		uint = 4;
		public static const ICON_TOWER_INFO:		uint = 5;
		
		public var _type:uint;	/**	Tipo do icone */
		public var _index:uint;	/**	Indice do icone no array correspondente a seu tipo*/
		
		public function Icon(aType:uint, aName:String, posX:Number, posY:Number, aIndex:uint)//, aTag:int=-1) 
		{
			
			//	NOTE - Nao vai chamar o super(x,y)???
			super(posX, posY);	//	[Brizo]
			
			//tag = aTag;
			
			_type = aType;
			if (aType == ICON_GUFO)
				this.loadGraphic(Icon.arrayIconsGufos[aIndex]);
			else if (aType == ICON_TOWER)
				this.loadGraphic(Icon.arrayIconsTowers[aIndex]);
			else if (aType == ICON_TOWER_SEEK)
				this.loadGraphic(Icon.arrayIconsTowerSeeks[aIndex]);
			else if (aType == ICON_TOWER_MODIFY)
				this.loadGraphic(Icon.arrayIconsTowersModifiers[aIndex]);
			else if (aType == ICON_TOWER_INFO)
				this.loadGraphic(Icon.arrayIconsTowersInfos[aIndex]);
			//else if(aType == ICON_TOWER_SMARTNESS)
			//	this.loadGraphic(IconTowerSmart);	//	mmm... talvez seja melhor um array duplo...
			this.name = aName;
			posOnMenuX = posX;
			posOnMenuY = posY;
			_index = aIndex;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////
		/// Se estiver visivel e ativo:
		///	- Detecta clique, atualizando TopFrame.selectedIcon[_type] e TopFrame.lastSelectedIcon
		///	- Detecta mouseOver
		/////////////////////////////////////////////////////////////////////////////////////////
		override public function update():void 
		{
			if (visible && active)
			{
				var scrolledX:Number = this.x - FlxG.scroll.x;
				var scrolledY:Number = this.y - FlxG.scroll.y;				
				
				if (FlxG.mouse.x >= scrolledX && 
					FlxG.mouse.x <= scrolledX + this.width && 
					FlxG.mouse.y >= scrolledY && 
					FlxG.mouse.y <= scrolledY + this.height) 
				{
					if (FlxG.mouse.justPressed())
					{
						TopFrame.selectedIcon[_type] = this;
						TopFrame.lastSelectedIcon = this;
					
						//	Desloca o icone clicado de forma a centraliza-lo na posicao clicada
						this.x = FlxG.mouse.x  - FlxG.scroll.x - (this.width >> 1);
						this.y = FlxG.mouse.y  - FlxG.scroll.y - (this.height >> 1);
					}
					
					if (_type == ICON_TOWER)
					{
						//if(_tag != -1)
						//if(hintEnabled)
						TopFrame.mouseIsOverATowerIcon = true;
						globais.UpdateGUITowerInfo(_index);
						if (!globais.selectableIconsGUIs[Icon.ICON_TOWER_INFO].visible)
							TopFrame.Show_TowerInfoGUI();
					}
				}
			}
			
			super.update();
		}
		
		public function returnToPlace():void {
			this.x = posOnMenuX;
			this.y = posOnMenuY;
		}
		
		public function setNewPlace(newX:Number,newY:Number,point:FlxPoint = null):void {
			this.posOnMenuX = newX;
			this.posOnMenuY = newY;
			if (point != null) {
				this.posOnMenuX = point.x;
				this.posOnMenuY = point.y;
			}
		}
		
		public function getPosMenu():FlxPoint {
			return new FlxPoint(this.posOnMenuX, this.posOnMenuY);
		}
		
		///
		///		Registra a funcao de callback de fim de clique sobre este icone - function_OnRelease(), invocada
		///	em OnRelease()
		///
		public function RegisterCallback_OnRelease(aCallback:Function=null):void
		{
			function_OnRelease = aCallback;
		}
		
		///
		///	Executa a funcao de callback de fim de clique - function_OnRelease()
		///
		public function OnRelease():void
		{
			if (function_OnRelease != null)
				function_OnRelease();
		}
		
		/*public function set tag(t:uint):void
		{
			_tag = t;
		}
		
		public function get tag():uint
		{
			return _tag;
		}*/
	}

}