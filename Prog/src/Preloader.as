package { 
import org.flixel.FlxPreloader;
import SWFStats.*;


	public class Preloader extends FlxPreloader { 
		
		public function Preloader() {
			
			var urls_allowed:Array = [
				"www.timewavegames.com",
				"www.flashgamelicense.com",
				"brizoman.timewavegames.com"
			];
			
			if (sitelock(urls_allowed))
			{
				this.root.alpha = 0;		
			}
			else
			{
				
				//	Log.View inicializa o uso dos SWFStats. E' uma comunicacao com o servidor do Playtomic para
				//guardarmos metricas, geolocalizarmos o jogador, etc...
				//	Ja incrementa o numero de Views nas estatisticas deste jogo
				Log.View(1409, "63b35ee8b6654625", root.loaderInfo.loaderURL);
				
				className = "Castaway15";	//	This should always be the name of your main project/document class
				
				super();
			}
			
		}
		
		public function sitelock(urls_allowed:Array) : Boolean {
			var lock:Boolean=true;
			var urlString:String=stage.loaderInfo.url;
			var urlParts:Array=urlString.split("://");
			var domain:Array=urlParts[1].split("/");

			for (var i:uint = 0; i < urls_allowed.length; i++) 
			{
			 if (urls_allowed[i]==domain[0]) {
			  lock = false;
			 }
			}

			return lock;
			//return false;
		}
		
	}
}