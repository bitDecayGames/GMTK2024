package ui;

import input.SimpleController;
import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.FlxSprite;
import com.bitdecay.lucidtext.TypingGroup;
import com.bitdecay.lucidtext.TypeOptions;
import flixel.group.FlxGroup;

@:access(com.bitdecay.lucidtext.TypingGroup)
class CharacterDialog extends FlxGroup {
	private static var expressionsAsset = AssetPaths.headshots__png;

	public var textGroup:TypingGroup;
	public var portrait:FlxSprite;
	public var options:TypeOptions;

	public var faster = false;

	// for cleaner input handling
	public var skipOneUpdate = false;

	var portraitMargins:Array<Float> = [5, 5, 60, 5];
	var noPortraitMargins:Array<Float> = [5, 5, 5, 5];

	public function new(speaker:CharacterIndex, initialText:String) {
		super();

		options = new TypeOptions(AssetPaths.ninePatch__png, [16, 16, 16, 16], portraitMargins, 10);
		options.checkPageConfirm = (delta) -> {
			if (SimpleController.just_pressed(A)) {
				// we don't want their press to go to the next page to also start fast-forwarding the next page
				skipOneUpdate = true;
				return true;
			}

			return false;
		};
		options.nextIconMaker = () -> {
			var nextIcon = new FlxSprite();
			nextIcon.scrollFactor.set();
			nextIcon.loadGraphic(AssetPaths.nextIcon__png);
			// nextIcon.animation.add('spin', [0,1,2,3], 8);
			// nextIcon.animation.play('spin');
			return nextIcon;
		}

		textGroup = new TypingGroup(
			FlxRect.get(FlxG.width * 0.1, FlxG.height * .7, FlxG.width * .8, FlxG.height * .25),
			initialText,
			options
		);
		textGroup.scrollFactor.set();
		textGroup.letterCallback = () -> {
			// FmodManager.PlaySoundOneShot(FmodSFX.TypeWriterSingleStroke);
		};
		textGroup.pageCallback = () -> {
			skipOneUpdate = true;
			faster = false;
			textGroup.options.modOps.speedMultiplier = 1;
		}

		add(textGroup);

        portrait = new FlxSprite(textGroup.bounds.x + 5, textGroup.bounds.top + (textGroup.bounds.bottom - textGroup.bounds.top) / 2 - 24);
        portrait.scrollFactor.set();
        portrait.loadGraphic(expressionsAsset, true, 48, 48);
        portrait.animation.frameIndex = speaker;
        add(portrait);
	}

	public function loadDialogLine(text:String) {
		textGroup.loadText(text);
		skipOneUpdate = true;
	}

	public function resetLastLine() {
		// TODO: Obviously not efficient, but works for now
		textGroup.loadText(textGroup.rawText);
		skipOneUpdate = true;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (skipOneUpdate) {
			skipOneUpdate = false;
			return;
		}

		if (SimpleController.just_pressed(A) && !faster) {
			faster = true;
			textGroup.options.modOps.speedMultiplier = 3;
		}

		if (!SimpleController.pressed(A) && faster) {
			faster = false;
			textGroup.options.modOps.speedMultiplier = 1;
		}
	}
}