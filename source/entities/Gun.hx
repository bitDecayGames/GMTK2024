package entities;

import flixel.math.FlxPoint;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import flixel.FlxSprite;

class Gun extends FlxSprite {
	public static var anims = AsepriteMacros.tagNames("assets/aseprite/pistol.json");

    var parent:FlxSprite;
    var drawfset = FlxPoint.get();

    public function new(follow:FlxSprite, drawfset:FlxPoint) {
        super(0, 0);
        //origin.set(offsetX, offsetY);
        parent = follow;
        this.drawfset.copyFrom(drawfset);
        Aseprite.loadAllAnimations(this, AssetPaths.pistol__json);
        // animation.play(anims.)
        origin.set(width/2, height/2);
    }

    public function setDrawfset(drawfset:FlxPoint, upMod:Float) {
        this.drawfset.copyFrom(drawfset);
        this.drawfset.y += upMod;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
    
    override function draw() {
        setPosition(parent.x + drawfset.x - width / 2, parent.y + drawfset.y - height / 2);

        if (angle > 90 || angle < -90) {
            // flipX = true;
            flipY = true;
        } else {
            // flipX = false;
            flipY = false;
        }

        super.draw();
    }
}