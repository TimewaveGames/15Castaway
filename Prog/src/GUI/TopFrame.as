package GUI 
{
	import caurina.transitions.Tweener;
	import org.flixel.FlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	//import org.flixel.FlxRect;
	import org.flixel.FlxSave;
	import org.flixel.TWFlxSprite;
	import core.globais;
	import org.flixel.FlxText;
	import towers.TowersAssets;
	import utils.TWMargin;
	import utils.TWTimer;
	
	/**
	 * 	GUI - Menu superior, escolha de torres, modificacao de torre, informacao de torre. No multiplayer, 
	 * tambem escolha de gufo e Dispatch Bay de gufos
	 * @author G. Wolff, [Brizo]
	 */
	public class TopFrame extends FlxGroup
	{
		[Embed(source = '../../../Art/Release/GUI/gufoWindow/bg.png')] private var imgBackgroundGufos:Class;
		[Embed(source = '../../../Art/Release/GUI/gufoDispatchBay/bg.png')] private var imgBackgroundBay:Class;
		[Embed(source = '../../../Art/Release/GUI/gufoDispatchBay/sendButton.png')] private var imgButtonBay:Class;
		
		[Embed(source = '../../../Art/Release/GUI/turretWindow/bg.png')] private var imgBackgroundTurretMenu:Class;
		
		[Embed(source = '../../../Art/Release/GUI/upperMenu/pilas_small.png')] private var imgUpperMenu_pilas:Class;
		[Embed(source = '../../../Art/Release/GUI/upperMenu/quota_small.png')] private var imgUpperMenu_quota:Class;
		
		//	Duracao (segundos) dos tweenings de alpha em ShowGUI e HideGUI
		public static const alpha_tweening_duration:Number = 0.2;
		
		//
		//	Constantes de posicionamento
		//
		
		/** Comprimento vertical dentro do qual todas as GUIs serao acomodadas */
		private var GUIs_HEIGHT:						uint;
		
		/** Comprimento horizontal dentro do qual a GUI de escolha de torres sera acomodada */
		private var GUI_TWRS_WIDTH:						uint;
		
		/** Comprimento horizontal dentro do qual a GUI de modificacao de torres sera acomodada */
		private const GUI_TWRS_MODIFIERS_WIDTH:			uint = 150;
		
		/** Comprimento horizontal dentro do qual a GUI de tipo de busca de gufos sera acomodada */
		private var GUI_TWRS_SEEKS_WIDTH:				uint;
		
		private var GUI_TWRS_INFOS_WIDTH:				uint = 180;
		
		private var GUI_TWRS_INFOS_HEIGHT:				uint = 100;
		
		/** Bordas das GUIs */
		private const GUIs_BORDERS:			TWMargin = new TWMargin(12, 12, 12, 12);
		
		//	Contantes relativas ao posicionamento dos icones de gufos
		private const NUM_COL:				uint = 4;
		private const NUM_LIN:				uint = 2;
		private const ICON_SIZE:			uint = 32;
		private const SPACE:				uint = 3;
		private const INIT_SPACE_X:			uint = 8;
		private const INIT_SPACE_Y:			uint = 23;
		
		private const TOLERANCE:uint = 8;
		
		//	Contantes relativas ao posicionamento da janela e dos icones de torres
		//private const TBACKGROUND_BORDER_X:	uint = 12;
		//private const TBACKGROUND_BORDER_Y:	uint = 12;
		private const TINIT_SPACE_X:		uint = 6;//3;
		private const TINIT_SPACE_Y:		uint = 21;//3;
		//private const TICON_SIZE:			uint = 32;
		private const TICON_BORDER:			uint = 1;// 2;
		
		/** Ultimo icone selecionado em cada uma das GUIs */
		public static var selectedIcon:Array = [
			null, //ICON_GUFO
			null, //ICON_TOWER
			null, //ICON_TOWER_SEEK
			null, //ICON_TOWER_SMARTNESS
			null, //ICON_TOWER_MODIFY
			null, //ICON_TOWER_INFO
			null, null, null, null, null	//	... prevencao...
		];
		/** ultimo icone selecionado dentre todas as GUIs */
		public static var lastSelectedIcon:Icon = null;
		
		/** */
		static public var mouseIsOverATowerIcon:Boolean;
		
		private var selectedWind:FlxGroup;
		private var windMouseDiff:FlxPoint;
		
		//	TODO - Preencher com os nomes corretos. Vai usar mesmo??
		private var arrayTowers:Array = ["nome1", "nome2", "nome3", "nome4", "nome5", "nome6", "nome7", 
			"nome8", "nome9", "nome10", "nome11", "nome12", "nome13", "nome14", "nome15", "nome16"];
		private var arrayTowersModifiers:Array = ["sell", "upgrade"];
		private var onStageTowerIcon:Array = [];
		private var backgroundTowers:TWFlxSprite = new TWFlxSprite;
		
		/** Outline de cada tipo de GUI */
		static public var outline:Array = [
			null, //ICON_GUFO
			null, //ICON_TOWER
			null, //ICON_TOWER_SEEK
			null, //ICON_TOWER_SMARTNESS
			null, //ICON_TOWER_MODIFY
			null, //ICON_TOWER_INFO
			null, null, null, null, null	//	... prevencao...
		];
		
		//	GUI de modificacao de torres
		protected var backgroundTwrsModifiers:	TWFlxSprite = new TWFlxSprite;
		static public var iconUpgrade:			Icon;
		static public var iconSell:				Icon;
		protected var towerToModify_name:		FlxText;
		protected var towerToModify_description:FlxText;
		
		//	GUI de tipo de busca de gufo (seek type)
		static public var iconStock:			Icon;
		static public var iconHurry:			Icon;
		static public var iconLastHope:			Icon;
		static public var iconMercy:			Icon;
		private var onStageTowerSeekIcon:		Array = [];
		private var arrayTowerSeeks:			Array = ["nome1", "nome2", "nome3", "nome4"];
		
		//	GUI de informacoes das torres
		protected var backgroundTwrsInfos:		TWFlxSprite = new TWFlxSprite;
		protected var infoTower_name:			FlxText;
		protected var infoTower_description:	FlxText;
		
		//
		private var backgroundBay:				TWFlxSprite;
		private var buttonGo:					FlxButton;
		private var arrayGufos:					Array = ["nome1", "nome2", "nome3", "nome4", "nome5", "nome6", "nome7", "nome8"];
		private var onStageGufoIcon:			Array = [];
		private var onBayGufoIcon:				Array = [];
		private var backgroundGufos:			TWFlxSprite;
		
		//	GUIs separadas em grupos. Guardam os enderecos das referencias homonimas que estao em globais.as
		public var groupGuiGufos:	FlxGroup;	//	menu com onde vao os gufos disponiveis para adicionar `a dispatch bay + dispatch bay vazia
		public var groupGuiTowers:	FlxGroup;	//	menu onde vao as torres disponiveis para construcao + torres
		public var groupGuiTowersSeeks:FlxGroup;//	icones de criterios de busca de gufos
		public var groupGuiTowersModifiers:FlxGroup;//	menu contextual: modificadores de torre - upgrade, sell. Vai tambem nome e descricao
		public var groupOnBay:		FlxGroup;		//	gufos que estao na dispatch bay
		public var groupUpperMenu:	FlxGroup;	//	menu superior, onde vai o dinheiro, cota de gufos...
		public var groupGuiTowersInfos:FlxGroup;//	menu contextual: informacoes de torre - nome e descricao
		
		/** Ultima GUI que foi mostrada (utilizado para impedir que elementos de uma GUI nao aparecam ao ela ser
		 * mostrada em virtude de estarem sendo invisibilizados por um forEach em curso - isso acontece 
		 * quando uma GUI e' escondida e mostrada novamente em um curto periodo de tempo)*/
		static public var lastShownGUI:int = -1;
		/** Parte da mesma estretegia descrita acima*/
		static public var GUIVisibleAgain:Array = [
			false, //ICON_GUFO
			false, //ICON_TOWER
			false, //ICON_TOWER_SEEK
			false, //ICON_TOWER_SMARTNESS
			false, //ICON_TOWER_MODIFY
			false, //ICON_TOWER_INFO
			false, false, false, false, false	//	... prevencao...
		];
		
		//
		//	Parte superior, onde vai o dinheiro, cota de Gufos...
		//
		
		//	retangulo azul de fundo
		protected var 		upperBlueRect:		TWFlxSprite = new TWFlxSprite(0, 0) ;
		
		//	Texto de tempo para a ultima wave
		
		//	Texto de dinheiro
		protected var		m_actualMoney1:		TWFlxSprite	= new TWFlxSprite(15,10);
		//protected var 		m_actualMoney1:FlxText = new FlxText(50, 20, 60, "Pila$: ");
		static public var 	m_actualMoney2:		FlxText 	= new FlxText(120, 20, 150, " ");
		
		//	Texto de quantidade de Gufos que ainda podem passar
		//protected var 		m_NGufosToReachQuota1:FlxText 	= new FlxText(150, 20, 230, "You can not let more than      Gufos survive");
		protected var 		m_NGufosToReachQuota1:TWFlxSprite = new TWFlxSprite(200, 10);
		static public var 	m_NGufosToReachQuota2:FlxText 	= new FlxText(310, 20, 120, "");
		
		public function TopFrame() 
		{
			groupGuiGufos 			= globais.groupGuiGufos;
			groupGuiTowers 			= globais.groupGuiTowers;
			groupGuiTowersSeeks		= globais.groupGuiTowersSeeks;
			groupGuiTowersModifiers = globais.groupGuiTowersModifiers;
			groupOnBay 				= globais.groupOnBay;
			groupUpperMenu			= globais.groupUpperMenu;
			groupGuiTowersInfos		= globais.groupGuiTowersInfos;
			
			globais.selectableIconsGUIs[Icon.ICON_GUFO] 		= groupGuiGufos;
			//globais.selectableIconsGUIs[Icon.ICON_ON_BAY]		= groupOnBay;
			globais.selectableIconsGUIs[Icon.ICON_TOWER] 		= groupGuiTowers;
			globais.selectableIconsGUIs[Icon.ICON_TOWER_SEEK] 	= groupGuiTowersSeeks;
			globais.selectableIconsGUIs[Icon.ICON_TOWER_MODIFY] = groupGuiTowersModifiers;
			globais.selectableIconsGUIs[Icon.ICON_TOWER_INFO] 	= groupGuiTowersInfos;
			//globais.selectableIconsGUIs[Icon.ICON_TOWER_SMARTNESS]= groupGuiTowersSmartness;
			//globais.selectableIconsGUIs[Icon.ICON_UPPER_MENU]		= groupUpperMenu;
			
			//	GUIs nao scrollam
			groupGuiGufos.scrollFactor 			= new FlxPoint(0, 0);
			groupGuiTowers.scrollFactor 		= new FlxPoint(0, 0);
			groupGuiTowersSeeks.scrollFactor 	= new FlxPoint(0, 0);
			groupGuiTowersModifiers.scrollFactor = new FlxPoint(0, 0);
			groupOnBay.scrollFactor 			= new FlxPoint(0, 0);
			groupUpperMenu.scrollFactor 		= new FlxPoint(0, 0);
			groupGuiTowersInfos.scrollFactor 	= new FlxPoint(0, 0);
			
			//
			//	GUI dos gufos (menu + dispatch bay vazia)
			//
			backgroundGufos = new TWFlxSprite(0,0);
			//backgroundTowers.createGraphic(NUM_COL * (ICON_SIZE + SPACE) + SPACE,NUM_LIN *  (ICON_SIZE + SPACE) + SPACE, 0xccffffff, true);
			backgroundGufos.loadGraphic(imgBackgroundGufos);
			
			backgroundBay = new TWFlxSprite(200, 350);
			backgroundBay.loadGraphic(imgBackgroundBay);
			
			buttonGo = new FlxButton(388, 362,sendGufos);
			buttonGo.loadGraphic(new TWFlxSprite(0, 0, imgButtonBay));
			
			groupGuiGufos.add(backgroundGufos, true);
			groupGuiGufos.add(backgroundBay, true);
			groupGuiGufos.add(buttonGo, true);
			
			//	NOTE - Descomentar no multiplayer
			//add(groupGuiGufos);
			
			//
			//	GUI dos gufos na dispatch bay comeca vazia para depois ir sendo preenchida com gufos selecionados
			//
			//	NOTE - Descomentar no multiplayer
			//add(groupOnBay);
			
			//
			//	GUI escolha de torres
			//
			backgroundTowers.loadGraphic(imgBackgroundTurretMenu);
			backgroundTowers.x = FlxG.width - 290;//(FlxG.width - backgroundTowers.width) / 2.;
			backgroundTowers.y = FlxG.height - backgroundTowers.height - GUIs_BORDERS.bottom;// TBACKGROUND_BORDER_Y;
			groupGuiTowers.add(backgroundTowers, true);
			add(groupGuiTowers);
			
			GUIs_HEIGHT = backgroundTowers.height;	//	Comprimento Y dentro do qual todas as GUIs serao acomodadas
			
			//
			//	GUI criterios busca de torres
			//
			add(groupGuiTowersSeeks);
			
			//
			//	GUI modificadores de torre
			//
			add(groupGuiTowersModifiers);
			
			//
			//	GUI de informacoes de torre
			//
			add(groupGuiTowersInfos);
			
			//
			//	Parte de cima, com texto de dinheiro, cota de gufos...
			//
			
			//	Retangulo azul de fundo
			upperBlueRect.createGraphic/*2*/(FlxG.width, 60, 0xff0a002b);	//	(cor de gufo quando foge)
			upperBlueRect.alpha = 0.9;
			groupUpperMenu.add(upperBlueRect, true);
			
			//	Texto de dinheiro
			m_actualMoney1.loadGraphic/*2*/(imgUpperMenu_pilas);
			m_actualMoney2.color = 0xFF0050;
			m_actualMoney2.size = 22;
			groupUpperMenu.add(m_actualMoney1, true);
			groupUpperMenu.add(m_actualMoney2, true);
			
			//	Texto da cota de Gufos que podem passar
			m_NGufosToReachQuota1.loadGraphic/*2*/(imgUpperMenu_quota);
			m_NGufosToReachQuota2.color = 0xFF0050;
			m_NGufosToReachQuota2.size = 22;
			groupUpperMenu.add(m_NGufosToReachQuota1, true);
			groupUpperMenu.add(m_NGufosToReachQuota2, true);
			
			add(groupUpperMenu);
			
			//
			//	Criando elementos ainda nao criados das GUIs e posicionando na tela
			//
			putGufosIcons();
			putTowersIcons();
			
			//
			//	Disponibilidade inicial das GUIs
			//
			groupGuiTowers.visible 			= true;
			groupGuiTowersSeeks.visible 	= true;
			groupGuiTowersModifiers.visible = false;
			groupGuiTowersInfos.visible 	= false;
			
			//
			//	Inicializando icone selecionado de cada tipo de GUI
			//
			selectedIcon[Icon.ICON_GUFO] 			= null;
			selectedIcon[Icon.ICON_TOWER] 			= null;// globais.groupGuiTowers.members[2];	//	TODO - 1o membro entre os disponiveis na fase
			selectedIcon[Icon.ICON_TOWER_SEEK] 		= globais.groupGuiTowersSeeks.members[0];//	TODO - idem acima
			selectedIcon[Icon.ICON_TOWER_SMARTNESS] = null;
			selectedIcon[Icon.ICON_TOWER_MODIFY] 	= null;// globais.groupGuiTowersModifiers.members[0];//	TODO - idem acima
			selectedIcon[Icon.ICON_TOWER_INFO] 		= null;
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////
		///	NOTE - Fora a parte [Brizo], apenas mantive funcionando a parte do Gustavo
		/////////////////////////////////////////////////////////////////////////////////////////
		override public function update():void 
		{	
			if (groupGuiGufos.members[0] != TopFrame.selectedIcon[Icon.ICON_GUFO] && TopFrame.selectedIcon[Icon.ICON_GUFO] != null) {
				groupGuiGufos.members.splice(groupGuiGufos.members.lastIndexOf(TopFrame.selectedIcon[Icon.ICON_GUFO]), 1);
				groupGuiGufos.members.push(TopFrame.selectedIcon[Icon.ICON_GUFO]);
				onStageGufoIcon.splice(onStageGufoIcon.lastIndexOf(TopFrame.selectedIcon[Icon.ICON_GUFO]), 1);
				onStageGufoIcon.push(TopFrame.selectedIcon[Icon.ICON_GUFO]);
			}
			
			if (FlxG.mouse.justReleased() && TopFrame.selectedIcon[Icon.ICON_GUFO] != null) {
				checkForSwitch();
				checkForAddBay();
				TopFrame.selectedIcon[Icon.ICON_GUFO] = null;
			}
			
			///	[Brizo]
			///	- Retorna o icone clicado a seu lugar e coloca o outline em cima dele
			///	- Executa funcao de callBack do ultimo icone clicado
			if (FlxG.mouse.justReleased())
			{
				if (lastSelectedIcon != null)
				{
					lastSelectedIcon.returnToPlace();
					if (outline[lastSelectedIcon._type] != null && TopFrame.selectedIcon[lastSelectedIcon._type] != null)
					{
						outline[lastSelectedIcon._type].x = TopFrame.selectedIcon[lastSelectedIcon._type].x;
						outline[lastSelectedIcon._type].y = TopFrame.selectedIcon[lastSelectedIcon._type].y;
					}
					/*
					//TopFrame.selectedIcon[Icon.ICON_TOWER].returnToPlace();
					outline[Icon.ICON_TOWER].x = TopFrame.selectedIcon[Icon.ICON_TOWER].x;
					outline[Icon.ICON_TOWER].y = TopFrame.selectedIcon[Icon.ICON_TOWER].y;
					//TopFrame.selectedIcon[Icon.ICON_TOWER_SEEK].returnToPlace();
					outline[Icon.ICON_TOWER_SEEK].x = TopFrame.selectedIcon[Icon.ICON_TOWER_SEEK].x;
					outline[Icon.ICON_TOWER_SEEK].y = TopFrame.selectedIcon[Icon.ICON_TOWER_SEEK].y;*/
					if (lastSelectedIcon.function_OnRelease != null && lastSelectedIcon.visible)
					{
						lastSelectedIcon.OnRelease();
						if (lastSelectedIcon == TopFrame.iconSell || lastSelectedIcon == TopFrame.iconUpgrade)
							lastSelectedIcon = null;
					}
				}
			}
			//////////////
			
			super.update();
			
		}
		
		///	Apenas mantive funcionando a parte do Gustavo...
		private function checkForSwitch():void {
			var oldPos:FlxPoint;
			for (var i:int = 0; i < onStageGufoIcon.length; i++) 
			{
				if (TopFrame.selectedIcon[Icon.ICON_GUFO].x + TOLERANCE >= onStageGufoIcon[i].x 
					&& TopFrame.selectedIcon[Icon.ICON_GUFO].x - TOLERANCE <= onStageGufoIcon[i].x 
					&& TopFrame.selectedIcon[Icon.ICON_GUFO].y + TOLERANCE >= onStageGufoIcon[i].y 
					&& TopFrame.selectedIcon[Icon.ICON_GUFO].y - TOLERANCE <= onStageGufoIcon[i].y) 
				{
					oldPos = TopFrame.selectedIcon[Icon.ICON_GUFO].getPosMenu();
					TopFrame.selectedIcon[Icon.ICON_GUFO].setNewPlace(0, 0, onStageGufoIcon[i].getPosMenu());
					onStageGufoIcon[i].setNewPlace(0, 0, oldPos);
					TopFrame.selectedIcon[Icon.ICON_GUFO].returnToPlace();
					onStageGufoIcon[i].returnToPlace();
					return;
				}
			}
			TopFrame.selectedIcon[Icon.ICON_GUFO].returnToPlace();
		}
		
		///	Apenas mantive funcionando a parte do Gustavo...
		private function checkForAddBay():void {
			//if (TopFrame.selectedIcon.overlaps(backgroundBay)) {
				groupOnBay.add(new TWFlxSprite(backgroundBay.x,backgroundBay.y + 10,Icon.arrayIconsGufos[TopFrame.selectedIcon[Icon.ICON_GUFO]._index]));
			//}
			organizeBay();
		}
		
		///	Apenas mantive funcionando a parte do Gustavo...
		private function organizeBay():void {
			var spacing:Number = 160 / groupOnBay.members.length;
			for (var i:int = 0; i < groupOnBay.members.length; ++i) {
				groupOnBay.members[i].x = backgroundBay.x + (i * spacing) + 5;
			}
		}
		
		///	Apenas mantive funcionando a parte do Gustavo...
		private function sendGufos():void {
			while (groupOnBay.members.length > 0) {
				groupOnBay.remove(groupOnBay.members[0], true);
			}
		}
		
		//////////////////////////////////////////////////////////////////////////////
		///		Posiciona os icones correspondentes aos gufos
		//////////////////////////////////////////////////////////////////////////////
		private function putGufosIcons():void {
			
			var posX:uint = INIT_SPACE_X;
			var posY:uint = INIT_SPACE_Y;
			var color:Number;
			var newIcon:Icon;
			
			for (var i:int = 0; i < arrayGufos.length; i++) 
			{
				if (i % 4 == 0 && i != 0) {
					posX = INIT_SPACE_X;
					posY += ICON_SIZE + SPACE;
				}
				
				newIcon = new Icon(Icon.ICON_GUFO, arrayGufos[i], backgroundGufos.x + posX, backgroundGufos.y + posY, Math.floor(Math.random() * 3));
				onStageGufoIcon.push(newIcon);
				
				//	Inclui' o super(x,y) no construtor do Icon. Agora n tem mais este bugre de ter q setar x e y de novo
				//newIcon.x = backgroundGufos.x + posX;
				//newIcon.y = backgroundGufos.y + posY;
				
				groupGuiGufos.add(newIcon,true);
				
				posX += ICON_SIZE + SPACE;
			}
		}
		
		//////////////////////////////////////////////////////////////////////////////
		///		Posiciona os icones correspondentes aos modelos de torres, tipos de busca de gufos
		///	e modificacao de torres (venda/upgrade)
		//////////////////////////////////////////////////////////////////////////////
		private function putTowersIcons():void
		{
			var posX:Number = backgroundTowers.x + TINIT_SPACE_X;
			var posY:Number = backgroundTowers.y + TINIT_SPACE_Y;
			var color:Number;
			var newIcon:Icon;
			
			//	Modelos de torres
			//	FIXME - Esse 8 esta' hard-coded!!!
			for (var i:uint = 0; i < 8/*arrayTowers.length*/; i++) 
			{					
				if (i % 4 == 0 && i != 0) {	//	4 colunas...
					posX = backgroundTowers.x + TINIT_SPACE_X;
					posY += TowersAssets.dimY_TIcons + TICON_BORDER;
				}
				else
				{
					if (i != 0)
						posX += TowersAssets.dimX_TIcons + TICON_BORDER;
				}
				
				FlxG.log(posX + " " + posY)
				newIcon = new Icon(Icon.ICON_TOWER, arrayTowers[i], posX, posY, i);
				
				//	Se o icone esta' fora da lista de torres permitidas, pinta de cinza e marca dead = true
				if (globais.availableTowersIDs.lastIndexOf(i) == -1)
				{
					FlxG.log("Torre " + i + " esta' fora!");
					newIcon.color = 0x80202020;
					newIcon.active = false;
				}
				
				onStageTowerIcon.push(newIcon);
				
				groupGuiTowers.add(newIcon,true);
			}
			outline[Icon.ICON_TOWER] = new TWFlxSprite;
			outline[Icon.ICON_TOWER].createGraphic(TowersAssets.dimX_TIcons, TowersAssets.dimY_TIcons, 0x800000ff);
			groupGuiTowers.add(outline[Icon.ICON_TOWER], true);
			
			//	Tipos de busca de gufos
			var nSeekIcons:Number = 4.;
			var vspacing:Number = (GUIs_HEIGHT - TowersAssets.dimY_TSeekIcons * nSeekIcons) / (nSeekIcons-1);
			posX = backgroundTowers.x - TowersAssets.dimX_TSeekIcons - GUIs_BORDERS.left;//backgroundTowers.x + backgroundTowers.width + 2;
			posY = backgroundTowers.y;
			iconStock	 = new Icon(Icon.ICON_TOWER_SEEK, arrayTowerSeeks[0], posX, posY, 0);
			onStageTowerSeekIcon.push(iconStock);
			groupGuiTowersSeeks.add(iconStock, true);
			posY += TowersAssets.dimY_TSeekIcons + vspacing;
			iconHurry	 = new Icon(Icon.ICON_TOWER_SEEK, arrayTowerSeeks[1], posX, posY, 1);
			onStageTowerSeekIcon.push(iconHurry);
			groupGuiTowersSeeks.add(iconHurry, true);
			posY += TowersAssets.dimY_TSeekIcons + vspacing;
			iconLastHope = new Icon(Icon.ICON_TOWER_SEEK, arrayTowerSeeks[2], posX, posY, 2);
			onStageTowerSeekIcon.push(iconLastHope);
			groupGuiTowersSeeks.add(iconLastHope, true);
			posY += TowersAssets.dimY_TSeekIcons + vspacing;
			iconMercy	 = new Icon(Icon.ICON_TOWER_SEEK, arrayTowerSeeks[3], posX, posY, 3);
			onStageTowerSeekIcon.push(iconMercy);
			groupGuiTowersSeeks.add(iconMercy, true);
			/*for (i = 0; i < nSeekIcons; i++) 
			{
				newIcon = new Icon(Icon.ICON_TOWER_SEEK, arrayTowerSeeks[i], posX, posY, i);
				
				onStageTowerSeekIcon.push(newIcon);
				groupGuiTowersSeeks.add(newIcon, true);
				
				posY += TowersAssets.dimY_TSeekIcons + vspacing;
			}*/
			outline[Icon.ICON_TOWER_SEEK] = new TWFlxSprite;
			outline[Icon.ICON_TOWER_SEEK].createGraphic(TowersAssets.dimX_TSeekIcons, TowersAssets.dimY_TSeekIcons, 0x800000ff);
			groupGuiTowersSeeks.add(outline[Icon.ICON_TOWER_SEEK], true);
			
			//
			//	Modificadores de torre (upgrade, sell. Mais nome e descricao)
			//
			posX = onStageTowerSeekIcon[0].x - GUI_TWRS_MODIFIERS_WIDTH - GUIs_BORDERS.left;
			
			backgroundTwrsModifiers.createGraphic(GUI_TWRS_MODIFIERS_WIDTH, backgroundTowers.height, 0x55505080);
			backgroundTwrsModifiers.alpha = 0.3;
			backgroundTwrsModifiers.x = posX;
			backgroundTwrsModifiers.y = backgroundTowers.y;
			groupGuiTowersModifiers.add(backgroundTwrsModifiers, true);
			
			towerToModify_name = new FlxText(posX, backgroundTowers.y, GUI_TWRS_MODIFIERS_WIDTH, "<no name>");
			groupGuiTowersModifiers.add(towerToModify_name, true);
			towerToModify_description = new FlxText(posX, backgroundTowers.y + towerToModify_name.height, 
				80, "<no description>");//80=width
			groupGuiTowersModifiers.add(towerToModify_description, true);
			
			iconSell = new Icon(Icon.ICON_TOWER_MODIFY, arrayTowersModifiers[0], posX, 0, 0);//0=sell
			groupGuiTowersModifiers.add(iconSell, true);
			
			iconUpgrade = new Icon(Icon.ICON_TOWER_MODIFY, arrayTowersModifiers[1], posX, 0, 1);//1=upgrade
			groupGuiTowersModifiers.add(iconUpgrade, true);
			posY = FlxG.height - GUIs_BORDERS.bottom - TowersAssets.dimY_TUpgradeIcon;
			//iconUpgrade.y = posY;
			iconUpgrade.setNewPlace(posX, posY);
			iconUpgrade.returnToPlace();
			vspacing = 4;// Espacamento entre iconSell e iconUpgrade
			//posY -= (vspacing + TowersAssets.dimY_TSellIcon);
			//iconSell.y = posY;
			posX += iconUpgrade.width + 4;
			//iconSell.x = posX;
			iconSell.setNewPlace(posX, posY);
			iconSell.returnToPlace();
			
			outline[Icon.ICON_TOWER_MODIFY] = null;	//	nao havera outline aqui
			
			//
			//	Informacoes de torre
			//
			posX = FlxG.width - GUI_TWRS_INFOS_WIDTH - GUIs_BORDERS.right;
			
			backgroundTwrsInfos.createGraphic(GUI_TWRS_INFOS_WIDTH, GUI_TWRS_INFOS_HEIGHT, 0x55505080);
			backgroundTwrsInfos.alpha = 0.3;
			backgroundTwrsInfos.x = posX;
			backgroundTwrsInfos.y = backgroundTowers.y - GUIs_BORDERS.top- GUI_TWRS_INFOS_HEIGHT;
			groupGuiTowersInfos.add(backgroundTwrsInfos, true);
			
			var offsetX:uint = 4;
			var offsetY:uint = 4;
			infoTower_name = new FlxText(posX + offsetX, backgroundTwrsInfos.y + offsetY,
				GUI_TWRS_INFOS_WIDTH - 2*offsetX, "-");
			groupGuiTowersInfos.add(infoTower_name, true);
			
			infoTower_description = new FlxText(posX + offsetX, infoTower_name.y + infoTower_name.height + offsetY, 
				GUI_TWRS_INFOS_WIDTH - 2*offsetX, "-");
			groupGuiTowersInfos.add(infoTower_description, true);		
			
			outline[Icon.ICON_TOWER_INFO] = null;	//	nao havera outline aqui
			
			//
			//	Se projetil e' smart ou nao
			//
			/*posX = backgroundTowers.x - 42 - 1;
			posY = backgroundTowers.y + backgroundTowers.height/2 - 42/2;
			newIcon = new Icon(Icon.ICON_TOWER_SMARTNESS, "icon_tower_smart", posX, posY, i);
			
			onStageTowerSeekIcon.push(newIcon);
			
			//	Pois e', tem q setar x e y de novo...
			newIcon.x = posX;
			newIcon.y = posY;
			
			groupGuiTowers.add(newIcon,true);*/
		}
		
		//
		//	TODO
		//
		public function CenterGUIs(aWichGUIs:int):void
		{
			switch(aWichGUIs)
			{
				case 0:	//	Towers + Towers modifiers + Seeks
					
				break;
				case 1:	//	Towers + Seeks
				break;
				case 2:	//	Towers modifiers + Seeks
				break;
			}
		}
		
		///
		///	Mostra a GUI do grupo indexado por aGUIindex, com tweening do alpha
		///
		static public function ShowGUI(aGUItype:uint):void
		{
			//	Estas variaveis evitam que elementos de uma GUI nao sejam exibidos (ver descricao)
			TopFrame.GUIVisibleAgain[aGUItype] = true;
			lastShownGUI = aGUItype;
			
			var aux:FlxGroup =  globais.selectableIconsGUIs[aGUItype];
			
			//if (selectedIcon[aGUItype] != null)
			//{
				//	Algumas GUIs nao tem outline (TOWER_MODIFY, TOWER_INFO...)
				if(selectedIcon[aGUItype] != null && outline[aGUItype] != null)
				{	
					outline[aGUItype].x = selectedIcon[aGUItype].x;
					outline[aGUItype].y = selectedIcon[aGUItype].y;
				}
				
				aux.members.forEach( show );
				aux.visible = true;
			//}
		}
		
		///
		///	Oculta a GUI do grupo indexado por aGUIindex, com tweening do alpha
		///
		static public function HideGUI(aGUItype:uint):void
		{
			TopFrame.GUIVisibleAgain[aGUItype] = false;
			
			var aux:FlxGroup = globais.selectableIconsGUIs[aGUItype];
			aux.members.forEach( hide );
			TWTimer.setTimeout(	function():void {aux.visible = false;}, TopFrame.alpha_tweening_duration);
		}
		
		static public function show(aCaller:*, index:int, arr:Array):void
		{
			aCaller.active = true;	//	antes de comecar o tweening, ja aceita cliques...
			//	... a nao ser que seja um icone nao disponibilizado neste level
			if(aCaller is Icon)
				if (globais.availableTowersIDs.lastIndexOf(aCaller._index,globais.availableTowersIDs.length-1) == -1)
				{
					//FlxG.log("Torre fora! Nada de mostrar este icone");
					aCaller.active = false;
				}
			aCaller.visible = true;
			Tweener.addTween(aCaller, { alpha:0.85, time:TopFrame.alpha_tweening_duration, rounded:false, transition:"bounceOutIn" } );			
		}
		
		static public function hide(aCaller:*, index:int, arr:Array):void
		{
			aCaller.active = false;	//	antes de comecar o tweening, ja nao aceita mais cliques
			Tweener.addTween(aCaller, { alpha:0, time:TopFrame.alpha_tweening_duration, rounded:false, transition:"bounceOutIn" } );
			TWTimer.setTimeout(
				function():void 
				{
					//	Este if impede que, no caso de a GUI ser tornada invisivel e depois visivel muito em seguida,
					//alguns membros nao aparecerem em virtude do forEach ainda estar em curso
					if (!TopFrame.GUIVisibleAgain[TopFrame.lastShownGUI])
						aCaller.visible = false; 
				}, 
				TopFrame.alpha_tweening_duration
			);
		}
		
		///
		///	Mostra GUI de selecao de torres e GUI de seek types
		///	@param aHide_TowersModifyGUI true: oculta GUI de modificacao de torres
		///
		static public function Show_CreateTowerGUIs(aHide_TowersModifyGUI:Boolean):void
		{
			if (aHide_TowersModifyGUI)
				HideGUI(Icon.ICON_TOWER_MODIFY)
			
			ShowGUI(Icon.ICON_TOWER);
			if(!globais.selectableIconsGUIs[Icon.ICON_TOWER_SEEK].visible)
				ShowGUI(Icon.ICON_TOWER_SEEK);
		}
		
		///
		///	Oculta GUI de selecao de torres e GUI de seek types
		///
		static public function Hide_CreateTowerGUIs():void
		{
			HideGUI(Icon.ICON_TOWER);
			if(globais.selectableIconsGUIs[Icon.ICON_TOWER_SEEK].visible)
				HideGUI(Icon.ICON_TOWER_SEEK);
		}
		
		///
		///	Mostra GUI de modificacao de torres e GUI de seek types
		///	@param aHide_SelectTowersGUI true: oculta GUI de selecao de torres
		///
		static public function Show_TowerModifyGUIs(aHide_SelectTowersGUI:Boolean):void
		{
			if (aHide_SelectTowersGUI)
				HideGUI(Icon.ICON_TOWER)
			
			ShowGUI(Icon.ICON_TOWER_MODIFY);
			if(!globais.selectableIconsGUIs[Icon.ICON_TOWER_SEEK].visible)
				ShowGUI(Icon.ICON_TOWER_SEEK);
		}
		
		///
		///	Oculta GUI de modificacao de torres e GUI de seek types
		///
		static public function Hide_TowerModifyGUIs():void
		{
			HideGUI(Icon.ICON_TOWER_MODIFY);
			if(globais.selectableIconsGUIs[Icon.ICON_TOWER_SEEK].visible)
				HideGUI(Icon.ICON_TOWER_SEEK);
		}
		
		///
		///	Mostra GUI de informacoes da torre sobre a qual o cursor esta' posicionado
		///
		static public function Show_TowerInfoGUI():void
		{
			ShowGUI(Icon.ICON_TOWER_INFO);
		}
		
		///
		///	Oculta GUI de informacoes da torre sobre a qual o cursor esta' posicionado
		///
		static public function Hide_TowerInfoGUI():void
		{
			HideGUI(Icon.ICON_TOWER_INFO);
		}
		
	}
}