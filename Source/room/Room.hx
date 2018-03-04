package room;

import openfl.Assets;
import flash.media.SoundChannel;
import openfl.Vector;
import haxe.ds.IntMap;

import characters.Npc;
import characters.Player;
import characters.AbstractCharacter;

import openfl.display.Sprite;

class Room extends Sprite {
    public static inline var VENTILATING_COOLDOWN:Float = 30.0;
    public static inline var VENTILATING_DURATION:Float = 3.0;
    public static inline var VENTILATING_DECR:Float = 0.2;

    public var ventilating(default, set):Float;
    public var ventilating_cooldown(default, set):Float;

    public var ventilating_on(get, never):Bool;
    public var ventilating_decr(get, never):Float;

    public var ventilator(default, null):RoomField;
    public var entrance(default, null):RoomField;

    public var fields(default, null):IntMap<IntMap<RoomField>>;
    public var fields_width(default, null):Int;
    public var fields_height(default, null):Int;

    public var player(default, null):Player;
    public var npcs(default, null):Vector<Npc>;

    public var sound_ventilator(default, null):SoundChannel;

    public function new(width:Int, height:Int, entrance_x:Int, entrance_y:Int, ventilator_x:Int, ventilator_y:Int) {
        super();

        this.ventilating = 0.0;
        this.ventilating_cooldown = 0.0;

        this.fields_width = width;
        this.fields_height = height;

        this.npcs = new Vector<Npc>();

        this.fields = new IntMap<IntMap<RoomField>>();
        for (i in 0 ... (this.fields_height = height)) {
            var fields_row:IntMap<RoomField> = new IntMap<RoomField>();

            for (j in 0 ... (this.fields_width = width)) {
                var field:RoomField = new RoomField(this, i, j);
                fields_row.set(j, field);

                if (entrance_x == i && entrance_y == j) {
                    this.entrance = field;
                }

                if (ventilator_x == i && ventilator_y == j) {
                    this.ventilator = field;
                }

                this.addChild(field);
                field.x = i * field.width;
                field.y = j * field.width;
            }

            this.fields.set(i, fields_row);
        }
    }

    public function onEnterFrame(delta:Int):Void {
        for (i in 0 ... this.fields_width) {
            for (j in 0 ... this.fields_height) {
                var field:RoomField = this.fields.get(i).get(j);

                if (null != field.occupied) {
                    if (Std.is(field.occupied, Npc)) {
                        var npc:Npc = cast(field.occupied, Npc);

                        if (npc.accusing) {
                            this.player.accuse(npc.accusation);
                        }
                    }
                }

                field.onEnterFrame(delta);
            }
        }

        var seconds:Float = delta / 1000.0;

        if (0 < this.ventilating) {
            this.ventilating -= seconds;
        } else {
            this.ventilating_cooldown -= seconds;
        }
    }

    public function add(character:AbstractCharacter, target:RoomField):Void {
        if (Std.is(character, Player)) {
            this.player = cast(character, Player);
        } else if (Std.is(character, Npc)) {
            this.npcs.push(cast(character, Npc));
        }

        target.occupy(character);
    }

    public function leave(character:AbstractCharacter):Void {
        if (Std.is(character, Npc)) {
            var npc:Npc = this.npcs.splice(this.npcs.indexOf(cast(character, Npc)), 1).get(0);
            npc.field.free();
        }
    }

    public function move(character:AbstractCharacter, direction:Direction):Void {
        var field:RoomField = character.field;
        if (null != field) {
            var target:RoomField = null;

            target = this.getFieldNextTo(field, direction);
            character.direction = direction;

            if (null != target && null == target.occupied) {
                field.free();

                target.occupy(character);
            }
        }
    }

    public function step(character:AbstractCharacter, target:RoomField):Void {
        if (null != character.field) {
            character.direction = character.field.getDirection(target);
        }

        if (null == target.occupied) {
            var field:RoomField = character.field;
            if (null != field) {
                field.free();
            }

            target.occupy(character);
        }
    }

    public function getRandomNpc():Npc {
        return 0 < this.npcs.length ? this.npcs.get(Std.int(Math.random() * this.npcs.length)) : null;
    }

    public function getEmptyAround(field:RoomField):Vector<RoomField> {
        var fields:Vector<RoomField> = new Vector<RoomField>();
        var target:RoomField = null;

        // left
        target = this.getFieldNextTo(field, Direction.LEFT);
        if (null != target && null == target.occupied) {
            fields.push(target);
        }

        // up
        target = this.getFieldNextTo(field, Direction.UP);
        if (null != target && null == target.occupied) {
            fields.push(target);
        }

        // right
        target = this.getFieldNextTo(field, Direction.RIGHT);
        if (null != target && null == target.occupied) {
            fields.push(target);
        }

        // down
        target = this.getFieldNextTo(field, Direction.DOWN);
        if (null != target && null == target.occupied) {
            fields.push(target);
        }

        return fields;
    }

    public function getFieldNextTo(field:RoomField, direction:Direction):RoomField {
        switch(direction){
            case Direction.DOWN:
                if (field.field_y < this.fields_height - 1) {
                    return fields.get(field.field_x).get(field.field_y + 1);
                }
            case Direction.LEFT:
                if (0 < field.field_x) {
                    return fields.get(field.field_x - 1).get(field.field_y);
                }
            case Direction.UP:
                if (0 < field.field_y) {
                    return fields.get(field.field_x).get(field.field_y - 1);
                }
            case Direction.RIGHT:
                if (field.field_x < this.fields_width - 1) {
                    return fields.get(field.field_x + 1).get(field.field_y);
                }
        }

        return null;
    }

    public function ventilate():Void {
        if (0 >= this.ventilating && 0 >= this.ventilating_cooldown && this.player.field == this.ventilator) {
            this.ventilating = VENTILATING_DURATION;
            this.ventilating_cooldown = VENTILATING_COOLDOWN;

            this.sound_ventilator = Assets.getSound('assets/Sounds/fan.mp3').play(0.0, 1);
        }
    }

    public function get_ventilating_on():Bool {
        return 0 < this.ventilating;
    }

    public function get_ventilating_decr():Float {
        return VENTILATING_DECR;
    }

    public function set_ventilating(value:Float):Float {
        if (0.0 > value) {
            this.ventilating = 0.0;

            if (null != this.sound_ventilator) {
                this.sound_ventilator.stop();
                this.sound_ventilator = null;
            }
        } else {
            this.ventilating = value;
        }

        return this.ventilating;
    }

    public function set_ventilating_cooldown(value:Float):Float {
        if (0.0 > value) {
            this.ventilating_cooldown = 0.0;
        } else {
            this.ventilating_cooldown = value;
        }

        return this.ventilating_cooldown;
    }
}
