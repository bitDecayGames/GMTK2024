package entities;

import echo.data.Data.CollisionData;
import echo.Body;
import flixel.math.FlxPoint;
import loaders.AsepriteMacros;
import loaders.Aseprite;

using echo.FlxEcho;

class GroundFire extends Unibody {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/flame.json");

    public function new(x:Float, y:Float) {
        super(x, y);

        Aseprite.loadAllAnimations(this, AssetPaths.flame__json);
        animation.play(anims.burn, -1);
    }

	override function handleEnter(other:Body, data:Array<CollisionData>) {
		super.handleEnter(other, data);

		if (other.object is Player) {
            var p:Player = cast other.object;
            p.takeDamage(this);
			p.hitByFireCount++;
		}
	}

	override function makeBody():Body {
		return this.add_body({
			x: x-8,
			y: y-8,
            kinematic: true,
			shapes: [
				{
					type:RECT,
					width: 16,
					height: 16,
					offset_y: 8,
				}
			]
		});
	}
}