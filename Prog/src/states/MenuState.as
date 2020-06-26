package states 
{
	//import core.globais;
	import caurina.transitions.Tweener;
	import core.assets.Graphics;
	import core.assets.Sounds;
	import core.globais;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import org.flixel.data.FlxFlash;
	import flash.events.MouseEvent;
	import org.flixel.FlxButton;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSound;
	import org.flixel.TWFlxButton;
	import org.flixel.FlxG;
	import org.flixel.FlxState;
	import stages.stageProduct;
	import org.flixel.FlxText;
	import org.flixel.FlxSave;
	import utils.TWMuteBtn;
	//import timewave.core.globals.ScoreTable;
	//import timewave.core.globals.TopLevel;
	import org.flixel.TWFlxSprite;
	import core.sound.SoundLoop;
	import SWFStats.*;
	
	/**
	 * 	Menu
	 * 	
	 * @author Serginho Chulapa
	 */
	 
	public class MenuState extends FlxState
	{
		/*	NOTE - Muito mais inteligente seria fazer o menu como um swf separado, feito pelo *designer* no Flash CS*/
		
		//	Fundo
		[Embed(source = '../../../Art/Release/15mainmenu_beta.png')] public static var imgBackground:Class;
		private var background:TWFlxSprite = new TWFlxSprite(0, 0, imgBackground);
		
		//	"Start 15Castaway"
		[Embed(source = '../../../Art/Release/15start.png')] public static var imgStart:Class;
		private const btnStart:FlxButton = new FlxButton(33, 259, startGame);
		
		private var flashButton:FlxFlash = new FlxFlash();
		
		//	Mute e unmute
		//	NOTE - NAO CONSIGO USAR O globais.btnMuteUnmute... seu callback perde a referencia quando saimos do MenuState... =/
		private var btnMuteUnmute:TWFlxButton;
		
		//	Hint (no momento, usada apenas no botao de mute/unmute)
		protected var hint:FlxText = new FlxText(0, 0, 200, "");
		
		//private var cursorStartLoaded:Boolean = false;
		protected var colorInc:int = 256 * 256 * 2 + 256 * 2 + 1 * 2;
		protected var increasingColor:Boolean = false;
		
		//private const saveState:FlxSave = new FlxSave();
		
		public function MenuState() 
		{
			
		}
		
		override public function create():void 
		{
			/*FlxG.mouse.show();
			
			TopLevel.actualState = null;
			
			ScoreTable.resetStats();
			TopLevel.score = 0;
			
			titleText.alignment = "center";
			titleText.size = 35;
			
			btnStart.loadText(startText);
			btnSurvival.loadText(survivaltText);
			btnSurvivalPlus.loadText(plusText);
			btnHowToPlay.loadText(howText);
			
			btnSurvival.active = false;
			btnSurvivalPlus.active = false;
			
			if (saveState.bind("TZdata")) {
				if (saveState.data.survOpen) {
					btnSurvival.active = true;
				}
				
				if (saveState.data.survPlusOpen) {
					btnSurvivalPlus.active = true;
				}
			}
			
			add(titleText);
			add(btnStart);
			add(btnSurvival);
			add(btnSurvivalPlus);
			add(btnHowToPlay);*/
			
			FlxG.playMusic(Sounds.SndIntrotheme15CLOOP);
			
			FlxG.mouse.show()
			
			btnStart.loadGraphic(new TWFlxSprite(0, 0, imgStart));
			
			//	Mute/unmute
			btnMuteUnmute = new TWMuteBtn(8./450. * background.width, 409./450. * background.height);
			btnMuteUnmute.on = true;	//	para se comportar como um checkBox
			btnMuteUnmute.loadGraphic(new TWFlxSprite(0, 0, Graphics.imgMuteOFF), new TWFlxSprite(0, 0, Graphics.imgMuteON));
			FlxG.mute = false;
			btnMuteUnmute.update();
			
			//	Comecamos sem hint
			hint.visible = false;
			
			//	Textos. NOTE - Muito mais inteligente sera' fazer o menu coomo um swf separado, feito pelo *designer* no Flash CS
			//	"START 15CASTAWAY"
			/*txtStart.setFormat("Franklin Gothic Heavy", 128, 0xff0033ff, "center"); //font-family or name, font-size, color, alignment
			txtStart.scale = new FlxPoint(1.395, 1.395);
			//	"How To Play"
			txtHowToPlay.setFormat("Kartika", 32, 0xff0033ff, "center");
			txtCastaways.setFormat("Kartika", 32, 0xff0033ff, "center");
			txtBoats.setFormat("Kartika", 32, 0xff0033ff, "center");
			txtIslands.setFormat("Kartika", 32, 0xff0033ff, "center");
			txtSharks.setFormat("Kartika", 32, 0xff0033ff, "center");*/
						
			add(background);
			add(btnStart);
			add(btnMuteUnmute);
			//add(txtStart);
			add(hint);	//	hint acima de todos
			
			globais.startTime = getTimer();
			
			super.create();
		}
		
		///
		///	Inicia o jogo
		///
		private function startGame():void {
			
			//	SWFStats: Incrementa o contador de Plays nas estatisticas deste jogo
			Log.Play();
			
			FlxG.music.stop();
			//FlxG.playMusic(Sounds.SndInGame);
			
			//	Musica loopante
			globais.inGameMusic = new SoundLoop;
			globais.inGameMusic.survive = true;	//	continuara' tocando mesmo quando houve troca de state
			FlxG.sounds.push(globais.inGameMusic);
			
			if (globais.isLevelUnlocked[0] == null)
					globais.isLevelUnlocked[0] = new Boolean;
				globais.isLevelUnlocked[0] = true;
			
			//	Indo para a 1a fase
			FlxG.state = new stageProduct(0);
			
			//	pirlimpimpim
			FlxG.flash.start();
		}
		
		///
		///
		///
		override public function update():void
		{
			//
			//	mouseOver ou nao no "Start 15Castaway"
			if (btnStart.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
				shineStartButton();
			else
			{
				btnStart.members[0].color = 0xffffffff;
				increasingColor = false;
			}
			
			//
			//	Hint...
			if (btnMuteUnmute.overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
			{
				hint.visible = true;
				hint.text = btnMuteUnmute.getHint();
				hint.x = FlxG.mouse.x - 10;	//	FIXME - HARD-CODED!
				hint.y = FlxG.mouse.y - 10;	//	FIXME - HARD-CODED!
			}
			else
				hint.visible = false;
			
			//	Na primeira vez que for muted, metrica e' logada informando
			globais.tryLogMutedMetric(FlxG.mute);
				
			//	e' ifo ai', pafero
			super.update();
			
			//FlxG.log(btnStart.members[0].color);
		}
		
		///
		///	"Brilha" o botao de start, transformando a cor na escala de cinza
		///
		private function shineStartButton():void
		{
			if (increasingColor == true)	//	aumenta a cor
			{
				if ((btnStart.members[0].color + colorInc) < 0xffffff)
					btnStart.members[0].color += colorInc;
				else
					increasingColor = false;
			}
			else	//	diminui a cor
			{
				if ((btnStart.members[0].color - colorInc) > 0x909090)
					btnStart.members[0].color -= colorInc;
				else
					increasingColor = true;
			}
		}
	
	}

}