package core 
{
	/**
	 * ...
	 * @author Timewave Games
	 */
	
	import core.sound.SoundLoop;
	import flash.utils.getTimer;
	import org.flixel.FlxG;
	import org.flixel.FlxState;
	import org.flixel.FlxText;
	import org.flixel.TWFlxButton;
	import stages.stage;	//	ah, nao me segurei! Nao ha nada de mal em guardar um ref global para o stage atual!
	import SWFStats.Log;
	
	//	Para salvar dados do jogador localmente (usamos para, quando ele jogar novamente, estarem liberados 
	//os levels que ele ja passou)
	//import flash.events.NetStatusEvent;
    import flash.net.SharedObject;
    //import flash.net.SharedObjectFlushStatus;
	
	public class globais
	{
		//	Stage atual
		public static var actualStage	:	stage							;
		
		//	Ponteiro para layer 0 do mapa stage corrente
		public static var mapLayer0 		:	Class						;
		
		//	Musica in-game, loopante
		public static var inGameMusic		:	SoundLoop					;
		
		//	Botao de mute/unmute
		//	NOTE - Sua posicao e graficos serao inicializados em MenuState.as
		//public static var btnMuteUnmute		:	TWFlxButton;
		
		//	Numeros de linhas e de colunas
		public static var N_LINES			:	uint	= 4					;
		public static var N_COLUMNS			:	uint	= 4					;
		
		//	Numerto de leves (TODO - melhor seria ler de um xml)
		public static const N_LEVELS		:	uint	= 41				;
		
		//
		//	Variaveis referentes a metricas
		//
		
		/**	Quantidade de movimentos feita durante o jogo inteiro em cada level
		/*	NAO zera a cada vez que o jogador joga o level	*/
		static public var totalMovesCount	:	Array	= new Array			;
		
		/**	Quantidade de retries feitas antes de vencer em cada level
		/*	NOTE - Deve ser zerada toda vez que um nivel e' vencido	*/
		static public var retriesToWin		: 	Array	= new Array			;
		
		/**	Quantidade de retries feita durante o jogo inteiro em cada level
		/*	NAO zera a cada vez que o jogador joga o level	*/
		static public var totalRetries		: 	Array	= new Array			;
		
		/**	Tempo dispendido durante o jogo inteiro em cada level
		/*	NAO zera a cada vez que o jogador joga o level
		/*	NAO CONTA o tempo de pause */
		static public var totaltimeLeft		:	Array	= new Array			;
		
		/** tick de inicio do jogo - momento em que aparece o menu */
		static public var startTime			:	uint						;
		
		/**	Lista informando se cada level esta' destravado (true) ou nao (false) */
		static public var isLevelUnlocked	:	Array	= new Array			;
		
		/**	Indica se o jogo ja foi muted alguma vez */
		static public var muteMetricLogged	:	Boolean	= false				;
		
		//	Lista de causas de derrota
		static public var EXCEEDED_MAX_MOVES:uint 		= 0;
		static public var BOAT_DESTROYED:uint 			= 1;
		static public var ADULT_EXPLODED:uint 			= 2;
		static public var CHILD_EXPLODED:uint 			= 3;
		static public var MANY_CASTAWAYS_EXPLODED:uint	= 4;
		static public var ADULT_WENT_TO_SHARK:uint		= 5;
		static public var SHARK_WENT_TO_ADULT:uint		= 6;
		static public var CHILD_WENT_TO_SHARK:uint		= 7;
		static public var SHARK_WENT_TO_CHILD:uint		= 8;
		static public var ANTISHARK__ADULT:uint			= 9;
		static public var ANTISHARK__CHILD:uint			= 10;
		static public var ANTISHARK__MANY_CASTAWAYS:uint = 11;
		
		/** Indice do FlxState ao fim do qual aparecera' a metrica de "Hello! etc..."
		 * 0: primeira fase, 1: 2a fase, ... */
		static public var stateWith_HelloMetric:uint;
		
		/** sinaliza se a helloMetric ja foi logada */
		static public var helloMetricLogged:Boolean = false;
		
		/** sinaliza se as informacoes default ja foram colocadas na telinha de log da Flixel */
		public static var defaultPanelLogged:Boolean = false;
		
		/**	Como um cookie. Para recuperar os levels destravados pelo jogador */
		public static var lastLevelUnlocked:SharedObject;
		
		public function globais() 
		{
			//btnMuteUnmute = new TWFlxButton(0, 0, globais.alternateMuteStatus);
		}
		
		///
		///	Recupera de "cookie" info do ultimo level destravado
		///
		static public function retrieveLastLevelUnlockedCookie():void
		{
			
			lastLevelUnlocked = SharedObject.getLocal("castaway15LLU");
			
			for (var i:uint = 0; i <= lastLevelUnlocked.data.savedValue; i++)
			{
				if (globais.isLevelUnlocked[i] == null)
					globais.isLevelUnlocked[i] = new Boolean;
				globais.isLevelUnlocked[i] = true
			}
		}
		
		///
		///	Verifica se state foi sorteado para apresentar a HelloMetric ao seu fim
		///
		static public function isHelloMetricForThisState(state:FlxState):Boolean
		{
			if (state is stage)
			{
				//FlxG.log("stateWith_HelloMetric == (state as stage).levelID :" + 
				//	stateWith_HelloMetric + " = " + ((state as stage).levelID) + " : " + (stateWith_HelloMetric == (state as stage).levelID));

				return (stateWith_HelloMetric == (state as stage).levelID);
			}
			
			return false;
		}
		
		///	Se usou mute pela 1a vez, loga metricas informando que mutou e quanto tempo havia corrido desde o MenuState ate' agora
		static public function tryLogMutedMetric(a_isMuted:Boolean):void
		{
			if(a_isMuted && !globais.muteMetricLogged)
			{
				Log.CustomMetric("Muted"); 
				Log.LevelAverageMetric("Time To Mute (s)", SWFStats_thisLevelTag, (globais.startTime - getTimer())/1000.); 
				globais.muteMetricLogged = true;
			}
		}
		
		static public function tryReset_RetriesToWinCount(level:uint):void
		{
			if (retriesToWin[level] == null)
			{
				retriesToWin[level] = new uint;
				retriesToWin[level] = 0;
			}
		}
		
		static public function tryReset_TotalRetriesCount(level:uint):void
		{
			if (totalRetries[level] == null)
			{
				totalRetries[level] = new uint;
				totalRetries[level] = 0;
			}
		}
		
		static public function tryReset_TotalTimeLeftCount(level:uint):void
		{
			if (totaltimeLeft[level] == null)
			{
				totaltimeLeft[level] = new uint;
				totaltimeLeft[level] = 0;
			}
			else
			{
				//FlxG.log("---");
				//FlxG.log("totaltimeLeft[" + level + "] = " + totaltimeLeft[level]);
			}
		}
		
		static public function tryReset_TotalMovesCount(level:uint):void
		{
			if (totalMovesCount[level] == null)
			{
				totalMovesCount[level] = new uint;
				totalMovesCount[level] = 0;
			}
		}
		///
		///	Tag que identifica o level atual, para utilizar no Log do SWFStats
		///	Resulta "00_Level", "01_Level", ..., "10_Level", etc...
		///
		static public function SWFStats_thisLevelTag():String
		{
			if(globais.actualStage.levelID <= 9)
				return "0" + String(globais.actualStage.levelID) + "_Level";
			else
				return String(globais.actualStage.levelID) + "_Level";
		}
		
		/**
		 * Atualiza estado do botao de mute/unmute de acordo com o mute/unmute da flixel
		 * @return	1 se o mouse esta' sobre esse botao. Senao, 0.
		 */
		static public function updateBtnMuteStatus(btnMuteUnmute:TWFlxButton):uint
		{
			//
			//	som
			
			//	primeiramente, sincronizando o estado do botao com o estado do mute da flixel
			//	(o usuario pode mutar e desmutar teclando "0" ao inves de clicar no botao)
			if (FlxG.mute)
			{
				btnMuteUnmute.pressed = true;
			}
			else
			{
				btnMuteUnmute.pressed = false;
			}
			
			//	tratando mouseClick (muda estado de mute) e mouseOver (mostra hint)
			if (btnMuteUnmute.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
			{
				//hint.visible = true;
				//hint.x = FlxG.mouse.x - 10;	//	FIXME! hard-coded
				//hint.y = FlxG.mouse.y - 10;	//	FIXME! hard-coded
				if (FlxG.mute)
					btnMuteUnmute.hint = "Click to unmute";
				else
					btnMuteUnmute.hint = "Click to mute";
				return 1;
			}
			else
			{
				//hint.visible = false;
				return 0;
			}
		}
		
		static public function logDefaultPanel():void
		{
			if (!defaultPanelLogged)
			{
				FlxG.log("15Castaway by TimeWave Games");
				FlxG.log("Check www.timewavegames.com for tips, tricks... and other cool games");
				FlxG.log("");
				FlxG.log("Credits:");
				FlxG.log("Production: Arthur Allievi");
				FlxG.log("Game Design: Caio Lopez");
				FlxG.log("Sounds/Music: Caio Lopez");
				FlxG.log("Graphics: Caio Lopez");
				FlxG.log("Additional art: Kojiio");
				FlxG.log("Programming: Brizoman");
				FlxG.log("Levels descriptions: Ju Malinverni");
				defaultPanelLogged = true;
			}
		}
		
	}

}