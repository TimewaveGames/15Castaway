package  
{
	/**
	 * 15Castaway main class
	 * @author Elomar Filgueira de Melo
	 */
	
	
	
	import core.globais;
	import org.flixel.FlxGame;
	import states.SplashState;
	import SWFStats.*;
	import org.flixel.FlxG;
	
	//////////////////////////////////////////////////////////
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.utils.getDefinitionByName;
	import flash.display.DisplayObject;
	//////////////////////////////////////////////////////////
	import flash.display.LoaderInfo;
	//////////////////////////////////////////////////////////
	
	//	cores na flixel sao 0xAARRGGBB (AA = alpha)
	[SWF(width = "450", height = "450", backgroundColor = "#000000")]
	
	//	ATENCAO! NOTE! Se for usar Mochi Live Update, nao podemos ter preloader (a Mochi coloca o dela). Portanto,
	//se for o caso, comentar a linha abaixo
	//[Frame(factoryClass="Preloader")]
	
	public class Castaway15 extends FlxGame
	{
		///////////////////////////////////////
		protected var _init:Boolean;
		protected var _min:uint;
		/**
		 * This should always be the name of your main project/document class (e.g. GravityHook).
		 */
		public var className:String;
		///////////////////////////////////////
		
		public function Castaway15(PixelSize:uint=1) : void
		{
			//	SWFStats: codigo e pais do jogador
			//	NOTE: isso ja manda a informacao para o Playtomic?
			//	FIXME - NAO FUNCIONOU!
			//GeoIP.Lookup(SetPlayerCountry);
			
			//	Recuperando informacao do ultimo level destravado pelo jogador, guardada localmente
			globais.retrieveLastLevelUnlockedCookie();
			
			if (CONFIG::USE_MOCHI)
			{
				//	Para o Mochi Live Update reconhecer
				var _mochiads_game_id:String = "0b9e45255dd91319";
				
				//	Com Mochi n estamos usando preloader, entao, precisamos logar no Playtomic aqui
				Log.View(1409, "63b35ee8b6654625", getMainLoaderInfo().loaderURL);
			}
			
			//////////////////////////////////////////////////
			//	NOTE - Estava em Preloader.as . Retiramos o preloader deste projeto porque estamos usando
			//Mochi Live Update, que ja tem seu preloader e por isso nao fazia nosso jogo funcionar corretamente.
			/*
			var urls_allowed:Array = [
				"www.timewavegames.com",
				"www.flashgamelicense.com",
				"brizoman.timewavegames.com"
			];
			
			var lock:Boolean = true;
			FlxG.log("churros");
			var urlString:String = getMainLoaderInfo().loaderURL;//stage.loaderInfo.url;
			var urlParts:Array=urlString.split("://");
			var domain:Array=urlParts[1].split("/");

			for (var i:uint = 0; i < urls_allowed.length; i++) 
			{
				if (urls_allowed[i]==domain[0]) {
					lock = false;
				}
			}
			
			lock = false;	//	ATENCAO: desativando sitelock nesta linha. Descomente-a para reativar o sitelock
			
			
			if (lock)
			{
				this.root.alpha = 0;				
			}
			else
			{
				//	Log.View inicializa o uso dos SWFStats. E' uma comunicacao com o servidor do Playtomic para
				//guardarmos metricas, geolocalizarmos o jogador, etc...
				//	Ja incrementa o numero de Views nas estatisticas deste jogo
				//Log.View(1409, "63b35ee8b6654625", root.loaderInfo.loaderURL);
				Log.View(1409, "63b35ee8b6654625", getMainLoaderInfo().loaderURL);
				
				className = "Castaway15";	//	This should always be the name of your main project/document class
			}
			//////////////////////////////////////////////////
			
			
			//////////////////////////////////////////////////
			//	NOTE - Estava em FlxPreloader.as . Retiramos o preloader deste projeto porque estamos usando
			//Mochi Live Update, que ja tem seu preloader e por isso nao fazia nosso jogo funcionar corretamente.
			//stop();	hmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm...
			_init = false;
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			//////////////////////////////////////////////////
			*/
			
			super(450, 450, SplashState , PixelSize);
		}

		
		public function SetPlayerCountry(country:Object, response:Object):void
		{
			if(response.Success)
			{
				// we have the country data
				//FlxG.log("TimeWave S2 " + country.Name + "..." + country.Code);	//	tchan				
			}
			else
			{
				// request failed because of response.ErrorCode
			}
		}
		
		//////////////////////////////////////////////////
		//	NOTE - Estava em FlxPreloader.as . Retiramos o preloader deste projeto porque estamos usando
		//Mochi Live Update, que ja tem seu preloader e por isso nao fazia nosso jogo funcionar corretamente.
		private function onEnterFrame(event:Event):void
        {
			if (/*root.loaderInfo*/getMainLoaderInfo().bytesLoaded >= /*root.loaderInfo*/getMainLoaderInfo().bytesTotal)
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				/*
				//nextFrame();	hmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm...
                var mainClass:Class = Class(getDefinitionByName(className));
	            if(mainClass)
	            {
	                var app:Object = new mainClass();
	                addChild(app as DisplayObject);
	            }*/
			}
			else
				return;
			
			/*if(!_init)
			{
				if((stage.stageWidth <= 0) || (stage.stageHeight <= 0))
					return;
				//create();	Isto e´ so´ codigo para controlar objetos do preloader, como a barra de carregamento
				_init = true;
			}
        	var i:int;
            graphics.clear();
			var time:uint = getTimer();
            if((framesLoaded >= totalFrames) && (time > _min))
            {
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
                nextFrame();
                var mainClass:Class = Class(getDefinitionByName(className));
	            if(mainClass)
	            {
	                var app:Object = new mainClass();
	                addChild(app as DisplayObject);
	            }
                removeChild(_buffer);
            }
            /*else	Isto e´ so´ codigo para controlar a barra de carregamento
			{
				var percent:Number = root.loaderInfo.bytesLoaded/root.loaderInfo.bytesTotal;
				if((_min > 0) && (percent > time/_min))
					percent = time/_min;
            	update(percent);
			}*/
			}
		//////////////////////////////////////////////////
		
		//////////////////////////////////////////////////
		//	Adaptacao para usar Mochi Live Update (https://www.mochimedia.com/support/dev_doc)
		//	"Since Live Updates loads your code with a flash.display.Loader, the FlashVars and URL 
		//should be accessed somewhat differently than normal. Some third party APIs may need small 
		//changes to use this LoaderInfo instead of root.loaderInfo. This code will get the true 
		//LoaderInfo in a game using Live Updates (but also works if not using Live Updates):"
		
		public function getMainLoaderInfo():LoaderInfo {
			var loaderInfo:LoaderInfo = root.loaderInfo;
			if (loaderInfo.loader != null) {
				loaderInfo = loaderInfo.loader.loaderInfo;
			}
			return loaderInfo;
		}

		//////////////////////////////////////////////////
	}

}