package entities;

import entities.Player.GunHas;
import flixel.FlxG;
import flixel.math.FlxPoint;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import flixel.FlxSprite;

class GunHusk extends FlxSprite {
    public var type:GunHas;

    public function new(spawnPoint:FlxPoint, type:GunHas) {
        super(spawnPoint.x-8, spawnPoint.y);
        Aseprite.loadAllAnimations(this, AssetPaths.pistolNoHand__json);
        origin.set(width/2, height/2);
        setType(type);
    }

    public function setType(type:Player.GunHas) {
        this.type = type;
        switch(type) {
            case HANDS:
                Aseprite.loadAllAnimations(this, AssetPaths.hand__json);
            case PISTOL:
                Aseprite.loadAllAnimations(this, AssetPaths.pistolNoHand__json);
            case MAGNUM:
                Aseprite.loadAllAnimations(this, AssetPaths.magnumNoHand__json);
            case SHOTTY:
                Aseprite.loadAllAnimations(this, AssetPaths.shottyNoHand__json);
            case ROCKET:
                Aseprite.loadAllAnimations(this, AssetPaths.glNoHand__json);
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