package entities;

import flixel.math.FlxPoint;
import flixel.FlxG;
import bitdecay.flixel.spacial.Cardinal;
import flixel.FlxSprite;
import input.InputCalcuator;
import input.SimpleController;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import echo.Body;

using echo.FlxEcho;

class Player extends Unibody {
	public static var anims = AsepriteMacros.tagNames("assets/aseprite/playerSketchpad.json");
	public static var layers = AsepriteMacros.layerNames("assets/aseprite/playerSketchpad.json");
	//public static var eventData = AsepriteMacros.frameUserData("assets/aseprite/playerSketchpad.json", "Layer 1");

	var playerNum = 0;

	public function new() {
		super(10, 10);
		// This call can be used once https://github.com/HaxeFlixel/flixel/pull/2860 is merged
		// FlxAsepriteUtil.loadAseAtlasAndTags(this, AssetPaths.player__png, AssetPaths.player__json);
		Aseprite.loadAllAnimations(this, AssetPaths.playerSketchpad__json);
		animation.play(anims.Idle);
		// animation.callback = (anim, frame, index) -> {
		// 	if (eventData.exists(index)) {
		// 		trace('frame $index has data ${eventData.get(index)}');
		// 	}
		// };
		//this.loadGraphic(AssetPaths.filler16__png, true, 16, 16);
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
					offset_y: 8,
				}
			]
		});
	}

	override public function update(delta:Float) {
		super.update(delta);

		handleDirectionIntent();

		handleMovement();
		updateCurrentAnimation(FlxG.mouse.getWorldPosition(tmp));
		FlxG.watch.addQuick("player vel: ", body.velocity);
	}

	var tmpCard:Cardinal;

	function handleDirectionIntent() {
		tmpCard = InputCalcuator.getInputCardinal(playerNum);
		tmpCard.asVector(inputDir);
		if (inputDir.length != 0) {
			intentState.add(RUNNING);
		}
	}

	override function updateCurrentAnimation(reference:FlxPoint) {
		var nextAnim = animation.curAnim.name;

		var upping = false;
		var downing = false;
		var lefting = false;
		var righting = false;
		var myPos = body.get_position();
		if (reference.x < myPos.x) {
			lefting = true;
			flipX = true;
		} else if (reference.x > myPos.x) {
			righting = true;
			flipX = false;
		}

		if (reference.y < myPos.y) {
			upping = true;
		} else if (reference.y > myPos.y) {
			upping = false;
		}

		if (intentState.has(RUNNING)) {
			if (upping) {
				nextAnim = anims.Run_up;
			} else {
				nextAnim = anims.Run;
			}
		} else {
			if (upping) {
				nextAnim = anims.Idle_up;
			} else {
				nextAnim = anims.Idle;
			}
		}

		playAnimIfNotAlready(nextAnim);
	}
}
