package pieces 
{
	/**
	 * ...
	 * @author Curie, M.
	 */
	public class PiecesAssets
	{
		[Embed(source = '../../../Art/Release/individual_tiles/neutro.png')] 			public static const pieceNeutro:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/adulto.png')] 			public static const pieceAdulto:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/ilha.png')] 				public static const pieceIlha:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/bote_vertical.png')] 	public static const pieceBote_V:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/bote_horizontal.png')] 	public static const pieceBote_H:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/tubarao_up.png')] 		public static const pieceTubaraoUp:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/tubarao_down.png')] 		public static const pieceTubaraoDown:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/tubarao_left.png')] 		public static const pieceTubaraoLeft:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/tubarao_right.png')] 	public static const pieceTubaraoRight:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/crianca.png')] 			public static const pieceCrianca:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/mina.png')] 				public static const pieceMina:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/antishark.png')] 		public static const pieceAntishark:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/vulcao.png')] 			public static const pieceVulcao:Class;
		
		[Embed(source = '../../../Art/Release/individual_tiles/deadAdult.png')] 		public static const pieceDeadAdult:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/deadChild.png')] 		public static const pieceDeadChild:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/deadBoat.png')]			public static const pieceDeadBoat:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/deadShark.png')] 		public static const pieceDeadShark:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/deadAntiShark.png')] 	public static const pieceDeadAntiShark:Class;
		[Embed(source = '../../../Art/Release/individual_tiles/deadMina.png')] 			public static const pieceDeadMina:Class;
		
		public static const piecesSprites:Array = [
			pieceNeutro,
			pieceAdulto,
			pieceIlha,
			pieceBote_V,
			pieceBote_H,
			pieceTubaraoUp,
			pieceTubaraoDown,
			pieceTubaraoLeft,
			pieceTubaraoRight,
			pieceCrianca,
			pieceMina,
			pieceAntishark,
			pieceVulcao,
			null,	//	o tile 13 indica posicao vazia no board
			pieceDeadAdult,
			pieceDeadChild,
			pieceDeadBoat,
			pieceDeadShark,
			pieceDeadAntiShark,
			pieceDeadMina
		];
		
		public static const dimXsprites:uint = 90;	// FIXME - HARD-CODED. Poderia ser uma variavel de compilacao
		public static const dimYsprites:uint = 90;	// FIXME - HARD-CODED. Poderia ser uma variavel de compilacao
		
		public function PiecesAssets() 
		{
			
		}
		
	}

}