# du-render
Dual Universe RenderScript Framework

This framework consists of a few parts:
- Screen Driver - powers the screen via RenderScript
- Layout Engine - Feeds the Screen Engine vith elements to draw
  - Data Bindings - Binds element properties to received data.
- Communication Stream - Handles communication with programming board or seat.
- SVG to Layout converter - External tool to convert SVG to a format suitable for use with the Layout Engine.

> du-render uses DU-LuaC for compilation; all instructions assume that is what is being used.

## Screen Driver (Screen side)

Using the driver is just two lines of code:

```lua
local driver = require("Driver").Instance()
driver.Animate(true)
```

This sets up the screen to communicate and prepares the Layout Engine to receive a layout.

The call to
```lua
driver.Animate(true)
```
Enables animation on _every frame_ with some render information being displayed; you can pass `false` to disable the information.

Instead of `Animate` you can call
```lua
driver.Render(frames, displayStats)
```
and adjust the responsiveness of the screen as well as opting/in/out of the render information. This is likely the call you want to do as it uses much less resources and it will still update the screen where there is data to be processed.

## Programming Board/Seat/Remote Controller

On the controller side, you need an instance of the `Steam` class, which in turn needs the following passed to it:
- Link to screen, i.e. the slot the screen is connected to.
- A callback function that receives the data received from the screen.
- A callback function that receives timeout events.

The screen can only received data as a string so any data must be serialized as such. The screen expects data in Json format, serialized as a string. When data is received it looks for the precence of the following keys, if either of these are found, the contents of that key is used and the remaining data discarded. If none of the keys are found, the entire message is considered as data to be bound to elements on the screen.
> Each message must contain only one of these keys, or none to be treated as data to be processed by the Layout Engine and its data-bindings.

`screen_layout` - the contents of this key is expected to be in a format supported by the Layout Engine and thus used to build the screen layout.

`activate_page` - this key is expected to contain a single string and the value is used as the name of the page to activate in the layout.


In the update event, use the `Stream.Write` function, to send data to the screen. There's a `Stream.WaitingToSend` function that can be called to check if there are outstanding messages to be sent already. If there are you should not call `Write` as that will just enqueue another message, eventually causing out-of-memory errors. As such, it is up to the application to hold the data until the stream is ready to send more data.

## Layouts

The Layout Engine support a custom Json-based data format to define screen layouts with pages and data bindings. It is loosely based on SVG and supports the properties supported by RenderScript.

The base structure looks as follows.

```json
{
  "fonts": {
  },
  "styles": {
  },
  "pages": {
    "pageName": {
      "components": []
    }
  }
}
```

- `pages` contains an arbitrary number of named pages that can be activated as needed and each page contains an arbitrary number of components.

### Fonts

- `fonts` contains zero or up to 8 named font definitions with font name and size.
  ```json
    "Play10": {
      "font": "Play",
      "size": 10
    }
    ```

For each font, `font` must be one of the fonts supported by RenderScript. The size in in pixels.

### Styles

- `styles` contains one or more named style definitions referenced by components.
  ```json
    "styleName": {
        "align": "h0,v1",
        "stroke": {
            "color": "r0,g1,b0,a1",
            "distance": 1
        },
        "fill": "r0,g0,b1,a1",
        "rotation": 45,
        "shadow": {
            "color": "r0.2,g0,b0,a1",
            "distance": 2
        }
    }
    ```

`align` refers to the font alignment as per RenderScript, where the x and Y in `hX,vY` matches the horizontal and vertical alignment.

Colors support values 0.0...5.0 in the `r`, `g` and `b` components, as well as 0.0...1.0 in the `a` component.

`rotation` is in degrees, counter clock-wise

`distance` is in pixels

`visible` determines if an item is visible

`hitable` determines if an item takes part in hit detection. An item must also be visible to take part.

If a style is missing, the engine will create a default one using crimosn as the color scheme.

### Components

Each page has one or more components with its respective properties.

```json
{
  "type": "box",
  "layer": 1,
  "visible": true,
  "hitable": true
  "pos1": "(1,1)",
  "pos2": "(100,100)",
  "corner_radius": 2,
  "style": "blue_green_border",
  "mouse": {
      "click": {
          "command": "data sent to controller"
      },
      "inside": {
          "set_style": "style used when mouse is over the component"
      }
  }
}
```

Each type has a `type` which can be on of `box`, `text`, `line` or `circle`.
All positions/dimensions are in pixels.
These attributes can be bound:
* visible
* hitable
* pos1...posN
* style
* mouse/click/command
* mouse/inside/set_style

### Data Bindings

The Layout Engine supports data bindings using the following syntax:

`$<type>(path{path/to:value}:init{<initial value>}:interval{number}:percent{<value at 100%>}:op{<operator>})`

- `<type>` can be
  - `num` - a number, expects values to be numbers
  - `str` - string, expects values to be strings
  - `vec2` - 2D vector, expects values in format `(x,y)`. When providing values, use a `Vec2` to contain the values.
  - `boolean` - a boolean, expects values to be booleans
- `path{path/to:value}` specifies the path in the incoming data structure where the `value` is to be found.
- `init{<value>}` specifies the initial value to use.
- `percent{<value>}` specifies the value to use when the incoming value is 1, i.e. this makes the actual value interpolated between the initial value and the specified in this tag.
- `interval{<number>}` specifies, in fractions of a second, minimum time between a value is updated on the screen. Good to prevent texts from becoming unreadable when they are updated often.
- `op{<operator>}` specifies an operator to apply on the inital value and the the incoming value.
  - <operator> can be
    - `mul` - multiplies the inital value with modifier
    - `div` - divides the inital value with modifier
- `format{}` - specifies a Lua format string, such as `my value: %f` or `string: %s` for numbers and strings respectively. Vec2 does not support format strings.

Also styles can be bound to data using `$str()`; make sure to include an `init{}` with a default style.

### Replication

Components can be replicated in X and Y in the desired steps. To do so, add the following to the component data:

```json
 "replicate": {
    "x_step": 50,
    "y_step": 50,
    "x_count": 3,
    "y_count": 3
}
```

This example would cause a 3x3 replication with a step size of 50 on the respective axes.

It is also possible to place a `[#]` in an string value, such as styles and data bindings, to change it to the current replication count, starting at 1.

### Local page activation

By entering a value into the `mouse/click/command` key, in the format `activatepage{page_name}`, a component can activate another page.