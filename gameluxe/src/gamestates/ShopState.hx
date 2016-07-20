package gamestates;

import analysis.DFT;
import data.GameInfo;
import data.CharacterData;
import luxe.Color;
import luxe.Input;
import luxe.Input.KeyEvent;
import luxe.Input.Key;
import luxe.Parcel;
import luxe.Scene;
import luxe.Sprite;
import luxe.Text;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import mint.List;
import ui.MintGridPanel;
import ui.MintImageButton;
import ui.MintImageButton_Store;

/**
 * ...
 * @author Simon
 */
class ShopState extends State
{
	private var game_info : GameInfo;
	private var scene : Scene;
	private var title_text : Text;
	var parcel : Parcel;
	var change_to : String;
	
	private var character_panel : MintGridPanel;
	private var characters : Array<CharacterData> = new Array();
	
	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		scene = null;
		
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (change_to != "")
		{
			machine.set(change_to);
			change_to = "";
		}
	}
	
	override public function onkeyup(event:KeyEvent) 
	{
		if(event.keycode == Key.escape)
			change_to = "MenuState";
	}
	
	override function onenter<T>(d:T)
	{
		super.onenter(d);
		trace("Entering Shop");
		
		// load parcels
		Main.load_parcel(parcel, "assets/data/shop_parcel.json", on_loaded);
		
		scene = new Scene("ShopScene");
		
		//Luxe.camera.size_mode = luxe.SizeMode.contain;
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
		
		// Background Layer
		Main.create_background(scene);
	}
	
	override public function onleave<T>(d:T) 
	{
		super.onleave(d);
		trace("Leaving Shop. Come again!");
		
		Main.canvas.destroy_children();
		
		scene.empty();
		scene.destroy();
		scene = null;
		title_text = null;
		
		parcel = null;
		
		characters = new Array();
	}
	
	function on_loaded( p: Parcel )
	{
		var json_resource = Luxe.resources.json("assets/data/shop.json");
		var character_data : Array<Dynamic> = json_resource.asset.json.characters;
		
		var background1 = new Sprite({
			texture: Luxe.resources.texture('assets/image/frontend_bg.png'),
			pos: new Vector(720, 450),
			size: new Vector(500, 900),
			scene: scene,
		});
		
		
		for (i in 0...character_data.length)
		{
			var n = character_data[i];
			var new_template : CharacterData = new CharacterData(n.name, n.tex_path, n.game_texture, n.cost);
			characters.push(new_template);
			trace("Loaded: " + n);
		}
		
		// UI layer	
		var window_w = 500;
		character_panel = new MintGridPanel(Main.canvas, "Characters", new Vector((Main.canvas.w / 2) - (window_w/2), 200), window_w, 3, 5);
		
		for (i in 0...characters.length)
		{
			var item : MintImageButton_Store = new MintImageButton_Store(character_panel, characters[i].name, 
				new Vector(0, 0), new Vector(143, 193), 
				characters[i].tex_path, function(b){ click_character(b); });

			character_panel.add_item(item);
		}
	}
	
	function click_character(b : MintImageButton )
	{
		trace("clicked character");
		for (i in 0...characters.length)
		{
			if (b.name == characters[i].name)
			{
				if (Main.achievement_manager.is_item_unlocked(characters[i].name))
				{
					trace("Set active");
					Main.achievement_manager.current_character_name = characters[i].name;
				}
				else if (Main.achievement_manager.current_coins > characters[i].cost)
				{
					trace("Purchased");
					Main.achievement_manager.unlocked_items.push(characters[i].name);
					Main.achievement_manager.current_coins -= characters[i].cost;
				}
				
				break;
			}
		}

		b.update_button();
		
	}
}