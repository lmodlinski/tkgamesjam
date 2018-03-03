package characters;

class Npc extends AbstractCharacter {
    public var accusation(default, null):Float;
    public var accusing(get, never):Bool;

    public function new(accusation:Float) {
        super();

        this.accusation = accusation;
    }

    public function get_accusing():Bool {
        return this.field.fart;
    }
}
