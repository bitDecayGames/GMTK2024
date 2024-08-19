package entities;

import entities.Player.GunHas;
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

	var spangleDegs:Float;

	var lifespan = 5.0;

    public function new(type:GunHas, source:FlxPoint, angle:Float, speed:Float) {
        super(source.x, source.y);

        var direction = new FlxPoint(1, 0);

        direction.rotateByDegrees(angle);
        this.speed = speed;
        direction.scale(speed);

		body.rotation = angle;
        
        body.velocity.set(direction.x, direction.y);

        //origin.set(offsetX, offsetY);
        this.drawfset.copyFrom(drawfset);
		switch(type) {
            case HANDS:
            case PISTOL:
				loadGraphic(AssetPaths.pistolBullet__png);
            case MAGNUM:
				loadGraphic(AssetPaths.magnumBullet__png);
            case SHOTTY:
				loadGraphic(AssetPaths.shottyBullet__png);
            case ROCKET:
				loadGraphic(AssetPaths.glBullet__png);
				// TODO: Rocket should explode for visual oomph
        }
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
			rotation: spangleDegs,
			max_velocity_x: 1000,
			max_velocity_length: 1000,
			drag_x: 0,
			mass: 100,
			shapes: [
				{
					type:CIRCLE,
					radius: 8,
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