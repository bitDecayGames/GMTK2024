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

using echo.FlxEcho;

class Player extends Unibody {
	public static var anims = AsepriteMacros.tagNames("assets/aseprite/playerSketchpad.json");
	public static var layers = AsepriteMacros.layerNames("assets/aseprite/playerSketchpad.json");
	//public static var eventData = AsepriteMacros.frameUserData("assets/aseprite/playerSketchpad.json", "Layer 1");

	var gun:Gun;

	var playerNum = 0;
	var dashing = false;

	var rollDurationMs = 400;
	var rollSpeedMultiplier = 2.1;
	var animTmp = FlxPoint.get();

	var rightDrawfset = FlxPoint.get(6, 9);
	var leftDrawfset = FlxPoint.get(10, 9);
	var upMod = -4;
	var storedLefting = false;
	var storedUpping = false;
	var lastInputDir = FlxPoint.get();
	var flippedInputDir = false;

	public function new(x:Float, y:Float) {
		super(x, y);

		speed = 100;

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
		//FlxG.state.add(gun);

		// FlxG.watch.add(this, "rollDurationMs", "Roll duration Ms");
		// FlxG.watch.add(this, "rollSpeedMultiplier", "Roll speed multiplier");
		// FlxG.watch.add(this, "speed", "Walk speed");
		// FlxG.watch.add(gun, "angle", "gun angle");
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
			rollSpeedMultiplier -= 0.1;
		}
		if (FlxG.keys.anyJustPressed([FlxKey.RBRACKET])){
			rollSpeedMultiplier += 0.1;
		}
		if (FlxG.keys.anyJustPressed([FlxKey.SEMICOLON])){
			speed -= 5;
		}
		if (FlxG.keys.anyJustPressed([FlxKey.QUOTE])){
			speed += 5;
		}

		if (!dashing && SimpleController.pressed(Button.A, playerNum)) {
			dashing = true;
			Timer.delay(() -> {
				// FmodManager.PlaySoundOneShot(FmodSFX.PlayerDeath);
				dashing = false;
			}, rollDurationMs);
			
			tmp.copyFrom(inputDir).scale(speed).scale(rollSpeedMultiplier);
			body.velocity.set(tmp.x, tmp.y);
		}

		if  (dashing) {
			intentState.add(DODGING);
		} else {
			handleDirectionIntent();
			handleMovement();

			
			var position = body.get_position();
			var positionAsFlxPoint = new FlxPoint(position.x, position.y);
			if (FlxG.mouse.justPressed) {
				var bullet = new Bullet(positionAsFlxPoint, gun.angle, 60);
				PlayState.me.AddBullet(bullet);
				PlayState.me.AddScrap(new Scrap(positionAsFlxPoint));
			}
		}

		updateCurrentAnimation(FlxG.mouse.getWorldPosition(tmp));
	}

	var tmpCard:Cardinal;

	function handleDirectionIntent() {
		tmpCard = InputCalcuator.getInputCardinal(playerNum);
		tmpCard.asVector(inputDir);
		if (inputDir.length != 0) {
			intentState.add(RUNNING);
		}

		if (inputDir.x != 0 && lastInputDir.x == 0) {
			flippedInputDir = true;
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
			gun.setDrawfset(upping ? rightDrawfset : leftDrawfset, upping ? upMod : 0);
		} else if (reference.x > myPos.x) {
			righting = true;
			flipX = false;
			gun.setDrawfset(upping ? leftDrawfset : rightDrawfset, upping ? upMod : 0);
		}

        var currentPlayerPosition = body.get_position();
		var cursorLeftOfPlayer = false;

		if (FlxG.mouse.getPosition().subtract(currentPlayerPosition.x, 0).x < 0) {
			cursorLeftOfPlayer = true;
		}
		if ((body.velocity.x > 0 && cursorLeftOfPlayer) || (body.velocity.x < 0 && !cursorLeftOfPlayer)) {
			reversing = true;
		}
		if (intentState.has(RUNNING)) {

			if (upping) {
				nextAnim = anims.Run_up;
			} else {
				nextAnim = anims.Run;
			}
		} else if (intentState.has(DODGING)) {
			if (upping) {
				nextAnim = anims.Dodeg_up;
			} else {
				nextAnim = anims.Dodge;
			}

			if (reversing && body.velocity.x > 0) {
				flipX = false;
			}
			if (reversing && body.velocity.x < 0) {
				flipX = true;
			}
		} else {
			if (upping) {
				nextAnim = anims.Idle_up;
			} else {
				nextAnim = anims.Idle;
			}
		}

		var forceAnimationRefresh = false;
		if (storedLefting != lefting || flippedInputDir) {
			forceAnimationRefresh = true;
		}
		playAnimIfNotAlready(nextAnim, reversing, forceAnimationRefresh);

		animTmp.copyFrom(reference);
		animTmp.subtract(body.x, body.y);
		gun.angle = animTmp.degrees;
		storedLefting = lefting;
		storedUpping = upping;
		lastInputDir.copyFrom(inputDir);
		flippedInputDir = false;
	}

    override function handleEnter(other:Body, data:Array<CollisionData>) {
        super.handleEnter(other, data);

        if (other.object is Bullet) {
            handleHit(cast other.object);
        }
    }

	function handleHit(bullet:Bullet) {
		// TODO: handle damage / scrap
		bullet.kill();
	}

	override function draw() {
		// Handles what order we draw the player/gun so that it looks right
		if (storedUpping) {
			gun.draw();
			super.draw();
		} else {
			super.draw();
			gun.draw();
		}
	}
}
