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

	public var bottom:DoorBottom = null;

	public var lastForced = false;

    public function new(iid:String, x:Float, y:Float, name:String) {
        super(x, y);
		this.iid = iid;
		this.name = name;
		Aseprite.loadAllAnimations(this, AssetPaths.doorTopHalf__json);
		animation.frameIndex = 0;

		animation.callback = (name, frameNumber, frameIndex) -> {
			if (frameNumber == 3) {
				body.active = false;
			}
			if (frameIndex == 1) {
				body.active = true;
			}
			if (frameNumber == 5)  {
				if (!lastForced) {
                	FlxG.camera.shake(0.025, 0.2);
				}
			}
		}

		// animation.finishCallback = (name) -> {
		// 	if (name == anims.open) {
		// 	}
		// }
    }

	public function open(force:Bool = false) {
		lastForced = force;
		if (bottom != null) {
			bottom.open(force);
		}
		animation.play(anims.open);

		if (!force) {
			FmodManager.PlaySoundOneShot(FmodSFX.DoorOpen2);
		}
	}
	
	public function close() {
		if (bottom != null) {
			bottom.close();
		}
		animation.play(anims.close);
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