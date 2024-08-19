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

	var dialogIndex = 0;

	var spawnPoint:String;
	var doorTop:DoorTop;
	var doorBottom:DoorBottom;
	public var shutter:Shutter = null;
	public var collector:ScrapCollector = null;

	var skipAllDialog = false;
	var fireDashTipDisplayedHitCount = 0;

	var activationRadius = 30;

	var introDialogDone = false;
	var introDialog2Done = false;

	public function new(x:Float, y:Float, spawnPoint:String, doorTop:DoorTop, doorBottom:DoorBottom, activationRadius:Int, collector:ScrapCollector) {
		#if skip_dialog
		skipAllDialog = true;
		#end

		super(x, y);
		ogXY.set(x, y);
		this.doorTop = doorTop;
		this.doorBottom = doorBottom;
		this.collector = collector;
		Aseprite.loadAllAnimations(this, AssetPaths.tinkSketchpad__json);
		animation.play(anims.Idle);
		this.spawnPoint = spawnPoint;
		this.activationRadius = activationRadius;
		

		if (spawnPoint == TINK_TARGETS) {
			if (collector != null){
				collector.isDepositable = false;
			}
		}
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
					switch(dialogIndex) {
						case 0:
							dialogIndex++;
							introDialogDone = true;

							var endDialogCallback = () -> {
								shutter.close();
								new FlxTimer().start(1, (t) -> {
									doorTop.open();
									doorBottom.open();
								});
							};

							triggerDialog(new CharacterDialog(TINK, "Hey buddy. I hear you are looking for some weapons. I can help with that, but you gotta bring me some scrap first.<page/>Anyways, see ya.", endDialogCallback), endDialogCallback);
					}
				case TINK_FIRE:
					switch(dialogIndex) {
						case 0:
							if (PlayState.me.player.hitByFireCount > 0) {
								PlayState.me.player.hitByFireCount = 0;
								dialogIndex++;
								var endDialogCallback = () -> {
									shutter.close();
								};
								
								new FlxTimer().start(1, (t) -> {
									triggerDialog(new CharacterDialog(TINK, "Well don't go walking into fire like that!<page/>Try dashing through the flames with SPACEBAR<page/>You are invincible during a dash, but you can't stop once you start, so choose your direction and position well.<page/>Taking damage will cause you to drop all your scrap. Don't leave any behind!", endDialogCallback), endDialogCallback);
								});
								return;
							} else if (PlayState.me.player.body.x > 550) { // If you dash through the fire without hitting it, skip the tutorial dialog
								dialogIndex++;
								introDialogDone = true;
								shutter.close();
							}
						case 1:
							if (PlayState.me.player.hitByFireCount % 3 == 0) {
								if (fireDashTipDisplayedHitCount != PlayState.me.player.hitByFireCount) {
									fireDashTipDisplayedHitCount = PlayState.me.player.hitByFireCount;
									triggerDialog(new CharacterDialog(TINK_GATE, "Dash through the fire with SPACEBAR!"));
								}
							}
					}
					
				case TINK_TARGETS:
					
				switch(dialogIndex) {
					case 0:
						dialogIndex++;
						triggerDialog(new CharacterDialog(TINK, "Ah, some targets! Time to start testing your sk...<page/>Wait, you still need a gun... Bring me 2 scrap and I will give you something easy to handle. Place the collected scrap into the scrap grider to my left.. uhh.. your left."));
						collector.isDepositable = true;
						// triggerDialog(new CharacterDialog(TINK, "Blast those crappy pink squares. They're actually targest, but I don't have assets yet."));"
						return;
						
					case 1:
						var targetsDone = true;
						for (t in PlayState.me.practiceTargets) {
							if (!t.beenShot) {
								targetsDone = false;
								break;
							}
						}

						if (targetsDone) {
							dialogIndex++;

							var endDialogCallback = () -> {
								shutter.close();
								new FlxTimer().start(1, (t) -> {
									doorTop.open();
									doorBottom.open();
								});
							};

							triggerDialog(new CharacterDialog(TINK, "All of em? Nice! Anyways, see ya.", endDialogCallback), endDialogCallback);
						}
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
