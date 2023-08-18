package;

class CharacterForm
{
	public var name:String;
	public var polishedName:String;
	public var noteType:String;
	public var noteMs:Array<Float>;

	public function new(name:String, polishedName:String, noteMs:Array<Float>, noteType:String = 'normal')
	{
		this.name = name;
		this.polishedName = polishedName;
		this.noteType = noteType;
		this.noteMs = noteMs;
	}
}