package entities;

import js.html.AbortController;
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
                        ])
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

        if (btree.process(delta) == FAIL) {
            // Intersting. why it fail?
        }
	}
}

// Jump a small distance 2-4 times, somewhat randomly within the play area. Maybe shoot a can projectile at the 
// peak of each hop
class HopAround implements Node {

    var can:TrashCan;
    var jumpsRemaining:Int;
    var jumping = false;
    var cooldown = 0.0;
    
    public function new(can:TrashCan) {
        this.can = can;
    }

    public function init(context:BTContext) {
        jumpsRemaining = FlxG.random.int(2, 4);
    }

    public function process(delta:Float):NodeStatus {
        if (can.hitByKillGun) {
            return FAIL;
        }

        if (jumping) {
            can.body.velocity.set(can.velocity.x, can.velocity.y);

            // if (can.path != null && !can.path.active) {
            //     jumping = false;
            //     cooldown = 1;
            // }

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
        }

        // Pick target location
        // Maybe ray cast in a 'random' direction to decide if we can jump as far as we want, and only jump to the wall if we hit something?
        var dest = can.getPosition();
        var jump = FlxPoint.get(1, 0).rotateByDegrees(FlxG.random.int(0, 359)).scale(15);
        dest.addPoint(jump);

        if (can.path == null) {
            can.path = new FlxPath([dest]);
        } else {
            can.path.start([dest]);
        }

        can.path.onComplete = (path) -> {jumping = false; cooldown = 1;};
        
        jumping = true;
        // initiate 'jump'

        // wait for path/animation to finish (likely path)

        return RUNNING;
    }

    public function exit() {}
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