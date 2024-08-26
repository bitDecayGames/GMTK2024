package;

import states.PlayState;
import entities.Player.GunHas;

class GlobalStateConfig {
    public var gunHas:GunHas;

    public function new() {}
}

class GlobalState {
    public static function SetGameState(globalStateConfig:GlobalStateConfig) {
        if (globalStateConfig.gunHas != null) {
            PlayState.me.player.setGun(globalStateConfig.gunHas);
        }
    }

    public static function SetGameStateByLevelName(levelName:String) {
        var globalStateConfig = new GlobalStateConfig();
        if (levelName == "Level_2") {
            globalStateConfig.gunHas = PISTOL;
        }

        SetGameState(globalStateConfig);
    }
}


