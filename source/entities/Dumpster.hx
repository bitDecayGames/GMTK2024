package entities;

import echo.data.Data.CollisionData;
import flixel.math.FlxPoint;
import states.PlayState;
import bitdecay.behavior.tree.BTContext;
import bitdecay.behavior.tree.BTree;
import bitdecay.behavior.tree.decorator.Repeater;
import bitdecay.behavior.tree.decorator.basic.AlwaysSucceed;
import bitdecay.behavior.tree.decorator.basic.Invert;
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
import behavior.Explode;
import echo.Body;
import loaders.AsepriteMacros;

using echo.FlxEcho;

class Dumpster extends Unibody {
    public static var anims = AsepriteMacros.tagNames("assets/aseprite/dumpster.json");

    var hitsToEachScrap = 5;
    var hitsToNextScrap = 5;
    var scrapDropped = 0;
    var firstPhaseScrap = 10;
    public var hitByKillGun = false;

    public var lastCollisionWall:Bool;
    public var lastCollisionPlayer:Bool;

    var btree:BTree;

    public function new(x:Float, y:Float) {
        super(x, y);
        Aseprite.loadAllAnimations(this, AssetPaths.dumpster__json);
        animation.play(anims.bothDoorsClosed);

        initBTree();
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
					width: 50,
					height: 27,
					offset_y: 16,
				}
			]
		});
    }

	function initBTree() {
        btree = new BTree(
            new Repeater(FOREVER, 
                new Selector(IN_ORDER, [
                    new BarrageAttack(this),
                    new Precondition(new StatusAction((delta) -> {
                        if (scrapDropped < firstPhaseScrap) {
                            return SUCCESS;
                        }
                        return FAIL;
                    }), new Sequence([
                        new Wait(0.5, 1.5),
                        new AlwaysSucceed(new Selector(RANDOM([4]), [
                            new Sequence([
                                new Invert(new RamAttack(this)),
                                new Selector(RANDOM([2, 2]), [
                                    new LeftDoorAttack(this),
                                    new RightDoorAttack(this),
                                    new BarrageAttack(this)
                                ])
                            ]),
                            // new LeftDoorAttack(this),
                            // new RightDoorAttack(this),
                            // new BarrageAttack(this)
                        ]))
                    ])),
                    new Precondition(new StatusAction((delta) -> {
                        return FAIL;
                    }), new Sequence([
                        new Wait(.25, 1),
                        new Selector(RANDOM([1, 1, 1]), [
                            // new BigJump(this),
                            // new CircleBlast(this),
                            // new ChainFire(this)
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

        if (btree.process(delta) == FAIL) {
            // Intersting. why it fail?
        }
	}

    override function handleEnter(other:Body, data:Array<CollisionData>) {
        super.handleEnter(other, data);

        lastCollisionWall = false;

        if (other.object is Bullet) {
            handleHit(cast other.object);
        }


        // TODO: Keep track of when player touches boss
        if (other.object is Player) {
            lastCollisionPlayer = true;
        }
    }

    override function handleTerrainHit(other:Body, data:Array<CollisionData>) {
        lastCollisionWall = true;
    }
}

class RamAttack implements Node {
    var can:Dumpster;

    var started = false;
    var ramSpeed = 120;

    public function new(can:Dumpster) {
        this.can = can;
    }

    public function init(context:BTContext) {
        started = false;
        can.animation.finishCallback = (name) -> {
        }
    }

    public function process(delta:Float):NodeStatus {
        if (can.lastCollisionPlayer) {
            // "attack" successfully hit the player
            can.body.velocity.set(0, 0);
            can.lastCollisionPlayer = false;
            return SUCCESS;
        }
        if (can.lastCollisionWall) {
            // "attack" failed to hit the player and hit something else
            can.body.velocity.set(0, 0);
            can.lastCollisionWall = false;
            return FAIL;
        }

        if (!started) {
            // TODO: SFX dumpster starts moving at player
            var p = PlayState.me.player;
            var target = FlxPoint.get(p.body.x, p.body.y);
            var vel = FlxPoint.get().copyFrom(target).subtract(can.body.x, can.body.y).normalize().scale(ramSpeed);
            can.body.velocity.set(vel.x, vel.y);
            target.put();
            vel.put();
            started = true;
        }

        return RUNNING;
    }

    public function exit() {}
}

class LeftDoorAttack implements Node {
    var can:Dumpster;

    var bombSpeed = 100;

    var prepForAttack:Bool;
    var readyForAttack:Bool;
    var attackSent:Bool;
    var finished:Bool;

    public function new(can:Dumpster) {
        this.can = can;
    }

    public function init(context:BTContext) {
        prepForAttack = false;
        readyForAttack = false;
        attackSent = false;
        finished = false;

        can.animation.finishCallback = (name) -> {
            if (name == Dumpster.anims.leftDoorOpen) {
                readyForAttack = true;
            } else if (name == Dumpster.anims.leftDoorClose) {
                finished = true;
            }
        }
    }

    public function process(delta:Float):NodeStatus {
        if (!prepForAttack) {
            prepForAttack = true;
            can.animation.play(Dumpster.anims.leftDoorOpen);
            return RUNNING;
        }

        if (readyForAttack && !attackSent) {
            attackSent = true;

            var e = FlxPoint.get(can.body.x, can.body.y);
            var p = FlxPoint.get(PlayState.me.player.body.x, PlayState.me.player.body.y);
            p.subtractPoint(e);
            PlayState.me.AddEnemyBullet(new ClusterBomb(can.body.x, can.body.y, p.degrees, bombSpeed));
            e.put();
            p.put();

            can.animation.play(Dumpster.anims.leftDoorClose);
            return RUNNING;
        }

        if (finished) {
            return SUCCESS;
        }

        return RUNNING;
    }

    public function exit() {}
}

// TODO: Implement 'boomerang' attack
class RightDoorAttack extends LeftDoorAttack {
    public function new(can:Dumpster) {
        super(can);
    }
}

class BarrageAttack implements Node {
    var can:Dumpster;

    var launchSpeed = 800;
    var landSpeed = 1200;
    var delay = 1;

    var prepForAttack:Bool;
    var readyForAttack:Bool;
    var attackSent:Bool;
    var started:Bool;
    var finished:Bool;

    var leftSpawn = FlxPoint.get();
    var middleSpawn = FlxPoint.get();
    var rightSpawn = FlxPoint.get();

    var launchTracker:Map<Int, Bool>;

    public function new(can:Dumpster) {
        this.can = can;
    }

    public function init(context:BTContext) {
        prepForAttack = false;
        readyForAttack = false;
        attackSent = false;
        started = false;
        finished = false;

        can.animation.finishCallback = (name) -> {
            if (name == Dumpster.anims.bothDoorsOpen) {
                can.animation.play(Dumpster.anims.missileLoad);
                prepForAttack = true;
            } else if (name == Dumpster.anims.missileLoad) {
                can.animation.play(Dumpster.anims.missileFire);
                readyForAttack = true;
            } else if (name == Dumpster.anims.missileFire) {
                can.animation.play(Dumpster.anims.bothDoorsClosed);
                attackSent = true;
            } else if (name == Dumpster.anims.bothDoorsClosed) {
                finished = true;
            }
        }


        launchTracker = new Map<Int, Bool>();

        can.animation.callback = (name, frame, index) -> {
            if (name == Dumpster.anims.missileFire) {
				if (launchTracker.exists(frame)) {
					return;
				}

				launchTracker.set(frame, true);
                switch (frame) {
                    case 0 | 6:
                        // fire missile left
                        trace('firing left');
                        PlayState.me.AddTopEntity(new TankMissile(leftSpawn, launchSpeed, landSpeed, delay));
                    case 2 | 8:
                        // fire missile center
                        trace('firing middle');
                        PlayState.me.AddTopEntity(new TankMissile(middleSpawn, launchSpeed, landSpeed, delay));
                    case 4 | 10:
                        // fire missile right
                        trace('firing right');
                        PlayState.me.AddTopEntity(new TankMissile(rightSpawn, launchSpeed, landSpeed, delay));
                    default:
                }

            }
        };
    }

    public function process(delta:Float):NodeStatus {
        if (!started) {
            started = true;
            can.animation.play(Dumpster.anims.bothDoorsOpen);
        }

        can.getGraphicMidpoint(leftSpawn).subtract(23, 0);
        can.getGraphicMidpoint(middleSpawn).subtract(6, 0);
        can.getGraphicMidpoint(rightSpawn).add(9, 0);

        if (finished) {
            return SUCCESS;
        }

        return RUNNING;
    }

    public function exit() {}
}
