package entities;

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
    var parent:FlxSprite;
    var drawfset = FlxPoint.get();
	var loopDropRadius = 30;

	public static var anims = AsepriteMacros.tagNames("assets/aseprite/bolt.json");

    public function new(source:FlxPoint) {
        super(source.x, source.y);
        Aseprite.loadAllAnimations(this, AssetPaths.bolt__json);
		animation.play(anims.Bolt);

		
        // accounting for known half-width and half-height here
        // assume we are placing loot based on center
        var boundaryBuffer = 24;
        var inventoryBuffer = 36;

        var levelBounds = PlayState.me.level.bounds;

        // Calculate final drop point
        var theta = Math.random() * 2 * Math.PI;
        var finalX = Math.min(Math.max(boundaryBuffer, source.x + loopDropRadius * Math.cos(theta)), levelBounds.width-boundaryBuffer);
        var finalY = Math.min(Math.max(boundaryBuffer*2, source.y + loopDropRadius * Math.sin(theta)), levelBounds.height-boundaryBuffer);
        var randomPointAroundPlayer = new FlxPoint(finalX, finalY);

        // Create the path for it to follow
        path = new FlxPath();
        var initialPoint = new FlxPoint(source.x, source.y);
        var midpoint = GetMidpoint(initialPoint, randomPointAroundPlayer);
        var topOfArc = FlxMath.minInt(Std.int(randomPointAroundPlayer.y), Std.int(randomPointAroundPlayer.y));
        midpoint.y = topOfArc-10;
        var points:Array<FlxPoint> = [getPosition(), midpoint, randomPointAroundPlayer];

		// path = new FlxPath();
        // var points:Array<FlxPoint> = [getPosition(), new FlxPoint(0,0)];

        // Start the movement and add it to the state
        path.start(points, 100, FlxPathType.FORWARD);
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

		body.velocity.set(velocity.x, velocity.y);
    }
    
    override function draw() {
        super.draw();
    }
}