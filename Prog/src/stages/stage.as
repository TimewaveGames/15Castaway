package stages 
{
	
	import board.Board;
	import caurina.transitions.Tweener;
	import core.assets.Graphics;
	import core.assets.Sounds;
	import core.sound.SoundLoop;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	import GUI.HelloMetricSplash;
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxText;
	import org.flixel.TWFlxButton;
	import org.flixel.TWFlxSprite;
	import pieces.PiecesAssets;
	import states.SplashState;
	import utils.TWMuteBtn;
	/*import core.factory.ObjectsFactory;*/
	import pieces.Piece;
	import org.flixel.FlxState;
	import org.flixel.FlxGame;
	import org.flixel.FlxRect;
	import org.flixel.FlxG;
	import SWFStats.*;
	import utils.TWMargin;
	import GUI.MessageSplash;
	import core.globais;

	/**
	 * 	
	 * /index{Shared Objects}	/index{Cookies} http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/SharedObject.html
	 * @author Chico Buarque
	 */
	public class stage extends FlxState
	{
		//xml com as caracteristicas deste level
		protected var xmlThisLevel	:	XML		;
		
		//xml com os textos de todos os levels
		protected static var xmlLevelsTexts:XML = new XML(new stageXML.xmlLevelsTexts);		
		
		//Ordem (ou ID) do level
		//protected var m_levelOrder	:	uint	;
		
		//	Conta o tempo de jogo transcorrido em segundos nesta fase (NAO CONTA o tempo de pause - o jogador pode pausar e ficar analisando)
		protected var m_timeLeft	:	Number	;
		
		//	Sinaliza se estamos em jogo ou sob algum splash ou algo assim (util para nao atualizar timers indevidamente, por exemplo)
		protected var m_inGame		:   Boolean	;
		
		//	Botoes
		private var btnUndo:TWFlxButton;
		//	NOTE - NAO CONSIGO USAR O globais.btnMuteUnmute... seu callback perde a referencia quando saimos do MenuState... =/
		private var btnMuteUnmute:TWFlxButton;
		private var btnBack:TWFlxButton;
		private var btnRetry:TWFlxButton;
		private var btnNext:TWFlxButton;
		private var btnSend:TWFlxButton;
		
		//	Hint atual
		protected var hint:FlxText = new FlxText(0, 0, 200, "");
		
		//	Dialogs de derrota, vitoria e descricao de level
		private static var imgFail:TWFlxSprite = new TWFlxSprite(0,0,Graphics.imgFail);
		private static var imgWin:TWFlxSprite = new TWFlxSprite(0,0,Graphics.imgWin);
		private static var imgDescription:TWFlxSprite = new TWFlxSprite(0, 0, Graphics.imgLevelDescription);		
		
		protected var m_levelID			:	uint;
		protected var m_levelName		:	String;
		protected var m_levelDescription:	String;
		protected var m_rescueQuota		:	uint;
		protected var m_movesLeft		:	uint;
		protected var m_topRankQuota	:	uint;
		protected var m_secondRankQuota	:	uint;
		
		protected var m_board			: 	Board;
		
		[Embed(source = "../../../Art/Release/FONTS/kartika.ttf", fontName="Kartika")] public var FontKartika:String;//, embedAsCFF="false")]
		protected var textLevelNumber	:	FlxText;
		protected var textLevelName		:	FlxText;
		protected var textHighScore		:	FlxText;
		protected var textMoves			:	FlxText;
		public var textTipMessage		:	FlxText;// = new FlxText(0, 0, 10);
		protected var tipMessageY		:	uint;
		//protected var textCastawaysToSave:	FlxText = new FlxText(500, 30, 250);
		
		public var m_movesCount			:	uint;
		public var m_undosCount			:	uint;
		//public var m_retriesCount;	tem q ser global
		
		//	message dialogs (ou splashs)
		public var messageFailWithUndo	:	MessageSplash;
		public var messageComplete		:	MessageSplash;
		public var messageDescription	:	MessageSplash;
		public var messageWonTheGame	:	MessageSplash;
		
		//	Musica in-game
		//private var soundLoop			:	SoundLoop;
		
		/** Splash de metrica "How would you rate this game so far?" */
		private var helloMetricSplash:HelloMetricSplash;
		
		//	auxiliares
		private var gameBoardWidth:uint, gameBoardHeight:uint;
		private var startTime:uint;	//	tick de qdo esta fase comecou 
		
		//	Super Xunxo contra o baixo astral
		private static var xunxed		:	Boolean = false;
		
		private var debugVar:uint;	//	debugre
		
		//	Segredo do morcego!!
		protected var secretAllowed:Boolean = false;
		
		
		
		override public function create() : void
		{
			//	Atualizando "cookie" com o ultimo level destravado
			var i:uint;
			for (i = 0; i < globais.N_LEVELS; i++)
			{
				if (globais.isLevelUnlocked[i] == null)
					break;
				if (globais.isLevelUnlocked[i] == false)
					break;
			}
			globais.lastLevelUnlocked.data.savedValue = i - 1;
			//	Escrevendo em disco:
			var flushStatus:String = null;
            try {
                flushStatus = globais.lastLevelUnlocked.flush(10000);
            } catch (error:Error) {
                //output.appendText("Error...Could not write SharedObject to disk\n");
            }
            /*	O exemplo no site da Adobe implementa onFlushStatus
			if (flushStatus != null) {
                switch (flushStatus) {
                    case SharedObjectFlushStatus.PENDING:
                        output.appendText("Requesting permission to save object...\n");
                        lastLevelUnlocked.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                        break;
                    case SharedObjectFlushStatus.FLUSHED:
                        output.appendText("Value flushed to disk.\n");
                        break;
                }
            }*/
			
			//	Cor do fundo
			bgColor 	= 0xff000000;
			
			//	Board (tabuleiro do fundo. Tambem controla a logica)
			m_board 	= new Board();
			
			//	SplashMessages (descricao de level, derrota, vitoria)
			gameBoardHeight = m_board.gameBoard.height;
			gameBoardWidth = m_board.gameBoard.width;
			messageDescription 	= new MessageSplash(MessageSplash.typeDescription, 	gameBoardWidth, gameBoardHeight, 
				OKandStartLevel, null, null, null, null);
			messageFailWithUndo	= new MessageSplash(MessageSplash.typeFailWithUndo,	gameBoardWidth, gameBoardHeight,
				null, null, null, retry, undo);
			messageComplete 	= new MessageSplash(MessageSplash.typeComplete, 	gameBoardWidth, gameBoardHeight,
				null, replay, goToDescription, null, null);
			messageWonTheGame 	= new MessageSplash(MessageSplash.typeWonTheGame, 	gameBoardWidth, gameBoardHeight,
				null, replay, null, null, null, sendScoresAndReset);
			
			messageDescription.hide();
			messageFailWithUndo.hide();
			messageComplete.hide();
			messageWonTheGame.hide();
			
			//	Botao de mute
			btnMuteUnmute = new TWMuteBtn(8./450. * m_board.gameBoard.width, 409./450. * m_board.gameBoard.height);
			btnMuteUnmute.on = true;	//	para se comportar como um checkBox
			btnMuteUnmute.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgMuteOFF), new TWFlxSprite(0, 0, Graphics.imgMuteON));
			
			//	Botao de undo
			btnUndo = new TWFlxButton(int(414./450.*m_board.gameBoard.width), int(410./450.*m_board.gameBoard.width), Board.undo,
				"Click to undo last move");
			btnUndo.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgUndo1), new TWFlxSprite(0, 0, Graphics.imgUndo2),
				new TWFlxSprite(0, 0, Graphics.imgUndo3));
				
			//	Botoes de back, retry, next e send
			btnBack = new TWFlxButton(int(11./450.*m_board.gameBoard.width), int(414./450.*m_board.gameBoard.width), previous,
				"Go to previous level");
			btnBack.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgBack1), new TWFlxSprite(0, 0, Graphics.imgBack2), 
				new TWFlxSprite(0, 0, Graphics.imgBack3));
			
			btnRetry = new TWFlxButton(int(11./450.*m_board.gameBoard.width), int(414./450.*m_board.gameBoard.width), retry,
				"Retry (reset) this level");
			btnRetry.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgRetry1), new TWFlxSprite(0, 0, Graphics.imgRetry2), 
				new TWFlxSprite(0, 0, Graphics.imgRetry3));
				
			btnNext = new TWFlxButton(int(11./450.*m_board.gameBoard.width), int(414./450.*m_board.gameBoard.width), nextIfUnlocked,
				"Go to next level");
			btnNext.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgNext1), new TWFlxSprite(0, 0, Graphics.imgNext2), 
				new TWFlxSprite(0, 0, Graphics.imgNext3));
			
			//	(Botao de Send e' tratado mais adiante, pois precisamos ler o m_levelID...)
			
			//	Reposicionando esses tres botoes centralizadamente 
			var btnXSpacing:int = int(m_board.gameBoard.width / 100.);	//	Espacamento entre os botoes. Belo chute
			btnBack.x = (m_board.gameBoard.width - btnBack.width - btnRetry.width - btnNext.width - 2 * btnXSpacing) / 2;
			btnRetry.x = btnBack.x + btnBack.width + btnXSpacing;
			btnNext.x = btnRetry.x + btnRetry.width + btnXSpacing;
			//	Em y, assumimos que os 3 botoes tem a mesma altura
			// NOTE - cuidado, pois m_board.PiecesAssets.dimXsprites e' hard-coded!!
			btnBack.y = m_board.gameBoard.height/2 + 2 * PiecesAssets.dimYsprites + 
				((m_board.gameBoard.height - 4 * PiecesAssets.dimYsprites) / 2 - btnBack.height) / 2;
				//3 * m_board.gameBoard.height / 4 + PiecesAssets.dimYsprites - btnBack.height / 2;
			btnRetry.y = btnBack.y;
			btnNext.y = btnBack.y;
			btnBack.setActive(true);
			btnRetry.setActive(true);
			btnNext.setActive(true);
			
			//	Textos na parte superior
			//	Esquerda...
			textLevelNumber = 	new FlxText(8./450. * gameBoardWidth, 4./450. * gameBoardHeight, 250);
			textLevelNumber.setFormat	("Kartika", 20, 0x51717E, "left");
			textLevelName = 	new FlxText(8./450. * gameBoardWidth, 20./450. * gameBoardHeight, 250);
			textLevelName.setFormat		("Kartika", 20, 0x51717E, "left");
			//	... direita...
			textHighScore = 	new FlxText(340./450. * gameBoardWidth, 4./450. * gameBoardHeight, 100);
			textHighScore.setFormat		("Kartika", 20, 0x51717E, "right");
			textMoves = 		new FlxText(340./450. * gameBoardWidth, 20./450. * gameBoardHeight, 100);
			textMoves.setFormat			("Kartika", 20, 0x51717E, "right");
			//	... e no centro
			tipMessageY = 6. / 450. * gameBoardHeight;
			textTipMessage = new FlxText(82./450. * gameBoardWidth, tipMessageY, gameBoardWidth);
			textTipMessage.setFormat("Kartika", 20, 0xff4937, "left");
			hideTipMessage();
			
			FlxG.mouse.show();
			
			/*
			//	Elementos de level design (sprites) que nao sao tiles
			//clearAllObjects();	ver comentario na definicao
			createObjects();
			
			globais.groupGuiGufos	= new FlxGroup();
			globais.groupGuiTowers	= new FlxGroup();
			globais.groupGuiTowersSeeks	= new FlxGroup();
			globais.groupGuiTowersModifiers	= new FlxGroup();
			globais.groupGuiTowersInfos	= new FlxGroup();
			globais.groupOnBay		= new FlxGroup();
			globais.groupUpperMenu	= new FlxGroup();*/
			
			//	Caracteristicas da fase
			m_levelID			= parseInt(xmlThisLevel.child("order"));
			m_rescueQuota		= parseInt(xmlThisLevel.child("rescueQuota"));
			m_movesLeft			= parseInt(xmlThisLevel.child("movesLeft"));
			m_topRankQuota		= parseInt(xmlThisLevel.child("topRankQuota"));
			m_secondRankQuota	= parseInt(xmlThisLevel.child("secondRankQuota"));
			
			//	Textos da fase
			for (i = 0; i < xmlLevelsTexts.child("level").length(); i++)
			{
				if (parseInt(xmlLevelsTexts.child("level")[i].@id) == m_levelID)
				{
					m_levelName 		= xmlLevelsTexts.child("level")[i].child("level_name_en");
					m_levelDescription 	= xmlLevelsTexts.child("level")[i].child("level_description_en");
				}
			}
			
			//	Temporizadores
			m_timeLeft 	= 0.0;
			//FlxG.log("globais.tryReset_TotalTimeLeftCount("+m_levelID+")");
			globais.tryReset_TotalTimeLeftCount(m_levelID);	//	reseta apenas se ainda nao foi inicializado
			
			//	Contadores para metricas
			m_movesCount = 0;
			m_undosCount = 0;
			globais.tryReset_RetriesToWinCount(m_levelID);	//	reseta apenas se ainda nao foi inicializado
			globais.tryReset_TotalRetriesCount(m_levelID);	//	reseta apenas se ainda nao foi inicializado
			globais.tryReset_TotalMovesCount(m_levelID);	//	reseta apenas se ainda nao foi inicializado
			
			//	Texto do messageDescription
			messageDescription.setDescriptionTexts(m_levelName, m_levelDescription);
			
			//textLevelName.text = String(m_levelOrder) + ": " + m_levelDescription;
			
			//	Movendo as pecas para suas posicoes iniciais
			movePiecesToInitialPosition(new globais.mapLayer0);
			
			//	Criamos botao de Send se estamos no ultimo level
			if (m_levelID + 1 == globais.N_LEVELS)
			{
				btnSend = new TWFlxButton(0, 0, sendScoresAndReset, "Submit your score to the leaderboards!");
				btnSend.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgSend1), new TWFlxSprite(0, 0, Graphics.imgSend2), 
					new TWFlxSprite(0, 0, Graphics.imgSend3));
				btnSend.setActive(false);
				btnSend.visible = false;
				btnSend.x = btnNext.x;
				btnSend.y = btnNext.y;
			}
			
			//	Adicionando os elementos graficos a este grupo, na ordem correta
			add(m_board);
			for (i = 0; i < Board.m_cellsPieces.length; i++)
			{
				if (Board.m_cellsPieces[i] != null)	//	lembre que uma peca sera' sempre nula
					add(Board.m_cellsPieces[i]);
			}
			add(textLevelName);
			add(textLevelNumber);
			add(textMoves);
			//add(textCastawaysToSave);
			add(textHighScore);
			add(textTipMessage);
			add(btnUndo);
			add(btnMuteUnmute);
			add(btnBack);
			add(btnRetry);
			add(btnNext);
			//	Os splashs devem ficar em cima de todo mundo (menos do hint). TODO - Na hora de sumirem, simplesmente serao jogados para fora da tela?
			add(messageComplete);
			add(messageWonTheGame);
			add(messageDescription);
			add(messageFailWithUndo);
			//	Hint por cima de todo mundo
			add(hint);
			
			
			//	- Desabilitando as pecas e os elementos do Board
			//	- Mostrando a janela de descricao (da qual ele so sai apertando OK)
			//	- Sinalizando que estamos "out-game"
			FlxG.play(Sounds.SndGenericButtonClick);
			this.deactivateBoardAndPieces();
			messageDescription.show();
			m_inGame = false;
			
			//
			//	update() nos botoes e pecas, para aparecerem na posicao correta
			//	
			btnUndo.update();
			btnBack.update();
			btnRetry.update();
			btnNext.update();
			btnMuteUnmute.update();
			(Board.m_cellsPieces).forEach(function (aCaller:*, index:int, arr:Array):void { if (aCaller != null) aCaller.update(); } );
		}
		
		/**
		 * Mostra mensagem de dica (tipo "Boats move only forth nad back!")
		 * @param	txt
		 */
		public function showTipMessage(txt:String):void
		{
			textTipMessage.text = txt;
			Tweener.addTween(textTipMessage, { y:tipMessageY, time:2, rounded:true, transition:"easeOutBack" } );
		}
		
		/**
		 * Esconde mensagem de dica
		 * @param	txt
		 */
		public function hideTipMessage():void
		{
			//	(-2 so para garantir que vai estar acima da tela)
			Tweener.addTween(textTipMessage, { y: - textTipMessage.height - 2, time:2, rounded:true, transition:"easeOutQuint" } );
			//setTimeout(function():void { textTipMessage.text = ""; }, 2000);
		}
		
		/**
		 * 	Player perdeu este level
		 *  Mostra a MessageSplash de derrota e desabilita todas as pecas ate' o jogador clicar em 
		 * Try Again (ou Undo Move, se houver), quando reinicia este level
		 * 	Sinaliza "out-game"
		 */
		public function failedLevel():void
		{
			messageFailWithUndo.show();
			this.deactivateBoardAndPieces();
			m_inGame = false;
		}
		
		/**
		 * 	Player venceu o level
		 * 	- Destrava proximo level
		 * 	- Reporta e controla algumas metricas
		 *  - Mostra a MessageSplash de vitoria e desabilita todas as pecas ate' o jogador clicar em Replay ou em Next
		 * 	- Sinaliza "out-game"
		 */
		public function levelCompleted():void
		{
			//	Destrava o level seguinte (se este nao foi o ultimo level)
			var thisWasTheLastLevel:Boolean = (m_levelID + 1 == globais.N_LEVELS);
			if (!thisWasTheLastLevel) 
			{
				if (globais.isLevelUnlocked[m_levelID + 1] == null)
					globais.isLevelUnlocked[m_levelID + 1] = new Boolean;
				globais.isLevelUnlocked[m_levelID + 1] = true;
			}
			
			//	SWFStats: tempo medio para passar desta fase
			//	- NAO conta as outras vezes que foi jogada esta fase
			//	- NAO conta o tempo de pause (utilize getTimer() - startTime se quiser contar com o tempo de pause)
			Log.LevelAverageMetric("Time To Complete", globais.SWFStats_thisLevelTag(), m_timeLeft);
			
			//	Idem anterior, mas CONTA as outras vezes que foi jogada esta fase
			Log.LevelAverageMetric("Total Time To Complete", globais.SWFStats_thisLevelTag(), globais.totaltimeLeft[m_levelID]);
			globais.totaltimeLeft[m_levelID] = 0;
			
			//	SWFStats: quantidade media de movimentos - NAO conta as outras vezes que foi jogada esta fase
			Log.LevelAverageMetric("Moves To Complete", globais.SWFStats_thisLevelTag(), m_movesCount);
			
			//	SWFStats: quantidade media de movimentos - conta de TODAS as vezes que jogou esta fase, ate' vencer
			Log.LevelAverageMetric("Total Moves To Complete", globais.SWFStats_thisLevelTag(), globais.totalMovesCount[m_levelID]);
			globais.totalMovesCount[m_levelID] = 0;
			
			//	SWFStats: quantidade media de retries para vencer nesta fase
			globais.totalRetries[m_levelID]++;
			Log.LevelAverageMetric("Retries To Complete", globais.SWFStats_thisLevelTag(), globais.totalRetries[m_levelID]);
			globais.retriesToWin[m_levelID] = 0;
			
			//	Tela de Level Complete. Se era o ultimo level, mostra tela de jogo finalizado
			if (!thisWasTheLastLevel)
				messageComplete.show();
			else
				messageWonTheGame.show();
			
			m_inGame = false;
			
			this.deactivateBoardAndPieces();
		}
		
		/**
		 * Jogador perdeu e escolheu voltar a ultima jogada para tentar se recobrar do erro
		 */
		private function undo():void
		{
			messageFailWithUndo.hide();
			this.activateBoardAndPieces();
			Board.undo();
			m_inGame = true;
		}
		
		/**
		 *  Jogador perdeu e escolheu jogar este level novamente.
		 * 	- Oculta a MessageSplash presente
		 * 	- Ativa as pecas e os elementos do board
		 * 	- Reporta metrica de retries
		 * 	- Reinicia o level
		 */
		private function retry():void
		{
			//	SWFStats: quantidade media de retries nesta fase
			globais.totalRetries[m_levelID]++;
			Log.LevelAverageMetric("Retries", globais.SWFStats_thisLevelTag(), globais.totalRetries[m_levelID]);
			
			messageFailWithUndo.hide();
			this.activateBoardAndPieces();
			reset();
		}
		
		/**
		 * 	Jogador venceu mas resolveu jogar o level novamente
		 *  Como em retry(), oculta a MessageSplash presente, ativa todas as pecas e reinicia o level
		 */
		private function replay():void
		{
			if (messageComplete.visible)
				messageComplete.hide();
			else if (messageWonTheGame.visible)
				messageWonTheGame.hide();
			
			this.activateBoardAndPieces();
			reset();			
		}
		
		/**
		 * 	Sai da messageComplete, depois carrega o proximo level (no create, as pecas e os elementos do board sao desativados
		 * e o messageDescription e' exibido)
		 */
		private function goToDescription():void
		{
			messageComplete.hide();
			tryNext();
		}
		
		/**
		 * 	Usuario clicou no OK no splash de descricao
		 * 	- Sai do splash
		 * 	- Ativa as pecas e os elementos do board
		 * 	- Marca o tick inicial
		 * 	- Sinaliza "in-game"
		 */
		private function OKandStartLevel():void
		{
			messageDescription.hide();
			this.activateBoardAndPieces();
			startTime = getTimer();
			m_inGame = true;
		}
		
		/**
		 * 	Clicou no Send no MessageSplash de quando vence o jogo. Manda scores para o servidor e reinicia o jogo
		 */
		private function sendScoresAndReset():void
		{
			//	TODO 	Send scores
			globais.inGameMusic.survive = false;	//	NOTE - Nao adiantou stop()... tive que apelar pro survive
			xunxed = false;	//	para a musica comecar a tocar novamente agora que o jogo vai reiniciar
			FlxG.state = new SplashState;
		}
		
		/**
		 * Reinicia este level
		 */
		private function reset():void
		{
			FlxG.state = new stageProduct(this.m_levelID);
			FlxG.play(Sounds.SndResetLevel);
			FlxG.flash.start();
		}
		
		/**
		 * 	Se este state nao foi o sorteado para mostrar a HelloMetric, simplesmente chama next()
		 * 	Caso contrario, mostra a HelloMetric e so chama next() depois do OK na metrica (verificacao feita no update())
		 */
		private function tryNext():void
		{
			if (globais.isHelloMetricForThisState(this) && !globais.helloMetricLogged)
			{
				helloMetricSplash = new HelloMetricSplash();
				add(helloMetricSplash);
				globais.helloMetricLogged = true;
			}
			else
				next();
		}
		
		/**
		 * Passa para o proximo level - ou player vence o jogo se este era o ultimo
		 */
		private function next():void
		{
			if ((this.m_levelID + 1) < stageXML.xmlsLevels.length)
			{
				FlxG.state = new stageProduct(this.m_levelID + 1);
				FlxG.play(Sounds.SndGenericButtonClick);
				//FlxG.flash.start();
			}
			//TODO - else FIM DO JOGO
		}
		
		/**
		 * Passa para o level anterior
		 */
		private function previous():void
		{
			if (this.m_levelID > 0)
			{
				FlxG.state = new stageProduct(m_levelID - 1);
				FlxG.play(Sounds.SndGenericButtonClick);
			}
		}
		
		/**
		 * Passa para o level posterior se ele esta' destravado
		 */
		private function nextIfUnlocked():void
		{
			//FlxG.log("nextIfUnlocked()");
			if ( this.m_levelID + 1 < stageXML.xmlsLevels.length 
				&& globais.isLevelUnlocked[this.m_levelID + 1])
			{
				FlxG.state = new stageProduct(this.m_levelID + 1);
				FlxG.play(Sounds.SndGenericButtonClick);
				//FlxG.flash.start();
			}
		}
		
		/**
		 * Desativa todas os elementos do jogo (botao de undo...) e as pecas, para que ninguem receba cliques
		 */
		public function deactivateBoardAndPieces():void
		{
			btnUndo.setActive(false);
			btnBack.setActive(false);
			btnRetry.setActive(false);
			btnNext.setActive(false);
			(Board.m_cellsPieces).forEach(function (aCaller:*, index:int, arr:Array):void { if(aCaller!=null) aCaller.setActive(false); } );
		}
		
		/**
		 * Ativa todas os elementos do jogo (botoes, pecas...) de modo que agora podem receber cliques novamente
		 * Botao de Next sera' desativado se o proximo level nao esta'  destravado ou se este e' o ultimo level
		 */
		public function activateBoardAndPieces():void
		{
			btnUndo.setActive(true);
			
			//	Se e' a 1a fase, nao habilita botao de previous
			if (this.m_levelID > 0)
				btnBack.setActive(true);
			else
				btnBack.setActive(false);
			
			btnRetry.setActive(true);
						
			//	Se esta e' a ultima fase, desabilita o botao de Next
			if (m_levelID + 1 == globais.N_LEVELS)
				btnNext.setActive(false);
			//	Senao, habilitado somente se o proximo level esta' destravado
			else
			{
				if (globais.isLevelUnlocked[m_levelID + 1]!=null)
				{
					if (globais.isLevelUnlocked[m_levelID + 1] == true)
						btnNext.setActive(true);
					else
						btnNext.setActive(false);
				}
				else
					btnNext.setActive(false);
			}
			
			(Board.m_cellsPieces).forEach(function (aCaller:*, index:int, arr:Array):void { if(aCaller!=null) aCaller.setActive(true); } );
		}
		
		///	Auxiliar. Converte um array do tipo ["1", "50", "3", ...] para [1, 50, 3, ...]
		private function StringsArray_to_UintsArray(arr:Array):void
		{
			for (var i:uint = 0; i < arr.length; i++)
				arr[i] = uint(arr[i]);
		}
		
		///	Parte das artimanhas para fazer o SoundLoop funcionar
		/*private function endGap():void {
			gap = true;
		}*/
		
		public function get rescueQuota():uint
		{
			return this.m_rescueQuota;
		}
		
		public function get levelID():uint
		{
			return this.m_levelID;
		}
		
		public function get movesLeft():uint
		{
			return this.m_movesLeft;
		}
		
		///	Retorna FlxPoint com a posicao do interior do board (sera' a origem para as pecas)
		public function getBoardInteriorOrigin():FlxPoint
		{
			return m_board.interiorOrigin;
		}
		
		///
		///	Posiciona as pecas descritas no mapa layer, preenchendo assim, Board.m_cellsPieces
		///	Tambem ja preenche o m_cellsPieces_buffer
		///
		protected function movePiecesToInitialPosition(layer:String):void
		{
			//FlxG.log(">movePiecesToInitialPosition");
			var ind:uint;
			var rows:Array = layer.split("\n");
			for (var i:uint = 0; i < globais.N_COLUMNS; i++)	//	nao usamos rows.length porque podem haver quebras de linha sobrando ao fim do arquivo
			{
				var column:Array = rows[i].split(",");
				for (var j:uint = 0; j < column.length; j++)
				{
					ind = i * column.length + j;
					//FlxG.log("ind = " + ind + ", column[" + j + "] = " + column[j]);
					StringsArray_to_UintsArray(column);
					switch(column[j])
					{
						case Piece.TILE_MINA:
							Board.m_cellsPieces.push( new Piece(ind, column[j], Board.tryMovePieceAndExplode) );
							//FlxG.log("mina");
						break;
						case Piece.TILE_ANTISHARK:
							Board.m_cellsPieces.push( new Piece(ind, column[j], Board.tryMovePieceAndRotateSharks) );
							//FlxG.log("antishark");
						break;
						case Piece.TILE_BOTE_H:	//	(nao e' erro. E' que queremos a mesma acao para estes dois cases)
						case Piece.TILE_BOTE_V:
							Board.m_cellsPieces.push( new Piece(ind, column[j], Board.tryMoveBoat) );
							//FlxG.log("bote");
						break;
						case Piece.TILE_ILHA:	//	(nao e' erro. E' que queremos a mesma acao para estes dois cases)
						case Piece.TILE_VULCAO:
							Board.m_cellsPieces.push( new Piece(ind, column[j], Board.tryMoveIslandOrVolcano) );
							//FlxG.log("ilha ou vulcao");
						break;
						case Piece.TILE_CRIANCA:
							Board.m_cellsPieces.push( new Piece(ind, column[j], Board.tryMoveChild) );
							//FlxG.log("crianca5");
						break;
						case Piece.NO_TILE:
							//FlxG.log("2, 3, 4...");
							Board.m_cellsPieces.push( null );
							//FlxG.log("..e' a danca do baiaco");
						break;
						default:
							//FlxG.log("No dia em que sai' de casa..." + ind + " " + column[j]);
							Board.m_cellsPieces.push( new Piece(ind, column[j], Board.tryMovePiece) );
							//FlxG.log("...minha mae me disse...");
					}
					
					if(Board.m_cellsPieces[ind] != null)
						Board.m_cellsTypes_buffer[ind] = Board.m_cellsPieces[ind].type;
					else
						Board.m_cellsTypes_buffer[ind] = null;
				}
			}
			//FlxG.log("movePiecesToInitialPosition>.");
		}
		
		public function stage(aLevelXMLData:Class)
		{
			xmlThisLevel = new XML(new aLevelXMLData);
		}
		
		/////////////////UPDATE///////////////////////
		override public function update() : void
		{
			//
			//	Se estamos sob a metrica de "HELLO! etc..."
			if (helloMetricSplash)
			{
				//	Estamos tendo que forcar o update(), nao sei porque
				helloMetricSplash.update();
				
				//	Sujeito ja deu o rating (apertou OK)
				if (helloMetricSplash.dead)
				{
					//	Como tivemos que forcar o update() de helloMetricSplash, forcamos o destroy() apenas por garantia...
					helloMetricSplash.destroy();
					helloMetricSplash = null;
					
					//	Vai para onde estava indo (proximo level)
					if ((this.m_levelID + 1) < stageXML.xmlsLevels.length)
					{
						FlxG.state = new stageProduct(this.m_levelID + 1);
						FlxG.play(Sounds.SndGenericButtonClick);
						//FlxG.flash.start();
					}
				}
				//	Se estamos sob o splash, nao atualizamos o playstate
				return;
			}
			
			super.update();
			
			//	NOTE - XUNXO / WORKAROUND
			//	Assim conseguimos fazer com que o som in-game toque
			if (!xunxed)
			{
				xunxed = true;
				reset();
			}
			
			/*//	DEBUG{
			if (FlxG.keys.justPressed("RIGHT"))
				if ((m_levelID + 1) < stageXML.xmlsLevels.length)
					FlxG.state = new stageProduct(m_levelID + 1);
					
			if (FlxG.keys.justPressed("LEFT"))
				if(m_levelID > 0)
					FlxG.state = new stageProduct(m_levelID - 1);
			//	}DEBUG*/
			
			//	Textos
			textLevelNumber.text = "LEVEL " + (m_levelID + 1);
			textLevelName.text = m_levelName;
			textHighScore.text = "High Score = ";
			textMoves.text = "Moves: " + m_movesCount;
			if (m_movesLeft > 0)	//	0 significa que o numero de movimentos e' ilimitado
				textMoves.text += "/" + m_movesLeft;
			
			
			//textCastawaysToSave.text = "Castaways to save: " + m_rescueQuota;
			
			//
			//	Hint \index{Hint}
			//	A responsabilidade de mostrar a hint nao e' dos botoes, mas do seu 'canvas-pai' (por exemplo, se dois botoes se
			//interseccionam, nao sao eles que deverao decidir qual das duas hints e' mostrada).
			//	Aqui simplesmente queremos a hint dos botoes de mute e de undo (e nao nos preocupamos com intereseccao)
			//	undo...
			if (btnUndo.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
			{
				hint.visible = true;
				hint.text = btnUndo.getHint();
				hint.x = FlxG.mouse.x - 100;	//	NOTE - HARD-CODED!
				hint.y = FlxG.mouse.y - 12;	//	NOTE - HARD-CODED!
			}
			//	... e mute
			else if (btnMuteUnmute.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
			{
				hint.visible = true;
				hint.text = btnMuteUnmute.getHint();
				hint.x = FlxG.mouse.x - 8;	//	NOTE - HARD-CODED!
				hint.y = FlxG.mouse.y - 12;	//	NOTE - HARD-CODED!
			}
			else
				hint.visible = false;
			
			//
			//	Se estamos sob um splash ou algo assim, nao atualiza timers
			//
			if (m_inGame)
			{
				updateTime();
				if (globais.totaltimeLeft != null)
					if (globais.totaltimeLeft[m_levelID] != null)
						globais.totaltimeLeft[m_levelID] += FlxG.elapsed;
			}
			
			/*	SEGREDO DO MORCEGO - Sequencia secreta SHIFT + T + W para pular de fase */
			if (FlxG.keys.SHIFT && FlxG.keys.ONE && FlxG.keys.FIVE && FlxG.keys.C && secretAllowed) {	//	:o
				secretAllowed = false;
				levelCompleted();
				return;
			}
			//	Se uma das teclas da sequencia secreta nao estiver apertada, entao da proxima que as tres
			//estiverem apertadas, pula de fase
			secretAllowed = (!FlxG.keys.SHIFT && FlxG.keys.ONE && FlxG.keys.FIVE && FlxG.keys.C);
			
			//	FIXME - APAGAR! DEBUGRE! ---------
			/*hint.visible = true;
			if (FlxG.keys.justReleased("T"))
				debugVar = 0;
			if (FlxG.keys.justReleased("I"))
				debugVar = 1;
			if (FlxG.keys.justReleased("N"))
				debugVar = 2;
			if (FlxG.keys.justReleased("M"))
				debugVar = 3;
			
			if (m_inGame)
			{
				switch(debugVar)
				{
					case 0: hint.text = String(m_timeLeft); 						break;
					case 1: hint.text = String(globais.totaltimeLeft[m_levelID]);	break;
					case 2: hint.text = String(m_movesCount);						break;
					case 3: hint.text = String(globais.totalMovesCount[m_levelID]);	break;
				}
			}
			
			if (FlxG.keys.justReleased("T"))
				levelCompleted();*/
			//----------------------------------
			
			//	Logando metrica de mute se foi muted pela 1a vez
			globais.tryLogMutedMetric(FlxG.mute);
			
		}
		
		///
		///	Atualiza o tempo transcorrido neste level
		///
		public function updateTime() : void
		{
			m_timeLeft += FlxG.elapsed;
			//TWTimer.timerUpdate();
		}
		
		public function get timeLeft():Number
		{
			return this.m_timeLeft;
		}
		
	}

}