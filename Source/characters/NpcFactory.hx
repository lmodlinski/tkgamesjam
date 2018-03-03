package characters;

import characters.talks.SmalltalkAnswer;
import openfl.Vector;
import characters.talks.Smalltalk;
class NpcFactory {
    public function new() {

    }

    public function createNpc(type:NpcType):Npc {
        switch(type){
            case NpcType.PIZZA_DELIVERY_GUY:
            case NpcType.COWORKER_MALE:
            case NpcType.COWORKER_FEMALE:
            case NpcType.SERVICE_GUY:
            case NpcType.NEW_HIRE:
            case NpcType.BOSS:
        }

        var smalltalks:Vector<Smalltalk> = new Vector<Smalltalk>();
        smalltalks.push(this.createSmalltalk());

        return new Npc(new BossAsset(), 0.1, 10.0 + Random.int(0, 15), 4, 6, smalltalks);
    }

    public function createSmalltalk():Smalltalk {
        var smalltalk:Smalltalk = new Smalltalk('test_smalltalk', 'sample text', 10.0, true);
        smalltalk.addAnswer(new SmalltalkAnswer('answer_1', '1. sample answer 1'));
        smalltalk.addAnswer(new SmalltalkAnswer('answer_2', '2. sample answer 2'), true);
        smalltalk.addAnswer(new SmalltalkAnswer('answer_3', '3. sample answer 3'));

        return smalltalk;
    }
}
