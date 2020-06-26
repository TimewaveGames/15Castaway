package pieces 
{
	import board.Board;
	import caurina.transitions.Tweener;
	import core.globais;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	//import org.flixel.FlxButton;
	import flash.events.MouseEvent;
	import org.flixel.TWFlxButton;
	
	/**
	 * ...
	 * @author Raulino Tatuira
	 */
	public class Piece extends TWFlxButton
	{
		/** posicao no tabuleiro:
		 * 0  1  2  3
		 * 4  5  6  7
		 * 8  9  10 11
		 * 12 13 14 15
		 */
		protected var m_indexOnBoard:uint;
		
		/** largura (=altura) */
		protected var m_size:uint = PiecesAssets.dimXsprites;	//	largura (=altura)
		
		/** Tipo: segue a ordem do array de assets PiecesAssets.piecesSprites */
		protected var m_type:uint;
		
		/** Destruido: se true, nao consegue aplicar efeitos (antishark destruido nao roda tubaroes,
		 * mina destruida nao explode mais, bote destruido nao salva, adulto ou crianca destruido nao
		 * pode ser salvo...)*/
		protected var m_destroyed:Boolean = false;
		
		/** Sinaliza se peca esta' salva ou nao - aplicavel apenas a pecas salvaveis, claro*/
		protected var m_safe:Boolean = false;
		
		static public const TILE_NEUTRO:uint = 0;
		static public const TILE_ADULTO:uint = 1;
		static public const TILE_ILHA:uint = 2;
		static public const TILE_BOTE_V:uint = 3;
		static public const TILE_BOTE_H:uint = 4;
		static public const TILE_TUBARAO_UP:uint = 5;
		static public const TILE_TUBARAO_DOWN:uint = 6;
		static public const TILE_TUBARAO_LEFT:uint = 7;
		static public const TILE_TUBARAO_RIGHT:uint = 8;
		static public const TILE_CRIANCA:uint = 9;
		static public const TILE_MINA:uint = 10
		static public const TILE_ANTISHARK:uint = 11;
		static public const TILE_VULCAO:uint = 12;
		//	NOTE - o valor 13 sera' usado para posicoes cazias no board
		static public const NO_TILE:uint = 13;
		static public const TILE_ADULTO_DEAD:uint = 14;
		static public const TILE_CRIANCA_DEAD:uint = 15;
		static public const TILE_BOTE_DEAD:uint = 16;
		static public const TILE_TUBARAO_DEAD:uint = 17;
		static public const TILE_ANTISHARK_DEAD:uint = 18;
		static public const TILE_MINA_DEAD:uint = 19;
		
		public function Piece(aIndexOnBoard:uint, aType:uint, aCallback:Function)
		{
			m_type 				= aType;
			m_indexOnBoard 		= aIndexOnBoard;
			
			var origin:FlxPoint = globais.actualStage.getBoardInteriorOrigin();
			
			super(
				origin.x + (aIndexOnBoard % globais.N_COLUMNS) * m_size,
				origin.y + int(aIndexOnBoard / globais.N_COLUMNS) * m_size,
				aCallback
			);
			
			loadGraphic(new FlxSprite(0, 0, PiecesAssets.piecesSprites[aType]));
			
			//this.members[0].scale = new FlxPoint(0.703125, 0.703125);	//	FIXME - TEMPORARIO!! APAGAR ISTO AQUI!!
			//FlxG.log("m_size = " + m_size);
			
		}
		
		///
		///	Posiciona a peca de acordo com seu indice no tabuleiro
		///
		public function positionPiece():void
		{
			var newX:uint = globais.actualStage.getBoardInteriorOrigin().x + (m_indexOnBoard % globais.N_COLUMNS) * m_size;
			var newY:uint = globais.actualStage.getBoardInteriorOrigin().y + int(m_indexOnBoard / globais.N_COLUMNS) * m_size;
			
			Tweener.addTween(this, { x:newX, y:newY, time:0.3, rounded:true, transition:"bounceOutIn" } );
			
			//	Negocio estranho da Flixel! Os sprites de um botao n seguem a posicao do botao automaticamente...!
			Tweener.addTween(this.members[0], { x:newX, y:newY, time:0.3, rounded:true, transition:"bounceOutIn" } );
			//this.members[0].x = this.x;
			//this.members[0].y = this.y;
		}
		
		public function get indexOnBoard():uint
		{
			return this.m_indexOnBoard;
		}
		
		public function set indexOnBoard(aIndexOnBoard:uint):void
		{
			this.m_indexOnBoard = aIndexOnBoard;
		}
		
		public function get destroyed():Boolean
		{
			return this.m_destroyed;
		}
		
		public function set destroyed(aDestroyed:Boolean):void
		{
			this.m_destroyed = aDestroyed;
		}
		
		public function get safe():Boolean
		{
			return this.m_safe;
		}
		
		public function set safe(aSafe:Boolean):void
		{
			this.m_safe = aSafe;
		}
		
		public function get type():uint
		{
			return this.m_type;
		}
		
		///
		///	Muda o tipo - e ja atualiza o sprite com o novo asset correspondente
		///
		public function changeType(aNewType:uint):void
		{
			this.m_type = aNewType;
			this.members[0].loadGraphic(PiecesAssets.piecesSprites[aNewType]);
		}
		
		///
		///	Retorna o tipo de peca morta correspondente ao tipo de peca viva aPieceType. Retorna -1 se
		///o tipo aPieceType nao tem correspondente morto
		///
		public static function obtainDeadPieceType(aPieceType:int):int
		{
			var deadPieceType:int = -1;
			switch(aPieceType)
			{
				case Piece.TILE_ADULTO:			deadPieceType = Piece.TILE_ADULTO_DEAD;		break;
				case Piece.TILE_BOTE_H:			deadPieceType = Piece.TILE_BOTE_DEAD;		break;
				case Piece.TILE_BOTE_V:			deadPieceType = Piece.TILE_BOTE_DEAD;		break;
				case Piece.TILE_CRIANCA:		deadPieceType = Piece.TILE_CRIANCA_DEAD;	break;
				case Piece.TILE_TUBARAO_DOWN:	deadPieceType = Piece.TILE_TUBARAO_DEAD;	break;
				case Piece.TILE_TUBARAO_LEFT:	deadPieceType = Piece.TILE_TUBARAO_DEAD;	break;
				case Piece.TILE_TUBARAO_RIGHT:	deadPieceType = Piece.TILE_TUBARAO_DEAD;	break;
				case Piece.TILE_TUBARAO_UP:		deadPieceType = Piece.TILE_TUBARAO_DEAD;	break;
				case Piece.TILE_ANTISHARK:		deadPieceType = Piece.TILE_ANTISHARK_DEAD;	break;
				case Piece.TILE_MINA:			deadPieceType = Piece.TILE_MINA_DEAD;		break;
			}
			return deadPieceType;
		}
		
		///
		///	* Muda o tipo para o correspondente morto
		///	* destroyed = true
		///	* muda callback para tryMovePiece
		///
		public function killPiece():void
		{
			this.changeType(Piece.obtainDeadPieceType(this.m_type));
			this.m_destroyed = true;
			this.callback = Board.tryMovePiece;
		}
		
		override public function update() : void 
		{
			super.update();
		}
		
		/**
		 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
		 * -> Override para informar qual peca foi clicada
		 */
		override protected function onMouseUp(event:MouseEvent):void
		{
			if(!exists || !visible || !active || !FlxG.mouse.justReleased() || (FlxG.pause && !pauseProof) || (_callback == null)) return;
			if (overlapsPoint(FlxG.mouse.x, FlxG.mouse.y))
			{
				Board.g_clickedPiece = this;
				_callback();
			}
		}
		
	}

}