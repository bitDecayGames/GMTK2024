package entities;

import echo.Line;
import echo.math.Vector2;
import echo.Echo;
import states.PlayState;
import flixel.tweens.FlxEase;
import flixel.FlxObject;
import flixel.tweens.FlxTween;
import echo.data.Data.CollisionData;
import flixel.path.FlxPath;
import flixel.math.FlxPoint;
import flixel.FlxG;
import bitdecay.behavior.tree.decorator.Repeater;
import bitdecay.behavior.tree.leaf.util.Success;
import bitdecay.behavior.tree.BTContext;
import bitdecay.behavior.tree.NodeStatus;
import bitdecay.behavior.tree.leaf.util.Wait;
import bitdecay.behavior.tree.composite.Sequence;
import bitdecay.behavior.tree.leaf.util.StatusAction;
import bitdecay.behavior.tree.composite.Precondition;
import bitdecay.behavior.tree.composite.Selector;
import bitdecay.behavior.tree.BTree;
import bitdecay.behavior.tree.Node;
import loaders.Aseprite;
import loaders.AsepriteMacros;
import behavior.Explode;
import echo.Body;

using echo.FlxEcho;

class TrashCan extends Unibody {
	public static var anims = AsepriteMacros.tagNames("assets/aseprite/trashcan.json");
	public static var layers = AsepriteMacros.layerNames("assets/aseprite/trashcan.json");
	//public static var eventData = AsepriteMacros.frameUserData("assets/aseprite/playerSketchpad.json", "Layer 1");

    var hitsToEachScrap = 5;
    var hitsToNextScrap = 5;
    var scrapDropped = 0;
    var firstPhaseScrap = 10;
    public var hitByKillGun = false;

    var btree:BTree;
    var forceFollow:FlxObject = null;

    public var startPoint = FlxPoint.get();

	public function new(x:Float, y:Float) {
		super(x, y);
        startPoint.set(x, y);
		// This call can be used once https://github.com/HaxeFlixel/flixel/pull/2860 is merged
		// FlxAsepriteUtil.loadAseAtlasAndTags(this, AssetPaths.player__png, AssetPaths.player__json);
		Aseprite.loadAllAnimations(this, AssetPaths.trashcan__json);
		animation.play(anims.idle);
		// animation.callback = (anim, frame, index) -> {
		// 	if (eventData.exists(index)) {
		// 		trace('frame $index has data ${eventData.get(index)}');
		// 	}
		// };
		//this.loadGraphic(AssetPaths.filler16__png, true, 16, 16);

        initBTree();
	}

    function initBTree() {
        btree = new BTree(
            new Repeater(FOREVER, 
                new Selector(IN_ORDER, [
                    new Precondition(new StatusAction((delta) -> {
                        if (scrapDropped < firstPhaseScrap) {
                            return SUCCESS;
                        }
                        return FAIL;
                    }), new Sequence([
                        new Wait(0.5, 1.5),
                        new Selector(RANDOM([1, 1]), [
                            new HopAround(this),
                            new BigJump(this)
                        ])
                    ])),
                    new Precondition(new StatusAction((delta) -> {
                        if (!hitByKillGun) {
                            return SUCCESS;
                        }

                        return FAIL;
                    }), new Sequence([
                        new Wait(.25, 1),
                        new Selector(RANDOM([1, 1, 1]), [
                            new BigJump(this),
                            new CircleBlast(this),
                            new ChainFire(this)
                        ])
                    ])),
                    new Sequence([
                        new Explode(this)
                    ])
                ]
            ))
        );
        btree.init(new BTContext());
    }

	override function makeBody():Body {
		return this.add_body({
			x: x,
			y: y,
			max_velocity_x: 1000,
			max_velocity_length: 1000,
			drag_x: 0,
			mass: 100,
            kinematic: true,
			shapes: [
				// Standard moving hitbox
				{
					type:RECT,
					width: 16,
					height: 32,
					offset_y: 8,
				}
			]
		});
	}

    function handleHit(bullet:Bullet) {
        // TODO: Whatever damage/scrap mechanic we want
        // TODO: SFX trash can hit by bullet
        bullet.kill();

        hitsToNextScrap--;
        if (hitsToNextScrap <= 0) {
            // drop scrap
            // TODO: SFX hit dropped scrap
		    PlayState.me.AddScrap(new Scrap(body.x, body.y));
            scrapDropped++;
            hitsToNextScrap = hitsToEachScrap;
        } else {
            // TODO: SFX hit  did not drop scrap
        }

    }

