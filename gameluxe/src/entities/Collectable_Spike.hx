package entities;
import entities.Avatar;
import luxe.Scene;
import luxe.Vector;

/**
 * ...
 * @author sm
 */
class Collectable_Spike extends Collectable
{
	public function new(scene : Scene, name : String, position : Vector) 
	{
		super(scene, name, 'assets/image/collectables/collectable_spike.png', '', new Vector(50, 50), position);
	}
		
	override function onCollisionEnter(player:Avatar):Void 
	{
		//Do fun stuff.
		// A bit of a game breaker, commenting out for now [Aik]
		//Luxe.events.fire("kill_player", {msg:"Massive SPIKES!"});
		super.onCollisionEnter(player);
	}
}