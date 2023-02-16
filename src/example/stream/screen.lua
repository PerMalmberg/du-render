local driver = require("Driver").Instance()
local offline =
{
    fonts = {
        offline = {
            font = "Montserrat",
            size = 180
        }
    },
    styles = {
        text_style = {
            align = "h1,v2",
            fill = "r1,g0,b0,a1"
        }
    },
    pages = {
        offline = {
            components = {
                {
                    type = "text",
                    layer = 1,
                    visible = true,
                    pos1 = "(512,305)",
                    style = "text_style",
                    font = "offline",
                    text = "Offline!"
                }
            }
        }
    }
}

driver.SetOfflineLayout(offline)
driver.Animate(true)
