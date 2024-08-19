package entities;

import entities.Player.GunHas;
import flixel.FlxG;
import flixel.math.FlxPoint;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import flixel.FlxSprite;

class GunHusk extends FlxSprite {
	public static var anims = AsepriteMacros.tagNames("assets/aseprite/pistol.json");

    public var type:GunHas;

    public function new(spawnPoint:FlxPoint) {
        super(spawnPoint.x-8, spawnPoint.y);
        Aseprite.loadAllAnimations(this, AssetPaths.pistol__json);
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

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
    
    override function draw() {
        super.draw();
    }
}