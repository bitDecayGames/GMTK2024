package entities;

import ui.WeaponUnlockOverlay;
import states.CreditsState;
import states.SplashScreenState;
import states.SplashScreenState.SplashImage;
import lime.tools.SplashScreen;
import flixel.util.FlxTimer;
import js.html.Console;
import echo.data.Data.CollisionData;
import states.PlayState;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.FlxG;
import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxSprite;
import input.InputCalcuator;
import input.SimpleController;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import echo.Body;
import haxe.Timer;
import ui.CharacterDialog;

using echo.FlxEcho;

class Scrappy extends Unibody {
	public static var anims = AsepriteMacros.tagNames("assets/aseprite/scrappy.json");

	// These need to match the strings attached to the spawns in LDTK
	public static inline var SCRAPPY_INTRO = "Intro";

	public var ogXY = FlxPoint.get();

	var distanceToPlayer:Float;

	public var dialogIndex = 0;

	public var spawnPoint:String;
	public var shutter:Shutter = null;

	public var readyTriggers:Array<EchoSprite> = [];

	var skipAllDialog = false;
	var fireDashTipDisplayedHitCount = 0;

	var activationRadius = 30;

	var introDialogDone = false;
	var introDialog2Done = false;

	public function new(x:Float, y:Float, spawnPoint:String, activationRadius:Int) {
		#if skip_dialog
		skipAllDialog = true;
		#end

		super(x, y);
		ogXY.set(x, y);
		Aseprite.loadAllAnimations(this, AssetPaths.scrappy__json);
		animation.play(anims.Idle);
		this.spawnPoint = spawnPoint;
		this.activationRadius = activationRadius;
		
	}

	override function makeBody():Body {
		return this.add_body({
			x: x+8,
			y: y+4,
			max_velocity_x: 1000,
			max_velocity_length: 1000,
			drag_x: 0,
			mass: 100,
			shapes: [
				// Standard moving hitbox
				{
					type:RECT,
					width: 16,
					height: 16,
				}
			]
		});
	}

	function triggerDialog(dialog:CharacterDialog, ?callback:() -> Void) {
		if (!skipAllDialog){
			PlayState.me.player.forceIdle();
			PlayState.me.openDialog(dialog);
		} else {
			if (callback != null) {
				callback();
			}
		}
	}

	override public function update(delta:Float) {
		super.update(delta);
		updateCurrentAnimation(FlxG.mouse.getWorldPosition(tmp));

		if (PlayState.me.dialogActive) {
			// just a fail-safe to keep extra dialogs from opening up once we know one is open
			return;
		}

		distanceToPlayer = PlayState.me.player.getMidpoint().distanceTo(getMidpoint());
		FlxG.watch.addQuick("Distance to player", distanceToPlayer);
		var checkDistance = activationRadius;
		if (distanceToPlayer < checkDistance) {

			switch (spawnPoint) {
				case SCRAPPY_INTRO:
					switch(dialogIndex) {
						case 0:
							dialogIndex++;
							introDialogDone = true;

							var endDialogCallback = () -> {}

							triggerDialog(new CharacterDialog(TINK, "Ah, a fellow scrapper. Nice to meet you, friend. The name's Scrappy", endDialogCallback), endDialogCallback);
					}
			}
		}
	}

	override function updateCurrentAnimation(reference:FlxPoint) {
		var nextAnim = animation.curAnim.name;

		var upping = false;
		var downing = false;
		var lefting = false;
		var righting = false;
		var reversing = false;
		var myPos = body.get_position();
		playAnimIfNotAlready(nextAnim, reversing, false);
	}

    override function handleEnter(other:Body, data:Array<CollisionData>) {
        super.handleEnter(other, data);
		if (other.object is Scrap) {
            handleScrap(cast other.object);
        }
    }

	function handleScrap(scrap:Scrap) {
		if (!scrap.collectible) {
			return;
		}
	}

	override function draw() {
		super.draw();
	}
}
