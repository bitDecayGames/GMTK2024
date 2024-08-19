package entities;

import entities.Player.GunHas;
import flixel.FlxG;
import flixel.math.FlxPoint;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import flixel.FlxSprite;

class Gun extends FlxSprite {
	public static var anims = AsepriteMacros.tagNames("assets/aseprite/pistol.json");

    public var type:GunHas;

    var parent:FlxSprite;
    var drawfset = FlxPoint.get();

    public function new(follow:FlxSprite, drawfset:FlxPoint) {
        super(0, 0);
        //origin.set(offsetX, offsetY);
        parent = follow;
        // TODO: Do we need different offsets for each weapon? probobly...
        this.drawfset.copyFrom(drawfset);
        Aseprite.loadAllAnimations(this, AssetPaths.pistol__json);
        // animation.play(anims.)
        origin.set(width/2, height/2);
    }

    public function setType(type:Player.GunHas) {
        this.type = type;
        switch(type) {
            case HANDS:
                Aseprite.loadAllAnimations(this, AssetPaths.hand__json);
            case PISTOL:
                Aseprite.loadAllAnimations(this, AssetPaths.pistol__json);
            case MAGNUM:
                Aseprite.loadAllAnimations(this, AssetPaths.magnum__json);
            case SHOTTY:
                Aseprite.loadAllAnimations(this, AssetPaths.shotty__json);
            case ROCKET:
                Aseprite.loadAllAnimations(this, AssetPaths.gl__json);
        }
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