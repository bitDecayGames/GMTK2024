package states;

import entities.ScrapCollector;
import ui.CharacterDialog;
import entities.Scrap;
import bitdecay.flixel.sorting.ZSorting;
import flixel.FlxObject;
import flixel.util.FlxSort;
import entities.Bullet;
import entities.TrashCan;
import entities.EchoSprite;
import echo.Body;
import echo.util.TileMap;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import entities.Reticle;
import entities.Item;
import flixel.util.FlxColor;
import debug.DebugLayers;
import achievements.Achievements;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxSprite;
import flixel.FlxG;
import bitdecay.flixel.debug.DebugDraw;
import flixel.group.FlxGroup;
import echo.FlxEcho;
import levels.ldtk.Level;

using states.FlxStateExt;

using echo.FlxEcho;

class PlayState extends FlxTransitionableState {
    public static var me:PlayState;
    
    public var player:Player;

    var uiCamera:FlxCamera;

	var reticle:FlxSprite;

    // TODO: We probably should hide the project within the level file
	public var level:Level;

    // groups for rendering
    var uiGroup:FlxGroup = new FlxGroup();
    public var terrainGroup = new FlxGroup();
    public var entityRenderGroup = new FlxTypedGroup<FlxSprite>();

    // groups for tracking things
    public var bulletGroup = new FlxGroup();
    public var enemyBulletGroup = new FlxGroup();
    public var playerGroup = new FlxGroup();
    public var enemyGroup = new FlxGroup();
    public var scrapGroup = new FlxGroup();
    public var generalInteractables = new FlxGroup();
    public var wallBodies:Array<Body> = [];
    public var topGroup = new FlxGroup();
    
	var tmp = FlxPoint.get();
	var tmp2 = FlxPoint.get();
    
    public function AddBullet(bullet:Bullet) {
        bullet.add_to_group(bulletGroup);
        // TODO: Do we want bullets on a separate render group so they are always above the player/enemies? (for readability)
        entityRenderGroup.add(bullet);
    }

    public function AddEnemyBullet(bullet:Bullet) {
        bullet.add_to_group(enemyBulletGroup);
        // TODO: Do we want bullets on a separate render group so they are always above the player/enemies? (for readability)
        entityRenderGroup.add(bullet);
    }
    
    public function AddScrap(scrap:Scrap) {
        scrap.add_to_group(scrapGroup);
        entityRenderGroup.add(scrap);
    }

    public function AddInteractable(int:EchoSprite) {
        int.add_to_group(generalInteractables);
        entityRenderGroup.add(int);
    }

    override public function create() {
        super.create();
        Lifecycle.startup.dispatch();

        me = this;

		FlxEcho.init({
			// TODO: This needs to be the size of the world as we load it from LDTK (or whatever we use)
			width: FlxG.width,
			height: FlxG.height,
		});

        add(terrainGroup);
        add(entityRenderGroup);
        add(topGroup);
        
        // Don't want to add these to the scene directly. let the render group handle them
        // add(playerGroup);
        // add(enemyGroup);
        // add(bulletGroup);

        // TODO: Confirm ordering here is proper
        loadLevel("Level_1");
		FmodManager.PlaySong(FmodSongs.WhereAmI);
		
		// add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));

        // Setting up the UI camera
        uiCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        uiCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(uiCamera, false);
        uiGroup.cameras = [uiCamera];

        // add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));
		// var cam = FlxG.camera;
		// DebugDraw.ME.drawCameraRect(cam.getCenterPoint().x - 5, cam.getCenterPoint().y - 5, 10, 10, DebugLayers.RAYCAST, FlxColor.RED);

        // Add uiGroup to the state
        add(uiGroup);
        
        var dialogTest = new CharacterDialog(TINK, "Hello buddy. I'd be happy to help you out, but I'm going to need some scrap for my troubles.");
        uiGroup.add(dialogTest);
	}
    
