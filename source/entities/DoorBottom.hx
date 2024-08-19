package entities;

import loaders.Aseprite;
import loaders.AsepriteMacros;
import echo.Body;

using echo.FlxEcho;

class DoorBottom extends Unibody {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/doorBottomHalf.json");

	public var iid:String;
	public var name:String;

    public function new(iid:String, x:Float, y:Float, name:String) {
        super(x, y);
		this.iid = iid;
		this.name = name;
		Aseprite.loadAllAnimations(this, AssetPaths.doorBottomHalf__json);
		animation.frameIndex = 0;

		animation.callback = (name, frameNumber, frameIndex) -> {
			if (frameNumber == 3) {
				body.active = false;
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
					height: 160,
				}
			]
		});
	}
}