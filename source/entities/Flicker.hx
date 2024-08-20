package entities;

import flixel.util.FlxTimer;
import flixel.FlxSprite;

class Flickerer {
    public static function flickerWhite(sprite:FlxSprite, totalBlinkTime:Float, numBlinks:Int) {
        // Store the original color transformation values
        var originalRedMultiplier = sprite.colorTransform.redMultiplier;
        var originalGreenMultiplier = sprite.colorTransform.greenMultiplier;
        var originalBlueMultiplier = sprite.colorTransform.blueMultiplier;
        var originalAlphaMultiplier = sprite.colorTransform.alphaMultiplier;
        
        var originalRedOffset = sprite.colorTransform.redOffset;
        var originalGreenOffset = sprite.colorTransform.greenOffset;
        var originalBlueOffset = sprite.colorTransform.blueOffset;
        var originalAlphaOffset = sprite.colorTransform.alphaOffset;

        // Start a timer to handle the flickering
        new FlxTimer().start(
            totalBlinkTime / numBlinks,
            function (timer) {
                if (timer.loopsLeft % 2 == 0) {
                    // Restore original color transformation
                    sprite.setColorTransform(
                        originalRedMultiplier,
                        originalGreenMultiplier,
                        originalBlueMultiplier,
                        originalAlphaMultiplier,
                        originalRedOffset,
                        originalGreenOffset,
                        originalBlueOffset,
                        originalAlphaOffset
                    );
                } else {
                    // Apply white flicker effect
                    sprite.setColorTransform(1, 1, 1, 1, 255, 255, 255, 255);
                }
            },
            numBlinks
        );
    }
}
