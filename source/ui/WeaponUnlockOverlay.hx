package ui;

import entities.Player.GunHas;
import states.PlayState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.util.FlxColor;
import loaders.AsepriteMacros;
import loaders.Aseprite;
import flixel.FlxSprite;
import flixel.FlxSubState;

class WeaponUnlockOverlay extends FlxSubState {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/weaponSplashScreens.json");

    public function new(type:GunHas) {
        super();

        var bgSprite = new FlxSprite();
        bgSprite.makeGraphic(1, 1, FlxColor.BLACK);
        bgSprite.scale.set(FlxG.width + 10, FlxG.height + 10);
        bgSprite.updateHitbox();
        bgSprite.scrollFactor.set();
        bgSprite.screenCenter();
        bgSprite.alpha = 0;
        add(bgSprite);

        var gunType = new FlxSprite();
        Aseprite.loadAllAnimations(gunType, AssetPaths.weaponSplashScreens__json);
        if (type == PISTOL) {
            gunType.animation.play(anims.pistol);
        } if (type == MAGNUM) {
            gunType.animation.play(anims.magnum);
        } if (type == SHOTTY) {
            gunType.animation.play(anims.shotty);
        } if (type == ROCKET) {
            gunType.animation.play(anims.gl);
        }
        gunType.scale.set(2, 2);
        gunType.updateHitbox();
        gunType.scrollFactor.set();
        gunType.screenCenter();

        var startY = gunType.y;
        var endY = gunType.y - FlxG.height;
        gunType.y += FlxG.height;

        // TODO: SFX screen fades
        FlxTween.tween(bgSprite, {"alpha": 0.5}, 0.25, {
            // Nothing needed here
            onComplete: (t) -> {
                // TODO: SFX graphic starts sliding in
            }
        }).then(FlxTween.tween(gunType, {"y": startY + 20}, .75, {
            ease: FlxEase.backIn,
            onComplete: (t) -> {
                // TODO: SFX graphic hits slow down spot in middle of screen
                // Upgrade the player graphic now as they'll be behind the art

                // TODO: SFX playergets new gun
                PlayState.me.player.setGun(type);
            }
        })).then(FlxTween.tween(gunType, {"y": startY - 20}, 2, {
            onComplete: (t) -> {
                // TODO: SFX graphic hits end of slow portion and starts zooming off
            }
        })).then(FlxTween.tween(gunType, {"y": endY}, 0.75, {
            ease: FlxEase.backOut
        })).then(FlxTween.tween(bgSprite, {"alpha": 0}, 0.25, {
            onComplete: (t) -> {
                PlayState.me.resumeGame();
                close();
            }
        }));

        // TODO: Tween this shit and add cool sound
        add(gunType);

        PlayState.me.pauseGame();
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
    }
}