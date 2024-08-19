package entities;

import js.html.Console;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import echo.Body;

using echo.FlxEcho;

class DoorTop extends Unibody {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/doorTopHalf.json");

	public var iid:String;
	public var name:String;

    public function new(iid:String, x:Float, y:Float, name:String) {
        super(x, y);
		this.iid = iid;
		this.name = name;
		Aseprite.loadAllAnimations(this, AssetPaths.doorTopHalf__json);
		animation.frameIndex = 0;

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
					height: 64,
				}
			]
		});
	}
}