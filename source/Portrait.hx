package;

class Portrait
{
	public var portraitPath:String;
	public var portraitAnim:Animation;
	public var left:Bool;

	public function new(portraitPath:String, portraitAnim:Animation = null, left:Bool)
	{
		this.portraitPath = portraitPath;
		this.portraitAnim = portraitAnim;
		this.left = left;
	}
}
