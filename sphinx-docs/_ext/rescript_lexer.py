"""Pygments lexer for ReScript, registered as a Sphinx extension.

The token classification mirrors the JFlex grammar shipped with the official
ReScript IntelliJ plugin (`Rescript.flex` + `RescriptSyntaxHighlighter.kt`)
so that fenced ``rescript`` / ``res`` / ``resi`` code blocks in
``sphinx-docs/user/*.md`` render with the same categories an IDE would use:
keywords, type/value constants, strings (regular, char, template literal),
numeric literals, single- and multi-line (nested) comments, ``@`` annotations,
``#`` polymorphic variants, ``'a`` type arguments, module / variant names,
operators, and JSX-style tags.

Reference: https://github.com/JetBrains/intellij-rescript (lexer rules).
"""

from __future__ import annotations

from pygments.lexer import RegexLexer, include, words
from pygments.token import (
    Comment,
    Error,
    Keyword,
    Name,
    Number,
    Operator,
    Punctuation,
    String,
    Text,
)


class RescriptLexer(RegexLexer):
    """Pygments :class:`~pygments.lexer.RegexLexer` for ReScript source code.

    Aliased as ``rescript`` / ``res`` / ``resi`` so MyST fenced blocks
    written as `````rescript`` (the convention used throughout
    ``sphinx-docs/user/``) pick this lexer up after :func:`setup` registers it
    with Sphinx.
    """

    name = "ReScript"
    aliases = ["rescript", "res", "resi"]
    filenames = ["*.res", "*.resi"]
    mimetypes = ["text/x-rescript"]

    # Mirrors RescriptTokenTypes.KEYWORDS — value-level / control-flow keywords.
    _KEYWORDS = (
        "and",
        "as",
        "assert",
        "async",
        "await",
        "begin",
        "catch",
        "class",
        "constraint",
        "do",
        "done",
        "downto",
        "else",
        "end",
        "exception",
        "external",
        "for",
        "functor",
        "if",
        "in",
        "include",
        "inherit",
        "initializer",
        "lazy",
        "let",
        "match",
        "method",
        "module",
        "mutable",
        "new",
        "nonrec",
        "object",
        "of",
        "open",
        "or",
        "pri",
        "private",
        "pub",
        "raw",
        "ffi",
        "raise",
        "rec",
        "sig",
        "struct",
        "switch",
        "then",
        "try",
        "unpack",
        "val",
        "virtual",
        "when",
        "while",
        "with",
        # Operator-form keywords from flex 146–152.
        "mod",
        "land",
        "lor",
        "lxor",
        "lsl",
        "lsr",
        "asr",
    )

    # `type` is a keyword but emitted with Keyword.Declaration so themes
    # that distinguish declarations from control flow render it consistently.
    _DECLARATION_KEYWORDS = ("type",)

    # Builtin type names that the IntelliJ lexer treats as standalone tokens
    # (UNIT / REF / OPTION) plus collection shorthands (list / dict).
    _TYPE_KEYWORDS = ("unit", "ref", "option", "list", "dict")

    # Builtin constants matching RescriptTokenTypes.BOOL_VALUE / NONE / SOME.
    _CONSTANTS = ("true", "false", "None", "Some")

    tokens = {
        "root": [
            # Whitespace + comments come first so they win against operator
            # prefixes (e.g. ``//`` must beat ``/``).
            (r"[ \t]+", Text.Whitespace),
            (r"\r?\n", Text.Whitespace),
            (r"//[^\n]*", Comment.Single),
            (r"/\*", Comment.Multiline, "comment"),
            # @annotation — supports dotted names (``@some.path``) per flex 252.
            (r"@[A-Za-z_][\w]*(?:\.[A-Za-z_][\w]*)*", Name.Decorator),
            (r"@", Name.Decorator),
            # Numeric literals — longest match first.
            (r"0[xX][0-9A-Fa-f][0-9A-Fa-f_]*[G-Zg-z]?", Number.Hex),
            (r"0[oO][0-7][0-7_]*[G-Zg-z]?", Number.Oct),
            (r"0[bB][01][01_]*[G-Zg-z]?", Number.Bin),
            (
                r"\d[\d_]*\.[\d_]*(?:[eE][+-]?\d[\d_]*)?[G-Zg-z]?",
                Number.Float,
            ),
            (
                r"\d[\d_]*(?:[eE][+-]?\d[\d_]*)[G-Zg-z]?",
                Number.Float,
            ),
            (r"\d[\d_]*[G-Zg-z]?", Number.Integer),
            # Char literal — must precede the type-argument rule because both
            # start with ``'``. Char literals always close with a second
            # ``'`` after one character or one escape sequence.
            (
                r"'(?:\\[\\'\"nbrt]|\\\d{3}|\\x[0-9a-fA-F]{2}"
                r"|\\o[0-3][0-7]{2}|[^\\'])'",
                String.Char,
            ),
            # Type argument: ``'a``, ``'foo``. Lowercase only — uppercase
            # after ``'`` is not a valid ReScript token.
            (r"'[a-z_][\w]*", Name.Variable.Magic),
            # Polymorphic variant tags: ``#Red``, ``#foo``.
            (r"#[A-Za-z_][\w]*", Name.Tag),
            # Keyword groups (`\b` boundaries via `words()`).
            (words(_DECLARATION_KEYWORDS, suffix=r"\b"), Keyword.Declaration),
            (words(_CONSTANTS, suffix=r"\b"), Keyword.Constant),
            (words(_TYPE_KEYWORDS, suffix=r"\b"), Keyword.Type),
            (words(_KEYWORDS, suffix=r"\b"), Keyword),
            # JSX-like closing tag (``</Foo>``). Same uppercase-only rule
            # as the opening side to stay symmetrical with the JSX-open
            # heuristic.
            (r"</(?=[A-Z])", Punctuation, "jsx-close"),
            # JSX-like opening tag (``<Foo``). Restricted to uppercase
            # follow because ReScript JSX components are PascalCase by
            # convention, and lowercase keeps type parameters like
            # ``list<int>`` from being mistaken for JSX. Lowercase HTML
            # tags (``<div>``) are intentionally not JSX-highlighted —
            # see steering 20260511-021 design §2.5.
            (r"<(?=[A-Z])", Punctuation, "jsx-open"),
            (r"/>", Punctuation),
            # String / template starts.
            (r"`", String.Backtick, "template"),
            (r'"', String, "string"),
            # Identifiers. UIDENT first (uppercase) so module / variant names
            # render as Name.Class even when they precede ``.``.
            (r"[A-Z][\w]*", Name.Class),
            (r"[a-z_][\w]*", Name),
            # Operators — order matters: longest-first within each family.
            (r"\.\.\.", Operator),
            (r"\.\.", Operator),
            (r"===|!==", Operator),
            (r"==|!=|<=|>=|=>|->|<-|\|>|::|\+\+|\|\||&&|##", Operator),
            (r"[+\-*/%]\.", Operator),
            (r"[+\-*/%<>=!|&~^?]", Operator),
            # Punctuation.
            (r"[(){}\[\];,.:]", Punctuation),
            (r"\\", Punctuation),
            # Anything unrecognised — surfaced as Error so it's visible.
            (r".", Error),
        ],
        # Nested /* ... */ blocks per flex 301–307.
        "comment": [
            (r"[^/*]+", Comment.Multiline),
            (r"/\*", Comment.Multiline, "#push"),
            (r"\*/", Comment.Multiline, "#pop"),
            (r"[/*]", Comment.Multiline),
        ],
        # Double-quoted string with escapes per flex 288–299.
        "string": [
            (r"\\\r?\n[ \t]*", String.Escape),
            (r'\\[\\\'"nbrt ]', String.Escape),
            (r"\\\d{3}", String.Escape),
            (r"\\o[0-3][0-7]{2}", String.Escape),
            (r"\\x[0-9a-fA-F]{2}", String.Escape),
            (r"\\.", String.Escape),
            (r'"', String, "#pop"),
            (r'[^\\"]+', String),
        ],
        # Backtick template literal with ``${...}`` interpolation per flex 277–286.
        "template": [
            (r"\\.", String.Escape),
            (r"\$\{", String.Interpol, "interp"),
            (r"`", String.Backtick, "#pop"),
            (r"\$(?!\{)", String.Backtick),
            (r"[^\\`$]+", String.Backtick),
        ],
        # Inside ``${ ... }`` — recurse into root so embedded ReScript
        # expressions get full highlighting.
        "interp": [
            (r"\}", String.Interpol, "#pop"),
            include("root"),
        ],
        # ``<Foo`` ... up to the next ``>`` or ``/>``. Keeps the tag name as
        # a single Name.Tag token; attributes inside fall back to root.
        "jsx-open": [
            (r"[A-Z][\w.]*", Name.Tag),
            (r"[a-z][\w]*", Name.Tag),
            (r"/>", Punctuation, "#pop"),
            (r">", Punctuation, "#pop"),
            include("root"),
        ],
        # ``</Foo>`` closing tag — tag name + final ``>``.
        "jsx-close": [
            (r"[A-Za-z][\w.]*", Name.Tag),
            (r">", Punctuation, "#pop"),
            (r"\s+", Text.Whitespace),
        ],
    }


def setup(app):
    """Register :class:`RescriptLexer` so Sphinx hands ``rescript`` blocks to it.

    Sphinx's ``highlight_language`` machinery looks up lexers in
    ``sphinx.highlighting.lexers``; assigning an instance there is the
    documented integration point for project-local Pygments lexers.
    """

    from sphinx.highlighting import lexers

    lexer = RescriptLexer()
    for alias in RescriptLexer.aliases:
        lexers[alias] = lexer

    return {"version": "0.1.0", "parallel_read_safe": True, "parallel_write_safe": True}
