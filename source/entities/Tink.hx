package entities;

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

	var player:Player;
	var distanceToPlayer:Float;

	var introDialogDone = false;

	public function new(x:Float, y:Float, player:Player) {
		super(x, y);
		this.player = player;
		Aseprite.loadAllAnimations(this, AssetPaths.tinkSketchpad__json);
		animation.play(anims.Idle);
	}

	override function makeBody():Body {
		return this.add_body({
			x: x,
			y: y,
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

	override public function update(delta:Float) {
		super.update(delta);
		updateCurrentAnimation(FlxG.mouse.getWorldPosition(tmp));

		distanceToPlayer = player.getMidpoint().distanceTo(getMidpoint());
		if (distanceToPlayer < 30) {
			if (!introDialogDone) {
				introDialogDone = true;
				var dialogTest = new CharacterDialog(TINK, "Hello buddy. I hear you are looking for some weapons. I can help with that, but you gotta bring me some scrap first.");
				PlayState.me.openDialog(dialogTest);
			} else {
				var dialogTest = new CharacterDialog(TINK, "2nd dialog here.");
				PlayState.me.openDialog(dialogTest);
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
