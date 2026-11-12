# Word count of a Markdown file.
#
#   janet words.janet paper.md
#
# Prints the total word count and the count excluding blockquotes (in a
# manuscript: the editorial note, figure placeholders and OPL blocks).
#
# Rule: YAML front matter and HTML comments are skipped. A word is a
# whitespace-separated token containing a letter or digit. Any non-ASCII
# character counts as a letter (so Cyrillic or Czech words count), except
# those whose UTF-8 lead byte is 0xC2 or 0xE2: Latin-1 punctuation and
# U+2000-U+2FFF (dashes, quotes, arrows, math symbols), so a standalone
# "—" or "→" is not a word.

(defn strip-front-matter [text]
  (if-let [m (peg/match ~(* "---\n" (to (* "\n" (+ "---" "...") (+ "\n" -1)))
                            "\n" (+ "---" "...") (+ "\n" -1) (position))
                        text)]
    (string/slice text (last m))
    text))

(def comment-peg
  (peg/compile ~(% (any (+ (/ (* "<!--" (thru "-->")) "") (<- 1))))))

(defn strip-comments [text]
  (first (peg/match comment-peg text)))

(defn letter? [b]
  (or (and (>= b (chr "0")) (<= b (chr "9")))
      (and (>= b (chr "A")) (<= b (chr "Z")))
      (and (>= b (chr "a")) (<= b (chr "z")))
      # UTF-8 lead bytes; continuation bytes (0x80-0xBF) never decide
      (and (>= b 0xC3) (not= b 0xE2))))

(defn word? [token]
  (truthy? (find letter? token)))

(defn count-words [text]
  (count word? (string/split " " (peg/replace-all '(set "\t\n\r\f\v") " " text))))

(defn blockquote? [line]
  (truthy? (peg/match '(* (any (set " \t")) ">") line)))

(defn main [_ &opt path]
  (unless path
    (eprint "usage: janet words.janet paper.md")
    (os/exit 2))
  (def text (->> (slurp path)
                (string/replace-all "\r\n" "\n")
                strip-front-matter
                strip-comments))
  (def lines (string/split "\n" text))
  (def body (string/join (filter |(not (blockquote? $)) lines) "\n"))
  (print "total: " (count-words text))
  (print "excluding blockquotes: " (count-words body)))
