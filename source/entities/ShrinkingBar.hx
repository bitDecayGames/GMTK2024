package entities;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class ShrinkingBar extends FlxSprite {
    var originalWidth:Float;

    public function new(x:Float, y:Float, width:Int, height:Int, duration:Float) {
        super(x, y);
        makeGraphic(width, height, 0xFFFF0000); // Create a red bar
        originalWidth = width;

        // Set the origin to the center left
        origin.set(0, height / 2);

        // Use FlxTween to scale the x value of the scale property to 0 over the specified duration
        FlxTween.tween(this.scale, {x: 0}, duration, {
            onComplete: (tween:FlxTween) -> {
                kill();
            }
        });
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Additional update logic if necessary
    }
}
