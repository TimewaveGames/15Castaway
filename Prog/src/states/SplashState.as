package states
{
	import core.assets.Graphics;
	import core.globais;
	import org.flixel.FlxG;
	import org.flixel.FlxSprite;
	import org.flixel.FlxState;
	import SWFStats.Log;
	import flash.utils.setTimeout;
	import flash.utils.clearTimeout;
	
	import flash.net.URLRequest;
	import flash.net.navigateToURL;


	
	/**
	 * ...
	 * @author Qulanunskatski
	 */
	public class SplashState extends FlxState
	{
		
		private const splashTimewave:FlxSprite = new FlxSprite(0, 0, Graphics.ImgSplashTimeWave);
		private const splashSponsor:FlxSprite = new FlxSprite(0, 0, Graphics.ImgSplashSponsor);
		private var timer:uint;
		private var cursorHalfWidth:uint;
		private var cursorHalfHeight:uint;
			
		private var splashClicked:Boolean;
		
		public function SplashState() 
		{
			if (!globais.defaultPanelLogged)
			{
				globais.logDefaultPanel();
				globais.defaultPanelLogged = true;
			}
			FlxG.mouse.load(Graphics.imgCursor);
			FlxG.mouse.show();
			cursorHalfWidth = FlxG.mouse.cursor.width / 2;
			cursorHalfHeight = FlxG.mouse.cursor.height / 2;
			
			splashClicked = false;
		}
		
		override public function create():void 
		{	
			//	Definindo em qual state vai aparecer a metrica de "HELLO! ..."
			globais.stateWith_HelloMetric = globais.N_LEVELS * Math.random();
			//FlxG.log("TopLevel.stateWith_HelloMetric = " + globais.stateWith_HelloMetric);
			
			FlxG.flash.start(0xff000000, 1,showTimewave);
			
			add(splashSponsor);
			add(splashTimewave);
			
			super.create();
		}
		
		override public function update():void 
		{
			//	Ao clique ou Enter: Se foi sobre a logo da TW, abre o site e guarda metrica correspondente
			if ( FlxG.keys.pressed("ENTER") || (FlxG.mouse.justPressed() && !splashClicked) )
			{
				if (splashTimewave.visible)
				{
					splashClicked = true;
					try {
						//	TODO FIXME - Enquanto no nosso site e no FGL, nao linkamos
						//	FIXME - Colocar o link para a secao do site correspondente a esse jogo
						//	FIXME - Atualizar a API do Playtomic (playtomic.com - accounts@timewavegames.com/passpadrão) para
						//poder usar o comando Link
						Log.CustomMetric("TimeWave splash clicked");
						navigateToURL(new URLRequest("http://www.timewavegames.com/#games"), '_blank'); // second argument is target
						//Link bla bla bla (ver tnk)
					} catch (e:Error) {
						trace("Error occurred!");
					}
				}
				//else	//	...senao, vai para o menu
				//	goMainMenu();
			}
			
			super.update();
		}
		
		private function showTimewave():void {
			timer = setTimeout(fadeToSponsor, 1000);
		}
		
		private function fadeToSponsor():void {
			//FlxG.fade.start(0xff000000, 1, flashToSponsor);	com splash de sponsor
			goIntroAndMenuState();	//	sem splash de sponsor
		}
		
		private function flashToSponsor():void {
			FlxG.fade.stop();
			FlxG.flash.start(0xff000000, 1, showSponsor);
			splashTimewave.visible = false;
		}
		
		private function showSponsor():void {
			timer = setTimeout(goIntroAndMenuState, 1000);
		}
		
		private function goIntroAndMenuState():void {
			clearTimeout(timer);
			FlxG.fade.stop();
			FlxG.flash.stop();
			FlxG.fade.start(0xff000000, 1, function():void { FlxG.state = new MenuState() } );
		}
		
	}

}