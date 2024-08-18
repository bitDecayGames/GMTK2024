package entities;

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
import echo.Body;

using echo.FlxEcho;

class TrashCan extends Unibody {
	public static var anims = AsepriteMacros.tagNames("assets/aseprite/trashcan.json");
	public static var layers = AsepriteMacros.layerNames("assets/aseprite/trashcan.json");
	//public static var eventData = AsepriteMacros.frameUserData("assets/aseprite/playerSketchpad.json", "Layer 1");

    var scrapDropped = 0;
    var firstPhaseScrap = 10;
    public var hitByKillGun = false;

    var btree:BTree;
    var forceFollow:FlxObject = null;

	public function new(x:Float, y:Float) {
		super(x, y);
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
                        new Wait(1, 3),
                        new Selector(RANDOM([1]), [
                            new HopAround(this) //,
                            // new BigJump(this),
                            // new CircleBlast(this)
                        ]),
                        new Explode(this)
                    ])),
                    new Precondition(new StatusAction((delta) -> {
                        if (!hitByKillGun) {
                            return SUCCESS;
                        }

                        return FAIL;
                    }), new Sequence([
                        new Wait(1, 1.5),
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
        bullet.kill();
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
    }

    public function followObj(obj:FlxObject) {
        forceFollow = obj;
    }
}

// Jump a small distance 2-4 times, somewhat randomly within the play area. Maybe shoot a can projectile at the 
// peak of each hop
class HopAround implements Node {

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
        jumpsRemaining = 100;
        // jumpsRemaining = FlxG.random.int(2, 4);
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
        while (dest.x < 16 || dest.x > FlxEcho.instance.world.width - 16 || dest.y < 16 * 2 || dest.y > FlxEcho.instance.world.height - 16) {
            jump.copyFrom(dir);
            jump.rotateByDegrees(FlxG.random.int(-30, 30)).scale(jumpDistance);
            dest.set(start.x + jump.x, start.y + jump.y);
            if (attempts > 5) {
                QuickLog.error('taking too long to find a jump destination: ${attempts}');
            }
        }

        var midpoint = FlxPoint.get(start.x, start.y);
        midpoint.addPoint(dest).scale(0.5);
        midpoint.y -= jumpHeight;

        hackObj.setPosition(start.x, start.y);

        // NGL, pretty jank way of going through the animations... but we'll clean it up at some point
        can.animation.play(TrashCan.anims.jump);
        can.animation.finishCallback = (name) -> {
            can.animation.finishCallback = null;
            can.animation.play(TrashCan.anims.float);
            can.followObj(hackObj);
            FlxTween.quadPath(hackObj, [start, midpoint, dest], .5, {
                // ease: FlxEase.sineOut,
                onComplete: (t) -> {
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

class CircleBlast implements Node {
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

class Explode implements Node {
    var can:TrashCan;
    public function new(can:TrashCan) {
        this.can = can;
    }

    public function init(context:BTContext) {}

    public function process(delta:Float):NodeStatus {
        can.kill();
        return SUCCESS;
    }

    public function exit() {}
}