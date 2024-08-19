package entities;

import flixel.FlxG;
import flixel.path.FlxPath;
import states.PlayState;
import loaders.AsepriteMacros;
import loaders.Aseprite;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class TankMissile extends FlxSprite {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/acetelyne.json");

    var delay:Float;
    var landSpeed:Float;

    var up = true;

    public function new(spawn:FlxPoint, launchSpeed:Float, landSpeed:Float, delay:Float) {
        super(spawn.x, spawn.y);
        this.delay = delay;
        this.landSpeed = landSpeed;
        Aseprite.loadAllAnimations(this, AssetPaths.acetelyne__json);
        this.velocity.set(0, -launchSpeed);
        // TODO: SFX tank missile launch
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (path != null && path.active) {
            return;
        }

        if (up && y < PlayState.me.player.body.y - 500) {
            up = false;
        }

        if (!up && delay > 0) {
            delay -= elapsed;
        }

        if (!up && delay <= 0) {
            var newX = PlayState.me.player.body.x - width / 2; 
            this.x = newX;
            var start = FlxPoint.get(newX, y);
            var end = FlxPoint.get(PlayState.me.player.body.x - width / 2, PlayState.me.player.body.y);
            path = new FlxPath();
            // TODO: SFX missile coming back in
            path.start([start, end], landSpeed);
            path.onComplete = (p) -> {
                kill();
                FlxG.camera.shake(0.01, 0.1);
                PlayState.me.AddEnemyBullet(new MissileExplosion(end.x, end.y));
            }
        }
    }
}