package entities;

import loaders.AsepriteMacros;
import loaders.Aseprite;
import flixel.math.FlxPoint;

class SpinningCan extends Bullet {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/spinningCan.json");

    public function new(start:FlxPoint, angle:Float, speed:Float) {
        super(HANDS, start, angle, speed);

        Aseprite.loadAllAnimations(this, AssetPaths.spinningCan__json);
        animation.play(anims.spinning_can);
    }
}