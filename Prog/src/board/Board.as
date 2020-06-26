package board 
{
	import core.assets.Sounds;
	import core.globais;
	import flash.display.Stage;
	import org.flixel.FlxG;
	import org.flixel.FlxGroup;
	import org.flixel.FlxPoint;
	import org.flixel.TWFlxSprite;
	import pieces.Piece;
	import pieces.PiecesAssets;
	import stages.stageProduct;
	import stages.stageXML;
	import SWFStats.*;
	/**
	 * 	- Grupo dos elementos do tabuleiro. A borda externa (imgBoarderLeft, imgBoarderTop, imgBoarderRight, 
	 * imgBoarderBottom) e a parte interna (interior), onde as pecas ficarao
	 * 	- Contem a matriz com os estados de cada celula (ou seja, que tile esta' em cada posicao)
	 * - Cuida da logica do jogo (permissoes de movimentacoes, acoes das pecas, verificacao de vitoria ou derrota...)
	 * 
	 * @author Mario Taqueuspa
	 */
	public class Board extends FlxGroup
	{
		/**	tamanho das bordas */
		private var m_boarderSize:uint;
		
		/**	Sprite do tabuleiro propriamente dito */
		[Embed(source = '../../../Art/Release/15bgingame.png')] protected var imgInterior:Class;
		public var gameBoard:TWFlxSprite = new TWFlxSprite(0, 0, imgInterior);
		
		/**	Matriz com as referencias das pecas que estao em cada posicao do board no momento 
		*, *, *, *,
		*, *, *, *,
		*, *, *, *,
		*, *, *, *];	*/
		public static var m_cellsPieces:Array;
		
		/** Guarda o m_cellsPieces anterior (*apenas os tipos*), para usar num eventual undo() */
		public static var m_cellsTypes_buffer:Array;		
		
		/**	Peca recem clicada */
		public static var g_clickedPiece:Piece;
		
		/** Posicoes relativas */
		public static const UP:uint = 0;
		public static const DOWN:uint = 1;
		public static const LEFT:uint = 2;
		public static const RIGHT:uint = 3;
		public static const UP_RIGHT:uint = 4;
		public static const UP_LEFT:uint = 5;
		public static const DOWN_RIGHT:uint = 6;
		public static const DOWN_LEFT:uint = 7;
		
		public static const relative8Positions:Array = [
			UP, DOWN, LEFT, RIGHT, UP_RIGHT, UP_LEFT, DOWN_RIGHT, DOWN_LEFT];
		
		public static const relative4Positions:Array = [UP, DOWN, LEFT, RIGHT];
		
		/** quantidade de adultos mortos na ultima movimentacao */
		private static var thisMove_killedAdults:uint = 0;
		/** quantidade de criancas mortas na ultima movimentacao */
		private static var thisMove_killedChildren:uint = 0;
		/** quantidade de botes destruidos na ultima movimentacao */
		private static var thisMove_killedBoats:uint = 0;
		
		public function Board() 
		{
			super();
			m_cellsPieces = new Array;
			m_cellsTypes_buffer = new Array;
			
			m_boarderSize = uint(41./450.*gameBoard.width);
			
			add(gameBoard);
		}
		
		///	Posicao considerada a origem para posicionamento das pecas
		public function get interiorOrigin():FlxPoint
		{
			return new FlxPoint(44./450.*gameBoard.width, 44./450.*gameBoard.height);
		}
		
		///
		///	Desliza a peca para a posicao adjacente vazia
		///	* @return -1 se nao ha posicao adjacente vazia - e toca som de movimento invalido
		///	* @return indice da nova posicao no board se houve movimento com sucesso - e toca som correspondente
		///
		public static function tryMovePiece_aux():int
		{
			var newPos:int;
			//	Tentando a movimentacao nas 4 posicoes adjacentes:
			for (var i:uint = 0; i < relative4Positions.length; i++)
			{
				//	-1 sinaliza que a posicao almejada esta' fora do tabuleiro
				if( (newPos = relativePositionIndexOnBoard(g_clickedPiece.indexOnBoard,relative4Positions[i])) != -1)
				{
					//	Se a posicao almejada nao tem nenhuma peca, podemos mover para ali
					if (m_cellsPieces[newPos] == null)
					{
						move(newPos);
						//applyGameLogicAfterMovements();
						FlxG.play(Sounds.SndMoveTile, 1);
						
						//	Conseguiu mover. Entao limpa mensagem
						globais.actualStage.hideTipMessage();
						
						return newPos;	//	ja moveu. Nao ha mais nada para ser visto aqui, garoto
					}
				}
			}
			
			FlxG.play(Sounds.SndMoveTileImpossible, 1);
			
			return -1;			
		}

		///
		///	@return retorna indice da posicao relativa a pos. Se ela esta' fora do board, retorna -1
		///
		public static function relativePositionIndexOnBoard(pos:uint,relativePos:uint):int
		{
			var returnValue:int = -1;
			switch(relativePos)
			{
				case UP:
					if (pos >= globais.N_COLUMNS)
						returnValue = pos - globais.N_COLUMNS;
				break;
				case LEFT:
					if(pos % globais.N_COLUMNS != 0)
						returnValue = pos - 1;
				break;
				case DOWN:
					if(pos < ( (globais.N_COLUMNS - 1) * globais.N_LINES))
						returnValue = pos + globais.N_COLUMNS;
				break;
				case RIGHT:
					if((pos + 1) % globais.N_COLUMNS != 0)
						returnValue = pos + 1;
				break;
				
				case UP_LEFT:
					if (pos >= globais.N_COLUMNS)
						if (pos % globais.N_COLUMNS != 0)
							returnValue = pos - globais.N_COLUMNS - 1;
				break;
				
				case UP_RIGHT:
					if (pos >= globais.N_COLUMNS)
						if((pos + 1) % globais.N_COLUMNS != 0)
							returnValue = pos - globais.N_COLUMNS + 1;
				break;
							
				case DOWN_LEFT:
					if(pos < ( (globais.N_COLUMNS - 1) * globais.N_LINES))
						if (pos % globais.N_COLUMNS != 0)
							returnValue = pos + globais.N_COLUMNS - 1;
				break;
				
				case DOWN_RIGHT:
					if(pos < ( (globais.N_COLUMNS - 1) * globais.N_LINES))
						if((pos + 1) % globais.N_COLUMNS != 0)
							returnValue = pos + globais.N_COLUMNS + 1;
				break;
			}
			//FlxG.log("returnValue = " + returnValue);
			return returnValue;
		}
		
		///
		///	* Movimenta a peca que estava em g_clickedPiecePosition, a levando para aNewPos
		///	* Atualiza m_cellsPieces
		///	* Atualiza o buffer com o estado anterior do board, para usar em um eventual undo()
		///	* Incrementa os contadores de numero de movimentos desta fase (o simples e o acumulado)
		///
		public static function move(aNewPos:uint):void
		{
			//	guardando estado anterior
			for (var k:uint = 0; k < globais.N_COLUMNS * globais.N_LINES; k++)
			{
				if(m_cellsPieces[k] != null)
					m_cellsTypes_buffer[k] = m_cellsPieces[k].type;
				else
					m_cellsTypes_buffer[k] = null;
			}
				
			//	swap...
			m_cellsPieces[aNewPos] = g_clickedPiece;
			m_cellsPieces[g_clickedPiece.indexOnBoard] = null;
			g_clickedPiece.indexOnBoard = aNewPos;
			g_clickedPiece.positionPiece();
			
			globais.actualStage.m_movesCount++;
			globais.totalMovesCount[globais.actualStage.levelID]++;
		}
		
		///
		///	Funcao chamada no mouseUp de uma peca deslizavel
		///
		public static function tryMovePiece():int
		{
			thisMove_killedAdults = thisMove_killedChildren = thisMove_killedBoats = 0;
			
			var returnValue:int = tryMovePiece_aux();
			if (returnValue != -1)
				applyGameLogicAfterMovements();

			//	Se chegou ate' aqui e' porque nao conseguiu mover
			return returnValue;
		}		
		
		///
		///	Funcao chamada no mouseUp de uma mina naval. Move a mina, depois explode matando tiles adjacentes, 
		///exceto ilhas e vulvoes, que não sofrem efeito
		///	Minas atingidas explodem tambem
		///	@param justExplode: true se deve apenas explodir a mina, sem move-la (e' o caso de quando uma mina e'
		///explodida por outra). false e' o default. Deve tentar mover a mina e, se ela se moveu, explodi-la
		///	@return false se nao conseguiu mover a mina
		///
		public static function tryMovePieceAndExplode(justExplode:Boolean=false):Boolean
		{
			//	tentando mover a mina para a posicao vazia
			var newPos:int;
			if (!justExplode)
			{
				newPos = tryMovePiece_aux();
				//FlxG.log("newPos = tryMovePiece_aux() = " + newPos);
				thisMove_killedAdults = thisMove_killedChildren = thisMove_killedBoats = 0;
			}
			else
			{
				newPos = g_clickedPiece.indexOnBoard;
				//FlxG.log("newPos = g_clickedPiece.indexOnBoard = " + newPos);
			}
			
			var explodeAgainIndexes:Array = new Array;	//	se uma mina for explodida, ela vai explodir tambem
			var explodingPositionIndex:int;
			if (newPos != -1 || justExplode )	//	se a mina realmente se moveu (ou se justExplode == true), aplica a explosao nos 8 tiles adjacentes
			{
				//	Consegue mover. Entao limpa mensagem
				globais.actualStage.hideTipMessage();
				
				//	Se esta mina esta' morta, nao vai explodir ninguem. So' retorna true porque conseguiu mover
				if (Board.m_cellsPieces[newPos].destroyed)
				{
					return true;
				}
				
				//	2 sons possiveis para mina explodindo. Ta', ta'... vou usar numeros aleatorios depois, nao quero procurar agora
				if (newPos % 2 == 0)
					FlxG.play(Sounds.SndMineExplosion);
				else
					FlxG.play(Sounds.SndMineExplosionAlternative);
				
				var newType:int;
				for (var i:uint = 0; i < relative8Positions.length; i++)
					//	se posicao esta' dentro do board...
					if ( (explodingPositionIndex = relativePositionIndexOnBoard(newPos, relative8Positions[i])) != -1)
						//	se ha uma peca nessa posicao...
						if (Board.m_cellsPieces[explodingPositionIndex] != null)
						{
							//	Guardamos os indices de eventuais minas atingidas, para aplicar uma reacao em cadeia
							if (Board.m_cellsPieces[explodingPositionIndex].type == Piece.TILE_MINA)
								if(Board.m_cellsPieces[explodingPositionIndex].destroyed == false)
									explodeAgainIndexes.push(explodingPositionIndex);
							
							//	Matando as pecas atingidas pela explosao (exceto minas, que provocarao reacao em cadeia, nao 
							//podendo entao ser destruidas agora)
							if( Board.m_cellsPieces[explodingPositionIndex].type != Piece.TILE_MINA )
								if ( (newType = Piece.obtainDeadPieceType(Board.m_cellsPieces[explodingPositionIndex].type)) != -1 )
								{
									Board.m_cellsPieces[explodingPositionIndex].killPiece();
									if (Board.m_cellsPieces[explodingPositionIndex].type == Piece.TILE_ADULTO_DEAD)
										thisMove_killedAdults++;
									else if (Board.m_cellsPieces[explodingPositionIndex].type == Piece.TILE_CRIANCA_DEAD)
										thisMove_killedChildren++;
									else if (Board.m_cellsPieces[explodingPositionIndex].type == Piece.TILE_BOTE_DEAD)
										thisMove_killedBoats++;
									/*Board.m_cellsPieces[explodingPositionIndex].changeType(newType);
									Board.m_cellsPieces[i].destroyed = true;
									aPiece.callback = tryMovePiece;*/
								}
						}
				
				//	Explodiu. Destruida, nao pode explodir novamente
				Board.m_cellsPieces[newPos].destroyed = true;
				Board.m_cellsPieces[newPos].changeType(Piece.obtainDeadPieceType(Piece.TILE_MINA));
				
				//	Aplicamos recursividade aqui para explodir as minas que foram atingidas
				for (var j:uint = 0; j < explodeAgainIndexes.length; j++)
				{
					g_clickedPiece = Board.m_cellsPieces[explodeAgainIndexes[j]];
					//FlxG.log("explodeAgainIndexes[j] = " + explodeAgainIndexes[j]);
					//FlxG.log("g_clickedPiece.indexOnBoard = " + g_clickedPiece.indexOnBoard);
					//FlxG.log("g_clickedPiece.destroyed = " + g_clickedPiece.destroyed);
					if (g_clickedPiece.destroyed == false)
					{
						//FlxG.log("Timaix!");
						tryMovePieceAndExplode(true);
					}
				}
				//	Aplicando a logica do jogo pois castaways podem ter morrido
				//FlxG.log("applyGameLogicAfterMovements()!");
				applyGameLogicAfterMovements();
				return true;
			}
			else
			{
				return false;	//	se a mina nao se moveu, cai fora e sinaliza com false
			}
		}
		
		///
		///	Funcao chamada no mouseUp de um antishark. Move o antishark, depois rotaciona em 180 graus os
		///tubaroes que estiverem nas 8 posicoes adjacentes
		///	Se nao conseguiu mover o antishark, retorna false
		///
		public static function tryMovePieceAndRotateSharks():Boolean
		{
			var newPos:int = tryMovePiece_aux();	//	tentando mover o tile antishark para a posicao vazia
			var affectedPositionIndex:int;
			if (newPos != -1)	//	se realmente se moveu, aplica rotacao nos 8 tiles adjacentes
			{
				thisMove_killedAdults = thisMove_killedChildren = thisMove_killedBoats = 0;
				
				//	Consegue mover. Entao limpa mensagem
				globais.actualStage.hideTipMessage();
				
				//	Se este antishark esta' morto, nao vai rotacionar ninguem. So' retorna true porque conseguiu mover
				if (Board.m_cellsPieces[newPos].destroyed)
					return true;
				
				for (var i:uint = 0; i < relative8Positions.length; i++)
					//	posicao esta' dentro do board...
					if ( (affectedPositionIndex = relativePositionIndexOnBoard(newPos, relative8Positions[i])) != -1)
						//	ha uma peca nessa posicao...
						if (Board.m_cellsPieces[affectedPositionIndex] != null)
						{
							switch(Board.m_cellsPieces[affectedPositionIndex].type)
							{
								case Piece.TILE_TUBARAO_DOWN:
									Board.m_cellsPieces[affectedPositionIndex].changeType(Piece.TILE_TUBARAO_UP);
									FlxG.play(Sounds.SndAntiSharkRotateShark, 1);
								break;
								case Piece.TILE_TUBARAO_UP:
									Board.m_cellsPieces[affectedPositionIndex].changeType(Piece.TILE_TUBARAO_DOWN);
									FlxG.play(Sounds.SndAntiSharkRotateShark, 1);
								break;
								case Piece.TILE_TUBARAO_LEFT:
									Board.m_cellsPieces[affectedPositionIndex].changeType(Piece.TILE_TUBARAO_RIGHT);
									FlxG.play(Sounds.SndAntiSharkRotateShark, 1);
								break;
								case Piece.TILE_TUBARAO_RIGHT:
									Board.m_cellsPieces[affectedPositionIndex].changeType(Piece.TILE_TUBARAO_LEFT);
									FlxG.play(Sounds.SndAntiSharkRotateShark, 1);
								break;
							}
						}
							
				//	Aplicando a logica do jogo pois tubaroes rotacionados podem matar castaways agora
				applyGameLogicAfterMovements();
				return true;
			}
			
			//	Se chegou ate' aqui e' porque nenhum tubarao foi rotacionado
			thisMove_killedAdults = thisMove_killedChildren = thisMove_killedBoats = 0;
			return false;
		}
		
		///
		///	Funcao chamada no mouseUp de uma peca boat. Desliza a peca para a posicao adjacente vazia (botes so 
		///se movem ao longo da direcao que estao orientados)
		///	* @return -1 se nao ha posicao adjacente vazia ou se nao ha direcao valida para o bote - e toca som de movimento invalido
		///	* @return indice da nova posicao no board se houve movimento com sucesso - e toca som correspondente
		///
		public static function tryMoveBoat():int
		{
			var newPos:int;
			var direction:Array = new Array;
			
			if (g_clickedPiece.type == Piece.TILE_BOTE_H)
			{
				direction.push(LEFT);
				direction.push(RIGHT);
			}
			else
			{
				direction.push(UP);
				direction.push(DOWN);
			}
			
			for (var i:uint = 0; i < direction.length; i++)
			{
				//	-1 sinaliza que a posicao almejada esta' fora do tabuleiro
				if ( (newPos = relativePositionIndexOnBoard(g_clickedPiece.indexOnBoard, direction[i])) != -1)
				{
					//	Se a posicao almejada nao tem nenhuma peca, podemos mover para ali
					if (m_cellsPieces[newPos] == null)
					{
						move(newPos);
						FlxG.play(Sounds.SndMoveTile, 1);
						applyGameLogicAfterMovements();
						globais.actualStage.hideTipMessage();	//	conseguiu mover, entao limpa mensagem
						thisMove_killedAdults = thisMove_killedChildren = thisMove_killedBoats = 0;
						return newPos;
					}
				}
			}
			
			//	Se chegou ate aqui e' porque nao moveu. Se a posicao vazia e' uma lateral do barco, avisa
			//que o barco so' anda para a frente e para tras
			if (g_clickedPiece.type == Piece.TILE_BOTE_H)
			{
				direction[0] = UP;
				direction[1] = DOWN;
			}
			else
			{
				direction[0] = LEFT;
				direction[1] = RIGHT;
			}
			for (i = 0; i < direction.length; i++)
			{
				//	-1 sinaliza que a posicao almejada esta' fora do tabuleiro
				if ( (newPos = relativePositionIndexOnBoard(g_clickedPiece.indexOnBoard, direction[i])) != -1)
				{
					//	Se a posicao almejada nao tem nenhuma peca...
					if (m_cellsPieces[newPos] == null)
					{
						//...avisa que o barco so' anda para a frente e para tras
						globais.actualStage.showTipMessage("Boats can move just forth and back!");
						break;
					}
				}
			}
			
			FlxG.play(Sounds.SndMoveTileImpossible, 1);
			
			return -1;			
		}
		
		///
		///	Funcao chamada no mouseUp de uma peca de crianca. Se ha um adulto em uma das 8 posicoes adjacentes,
		///desliza a peca para a posicao adjacente vazia
		///	* @return -1 se nao ha posicao adjacente vazia ou se nao ha adulto perto - e toca som de movimento invalido
		///	* @return indice da nova posicao no board se houve movimento com sucesso - e toca som correspondente
		///
		public static function tryMoveChild():int
		{
			var newPos:int;
			var adultFound:Boolean = false;

			//	Se nao ha um adulto perto, nao pode mover
			for (var i:uint = 0; i < relative8Positions.length; i++)
			{
				//	-1 sinaliza que a posicao almejada esta' fora do tabuleiro
				if( (newPos = relativePositionIndexOnBoard(g_clickedPiece.indexOnBoard,relative8Positions[i])) != -1)
				{
					if (m_cellsPieces[newPos] != null)	//	Se ha uma peca...
					{
						//FlxG.log("m_cellsPieces[" + newPos + "].type = " + m_cellsPieces[newPos].type);
						if (m_cellsPieces[newPos].type == Piece.TILE_ADULTO)	//	... e e' um adulto, a crianca pode se mover
						{
							//FlxG.log("adultFound");
							adultFound = true;
							break;
						}
					}
				}
			}
			
			if (!adultFound)
			{
				//FlxG.log("adult not found");
				FlxG.play(Sounds.SndMoveTileImpossible, 1);
				globais.actualStage.showTipMessage("Children need an adjacent adult to move!");
				thisMove_killedAdults = thisMove_killedChildren = thisMove_killedBoats = 0;
				return -1;
			}
			
			//	Se chegou ate aqui e' porque moveu. Entao limpamos a mensagem
			globais.actualStage.hideTipMessage();
			
			thisMove_killedAdults = thisMove_killedChildren = thisMove_killedBoats = 0;
			
			var returnValue:int = tryMovePiece_aux();
			if (returnValue != -1)
				applyGameLogicAfterMovements();
			
			return returnValue;
		}
		
		///
		///	Sua fe' e' pequena, meu jovem
		///
		public static function tryMoveIslandOrVolcano():int
		{
			FlxG.play(Sounds.SndMoveTileImpossible, 1);
			globais.actualStage.showTipMessage("No enough faith. Mountains won't move!");
			return -1;
		}
		
		///
		///	Apos a peca ser movimentada, algumas coisas ainda podem acontecer (alem das acoes de antishark e bomba):
		///	- adultos e criancas podem ser comidos por tubaroes
		///	- adultos e criancas podem estar em posicao de salvamento ou nao
		///	Depois chama verifyDeadOrEscape(), para sinalizar derrota ou vitoria
		///
		public static function applyGameLogicAfterMovements():void
		{
			var actualSafeCastaways:uint = 0;
			var actualAliveCastaways:uint = 0;
			
			var i:uint, j:uint;
			var thisPosIndex:uint;
			var neighborPosIndexUP:int, neighborPosIndexDOWN:int, neighborPosIndexLEFT:int, neighborPosIndexRIGHT:int;
			var neighborPosIndexUP_LEFT:int, neighborPosIndexUP_RIGHT:int, neighborPosIndexDOWN_LEFT:int, neighborPosIndexDOWN_RIGHT:int;
			for (i = 0; i < Board.m_cellsPieces.length; i++)
			{
				if (Board.m_cellsPieces[i] == null)
					continue;
				
				if(Board.m_cellsPieces[i].type == Piece.TILE_ADULTO || Board.m_cellsPieces[i].type == Piece.TILE_CRIANCA)
				{
					
					//	Tubaroes tem prioridade para matar criancas e adultos
					if ( (neighborPosIndexUP = relativePositionIndexOnBoard(i, UP)) != -1)
						if (Board.m_cellsPieces[neighborPosIndexUP] != null)
							if (Board.m_cellsPieces[neighborPosIndexUP].type == Piece.TILE_TUBARAO_DOWN)
							{
								Board.m_cellsPieces[i].killPiece();
								FlxG.play(Sounds.SndBonecoDies, 1);
								//applyGameLogicAfterMovements();
								continue;
							}
					
					if ( (neighborPosIndexDOWN = relativePositionIndexOnBoard(i, DOWN)) != -1)
						if (Board.m_cellsPieces[neighborPosIndexDOWN] != null)
							if (Board.m_cellsPieces[neighborPosIndexDOWN].type == Piece.TILE_TUBARAO_UP)
							{
								Board.m_cellsPieces[i].killPiece();
								FlxG.play(Sounds.SndBonecoDies, 1);
								//applyGameLogicAfterMovements();
								continue;
							}
						
					if ( (neighborPosIndexLEFT = relativePositionIndexOnBoard(i, LEFT)) != -1)
						if (Board.m_cellsPieces[neighborPosIndexLEFT] != null)
							if (Board.m_cellsPieces[neighborPosIndexLEFT].type == Piece.TILE_TUBARAO_RIGHT)
							{
								Board.m_cellsPieces[i].killPiece();
								FlxG.play(Sounds.SndBonecoDies, 1);
								//applyGameLogicAfterMovements();
								continue;
							}
						
					if ( (neighborPosIndexRIGHT = relativePositionIndexOnBoard(i, RIGHT)) != -1)
						if (Board.m_cellsPieces[neighborPosIndexRIGHT] != null)
							if (Board.m_cellsPieces[neighborPosIndexRIGHT].type == Piece.TILE_TUBARAO_LEFT)
							{
								Board.m_cellsPieces[i].killPiece();
								FlxG.play(Sounds.SndBonecoDies, 1);
								//applyGameLogicAfterMovements();
								continue;
							}
							
					//	Se chegou ate' aqui, o castaway esta' vivo
					//if(Board.m_cellsPieces[i].destroyed == false)
						actualAliveCastaways++;
							
					//	Verificacao de salvamento
					var newPos:int;
					var safe:Boolean = false;
					for (j = 0; j < relative4Positions.length; j++)
					{
						//	-1 sinaliza que a posicao almejada esta' fora do tabuleiro
						if( (newPos = relativePositionIndexOnBoard(/*thisPosIndex*/i,relative4Positions[j])) != -1)
						{
							if (m_cellsPieces[newPos] != null)	//	Se ha uma peca...
							{
								if (m_cellsPieces[newPos].type == Piece.TILE_ILHA)
								{
									safe = true;
									break;
								}
								else if (m_cellsPieces[newPos].type == Piece.TILE_BOTE_V)
								{
									if (relative4Positions[j] == LEFT || relative4Positions[j] == RIGHT)
									{
										safe = true;
										break;
									}
								}
								else if (m_cellsPieces[newPos].type == Piece.TILE_BOTE_H)
								{
									if (relative4Positions[j] == UP || relative4Positions[j] == DOWN)
									{
										safe = true;
										break;
									}
								}
							}
						}				
					}
					if (safe)
					{
						actualSafeCastaways++;
						if (m_cellsPieces[i].safe == false)	//	toca som de safe apenas se ficou safe agora (n toca se *permaneceu* safe)
							FlxG.play(Sounds.SndBonecoSafe, 1);
						m_cellsPieces[i].safe = true;
						//continue;
					}
					else
						m_cellsPieces[i].safe = false;
				}
			}
			
			//	Verifica vitoria ou derrota
			verifyDeadOrEscape(actualSafeCastaways, actualAliveCastaways);
		}
		
		///
		///	- A cota de salvamentos sendo atingida, passa de fase (e guarda as metricas: tempo que levou, # movimentos)
		///	- O numero de castaways vivos impossibilitando atingir a cota de salvamentos, sinaliza derrota
		///	- O numero de movimentos ultrapassando o estipulado para o level, sinaliza derrota
		///	- No caso de derrota, guarda metrica da causa da derrota. Ela e' inferida da comparacao do estado atual do
		///board com o anterior
		///
		public static function verifyDeadOrEscape(aActualSafeCastaways:uint, aActualAliveCastaways:uint):void
		{
			//	Verifica se passou de level
			/*FlxG.log("actualSafeCastaways = " + aActualSafeCastaways);
			FlxG.log("globais.actualStage.movesLeft = " + globais.actualStage.movesLeft);
			FlxG.log("globais.actualStage.rescueQuota = " + globais.actualStage.rescueQuota);
			FlxG.log("actualAliveCastaways = " + aActualAliveCastaways);
			FlxG.log("# of levels = " + stageXML.xmlsLevels.length);*/
			if (aActualSafeCastaways >= globais.actualStage.rescueQuota)
			{
				if ((globais.actualStage.levelID + 1) < stageXML.xmlsLevels.length)
				{
					globais.actualStage.levelCompleted();
					return;
				}
				else	//	Fechou o jogo! =)
				{
					//FlxG.state = new stageFimMuitoLegal();
				}
			}
			
			//
			//	Verifica se perdeu o level
			//	Se perdeu, guarda metrica que representa a causa
			
			
			//	Passou a quantidade maxima de movimentos
			if( (globais.actualStage.m_movesCount > globais.actualStage.movesLeft) && globais.actualStage.movesLeft > 0 )
			{
				Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.EXCEEDED_MAX_MOVES); 
				globais.actualStage.failedLevel();
				return;
			}
			
			//	Castaways mortos...
			if (aActualAliveCastaways < globais.actualStage.rescueQuota)
			{
				globais.actualStage.failedLevel();
				
				//... por mina...
				if (g_clickedPiece.type == Piece.TILE_MINA_DEAD)
				{
					if (thisMove_killedAdults == 1)
					{
						if (thisMove_killedChildren > 0)
						{
							Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.MANY_CASTAWAYS_EXPLODED);
							return;
						}
						else
						{
							Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.ADULT_EXPLODED);
							return;
						}
					}
					else if (thisMove_killedAdults > 1)
					{
						Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.MANY_CASTAWAYS_EXPLODED);
						return;
					}
					
					if (thisMove_killedChildren == 1)
					{
						if (thisMove_killedAdults > 0)
						{
							Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.MANY_CASTAWAYS_EXPLODED);
							return;
						}
						else
						{
							Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.CHILD_EXPLODED);
							return;
						}
					}
					else if (thisMove_killedChildren > 1)
					{
						Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.MANY_CASTAWAYS_EXPLODED);
						return;
					}
				}
				
				//... por antishark...
				else if (g_clickedPiece.type == Piece.TILE_ANTISHARK)
				{
					if (thisMove_killedAdults == 1)
					{
						if (thisMove_killedChildren > 0)
						{
							Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.ANTISHARK__MANY_CASTAWAYS);
							return;
						}
						else
						{
							Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.ANTISHARK__ADULT);
							return;
						}
					}
					else if (thisMove_killedAdults > 1)
					{
						Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.ANTISHARK__MANY_CASTAWAYS);
						return;
					}
					
					if (thisMove_killedChildren == 1)
					{
						if (thisMove_killedAdults > 0)
						{
							Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.ANTISHARK__MANY_CASTAWAYS);
							return;
						}
						else
						{
							Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.ANTISHARK__CHILD);
							return;
						}
					}
					else if (thisMove_killedChildren > 1)
					{
						Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.ANTISHARK__MANY_CASTAWAYS);
						return;
					}
				}
				
				//	... por tubarao 'passivo' (tubarao foi ate' a vitima)...
				else if (g_clickedPiece.type == Piece.TILE_TUBARAO_DOWN || g_clickedPiece.type == Piece.TILE_TUBARAO_LEFT
						|| g_clickedPiece.type == Piece.TILE_TUBARAO_RIGHT || g_clickedPiece.type == Piece.TILE_TUBARAO_UP)
				{
					if (thisMove_killedAdults > 0)
						Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.SHARK_WENT_TO_ADULT);
					else
						Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.SHARK_WENT_TO_CHILD);
					return;
				}
				
				//	...	ou por tubarao 'ativo' (vitima foi ate' o tubarao)
				else if (g_clickedPiece.type == Piece.TILE_ADULTO || g_clickedPiece.type == Piece.TILE_CRIANCA)
				{
					if (thisMove_killedAdults > 0)
						Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.ADULT_WENT_TO_SHARK);
					else
						Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.CHILD_WENT_TO_SHARK);
					return;
				}
				
			}
			
			//	Bote destruido. Se certamente impossibilita vitoria, jogador perde o level. Se e' necessaria maior analise
			//para ver se perde o level ou nao, nao faz nada, por ora
			if ( thisMove_killedBoats > 0 )
			{
				//	Verificando qtd possivel de salvamentos
				var posibleSavings:int = 0;
				var deadCastaways:uint = 0;
				var indx:uint;
				for (var i:uint = 0; i < globais.N_COLUMNS; i++)
				{
					for (var j:uint = 0; j < globais.N_LINES; j++)
					{
						indx = j * globais.N_COLUMNS + i;
						
						//	buraco
						if (Board.m_cellsPieces[indx] == null)
							continue;
						
						//	Ilhas
						if (Board.m_cellsPieces[indx].type == Piece.TILE_ILHA)
						{
							//	Ilha em canto
							if ( (i == j && j == 0) || (i == globais.N_COLUMNS - 1 && j == globais.N_LINES - 1)
							|| (i==0 && j == globais.N_LINES - 1) || (i == globais.N_COLUMNS - 1 && j==0))
								posibleSavings += 2;
							//	Ilha em borda
							else if (i == 0 || j == 0 || i == globais.N_COLUMNS - 1 || j == globais.N_LINES - 1)
								posibleSavings += 3;
							//	Ilha 'solta'
							else
								posibleSavings += 4;								
						}
						//	Botes
						else if (Board.m_cellsPieces[indx].type == Piece.TILE_BOTE_H
						|| Board.m_cellsPieces[indx].type == Piece.TILE_BOTE_V)
						{
							posibleSavings += 2;
						}
						//	Castaways mortos
						else if (Board.m_cellsPieces[indx].type == Piece.TILE_ADULTO_DEAD
						|| Board.m_cellsPieces[indx].type == Piece.TILE_CRIANCA_DEAD)
						{
							deadCastaways++;
						}						
					}
				}
				//	Se nao e' possivel salvar a qtd necessaria, perdeu o level
				if(posibleSavings < globais.actualStage.rescueQuota - deadCastaways)
				{
					Log.LevelRangedMetric("Death Cause", globais.SWFStats_thisLevelTag(), globais.BOAT_DESTROYED);
					globais.actualStage.failedLevel();
					//return;
				}
			}
		}
		
		///
		///	Desfaz movimentacao, utilizando os tipos de pecas do estado anterior do board (m_cellsTypes_buffer) 
		///
		public static function undo():void
		{
			//	Primeiramente busca a posicao nula anterior (a peca que esta' atualmente nessa 
			//posicao e' a peca que se deslocou) e a atual posicao nula
			var anteriorEmptyCell:uint, actualEmptyCell:uint;
			for (var i:uint = 0; i < globais.N_COLUMNS * globais.N_LINES; i++)
			{
				if (m_cellsTypes_buffer[i] == null)
					anteriorEmptyCell = i;
				if (m_cellsPieces[i] == null)
					actualEmptyCell = i;
			}
			
			//	(isso e' necessario porque vamos apenas modificando os tipos das pecas, sendo que essas pecas 
			//sao obtidas por referencia - entao temos que tratar separadamente as referencias nulas)
			if (m_cellsPieces[anteriorEmptyCell] == null)
				return;	//	nao e' permitido mais undos. Tchau
			
			//	(se ainda esta' aqui, realmente usou o undo)
			
			//	Atualizando contador de undos
			globais.actualStage.m_undosCount++;
			//	SWFStats: quantidade media de undos nesta fase
			Log.LevelAverageMetric("Undos", globais.SWFStats_thisLevelTag(), globais.actualStage.m_undosCount);
			
			//	Efetuando undo
			m_cellsPieces[actualEmptyCell] = m_cellsPieces[anteriorEmptyCell];
			m_cellsPieces[actualEmptyCell].indexOnBoard = actualEmptyCell;
			m_cellsPieces[actualEmptyCell].positionPiece();
			
			//	Temos que ressuscitar a peca movimentada se ela morreu agora
			if (m_cellsPieces[actualEmptyCell].type == Piece.TILE_MINA_DEAD)
			{
				m_cellsPieces[actualEmptyCell].changeType(Piece.TILE_MINA);
				m_cellsPieces[actualEmptyCell].destroyed = false;
			}
			if (m_cellsPieces[actualEmptyCell].type == Piece.TILE_ADULTO_DEAD)
			{
				m_cellsPieces[actualEmptyCell].changeType(Piece.TILE_ADULTO);
				m_cellsPieces[actualEmptyCell].destroyed = false;
			}
			if (m_cellsPieces[actualEmptyCell].type == Piece.TILE_CRIANCA_DEAD)
			{
				m_cellsPieces[actualEmptyCell].changeType(Piece.TILE_CRIANCA);
				m_cellsPieces[actualEmptyCell].destroyed = false;
			}
			
			//	Posicao anterior volta a ser nula
			m_cellsPieces[anteriorEmptyCell] = null;
			
			//	Agora volta o estado do board ao estado anterior para o restante das celulas
			for (i = 0; i < globais.N_COLUMNS * globais.N_LINES; i++)
			{
				if (i == actualEmptyCell)
					continue;
				
				if (m_cellsTypes_buffer[i] != null)
				{
					m_cellsPieces[i].changeType(m_cellsTypes_buffer[i]);
					m_cellsPieces[i].positionPiece();
				}
				else
					m_cellsPieces[i] = null;
			}
			
			//	Por fim, iguala m_cellsTypes_buffer[i] a m_cellsPieces[i].types, o que garante que nao sao possiveis
			//undos consecutivos (enquanto nosso buffer de undos guarda so uma jogada)
			for (i = 0; i < globais.N_COLUMNS * globais.N_LINES; i++)
				m_cellsTypes_buffer[i] = m_cellsPieces[i];
		}

	}

}