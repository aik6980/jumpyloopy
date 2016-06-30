package gamestates;

import data.GameInfo;
import entities.BeatManager;
import luxe.Audio.AudioState;
import luxe.Color;
import luxe.Parcel;
import luxe.ParcelProgress;
import luxe.Vector;
import luxe.options.StateOptions;
import luxe.States.State;
import luxe.tween.Actuate;
import mint.Button;
import mint.types.Types.TextAlign;
import snow.types.Types.AudioHandle;

#if (cpp || neko)
import systools.Dialogs;
#end

/**
 * ...
 * @author Aik
 */
class LevelSelectState extends State
{
	var game_info : GameInfo;
	
	var parcel : Parcel;
	
	/// deferred state transition
	var change_to = "";
	
	/// music preview
	var music_handle : AudioHandle;
	var music_volume = 0.0;
	
	/// user mode
	var audio_fn = "";
	var audio_fft_params_id = "";

	public function new(_name:String, game_info : GameInfo) 
	{
		super({name: _name});
		this.game_info = game_info;
		
		Luxe.events.listen("BeatManager.AudioLoaded", on_audio_analysis_completed );
	}
	
	override function onleave<T>(_value:T)
	{
		Actuate.reset();
		Luxe.audio.stop(music_handle);
		
		Main.canvas.destroy_children();		
		parcel = null;
	}
	
	override function onenter<T>(_value:T)
	{
		trace("Entering level select");
		
		// load parcels
		parcel = new Parcel();
		parcel.from_json(Luxe.resources.json("assets/data/level_select_parcel.json").asset.json);
		
		var progress = new ParcelProgress({
            parcel      : parcel,
            background  : new Color(0,0,0,0.85),
            oncomplete  : on_loaded
        });
		
		parcel.load();
		
		Luxe.camera.size = new Vector(Main.global_info.ref_window_size_x, Main.global_info.ref_window_size_y);
	}
	
	function create_button( desc: Dynamic) : Button
	{
		var button = MenuState.create_button( desc );
		
		button.onmouseenter.listen(
			function(e, c)
			{
				if (Luxe.audio.state_of(music_handle) == AudioState.as_playing)
				{
					return;
				}
				
				var audio_name = desc.track;
		
				var load = snow.api.Promise.all([
					Luxe.resources.load_audio(audio_name, {is_stream:true})
				]);
		
				load.then(function(_)
				{
					var music = Luxe.resources.audio(audio_name);
					music_handle = Luxe.audio.play(music.source, music_volume, false);
					
					Actuate.tween(this, 0.5, {music_volume:1.0});
				});
			});
			
		button.onmouseleave.listen( function(e, c)
		{
			Actuate.tween(this, 0.5, {music_volume:0.0})
				.onComplete(function() {Luxe.audio.stop(music_handle);});
		});
		
		return button;
	}
	
	function on_loaded( p: Parcel )
	{
		var json_resource = Luxe.resources.json("assets/data/level_select.json");
		var layout_data = json_resource.asset.json;
		
		var title = new mint.Label({
			parent: Main.canvas, name: 'label',
			mouse_input:false, x:layout_data.title.pos_x, y:layout_data.title.pos_y, w:Main.global_info.ref_window_size_x, h:100, text_size: 48,
			align: TextAlign.center, align_vertical: TextAlign.center,
			text: layout_data.title.text,
		});
		
		var button0 = create_button( layout_data.level_0 );
		button0.onmouseup.listen(
			function(e,c) 
			{
				Main.beat_manager.load_song(layout_data.level_0.track);
				//change_to = "GameState";
			});
		
		var button1 = create_button( layout_data.level_1 );
		button1.onmouseup.listen(
			function(e,c) 
			{
				Main.beat_manager.load_song(layout_data.level_1.track);
				//change_to = "GameState";
			});
		
		var button2 = MenuState.create_button( layout_data.level_x );
		button2.onmouseup.listen(
			function(e,c) 
			{
				//change_to = "GameState";
				#if cpp
				var filters: FILEFILTERS = { count: 1
				, descriptions: ["OGG files"]
				, extensions: ["*.ogg"]	
				
				};	
				var result:Array<String> = Dialogs.openFile(
				"Select a file please!"
				, "Please select one or more files, so we can see if this method works"
				, filters
				);
				
				trace(result);
				if (result != null)
				{
					// if we have the audio tweak file
					audio_fn = result[0];
					audio_fft_params_id = StringTools.replace(audio_fn, "ogg", "json");
					
					// reload resource
					var json_data = Luxe.resources.json(audio_fft_params_id);
					if (json_data != null)
					{
						Luxe.resources.destroy(audio_fft_params_id, true);
					}
					
					var loaded_cfg = Luxe.resources.load_json(audio_fft_params_id).then( on_audio_cfg_loaded, on_audio_cfg_notfound );
				}
				#end
			}
		);
	}
	
	function on_audio_cfg_loaded(e)
	{
		trace("cfg file loaded");
		
		var json_data = Luxe.resources.json(audio_fft_params_id).asset.json;
		if (json_data != null)
		{		
			BeatManager.bands[0].low = json_data.band[0];
			BeatManager.bands[0].high = json_data.band[1];
			BeatManager.multipliers[0] = json_data.peak[0];
		}
		
		Main.beat_manager.load_song(audio_fn);
		audio_fn = "";
		audio_fft_params_id = "";
	}
	
	function on_audio_cfg_notfound(e)
	{
		trace("cfg file not found");
		
		Main.beat_manager.load_song(audio_fn);
		audio_fn = "";
		audio_fft_params_id = "";
	}
	
	public function on_audio_analysis_completed(e)
	{
		change_to = "StoryIntroState";
	}
	
	override public function update(dt:Float) 
	{
		super.update(dt);
		
		if (change_to != "")
		{
			machine.set(change_to);
			change_to = "";
		}
		
		// fade music in/out if we need to
		if (music_handle != null)
		{
			Luxe.audio.volume(music_handle, music_volume);
		}
	}
}