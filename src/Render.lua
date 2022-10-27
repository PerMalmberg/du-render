---@enum ShapeType
ShapeType = {
    Bezier = 0,
    Box = 1,
    BoxRounded = 2,
    Circle = 3,
    Image = 4,
    Line = 5,
    Polygon = 6,
    Text = 7,
}

---@enum AlignHor
AlignHor = {
    Left = 0,
    Center = 1,
    Right = 2,
}

---@enum AlignVer
AlignVer = {
    Ascender = 0,
    Top = 1,
    Middle = 2,
    Baseline = 3,
    Bottom = 4,
    Descender = 5,
}

---@alias n number
---@alias i integer

---@class Render
---@field addBezier fun(layer:i, x1:n, y1:n, x2:n, y2:n, x3:n, y3:n)
---@field addBox fun(layer:i, x:n, y:n, width:n, height:n)
---@field addBoxRounded fun(layer:i, x:n, y:n, width:n, height:n, radius:n)
---@field addCircle fun(layer:i, x:n, y:n, radius:n)
---@field addImage fun(layer:i, image:i, x:n, y:n, width:n, height:n)
---@field addImageSub fun(layer:i, image:i, x:n, y:n, width:n, height:n, subX:n, subY:n, subWidth:n, subHeight:n)
---@field addLine fun(layer:i, x1:n, y1:n, x2:n, y2:n)
---@field addQuad fun(layer:i, x1:n, y1:n, x2:n, y2:n, x3:n, y3:n, x4:n, y4:n)
---@field addText fun(layer:i, font:i, text:string, x:n, y:n)
---@field addTriangle fun(layer:i, x1:n, y1:n, x2:n, y2:n, x3:n, y3:n)
---@field createLayer fun():i
---@field getAvailableFontCount fun():i
---@field getAvailableFontName fun(index):string
---@field getCursor fun():n,n Returns a tuple containing the (x, y) coordinates of the cursor, or (-1, -1) if the screen is not currently raycasted
---@field getCursorDown fun():boolean True if the mouse cursor is currently pressed down on the screen, false otherwise
---@field getCursorPressed fun():boolean True if the mouse cursor has been pressed down on the screen at any time since the last script execution, false otherwise
---@field getCursorReleased fun():boolean True if the mouse cursor has been released on the screen at any time since the last script execution, false otherwise
---@field getDeltaTime fun():n Return the time, in seconds, since the screen was last updated.
---@field getFontMetrics fun(font:i):n,n A tuple containing the maximal ascender and descender, respectively, of the given font
---@field getFontSize fun(font:i):n The font size in vertical pixels
---@field getImageSize fun(image:i):n,n A tuple containing the width and height, respectively, of the image, or (0, 0) if the image is not yet loaded
---@field getInput fun():string The input string, as set by the screen unit API function setScriptInput, or an empty string if there is no current input
---@field getLocale fun():string The locale, currently one of "en-US", "fr-FR", or "de-DE"
---@field getRenderCost fun():n The cost of all rendering operations performed by the render script so far (at the time of the call to this function)
---@field getRenderCostMax fun():n The render cost limit. A script that exceeds this limit (in one execution) will not render correctly and will instead throw an error. Note that this value may change between version releases
---@field getResolution fun():n,n A tuple containing the (width, height) of the screen's render surface, in pixels
---@field getTextBounds fun(font:i, text:string):n,n A tuple containing the width and height, respectively, of the bounding box
---@field getTime fun():n Time, in seconds, since the render script started running
---@field isImageLoaded fun(image:i):boolean True if the image is fully loaded and ready to use, false otherwise
---@field loadImage fun(url:string):i Load an image to be used with addImage from the given URL
---@field loadFont fun(name:string, size:i):i Load a font to be used with addText
---@field logMessage fun(message:string) Log a message for debugging purposes. If the "enable output in Lua channel" box is checked on the editor panel for the given screen, the message will be displayed in the Lua channel.
---@field requestAnimationFrame fun(frames:i) Request that this screen should be redrawn in a certain number of frames. A screen that requires highly-fluid animations should call requestAnimationFrame(1) before it returns.
---@field setBackgroundColor fun(red:n, green:n, blue:n) Set the background color of the screen
---@field setDefaultFillColor fun(layer:i, shape:ShapeType, red:n, green:n, blue:n, alpha:n)
---@field setDefaultRotation fun(layer:i, shape:ShapeType, rotation:number)
---@field setDefaultShadow fun(layer:i, shape:ShapeType, radius:n, red:n, green:n, blue:n, alpha:n) Set the default shadow for all subsequent shapes of the given type added to the given layer
---@field setDefaultStrokeColor fun(layer:i, shape:ShapeType, red:n, green:n, blue:n, alpha:n)
---@field setDefaultStrokeWidth fun(layer:i, shape:ShapeType, strokeWidth:n)
---@field setDefaultTextAlign fun(layer:i, hor:AlignHor, ver:AlignVer)
---@field setFontSize fun(font:i, size:i) Set the size at which a font will render.
---@field setLayerClipRect fun(layer:i, x:n, y:n, width:n, height:n) Set a clipping rectangle applied to the layer as a whole.
---@field setLayerOrigin fun(layer:i, x:n, y:n) Set the transform origin of a layer; layer scaling and rotation are applied relative to this origin
---@field setLayerRotation fun(layer:i, rotationRad:n) Set a rotation applied to the layer as a whole, relative to the layer's transform origin
---@field setLayerScale fun(layer:i, widthScale:n, hightScale:n) Set a scale factor applied to the layer as a whole, relative to the layer's transform origin.
---@field setLayerTranslation fun(layer:i, tx:n, ty:n) Set a translation applied to the layer as a whole
---@field setNextFillColor fun(layer:i, red:n, green:n, blue:n, alpha:n) Set the fill color of the next rendered shape on the given layer; has no effect on shapes that do not support a fill color
---@field setNextRotation fun(layer:i, rotationRad:n) Set the rotation of the next rendered shape on the given layer; has no effect on shapes that do not support rotation
---@field setNextRotationDegrees fun(layer:i, rotationDeg:n) Set the rotation of the next rendered shape on the given layer; has no effect on shapes that do not support rotation
---@field setNextShadow fun(layer:i, radius, red:n, green:n, blue:n, alpha:n) Set the shadow of the next rendered shape on the given layer; has no effect on shapes that do not support a shadow
---@field setNextStrokeColor fun(layer:i, red:n, green:n, blue:n, alpha:n) Set the stroke color of the next rendered shape on the given layer; has no effect on shapes that do not support a stroke color
---@field setNextStrokeWidth fun(layer:i, strokeWidth:i) Set the stroke width of the next rendered shape on the given layer; has no effect on shapes that do not support a stroke width
---@field setNextTextAlign fun(layer:i, hor:AlignHor, ver:AlignVer) Set the text alignment of the next rendered text string on the given layer. By default, text is anchored horizontally on the left, and vertically on the baseline.
---@field setOutput fun(output:string) Set the script's output string, which can be retrieved via a programming board with the screen unit API function getScriptOutput



