package entities;

import echo.data.Data.CollisionData;
import echo.Body;

using echo.FlxEcho;

class PracticeTarget extends Unibody {

    public var beenShot = false;

    public function new(x:Float, y:Float) {
        super(x, y);
        
		this.loadGraphic(AssetPaths.filler16__png, true, 16, 16);
    }

    override function makeBody():Body {
        return this.add_body({
			x: x,
			y: y,
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
    }

    override function handleEnter(other:Body, data:Array<CollisionData>) {
        super.handleEnter(other, data);

        if (other.object is Bullet) {
            other.object.kill();
            kill();
            FmodManager.PlaySoundOneShot(FmodSFX.TargetHit);
            // TODO: Play some animation? Explode? Something
            beenShot = true;
        }
    }
}