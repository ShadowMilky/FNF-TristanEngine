package;

class PauseOption
{
	public var optionName:String;

	public function new(optionName:String)
	{
		this.optionName = optionName;
	}

	public static function getOption(list:Array<PauseOption>, optionName:String):PauseOption
	{
		for (option in list)
		{
			if (option.optionName == optionName)
				return option;
		}
		return null;
	}
}
