package GUI
{
	import core.globais;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxSprite;
	import org.flixel.TWFlxButton;
	import SWFStats.Log;
	/**
	 * ...
	 * @author Joel Nascimento
	 */
	public class HelloMetricSplash extends FlxGroup
	{
		[Embed(source = '../../../Art/Release/helloMetricSplash.png')] public static var imgBackground:Class;
		private var background:FlxSprite = new FlxSprite(0, 0, imgBackground);
		
		private var stars:Array = new Array;
		[Embed(source = '../../../Art/Release/Estrela_ON.png')] public static var imgEstrelaON:Class;
		[Embed(source = '../../../Art/Release/Estrela_OFF.png')] public static var imgEstrelaOFF:Class;
		[Embed(source = '../../../Art/Release/Estrela_OVER.png')] public static var imgEstrelaOVER:Class;
		
		private var btnOK:TWFlxButton = new TWFlxButton(0, 0, sendRatingAndExit, "Click to send your rating!");
		[Embed(source = '../../../Art/Release/OK_ON.png')] public static var imgBtnON:Class;
		[Embed(source = '../../../Art/Release/OK_OFF.png')] public static var imgBtnOFF:Class;
		[Embed(source = '../../../Art/Release/OK_OVER.png')] public static var imgBtnOVER:Class;
		
		private var lastClickedStar:int = -1;
		
		public function HelloMetricSplash() 
		{
			super();
			
			//	Estrelas
			var star1:TWFlxButton = new TWFlxButton(0, 0, star1Clicked);
			var star2:TWFlxButton = new TWFlxButton(0, 0, star2Clicked);
			var star3:TWFlxButton = new TWFlxButton(0, 0, star3Clicked);
			var star4:TWFlxButton = new TWFlxButton(0, 0, star4Clicked);
			var star5:TWFlxButton = new TWFlxButton(0, 0, star5Clicked);
			
			stars.push(star1);
			stars.push(star2);
			stars.push(star3);
			stars.push(star4);
			stars.push(star5);
			
			for (var i:uint = 0; i < stars.length; i++)
			{
				(stars[i] as TWFlxButton).loadGraphic(new FlxSprite(0, 0, imgEstrelaOVER), new FlxSprite(0, 0, imgEstrelaON), 
					new FlxSprite(0, 0, imgEstrelaOFF));
				//	comportamento de checkbox para a tchurma
				(stars[i] as TWFlxButton).on = true;
				//	comecam nao-apertadas
				(stars[i] as TWFlxButton).pressed = false;
				//	mudam de sprite ao mouseOver (normalmente botoes do tipo checkBox nao fazem isso)
				(stars[i] as TWFlxButton).highlightOnMouseOver = true;
			}
			
			//	Bottao de OK
			btnOK.loadGraphic(new FlxSprite(0, 0, imgBtnOVER), new FlxSprite(0, 0, imgBtnON), new FlxSprite(0, 0, imgBtnOFF));
			btnOK.on = true;
			btnOK.pressed = false;
			btnOK.highlightOnMouseOver = true;
			
			//	Adicionando todo mundo...
			add(background);
			for (i = 0; i < stars.length; i++)
				add(stars[i]);
			add(btnOK);
			
			//	... e posicionando
			positionElements();
			
			//	Comecamos com 3 estrelas
			star3Clicked();
		}
		
		private function positionElements():void
		{
			var horizSpaceBetweenStars:uint = 0;
			for (var i:uint = 0; i < stars.length; i++)
			{
				(stars[i] as TWFlxButton).y = 241. / 512. * 512.;
				(stars[i] as TWFlxButton).x = (background.width - stars.length * (stars[i] as TWFlxButton).width) / 2
					+ i * (stars[i] as TWFlxButton).width - 1;
			}
			btnOK.x = (background.width - btnOK.width) / 2;
			btnOK.y = 325. / 512. * 512.;
		}
		
		private function sendRatingAndExit():void
		{
			Log.LevelRangedMetric("Ratings", globais.SWFStats_thisLevelTag(), lastClickedStar);
			this.killMembers();
			this.kill();
		}
		
		override public function update():void
		{
			super.update();				
			
			//	Detecta se ha mouseOver em uma estrela
			var index_lastStarHighlighted:int = -1;
			for (var i:int = 0; i < stars.length; i++)
				if ((stars[i] as TWFlxButton).overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
					index_lastStarHighlighted = i;
			
			//	Mouse sobre uma estrela. Ilumina ela e as anteriores - e apaga as posteriores
			if (index_lastStarHighlighted >= 0)
			{
				for (i = index_lastStarHighlighted; i >= 0; i--)
					(stars[i] as TWFlxButton).pressed = true;
				
				for (i = index_lastStarHighlighted + 1; i < stars.length; i++)
					(stars[i] as TWFlxButton).pressed = false;
			}
			//	Mouse nao esta' sobre nenhuma estrela. Volta graficos ao padrao e seta clicked == true para a ultima estrela
			//clicada e as anteriores - e false para as posteriores
			else
			{
				if (lastClickedStar >= 0)
					starClicked(lastClickedStar);
				else
					for (i = 0; i < stars.length; i++)
						(stars[i] as TWFlxButton).pressed = false;
			}
		}
		
		private function starClicked(starIndex:uint):void
		{			
			//	Todas as estrelas posteriores sao apagadas...
			for (var j:uint = starIndex + 1; j < stars.length; j++)
				(stars[j] as TWFlxButton).pressed = false;
			
			//...	e as anteriores, acesas
			for (j = 0; j <= starIndex; j++)
				(stars[j] as TWFlxButton).pressed = true;
				
			lastClickedStar = starIndex;
		}
		
		private function star1Clicked():void
		{
			starClicked(0);
		}
		
		private function star2Clicked():void
		{
			starClicked(1);
		}
		
		private function star3Clicked():void
		{
			starClicked(2);
		}
		
		private function star4Clicked():void
		{
			starClicked(3);
		}
		
		private function star5Clicked():void
		{
			starClicked(4);
		}
	}

}