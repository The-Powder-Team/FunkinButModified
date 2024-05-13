package funkin.play.event;

import flixel.tweens.FlxTween;
import flixel.FlxCamera;
import flixel.tweens.FlxEase;
// Data from the chart
import funkin.data.song.SongData;
import funkin.data.song.SongData.SongEventData;
// Data from the event schema
import funkin.play.event.SongEvent;
import funkin.data.event.SongEventSchema;
import funkin.data.event.SongEventSchema.SongEventFieldType;

/**
 * This class represents a handler for scroll speed events.
 *
 * Example: Scroll speed change of both strums from 1x to 1.3x:
 * ```
 * {
 *   'e': 'ScrollSpeed',
 *   "v": {
 *      "scroll": "1.3",
 *      "duration": "4",
 *      "ease": "linear"
 *    }
 * }
 * ```
 */
class ScrollSpeedEvent extends SongEvent
{
  public function new()
  {
    super('ScrollSpeed');
  }

  static final DEFAULT_SCROLL:Float = 1;
  static final DEFAULT_DURATION:Float = 4.0;
  static final DEFAULT_EASE:String = 'linear';
  static final DEFAULT_STRUMLINE:String = 'both'; // my special little trick

  public override function handleEvent(data:SongEventData):Void
  {
    // Does nothing if there is no PlayState.
    if (PlayState.instance == null) return;

    var scroll:Float = data.getFloat('scroll') ?? DEFAULT_SCROLL;

    var duration:Float = data.getFloat('duration') ?? DEFAULT_DURATION;

    var ease:String = data.getString('ease') ?? DEFAULT_EASE;

    var strumline:String = data.getString('strumline') ?? DEFAULT_STRUMLINE;

    var strumlineNames:Array<String> = [];

    if (scroll == 0)
    {
      // if the parameter is set to 0, reset the scroll speed to normal.
      scroll = PlayState.instance?.currentChart?.scrollSpeed ?? 1.0;
    }

    switch (strumline)
    {
      case 'both':
        strumlineNames = ['playerStrumline', 'opponentStrumline'];
      default:
        strumlineNames = [strumline + 'Strumline'];
    }
    // If it's a string, check the value.
    switch (ease)
    {
      case 'INSTANT':
        PlayState.instance.tweenScrollSpeed(scroll, 0, null, strumlineNames);
      default:
        var durSeconds = Conductor.instance.stepLengthMs * duration / 1000;
        var easeFunction:Null<Float->Float> = Reflect.field(FlxEase, ease);
        if (easeFunction == null)
        {
          trace('Invalid ease function: $ease');
          return;
        }

        PlayState.instance.tweenScrollSpeed(scroll, durSeconds, easeFunction, strumlineNames);
    }
  }

  public override function getTitle():String
  {
    return 'Scroll Speed';
  }

  /**
   * ```
   * {
   *   'scroll': FLOAT, // Target scroll level.
   *   'duration': FLOAT, // Duration in steps.
   *   'ease': ENUM, // Easing function.
   * }
   * @return SongEventSchema
   */
  public override function getEventSchema():SongEventSchema
  {
    return new SongEventSchema([
      {
        name: 'scroll',
        title: 'Scroll Amount',
        defaultValue: 0.0,
        step: 0.1,
        type: SongEventFieldType.FLOAT,
        units: 'x'
      },
      {
        name: 'duration',
        title: 'Duration',
        defaultValue: 4.0,
        step: 0.5,
        type: SongEventFieldType.FLOAT,
        units: 'steps'
      },
      {
        name: 'ease',
        title: 'Easing Type',
        defaultValue: 'linear',
        type: SongEventFieldType.ENUM,
        keys: [
          'Linear' => 'linear',
          'Instant (Ignores Duration)' => 'INSTANT',
          'Sine In' => 'sineIn',
          'Sine Out' => 'sineOut',
          'Sine In/Out' => 'sineInOut',
          'Quad In' => 'quadIn',
          'Quad Out' => 'quadOut',
          'Quad In/Out' => 'quadInOut',
          'Cube In' => 'cubeIn',
          'Cube Out' => 'cubeOut',
          'Cube In/Out' => 'cubeInOut',
          'Quart In' => 'quartIn',
          'Quart Out' => 'quartOut',
          'Quart In/Out' => 'quartInOut',
          'Quint In' => 'quintIn',
          'Quint Out' => 'quintOut',
          'Quint In/Out' => 'quintInOut',
          'Expo In' => 'expoIn',
          'Expo Out' => 'expoOut',
          'Expo In/Out' => 'expoInOut',
          'Smooth Step In' => 'smoothStepIn',
          'Smooth Step Out' => 'smoothStepOut',
          'Smooth Step In/Out' => 'smoothStepInOut',
          'Elastic In' => 'elasticIn',
          'Elastic Out' => 'elasticOut',
          'Elastic In/Out' => 'elasticInOut'
        ]
      },
      {
        name: 'strumline',
        title: 'Target Strumline',
        defaultValue: 'both',
        type: SongEventFieldType.ENUM,
        keys: ['Both' => 'both', 'Player' => 'player', 'Opponent' => 'opponent']
      }
    ]);
  }
}