package entities;

import echo.Body;
import loaders.AsepriteMacros;
import loaders.Aseprite;
import flixel.math.FlxPoint;

using echo.FlxEcho;

class SpinningCan extends Bullet {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/spinningCan.json");

    public function new(start:FlxPoint, angle:Float, speed:Float) {
        super(HANDS, start, angle, speed);

        Aseprite.loadAllAnimations(this, AssetPaths.spinningCan__json);
        animation.play(anims.spinning_can);
    }

	override function makeBody():Body {
		return this.add_body({
			x: x,
			y: y,
			rotation: spangleDegs,
			max_velocity_x: 1000,
			max_velocity_length: 1000,
			drag_x: 0,
			mass: 100,
			shapes: [
				{
					type:CIRCLE,
					radius: 1,
				}
			]
		});
	}
}