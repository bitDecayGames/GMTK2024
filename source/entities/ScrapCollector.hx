package entities;

import flixel.text.FlxText.FlxTextAlign;
import flixel.FlxObject;
import flixel.math.FlxVelocity;
import ui.WeaponUnlockOverlay;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.text.FlxBitmapText;
import flixel.path.FlxPath;
import flixel.path.FlxPath.FlxPathType;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import misc.FlxTextFactory;
import states.PlayState;
import echo.data.Data.CollisionData;
import echo.Body;
import loaders.Aseprite;
import loaders.AsepriteMacros;

using echo.FlxEcho;

class ScrapCollector extends Unibody {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/recepticle.json");

    var displayText:FlxBitmapText;

    var opening = false;
    var scrapToActivate = 0;
    var closed = true;
    var scrapToClose = 0;
    public var id = "";
    var givingPlayerGun = false;

    
    var gun:GunHusk;
    var gunBLine = false;
    var gunCollected = false;

    public var isDepositable = true;

    public function new(x:Float, y:Float, scrapToActivate:Int, id:String) {
        super(x-8, y);
        Aseprite.loadAllAnimations(this, AssetPaths.recepticle__json);
        animation.frameIndex = 0;
        this.id = id;

        animation.finishCallback = handleAnimFinish;

        displayText = FlxTextFactory.make('${scrapToActivate}', x-10, y-28, 16, FlxTextAlign.RIGHT);
        PlayState.me.AddTopEntity(displayText);
        this.scrapToActivate = scrapToActivate;
    }

    var animationDelaySecs = 0.2;

	function GetMidpoint(point1:FlxPoint, point2:FlxPoint):FlxPoint {
        var pointsAdded = new FlxPoint(point1.x+point2.x, point1.y+point2.y);
        return new FlxPoint(pointsAdded.x/2, pointsAdded.y/2);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
		body.velocity.set(velocity.x, velocity.y);

        displayText.text = '${scrapToActivate}';

        if (!closed && scrapToClose <= 0){
            closed = true;
            animation.play(anims.close);
            FmodManager.PlaySoundOneShot(FmodSFX.CollectorOpen);
        }

        if (scrapToActivate <= 0 && isDepositable) {
            isDepositable = false;
            new FlxTimer().start(1, (t) -> {
                FmodManager.PlaySoundOneShot(FmodSFX.CollectorGrinding);
                new FlxTimer().start(1.45, (t) -> {
                    FlxG.camera.shake(0.01, 1.74);
                    new FlxTimer().start(2, (t) -> {
                        givingPlayerGun = true;
                        animation.play(anims.open);
                        FmodManager.PlaySoundOneShot(FmodSFX.CollectorOpen);
                    });
                    
                });
            });  
        }

        if (gunBLine && gun != null && gun.active && !gunCollected) {
            FlxG.watch.addQuick("gun location", gun.getPosition());
            FlxG.watch.addQuick("player location", PlayState.me.player.getPosition());
            FlxVelocity.moveTowardsObject(gun, PlayState.me.player, 200);
            if (PlayState.me.player.getPosition().distanceTo(gun.getPosition()) < 2) {
                collectGun();
            }
        }
    }

    function collectGun() {
        gunCollected = true;
        FmodManager.PlaySoundOneShot(FmodSFX.GunGet);
        FmodManager.PauseSong();
        new FlxTimer().start(0.4, (t) -> {
            FmodManager.PlaySoundOneShot(FmodSFX.GunGetJingle);
            PlayState.me.openSubState(new WeaponUnlockOverlay(PISTOL));
        });   
        new FlxTimer().start(4, (t) -> {
            FmodManager.UnpauseSong();
        });   
        gun.kill();
    }

    function handleAnimFinish(name:String) {
        if(name == anims.open && givingPlayerGun) {
            new FlxTimer().start(0.5, (t) -> {
                new FlxTimer().start(1, (t) -> {
                    animation.play(anims.close);
                    FmodManager.PlaySoundOneShot(FmodSFX.CollectorOpen);
                });
                FmodManager.PlaySoundOneShot(FmodSFX.GunSpawn);
                var player = PlayState.me.player;
                var myPosition = new FlxPoint(body.get_position().x, body.get_position().y);
                var playerPosition = new FlxPoint(player.body.get_position().x, player.body.get_position().y);
        
                gun = new GunHusk(myPosition);
                PlayState.me.topGroup.add(gun);
        
                // Create the path for it to follow
                gun.path = new FlxPath();
                var midpoint = GetMidpoint(playerPosition, myPosition);
                var topOfArc = body.y-32;
                midpoint.y = topOfArc-10;

                var arcTop = GetMidpoint(myPosition, midpoint);
                arcTop.y -= 32;
                var points:Array<FlxPoint> = [myPosition, arcTop, midpoint];
        
                // Start the movement and add it to the state
                //gun.path.start(points, 100, FlxPathType.FORWARD);
                FlxTween.quadPath(gun, points, 100, false, {
                    onComplete: (p) -> {
                        gunBLine = true;
                    }
                });
            });
        } else if (name == anims.open) {
            opening = false;
            closed = false;
            var player = PlayState.me.player;
            var scrapCount = player.scrapCount;
            scrapToClose = scrapCount;

            for (i in 0...scrapCount) {

                new FlxTimer().start(i * animationDelaySecs, (t) -> {
                    var myPosition = new FlxPoint(body.get_position().x, body.get_position().y);
                    var playerPosition = new FlxPoint(player.body.get_position().x, player.body.get_position().y);

                    var depositScrap = new Scrap(playerPosition.x, playerPosition.y, 0, true);
                    PlayState.me.topGroup.add(depositScrap);

                    FmodManager.PlaySoundOneShot(FmodSFX.ScrapSpawnDeposited2);

                    // Create the path for it to follow
                    depositScrap.path = new FlxPath();
                    var midpoint = GetMidpoint(playerPosition, myPosition);
                    var topOfArc = body.y-32;
                    midpoint.y = topOfArc-20;
                    var points:Array<FlxPoint> = [playerPosition, midpoint, myPosition];

                    depositScrap.doPath(points, () -> {
                        scrapToClose--;
                        scrapToActivate--;
                        FmodManager.PlaySoundOneShot(FmodSFX.ScrapSpawnDepositedComplete);    
                        depositScrap.kill();
                    });
                });
            }

            // Calculate the total time you want the animation to take
            // Divide that by how many scrap you hold
            // Start a loop with cascading delays 
            // Close door
            PlayState.me.player.scrapCount = 0;
            if (scrapCount > 0) {
                QuickLog.notice('deposited ${scrapCount} scrap');
                 // TODO: spawn particles for player scrap and have them fly to the receptical
                 // Once that's done, close this bidge
            }
        }
    }

    override function handleEnter(other:Body, data:Array<CollisionData>) {
        super.handleEnter(other, data);

        if (isDepositable && other.object is Player) {
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