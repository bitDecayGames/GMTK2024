package entities;

import states.PlayState;
import loaders.AsepriteMacros;
import loaders.Aseprite;
import flixel.math.FlxPoint;
import flixel.FlxSprite;

class IncomingMissile extends FlxSprite {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/acetelyne.json");

    var delay:Float;
    var landSpeed:Float;

    public function new(x:Float, launchSpeed:Float) {
        // XXX: Maybe need to find vertical offset?
        super(x, PlayState.me.player.body.y - 400);
        Aseprite.loadAllAnimations(this, AssetPaths.acetelyne__json);
        angle = 180; // get thing pointed the right way
        this.velocity.set(0, -launchSpeed);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        delay -= elapsed;
        if (delay > 0) {
            return;
        }

        PlayState.me.RemoveTopEntity(this);
        kill();

        PlayState.me.AddEnemyBullet(new IncomingMissile(PlayState.me.player.body.x));
    }
}