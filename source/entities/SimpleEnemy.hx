package entities;

import flixel.group.FlxGroup;
import helpers.Vector2Math;
import echo.math.Vector2;
import states.PlayState;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import echo.data.Data.CollisionData;
import echo.Body;

using echo.FlxEcho;

class SimpleEnemy extends Unibody {

    var dodgeDistance = 40;
    var dodgeSpeedMultiplier = 6;
    var dodgeTime = 0.15;

    public var beenShot = false;
    private var hasDodged = false;
    private var startDodge = false;
    private var dodging = false;

    var player:Player;
    var myPosition:FlxPoint;
    var playerPosition:FlxPoint;
    var direction:FlxPoint;

    public static var anims = AsepriteMacros.tagNames("assets/aseprite/target.json");

    public function new(x:Float, y:Float) {
        super(x, y);

        speed = 2000;

        myPosition = new FlxPoint(0, 0);
        playerPosition = new FlxPoint(0, 0);
        direction = new FlxPoint(0, 0);
        
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
    
        var myPositionVector = body.get_position();
        var playerPositionVector = PlayState.me.player.body.get_position();
        direction.set(playerPositionVector.x - myPositionVector.x, playerPositionVector.y - myPositionVector.y).normalize();
    
        // TODO this check should be done with event listeners and not a mega for for each loop. There will likely be performance issues with this code
        PlayState.me.bulletGroup.forEach((b) -> {
            var bullet:Bullet = cast(b, Bullet);
            if (Vector2Math.distanceTo(bullet.body.get_position(), myPositionVector) < dodgeDistance && !hasDodged && !dodging) {
                startDodge = true;
            }
        });
        if (startDodge) {
            startDodge = false;
            dodging = true;
            performDodgeMovement(elapsed, myPositionVector);
        } else if (!beenShot && !dodging) {
            body.velocity.set(direction.x * speed * elapsed, direction.y * speed * elapsed);
        }
    }
    
    private function performDodgeMovement(elapsed:Float, myPositionVector:Vector2):Void {
        var perpendicularDirection1 = new Vector2(-direction.y, direction.x).normalize();
        var perpendicularDirection2 = new Vector2(direction.y, -direction.x).normalize();
    
        var closestBullet:Bullet = findClosestBullet(myPositionVector);
    
        // Manually add the vectors
        var positionAfterMove1 = new Vector2(myPositionVector.x + perpendicularDirection1.x, myPositionVector.y + perpendicularDirection1.y);
        var positionAfterMove2 = new Vector2(myPositionVector.x + perpendicularDirection2.x, myPositionVector.y + perpendicularDirection2.y);
    
        var distance1 = Vector2Math.distanceTo(closestBullet.body.get_position(), positionAfterMove1);
        var distance2 = Vector2Math.distanceTo(closestBullet.body.get_position(), positionAfterMove2);
    
        var bestDodgeDirection:Vector2 = (distance1 > distance2) ? perpendicularDirection1 : perpendicularDirection2;
    
        var dodgeSpeed = speed * dodgeSpeedMultiplier; // Increase speed during dodge
    
        // Move in the direction that maximizes distance from the bullet
        body.velocity.set(bestDodgeDirection.x * dodgeSpeed * elapsed, bestDodgeDirection.y * dodgeSpeed * elapsed);
    
        new FlxTimer().start(dodgeTime, (t) -> {
            dodging = false;
            hasDodged = true;
        });
    }
    

    private function findClosestBullet(position:Vector2):Bullet {
        var closestBullet:Bullet = null;
        var minDistance:Float = Math.POSITIVE_INFINITY;

        PlayState.me.bulletGroup.forEach((b) -> {
            var bullet:Bullet = cast(b, Bullet);
            var distance = Vector2Math.distanceTo(bullet.body.get_position(), position);

            if (distance < minDistance) {
                minDistance = distance;
                closestBullet = bullet;
            }
        });

        return closestBullet;
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
