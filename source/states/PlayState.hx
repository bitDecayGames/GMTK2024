package states;

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

using states.FlxStateExt;

class PlayState extends FlxTransitionableState {
    var player:FlxSprite;
    var uiGroup:FlxGroup = new FlxGroup();
    var uiCamera:FlxCamera;
	var reticle:FlxSprite;
    
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

        player = new Player();
        add(player);

		// We likely only want to follow the player directly for cutscenes adn the like
		// FlxG.camera.follow(player);

        var item = new Item();
        item.y = 50;
        add(item);
		// We want the reticle to likely live on the UI camera for ease of tracking the mouse?
		// Or do we just want to project the mouse position into the game world cam?
		reticle = new Reticle();
		add(reticle);
		
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
