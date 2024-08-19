package entities;

import states.PlayState;
import echo.data.Data.CollisionData;
import echo.Body;
import loaders.Aseprite;
import loaders.AsepriteMacros;

using echo.FlxEcho;

class ScrapCollector extends Unibody {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/recepticle.json");

    var opening = false;

    public function new(x:Float, y:Float) {
        super(x, y);
        Aseprite.loadAllAnimations(this, AssetPaths.recepticle__json);
        animation.frameIndex = 0;

        animation.finishCallback = handleAnimFinish;
    }

    function handleAnimFinish(name:String) {
        if (name == anims.open) {
            opening = false;
            var scrapCount = PlayState.me.player.scrapCount;
            PlayState.me.player.scrapCount = 0;
            if (scrapCount > 0) {
                QuickLog.notice('deposited ${scrapCount} scrap');
                 // TODO: spawn particles for player scrap and have them fly to the receptical
                 // Once that's done, close this bidge
                 animation.play(anims.close);
                 FmodManager.PlaySoundOneShot(FmodSFX.CollectorOpen);
            }
        }
    }

    override function handleEnter(other:Body, data:Array<CollisionData>) {
        super.handleEnter(other, data);

        if (other.object is Player) {
            if (!opening) {
                opening = true;
                var p:Player = cast other.object;
                if (p.scrapCount <= 0) {
                    return;
                }
    
                deposit();
            }
        }
    }

    public function deposit() {
        // TODO: spawn a bunch of particles from the player and animate them into my mouth
        // TODO: close
        // TODO: track for Tink, somehow
        animation.play(anims.open);
        FmodManager.PlaySoundOneShot(FmodSFX.CollectorOpen);
    }

	override function makeBody():Body {
		return this.add_body({
			x: x,
			y: y,
            kinematic: true,
			mass: 100,
			shapes: [
				{
					type:RECT,
					width: 32,
					height: 16,
				}
			]
		});
	}
}