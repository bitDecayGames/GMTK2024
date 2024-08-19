package entities;

import loaders.Aseprite;
import loaders.AsepriteMacros;
import echo.Body;

using echo.FlxEcho;

class DoorTop extends Unibody {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/doorTopHalf.json");

    public function new(x:Float, y:Float) {
        super(x, y);
		Aseprite.loadAllAnimations(this, AssetPaths.doorTopHalf__json);
		animation.frameIndex = 0;
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