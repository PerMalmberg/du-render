local layout = {
    fonts = {
        Play10 = {
            font = "Play",
            size = 10
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
        fuel_text = {
            align = "h0,v1",
            fill = "r0.4,g0,b0,a1"
        },
        image = {
            fill = "#ff0000ff",
            stroke = {
                distance = 2,
                color = "#ffffff"
            }
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
                            command = "$str(path{path/to/data:key}:format{My command: '%s'}:interval{1}:init{init value}:op{mul})"
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
                    style = "circle_style_{#}",
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
                    type = "image",
                    layer = 3,
                    pos1 = "(600,300)",
                    dimensions = "(600,300)",
                    url = "assets.prod.novaquark.com/94617/35a7afe8-f911-4513-b9b4-e5b1ef20216d.png",
                    style = "image"
                },
                {
                    type = "text",
                    layer = 4,
                    pos1 = "(800,500)",
                    text = "other page...",
                    style = "text_style",
                    font = "Play",
                    mouse = {
                        click = {
                            command = "activatepage{page_with_hidden}"
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
                    font = "Play",
                    mouse = {
                        click = {
                            command = "activatepage{firstpage}"
                        }
                    }
                }
            }
        }
    }
}

return layout
