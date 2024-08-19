package entities;

import flixel.FlxG;
import loaders.AsepriteMacros;
import loaders.Aseprite;
import flixel.FlxSprite;

class Shutter extends FlxSprite {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/shutter.json");

    public function new(x:Float, y:Float) {
        super(x, y);
        Aseprite.loadAllAnimations(this, AssetPaths.shutter__json);

		animation.callback = (name, frameNumber, frameIndex) -> {
			if (frameNumber == 4)  {
                FlxG.camera.shake(0.05, 0.1);
			}
		}
    }

    public function close() {
		// TODO: SFX close shutter sound
        animation.play(anims.close);
    }
}