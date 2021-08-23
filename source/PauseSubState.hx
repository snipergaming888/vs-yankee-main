package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Chart Editor', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var difficultyChoices:Array<String> = ['EASY', 'NORMAL', 'HARD', 'BACK'];

	public function new(x:Float, y:Float)
	{
		super();

		if (PlayState.isStoryMode) {
			if (PlayState.storyPlaylist.length != 1) {
				menuItems = ['Resume', 'Restart Song', 'Skip Song', 'Change Difficulty', 'Chart Editor', 'Exit to menu'];
			}
			else
				{
					menuItems = ['Resume', 'Restart Song', 'Change Difficulty', 'Chart Editor', 'Exit to menu'];
				}
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	function regenMenu():Void
		{
			for (i in 0...grpMenuShit.members.length)
				grpMenuShit.remove(grpMenuShit.members[0], true);
	
			for (i in 0...menuItems.length)
			{
				var item = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
				item.isMenuItem = true;
				item.targetY = i;
				grpMenuShit.add(item);
			}
	
			curSelected = 0;
			changeSelection();
		}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					FlxG.resetState();
				case "Exit to menu":
					PlayState.loadRep = false;
					if (PlayState.offsetTesting)
					{
						PlayState.offsetTesting = false;
						FlxG.switchState(new OptionsMenu());
					}
					else
						FlxG.switchState(new MainMenuState());
				case "Chart Editor":
					FlxG.switchState(new ChartingState());	
				case "Skip Song":
					PlayState.storyPlaylist.remove(PlayState.storyPlaylist[0]);

					var difficulty:String = "";

					if (PlayState.storyDifficulty == 0) {
						difficulty = '-easy';
					}

					if (PlayState.storyDifficulty == 2) {
						difficulty = '-hard';
					}

					trace('LOADING NEXT SONG');
					trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
					FlxG.sound.music.stop();
					LoadingState.loadAndSwitchState(new PlayState());
				case "Change Difficulty":
					menuItems = difficultyChoices;
					regenMenu();
				case "EASY" | "NORMAL" | "HARD":
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.SONG.song.toLowerCase(), curSelected),
						PlayState.SONG.song.toLowerCase());
					PlayState.storyDifficulty = curSelected;
					FlxG.resetState();
					trace('changing difficulty to' + curSelected);
				case "BACK":
					if (PlayState.isStoryMode)
						{
							if (PlayState.storyPlaylist.length != 1) {
								menuItems = ['Resume', 'Restart Song', 'Skip Song', 'Change Difficulty', 'Chart Editor', 'Exit to menu'];
								regenMenu();
							}
							else
								{
									menuItems = ['Resume', 'Restart Song', 'Change Difficulty', 'Chart Editor', 'Exit to menu'];
								}	
						}
						else
					menuItems = ['Resume', 'Restart Song', 'Change Difficulty', 'Chart Editor', 'Exit to menu'];
					regenMenu();
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
