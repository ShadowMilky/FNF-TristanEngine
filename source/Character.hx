package;

import sys.FileSystem;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSort;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;

using StringTools;

typedef CharacterData =
{
	var name:String;
	var asset:String;
	var startingAnim:String;

	/**
	 * Whether this character is flipped horizontally.
	 * @default false
	 */
	var ?flipX:Bool;

	/**
	 * The scale of this character.
	 * Pixel characters typically use 6.
	 * @default 1
	 */
	var ?scale:Int;

	/**
	 * Whether this character has antialiasing.
	 * @default true
	 */
	var ?antialiasing:Bool;

	var ?nativePlayable:Bool;
	var ?globalPosition:Array<Float>;

	/**
	 * The color of this character's health bar.
	 */
	var barColor:String;

	/**
	 * Whether this character uses a dancing idle instead of a regular idle.
	 * (ex. gf, spooky)
	 * @default false
	 */
	var ?isDancing:Bool;

	var animations:Array<AnimationData>;
}

typedef AnimationData =
{
	var name:String;
	var prefix:String;
	var ?offsets:Array<Int>;

	/**
	 * Whether this animation is looped.
	 * @default false
	 */
	var ?looped:Bool;

	var ?flipX:Bool;
	var ?flipY:Bool;

	/**
	 * The frame rate of this animation.
	 		* @default 24
	 */
	var ?frameRate:Int;

	// var ?frameIndices:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;
	public var isDancing:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;
	public var canDance:Bool = true;

	public var nativelyPlayable:Bool = false;

	public var globalOffset:Array<Float> = new Array<Float>();
	public var offsetScale:Float = 1;

	public var barColor:FlxColor;

	public var canSing:Bool = true;
	public var skins:Map<String, String> = new Map<String, String>();

	public var charList:Array<String> = [];

	public var animationNotes:Array<Dynamic> = [];

	public var specialAnim:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;
		charList = CoolUtil.coolTextFile(Paths.file('data/characterList.txt', TEXT, 'preload'));

		skins.set('normal', curCharacter);
		skins.set('gfSkin', 'gf-none');

		antialiasing = true;

		switch (curCharacter)
		{
			case 'bf':
				frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
				animation.addByPrefix('dodge', "boyfriend dodge", 24, false);
				animation.addByPrefix('scared', 'BF idle shaking', 24);
				animation.addByPrefix('hit', 'BF hit', 24, false);

				loadOffsetFile(curCharacter);

				skins.set('gfSkin', 'gf');

				barColor = FlxColor.fromRGB(49, 176, 209);

				playAnim('idle');

				nativelyPlayable = true;

				flipX = true;
			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('characters/bfPixel', 'shared');
				animation.addByPrefix('idle', 'BF IDLE', 24, false);
				animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
				animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

				loadOffsetFile(curCharacter);

				skins.set('gfSkin', 'gf-pixel');

				globalOffset = [196, 163];

				barColor = FlxColor.fromRGB(49, 176, 209);

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();

				antialiasing = false;
				nativelyPlayable = true;

				playAnim('idle');
				flipX = true;
			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('characters/bfPixelsDEAD', 'shared');
				animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
				animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
				animation.addByPrefix('deathLoop', "Retry Loop", 24, true);
				animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
				nativelyPlayable = true;
				flipX = true;
				playAnim('firstDeath');
			case 'generic-death':
				frames = Paths.getSparrowAtlas('ui/lose', 'shared');
				animation.addByPrefix('firstDeath', "lose... instance 1", 24, false);
				animation.addByPrefix('deathLoop', "still", 24, true);
				animation.addByPrefix('deathConfirm', "still", 24, false);

				loadOffsetFile(curCharacter);
				flipX = true;
				playAnim('firstDeath');
			case 'gf':
				// GIRLFRIEND CODE
				frames = Paths.getSparrowAtlas('characters/GF_assets', 'shared');

				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsetFile(curCharacter);

				barColor = FlxColor.fromString('#33de39');

				playAnim('danceRight');
			case 'gf-pixel':
				frames = Paths.getSparrowAtlas('characters/gfPixel', 'shared');
				animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
				animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile(curCharacter);

				globalOffset = [300, 280];

				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
				barColor = FlxColor.fromString('#33de39');

				playAnim('danceRight');
			case 'gf-christmas':
				frames = Paths.getSparrowAtlas('characters/gfChristmas', 'shared');
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -2);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				barColor = FlxColor.fromString('#33de39');

				playAnim('danceRight');

			case 'gf-car':
				frames = Paths.getSparrowAtlas('characters/gfCar', 'shared');

				animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
					false);

				addOffset('danceLeft', 0);
				addOffset('danceRight', 0);

				barColor = FlxColor.fromString('#33de39');

				playAnim('danceRight');
			case 'dad':
				// DAD ANIMATION LOADING CODE
				frames = Paths.getSparrowAtlas('characters/DADDY_DEAREST', 'shared');

				animation.addByPrefix('idle', 'Dad idle dance', 24);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				addOffset('idle');
				addOffset("singUP", -6, 50);
				addOffset("singRIGHT", 0, 27);
				addOffset("singLEFT", -10, 10);
				addOffset("singDOWN", 0, -30);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			case 'spooky':
				frames = Paths.getSparrowAtlas('characters/spooky_kids_assets', 'shared');

				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				addOffset('danceLeft');
				addOffset('danceRight');

				addOffset("singUP", -20, 26);
				addOffset("singRIGHT", -130, -14);
				addOffset("singLEFT", 130, -10);
				addOffset("singDOWN", -50, -130);

				globalOffset = [0, 200];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('danceRight');
			case 'mom':
				frames = Paths.getSparrowAtlas('characters/Mom_Assets', 'shared');

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ PHANTOM IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", 14, 71);
				addOffset("singRIGHT", 10, -60);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -160);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

			case 'mom-car':
				frames = Paths.getSparrowAtlas('characters/momCar', 'shared');

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				addOffset('idle');
				addOffset("singUP", 14, 71);
				addOffset("singRIGHT", 10, -60);
				addOffset("singLEFT", 250, -23);
				addOffset("singDOWN", 20, -160);

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			case 'monster':
				frames = Paths.getSparrowAtlas('characters/Monster_Assets', 'shared');

				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -30, -40);

				globalOffset = [0, 100];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			case 'monster-christmas':
				frames = Paths.getSparrowAtlas('characters/monsterChristmas', 'shared');

				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				addOffset('idle');
				addOffset("singUP", -20, 50);
				addOffset("singRIGHT", -51);
				addOffset("singLEFT", -30);
				addOffset("singDOWN", -40, -94);

				globalOffset = [0, 130];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');
			/* case 'pico':
				frames = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');

				animation.addByPrefix('idle', "Pico Idle Dance", 24);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
				animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24);

				addOffset('idle');
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -68, -7);
				addOffset("singLEFT", 65, 9);
				addOffset("singDOWN", 200, -70);
				addOffset("singUPmiss", -19, 67);
				addOffset("singRIGHTmiss", -60, 41);
				addOffset("singLEFTmiss", 62, 64);
				addOffset("singDOWNmiss", 210, -28);

				globalOffset = [0, 300];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				flipX = true; */

			case 'bf-christmas':
				frames = Paths.getSparrowAtlas('characters/bfChristmas', 'shared');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);

				skins.set('gfSkin', 'gf-christmas');

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				nativelyPlayable = true;
				flipX = true;
			case 'bf-car':
				frames = Paths.getSparrowAtlas('characters/bfCar', 'shared');

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);

				skins.set('gfSkin', 'gf-car');

				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				nativelyPlayable = true;
				flipX = true;
			case 'senpai':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);

				globalOffset = [150, 360];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('characters/senpai', 'shared');
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				addOffset('idle');
				addOffset("singUP", 5, 37);
				addOffset("singRIGHT");
				addOffset("singLEFT", 40);
				addOffset("singDOWN", 14);

				globalOffset = [150, 360];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;
			case 'spirit':
				frames = Paths.getPackerAtlas('characters/spirit', 'shared');
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				addOffset('idle', -220, -280);
				addOffset('singUP', -220, -240);
				addOffset("singRIGHT", -220, -280);
				addOffset("singLEFT", -200, -280);
				addOffset("singDOWN", 170, 110);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				globalOffset = [-150, 100];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('characters/mom_dad_christmas_assets', 'shared');
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);

				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				addOffset('idle');
				addOffset("singUP", -47, 24);
				addOffset("singRIGHT", -1, -23);
				addOffset("singLEFT", -30, 16);
				addOffset("singDOWN", -31, -29);
				addOffset("singUP-alt", -47, 24);
				addOffset("singRIGHT-alt", -1, -24);
				addOffset("singLEFT-alt", -30, 15);
				addOffset("singDOWN-alt", -30, -27);

				globalOffset = [-500, 0];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

			case 'tankman':
				frames = Paths.getSparrowAtlas('characters/tankmanCaptain', 'shared');
				animation.addByPrefix('idle', 'Tankman Idle Dance', 24, false);
				animation.addByPrefix('singUP', 'Tankman UP note 1', 24, false);
				animation.addByPrefix('singDOWN', 'Tankman DOWN note 1', 24, false);
				animation.addByPrefix('singRIGHT', 'Tankman Note Left 1', 24, false);
				animation.addByPrefix('singLEFT', 'Tankman Right Note 1', 24, false);

				animation.addByPrefix('singUP-alt', 'TANKMAN UGH', 24, false);
				animation.addByPrefix('singDOWN-alt', 'PRETTY GOOD tankman', 24, false);

				animation.addByPrefix('singUPmiss', 'Tankman UP note MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Tankman DOWN note MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'Tankman Right Note MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'Tankman Note Left MISS', 24, false);

				addOffset('idle');
				addOffset("singUP", 48, 54);
				addOffset("singDOWN", 76, -101);
				addOffset("singLEFT", 84, -14);
				addOffset("singRIGHT", -21, -31);
				addOffset("singUP-alt", -15, -8);
				addOffset('singDOWN-alt', 1, 16);
				addOffset("singUPmiss", 48, 54);
				addOffset("singRIGHTmiss", 84, -14);
				addOffset("singLEFTmiss", -21, -31);
				addOffset("singDOWNmiss", 76, 101);

				globalOffset = [0, 240];
				barColor = FlxColor.fromString(getColorCode(curCharacter));

				playAnim('idle');

				flipX = true;

			case 'pico-speaker':
				frames = Paths.getSparrowAtlas('characters/picoSpeaker', 'shared');

				quickAnimAdd('shoot1', "Pico shoot 1");
				quickAnimAdd('shoot2', "Pico shoot 2");
				quickAnimAdd('shoot3', "Pico shoot 3");
				quickAnimAdd('shoot4', "Pico shoot 4");

				// here for now, will be replaced later for less copypaste
				loadOffsetFile(curCharacter);
				playAnim('shoot1');

				loadMappedAnims();

			case 'gf-tankmen':
				frames = Paths.getSparrowAtlas('characters/gfTankmen', 'shared');
				animation.addByIndices('sad', 'GF Crying at Gunpoint', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, true);
				animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile('gf');
				playAnim('danceRight');

			case 'bf-holding-gf':
				frames = Paths.getSparrowAtlas('characters/bfAndGF', 'shared');
				quickAnimAdd('idle', 'BF idle dance');
				quickAnimAdd('singDOWN', 'BF NOTE DOWN0');
				quickAnimAdd('singLEFT', 'BF NOTE LEFT0');
				quickAnimAdd('singRIGHT', 'BF NOTE RIGHT0');
				quickAnimAdd('singUP', 'BF NOTE UP0');

				quickAnimAdd('singDOWNmiss', 'BF NOTE DOWN MISS');
				quickAnimAdd('singLEFTmiss', 'BF NOTE LEFT MISS');
				quickAnimAdd('singRIGHTmiss', 'BF NOTE RIGHT MISS');
				quickAnimAdd('singUPmiss', 'BF NOTE UP MISS');
				quickAnimAdd('bfCatch', 'BF catches GF');

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;
			default:
				parseDataFile();
		}
		dance();

		if (isPlayer)
			flipX = !flipX;
	}

	public function loadMappedAnims()
	{
		var swagshit = Song.loadFromJson('picospeaker');

		var notes = swagshit.notes;

		for (section in notes)
		{
			for (idk in section.sectionNotes)
			{
				animationNotes.push(idk);
			}
		}

		TankmenBG.animationNotes = animationNotes;

		trace(animationNotes);
		animationNotes.sort(sortAnims);
	}

	inline function sortAnims(val1:Array<Dynamic>, val2:Array<Dynamic>):Int
		return FlxSort.byValues(FlxSort.ASCENDING, val1[0], val2[0]);

	inline function quickAnimAdd(name:String, prefix:String)
		animation.addByPrefix(name, prefix, 24, false);

	function loadOffsetFile(character:String)
	{
		var offsetStuffs:Array<String> = CoolUtil.coolTextFile(Paths.offsetFile(character));

		for (offsetframest in offsetStuffs)
		{
			var offsetInfo:Array<String> = offsetframest.split(' ');

			addOffset(offsetInfo[0], Std.parseFloat(offsetInfo[1]), Std.parseFloat(offsetInfo[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (animation == null || animation.curAnim == null)
		{
			super.update(elapsed);
			return;
		}
		if (!nativelyPlayable && !isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
				holdTimer += elapsed;

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}

			if (specialAnim && animation.finished)
			{
				specialAnim = false;
				dance();
			}
		}

		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
			case "pico-speaker":
				// for pico??
				if (animationNotes.length > 0)
				{
					if (Conductor.songPosition > animationNotes[0][0])
					{
						trace('played shoot anim' + animationNotes[0][1]);

						var shootAnim:Int = 1;

						if (animationNotes[0][1] >= 2)
							shootAnim = 3;

						shootAnim += FlxG.random.int(0, 1);

						playAnim('shoot' + shootAnim, true);
						animationNotes.shift();
					}
				}

				if (animation.curAnim.finished)
				{
					playAnim(animation.curAnim.name, false, false, animation.curAnim.numFrames - 3);
				}
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR DANCING SHIT
	 */
	inline function loadBoyfriend(flippedLol:Bool, nativePlay:Bool)
	{
		frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');

		animation.addByPrefix('idle', 'BF idle dance', 24, false);
		animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
		animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
		animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
		animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
		animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
		animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
		animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
		animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
		animation.addByPrefix('hey', 'BF HEY', 24, false);

		animation.addByPrefix('firstDeath', "BF dies", 24, false);
		animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
		animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);
		animation.addByPrefix('dodge', "boyfriend dodge", 24, false);
		animation.addByPrefix('scared', 'BF idle shaking', 24);
		animation.addByPrefix('hit', 'BF hit', 24, false);

		loadOffsetFile(curCharacter);

		skins.set('gfSkin', 'gf');

		barColor = FlxColor.fromRGB(49, 176, 209);

		playAnim('idle');

		if (nativePlay)
			nativelyPlayable = true;

		if (flippedLol)
			flipX = true;
	}

	public function dance()
	{
		if (!debugMode && canDance)
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-christmas':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-car':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					if (isDancing)
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
					else
					{
						if (!specialAnim)
						{
							playAnim('idle');
						}
					}
			}
		}
	}

	function parseDataFile()
	{
		// Load the data from JSON and cast it to a struct we can easily read.
		var jsonData = Paths.characterFile(curCharacter);
		if (jsonData == null)
		{
			trace('Failed to parse JSON data for character ${curCharacter}');
			return;
		}

		var data:CharacterData = cast jsonData;

		var tex:FlxAtlasFrames = Paths.getSparrowAtlas(data.asset, 'shared');
		frames = tex;

		// bro thought anim is null

		for (i in data.animations)
		{
			var frameRate = i.frameRate == null ? 24 : i.frameRate;
			var looped = i.looped == null ? false : i.looped;
			var flipX = i.flipX == null ? false : i.flipX;
			var flipY = i.flipY == null ? false : i.flipY;

			/*if (anim.frameIndices != null)
				{
					animation.addByIndices(anim.name, anim.prefix, anim.frameIndices, "", frameRate, looped, flipX, flipY);
				}
				else
				{ */
			animation.addByPrefix(i.name, i.prefix, frameRate, looped, flipX, flipY);
			//		}

			// animOffsets[anim.name] = anim.offsets == null ? [0, 0] : anim.offsets;
		}

		this.isDancing = data.isDancing == null ? false : data.isDancing;

		loadOffsetFile(curCharacter);

		flipX = data.flipX == null ? false : data.flipX;

		setGraphicSize(Std.int(width * (data.scale == null ? 1 : data.scale)));

		updateHitbox();

		antialiasing = data.antialiasing == null ? FlxG.save.data.antialiasing : data.antialiasing;

		globalOffset = data.globalPosition == null ? [0, 0] : data.globalPosition;
		nativelyPlayable = data.nativePlayable == null ? false : data.nativePlayable;

		barColor = FlxColor.fromString(data.barColor);

		playAnim(data.startingAnim);
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (animation.getByName(AnimName) == null)
			return; // why wasn't this a thing in the first place
		if ((AnimName.toLowerCase() == 'idle' || AnimName.toLowerCase().startsWith('dance')) && !canDance)
			return;
		if (AnimName.toLowerCase().startsWith('sing') && !canSing)
			return;

		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
			offset.set(daOffset[0] * offsetScale, daOffset[1] * offsetScale);
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
				danced = true;
			else if (AnimName == 'singRIGHT')
				danced = false;

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
				danced = !danced;
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function getColorCode(char:String):String
	{
		var returnedString:String = '';
		for (i in 0...charList.length)
		{
			var currentValue = charList[i].trim().split(':');
			if (currentValue[0] != char)
				continue;
			else
				returnedString = currentValue[2]; // this is the color code one
		}
		if (returnedString == '')
			return char;
		else
			return returnedString;
	}
}
