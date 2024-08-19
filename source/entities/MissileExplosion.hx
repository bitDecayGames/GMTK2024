package entities;

import loaders.AsepriteMacros;
import loaders.Aseprite;
import flixel.math.FlxPoint;

class MissileExplosion extends Bullet {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/explosion.json");

    public function new(x:Float, y:Float) {
        super(FlxPoint.weak(x, y), 0, 0);
        // TODO: SFX missile explosion
        Aseprite.loadAllAnimations(this, AssetPaths.explosion__json);
        animation.play(anims.explode);
        animation.finishCallback = (n) -> {
            kill();
        }
    }
}