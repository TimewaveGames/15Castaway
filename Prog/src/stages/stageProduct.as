package stages 
{
	import core.globais;
	import org.flixel.FlxG;
	/**
	 * Especializacao de stage, representa um level, cujas caracteristicas sao lidas de xml
	 * @author Dino 7 Cordas
	 */
	public class stageProduct extends stage
	{
		
		public function stageProduct(levelOrder:uint) 
		{
			//m_levelOrder = levelOrder;
			m_levelID = levelOrder;
			
			//Layers dos mapas do stage atual em globais
			globais.mapLayer0 = stageXML.xmlsLevelsLayers[m_levelID];
			
			//	Atualiza ponteiro global do stage atual
			globais.actualStage = this;
			
			//Chama o construtor da classe STAGE informando as caracteristicas deste stage (# de movimentos, nome, etc...)
			super(stageXML.xmlsLevels[m_levelID]);
			
		}
		
	}

}
