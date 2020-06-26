package core.factory 
{
	import portals.Portal;
	/**
	 * ...
	 * @author Dr. Willy
	 */
	public class PortalFactory
	{
		
		//	Nao instanciar!
		public function PortalFactory() 
		{
			
		}
		
		public static function createPortal(aType:int):Portal
		{
			var newPortal:Portal;
			switch(aType)
			{
				case 0: newPortal = new Portal(); break;
			}
			
			return newPortal;
		}
		/*public static function createPlayerBullet():Bullet {
			return new Bullet(500,600, 1,12,6,Images.ImgBullet); 
		}
		
		public static function createPlayerBulletBuff():Bullet {
			return new Bullet(500,600, 1,12,6,Images.ImgBulletPowerUp,10,10,true,20); 
		}
		
		public static function createEnemyBullet(speed:uint, damage:uint):Bullet {
			return new Bullet(speed,speed + 100, damage,12,6,Images.ImgBulletEnemy);
		}
		
		public static function createPlayerBomb():Bomb {
			return new Bomb(600,1,75);
		}*/

		
	}

}