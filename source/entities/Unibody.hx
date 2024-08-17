package entities;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import debug.DebugLayers;
import bitdecay.flixel.debug.DebugDraw;
import echo.Line;
import states.PlayState;
import flixel.util.FlxSpriteUtil;
import echo.util.AABB;
import flixel.math.FlxPoint;
import echo.math.Vector2;
import animation.AnimationState;
// import config.Constants;

class Unibody extends EchoSprite {
	// true cap on absolute speed (nice for limiting max fall speed, etc)
	// var MAX_VELOCITY = 15 * Constants.BLOCK_SIZE;
	var WALL_COLLIDE_SFX_THRESHOLD = 100;
	// var BULLET_SPEED = 15 * Constants.BLOCK_SIZE;

	var previousVelocity:Vector2 = new Vector2(0, 0);

	var speed:Float = 30;

	var tmp:FlxPoint = FlxPoint.get();
	var tmpAABB:AABB = AABB.get();
	var echoTmp:Vector2 = new Vector2(0, 0);

	var inputDir = FlxPoint.get();
	var intentState = new AnimationState();
	var animState = new AnimationState();

	public var killable = true;

	public function new(x:Float, y:Float) {
		super(x, y);

		// This aligns the body's bottom edge with whatever coordinate y was passed in for our creation
		// body.y = body.y - (body.shapes[0].bottom - body.shapes[0].top)/2 - body.shapes[0].get_local_position().y;
	}

	public function invulnerable(duration:Float) {
		killable = false;
		FlxSpriteUtil.flicker(this, duration, (f) -> {
			killable = true;
		});
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		intentState.reset();
		animState.reset();
	}

	function handleMovement() {
		if (intentState.has(RUNNING)) {
			animState.add(RUNNING);
			tmp.copyFrom(inputDir).scale(speed);
			body.velocity.set(tmp.x, tmp.y);
		} else {
			body.velocity.set(0,0);
		}
	}

	function handleShoot() {
		// if (Math.abs(body.x - camera.getCenterPoint().x) < FlxG.width * 2) {
		// 	FmodManager.PlaySoundOneShot(FmodSFX.WeaponGunShoot);
		// }
		// var trajectory = FlxPoint.weak(BULLET_SPEED, 0);
		// var vertOffset = 7;
		// var horizontalOffset = 0;
		// var offset = FlxPoint.weak(12);
		// var angleAdjust = flipX ? 180 : 0;
		// if (intentState.has(MOVE_RIGHT)) {
		// 	if (intentState.has(UPPING)) {
		// 		angleAdjust = -45;
		// 	} else if (intentState.has(DOWNING)) {
		// 		angleAdjust = 45;
		// 	}
		// } else if (intentState.has(MOVE_LEFT)) {
		// 	angleAdjust = 180;
		// 	if (intentState.has(UPPING)) {
		// 		angleAdjust = -135;
		// 	} else if (intentState.has(DOWNING)) {
		// 		angleAdjust = 135;
		// 	}
		// } else {
		// 	if (intentState.has(UPPING)) {
		// 		vertOffset = 6;
		// 		angleAdjust = -90;
		// 	} else if (intentState.has(DOWNING)) {
		// 		if (grounded) {
		// 			offset.x = 18;
		// 			vertOffset = 13;
		// 		} else {
		// 			angleAdjust = 90;
		// 			horizontalOffset = 4 * (flipX ? -1 : 1);
		// 			vertOffset = 14;
		// 		}
		// 	}
		// }

		// if (StringTools.startsWith(animation.curAnim.name, "Jump")) {
		// 	vertOffset -= 6;
		// }

		// trajectory.rotateByDegrees(angleAdjust);
		// offset.rotateByDegrees(angleAdjust);
		// var bullet = BasicBullet.pool.recycle(BasicBullet);
		// bullet.spawn(body.x + offset.x + horizontalOffset, body.y + offset.y + vertOffset, trajectory);
		// addBulletToGame(bullet);
		// if (animation.curAnim != null && !StringTools.endsWith(animation.curAnim.name, "Shoot")) {
		// 	muzzleFlashAnim(0.05);
		// }
	}

	// function addBulletToGame(bullet:BasicBullet) {
        // This seems like it will probably be the responsibility of the gun itself once we hook that up?
		// PlayState.ME.addEnemyBullet(bullet);
	// }

	function updateCurrentAnimation() {
		var nextAnim = animation.curAnim.name;

		// if (intentState.has(MOVE_RIGHT)) {
		// 	flipX = false;
		// } else if (intentState.has(MOVE_LEFT)) {
		// 	flipX = true;
		// }

		// if (animState.has(GROUNDED)) {
		// 	if (animState.has(RUNNING)) {
		// 		if (intentState.has(UPPING)) {
		// 			nextAnim = anims.RunUpward;
		// 		} else if (intentState.has(DOWNING)) {
		// 			nextAnim = anims.RunDownward;
		// 		} else {
		// 			nextAnim = anims.Run;

		// 		}
		// 	} else { 
		// 		if (intentState.has(UPPING)) {
		// 			nextAnim = anims.IdleUp;
		// 		} else if (intentState.has(DOWNING)) {
		// 			nextAnim = anims.Prone;
		// 		} else {
		// 			nextAnim = anims.Idle;
		// 		}
		// 	}
		// } else {
		// 	if (animState.has(RUNNING)) {
		// 		if (intentState.has(UPPING)) {
		// 			nextAnim = anims.JumpUpward;
		// 		} else if (intentState.has(DOWNING)) {
		// 			nextAnim = anims.JumpDownward;
		// 		} else {
		// 			nextAnim = anims.Jump;
		// 		}
		// 	} else { 
		// 		if (intentState.has(UPPING)) {
		// 			nextAnim = anims.JumpUp;
		// 		} else if (intentState.has(DOWNING)) {
		// 			// no animation here as this is how you initiate fast-fall
		// 			nextAnim = anims.Jump;
		// 		} else {
		// 			nextAnim = anims.Jump;
		// 		}
		// 	}
		// 	if (body.velocity.y > 0 && !StringTools.endsWith(nextAnim, "Fall") && !StringTools.endsWith(nextAnim, "FallShoot")) {
		// 		nextAnim = nextAnim + "Fall";
		// 	}
		// }

		// playAnimIfNotAlready(nextAnim);
	}

	// function playAnimIfNotAlready(name:String):Bool {
		// if (animation.curAnim == null || (animation.curAnim.name != name && animation.curAnim.name != name + "Shoot")) {
		// 	animation.play(name, true);
		// 	return true;
		// }
		// return false;
	// }

	// @:access(flixel.animation.FlxAnimation)
	// function muzzleFlashAnim(duration:Float) {
	// 	var restoreName = animation.curAnim.name;

	// 	inheretAnimation(animation.curAnim.name + "Shoot");
	// 	shootTimer.start(0.05, (t) -> {
	// 		if (animation.curAnim != null && StringTools.endsWith(animation.curAnim.name, "Shoot")) {
	// 			inheretAnimation(restoreName);
	// 		}
	// 	});
	// }

	// @:access(flixel.animation.FlxAnimation)
	// function inheretAnimation(name:String) {
	// 	if (animation.getByName(name) == null) {
	// 		return;
	// 	}

	// 	var frame = animation.curAnim.curFrame;
	// 	var frameTime = animation.curAnim._frameTimer;
	// 	animation.curAnim = animation.getByName(name);
	// 	animation.curAnim.curFrame = frame;
	// 	animation.curAnim._frameTimer = frameTime;
	// }
}
