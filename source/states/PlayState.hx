package states;

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
    
    var player:FlxSprite;
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
    public var wallBodies:Array<Body> = [];
    
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

    override public function create() {
        super.create();
        Lifecycle.startup.dispatch();

        me = this;

        FlxG.camera.pixelPerfectRender = true;

		FlxEcho.init({
			// TODO: This needs to be the size of the world as we load it from LDTK (or whatever we use)
			width: FlxG.width,
			height: FlxG.height,
		});

        add(terrainGroup);
        add(entityRenderGroup);
        
        // Don't want to add these to the scene directly. let the render group handle them
        // add(playerGroup);
        // add(enemyGroup);
        // add(bulletGroup);

        // TODO: Confirm ordering here is proper
        loadLevel("Level_0");
		
		// add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));

        // Setting up the UI camera
        uiCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        uiCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(uiCamera, false);
        uiGroup.cameras = [uiCamera];
		// QuickLog.error('Example error');	

        // Adding the FL Studio logo as a static UI element in the center of the screen
        var flStudioLogo = new FlxSprite(50, 50, AssetPaths.items__png);
        uiGroup.add(flStudioLogo);
		// FmodManager.PlaySoundOneShot(FmodSFX.MenuHover);

        add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));
		// var cam = FlxG.camera;
		// DebugDraw.ME.drawCameraRect(cam.getCenterPoint().x - 5, cam.getCenterPoint().y - 5, 10, 10, DebugLayers.RAYCAST, FlxColor.RED);

        // Add uiGroup to the state
        add(uiGroup);
        
	}
    
    function loadLevel(levelName:String) {
        level = new levels.ldtk.Level(levelName);

        for (body in wallBodies) {
			FlxEcho.instance.world.remove(body);
			body.dispose();
		}
        wallBodies = [];

        uiGroup.forEach((f) -> f.destroy());
		uiGroup.clear();

        bulletGroup.forEach((f) -> f.destroy());
		bulletGroup.clear();

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

        AddBullet(new Bullet(new FlxPoint(0, 0), 0, 100));

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

        var testTrash = new TrashCan(100, 100);
        testTrash.add_to_group(enemyGroup);
        entityRenderGroup.add(testTrash);

		// We want the reticle to likely live on the UI camera for ease of tracking the mouse?
		// Or do we just want to project the mouse position into the game world cam?
		reticle = new Reticle();
        uiGroup.add(reticle);

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
        FlxEcho.listen(enemyBulletGroup, playerGroup, {
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
        // Only player is told of scraps
        FlxEcho.listen(scrapGroup, playerGroup, {
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
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

		reticle.getPosition(tmp);
		player.getPosition(tmp2);
		
		tmp.addPoint(tmp2).scale(.5);
		camera.focusOn(tmp);

        entityRenderGroup.sort(ZSorting.getSort(CENTER));
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