	override public function update(delta:Float) {
		super.update(delta);

        if (forceFollow != null) {
            body.set_position(forceFollow.x, forceFollow.y);
        }

        if (btree.process(delta) == FAIL) {
            // Intersting. why it fail?
        }
	}

    override function handleEnter(other:Body, data:Array<CollisionData>) {
        super.handleEnter(other, data);

        if (other.object is Bullet) {
            handleHit(cast other.object);
        }

        if (other.object is Player) {
            var p:Player = cast other.object;
            p.takeDamage(this);
        }
    }

    public function followObj(obj:FlxObject) {
        forceFollow = obj;
    }
}

// Jump a small distance 2-4 times, somewhat randomly within the play area. Maybe shoot a can projectile at the 
// peak of each hop
class HopAround implements Node {
    var edgeBuffer = 32;

    var jumpHeight = 90;
    var jumpDistance = 20;
    var can:TrashCan;
    var jumpsRemaining:Int;
    var jumping = false;
    var cooldown = 0.0;

    var hackObj = new FlxObject();

    public function new(can:TrashCan) {
        this.can = can;
    }

    public function init(context:BTContext) {
        //jumpsRemaining = 100;
        jumpsRemaining = FlxG.random.int(2, 4);
        FlxG.state.add(hackObj);
    }

    public function process(delta:Float):NodeStatus {
        if (can.hitByKillGun) {
            return FAIL;
        }

        if (jumping) {
            // TODO: We want to be able to "fail" out of this node if the player hits us with the killshot
            return RUNNING;
        }
        if (cooldown > 0) {
            cooldown -= delta;

            if (cooldown <= 0) {
                if (jumpsRemaining <= 0) {
                    return SUCCESS;
                }
            }

            return RUNNING;
        }

        jumping = true;

        // Pick target location
        // Maybe ray cast in a 'random' direction to decide if we can jump as far as we want, and only jump to the wall if we hit something?
        var start = FlxPoint.get(can.body.x, can.body.y);
        var dest = FlxPoint.get();

        var dir = FlxPoint.get(PlayState.me.player.body.x, PlayState.me.player.body.y).subtractPoint(start).normalize();

        var jump = FlxPoint.get();
        var attempts = 0;
        while (dest.x < edgeBuffer || dest.x > FlxEcho.instance.world.width - edgeBuffer || dest.y < edgeBuffer * 2 || dest.y > FlxEcho.instance.world.height - edgeBuffer) {
            attempts++;
            jump.copyFrom(dir);
            jump.rotateByDegrees(FlxG.random.int(-30, 30)).scale(jumpDistance);
            dest.set(start.x + jump.x, start.y + jump.y);
            if (attempts > 5) {
                // Don't get in bad situation... just jump back to your spawn point!
                dest.copyFrom(can.startPoint);
                //QuickLog.error('taking too long to find a jump destination: ${attempts}');
                break;
            }
        }

        var midpoint = FlxPoint.get(start.x, start.y);
        midpoint.addPoint(dest).scale(0.5);
        midpoint.y -= jumpHeight;

        hackObj.setPosition(start.x, start.y);

        // NGL, pretty jank way of going through the animations... but we'll clean it up at some point
        can.animation.play(TrashCan.anims.jump, true);
        can.animation.finishCallback = (name) -> {
            can.animation.finishCallback = null;
            can.animation.play(TrashCan.anims.float);
            can.followObj(hackObj);
            // TODO: SFX small jump started
            FlxTween.quadPath(hackObj, [start, midpoint, dest], .5, {
                // ease: FlxEase.sineOut,
                onComplete: (t) -> {
                    // TODO: SFX small jump landed
                    FlxG.camera.shake(0.01, 0.1);
                    can.followObj(null);
                    can.animation.play(TrashCan.anims.land);
                    can.animation.finishCallback = (name) -> {
                        can.animation.play(TrashCan.anims.idle);
                        jumpsRemaining--;
                        jumping = false;
                        cooldown = 1;
                        can.animation.finishCallback = null;
                    };
                }
            });
        };

        return RUNNING;
    }

    public function exit() {
        FlxG.state.remove(hackObj);
    }
}

class BigJump implements Node {
    var can:TrashCan;
    var targetPoint = new Vector2(0, 0);
    var state:String = "wait";
    var fallSpeed = 1000.0;
    var offScreenBuffer = 16 * 5;
    var blastDirections = 12;

    var stateWait = "wait";
    var stateWindup = "windup";
    var stateLaunch = "launch";
    var stateTarget = "target";
    var stateFall = "fall";
    var stateLand = "land";
    var stateShoot = "shoot";
    var stateDone = "done";

    var cd:Float = 0;

    public function new(can:TrashCan) {
        this.can = can;
    }

