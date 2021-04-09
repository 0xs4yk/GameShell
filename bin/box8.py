#!/usr/bin/env python3

import sys
import getopt


def text_width(B):
    return max(map(len, B))


def text_height(B):
    return len(B)


def normalize_text(text, margin=(0, 2, 0, 2), width=None, min_w=0, min_h=0):
    if width is None:
        width = text_width(text)
    width = max(min_w, width)

    m_top, m_right, m_bottom, m_left = margin
    text = [""]*m_top + text + [""]*m_bottom
    template = " "*m_left + "{:" + str(width) + "}" + " "*m_right
    for i in range(len(text)):
        text[i] = template.format(text[i])
    if len(text) < min_h:
        text.extend([" " * (width+m_right+m_left)]*(min_h-len(text)))
    return text


def make_box(text, margin=(0, 0, 0, 0),
             UL="+", UM="-", UR="+",
             ML="|",         MR="|",
             LL="+", LM="-", LR="+",
             neg_padding=(0, 0, 0, 0),
             default_margin=(0, 0, 0, 0),
             descr=""):

    if margin is None:
        margin = default_margin

    if isinstance(UL, str):
        UL = UL.split("\n")
    if isinstance(UM, str):
        UM = UM.split("\n")
    if isinstance(UR, str):
        UR = UR.split("\n")

    if isinstance(ML, str):
        ML = ML.split("\n")
    if isinstance(MR, str):
        MR = MR.split("\n")

    if isinstance(LL, str):
        LL = LL.split("\n")
    if isinstance(LM, str):
        LM = LM.split("\n")
    if isinstance(LR, str):
        LR = LR.split("\n")

    # check basic sanity
    assert text_height(UL) == text_height(UR)
    assert text_height(LL) == text_height(LR)
    assert text_width(UL) == text_width(LL)
    # assert text_width(UR) == text_width(LR)
    assert text_height(ML) == text_height(MR)
    assert text_width(UM) == text_width(LM)

    np_top, np_right, np_bottom, np_left = neg_padding
    m_top, m_right, m_bottom, m_left = margin

    if isinstance(text, str):
        text = text.split("\n")

    text = normalize_text(text, margin=margin, min_w=neg_padding[1]+neg_padding[3], min_h=neg_padding[0]+neg_padding[2])

    # Left and Right parts
    Left = []
    Right = []

    w = text_width(UL)
    for i in range(text_height(UL) - np_top):
        Left.append(UL[i].rstrip(" ").ljust(w, " "))
        Right.append(UR[i])

    w = text_width(UL) - np_left
    for i in range(text_height(UL) - np_top, text_height(UL)):
        Left.append(UL[i].rstrip(" ").ljust(w, " "))
        Right.append(UR[i][np_right:])

    w = text_width(UL) - np_left
    h = text_height(ML)
    for i in range(text_height(text) - np_top - np_bottom):
        Left.append(ML[i % h].rstrip(" ").ljust(w, " "))
        Right.append(MR[i % h][np_right:])

    w = text_width(UL) - np_left
    h = text_height(ML)
    for i in range(np_bottom):
        Left.append(LL[i].rstrip(" ").ljust(w, " "))
        Right.append(LR[i][np_right:])

    w = text_width(LL)
    for i in range(np_bottom, text_height(LL)):
        Left.append(LL[i].rstrip(" ").ljust(w, " "))
        Right.append(LR[i])

    # Middle part
    Middle = []

    w = text_width(text) - np_left - np_right
    for i in range(text_height(UL) - np_top):
        Middle.append(UM[i] * w)

    Middle.extend(text)

    for i in range(np_bottom, text_height(LM)):
        Middle.append(LM[i] * w)

    for i in range(len(Middle)):
        # print(Left[i] + "," + Middle[i] + "," + Right[i])
        print(Left[i] + Middle[i] + Right[i])


########################################################################
# box designs

