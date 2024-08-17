package states;

import flixel.FlxCamera;
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

using states.FlxStateExt;

class PlayState extends FlxTransitionableState {
    var player:FlxSprite;
    var uiGroup:FlxGroup = new FlxGroup();
    var uiCamera:FlxCamera;

    override public function create() {
        super.create();
        Lifecycle.startup.dispatch();

        FlxG.camera.pixelPerfectRender = true;

        player = new Player();
        add(player);

		FlxG.camera.follow(player);

        var item = new Item();
        item.y = 50;
        add(item);

        // Setting up the UI camera
        uiCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        uiCamera.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(uiCamera, false);
        uiGroup.cameras = [uiCamera];

        // Adding the FL Studio logo as a static UI element in the center of the screen
        var flStudioLogo = new FlxSprite(50, 50, AssetPaths.items__png);
        uiGroup.add(flStudioLogo);
		// FmodManager.PlaySoundOneShot(FmodSFX.MenuHover);

        add(Achievements.ACHIEVEMENT_NAME_HERE.toToast(true, true));

        QuickLog.error('Example error');

        // Add uiGroup to the state
        add(uiGroup);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        var cam = FlxG.camera;
        DebugDraw.ME.drawCameraRect(cam.getCenterPoint().x - 5, cam.getCenterPoint().y - 5, 10, 10, DebugLayers.RAYCAST, FlxColor.RED);
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
