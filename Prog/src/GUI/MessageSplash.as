package GUI 
{
	/**
	 * Mensagens de descricao de level, vitoria ou derrota. Com 1 ou 2 botoes de opcoes
	 * O botao 1 pode ser de:
	 * 	- Replay (MessageSplash do tipo typeComplete)
	 * 	- Undo Move (MessageSplash do tipo typeFailWithUndo)
	 * 	- OK (MessageSplash do tipo typeDescription) ou Try Again (MessageSplash do tipo typeFail)
	 * O botao 2:
	 * 	- Next (MessageSplash do tipo typeComplete)
	 * 	- Try Again (MessageSplash do tipo FailWithUndo <- NOTE - nao esta' implementado no momento) 
	 * 
	 * A mensagem de descricao possui um _textLevelName e um _textLevelDescription
	 * 
	 * @author Einstein, Podolski, Rosen, Emerson, Lake, Palmer
	 */
	
	import core.assets.Graphics;
	import org.flixel.FlxPoint;
	import org.flixel.FlxText;
	import org.flixel.TWFlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.TWFlxSprite;
	
	public class MessageSplash extends FlxGroup
	{
		// tipos
		static public const typeDescription:	int = 0;
		static public const typeComplete:		int = 1;
		static public const typeFail:			int = 2;
		static public const typeFailWithUndo:	int = 3;
		static public const typeWonTheGame:		int = 4;
		static public const NTYPES:				int = 5;	
		
		/** tipo: um dentre os 4 acima */
		private var m_type:int = -1;
		
		/** fundo =p */
		private var m_background:TWFlxSprite;
		
		/** botoes */
		private var m_button1:TWFlxButton;
		private var m_button2:TWFlxButton;
		
		/** textos (apenas para o tipo typeDescription)*/
		//	/index{Embedding fonts} /index{Embedding text fonts}
		//[Embed(source = "../../../Art/Release/FONTS/kartika.ttf", fontName="Kartika")] public var FontKartika:String;//, embedAsCFF="false")]
		//[Embed(source = "../../../Art/Release/FONTS/FRAHV.ttf", fontName = "Franklin Gothic Heavy")] public var FontFRAHV:String;//, embedAsCFF="false")]
		[Embed(source = "../../../Art/Release/FONTS/kartika.ttf", fontName="Kartika", embedAsCFF="false")] public var FontKartika:String;//
		[Embed(source = "../../../Art/Release/FONTS/FRAHV.ttf", fontName="Franklin Gothic Heavy", embedAsCFF="false")] public var FontFRAHV:String;//, embedAsCFF="false")]
		private var m_textLevelName:FlxText;
		private var m_textLevelDescription:FlxText;
		
		/** estrelas */
		
		/** dimensoes onde esta' inserido */
		//private var parentDims:FlxPoint;
		
		
		/**
		 * 
		 * @param	type -> m_type
		 * @param	widthToCenter : largura na qual este MessageSplash sera' centralizado
		 * @param	heightToCenter : altura na qual este MessageSplash sera' centralizado
		 * @param	callback_replay_ok_tryagain: funcao de callback ao apertar o botao do tipo replay, undo ou trya again sem opcao de undo
		 * @param	callback_next_tryagain2: funcao de callback ao apertar o botao OK ou o try again com opcao de undo
		 */
		public function MessageSplash(type:uint, widthToCenter:uint, heightToCenter:uint, 
			callbackOK:Function = null, 
			callbackReplay:Function = null, 
			callbackNext:Function = null, 
			callbackTryAgain:Function = null, 
			callbackUndo:Function = null,
			callbackSend:Function = null)
		{
			//	Se o tipo e' invalido, seta como -1 e retorna. Se os callbacks correspondentes ao tipo de botao forem nulos, tambem
			//	Se o tipo e' valido, inicializa o splash com os botoes apropriados e posiciona tudo
			if(type < 0 || type >= MessageSplash.NTYPES)
			{
				m_type = -1;
				return;
			}
			else
			{
				//parentDims = new FlxPoint(widthToCenter, heightToCenter);
				m_type = type;
				switch(m_type)
				{
					case typeDescription: 
						if (callbackOK == null)	
							return;
						m_background = new TWFlxSprite(0, 0, Graphics.imgLevelDescription); 
						m_button1 = new TWFlxButton(0, 0, callbackOK);
						m_button1.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgOK1), new TWFlxSprite(0, 0, Graphics.imgOK2));
						//	textos:
						m_textLevelName = new FlxText(0.05 * m_background.width, 8. / 145. * m_background.height,
							0.9 * m_background.width);
						m_textLevelName.setFormat("Franklin Gothic Heavy", 24, 0x51717E, "center");
						m_textLevelDescription = new FlxText(0.03 * m_background.width, 30. / 145. * m_background.height,
							0.94 * m_background.width);
						m_textLevelDescription.setFormat("Kartika", 24, 0x51717E, "left");
					break;
					case typeComplete: 
						if (callbackReplay == null && callbackNext == null)
							return;
						m_background = new TWFlxSprite(0, 0, Graphics.imgWin);
						m_button1 = new TWFlxButton(0, 0, callbackReplay);
						m_button1.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgReplay1), new TWFlxSprite(0, 0, Graphics.imgReplay2));
						m_button2 = new TWFlxButton(0, 0, callbackNext);
						m_button2.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgNext1), new TWFlxSprite(0, 0, Graphics.imgNext2));
					break;
					case typeWonTheGame: 
						if (callbackReplay == null && callbackSend == null)
							return;
						m_background = new TWFlxSprite(0, 0, Graphics.imgWin);
						m_button1 = new TWFlxButton(0, 0, callbackReplay);
						m_button1.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgReplay1), new TWFlxSprite(0, 0, Graphics.imgReplay2));
						m_button2 = new TWFlxButton(0, 0, callbackSend);
						m_button2.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgSend1), new TWFlxSprite(0, 0, Graphics.imgSend2));
					break;
					case typeFail:
						if (callbackTryAgain == null)
							return;
						m_background = new TWFlxSprite(0, 0, Graphics.imgFail);
						m_button1 = new TWFlxButton(0, 0, callbackTryAgain);
						m_button1.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgTryAgain1), new TWFlxSprite(0, 0, Graphics.imgTryAgain2));
					break;
					case typeFailWithUndo: 
						if (callbackTryAgain == null && callbackUndo == null)
							return;
						m_background = new TWFlxSprite(0, 0, Graphics.imgFail);
						m_button1 = new TWFlxButton(0, 0, callbackUndo);
						m_button1.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgRollback1), new TWFlxSprite(0, 0, Graphics.imgRollback2));
						m_button2 = new TWFlxButton(0, 0, callbackTryAgain);
						m_button2.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgTry2Again1), new TWFlxSprite(0, 0, Graphics.imgTry2Again2));
					break;
				}
			}
			
			add(m_background);
			
			//
			//	Centralizando
			
			//	Posicao centralizada em relacao a um retangulo em (0,0) de dimensoes widthToCenter, heightToCenter
			var xCentered:int = (widthToCenter - m_background.width) / 2;
			var yCentered:int = (heightToCenter - m_background.height) / 2;
			this.x = xCentered;
			this.y = yCentered;
			
			//	Centralizando os botoes
			var spaceBetween:uint = m_background.width / 60;	//	um belo chute
			switch(type)
			{
				case typeDescription: 
					m_button1.x = (m_background.width - m_button1.width) / 2;
					m_button1.y = ( 104 / 132 ) * m_background.height;
					add(m_button1);
				break;
				case typeComplete:
				case typeWonTheGame:	//	typeComplete e typeWonTheGame tem a mesma aparencia
					m_button1.x = ( m_background.width - m_button1.width - m_button2.width - spaceBetween) / 2;
					m_button1.y = ( 96 / 132 ) * m_background.height;
					m_button2.x = m_button1.x + m_button1.width + spaceBetween;
					m_button2.y = m_button1.y;
					add(m_button1);
					add(m_button2);
				break;
				case typeFail:
					m_button1.x = (m_background.width - m_button1.width) / 2;
					m_button1.y = ( 96 / 132 ) * m_background.height;
					add(m_button1);
				break;
				case typeFailWithUndo: 	
					m_button1.x = ( m_background.width - m_button1.width - m_button2.width - spaceBetween ) / 2;
					m_button1.y = ( 96 / 132 ) * m_background.height;
					m_button2.x = m_button1.x + m_button1.width + spaceBetween;
					m_button2.y = m_button1.y;
					add(m_button1);
					add(m_button2);
				break;
			}
			
			//	Adicionando textos (se for typeDescription)
			if (this.m_type == typeDescription)
			{
				add(m_textLevelName);
				add(m_textLevelDescription);
			}
		}
		
		/**
		 * Seta textos de nome e descricao de level
		 */
		public function setDescriptionTexts(lvlName:String, lvlDescription:String):void
		{
			if (this.m_type == typeDescription)
			{
				m_textLevelName.text = lvlName;
				m_textLevelDescription.text = lvlDescription;
			}
		}
		
		/**
		 * Sets <code>active</code> property and extends it to all members (useful to prevent members from processing clicks, for example)
		 */
		public function setActive(actv:Boolean):void
		{
			this.active = actv;
			if (m_button1 != null)
				m_button1.setActive(actv);
			if (m_button2 != null)
				m_button2.setActive(actv);
			/*this.members.forEach(
				function (aCaller:*, index:int, arr:Array):void { 
					if (aCaller != null)
						if (aCaller is TWFlxButton)
							aCaller.setActive(actv); 
						else
							aCaller.active = actv;
				} 
			);*/			
		}
		
		public function show():void
		{
			this.visible = true;
			this.setActive(true);
			/*this.x = (parentDims.x - m_background.width) / 2;
			this.y = (parentDims.y - m_background.height) / 2;*/
		}
		
		/**
		 * 
		 */
		public function hide():void
		{
			this.visible = false;
			this.setActive(false);
			/*this.x = parentDims.x + 100;
			this.y = parentDims.y + 100;*/
		}
		
		/*public function get type():uint
		{
			return m_type;
		}*/
	}

}