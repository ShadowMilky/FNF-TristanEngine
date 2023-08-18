package;

import flixel.util.FlxColor;

class Week
{
	public var songList:Array<String>;
	public var weekName:String;
	public var weekColor:FlxColor;
	public var bannerName:String;

	public function new(songList:Array<String>, weekName:String, weekColor:FlxColor, bannerName:String)
	{
		this.songList = songList;
		this.weekName = weekName;
		this.weekColor = weekColor;
		this.bannerName = bannerName;
	}
}
