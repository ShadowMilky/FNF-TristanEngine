package;

import flixel.addons.transition.Transition;
import flixel.group.FlxGroup;
import Section.SwagSection;
import Song.SwagSong;
#if HSCRIPT_ALLOWED
import HScriptTool.Script;
#end
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import openfl.utils.Assets;
import flixel.math.FlxAngle;
import flixel.util.FlxDestroyUtil;
#if VIDEOS_ALLOWED
#if (hxCodec >= "3.0.0")
import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec == "2.6.1")
import hxcodec.VideoHandler;
#elseif (hxCodec == "2.6.0")
import VideoHandler;
#else
import vlc.MP4Handler as VideoHandler;
#end
#end
#if desktop
import Discord.DiscordClient;
#end

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;

	public static var curStage:String = '';
	public static var characteroverride:String = "none";
	public static var formoverride:String = "none";
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public var dadGroup:FlxGroup;
	public var bfGroup:FlxGroup;
	public var gfGroup:FlxGroup;

	public static var curmult:Array<Float> = [1, 1, 1, 1];

	var focusOnDadGlobal:Bool = true;
	var fastCarCanDrive:Bool = true;

	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";

	public var vocals:FlxSound;

	private var dad:Character;
	private var dadmirror:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	private var strumLine:FlxSprite;
	private var strumLineNotes:FlxTypedGroup<StrumNote>;

	public var playerStrums:FlxTypedGroup<StrumNote>;
	public var dadStrums:FlxTypedGroup<StrumNote>;

	public var camZooming:Bool = false;

	private var gfSpeed:Int = 1;

	public var health:Float = 1;

	private var combo:Int = 0;

	public static var misses:Int = 0;

	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;

	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;

	private var camDialogue:FlxCamera;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;
	private var camTransition:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	final pixelStages:Array<String> = ['school', 'schoolEvil']; // da pixel stages
	final specialStages:Array<String> = ['limo', 'mall', 'mallEvil']; // da custom bg stages

	public var hasDialogue:Bool = false;

	final notestuffs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	var songScore:Int = 0;

	var curLight:Int = 0;
	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var gfCutsceneLayer:FlxGroup;
	var bfTankCutsceneLayer:FlxGroup;
	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;

	var scoreTxt:FlxText;
	var botplayTxt:FlxText;
	var engineWatermark:FlxText;
	var songName:FlxText;

	var allNotesMs:Float = 0;
	var averageMs:Float = 0;

	var msTimeTxt:FlxText;
	var msTimeTxtTween:FlxTween;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	var inCutscene:Bool = false;

	public var backgroundSprites:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	public var subtitleManager:SubtitleManager;

	var revertedBG:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var possibleNotes:Array<Note> = [];

	var tweenList:Array<FlxTween> = new Array<FlxTween>();

	var tweenTime:Float;

	var songPosBar:FlxBar;
	var songPosBG:FlxSprite;

	var bfNoteCamOffset:Array<Float> = new Array<Float>();
	var dadNoteCamOffset:Array<Float> = new Array<Float>();

	#if VIDEOS_ALLOWED
	var video:VideoHandler;
	#end

	var scriptThing:Dynamic;

	public static var canRunScript:Bool = false;

	public static var scrollType:String = '';

	var stageCheck:String = 'stage';

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;

	var foregroundSprites:FlxTypedGroup<BGSprite>;

	override public function create()
	{
		instance = this;

		paused = false;
		scrollType = FlxG.save.data.downscroll ? 'downscroll' : 'upscroll';

		theFunne = FlxG.save.data.newInput;
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		misses = 0;

		curStage = "";

		initDiscord();

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camDialogue = new FlxCamera();
		camDialogue.bgColor.alpha = 0;
		camTransition = new FlxCamera();
		camTransition.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);
		FlxG.cameras.add(camDialogue, false);
		FlxG.cameras.add(camTransition, false);

		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		persistentUpdate = persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('test');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		// DIALOGUE STUFF
		// Hi guys i know yall are gonna try to add more dialogue here, but with this new system, all you have to do is add a dialogue file with the name of the song in the assets/data/dialogue folder,
		// and it will automatically get the dialogue in this function
		if (Assets.exists(Paths.txt('dialogue/${SONG.song.toLowerCase()}')))
		{
			try
			{
				dialogue = CoolUtil.coolTextFile(Paths.txt('dialogue/${SONG.song.toLowerCase()}'));
				hasDialogue = true;
			}
			catch (e)
			{
				hasDialogue = false;
			}
		}
		else
			hasDialogue = false;

		if (SONG.stage == null)
		{
			switch (SONG.song.toLowerCase())
			{
				case 'bopeebo' | 'fresh' | 'dad-battle':
					stageCheck = 'stage';
				case 'spookeez' | 'south' | 'monster':
					stageCheck = 'spooky';
				case 'pico' | 'philly' | 'blammed':
					stageCheck = 'philly';
				case 'satin-panties' | 'high' | 'milf':
					stageCheck = 'limo';
				case 'cocoa' | 'eggnog':
					stageCheck = 'mall';
				case 'winter-horrorland':
					stageCheck = 'mallEvil';
				case 'senpai' | 'roses':
					stageCheck = 'school';
				case 'thorns':
					stageCheck = 'schoolEvil';
				case 'ugh' | 'guns' | 'stress':
					stageCheck = 'tank';
				default:
					stageCheck = 'stage';
			}
		}
		else
			stageCheck = SONG.stage;

		backgroundSprites = createBackgroundSprites(stageCheck, false);

		var gfVersion:String = 'gf';

		if (SONG.gf != null)
		{
			gfVersion = SONG.gf;
		}
		if (formoverride == "bf-pixel" || SONG.player1 == "bf-pixel" && pixelStages.contains(curStage))
		{
			gfVersion = 'gf-pixel';
		}

		gfGroup = new FlxGroup();
		dadGroup = new FlxGroup();
		bfGroup = new FlxGroup();

		switch (stageCheck)
		{
			default:
				add(gfGroup);
				// Shitty layering but whatev it works LOL
				if (curStage == 'limo')
					add(limo);
				add(dadGroup);
				add(bfGroup);
		}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		switch (gfVersion)
		{
			case 'pico-speaker':
				gf.x -= 50;
				gf.y -= 200;

				var tempTankman:TankmenBG = new TankmenBG(20, 500, true);
				tempTankman.strumTime = 10;
				tempTankman.resetShit(20, 600, true);
				tankmanRun.add(tempTankman);

				for (i in 0...TankmenBG.animationNotes.length)
				{
					if (FlxG.random.bool(16))
					{
						var tankman:TankmenBG = tankmanRun.recycle(TankmenBG);
						// new TankmenBG(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
						tankman.strumTime = TankmenBG.animationNotes[i][0];
						tankman.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
						tankmanRun.add(tankman);
					}
				}
		}

		if (gfVersion == 'gf-none')
			gf.visible = false;

		dad = new Character(100, 100, SONG.player2);

		for (tween in tweenList)
			tween.active = false;

		var camPos:FlxPoint = FlxPoint.get(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			// DONT USE THIS TO SET CHARACTER POSITIONS, DO THAT IN CHARACTER/GLOBALOFFSET INSTEAD!!!!
			// USE THIS TO FIX CAMERA STUFF
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}
		}

		if (formoverride == "none" || formoverride == "bf" && pixelStages.contains(curStage) || formoverride == "bf" && specialStages.contains(curStage)
			|| formoverride == SONG.player1)
			boyfriend = new Boyfriend(770, 450, SONG.player1);
		else
			boyfriend = new Boyfriend(770, 450, formoverride);

		repositionCharStages();

		gfGroup.add(gf);
		dadGroup.add(dad);
		if (dadmirror != null)
			dadGroup.add(dadmirror);

		bfGroup.add(boyfriend);

		add(foregroundSprites);

		var doof:DialogueBox = new DialogueBox(false, dialogue, isStoryMode);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (scrollType == 'downscroll')
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

		final noteSplash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(noteSplash);
		noteSplash.alpha = 0.00001;
		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<StrumNote>();

		dadStrums = new FlxTypedGroup<StrumNote>();

		generateSong();

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		camPos.put();
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		// char repositioning
		repositionChar(dad);
		if (dadmirror != null)
		{
			repositionChar(dadmirror);
		}
		repositionChar(boyfriend);
		repositionChar(gf);

		if (FlxG.save.data.songPosition)
		{
			final yPos = scrollType == 'downscroll' ? FlxG.height * 0.9 + 20 : strumLine.y - 20;

			songPosBG = new FlxSprite(0, yPos).loadGraphic(Paths.image('ui/timerBar'));
			songPosBG.antialiasing = true;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), Conductor,
				'songPosition', 0, FlxG.sound.music.length);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.fromRGB(57, 255, 20));
			insert(members.indexOf(songPosBG), songPosBar);

			songName = new FlxText(songPosBG.x, songPosBG.y, 0, "0:00", 32);
			songName.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			songName.borderSize = 2.5;
			songName.antialiasing = true;
			songName.visible = false;

			final xValues = CoolUtil.getMinAndMax(songName.width, songPosBG.width);
			final yValues = CoolUtil.getMinAndMax(songName.height, songPosBG.height);

			songName.x = songPosBG.x - ((xValues[0] - xValues[1]) / 2);
			songName.y = songPosBG.y + ((yValues[0] - yValues[1]) / 2);

			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}

		var healthBarPath = switch (SONG.song.toLowerCase())
		{
			default:
				Paths.image('ui/healthBar');
		}

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(healthBarPath);
		if (scrollType == 'downscroll')
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = true;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(dad.barColor, boyfriend.barColor);
		insert(members.indexOf(healthBarBG), healthBar);

		engineWatermark = new FlxText(4, healthBarBG.y + 50, 0, SONG.song + " | Tristan " + MainMenuState.engineVer, 16);

		engineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		engineWatermark.scrollFactor.set();
		engineWatermark.borderSize = 1.25;
		engineWatermark.antialiasing = true;
		add(engineWatermark);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 150, healthBarBG.y + 40, FlxG.width, "", 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.5;
		scoreTxt.antialiasing = true;
		scoreTxt.screenCenter(X);
		add(scoreTxt);

		msTimeTxt = new FlxText(0, 0, 400, "", 32);
		msTimeTxt.setFormat(Paths.font('vcr.ttf'), 32, 0xFF3517E0, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		msTimeTxt.scrollFactor.set();
		msTimeTxt.alpha = 0;
		msTimeTxt.visible = true;
		msTimeTxt.borderSize = 2;
		add(msTimeTxt);

		botplayTxt = new FlxText(400, songPosBG.y + 55, FlxG.width - 800, "BOTPLAY", 32);
		botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botplayTxt.scrollFactor.set();
		botplayTxt.borderSize = 2;
		botplayTxt.visible = FlxG.save.data.botplay;
		add(botplayTxt);
		if (scrollType == 'downscroll')
		{
			botplayTxt.y = songPosBG.y - 78;
		}

		iconP1 = new HealthIcon((formoverride == "none" || formoverride == "bf") ? SONG.player1 : formoverride, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		msTimeTxt.cameras = [camHUD];
		botplayTxt.cameras = [camHUD];
		if (engineWatermark != null)
			engineWatermark.cameras = [camHUD];
		doof.cameras = [camDialogue];

		#if HSCRIPT_ALLOWED
		if (Assets.exists(Paths.scriptFile(SONG.song.toLowerCase())))
		{
			try
			{
				scriptThing = HScriptTool.create(Paths.scriptFile(SONG.song.toLowerCase()));
				canRunScript = true;
			}
			catch (e)
			{
				scriptThing = null;
				canRunScript = false;
			}
		}
		else
		{
			scriptThing = null;
			canRunScript = false;
		}

		if (scriptThing != null && canRunScript)
		{
			scriptThing.setVariable("create", function()
			{
			});
			scriptThing.setVariable("update", function(elapsed:Float)
			{
			});
			scriptThing.setVariable("beatHit", function(curBeat:Int)
			{
			});
			scriptThing.setVariable("stepHit", function(curStep:Int)
			{
			});
			scriptThing.setVariable("PlayState", this);
			scriptThing.setVariable("StringTools", StringTools);
			scriptThing.setVariable("Character", Character);
			scriptThing.setVariable("dad", dad);
			scriptThing.setVariable("gf", gf);
			scriptThing.setVariable("bf", boyfriend);
			scriptThing.setVariable("PlatformUtil", PlatformUtil);
			scriptThing.setVariable("FlxTween", FlxTween); // I personally would not remove flxtween.
			scriptThing.setVariable("FlxEase", FlxEase);
			scriptThing.setVariable("FlxSprite", FlxSprite);
			scriptThing.setVariable("Math", Math);
			scriptThing.setVariable("FlxG", FlxG);
			scriptThing.setVariable("FlxTimer", FlxTimer);
			scriptThing.setVariable("Main", Main);
			scriptThing.setVariable("Conductor", Conductor);
			scriptThing.setVariable("Std", Std);
			scriptThing.setVariable("FlxG", FlxG);
			scriptThing.setVariable("FlxTextBorderStyle", FlxTextBorderStyle);
			scriptThing.setVariable("Paths", Paths);
			scriptThing.setVariable("Alphabet", Alphabet);
			scriptThing.setVariable("curStep", curStep);
			scriptThing.setVariable("curBeat", curBeat);
			scriptThing.setVariable("bpm", SONG.bpm);
			scriptThing.setVariable("goodNoteHit", function(note:Note)
			{
				goodNoteHit(note);
			});

			scriptThing.setVariable("fromRGB", function(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255)
			{
				return FlxColor.fromRGB(Red, Green, Blue, Alpha);
			});

			scriptThing.loadFile();

			scriptThing.executeFunc("create");
		}
		#end

		startingSong = true;

		if (startTimer != null && !startTimer.active)
		{
			startTimer.active = true;
		}
		if (isStoryMode)
		{
			if (hasDialogue)
			{
				schoolIntro(doof);
			}
			else
			{
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
				startCountdown();
			}
		}
		else
		{
			switch (SONG.song.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		subtitleManager = new SubtitleManager();
		subtitleManager.cameras = [camHUD];
		add(subtitleManager);

		super.create();

		Transition.nextCamera = camTransition;
	}

	public function createBackgroundSprites(bgName:String, revertedBG:Bool):FlxTypedGroup<FlxSprite>
	{
		var sprites:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
		var bgZoom:Float = 1.05;
		var stageName:String = '';
		switch (bgName)
		{
			case 'spooky':
				stageName = 'spooky';

				var hallowTex = Paths.getSparrowAtlas('stages/spooky/halloween_bg');

				halloweenBG = new FlxSprite(-200, -100);
				halloweenBG.frames = hallowTex;
				halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
				halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
				halloweenBG.animation.play('idle');
				halloweenBG.antialiasing = true;
				sprites.add(halloweenBG);
				add(halloweenBG);

				isHalloween = true;
			case 'philly':
				stageName = 'philly';

				var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('stages/philly/sky'));
				bg.scrollFactor.set(0.1, 0.1);
				sprites.add(bg);
				add(bg);

				var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('stages/philly/city'));
				city.scrollFactor.set(0.3, 0.3);
				city.setGraphicSize(Std.int(city.width * 0.85));
				city.updateHitbox();
				sprites.add(city);
				add(city);

				phillyCityLights = new FlxTypedGroup<FlxSprite>();
				add(phillyCityLights);

				for (i in 0...5)
				{
					var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('stages/philly/win' + i));
					light.scrollFactor.set(0.3, 0.3);
					light.visible = false;
					light.setGraphicSize(Std.int(light.width * 0.85));
					light.updateHitbox();
					light.antialiasing = true;
					phillyCityLights.add(light);
				}

				var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('stages/philly/behindTrain'));
				sprites.add(streetBehind);
				add(streetBehind);

				phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('stages/philly/train'));
				sprites.add(phillyTrain);
				add(phillyTrain);

				trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
				FlxG.sound.list.add(trainSound);

				var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('stages/philly/street'));
				sprites.add(street);
				add(street);

				street.antialiasing = true;
				streetBehind.antialiasing = true;
				phillyTrain.antialiasing = true;
			case 'limo':
				stageName = 'limo';
				bgZoom = 0.9;

				var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('stages/limo/limoSunset'));
				skyBG.scrollFactor.set(0.1, 0.1);
				sprites.add(skyBG);
				add(skyBG);

				var bgLimo:FlxSprite = new FlxSprite(-200, 480);
				bgLimo.frames = Paths.getSparrowAtlas('stages/limo/bgLimo');
				bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
				bgLimo.animation.play('drive');
				bgLimo.scrollFactor.set(0.4, 0.4);
				sprites.add(bgLimo);
				add(bgLimo);

				grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
				add(grpLimoDancers);

				for (i in 0...5)
				{
					var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
					dancer.scrollFactor.set(0.4, 0.4);
					grpLimoDancers.add(dancer);
				}

				var limoTex = Paths.getSparrowAtlas('stages/limo/limoDrive');

				limo = new FlxSprite(-120, 550);
				limo.frames = limoTex;
				limo.animation.addByPrefix('drive', "Limo stage", 24);
				limo.animation.play('drive');
				limo.antialiasing = true;

				fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('stages/limo/fastCarLol'));
			case 'mall':
				stageName = 'mall';
				bgZoom = 0.8;

				var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('stages/christmas/bgWalls'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				sprites.add(bg);
				add(bg);

				upperBoppers = new FlxSprite(-240, -90);
				upperBoppers.frames = Paths.getSparrowAtlas('stages/christmas/upperBop');
				upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
				upperBoppers.antialiasing = true;
				upperBoppers.scrollFactor.set(0.33, 0.33);
				upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
				upperBoppers.updateHitbox();
				sprites.add(upperBoppers);
				add(upperBoppers);

				var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('stages/christmas/bgEscalator'));
				bgEscalator.antialiasing = true;
				bgEscalator.scrollFactor.set(0.3, 0.3);
				bgEscalator.active = false;
				bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
				bgEscalator.updateHitbox();
				sprites.add(bgEscalator);
				add(bgEscalator);

				var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('stages/christmas/christmasTree'));
				tree.antialiasing = true;
				tree.scrollFactor.set(0.40, 0.40);
				sprites.add(tree);
				add(tree);

				bottomBoppers = new FlxSprite(-300, 140);
				bottomBoppers.frames = Paths.getSparrowAtlas('stages/christmas/bottomBop');
				bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
				bottomBoppers.antialiasing = true;
				bottomBoppers.scrollFactor.set(0.9, 0.9);
				bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
				bottomBoppers.updateHitbox();
				sprites.add(bottomBoppers);
				add(bottomBoppers);

				var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('stages/christmas/fgSnow'));
				fgSnow.active = false;
				fgSnow.antialiasing = true;
				sprites.add(fgSnow);
				add(fgSnow);

				santa = new FlxSprite(-840, 150);
				santa.frames = Paths.getSparrowAtlas('stages/christmas/santa');
				santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
				santa.antialiasing = true;
				sprites.add(santa);
				add(santa);
			case 'mallEvil':
				stageName = 'mallEvil';
				bgZoom = 0.8;

				var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('stages/christmas/evilBG'));
				bg.antialiasing = true;
				bg.scrollFactor.set(0.2, 0.2);
				bg.active = false;
				bg.setGraphicSize(Std.int(bg.width * 0.8));
				bg.updateHitbox();
				sprites.add(bg);
				add(bg);

				var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('stages/christmas/evilTree'));
				evilTree.antialiasing = true;
				evilTree.scrollFactor.set(0.2, 0.2);
				sprites.add(evilTree);
				add(evilTree);

				var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("stages/christmas/evilSnow"));
				evilSnow.antialiasing = true;
				sprites.add(evilSnow);
				add(evilSnow);
			case 'school':
				stageName = 'school';

				var bgSky = new FlxSprite().loadGraphic(Paths.image('stages/weeb/weebSky'));
				bgSky.scrollFactor.set(0.1, 0.1);
				sprites.add(bgSky);
				add(bgSky);

				var repositionShit = -200;

				var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('stages/weeb/weebSchool'));
				bgSchool.scrollFactor.set(0.6, 0.90);
				sprites.add(bgSchool);
				add(bgSchool);

				var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('stages/weeb/weebStreet'));
				bgStreet.scrollFactor.set(0.95, 0.95);
				sprites.add(bgStreet);
				add(bgStreet);

				var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('stages/weeb/weebTreesBack'));
				fgTrees.scrollFactor.set(0.9, 0.9);
				sprites.add(fgTrees);
				add(fgTrees);

				var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
				var treetex = Paths.getPackerAtlas('stages/weeb/weebTrees');
				bgTrees.frames = treetex;
				bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
				bgTrees.animation.play('treeLoop');
				bgTrees.scrollFactor.set(0.85, 0.85);
				sprites.add(bgTrees);
				add(bgTrees);

				var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
				treeLeaves.frames = Paths.getSparrowAtlas('stages/weeb/petals');
				treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
				treeLeaves.animation.play('leaves');
				treeLeaves.scrollFactor.set(0.85, 0.85);
				sprites.add(treeLeaves);
				add(treeLeaves);

				var widShit = Std.int(bgSky.width * 6);

				bgSky.setGraphicSize(widShit);
				bgSchool.setGraphicSize(widShit);
				bgStreet.setGraphicSize(widShit);
				bgTrees.setGraphicSize(Std.int(widShit * 1.4));
				fgTrees.setGraphicSize(Std.int(widShit * 0.8));
				treeLeaves.setGraphicSize(widShit);

				fgTrees.updateHitbox();
				bgSky.updateHitbox();
				bgSchool.updateHitbox();
				bgStreet.updateHitbox();
				bgTrees.updateHitbox();
				treeLeaves.updateHitbox();

				bgGirls = new BackgroundGirls(-100, 190);
				bgGirls.scrollFactor.set(0.9, 0.9);

				if (SONG.song.toLowerCase() == 'roses')
				{
					bgGirls.getScared();
				}

				bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
				bgGirls.updateHitbox();
				sprites.add(bgGirls);
				add(bgGirls);
			case 'schoolEvil':
				stageName = 'schoolEvil';

				var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
				var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

				var posX = 400;
				var posY = 200;

				var bg:FlxSprite = new FlxSprite(posX, posY);
				bg.frames = Paths.getSparrowAtlas('stages/weeb/animatedEvilSchool');
				bg.animation.addByPrefix('idle', 'background 2', 24);
				bg.animation.play('idle');
				bg.scrollFactor.set(0.8, 0.9);
				bg.scale.set(6, 6);
				sprites.add(bg);
				add(bg);
			case 'tank':
				defaultCamZoom = 0.90;
				curStage = 'tank';

				var bg:BGSprite = new BGSprite('tankSky', -400, -400, Paths.image('stages/tank/tankSky'), null, 0, 0);
				add(bg);

				var tankSky:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20),
					Paths.image('stages/tank/tankClouds'), null, 0.1, 0.1);
				tankSky.active = true;
				tankSky.velocity.x = FlxG.random.float(5, 15);
				add(tankSky);

				var tankMountains:BGSprite = new BGSprite('tankMountains', -300, -20, Paths.image('stages/tank/tankMountains'), null, 0.2, 0.2);
				tankMountains.setGraphicSize(Std.int(tankMountains.width * 1.2));
				tankMountains.updateHitbox();
				add(tankMountains);

				var tankBuildings:BGSprite = new BGSprite('tankBuildings', -200, 0, Paths.image('stages/tank/tankBuildings'), null, 0.30, 0.30);
				tankBuildings.setGraphicSize(Std.int(tankBuildings.width * 1.1));
				tankBuildings.updateHitbox();
				add(tankBuildings);

				var tankRuins:BGSprite = new BGSprite('tankRuins', -200, 0, Paths.image('stages/tank/tankRuins'), null, 0.35, 0.35);
				tankRuins.setGraphicSize(Std.int(tankRuins.width * 1.1));
				tankRuins.updateHitbox();
				add(tankRuins);

				var smokeLeft:BGSprite = new BGSprite('smokeLeft', -200, -100, Paths.image('stages/tank/smokeLeft'), {
					name: 'SmokeBlurLeft',
					prefixName: 'SmokeBlurLeft instance',
					frames: 24,
					looped: true
				}, 0.4, 0.4);
				add(smokeLeft);

				var smokeRight:BGSprite = new BGSprite('smokeRight', 1100, -100, Paths.image('stages/tank/smokeLeft'), {
					name: 'SmokeRight',
					prefixName: 'SmokeRight instance',
					frames: 24,
					looped: true
				}, 0.4, 0.4);
				add(smokeRight);

				// tankGround.

				tankWatchtower = new BGSprite('tankWatchtower', 100, 50, Paths.image('stages/tank/tankWatchtower'), {
					name: 'tankWatchtower',
					prefixName: 'watchtower gradient color instance',
					frames: 24,
					looped: false
				}, 0.5, 0.5);
				add(tankWatchtower);

				tankGround = new BGSprite('tankRolling', 300, 300, Paths.image('stages/tank/tankWatchtower'), {
					name: 'tankRolling',
					prefixName: 'BG tank w lighting',
					frames: 24,
					looped: true
				}, 0.5, 0.5);
				add(tankGround);
				// tankGround.active = false;

				tankmanRun = new FlxTypedGroup<TankmenBG>();
				add(tankmanRun);

				var tankGround:BGSprite = new BGSprite('tankGround', -420, -150, Paths.image('stages/tank/tankGround'), null);
				tankGround.setGraphicSize(Std.int(tankGround.width * 1.15));
				tankGround.updateHitbox();
				add(tankGround);

				moveTank();

				// smokeLeft.screenCenter();

				var fgTank0:BGSprite = new BGSprite('tank0', -500, 650, Paths.image('stages/tank/tank0'), {
					name: 'tank0',
					prefixName: 'fg',
					frames: 24,
					looped: false
				}, 1.7, 1.5);
				foregroundSprites.add(fgTank0);

				var fgTank1:BGSprite = new BGSprite('tank1', -300, 750, Paths.image('stages/tank/tank1'), {
					name: 'tank1',
					prefixName: 'fg',
					frames: 24,
					looped: false
				}, 2, 0.2);
				foregroundSprites.add(fgTank1);

				// just called 'foreground' just cuz small inconsistency no bbiggei
				var fgTank2:BGSprite = new BGSprite('tank2', 450, 940, Paths.image('stages/tank/tank2'), {
					name: 'tank2',
					prefixName: 'foreground',
					frames: 24,
					looped: false
				}, 1.5, 1.5);
				foregroundSprites.add(fgTank2);

				var fgTank3:BGSprite = new BGSprite('tank3', 1300, 1200, Paths.image('stages/tank/tank3'), {
					name: 'tank3',
					prefixName: 'fg',
					frames: 24,
					looped: false
				}, 3.5, 2.5);
				foregroundSprites.add(fgTank3);

				var fgTank4:BGSprite = new BGSprite('tank4', 1300, 900, Paths.image('stages/tank/tank4'), {
					name: 'tank4',
					prefixName: 'fg',
					frames: 24,
					looped: false
				}, 1.5, 1.5);
				foregroundSprites.add(fgTank4);

				var fgTank5:BGSprite = new BGSprite('tank5', 1620, 700, Paths.image('stages/tank/tank5'), {
					name: 'tank5',
					prefixName: 'fg',
					frames: 24,
					looped: false
				}, 1.5, 1.5);
				foregroundSprites.add(fgTank5);
			default:
				bgZoom = 0.9;
				stageName = 'stage';

				var bg:BGSprite = new BGSprite('bg', -600, -200, Paths.image('stages/stage/stageback'), null, 0.9, 0.9);
				sprites.add(bg);
				add(bg);

				var stageFront:BGSprite = new BGSprite('stageFront', -650, 600, Paths.image('stages/stage/stagefront'), null, 0.9, 0.9);
				stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
				stageFront.updateHitbox();
				sprites.add(stageFront);
				add(stageFront);

				var stageCurtains:BGSprite = new BGSprite('stageCurtains', -500, -300, Paths.image('stages/stage/stagecurtains'), null, 1.3, 1.3);
				stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
				stageCurtains.updateHitbox();
				sprites.add(stageCurtains);
				add(stageCurtains);
		}
		if (!revertedBG)
		{
			defaultCamZoom = bgZoom;
			curStage = stageName;
		}

		return sprites;
	}

	inline function initDiscord():Void
	{
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyString();

		// To avoid having duplicate images in Discord assets
		switch (SONG.player2)
		{
			default:
				iconRPC = 'none';
		}

		if (isStoryMode)
			detailsText = "Story Mode: Week " + storyWeek;
		else
			detailsText = "Freeplay Mode: ";

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	function schoolIntro(?dialogueBox:DialogueBox, isStart:Bool = true):Void
	{
		inCutscene = true;
		camFollow.setPosition(boyfriend.getGraphicMidpoint().x - 200, dad.getGraphicMidpoint().y - 10);
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var stupidBasics:Float = 1;
		if (isStart)
		{
			FlxTween.tween(black, {alpha: 0}, stupidBasics);
		}
		else
		{
			black.alpha = 0;
			stupidBasics = 0;
		}
		new FlxTimer().start(stupidBasics, function(fuckingSussy:FlxTimer)
		{
			if (dialogueBox != null)
				add(dialogueBox);
			else
				startCountdown();
		});
	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);

		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;
		var swagCounter:Int = 0;

		if (FlxG.save.data.msText)
		{
			if (scrollType == 'downscroll')
			{
				msTimeTxt.x = playerStrums.members[1].x - 100;
				msTimeTxt.y = playerStrums.members[1].y + 100;
			}
			else
			{
				msTimeTxt.x = playerStrums.members[1].x - 100;
				msTimeTxt.y = playerStrums.members[1].y - 50;
			}
		}

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			// this just based on beatHit stuff but compact
			if (swagCounter % gfSpeed == 0)
				gf.dance();
			if (swagCounter % 2 == 0)
			{
				if (!boyfriend.animation.curAnim.name.startsWith("sing"))
					boyfriend.playAnim('idle');
				if (!dad.animation.curAnim.name.startsWith("sing"))
					dad.dance();
				else if (dadmirror != null && !dadmirror.animation.curAnim.name.startsWith("sing"))
					dadmirror.dance();
			}
			else if (dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			var introSoundAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			var soundAssetsAlt:Array<String> = new Array<String>();

			introAssets.set('default', ['ui/ready', "ui/set", "ui/go"]);

			introSoundAssets.set('default', ['default/intro3', 'default/intro2', 'default/intro1', 'default/introGo']);
			introSoundAssets.set('pixel', [
				'pixel/intro3-pixel',
				'pixel/intro2-pixel',
				'pixel/intro1-pixel',
				'pixel/introGo-pixel'
			]);

			switch (SONG.song.toLowerCase())
			{
				default:
					soundAssetsAlt = introSoundAssets.get('default');
			}

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('introSounds/' + soundAssetsAlt[0]), 0.6);
					focusOnDadGlobal = false;
					ZoomCam(false);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();
					ready.antialiasing = true;

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introSounds/' + soundAssetsAlt[1]), 0.6);
					focusOnDadGlobal = true;
					ZoomCam(true);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					set.screenCenter();

					set.antialiasing = true;
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introSounds/' + soundAssetsAlt[2]), 0.6);
					focusOnDadGlobal = false;
					ZoomCam(false);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					go.updateHitbox();

					go.screenCenter();

					go.antialiasing = true;
					add(go);

					var sex:Float = 1000;

					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / sex, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introSounds/' + soundAssetsAlt[3]), 0.6);

					focusOnDadGlobal = true;
					ZoomCam(true);
					if (songName != null)
					{
						songName.visible = true;
					}
			}

			swagCounter += 1;
		}, 4);
	}

	function playCutscene(name:String)
	{
		inCutscene = true;
		FlxG.sound.music.stop();

		#if VIDEOS_ALLOWED
		video = new VideoHandler();
		#if (hxCodec < "3.0.0")
		video.finishCallback = () ->
		{
			switch (SONG.song.toLowerCase())
			{
				default:
					startCountdown();
			}
		}
		video.playVideo(Paths.video(name));
		#else
		video.play(Paths.video(name));
		video.onEndReached.add(() ->
		{
			video.dispose();
			switch (SONG.song.toLowerCase())
			{
				default:
					startCountdown();
			}
			return;
		});
		#end
		#else
		return;
		#end
	}

	function playEndCutscene(name:String)
	{
		inCutscene = true;

		#if VIDEOS_ALLOWED
		video = new VideoHandler();
		#if (hxCodec < "3.0.0")
		video.finishCallback = () -> LoadingState.loadAndSwitchState(new PlayState());
		video.playVideo(Paths.video(name));
		#else
		video.play(Paths.video(name));
		video.onEndReached.add(() -> LoadingState.loadAndSwitchState(new PlayState()));
		#end
		#else
		return;
		#end
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
			vocals.play();
		}
		for (tween in tweenList)
			tween.active = true;

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
		FlxG.sound.music.onComplete = endSong;
		if (songPosBar != null)
			songPosBar.setRange(0, FlxG.sound.music.length);
	}

	private function generateSong():Void
	{
		Conductor.changeBPM(SONG.bpm);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song, ""));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = SONG.notes;

		for (section in noteData)
		{
			var sectionCount = noteData.indexOf(section);

			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var OGNoteDat = daNoteData;
				var daNoteStyle:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, gottaHitNote, daNoteStyle, false);
				swagNote.originalType = OGNoteDat;
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true,
						gottaHitNote, daNoteStyle, false);
					sustainNote.originalType = OGNoteDat;
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
				}

				swagNote.mustPress = gottaHitNote;
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	inline function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int, regenerate:Bool = false):Void
	{
		final note_order:Array<Int> = [0, 1, 2, 3];
		for (i in 0...4)
		{
			var arrowType:Int = note_order[i];
			var strumType:String = '';
			var babyArrow:StrumNote = new StrumNote(0, strumLine.y, strumType, arrowType, player == 1);

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			babyArrow.x += Note.swagWidth * Math.abs(i);
			babyArrow.x += 78 + 78 / 4;
			babyArrow.x += ((FlxG.width / 2) * player);

			babyArrow.baseX = babyArrow.x;
			if (player == 1)
				playerStrums.add(babyArrow);
			else
				dadStrums.add(babyArrow);

			strumLineNotes.add(babyArrow);
		}
	}

	inline function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.sineInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				@:privateAccess { // This is so hiding the debugger doesn't play the music again
					FlxG.sound.music._alreadyPaused = true;
					vocals._alreadyPaused = true;
				}
			}
			if (tweenList != null && tweenList.length != 0)
			{
				for (tween in tweenList)
				{
					if (!tween.finished)
					{
						tween.active = false;
					}
				}
			}

			#if desktop
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") |",
				"Acc: "
				+ truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (startTimer != null && !startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (startTimer != null && !startTimer.finished)
				startTimer.active = true;

			if (tweenList != null && tweenList.length != 0)
			{
				for (tween in tweenList)
				{
					if (!tween.finished)
					{
						tween.active = true;
					}
				}
			}
			paused = false;

			if (startTimer != null && startTimer.finished)
			{
				#if desktop
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") ",
					"\nAcc: "
					+ truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					FlxG.sound.music.length
					- Conductor.songPosition);
				#end
			}
			else
			{
				#if desktop
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") ", iconRPC);
				#end
			}
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	public static var paused:Bool = false;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	inline function truncateFloat(number:Float, precision:Int):Float
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round(num) / Math.pow(10, precision);
		return num;
	}

	override public function update(elapsed:Float)
	{
		#if HSCRIPT_ALLOWED
		if (scriptThing != null && canRunScript)
			scriptThing.executeFunc("update", [elapsed]);
		#end

		if (songName != null)
			songName.text = FlxStringUtil.formatTime((FlxG.sound.music.length - FlxG.sound.music.time) / 1000);

		if (startingSong && startTimer != null && !startTimer.active)
			startTimer.active = true;

		if (paused && FlxG.sound.music != null && vocals != null && vocals.playing)
		{
			FlxG.sound.music.pause();
			vocals.pause();
			@:privateAccess { // This is so hiding the debugger doesn't play the music again
				FlxG.sound.music._alreadyPaused = true;
				vocals._alreadyPaused = true;
			}
		}

		if (tweenList != null && tweenList.length != 0)
		{
			for (tween in tweenList)
			{
				if (tween.active && !tween.finished)
					tween.percent = FlxG.sound.music.time / tweenTime;
			}
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
			case 'tank':
				moveTank();
		}

		super.update(elapsed);

		switch (SONG.song.toLowerCase())
		{
			default:
				if (FlxG.save.data.accuracyDisplay)
					{
						scoreTxt.text = LanguageManager.getTextString('play_score') + Std.string(songScore) + " | " + LanguageManager.getTextString('play_miss')
						+ misses + " | " + LanguageManager.getTextString('play_accuracy') + truncateFloat(accuracy, 2) + "%";
					}
					else
					{
						scoreTxt.text = LanguageManager.getTextString('play_score') + Std.string(songScore) ;
					}
		}
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
			{
				playerStrums.forEach((note:StrumNote) -> FlxTween.completeTweensOf(note));
				dadStrums.forEach((note:StrumNote) -> FlxTween.completeTweensOf(note));
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			if (FlxTransitionableState.skipNextTransIn)
				Transition.nextCamera = null;

			switch (SONG.song.toLowerCase())
			{
				default:
					FlxG.switchState(new ChartingState());
					#if desktop
					DiscordClient.changePresence("Chart Editor", null, null, true);
					#end
			}
		}

		final thingy = 0.88;

		iconP1.centerOffsets();
		iconP2.centerOffsets();

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		final iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.changeState('losing');
		else
			iconP1.changeState('normal');

		if (healthBar.percent > 80)
			iconP2.changeState('losing');
		else
			iconP2.changeState('normal');

		// #if debug
		if (FlxG.keys.justPressed.FOUR)
		{
			trace('DUMP LOL:\nDAD POSITION: ${dad.getPosition()}\nBOYFRIEND POSITION: ${boyfriend.getPosition()}\nGF POSITION: ${gf.getPosition()}\nCAMERA POSITION: ${camFollow.getPosition()}');
		}
		if (FlxG.keys.justPressed.FIVE)
		{
			FlxG.switchState(new CharacterDebug(dad.curCharacter));
		}
		if (FlxG.keys.justPressed.SEMICOLON)
		{
			FlxG.switchState(new CharacterDebug(boyfriend.curCharacter));
		}
		if (FlxG.keys.justPressed.COMMA)
		{
			FlxG.switchState(new CharacterDebug(gf.curCharacter));
		}
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new CharEditingState(dad.curCharacter));
		if (FlxG.keys.justPressed.SIX)
			FlxG.switchState(new CharEditingState(boyfriend.curCharacter));
		if (FlxG.keys.justPressed.TWO) // Go 10 seconds into the future :O
		{
			FlxG.sound.music.pause();
			vocals.pause();
			boyfriend.stunned = true;
			Conductor.songPosition += 10000;
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.strumTime + 800 < Conductor.songPosition)
				{
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
			for (i in 0...unspawnNotes.length)
			{
				var daNote:Note = unspawnNotes.shift();
				if (daNote.strumTime + 800 >= Conductor.songPosition)
					break;

				daNote.destroy();
			}

			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();

			vocals.time = Conductor.songPosition;
			vocals.play();
			boyfriend.stunned = false;
		}
		if (FlxG.keys.justPressed.THREE)
			FlxG.switchState(new CharEditingState(gf.curCharacter));
		// #end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
				{
					startSong();
				}
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0)
		{
			boyfriend.stunned = true;

			persistentUpdate = persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();
			gameOver();
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes.shift();
				dunceNote.finishedGenerating = true;

				notes.add(dunceNote);
			}
		}
		var currentSection = SONG.notes[Math.floor(curStep / 16)];

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
					daNote.active = daNote.visible = false;
				else
					daNote.visible = daNote.active = true;

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (currentSection != null)
					{
						if (currentSection.altAnim || daNote.noteStyle == 'alt-animation')
						{
							altAnim = '-alt';

							if (!daNote.mustPress)
							{
								dad.specialAnim = true;

								if (dadmirror != null)
									dadmirror.specialAnim = true;
							}
							else
								boyfriend.specialAnim = true;
						}
					}

					var noteToPlay:String = notestuffs[Math.round(Math.abs(daNote.originalType)) % 4];
					switch (daNote.noteStyle)
					{
						default:
							if (dad.nativelyPlayable)
							{
								switch (noteToPlay)
								{
									case 'LEFT':
										noteToPlay = 'RIGHT';
									case 'RIGHT':
										noteToPlay = 'LEFT';
								}
							}
							dad.playAnim('sing' + noteToPlay + altAnim, true);
							if (dadmirror != null)
							{
								dadmirror.playAnim('sing' + noteToPlay + altAnim, true);
							}
					}
					cameraMoveOnNote(daNote.originalType, 'dad');

					dadStrums.forEach(function(sprite:StrumNote)
					{
						if (Math.abs(Math.round(Math.abs(daNote.noteData)) % 4) == sprite.ID)
						{
							sprite.animation.play('confirm', true);
							if (sprite.animation.curAnim.name == 'confirm')
							{
								sprite.centerOffsets();
								sprite.offset.x -= 13;
								sprite.offset.y -= 13;
							}
							else
								sprite.centerOffsets();

							sprite.animation.finishCallback = name ->
							{
								sprite.animation.play('static', true);
								sprite.centerOffsets();
							}
						}
					});

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					notes.remove(daNote, true);
					daNote.destroy();
				}
				switch (SONG.song.toLowerCase())
				{
					default:
						daNote.y = yFromNoteStrumTime(daNote, strumLine, scrollType == 'downscroll');
				}
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));
				var noteSpeed = (daNote.LocalScrollSpeed == 0 ? 1 : daNote.LocalScrollSpeed);

				if (daNote.wasGoodHit && daNote.isSustainNote && Conductor.songPosition >= (daNote.strumTime + 10))
					destroyNote(daNote);

				if (!daNote.wasGoodHit
					&& daNote.mustPress
					&& daNote.finishedGenerating
					&& Conductor.songPosition >= daNote.strumTime + (350 / (0.45 * FlxMath.roundDecimal(SONG.speed * noteSpeed, 2))))
				{
					noteMiss(daNote.originalType);

					vocals.volume = 0;

					destroyNote(daNote);
				}
			});
		}

		ZoomCam(focusOnDadGlobal);

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function destroyNote(note:Note)
	{
		scriptThing.executeFunc("destroyNote", [note]);
		notes.remove(note, true);
		note.destroy();
	}

	function yFromNoteStrumTime(note:Note, strumLine:FlxSprite, downScroll:Bool):Float
	{
		var change = downScroll ? -1 : 1;
		var speed:Float = SONG.speed;
		var val:Float = strumLine.y - (Conductor.songPosition - note.strumTime) * (change * 0.45 * FlxMath.roundDecimal(speed * note.LocalScrollSpeed, 2));
		if (note.isSustainNote && downScroll && note.animation != null)
		{
			if (note.animation.curAnim.name.endsWith('end'))
			{
				val += (note.height * speed);
			}
		}
		return val;
	}

	function ZoomCam(focusondad:Bool):Void
	{
		var bfplaying:Bool = false;
		if (focusondad)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (!bfplaying && daNote.mustPress)
					bfplaying = true;
			});
		}
		if (focusondad)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

			switch (dad.curCharacter)
			{
				case 'mom':
					camFollow.y = dad.getMidpoint().y;
				case 'senpai':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
				case 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
			}

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				tweenCamIn();
			}

			bfNoteCamOffset[0] = 0;
			bfNoteCamOffset[1] = 0;

			camFollow.x += dadNoteCamOffset[0];
			camFollow.y += dadNoteCamOffset[1];
		}
		else
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			dadNoteCamOffset[0] = 0;
			dadNoteCamOffset[1] = 0;

			camFollow.x += bfNoteCamOffset[0];
			camFollow.y += bfNoteCamOffset[1];

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.sineInOut});
			}
		}
	}

	function endSong():Void
	{
		inCutscene = canPause = false;

		scriptThing.executeFunc("endSong");

		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.save.flush();

		Highscore.saveScore(SONG.song, songScore, storyDifficulty, characteroverride == "none"
			|| characteroverride == "bf" ? "bf" : characteroverride);

		if (isStoryMode)
		{
			campaignScore += songScore;

			var completedSongs:Array<String> = [];
			var allSongsCompleted:Bool = true;
			if (FlxG.save.data.songsCompleted == null)
			{
				FlxG.save.data.songsCompleted = new Array<String>();
			}
			completedSongs = FlxG.save.data.songsCompleted;
			completedSongs.push(storyPlaylist[0]);
			FlxG.save.data.songsCompleted = completedSongs;
			FlxG.save.flush();

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				if (FlxTransitionableState.skipNextTransIn)
				{
					Transition.nextCamera = null;
				}
				switch (SONG.song.toLowerCase())
				{
					default:
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						FlxG.switchState(new StoryMenuState());
				}
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				Highscore.saveWeekScore(storyWeek, campaignScore,
					storyDifficulty, characteroverride == "none" || characteroverride == "bf" ? "bf" : characteroverride);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				switch (SONG.song.toLowerCase())
				{
					default:
						nextSong();
				}
			}
		}
		else
		{
			switch (SONG.song.toLowerCase())
			{
				default:
					FlxG.switchState(new FreeplayState());
			}
			if (FlxTransitionableState.skipNextTransIn)
			{
				Transition.nextCamera = null;
			}
		}
	}

	function nextSong()
	{
		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;
		prevCamFollow = camFollow;

		PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0]);
		FlxG.sound.music.stop();

		switch (SONG.song.toLowerCase())
		{
			default:
				LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	public function createScorePopUp(daX:Float, daY:Float, autoPos:Bool, daRating:String, daCombo:Int, daStyle:String):Void
	{
		if (daStyle.length <= 0)
			daStyle = '';

		var assetPath:String = switch (daStyle)
		{
			case 'pixel': 'pixel/';
			default: '';
		}

		// assetPath is for week6
		var rating = new FlxSprite().loadGraphic(Paths.image("ui/" + assetPath + daRating));
		if (rating.graphic == null)
		{
			rating.loadGraphic(Paths.image("ui/" + daRating));
			trace("Rating image not found in " + (Paths.image('ui/$assetPath')));
		}
		rating.screenCenter();
		rating.x = autoPos ? FlxG.width * 0.55 : daX - 40;
		rating.y -= 60;
		if (FlxG.save.data.changedHit)
		{
			rating.x = FlxG.save.data.changedHitX;
			rating.y = FlxG.save.data.changedHitY;
		}
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ui/" + assetPath + "combo"));
		if (comboSpr.graphic == null)
		{
			comboSpr.loadGraphic(Paths.image("ui/combo"));
			trace("Combo image not found in " + (Paths.image('ui/$assetPath')));
		}
		comboSpr.screenCenter();
		comboSpr.x = autoPos ? FlxG.width * 0.55 : daX;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);
		if (combo >= 10)
			add(comboSpr);

		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.antialiasing = true;
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.antialiasing = true;

		comboSpr.updateHitbox();
		rating.updateHitbox();

		comboSpr.cameras = [camHUD];
		rating.cameras = [camHUD];

		var seperatedScore:Array<Int> = [];

		var comboSplit:Array<String> = (daCombo + "").split('');

		if (comboSplit.length == 2)
			seperatedScore.push(0); // make sure theres a 0 in front or it looks weird lol!

		for (i in 0...comboSplit.length)
		{
			var str:String = comboSplit[i];
			seperatedScore.push(Std.parseInt(str));
		}

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image("ui/" + assetPath + "num" + Std.int(i)));
			if (numScore.graphic == null)
			{
				numScore.loadGraphic(Paths.image("ui/num" + Std.int(i)));
				trace("Number images not found in " + (Paths.image('ui/$assetPath')));
			}
			numScore.screenCenter();
			numScore.x = autoPos ? FlxG.width * 0.55 + (43 * daLoop) - 90 : daX + (43 * daLoop) - 90;
			numScore.y += 80;

			numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (daCombo >= 10)
				add(numScore);

			numScore.cameras = [camHUD];

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});
	}

	private function popUpScore(strumtime:Float, note:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);

		allNotesMs += noteDiff;
		averageMs = allNotesMs / totalNotesHit;
		if (FlxG.save.data.msText)
		{
			msTimeTxt.alpha = 1;
			msTimeTxt.text = Std.string(Math.round(noteDiff)) + "ms";
			if (msTimeTxtTween != null)
			{
				msTimeTxtTween.cancel();
				msTimeTxtTween.destroy(); // top 10 awesome code
			}
			msTimeTxtTween = FlxTween.tween(msTimeTxt, {alpha: 0}, 0.25, {
				onComplete: function(tw:FlxTween)
				{
					msTimeTxtTween = null;
				},
				startDelay: 0.7
			});
		}

		vocals.volume = 1;

		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 2)
		{
			daRating = 'shit';
			totalNotesHit -= 2;
			score = 10;
			shits++;
		}
		else if (noteDiff < Conductor.safeZoneOffset * -2)
		{
			daRating = 'shit';
			totalNotesHit -= 2;
			score = 25;
			shits++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.45)
		{
			daRating = 'bad';
			score = 100;
			totalNotesHit += 0.2;
			bads++;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.25)
		{
			daRating = 'good';
			totalNotesHit += 0.65;
			score = 200;
			goods++;
		}
		if (daRating == 'sick')
		{
			totalNotesHit += 1;
			sicks++;
		}
		score = Std.int(FlxMath.roundDecimal(score * curmult[note.noteData], 0));

		songScore += score;

		if (daRating == 'sick')
		{
			var noteSplash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			noteSplash.setupNoteSplash(note.x, note.y, note.noteData);
			grpNoteSplashes.add(noteSplash);
		}

		createScorePopUp(0, 0, true, daRating, combo, '');
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	private function keyShit():Void
	{
		// HOLDING
		var up = controls.UP;
		var right = controls.RIGHT;
		var down = controls.DOWN;
		var left = controls.LEFT;

		var upP = controls.UP_P;
		var rightP = controls.RIGHT_P;
		var downP = controls.DOWN_P;
		var leftP = controls.LEFT_P;

		var upR = controls.UP_R;
		var rightR = controls.RIGHT_R;
		var downR = controls.DOWN_R;
		var leftR = controls.LEFT_R;

		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var releaseArray:Array<Bool> = [leftR, downR, upR, rightR];

		if (FlxG.save.data.botplay)
		{
			var BOTPLAY_pressed_anything = false;

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.finishedGenerating)
				{
					if (daNote.strumTime <= Conductor.songPosition)
					{
						BOTPLAY_pressed_anything = true;
						if (!daNote.isSustainNote)
						{
							controlArray[daNote.noteData % 4] = true;
							switch (daNote.noteData % 4)
							{
								case 0:
									leftP = true;
								case 1:
									downP = true;
								case 2:
									upP = true;
								case 3:
									rightP = true;
							}
						}
						switch (daNote.noteData % 4)
						{
							case 0:
								left = true;
							case 1:
								down = true;
							case 2:
								up = true;
							case 3:
								right = true;
						}
					}
				}
			});
			if (!BOTPLAY_pressed_anything)
				for (e in releaseArray)
					e = true;
		}

		if ((upP || rightP || downP || leftP) && !boyfriend.stunned && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			possibleNotes = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isSustainNote && daNote.finishedGenerating)
				{
					possibleNotes.push(daNote);
				}
			});

			haxe.ds.ArraySort.sort(possibleNotes, function(a, b):Int
			{
				var notetypecompare:Int = Std.int(a.noteData - b.noteData);

				if (notetypecompare == 0)
					return Std.int(a.strumTime - b.strumTime);

				return notetypecompare;
			});

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				// Jump notes
				var lasthitnote:Int = -1;
				var lasthitnotetime:Float = -1;

				for (note in possibleNotes)
				{
					if (!note.mustPress)
						continue;

					if (controlArray[note.noteData % 4])
					{
						if (lasthitnotetime > Conductor.songPosition - Conductor.safeZoneOffset
							&& lasthitnotetime < Conductor.songPosition +
							(Conductor.safeZoneOffset * 0.07)) // reduce the past allowed barrier just so notes close together that aren't jacks dont cause missed inputs
						{
							if ((note.noteData % 4) == (lasthitnote % 4))
							{
								lasthitnotetime = -999999; // reset the last hit note time
								continue; // the jacks are too close together
							}
						}
						lasthitnote = note.noteData;
						lasthitnotetime = note.strumTime;
						goodNoteHit(note);
					}
				}

				if (daNote.wasGoodHit)
				{
					notes.remove(daNote, true);
					daNote.destroy();
				}
			}
			else
			{
				for (shit in 0...controlArray.length)
				{
					if (controlArray[shit] && !theFunne && !inCutscene)
					{
						noteMiss(shit);
						updateAccuracy();
					}
				}
			}
		}

		if ((up || right || down || left) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{
					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 2:
							if (up || upHold)
								goodNoteHit(daNote);
						case 3:
							if (right || rightHold)
								goodNoteHit(daNote);
						case 1:
							if (down || downHold)
								goodNoteHit(daNote);
						case 0:
							if (left || leftHold)
								goodNoteHit(daNote);
					}
				}
			});
		}

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !up && !down && !right && !left)
		{
			if ((boyfriend.animation.curAnim.name.startsWith('sing')) && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idle');

				bfNoteCamOffset[0] = 0;
				bfNoteCamOffset[1] = 0;
			}
		}

		playerStrums.forEach(function(spr:StrumNote)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
			{
				spr.animation.play('pressed');
			}
			if (releaseArray[spr.ID])
			{
				spr.animation.play('static');
			}

			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (true)
		{
			misses++;
			health -= 0.04;

			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			songScore -= 100;

			var deathSound:FlxSound = new FlxSound();
			switch (SONG.song.toLowerCase())
			{
				default:
					deathSound.loadEmbedded(Paths.soundRandom('missnote', 1, 3));
			}
			deathSound.volume = FlxG.random.float(0.1, 0.2);
			deathSound.play();

			var noteToPlay:String = notestuffs[Math.round(Math.abs(direction)) % 4];
			if (!boyfriend.nativelyPlayable)
			{
				switch (noteToPlay)
				{
					case 'LEFT':
						noteToPlay = 'RIGHT';
					case 'RIGHT':
						noteToPlay = 'LEFT';
				}
			}
			if (boyfriend.animation.getByName('sing${noteToPlay}miss') != null)
			{
				boyfriend.playAnim('sing' + noteToPlay + "miss", true);
			}
			else
			{
				boyfriend.color = 0xFF000084;
				boyfriend.playAnim('sing' + noteToPlay, true);
			}
			updateAccuracy();
		}
	}

	function cameraMoveOnNote(note:Int, character:String)
	{
		var amount:Array<Float> = new Array<Float>();
		var followAmount:Float = FlxG.save.data.noteCamera ? 20 : 0;
		switch (note)
		{
			case 0:
				amount[0] = -followAmount;
				amount[1] = 0;
			case 1:
				amount[0] = 0;
				amount[1] = followAmount;
			case 2:
				amount[0] = 0;
				amount[1] = -followAmount;
			case 3:
				amount[0] = followAmount;
				amount[1] = 0;
		}
		switch (character)
		{
			case 'dad':
				dadNoteCamOffset = amount;
			case 'bf':
				bfNoteCamOffset = amount;
		}
	}

	inline final function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
	}

	function goodNoteHit(note:Note):Void
	{
		scriptThing.executeFunc("goodNoteHit", [note]);

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				if (FlxG.save.data.donoteclick)
				{
					FlxG.sound.play(Paths.sound('note_click'));
				}
				combo++;
			}
			else
				totalNotesHit += 1;

			health += 0.023;

			switch (note.noteStyle)
			{
				default:
					var fuckingDumbassBullshitFuckYou:String;
					fuckingDumbassBullshitFuckYou = notestuffs[Math.round(Math.abs(note.originalType)) % 4];
					if (!boyfriend.nativelyPlayable)
					{
						switch (notestuffs[Math.round(Math.abs(note.originalType)) % 4])
						{
							case 'LEFT':
								fuckingDumbassBullshitFuckYou = 'RIGHT';
							case 'RIGHT':
								fuckingDumbassBullshitFuckYou = 'LEFT';
						}
					}
					boyfriend.playAnim('sing' + fuckingDumbassBullshitFuckYou, true);
			}
			cameraMoveOnNote(note.originalType, 'bf');

			playerStrums.forEach(function(spr:StrumNote)
			{
				if (Math.abs(note.noteData) == spr.ID)
					spr.animation.play('confirm', true);
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			notes.remove(note, true);
			note.destroy();

			updateAccuracy();
		}
	}

	override function stepHit()
	{
		super.stepHit();

		#if HSCRIPT_ALLOWED
		if (scriptThing != null && canRunScript)
			scriptThing.executeFunc("stepHit", [curStep]);
		#end

		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
			resyncVocals();

		switch (SONG.song.toLowerCase())
		{
			case 'ugh':
				switch (curStep)
				{
					case 60 | 444 | 524 | 828:
						FlxTween.tween(camGame, {zoom: 1.3}, 0.5, {
							ease: FlxEase.quadInOut,
							onComplete: function(tween)
							{
								FlxTween.tween(camGame, {zoom: defaultCamZoom}, 0.5, {ease: FlxEase.quadInOut});
							}
						});
						subtitleManager.addSubtitle(LanguageManager.getTextString('ugh'), 0.02, 1);
				}
		}

		#if desktop
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"Acc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			FlxG.sound.music.length
			- Conductor.songPosition);
		#end
	}

	override function beatHit()
	{
		super.beatHit();

		#if HSCRIPT_ALLOWED
		if (scriptThing != null && canRunScript)
			scriptThing.executeFunc("beatHit", [curBeat]);
		#end

		var currentSection = SONG.notes[Std.int(curStep / 16)];
		if (generatedMusic && currentSection != null)
		{
			focusOnDadGlobal = !currentSection.mustHitSection;
			ZoomCam(!currentSection.mustHitSection);
		}
		if (generatedMusic)
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);

		if (currentSection != null)
		{
			if (currentSection.changeBPM)
			{
				Conductor.changeBPM(currentSection.bpm);
				FlxG.log.add('CHANGED BPM!');
			}
		}

		if (curBeat % 2 == 0)
		{
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
				boyfriend.playAnim('idle');
			if (!dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();
			else if (dadmirror != null && !dadmirror.animation.curAnim.name.startsWith("sing"))
				dadmirror.dance();
		}
		else if (dad.curCharacter == 'spooky')
		{
			if (!dad.animation.curAnim.name.startsWith("sing"))
				dad.dance();
		}

		if (SONG.song.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}
		if (camZooming && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		if (curBeat % 8 == 7 && SONG.song == 'Bopeebo')
			boyfriend.playAnim('hey', true);

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		foregroundSprites.forEach(spr -> spr.dance());

		if (curBeat % gfSpeed == 0)
		{
			curBeat % (gfSpeed * 2) == 0 ? {
				iconP1.scale.set(1.1, 0.8);
				iconP2.scale.set(1.1, 1.3);

				FlxTween.angle(iconP1, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP2, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
			} : {
				iconP1.scale.set(1.1, 1.3);
				iconP2.scale.set(1.1, 0.8);

				FlxTween.angle(iconP2, -15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				FlxTween.angle(iconP1, 15, 0, Conductor.crochet / 1300 * gfSpeed, {ease: FlxEase.quadOut});
				}

			FlxTween.tween(iconP1, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});
			FlxTween.tween(iconP2, {'scale.x': 1, 'scale.y': 1}, Conductor.crochet / 1250 * gfSpeed, {ease: FlxEase.quadOut});

			iconP1.updateHitbox();
			iconP2.updateHitbox();
		}

		if (curBeat % gfSpeed == 0)
			gf.dance();

		switch (curStage)
		{
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8 && !trainSound.playing)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	override function destroy()
	{
		instance = null;
		if (scriptThing != null)
			scriptThing = null;
		canRunScript = false;

		grpNoteSplashes = FlxDestroyUtil.destroy(grpNoteSplashes);

		super.destroy();
	}

	function gameOver()
	{
		var deathSkinCheck = formoverride == "bf" || formoverride == "none" ? SONG.player1 : formoverride;

		openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, deathSkinCheck));

		#if desktop
		DiscordClient.changePresence("GAME OVER -- "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") ",
			"\nAcc: "
			+ truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	public function repositionChar(char:Character)
	{
		char.x += char.globalOffset[0];
		char.y += char.globalOffset[1];
	}

	public function repositionCharStages()
	{
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;

			case 'schoolEvil':
				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				add(evilTrail);
		}
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	function resetFastCar()
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function moveTank():Void
	{
		if (!inCutscene)
		{
			var daAngleOffset:Float = 1;
			tankAngle += FlxG.elapsed * tankSpeed;
			tankGround.angle = tankAngle - 90 + 15;

			tankGround.x = tankX + Math.cos(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1500;
			tankGround.y = 1300 + Math.sin(FlxAngle.asRadians((tankAngle * daAngleOffset) + 180)) * 1100;
		}
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	final tankSpeed:Float = FlxG.random.float(5, 7);
	final tankX:Float = 400;

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		boyfriend.animation.finishCallback = s -> boyfriend.dance();

		gf.playAnim('scared', true);
		gf.animation.finishCallback = s -> gf.dance();
	}
}
