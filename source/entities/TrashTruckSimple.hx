package entities;

import loaders.Aseprite;
import flixel.FlxSprite;

class TrashTruckSimple extends FlxSprite {
    public function new() {
        super();
        Aseprite.loadAllAnimations(this, AssetPaths.truck__json);
    }
}