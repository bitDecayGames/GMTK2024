package entities;

import flixel.math.FlxPoint;
import flixel.FlxG;
import echo.shape.Circle;
import echo.Body;

using echo.FlxEcho;

// The reticle will have a hitbox, but it will act like a sensor so that we can
// change animation based on what it is hovering over. Otherwise, it shouldn't have much
// reason to interact with the game world, that I know of.
class Reticle extends Unibody {

    public function new() {
        super(0, 0);
        
		this.loadGraphic(AssetPaths.filler16__png, true, 16, 16);
    }

    override function makeBody():Body {
        return this.add_body({
			x: x,
			y: y,
			max_velocity_x: 1000,
			max_velocity_length: 1000,
			drag_x: 0,
			mass: 0,
            kinematic: true,
			shapes: [
				{
					type:CIRCLE,
                    radius: 8,
					offset_x: 8,
					offset_y: 8,
				}
			]
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        FlxG.mouse.getWorldPosition(tmp);
        body.set_position(tmp.x, tmp.y);
    }
}