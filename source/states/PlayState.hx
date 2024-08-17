package states;

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
    var uiCamera:FlxCamera;

    var player:FlxSprite;
	var reticle:FlxSprite;

    // TODO: We probably should hide the project within the level file
	public var level:Level;

    var uiGroup:FlxGroup = new FlxGroup();
    public var terrainGroup = new FlxGroup();

    public var playerGroup = new FlxGroup();
    public var wallBodies:Array<Body> = [];
    
	var tmp = FlxPoint.get();
	var tmp2 = FlxPoint.get();

    override public function create() {
        super.create();
        Lifecycle.startup.dispatch();

        FlxG.camera.pixelPerfectRender = true;

		FlxEcho.init({
			// TODO: This needs to be the size of the world as we load it from LDTK (or whatever we use)
			width: FlxG.width,
			height: FlxG.height,
		});

        add(terrainGroup);
        add(playerGroup);

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

        playerGroup.forEach((f) -> f.destroy());
		playerGroup.clear();
		player = null;

        FlxEcho.clear();

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

		// We want the reticle to likely live on the UI camera for ease of tracking the mouse?
		// Or do we just want to project the mouse position into the game world cam?
		reticle = new Reticle();
        uiGroup.add(reticle);

        configureListeners();
    }

    function configureListeners() {
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
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

		reticle.getPosition(tmp);
		player.getPosition(tmp2);
		
		tmp.addPoint(tmp2).scale(.5);
		camera.focusOn(tmp);

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
