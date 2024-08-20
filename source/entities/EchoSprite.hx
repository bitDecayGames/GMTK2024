package entities;


import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.FlxObject;
import echo.Body;
import flixel.FlxSprite;
import echo.data.Data.CollisionData;

using echo.FlxEcho;

class EchoSprite extends FlxSprite {
	public var body:Body;


    public var forceFollow:FlxObject = null;

	@:access(echo.FlxEcho)
	public function new(X:Float, Y:Float) {
		super(X, Y);

		pixelPerfectPosition = true;
		configSprite();
		body = makeBody();

		// XXX: We want to force position and rotation immediately
		if (body != null) {
			body.update_body_object();
		}
	}

	override function kill() {
		super.kill();
		if (body != null) {
			body.active = false;
			this.remove_object(true);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

        if (forceFollow != null) {
            body.set_position(forceFollow.x, forceFollow.y);
        }
	}

    public function doPath(points:Array<FlxPoint>, doneFn:() -> Void) {
        forceFollow = new FlxObject();
        FlxTween.quadPath(forceFollow, points, 100, false, {
            onComplete: (t) -> {
                forceFollow.destroy();
                forceFollow = null;
                if (doneFn != null) {
                    doneFn();
                }
            }
        });
    }

	public function configSprite() {}

	public function makeBody():Body {
		return null;
	}

	public function handleEnter(other:Body, data:Array<CollisionData>) {

	}

	public function handleTerrainHit(other:Body, data:Array<CollisionData>) {

	}

	public function handleStay(other:Body, data:Array<CollisionData>) {

	}

	public function handleExit(other:Body) {
		
	}
}