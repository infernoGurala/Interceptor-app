library;

/// Display-only markdown cleanup. Files on disk are never modified.

/// Removes a leading YAML front matter block (`--- ... ---`) from markdown.
String stripFrontMatter(String markdown) {
  final text = markdown.startsWith('\uFEFF') ? markdown.substring(1) : markdown;
  final match = _frontMatter.firstMatch(text);
  return match == null ? text : text.substring(match.end).trimLeft();
}

final _frontMatter = RegExp(
  r'^\s*---[ \t]*\r?\n[\s\S]*?\r?\n(?:---|\.\.\.)[ \t]*(?:\r?\n|$)',
);

/// Turns Obsidian-style wikilinks into plain text:
///   [[Note]]              -> Note
///   [[Note|Alias]]        -> Alias
///   [[Note#Heading]]      -> Note › Heading
///   [[folder/Note.md]]    -> Note
///   ![[embed.png]]        -> embed
String stripWikiLinks(String markdown) {
  return markdown.replaceAllMapped(_wikiLink, (m) {
    final target = m.group(1)!.trim();
    final alias = m.group(2)?.trim();
    if (alias != null && alias.isNotEmpty) return alias;

    final hashIdx = target.indexOf('#');
    var page = hashIdx >= 0 ? target.substring(0, hashIdx) : target;
    final section = hashIdx >= 0
        ? target.substring(hashIdx + 1).replaceFirst(RegExp(r'^\^'), '')
        : '';

    page = page.split('/').last;
    page = page.replaceFirst(RegExp(r'\.md$', caseSensitive: false), '');
    final dot = page.lastIndexOf('.');
    if (m.group(0)!.startsWith('!') && dot > 0) page = page.substring(0, dot);

    if (page.isEmpty) return section;
    return section.isEmpty ? page : '$page › $section';
  });
}

final _wikiLink = RegExp(r'!?\[\[([^\[\]|]+?)(?:\|([^\[\]]*?))?\]\]');

/// Full cleanup used before rendering a note.
String cleanForDisplay(String markdown) =>
    stripWikiLinks(stripFrontMatter(markdown));