    public function init(context:BTContext) {
        state = stateWait;

        can.animation.finishCallback = (name) -> {
            if (name == TrashCan.anims.windup && state == stateWindup) {
                // TODO: SFX trash can leaves the ground
                can.animation.play(TrashCan.anims.launch);
                can.body.get_position(targetPoint);
                var line = Line.get(can.body.x, can.body.y, can.body.x, can.body.y - 1000);
                var intersect = Echo.linecast(line, PlayState.me.wallBodies, FlxEcho.instance.world);
                if (intersect != null) {
                    targetPoint.y = can.body.y - intersect.closest.distance - offScreenBuffer;
                } else {
                    targetPoint.y -= 1000;
                }

                state = stateLaunch;
            } else if (name == TrashCan.anims.land) {
                can.animation.play(TrashCan.anims.idle);
                state = stateDone;
            }
        }
    }

    public function process(delta:Float):NodeStatus {
        FlxG.watch.addQuick('trash state: ', state);
        if (cd > 0) {
            cd -= delta;
        }
        if (state == stateWait) {
			if (cd <= 0) {
				can.animation.play(TrashCan.anims.windup);
				state = stateWindup;
			}
		} else if (state == stateLaunch) {
			if (can.body.y > targetPoint.y) {
				can.body.velocity.y = -fallSpeed;
			} else {
				can.body.set_position(can.body.x, targetPoint.y);
				state = stateTarget;
				cd = 1;
			}
		} else if (state == stateTarget) {
			if (cd <= 0) {
                // TODO: SFX Trash can starts falling
				PlayState.me.player.body.get_position(targetPoint);
				can.animation.play(TrashCan.anims.float);
                can.body.set_position(targetPoint.x, can.body.y);
                state = stateFall;
			}
		} else if (state == stateFall) {
			if (can.body.y < targetPoint.y) {
				can.body.velocity.y = fallSpeed;
			} else {
                // TODO: Screen shake
                // TODO: SFX: trash can lands big jump
                FlxG.camera.shake();
                can.body.velocity.set(0, 0);
				can.body.set_position(targetPoint.x, targetPoint.y);
				can.animation.play(TrashCan.anims.land);
				state = stateLand;


				var increment = 360 / blastDirections;
				var startPos = FlxPoint.get(can.body.x, can.body.y);
				// TODO: SFX shoot ring of cans
				for (i in 0...12) {
					PlayState.me.AddEnemyBullet(new SpinningCan(startPos, i * increment, 100));
				}
			}
		} else if (state == stateLand) {
			// TODO: Shoot upon landing?
        } else if (state == stateDone) {
            if (cd <= 0) {
			    return SUCCESS;
            }
		} 

        return RUNNING;
    }

    public function exit() {}
}

class CircleBlast implements Node {
    var can:TrashCan;
    var blastDirections = 12;
    var angleOffset = 0;
    var angleChange = 5;
    var baseCoolDown = 0.2;

    var wavesRemaining = 3;
    var cd = 0.0;

    var started = false;

    public function new(can:TrashCan) {
        this.can = can;
    }

    public function init(context:BTContext) {
        started = false;
        angleOffset = 0;
        wavesRemaining = 8;

        can.animation.finishCallback = (name) -> {
            if (name == TrashCan.anims.open) {
                can.animation.play(TrashCan.anims.shoot);
            }
        }
    }

    public function process(delta:Float):NodeStatus {
        if (!started) {
            started = true;
            can.animation.play(TrashCan.anims.open);
            return RUNNING;
        }

        if (can.animation.name == null || can.animation.name != TrashCan.anims.shoot) {
            return RUNNING;
        }

        if (cd > 0) {
            cd -= delta;
            return RUNNING;
        }

        if (wavesRemaining == 0) {
            can.animation.play(TrashCan.anims.idle);
            return SUCCESS;
        }

		wavesRemaining--;

		var increment = 360 / blastDirections;
		var startPos = FlxPoint.get(can.body.x, can.body.y);
		// TODO: SFX shoot ring of cans
		for (i in 0...12) {
			PlayState.me.AddEnemyBullet(new SpinningCan(startPos, angleOffset + i * increment, 100));
		}

		cd = baseCoolDown;
        angleOffset += angleChange;
        
        return RUNNING;
    }

    public function exit() {}
}

class ChainFire implements Node {
    var can:TrashCan;
    public function new(can:TrashCan) {
        this.can = can;
    }

    public function init(context:BTContext) {}

    public function process(delta:Float):NodeStatus {
        // TODO: implement
        return SUCCESS;
    }

    public function exit() {}
}
