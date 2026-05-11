"""Unit tests for the in-repo ReScript Pygments lexer.

Mirrors the token coverage of the IntelliJ plugin's JFlex grammar
(see ``Rescript.flex``) so regressions surface as failing assertions
rather than silently un-highlighted code blocks in the built docs.
"""

from __future__ import annotations

import sys
from pathlib import Path

# ``sphinx-docs/_ext`` is added to sys.path by conf.py at Sphinx build time;
# under pytest we replicate the same shim so tests can import the lexer
# without depending on Sphinx loading conf.py.
_EXT_DIR = Path(__file__).resolve().parent.parent / "_ext"
if str(_EXT_DIR) not in sys.path:
    sys.path.insert(0, str(_EXT_DIR))

from pygments.token import (  # noqa: E402
    Comment,
    Keyword,
    Name,
    Number,
    Operator,
    Punctuation,
    String,
)
from rescript_lexer import RescriptLexer  # noqa: E402


def _tokens(source: str):
    """Tokenize ``source`` and drop pure-whitespace runs for terser asserts."""
    lexer = RescriptLexer()
    return [(token_type, value) for token_type, value in lexer.get_tokens(source) if value.strip()]


def _has_token(tokens, token_type, value):
    return (token_type, value) in tokens


def _token_text(tokens, *token_types):
    return "".join(v for t, v in tokens if t in token_types or any(t in tt for tt in token_types))


# ---------------------------------------------------------------------------
# Registration
# ---------------------------------------------------------------------------


def test_aliases_include_rescript_and_short_forms():
    """The lexer must expose all aliases used by docs fences."""
    assert "rescript" in RescriptLexer.aliases
    assert "res" in RescriptLexer.aliases
    assert "resi" in RescriptLexer.aliases


# ---------------------------------------------------------------------------
# Keywords
# ---------------------------------------------------------------------------


def test_let_binding_emits_keyword_and_value_categories():
    tokens = _tokens("let x = 42")
    assert _has_token(tokens, Keyword, "let")
    assert _has_token(tokens, Name, "x")
    assert _has_token(tokens, Operator, "=")
    assert _has_token(tokens, Number.Integer, "42")


def test_type_keyword_uses_declaration_subtoken():
    tokens = _tokens("type t = int")
    assert _has_token(tokens, Keyword.Declaration, "type")


def test_switch_and_match_are_keywords():
    tokens = _tokens("switch x { | Some(v) => v | None => 0 }")
    assert _has_token(tokens, Keyword, "switch")
    assert _has_token(tokens, Keyword.Constant, "Some")
    assert _has_token(tokens, Keyword.Constant, "None")


def test_builtin_type_keywords():
    tokens = _tokens("let xs: list<int> = list{}")
    assert _has_token(tokens, Keyword.Type, "list")
    assert _has_token(tokens, Name, "int")


def test_async_await():
    tokens = _tokens("let f = async () => await g()")
    assert _has_token(tokens, Keyword, "async")
    assert _has_token(tokens, Keyword, "await")


# ---------------------------------------------------------------------------
# Strings, chars, templates
# ---------------------------------------------------------------------------


def test_string_keeps_keywords_unhighlighted_inside():
    tokens = _tokens('let s = "let y = 1"')
    # Only one ``let`` should be classified as keyword (the binding itself).
    let_keywords = [v for t, v in tokens if t is Keyword and v == "let"]
    assert let_keywords == ["let"]
    # The literal should be present as String content.
    string_runs = [v for t, v in tokens if t is String]
    assert any("let y = 1" in v for v in string_runs)


def test_char_literal_distinct_from_type_argument():
    tokens = _tokens("let c = 'a'")
    assert _has_token(tokens, String.Char, "'a'")


def test_type_argument_uses_name_subtoken():
    tokens = _tokens("type t<'a> = list<'a>")
    type_args = [v for t, v in tokens if t is Name.Variable.Magic]
    assert "'a" in type_args


def test_template_literal_interpolation():
    tokens = _tokens("let g = `hello ${name}!`")
    template_runs = [v for t, v in tokens if t is String.Backtick]
    assert any("hello " in v for v in template_runs)
    # ``${`` opens an Interpol region and ``}`` closes it.
    interp_marks = [v for t, v in tokens if t is String.Interpol]
    assert "${" in interp_marks
    assert "}" in interp_marks
    # The identifier inside the interpolation should be highlighted as Name.
    assert _has_token(tokens, Name, "name")


# ---------------------------------------------------------------------------
# Comments
# ---------------------------------------------------------------------------


def test_single_line_comment():
    tokens = _tokens("// a remark\nlet x = 1")
    assert any(t is Comment.Single and "remark" in v for t, v in tokens)


def test_multiline_comment_with_nesting():
    tokens = _tokens("/* outer /* inner */ outer-end */ let x = 1")
    comment_text = "".join(v for t, v in tokens if t is Comment.Multiline)
    assert "inner" in comment_text
    assert "outer-end" in comment_text
    # Code after the closing ``*/`` resumes normal highlighting.
    assert _has_token(tokens, Keyword, "let")


# ---------------------------------------------------------------------------
# Annotations, poly variants, modules
# ---------------------------------------------------------------------------


def test_at_annotation_with_dotted_name():
    tokens = _tokens('@module("foo") external x: int = "default"')
    assert _has_token(tokens, Name.Decorator, "@module")
    assert _has_token(tokens, Keyword, "external")


def test_poly_variant_tag():
    tokens = _tokens("let x = #Red")
    assert _has_token(tokens, Name.Tag, "#Red")


def test_module_uppercase_is_class_token():
    tokens = _tokens('Console.log("hello")')
    assert _has_token(tokens, Name.Class, "Console")
    assert _has_token(tokens, Punctuation, ".")
    assert _has_token(tokens, Name, "log")


# ---------------------------------------------------------------------------
# Numbers
# ---------------------------------------------------------------------------


def test_numeric_literal_variants():
    tokens = _tokens("let a = 0xFF\nlet b = 0o17\nlet c = 0b1010\nlet d = 3.14\nlet e = 1_000")
    assert _has_token(tokens, Number.Hex, "0xFF")
    assert _has_token(tokens, Number.Oct, "0o17")
    assert _has_token(tokens, Number.Bin, "0b1010")
    assert _has_token(tokens, Number.Float, "3.14")
    assert _has_token(tokens, Number.Integer, "1_000")


# ---------------------------------------------------------------------------
# Operators
# ---------------------------------------------------------------------------


def test_pipe_forward_and_arrow_are_operators():
    tokens = _tokens("let f = x => x |> g")
    assert _has_token(tokens, Operator, "=>")
    assert _has_token(tokens, Operator, "|>")


def test_strict_equality_operators():
    tokens = _tokens("a === b && c !== d")
    assert _has_token(tokens, Operator, "===")
    assert _has_token(tokens, Operator, "!==")
    assert _has_token(tokens, Operator, "&&")


# ---------------------------------------------------------------------------
# JSX
# ---------------------------------------------------------------------------


def test_jsx_open_and_close_emit_tag_names():
    tokens = _tokens("<Button onClick={handler}>label</Button>")
    tag_names = [v for t, v in tokens if t is Name.Tag]
    assert "Button" in tag_names
    # The closing variant should also surface ``Button``.
    assert tag_names.count("Button") == 2


def test_jsx_self_closing():
    tokens = _tokens('<Icon name={"x"} />')
    assert _has_token(tokens, Name.Tag, "Icon")
    assert _has_token(tokens, Punctuation, "/>")
