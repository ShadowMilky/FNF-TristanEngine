package;

import flixel.FlxG;
import tea.*;

class HBase extends SScript
{
	public function new(?path:String)
	{
		super(path);

		set("PlayState", PlayState);
		set("GameOverSubstate", GameOverSubstate);
		set("importLib", importLib);
		set("Reflect", Reflect);
		set("Type", Type);
		set("CoolUtil", CoolUtil);
		set("Controls", Controls);
		set("FlxG", flixel.FlxG);
		set("FlxSprite", flixel.FlxSprite);
		set("FlxGroup", flixel.group.FlxGroup);
		set("FlxMath", flixel.math.FlxMath);
		set("FlxColor", flixel.util.FlxColor);
		set("FlxTimer", flixel.util.FlxTimer);
		set("FlxObject", flixel.FlxObject);
		set("FlxText", flixel.text.FlxText);
		set("StringTools", StringTools);
		set("FlxStringUtils", flixel.util.FlxStringUtil);
		set("FlxSort", flixel.util.FlxSort);
		set("FlxButton", flixel.ui.FlxButton);
		set("FlxSave", flixel.util.FlxSave);
		set("Log", haxe.Log)
		set("Lib", openfl.Lib);
		set("LimeApplication", lime.app.Application)
		set("OpenFlAssets", openfl.utils.Assets);
		set("Json", haxe.Json);
		set("Http", haxe.Http);
		set("Expection", haxe.Exception);
		set("Matrix", openfl.geom.Matrix);
		set("FlxBar", flixel.ui.FlxBar);
		set("FlxSpriteGroup", flixel.group.FlxSpriteGroup)
		set("FlxObject", flixel.FlxObject);
		set("FlxTween", flixel.tweens.FlxTween);
		set("FlxEase", flixel.tweens.FlxEase);
		set("Promise", lime.app.Promise);
		set("Future", lime.app.Future);
		set("JsonParser", haxe.format.JsonParser);
		set("LimeAssets", lime.utils.Assets);
		set("FlxSound", flixel.system.FlxSound);
		set("Conductor", Conductor);
		set("PlatformUtil", PlatformUtil);
		set("SubtitleManager", SubtitleManager);
		set("Subtitle", Subtitle);
		parser.line = 1;
		parser.allowTypes = true;
		parser.allowJSON = true;
	} // psych engine??? i might switch to a different lib which will deprecate this

	function importLib(lib:String, alias = "")
	{
		var name = alias != "" ? alias : lib.split(".").pop();
		var target = Type.resolveClass(lib);
		if (target != null && get(name) == null)
			set(name, target);
	}
}

class CallbackScript extends HBase
{
	var name:String = "h";

	public function exec(target:String, args:Array<Dynamic>):Dynamic
	{
		try
		{
			return call(target, args);
		}
		catch (e)
		{
			trace('Callback:$name function "$target" failed: ${e.message}');
			return null;
		}
	}
}

class HCharacter extends CallbackScript
{
	override public function new(charClass:Character, path:String)
	{
		super(path);
		name = "Character:" + charClass.curCharacter;
		set("this", charClass);
		set("char", charClass);
		set("Paths", new CustomPaths(charClass.curCharacter, "characters"));
		set("_Paths", Paths);
	}
}

class HVars
{
	static public var STOP:Int = 0;
}