Hash_box = {
    "UL": "#", "UM": "#", "UR": "#",
    "ML": "#",            "MR": "#",
    "LL": "#", "LM": "#", "LR": "#",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

Star_box = {
    "UL": "*", "UM": "*", "UR": "*",
    "ML": "*",            "MR": "*",
    "LL": "*", "LM": "*", "LR": "*",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

ADA_box = {
    "UL": "--", "UM": "-", "UR": "--",
    "ML": "--",            "MR": "--",
    "LL": "--", "LM": "-", "LR": "--",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

ADA2_box = {
    "UL": "--", "UM": "-", "UR": "",
    "ML": "--",            "MR": "",
    "LL": "--", "LM": "-", "LR": "",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

C_box = {
    "UL": "/*", "UM": "*", "UR": "*/",
    "ML": "/*",            "MR": "*/",
    "LL": "/*", "LM": "*", "LR": "*/",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

C2_box = {
    "UL": "/*", "UM": " ", "UR": "*/",
    "ML": "/*",            "MR": "*/",
    "LL": "/*", "LM": " ", "LR": "*/",
    "neg_padding": (1, 0, 1, 0),
    "default_margin": (0, 1, 0, 1),
}

C3_box = {
    "UL": "/*", "UM": " ", "UR": "*",
    "ML": " *",            "MR": "*",
    "LL": " *", "LM": " ", "LR": "*/",
    "neg_padding": (1, 0, 1, 0),
    "default_margin": (0, 1, 0, 1),
}

HTML_box = {
    "UL": "<!-- ", "UM": "-", "UR": " -->",
    "ML": "<!-- ",            "MR": " -->",
    "LL": "<!-- ", "LM": "-", "LR": " -->",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

HTML2_box = {
    "UL": "<!-- ", "UM": " ", "UR": " -->",
    "ML": "<!-- ",            "MR": " -->",
    "LL": "<!-- ", "LM": " ", "LR": " -->",
    "neg_padding": (1, 0, 1, 0),
    "default_margin": (0, 1, 0, 1),
}

CAML_box = {
    "UL": "(*", "UM": "*", "UR": "*)",
    "ML": "(*",            "MR": "*/",
    "LL": "(*", "LM": "*", "LR": "*/",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

Ascii_box = {
    "UL": "+", "UM": "-", "UR": "+",
    "ML": "|",            "MR": "|",
    "LL": "+", "LM": "-", "LR": "+",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

Unicode_simple_box = {
    "UL": "┌", "UM": "─", "UR": "┐",
    "ML": "│",            "MR": "│",
    "LL": "└", "LM": "─", "LR": "┘",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (1, 1, 1, 1),
}

Inverted_corners_box = {
    "UL": [
        "  |",
        "--+",
    ],
    "UR": [
        "|  ",
        "+--",
    ],
    "UM": [
        " ",
        "-",
    ],
    "LL": [
        "--+",
        "  |",
    ],
    "LR": [
        "+--",
        "|  ",
    ],
    "LM": [
        "-",
        " ",
    ],
    "ML": [
        "  |",
    ],
    "MR": [
        "|  ",
    ],
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}
Unicode_inverted_corners_box = {
    "UL": [
        " │",
        "─┼",
    ],
    "UR": [
        "│ ",
        "┼─",
    ],
    "UM": [
        " ",
        "─",
    ],
    "LL": [
        "─┼",
        " │",
    ],
    "LR": [
        "┼─",
        "│ ",
    ],
    "LM": [
        "─",
        " ",
    ],
    "ML": [
        " │",
    ],
    "MR": [
        "│ ",
    ],
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

Unicode_round_box = {
    "UL": "╭", "UM": "─", "UR": "╮",
    "ML": "│",            "MR": "│",
    "LL": "╰", "LM": "─", "LR": "╯",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

Unicode_bold_box = {
    "UL": "┏", "UM": "━", "UR": "┓",
    "ML": "┃",            "MR": "┃",
    "LL": "┗", "LM": "━", "LR": "┛",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

Unicode_double_box = {
    "UL": "╔", "UM": "═", "UR": "╗",
    "ML": "║",            "MR": "║",
    "LL": "╚", "LM": "═", "LR": "╝",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

Unicode_shadow_box = {
    "UL": "┌", "UM": "─", "UR": "┒",
    "ML": "│",            "MR": "┃",
    "LL": "┕", "LM": "━", "LR": "┛",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

Unicode_shadow2_box = {
    "UL": "┌", "UM": "─", "UR": "╖",
    "ML": "│",            "MR": "║",
    "LL": "╘", "LM": "═", "LR": "╝",
    "neg_padding": (0, 0, 0, 0),
    "default_margin": (0, 1, 0, 1),
}

Parchment_box = {
    "UL": [
        r"      _____",
        r"    / \    ",
        r"   |   |   ",
        r"    \_ |   ",
    ],
    "UR": [
        r"_  ",
        r" \.",
        r" |.",
        r" |.",
    ],
    "UM": [
        r"_",
        r" ",
        r" ",
        r" ",
    ],
    "LL": [
        r"       |   ",
        r"       |  /",
        r"       \_/_",
    ],
    "LR": [
        r"_|___ ",
        r"    /.",
        r"___/. ",
    ],
    "LM": [
        r"_",
        r" ",
        r"_",
    ],
    "ML": [
        r"       |   ",
    ],
    "MR": [
        r" |.",
    ],
    "neg_padding": (3, 1, 0, 3),
    "default_margin": (1, 1, 0, 1),
    "descr": "coded by Thomas Jensen <boxes@thomasjensen.com> (boxes)",
}

Scroll_box = {
    "UL": [
        r" __^__ ",
        r"( ___ )",
    ],
    "UR": [
        r" __^__ ",
        r"( ___ )",
    ],
    "UM": [
        r" ",
        r"-",
    ],
    "LL": [
        r" |___| ",
        r"(_____)",
    ],
    "LR": [
        r" |___| ",
        r"(_____)",
    ],
    "LM": [
        r" ",
        r"-",
    ],
    "ML": [
        r" | / | ",
    ],
    "MR": [
        r" | \ | ",
    ],
    "neg_padding": (0, 1, 1, 1),
    "default_margin": (1, 2, 1, 2),
    "descr": "coded by Thomas Jensen <boxes@thomasjensen.com> (boxes)",
}

Parchment2_box = {
    "UL": [
        r"     ___",
        r"()==( ",
        r"     '__",
    ],
    "UR": [
        r"_     ",
        r"(@==()",
        r"_'|   ",
    ],
    "UM": [
        r"_",
        r" ",
        r"_",
    ],
    "LL": [
        r"     __)",
        r"()==(   ",
        r"     '--",
    ],
    "LR": [
        r"__|    ",
        r" (@==()",
        r"-'     ",
    ],
    "LM": [
        r"_",
        r" ",
        r"-",
    ],
    "ML": [
        r"       |",
    ],
    "MR": [
        r"  |",
    ],
    "neg_padding": (0, 2, 0, 0),
    "default_margin": (1, 1, 1, 1),
}

Parchment3_box = {
    "UL": [
        r"  ,---",
        r" (_\  ",
    ],
    "UR": [
        r"----.  ",
        r"     \ ",
    ],
    "UM": [
        r"-",
        r" ",
    ],
    "LL": [
        r"   _| ",
        r"  (_/_",
        r"      ",
        r"      ",
        r"      ",
    ],
    "LR": [
        r"      |",
        r"(*)___/",
        r" \\    ",
        r"  ))   ",
        r"  ^    ",
    ],
    "LM": [
        r" ",
        r"_",
        r" ",
        r" ",
        r" ",
    ],
    "ML": [
        r"    |",
    ],
    "MR": [
        r"      |",
    ],
    "neg_padding": (1, 5, 1, 0),
    "default_margin": (1, 1, 1, 1),
}
# cf http://ascii.co.uk/art/scroll

Parchment4_box = {
    "UL": [
        r' /"\/\_..',
        r'(     _||',
        r' \_/\/ ||',
    ],
    "UR": [
        r'-._/\/"\ ',
        r'||_     )',
        r'|| \/\_/ '
    ],
    "UM": [
        r"-",
        r" ",
        r" ",
    ],
    "LL": [
        r' /"\/\_|-',
        r'(     _| ',
        r' \_/\/ `-'
    ],
    "LR": [
        r'-|_/\/"\ ',
        r' |_     )',
        r"-' \/\_/ ",
    ],
    "LM": [
        r"-",
        r" ",
        r"-",
    ],
    "ML": [
        r"       ||",
    ],
    "MR": [
        r"||",
    ],
    "neg_padding": (2, 0, 0, 0),
    "default_margin": (1, 1, 1, 1),
    "descr": "coded by Tristano Ajmone <tajmone@gmail.com> (boxes)",
}

Scroll2_box = {
    "UL": [
        r" / ~~~~~",
        r"|  /~~\ ",
        r"|\ \   |",
        r"| \   /|",
        r"|  ~~  |",
    ],
    "UR": [
        r"~~~~~ \ ",
        r" /~~\  |",
        r"|   / /|",
        r"|\   / |",
        r"|  ~~  |",
    ],
    "UM": [
        r"~",
        r" ",
        r" ",
        r" ",
        r" ",
    ],
    "LL": [
        r" \     |",
        r"  \   / ",
        r"   ~~~  ",
    ],
    "LR": [
        r"|     / ",
        r" \   /  ",
        r"  ~~~   ",
    ],
    "LM": [
        r"~",
        r" ",
        r" ",
    ],
    "ML": [
        r"|      |",
    ],
    "MR": [
        r"|      |",
    ],
    "neg_padding": (4, 0, 0, 0),
    "default_margin": (1, 1, 1, 1),
    "descr": "coded by Thomas Jensen <boxes@thomasjensen.com> (boxes)",
}

Twisted_box = {
    "UL": [
        r"._____. ._____. .__",
        r"| ._. | | ._. | | .",
        r"| !_| |_|_|_! | | !",
        r"!___| |_______! !__",
        r".___|_|_| |________",
        r"| ._____| |________",
        r"| !_! | | |        ",
        r"!_____! | |        ",
        r"._____. | |        ",
        r"| ._. | | |        ",
    ],
    "UR": [
        r"__. ._____. ._____.",
        r". | | ._. | | ._. |",
        r"! | | !_| |_|_|_! |",
        r"__! !___| |_______!",
        r"________|_|_| |___.",
        r"____________| |_. |",
        r"        | | ! !_! |",
        r"        | | !_____!",
        r"        | | ._____.",
        r"        | | | ._. |",
    ],
    "UM": [
        r"_",
        r"_",
        r"_",
        r"_",
        r"_",
        r"_",
        r" ",
        r" ",
        r" ",
        r" ",
    ],
    "LL": [
        r"| !_! | | |        ",
        r"!_____! | |        ",
        r"._____. | |        ",
        r"| ._. | | |        ",
        r"| !_| |_|_|________",
        r"!___| |____________",
        r".___|_|_| |___. .__",
        r"| ._____| |_. | | .",
        r"| !_! | | !_! | | !",
        r"!_____! !_____! !__",
    ],
    "LR": [
        r"        | | ! !_! |",
        r"        | | !_____!",
        r"        | | ._____.",
        r"        | | | ._. |",
        r"________| |_|_|_! |",
        r"________| |_______!",
        r"__. .___|_|_| |___.",
        r". | | ._____| |_. |",
        r"! | | !_! | | !_! |",
        r"__! !_____! !_____!",
    ],
    "LM": [
        r" ",
        r" ",
        r" ",
        r" ",
        r"_",
        r"_",
        r"_",
        r"_",
        r"_",
        r"_",
    ],
    "ML": [
        r"| | | | | |       ",
    ],
    "MR": [
        r"        | | | | | |",
    ],
    "neg_padding": (4, 8, 4, 8),
    "default_margin": (1, 1, 0, 1),
    "descr": "design by Michael Naylor, coded by Tristano Ajmone <tajmone@gmail.com> (boxes)",
}


BOXES = {
    "ASCiI": Ascii_box,
    "hash": Hash_box,
    "star": Star_box,
    "ADA": ADA_box,
    "ADA2": ADA2_box,
    "C": C_box,
    "C2": C2_box,
    "C3": C3_box,
    "HTMl": HTML_box,
    "HTMl2": HTML2_box,
    "CAMl": CAML_box,
    "Unicode": Unicode_simple_box,
    "Unicode_round": Unicode_round_box,
    "Unicode_double": Unicode_double_box,
    "Unicode_bold": Unicode_bold_box,
    "Unicode_shadow": Unicode_shadow_box,
    "Unicode_shadow2": Unicode_shadow2_box,
    "Parchment": Parchment_box,
    "Parchment2": Parchment2_box,
    "Parchment3": Parchment3_box,
    "Parchment4": Parchment4_box,
    "Scroll": Scroll_box,
    "Scroll2": Scroll2_box,
    "Unicode_inverted": Unicode_inverted_corners_box,
    "Inverted": Inverted_corners_box,
    "Twisted": Twisted_box
}


LOREM = """
Lorem ipsum dolor sit amet, consectetur adipisicing
elit, sed do eiusmod tempor incididunt ut labore et
dolore magna aliqua. Ut enim ad minim veniam, quis
nostrud exercitation ullamco laboris nisi ut aliquip ex
ea commodo consequat.  Duis aute irure dolor in
reprehenderit in voluptate velit esse cillum dolore eu
fugiat nulla pariatur. Excepteur sint occaecat
cupidatat non proident, sunt in culpa qui officia
deserunt mollit anim id est laborum.
""".strip("\n")


def Box(text, margin, box):
    make_box(text, margin, **box)


def error(msg, retcode):
    sys.stderr.write("\n*** " + msg + " ***\n\n")
    sys.exit(retcode)


def main():

    # parsing the command line arguments
    short_options = "hb:lm:"

    long_options = ["help", "box=", "list", "margin=", "lorem"]

    try:
        opts, args = getopt.getopt(sys.argv[1:], short_options, long_options)
    except getopt.GetoptError as err:
        error(str(err), 1)

    # default values
    box = "ASCII"
    margin = None
    text = None

    for o, a in opts:
        if o in ["-h", "--help"]:
            print("""
Usage: {prog:} [options]
    adds a "box" around UTF-8 encoded stdin
    inspired (copied) from the program "boxes", by Thomas Jensen

Options:
   -h,  --help                      display this message
   -b <design>, --box=<design>      choose box design
   -l, --list                       show available designs
   -m <...>, --margin=<...>         adds margin around text (top, right, bottom, left)
                                        default: use design's default
   --lorem                          test a design with Lorem text
""".format(prog=sys.argv[0]))
            sys.exit(0)
        elif o in ["-l", "--list"]:
            designs = sorted(list(BOXES.keys()))
            for b in designs:
                print("*"*72)
                m = ",".join(map(str, BOXES[b]["default_margin"]))
                print("design: '{}' (default margin={})".format(b, m))
                d = BOXES[b].get("descr", "")
                if d:
                    print(d)
                print("")
                Box(LOREM, None, BOXES[b])
                print("")
            sys.exit(0)
        elif o in ["-m", "--margin"]:
            try:
                tmp = tuple(map(int, a.split(",")))
                assert len(tmp) == 4
                margin = tmp
            except Exception as err:
                error("Invalid margin: '{}' ({})".format(a, err), 1)
        elif o in ["-b", "--box"]:
            if a in BOXES:
                box = a
            else:
                error("Unknown box design: '{}'".format(a))
        elif o in ["--lorem"]:
            text = LOREM
        else:
            error("You shouldn't see this!!!", 2)

    if text is None:
        text = []
        for l in sys.stdin:
            text.append(l.rstrip("\n"))

    Box(text, margin, BOXES[box])


if __name__ == "__main__":
    main()
