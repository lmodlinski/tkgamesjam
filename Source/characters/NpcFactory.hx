package characters;

import haxe.ds.StringMap;
import haxe.Json;
import openfl.Assets;
import characters.talks.SmalltalkAnswer;
import openfl.Vector;
import characters.talks.Smalltalk;
class NpcFactory {
    private static var json_map(null, null):StringMap<Vector<Smalltalk>> = new StringMap<Vector<Smalltalk>>();

    public function new() {

    }

    public function createNpc(type:NpcType):Npc {
        switch(type){
            case NpcType.PIZZA_DELIVERY_GUY:
                return new Npc(new PizzaDeliveryGuyAsset(), NpcType.PIZZA_DELIVERY_GUY, 0.01, Random.int(10, 20), 1, 3, this.createSmalltalks('assets/smalltalks/pizza_delivery_guy.json'));
            case NpcType.COWORKER_MALE:
                return new Npc(new CoworkerMaleAsset(), NpcType.COWORKER_MALE, 0.03, Random.int(0, 45), 2, 2, this.createSmalltalks('assets/smalltalks/coworker_male.json'));
            case NpcType.COWORKER_FEMALE:
                return new Npc(new CoworkerFemaleAsset(), NpcType.COWORKER_FEMALE, 0.03, Random.int(30, 50), 5, 6, this.createSmalltalks('assets/smalltalks/coworker_female.json'));
            case NpcType.SERVICE_GUY:
                return new Npc(new ServiceGuyAsset(), NpcType.SERVICE_GUY, 0.02, Random.int(25, 50), 2, 3, this.createSmalltalks('assets/smalltalks/service_guy.json'));
            case NpcType.NEW_HIRE:
                return new Npc(new NewHireAsset(), NpcType.NEW_HIRE, 0.002, Random.int(0, 20), 2, 6, this.createSmalltalks('assets/smalltalks/new_hire.json'));
            case NpcType.BOSS:
                return new Npc(new BossAsset(), NpcType.BOSS, 0.05, Random.int(90, 100), 1, 2, this.createSmalltalks('assets/smalltalks/boss.json'));
        }
    }

    public function createSmalltalks(json:String):Vector<Smalltalk> {
        if (!json_map.exists(json)) {
            var smalltalks:Vector<Smalltalk> = new Vector<Smalltalk>();

            for (smalltalk_raw in cast(Json.parse(Assets.getText(json)).smalltalks, Array<Dynamic>)) {
                var smalltalk:Smalltalk = new Smalltalk(smalltalk_raw.id, smalltalk_raw.text, smalltalk_raw.shame_decr, smalltalk_raw.shame_stop);
                var correct_answer:String = smalltalk_raw.correct;

                var answers_raw:Array<Dynamic> = cast(smalltalk_raw.answers, Array<Dynamic>);

                for (i in 0 ... answers_raw.length) {
                    var answer_raw = answers_raw[i];
                    smalltalk.addAnswer(new SmalltalkAnswer(answer_raw.id, '' + (i + 1) + '. ' + answer_raw.text), answer_raw.id == correct_answer);
                }

                smalltalks.push(smalltalk);
            }

            json_map.set(json, smalltalks);
        }

        return json_map.get(json);
    }
}
