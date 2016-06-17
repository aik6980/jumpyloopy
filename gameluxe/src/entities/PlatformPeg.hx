package entities;

import data.GameInfo;
import luxe.Camera;
import luxe.Scene;
import luxe.options.SpriteOptions;
import luxe.Sprite;
import luxe.Vector;

/**
 * ...
 * @author aik
 */
class PlatformPeg extends Sprite
{
	public function new(scene:Scene, game_info:GameInfo, n : Int) 
	{
		var options : SpriteOptions =
		{
			name: 'PlatformPeg${n}',
			texture: Luxe.resources.texture('assets/image/spritesheet_jumper.png'),
			uv: game_info.spritesheet_elements['coin_gold.png'],
			pos: Luxe.screen.mid,
			size: new Vector(game_info.spritesheet_elements['coin_gold.png'].w, game_info.spritesheet_elements['coin_gold.png'].h),
			scene: scene,
		};
		
		super(options);
		scale.set_xy(0.4, 0.4);
	}
	
}