package entities;

import echo.data.Data.CollisionData;
import echo.Body;
import flixel.math.FlxPoint;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import flixel.FlxSprite;

using echo.FlxEcho;

class Bullet extends Unibody {

    var parent:FlxSprite;
    var drawfset = FlxPoint.get();

	var lifespan = 5.0;

    public function new(source:FlxPoint, angle:Float, speed:Float) {
        super(source.x, source.y);

        var direction = new FlxPoint(1, 0);

        direction.rotateByDegrees(angle);
        this.speed = speed;
        direction.scale(speed);

        
        body.velocity.set(direction.x, direction.y);

        //origin.set(offsetX, offsetY);
        this.drawfset.copyFrom(drawfset);
		loadGraphic(AssetPaths.magnumBullet__png);
		centerOrigin();
    }

	override function handleEnter(other:Body, data:Array<CollisionData>) {
		super.handleEnter(other, data);

		// if (other.object is BasicBullet) {
		// 	FmodManager.PlaySoundOneShot(FmodSFX.EnemyAlienDeath);
		// 	animation.play(anims.Death);
		// 	body.active = false;
		// }
	}

	override function makeBody():Body {
		return this.add_body({
			x: x,
			y: y,
			max_velocity_x: 1000,
			max_velocity_length: 1000,
			drag_x: 0,
			mass: 100,
			shapes: [
				// Standard moving hitbox
				{
					type:RECT,
					width: 16,
					height: 16,
					offset_y: 8,
				}
			]
		});
	}

    override function update(elapsed:Float) {
        super.update(elapsed);

		lifespan -= elapsed;
		if (lifespan <= 0) {
			// likely need to do some pooling eventually so that we can reuse these bodies
			kill();
		}
    }
    
    override function draw() {
        super.draw();
    }
}