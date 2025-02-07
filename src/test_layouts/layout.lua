local layout = {
    fonts = {
        Play10 = {
            font = "Play",
            size = 10
        },
        Play24 = {
            font = "Play",
            size = 24
        },
        Montserrat15 = {
            font = "Montserrat",
            size = 15
        },
        Montserrat100 = {
            font = "Montserrat",
            size = 100
        }
    },
    styles = {
        circle_style_1 = {
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 1
            }
        },
        circle_style_2 = {
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 2
            }
        },
        circle_style_3 = {
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 3
            }
        },
        circle_style_4 = {
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 4
            }
        },
        circle_style_5 = {
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 5
            }
        },
        circle_style_6 = {
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 6
            }
        },
        circle_style_7 = {
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 7
            }
        },
        circle_style_8 = {
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 8
            }
        },
        circle_style_9 = {
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 9
            }
        },
        circle_style_hover_1 = {
            stroke = {
                color = "r1,g0,b0,a1",
                distance = 5
            }
        },
        circle_style_hover_2 = {
            stroke = {
                color = "r0,g1,b0,a1",
                distance = 5
            }
        },
        line_style = {
            stroke = {
                color = "r1,g0.843,b0,a1",
                distance = 5
            }
        },
        blue_green_border = {
            align = "h0,v1",
            stroke = {
                color = "r0,g1,b0,a1",
                distance = 1
            },
            fill = "r0,g0,b1,a1",
            rotation = 45,
            shadow = {
                color = "r0.2,g0,b0,a1",
                distance = 2
            }
        },
        transparent_red_border = {
            align = "h0,v1",
            stroke = {
                color = "r1,g0,b0,a1",
                distance = 1
            },
            fill = "r1,g2,b3,a0",
            rotation = 0,
            shadow = {
                color = "r1,g1,b1,a0",
                distance = 0
            }
        },
        gauge_style_base = {
            align = "h0,v1",
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 1
            },
            fill = "r0,g0,b0.1,a1",
            rotation = 0,
            shadow = {
                color = "r1,g1,b1,a0",
                distance = 0
            }
        },
        gauge_style_bar = {
            align = "h0,v1",
            stroke = {
                color = "r1,g1,b1,a1",
                distance = 0
            },
            fill = "r0,g1,b0,a1",
            rotation = 0,
            shadow = {
                color = "r1,g1,b1,a0",
                distance = 0
            }
        },
        text_style = {
            align = "h0,v1",
            stroke = {
                color = "r0,g1,b0,a1",
                distance = 1
            },
            fill = "r0.1,g0.1,b0.1,a1"
        },
        column_text_style = {
            align = "h1,v1",
            fill = "#ffffffff"
        },
        fuel_text = {
            align = "h0,v1",
            fill = "r0.4,g0,b0,a1"
        },
        image = {
            fill = "#ffffffff",
            stroke = {
                distance = 2,
                color = "#ffffff"
            }
        },
        ascender = {
            align = "h0,v0",
            fill = "#ffffffff"
        },
        ascenderHover = {
            align = "h0,v0",
            fill = "#2f6fd0ff"
        },
        top = {
            align = "h0,v1",
            fill = "#ffffffff"
        },
        topHover = {
            align = "h0,v1",
            fill = "#2f6fd0ff"
        },
        middle = {
            align = "h2,v2",
            fill = "#ffffffff"
        },
        middleHover = {
            align = "h2,v2",
            fill = "#2f6fd0ff"
        },
        baseline = {
            align = "h0,v3",
            fill = "#ffffffff"
        },
        baselineHover = {
            align = "h0,v3",
            fill = "#2f6fd0ff"
        },
        bottom = {
            align = "h0,v4",
            fill = "#ffffffff"
        },
        bottomHover = {
            align = "h0,v4",
            fill = "#2f6fd0ff"
        },
        descender = {
            align = "h0,v5",
            fill = "#ffffffff"
        },
        descenderHover = {
            align = "h0,v5",
            fill = "#2f6fd0ff"
        }

    },
    pages = {
        firstpage = {
            components = {
                {
                    type = "box",
                    layer = 1,
                    visible = true,
                    pos1 = "(1,1)",
                    pos2 = "(100,100)",
                    corner_radius = 2,
                    style = "blue_green_border",
                    mouse = {
                        click = {
                            command =
                            "$str(path{path/to/data:key}:format{My command: '%s'}:interval{1}:init{init value}:op{mul})"
                        },
                        inside = {
                            set_style = "transparent_red_border"
                        }
                    }
                },
                {
                    type = "box",
                    layer = 1,
                    visible = true,
                    pos1 = "(100,100)",
                    pos2 = "(150,150)",
                    corner_radius = 2,
                    style = "blue_green_border",
                    mouse = {
                        click = {
                            command = "just text command"
                        },
                        inside = {
                            set_style = "transparent_red_border"
                        }
                    }
                },
                {
                    type = "box",
                    layer = 1,
                    visible = true,
                    pos1 = "(200,0)",
                    pos2 = "(250,613)",
                    corner_radius = 5,
                    style = "gauge_style_base"
                },
                {
                    type = "box",
                    layer = 1,
                    visible = true,
                    pos1 = "$vec2(path{gauge/fuel:value}:init{(248,611)}:interval{0.1}:percent{(248,2)})",
                    pos2 = "(202,611)",
                    corner_radius = 125,
                    style = "gauge_style_bar"
                },
                {
                    type = "text",
                    layer = 2,
                    visible = true,
                    pos1 = "(100,100)",
                    style = "text_style",
                    font = "Montserrat100",
                    text = "Awesome text!",
                    mouse = {
                        click = {
                            command = "command from text"
                        },
                        inside = {
                            set_style = "missing style"
                        }
                    }
                },
                {
                    type = "line",
                    layer = 3,
                    visible = true,
                    pos1 = "$vec2(path{gauge/fuel:value}:init{(248,611)}:interval{0.1}:percent{(248,2)})",
                    pos2 = "$vec2(path{gauge/fuel:value}:init{(255,611)}:interval{0.1}:percent{(255,2)})",
                    style = "line_style",
                    replicate = {
                        x_step = 200,
                        y_step = 0,
                        x_count = 2,
                        y_count = 1
                    }
                },
                {
                    type = "text",
                    layer = 2,
                    visible = true,
                    text = "$num(path{gauge/fuel:value100}:init{0}:format{Fuel level: %0.2f})",
                    pos1 = "$vec2(path{gauge/fuel:value}:init{(258,601)}:interval{0.1}:percent{(258,10)})",
                    style = "fuel_text",
                    font = "Montserrat15"
                },
                {
                    type = "circle",
                    layer = 2,
                    visible = true,
                    pos1 = "(400,200)",
                    style = "circle_style_[#]",
                    radius = 25,
                    mouse = {
                        inside = {
                            set_style = "$str(path{circle/style:hover}:init{circle_style_hover_1})"
                        }
                    },
                    replicate = {
                        x_step = 50,
                        y_step = 50,
                        x_count = 3,
                        y_count = 3
                    }
                },
                {
                    type = "text",
                    layer = 2,
                    visible = true,
                    pos1 = "(400,200)",
                    font = "Play10",
                    style = "column_text_style",
                    text = "[#]",
                    mouse = {
                        inside = {
                            set_style = "$str(path{circle/style:hover}:init{circle_style_hover_1})"
                        }
                    },
                    replicate = {
                        x_step = 50,
                        y_step = 50,
                        x_count = 3,
                        y_count = 3,
                        column_mode = true
                    }
                },
                {
                    type = "image",
                    layer = 3,
                    pos1 = "(600,300)",
                    dimensions = "(20,20)",
                    sub = "(0,0)",
                    subDimensions = "(20,20)",
                    url = "assets.prod.novaquark.com/94617/4158c26e-9db3-4a28-9468-b84207e44eec.png",
                    style = "image"
                },
                {
                    type = "image",
                    layer = 3,
                    pos1 = "(650,300)",
                    dimensions = "(20,20)",
                    sub = "(0,21)",
                    subDimensions = "(20,20)",
                    url = "assets.prod.novaquark.com/94617/4158c26e-9db3-4a28-9468-b84207e44eec.png",
                    style = "image"
                },
                {
                    type = "text",
                    layer = 4,
                    pos1 = "(800,500)",
                    text = "other page...",
                    style = "text_style",
                    font = "Play24",
                    mouse = {
                        click = {
                            command = "activatepage{page_with_hidden}"
                        }
                    }
                },
                {
                    type = "text",
                    pos1 = "(800,540)",
                    text = "Text page...",
                    style = "text_style",
                    layer = 4,
                    font = "Play24",
                    mouse = {
                        click = {
                            command = "activatepage{textPage}"
                        }
                    }
                }
            }
        },
        page_with_hidden = {
            components = {
                {
                    type = "box",
                    layer = 1,
                    visible = "$bool(path{:visible}:init{false}:interval{0})",
                    pos1 = "(1,1)",
                    pos2 = "(100,100)",
                    corner_radius = 2,
                    style = "blue_green_border"
                },
                {
                    type = "box",
                    layer = 2,
                    visible = true,
                    pos1 = "(100,100)",
                    pos2 = "(150,150)",
                    corner_radius = 2,
                    style = "blue_green_border"
                },
                {
                    type = "text",
                    layer = 3,
                    pos1 = "(800,500)",
                    text = "first page...",
                    style = "text_style",
                    font = "Play10",
                    mouse = {
                        click = {
                            command = "activatepage{firstpage}"
                        }
                    }
                }
            }
        },
        textPage = {
            components = {
                {
                    type = "text",
                    layer = 1,
                    style = "ascender",
                    pos1 = "(50,75)",
                    font = "Play24",
                    text = "Ascender xXjTñ ÅÄÖ",
                    mouse = {
                        inside = {
                            set_style = "ascenderHover"
                        }
                    }
                },
                {
                    type = "text",
                    layer = 1,
                    style = "top",
                    pos1 = "(50,125)",
                    font = "Play24",
                    text = "Top xXjTñ ÅÄÖ",
                    mouse = {
                        inside = {
                            set_style = "topHover"
                        }
                    }
                },
                {
                    type = "text",
                    layer = 1,
                    style = "middle",
                    pos1 = "(800,200)",
                    font = "Play24",
                    text = "Middle xXjTñ ÅÄÖ",
                    mouse = {
                        inside = {
                            set_style = "middleHover"
                        }
                    }
                },
                {
                    type = "text",
                    layer = 1,
                    style = "baseline",
                    pos1 = "(50,275)",
                    font = "Play24",
                    text = "Baseline xXjTñ ÅÄÖ",
                    mouse = {
                        inside = {
                            set_style = "baselineHover"
                        }
                    }
                },
                {
                    type = "text",
                    layer = 1,
                    style = "bottom",
                    pos1 = "(50,350)",
                    font = "Play24",
                    text = "Bottom xXjTñ ÅÄÖ",
                    mouse = {
                        inside = {
                            set_style = "bottomHover"
                        }
                    }
                },
                {
                    type = "text",
                    layer = 1,
                    style = "descender",
                    pos1 = "(50,425)",
                    font = "Play24",
                    text = "Descender xXjTñ ÅÄÖ",
                    mouse = {
                        inside = {
                            set_style = "descenderHover"
                        }
                    }
                },
            }
        }
    }
}

return layout