local Render = {}
Render.__index = _ENV

---@type Render
local singelton

---Gets the RenderScript instance
---@return Render
function Render.Instance()
    if singelton then
        return singelton
    end
    singelton = {
        addBezier = _ENV.addBezier,
        addBox = _ENV.addBox,
        addBoxRounded = _ENV.addBoxRounded,
        addCircle = _ENV.addCircle,
        addImage = _ENV.addImage,
        addImageSub = _ENV.addImageSub,
        addLine = _ENV.addLine,
        addQuad = _ENV.addQuad,
        addText = _ENV.addText,
        addTriangle = _ENV.addTriangle,
        createLayer = _ENV.createLayer,
        getAvailableFontCount = _ENV.getAvailableFontCount,
        getAvailableFontName = _ENV.getAvailableFontName,
        getCursor = _ENV.getCursor,
        etCursorDown = _ENV.etCursorDown,
        getCursorPressed = _ENV.getCursorPressed,
        getCursorReleased = _ENV.getCursorReleased,
        getDeltaTime = _ENV.getDeltaTime,
        getFontMetrics = _ENV.getFontMetrics,
        getFontSize = _ENV.getFontSize,
        getImageSize = _ENV.getImageSize,
        getInput = _ENV.getInput,
        getLocale = _ENV.getLocale,
        getRenderCost = _ENV.getRenderCost,
        getRenderCostMax = _ENV.getRenderCostMax,
        getResolution = _ENV.getResolution,
        getTextBounds = _ENV.getTextBounds,
        getTime = _ENV.getTime,
        isImageLoaded = _ENV.isImageLoaded,
        loadImage = _ENV.loadImage,
        loadFont = _ENV.loadFont,
        logMessage = _ENV.logMessage,
        requestAnimationFrame = _ENV.requestAnimationFrame,
        setBackgroundColor = _ENV.setBackgroundColor,
        setDefaultFillColor = _ENV.setDefaultFillColor,
        setDefaultRotation = _ENV.setDefaultRotation,
        setDefaultShadow = _ENV.setDefaultShadow,
        setDefaultStrokeColor = _ENV.setDefaultStrokeColor,
        setDefaultStrokeWidth = _ENV.setDefaultStrokeWidth,
        setDefaultTextAlign = _ENV.setDefaultTextAlign,
        setFontSize = _ENV.setFontSize,
        setLayerClipRect = _ENV.setLayerClipRect,
        setLayerOrigin = _ENV.setLayerOrigin,
        setLayerRotation = _ENV.setLayerRotation,
        setLayerScale = _ENV.setLayerScale,
        setLayerTranslation = _ENV.setLayerTranslation,
        setNextFillColor = _ENV.setNextFillColor,
        setNextRotation = _ENV.setNextRotation,
        setNextRotationDegrees = _ENV.setNextRotationDegrees,
        setNextShadow = _ENV.setNextShadow,
        setNextStrokeColor = _ENV.setNextStrokeColor,
        setNextStrokeWidth = _ENV.setNextStrokeWidth,
        setNextTextAlign = _ENV.setNextTextAlign,
        setOutput = _ENV.setOutput,
    }

    setmetatable(singelton, Render)
    return singelton
end

return Render
