package entities;

import loaders.AsepriteMacros;
import loaders.Aseprite;
import states.PlayState;
import flixel.math.FlxPoint;

class ClusterBomb extends Bullet {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/spinningBottle.json");

    var triggerDist = 40.0;
    var blastDirections = 16;
    
    public function new(x:Float, y:Float, angle:Float, speed:Float) {
        // TODO: get real aim
        super(FlxPoint.weak(x, y), angle, speed);

        Aseprite.loadAllAnimations(this, AssetPaths.spinningBottle__json);
        animation.play(anims.spin);
    }

    var p1 = FlxPoint.get();
    var p2 = FlxPoint.get();

    override function update(elapsed:Float) {
        super.update(elapsed);

        p1.set(body.x, body.y);
        p2.set(PlayState.me.player.body.x, PlayState.me.player.y);
        if (p1.distanceTo(p2) < triggerDist ||
            Math.abs(p1.x - p2.x) < 5 || Math.abs(p1.y - p2.y) < 5) {
            var increment = 360 / blastDirections;
            var startPos = FlxPoint.get(body.x, body.y);
            // TODO: SFX shoot ring of cans
            for (i in 0...blastDirections) {
                PlayState.me.AddEnemyBullet(new SpinningCan(startPos, i * increment, 100));
            }
            // TODO: some graphic for this thing blowing up?
            kill();
        }
    }
}