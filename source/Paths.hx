package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
#if sys import sys.FileSystem; #end

class Paths
{
	inline public static final SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	inline static public function isLocale():Bool
		return LanguageManager.save.data.language != 'en-US';

	inline static public function setCurrentLevel(name:String)
		currentLevel = name.toLowerCase();

	public static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	inline static public function getDirectory(directoryName:String, ?library:String)
	{
		return getPath('images/$directoryName', IMAGE, library);
	}

	inline static public function getLibraryPath(file:String, library = "preload")
	{
		return (library == "preload" || library == "default") ? getPreloadPath(file) : getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		var defaultReturnPath = getPath(file, type, library);
		if (isLocale())
		{
			var langaugeReturnPath = getPath('locale/${LanguageManager.save.data.language}/' + file, type, library);
			if (FileAssets.exists(langaugeReturnPath))
			{
				return langaugeReturnPath;
			}
			else
			{
				return defaultReturnPath;
			}
		}
		else
		{
			return defaultReturnPath;
		}
	}

	inline static public function txt(key:String, ?library:String)
	{
		var defaultReturnPath = getPath('data/$key.txt', TEXT, library);
		if (isLocale())
		{
			var langaugeReturnPath = getPath('locale/${LanguageManager.save.data.language}/data/$key.txt', TEXT, library);
			if (FileAssets.exists(langaugeReturnPath))
			{
				return langaugeReturnPath;
			}
			else
			{
				return defaultReturnPath;
			}
		}
		else
		{
			return defaultReturnPath;
		}
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function data(key:String, ?library:String)
	{
		return getPath('data/$key', TEXT, library);
	}

	inline static public function chart(key:String, ?library:String)
	{
		return getPath('data/charts/$key.json', TEXT, library);
	}

	inline static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String, addon:String = "")
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Voices${addon}.$SOUND_EXT';
	}

	inline static public function inst(song:String)
	{
		return 'songs:assets/songs/${song.toLowerCase()}/Inst.$SOUND_EXT';
	}

	inline static public function externmusic(song:String)
	{
		return 'songs:assets/songs/extern/${song.toLowerCase()}.$SOUND_EXT';
	}

	inline static public function image(key:String, ?library:String)
	{
		var defaultReturnPath = getPath('images/$key.png', IMAGE, library);
		if (isLocale())
		{
			var langaugeReturnPath = getPath('locale/${LanguageManager.save.data.language}/images/$key.png', IMAGE, library);
			if (FileAssets.exists(langaugeReturnPath))
			{
				return langaugeReturnPath;
			}
			else
			{
				return defaultReturnPath;
			}
		}
		else
		{
			return defaultReturnPath;
		}
	}

	/*
		WARNING!!
		DO NOT USE splashImage, splashFile or getSplashSparrowAtlas for searching stuff in paths!!!!!
		I'm only using these for FlxSplash since the languages haven't loaded yet!
	 */
	inline static public function splashImage(key:String, ?library:String, ?ext:String = 'png')
	{
		var defaultReturnPath = getPath('images/$key.$ext', IMAGE, library);
		return defaultReturnPath;
	}

	inline static public function splashFile(file:String, type:AssetType = TEXT, ?library:String)
	{
		var defaultReturnPath = getPath(file, type, library);
		return defaultReturnPath;
	}

	inline static public function getSplashSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(splashImage(key, library), splashFile('images/$key.xml', library));
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function scriptFile(key:String)
	{
		return getPath('data/scripts/$key.hx', TEXT, 'preload');
	}

	inline static public function langaugeFile():String
	{
		return getPath('locale/languages.txt', TEXT, 'preload');
	}

	inline static public function characterFile(character:String):String
	{
		return getPath('data/characters/' + character + '.json', TEXT, 'preload');
	}

	inline static public function offsetFile(character:String):String
	{
		return getPath('data/offsets/' + character + '.txt', TEXT, 'preload');
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function video(key:String, ?library:String)
	{
		return getPath('videos/$key.mp4', BINARY, library);
	}
}

class CustomPaths
{
	var dir:String = "";
	var lib:String = "";

	public function new(dir:String, lib:String)
	{
		this.dir = dir;
		this.lib = lib;
	}

	public function music(key:String, useFullDir = false)
	{
		return Paths.getPath('$dir/${useFullDir ? 'music/' : ''}$key.${Paths.SOUND_EXT}', MUSIC, lib);
	}

	public function sound(key:String, useFullDir = false)
	{
		return Paths.getPath('$dir/${useFullDir ? 'sounds/' : ''}$key.${Paths.SOUND_EXT}', SOUND, lib);
	}

	public function soundRandom(key:String, min:Int, max:Int, useFullDir = false)
	{
		return sound(key + FlxG.random.int(min, max), useFullDir);
	}

	public function txt(key:String, useFullDir = false)
	{
		return Paths.getPath('$dir/${useFullDir ? 'data/' : ''}$key.txt', TEXT, lib);
	}

	public function json(key:String, useFullDir = false)
	{
		return Paths.getPath('$dir/${useFullDir ? 'data/' : ''}$key.json', TEXT, lib);
	}

	public function image(key:String, useFullDir = false)
	{
		return Paths.getPath('$dir/${useFullDir ? 'images/' : ''}$key.png', IMAGE, lib);
	}

	public function getSparrowAtlas(key:String, useFullDir = false)
	{
		return FlxAtlasFrames.fromSparrow(image(key, useFullDir), Paths.file('$dir/${useFullDir ? 'images/' : ''}$key.xml', lib));
	}

	public function getPackerAtlas(key:String, useFullDir = false)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, useFullDir), Paths.file('$dir/${useFullDir ? 'images/' : ''}$key.txt', lib));
	}
}

/**
 * there's a big difference between the two
 * sys.FileSystem actually checks the directory while OpenFL only checks the manifest and could return true for a non-existing directory/file
 * so we're gonna use this for one over the other
 * but, OpenFL assets is compatible on every platform compared to sys's FileSystem
 */
typedef FileAssets = #if sys FileSystem; #else OpenFlAssets; #end
