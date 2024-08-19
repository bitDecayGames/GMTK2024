package entities;

import flixel.FlxObject;
import flixel.util.FlxTimer;
import echo.Echo;
import echo.Line;
import flixel.tweens.FlxTween;
import states.PlayState;
import flixel.math.FlxMath;
import flixel.path.FlxPath;
import flixel.FlxG;
import echo.data.Data.CollisionData;
import echo.Body;
import flixel.math.FlxPoint;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import flixel.FlxSprite;

using echo.FlxEcho;

class Scrap extends Unibody {
	public static var animsBolt = AsepriteMacros.tagNames("assets/aseprite/bolt.json");
	public static var animsNut = AsepriteMacros.tagNames("assets/aseprite/nut.json");

	var loopDropRadius = 30;
    public var collectible = true;

    var delayedPickup = false;
    var pointPicked = false;

    var forceFollow = new FlxObject();

    public function new(x:Float, y:Float, distance:Int = 30, delayPickup:Bool = false) {
        super(x, y);

        loopDropRadius = distance;

        delayedPickup = delayPickup;
        if (delayPickup) {
            collectible = false;
            new FlxTimer().start(1, (t) -> {
                // fail safe in case the thing can't finish its path
                collectible = true;
            });
        }
    }

    override function configSprite() {
        super.configSprite();

        if(Math.random() < 0.5){
            Aseprite.loadAllAnimations(this, AssetPaths.bolt__json);
            animation.play(animsBolt.Bolt);
        } else {
            Aseprite.loadAllAnimations(this, AssetPaths.nut__json);
            animation.play(animsNut.spin);
        }
    }

	function GetMidpoint(point1:FlxPoint, point2:FlxPoint):FlxPoint {
        var pointsAdded = new FlxPoint(point1.x+point2.x, point1.y+point2.y);
        return new FlxPoint(pointsAdded.x/2, pointsAdded.y/2);
    }

	override function handleEnter(other:Body, data:Array<CollisionData>) {
		super.handleEnter(other, data);

		if (other.object is Player) {
			// kill();
		}
	}

	override function makeBody():Body {
		return this.add_body({
			x: x,
			y: y,
            //kinematic: true,
			// shape: {
            //     type:RECT,
            //     width: 16,
            //     height: 16,
			// }
		});
	}

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (!pointPicked) {
            pointPicked = true; 
            pickPoint();
        }

        if (forceFollow != null) {
            body.set_position(forceFollow.x, forceFollow.y);
        }
    }

    function pickPoint() {
        var start = getMidpoint();

        if (loopDropRadius == 0) {
            collectible = true;
            return;
        }
		
        // Calculate final drop point
        var theta = Math.random() * 2 * Math.PI;
        var xdist = start.x + loopDropRadius * Math.cos(theta);
        var ydist = start.y + loopDropRadius * Math.sin(theta);

        var line = Line.get(start.x, start.y, xdist, ydist);
        var intersect = Echo.linecast(line, PlayState.me.wallBodies);
        if (intersect != null) {
            xdist = intersect.closest.hit.x;
            ydist = intersect.closest.hit.y;
        }

        var randomPointAroundPlayer = new FlxPoint(xdist, ydist);

        // Create the path for it to follow
        path = new FlxPath();

        var midpoint = GetMidpoint(start, randomPointAroundPlayer);
        var topOfArc = FlxMath.minInt(Std.int(randomPointAroundPlayer.y), Std.int(randomPointAroundPlayer.y));
        midpoint.y = topOfArc-20;
        var points:Array<FlxPoint> = [start, midpoint, randomPointAroundPlayer];

        // Start the movement and add it to the state
        //path.start(points, 100, FlxPathType.FORWARD);
        FlxTween.quadPath(forceFollow, points, 100, false, {
            onComplete: (t) -> {
                forceFollow.destroy();
                forceFollow = null;
            }
        });
    }
    
    override function draw() {
        super.draw();
    }
}