    function loadLevel(levelName:String) {
        for (body in wallBodies) {
			FlxEcho.instance.world.remove(body);
			body.dispose();
		}
        wallBodies = [];

        uiGroup.forEach((f) -> f.destroy());
		uiGroup.clear();

        bulletGroup.forEach((f) -> f.destroy());
		bulletGroup.clear();

        generalInteractables.forEach((f) -> f.destroy());
		generalInteractables.clear();

        scrapGroup.forEach((f) -> f.destroy());
		scrapGroup.clear();

        enemyGroup.forEach((f) -> f.destroy());
		enemyGroup.clear();

        playerGroup.forEach((f) -> f.destroy());
		playerGroup.clear();
		player = null;

        entityRenderGroup.forEach((f) -> {
            if (f.exists) {
                f.destroy();
            }
        });
        entityRenderGroup.clear();

        FlxEcho.clear();

        level = new levels.ldtk.Level(levelName);

        bulletGroup.add_group_bodies();
        enemyGroup.add_group_bodies();

        camera.scroll.set();
		camera.setScrollBoundsRect(0, 0, level.bounds.width, level.bounds.height);
		FlxEcho.instance.world.set(0, 0, level.bounds.width, level.bounds.height);

        wallBodies = wallBodies.concat(TileMap.generate(level.rawCollisionInts, 16, 16, level.rawTerrainTilesWide, level.rawTerrainTilesWide, 0, 0, 0));
		for (body in wallBodies) {
			FlxEcho.instance.world.add(body);
		}
        
        camera.setScrollBoundsRect(0, 0, level.bounds.width, level.bounds.height);

        terrainGroup.insert(0, level.terrainGfx);

        player = new Player(level.playerSpawnPoint.x, level.playerSpawnPoint.y);
        player.add_to_group(playerGroup);
        entityRenderGroup.add(player);

        for (door in level.doors) {
            AddInteractable(door);
        }

        // var testTrash = new TrashCan(100, 100);
        // testTrash.add_to_group(enemyGroup);
        // entityRenderGroup.add(testTrash);

        var testRecepticle = new ScrapCollector(150, 150);
        AddInteractable(testRecepticle);

		// We want the reticle to likely live on the UI camera for ease of tracking the mouse?
		// Or do we just want to project the mouse position into the game world cam?
		reticle = new Reticle();
        topGroup.add(reticle);

        configureListeners();
    }

    function configureListeners() {
        FlxEcho.instance.world.listen(FlxEcho.get_group_bodies(enemyGroup), wallBodies, {
			separate: true,
			enter: (a, b, o) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleEnter(b, o);
				}
			},
			exit: (a, b) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleExit(b);
				}
			}
		});
        FlxEcho.instance.world.listen(FlxEcho.get_group_bodies(playerGroup), wallBodies, {
			separate: true,
			enter: (a, b, o) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleEnter(b, o);
				}
			},
			exit: (a, b) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleExit(b);
				}
			}
		});
        FlxEcho.instance.world.listen(FlxEcho.get_group_bodies(bulletGroup), wallBodies, {
			separate: true,
			enter: (a, b, o) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleEnter(b, o);
                    aSpr.kill();
				}                
			},
			exit: (a, b) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleExit(b);
				}
			}
		});
        FlxEcho.listen(enemyGroup, playerGroup, {
			separate: true,
			enter: (a, b, o) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleEnter(b, o);
				}                
			},
			exit: (a, b) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleExit(b);
				}
			}
		});
        // Only player is told of bullets
        FlxEcho.listen(playerGroup, enemyBulletGroup, {
			separate: false,
			enter: (a, b, o) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleEnter(b, o);
				}                
			},
			exit: (a, b) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleExit(b);
				}
			}
		});
        // Only enemies are told of bullets
        FlxEcho.listen(enemyGroup, bulletGroup, {
			separate: false,
			enter: (a, b, o) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleEnter(b, o);
				}                
			},
			exit: (a, b) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleExit(b);
				}
			}
		});
        // Player is told of scrap collisions
        FlxEcho.listen(playerGroup, scrapGroup, {
			separate: false,
			enter: (a, b, o) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleEnter(b, o);
				}                
			},
            stay: (a, b, o) -> {
                // Slightly special case as we know scrap can be delayed in pickup. we want this to feel right
                if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleEnter(b, o);
				}            
            },
			exit: (a, b) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleExit(b);
				}
			}
		});
        // Interactables told of player touch to help isolate code
        FlxEcho.listen(generalInteractables, playerGroup, {
			separate: true,
			enter: (a, b, o) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleEnter(b, o);
				}                
			},
            stay: (a, b, o) -> {
                // Slightly special case as we know scrap can be delayed in pickup. we want this to feel right
                if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleEnter(b, o);
				}            
            },
			exit: (a, b) -> {
				if (a.object is EchoSprite) {
					var aSpr:EchoSprite = cast a.object;
					aSpr.handleExit(b);
				}
			}
		});
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

		reticle.getPosition(tmp);
		player.getPosition(tmp2);
		
        var focus = FlxPoint.get();
        focus.copyFrom(tmp).subtractPoint(tmp2).scale(0.2);
        focus.addPoint(tmp2);
		camera.focusOn(focus);

        entityRenderGroup.sort(ZSorting.getSort(BOTTOM));
    }

    override public function onFocusLost() {
        super.onFocusLost();
        this.handleFocusLost();
    }

    override public function onFocus() {
        super.onFocus();
        this.handleFocus();
    }
}
