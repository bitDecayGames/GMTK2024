package entities;

import flixel.util.FlxTimer;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import echo.data.Data.CollisionData;
import echo.Body;

using echo.FlxEcho;

class PracticeTarget extends Unibody {

    public var beenShot = false;

    public static var anims = AsepriteMacros.tagNames("assets/aseprite/target.json");

    public function new(x:Float, y:Float) {
        super(x, y);
        
        Aseprite.loadAllAnimations(this, AssetPaths.target__json);
    }

    override function makeBody():Body {
        return this.add_body({
			x: x,
			y: y,
            kinematic: true,
			shapes: [
				{
					type:CIRCLE,
                    radius: 6
				}
			]
        });

        animation.finishCallback = (name) -> {
            if (name == anims.drop) {
                beenShot = true;
            }
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

    }

    override function handleEnter(other:Body, data:Array<CollisionData>) {
        super.handleEnter(other, data);

        if (other.object is Bullet) {
            other.object.kill();
            body.active = false;
            FmodManager.PlaySoundOneShot(FmodSFX.TargetHit2);
            animation.play(anims.drop);
            new FlxTimer().start(0.2, (t) -> {
                beenShot = true;
            });
        }
    }
}