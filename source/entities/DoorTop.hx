package entities;

import flixel.FlxG;
import js.html.Console;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import echo.Body;

using echo.FlxEcho;

class DoorTop extends Unibody {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/doorTopHalf.json");

	public var name:String;

    public function new(x:Float, y:Float, name:String) {
        super(x, y);
		this.name = name;
		Aseprite.loadAllAnimations(this, AssetPaths.doorTopHalf__json);
		animation.frameIndex = 0;

		animation.callback = (name, frameNumber, frameIndex) -> {
			if (frameNumber == 5)  {
                FlxG.camera.shake(0.05, 0.1);
			}
		}

		animation.finishCallback = (name) -> {
			if (name == anims.open) {
				body.active = false;
			}
		}
    }

	public function open() {
		animation.play(anims.open);
		FmodManager.PlaySoundOneShot(FmodSFX.DoorOpen2);
	}
    
	override function makeBody():Body {
		return this.add_body({
			x: x,
			y: y,
			mass: 100,
            kinematic: true,
			shapes: [
				{
					type:RECT,
					width: 32,
					height: 64,
				}
			]
		});
	}
}