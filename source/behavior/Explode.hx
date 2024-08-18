package behavior;

import bitdecay.behavior.tree.NodeStatus;
import bitdecay.behavior.tree.BTContext;
import entities.EchoSprite;
import bitdecay.behavior.tree.Node;

class Explode implements Node {
    var can:EchoSprite;
    public function new(can:EchoSprite) {
        this.can = can;
    }

    public function init(context:BTContext) {}

    public function process(delta:Float):NodeStatus {
        can.kill();
        return SUCCESS;
    }

    public function exit() {}
}