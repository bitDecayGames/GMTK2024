package entities;

import flixel.math.FlxPoint;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import flixel.FlxSprite;

class Gun extends FlxSprite {
	public static var slices = AsepriteMacros.sliceNames("assets/aseprite/sketchpad.json");

    var parent:FlxSprite;
    var drawfset = FlxPoint.get();

    public function new(follow:FlxSprite, offsetX:Float, offsetY:Float) {
        super(0, 0);
        origin.set(offsetX, offsetY);
        parent = follow;
        drawfset.set(offsetX, offsetY);
        Aseprite.loadSlice(this, AssetPaths.sketchpad__json, slices.pistol_0);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
    
    override function draw() {
        setPosition(parent.x + drawfset.x, parent.y + drawfset.y);

        super.draw();
    }
}