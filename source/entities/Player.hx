package entities;

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

using echo.FlxEcho;

class Player extends Unibody {
	public static var anims = AsepriteMacros.tagNames("assets/aseprite/playerSketchpad.json");
	public static var layers = AsepriteMacros.layerNames("assets/aseprite/playerSketchpad.json");
	//public static var eventData = AsepriteMacros.frameUserData("assets/aseprite/playerSketchpad.json", "Layer 1");

	var gun:Gun;

	var playerNum = 0;
	var lockControls = false;

	var rollDurationMs = 400;
	var rollSpeed = 60;
	var animTmp = FlxPoint.get();

	var rightDrawfset = FlxPoint.get(6, 9);
	var leftDrawfset = FlxPoint.get(10, 9);
	var upMod = -6;
	var storedLefting = false;

	public function new(x:Float, y:Float) {
		super(x, y);
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

		gun = new Gun(this, rightDrawfset);

		// TODO: This is not how we want to leave this, but it's a good filler for now
		FlxG.state.add(gun);
		speed = 40;

		// FlxG.watch.add(this, "rollDurationMs", "Roll duration Ms");
		// FlxG.watch.add(this, "rollSpeed", "Roll speed");
		FlxG.watch.add(gun, "angle", "gun angle");
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

		// debug tweaking 
		if (FlxG.keys.anyJustPressed([FlxKey.PLUS])){
			rollDurationMs += 100;
		}
		if (FlxG.keys.anyJustPressed([FlxKey.MINUS])){
			rollDurationMs -= 100;
		}
		if (FlxG.keys.anyJustPressed([FlxKey.LBRACKET])){
			rollSpeed -= 5;
		}
		if (FlxG.keys.anyJustPressed([FlxKey.RBRACKET])){
			rollSpeed += 5;
		}

		if (!lockControls && SimpleController.pressed(Button.A, playerNum)) {
			lockControls = true;
			Timer.delay(() -> {
				// FmodManager.PlaySoundOneShot(FmodSFX.PlayerDeath);
				lockControls = false;
				alpha = 1;
			}, rollDurationMs);
			
			alpha = 0.5;
			tmp.copyFrom(inputDir).scale(rollSpeed);
			body.velocity.set(tmp.x, tmp.y);
		}

		if (!lockControls) {
			handleDirectionIntent();
			handleMovement();
			updateCurrentAnimation(FlxG.mouse.getWorldPosition(tmp));

			
			var position = body.get_position();
			if (FlxG.mouse.justPressed) {
				var bullet = new Bullet(new FlxPoint(position.x, position.y), gun.angle, 60);
				PlayState.me.AddBullet(bullet);
			}
		}

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
		var reversing = false;
		var myPos = body.get_position();
		if (reference.y < myPos.y) {
			upping = true;
		} else if (reference.y > myPos.y) {
			upping = false;
		}

		if (reference.x < myPos.x) {
			lefting = true;
			flipX = true;
			gun.setDrawfset(leftDrawfset, upping ? upMod : 0);
		} else if (reference.x > myPos.x) {
			righting = true;
			flipX = false;
			gun.setDrawfset(rightDrawfset, upping ? upMod : 0);
		}

        var currentPlayerPosition = body.get_position();
		var cursorLeftOfPlayer = false;

		if (intentState.has(RUNNING)) {
			if (FlxG.mouse.getPosition().subtract(currentPlayerPosition.x, 0).x < 0) {
				cursorLeftOfPlayer = true;
			}

			if (upping) {
				nextAnim = anims.Run_up;
			} else {
				nextAnim = anims.Run;
			}
			
			if ((body.velocity.x > 0 && cursorLeftOfPlayer) || (body.velocity.x < 0 && !cursorLeftOfPlayer)) {
				reversing = true;
			}
		} else {
			if (upping) {
				nextAnim = anims.Idle_up;
			} else {
				nextAnim = anims.Idle;
			}
		}

		var forceAnimationRefresh = false;
		if (storedLefting != lefting) {
			forceAnimationRefresh = true;
		}
		playAnimIfNotAlready(nextAnim, reversing, forceAnimationRefresh);

		animTmp.copyFrom(reference);
		animTmp.subtract(body.x, body.y);
		gun.angle = animTmp.degrees;
		storedLefting = lefting;
	}

	override function draw() {
		// Handles what order we draw the player/gun so that it looks right
		if (StringTools.endsWith(animation.curAnim.name, "up")) {
			gun.draw();
			super.draw();
		} else {
			super.draw();
			gun.draw();
		}
	}
}
