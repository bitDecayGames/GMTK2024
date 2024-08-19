package entities;

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

class Tink extends Unibody {
	public static var anims = AsepriteMacros.tagNames("assets/aseprite/tinkSketchpad.json");

	// These need to match the strings attached to the Tink spawns in LDTK
	public static inline var TINK_INTRO = "Intro";
	public static inline var TINK_FIRE = "Fire";
	public static inline var TINK_TARGETS = "Targets";

	public var ogXY = FlxPoint.get();

	var distanceToPlayer:Float;

	var spawnPoint:String;
	var doorTop:DoorTop;
	var doorBottom:DoorBottom;
	public var shutter:Shutter = null;

	var skipAllDialog = false;

	var activationRadius = 30;

	var introDialogDone = false;
	var introDialog2Done = false;

	public function new(x:Float, y:Float, spawnPoint:String, doorTop:DoorTop, doorBottom:DoorBottom, activationRadius:Int) {
		#if skip_dialog
		skipAllDialog = true;
		#end

		super(x, y);
		ogXY.set(x, y);
		this.doorTop = doorTop;
		this.doorBottom = doorBottom;
		Aseprite.loadAllAnimations(this, AssetPaths.tinkSketchpad__json);
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
		if (distanceToPlayer < activationRadius) {

			switch (spawnPoint) {
				case TINK_INTRO:

					if (!introDialogDone) {
						introDialogDone = true;

						var endDialogCallback = () -> {
							shutter.close();
							new FlxTimer().start(1, (t) -> {
								doorTop.open();
								doorBottom.open();
							});
						};

						triggerDialog(new CharacterDialog(TINK, "Hello buddy. I hear you are looking for some weapons. I can help with that, but you gotta bring me some scrap first.<page/>Anyways, see ya.", endDialogCallback), endDialogCallback);
					} 
				case TINK_TARGETS:
					if (!introDialogDone) {
						introDialogDone = true;
						triggerDialog(new CharacterDialog(TINK, "Blast those crappy pink squares. They're actually targest, but I don't have assets yet."));
						return;
					} else if (!introDialog2Done) {
						var targetsDone = true;
						for (t in PlayState.me.practiceTargets) {
							if (!t.beenShot) {
								targetsDone = false;
								break;
							}
						}

						if (targetsDone && !introDialog2Done) {
							introDialog2Done = true;

							var endDialogCallback = () -> {
								shutter.close();
							};

							triggerDialog(new CharacterDialog(TINK, "All of em? Nice! Anyways, see ya.", endDialogCallback), endDialogCallback);
						}
					}
				case TINK_FIRE:
					if (!introDialogDone) {
						introDialogDone = true;
						var endDialogCallback = () -> {
							shutter.close();
						};
						triggerDialog(new CharacterDialog(TINK, "Hmmmm. An impassable wall of fire!<page/>Impassable for most, that is!<page/>Press SPACEBAR to dash through it!<page/>You are invincible during a dash, but you can't stop once you start, so choose your direction and position well.<page/>Go on, try it.", endDialogCallback), endDialogCallback);
						return;
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
