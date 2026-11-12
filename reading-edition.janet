# Reading edition of a Markdown paper, for annotation on a tablet.
#
#   janet reading-edition.janet paper.md build/<name>.pdf
#
# Runs pandoc to produce HTML with embedded CSS, then a headless
# Chromium-based browser (Edge or Chrome, or the one named by $BROWSER)
# with --print-to-pdf. Intermediate files go to build/reading-edition/;
# write the PDF to build/ too, and copy selected editions to readings/
# by hand.
#
# Layout: 157 x 210 mm pages, margins 15/44/15/12 mm (wide right margin for
# annotations), serif text at 10.2 pt, line-height 1.38, left-aligned. The
# editorial note and figure placeholders are boxed; tables become stacked
# label/value blocks. The running header takes its title and version from
# the front matter (title:, draft:), or else from the first "#" heading and
# "Working draft <version> ·"; the footer shows "page / total".
# --citeproc is added when the front matter declares a bibliography.

(def work-dir "build/reading-edition")

(def browsers
  ["C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"
   "C:/Program Files/Microsoft/Edge/Application/msedge.exe"
   "C:/Program Files/Google/Chrome/Application/chrome.exe"
   "/usr/bin/microsoft-edge"
   "/usr/bin/google-chrome"
   "/usr/bin/chromium"
   "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"])

(defn front-matter
  "The YAML front matter of text, or an empty string."
  [text]
  (if-let [m (peg/match ~(* "---\n" (<- (to (* "\n" (+ "---" "...") (+ "\n" -1)))))
                        text)]
    (first m)
    ""))

(defn yaml-value
  "Value of a top-level `key: value` line in front matter, unquoted."
  [fm key]
  (if-let [m (peg/match ~(any (+ (* "\n" ,key ":" (any " ")
                                    (<- (some (if-not "\n" 1))))
                                 1))
                        (string "\n" fm))]
    (if-let [v (first m)]
      (let [v (string/trim v)]
        (if (and (> (length v) 1) (string/has-prefix? "\"" v) (string/has-suffix? "\"" v))
          # double-quoted, as init.janet writes it: undo \" and \\
          (first (peg/match ~(% (any (+ (* "\\" (<- 1)) (<- 1)))) (string/slice v 1 -2)))
          (string/trim v "\"'"))))))

(defn first-match [patt text]
  (if-let [m (peg/match ~(any (+ ,patt 1)) text)] (first m)))

(defn paper-title [text fm]
  (or (yaml-value fm "title")
      (first-match ~(* "\n# " (<- (some (if-not "\n" 1)))) (string "\n" text))))

(defn paper-version [text fm]
  (or (yaml-value fm "draft")
      (first-match ~(* "Working draft " (<- (some (if-not (+ " ·" "\n" "*") 1)))) text)))

(defn boxes
  "Turn the editorial note and figure placeholders, which are blockquotes,
  into fenced divs with classes ednote and figph."
  [text]
  (def out @[])
  (var cls nil)
  (each line (string/split "\n" text)
    (if (and cls (string/has-prefix? ">" line))
      (array/push out (string/slice line (if (string/has-prefix? "> " line) 2 1)))
      (do
        (when cls (array/push out ":::") (set cls nil))
        (cond
          (string/has-prefix? "> **Editorial note" line)
          (do (set cls "ednote") (array/push out "::: ednote" (string/slice line 2)))

          (peg/match ~(* "> **FIGURE " :d) line)
          (do (set cls "figph") (array/push out "::: figph" (string/slice line 2)))

          (array/push out line)))))
  (when cls (array/push out ":::"))
  (string/join out "\n"))

(defn css-string [s]
  (string "\"" (->> s (string/replace-all "\\" "\\\\") (string/replace-all "\"" "\\\"")) "\""))

(defn css [title version]
  (def head (string/ascii-upper title))
  (def right (string (if version (string "DRAFT " (string/ascii-upper version) " · ") "")
                     "READING EDITION · NOT FOR CIRCULATION"))
  (string
    ```
@page {
  size: 157mm 210mm; margin: 15mm 44mm 15mm 12mm;
  @top-left { content: ``` (css-string head) ```; font-family: 'DejaVu Sans', Verdana, sans-serif; font-size: 6.5pt; color: #555; }
  @top-right { content: ``` (css-string right) ```; font-family: 'DejaVu Sans', Verdana, sans-serif; font-size: 6.5pt; color: #555; }
  @bottom-center { content: counter(page) " / " counter(pages); font-family: 'DejaVu Sans', Verdana, sans-serif; font-size: 7pt; color: #555; }
}
html { font-family: 'Liberation Serif', 'Times New Roman', 'DejaVu Serif', serif; font-size: 10.2pt; line-height: 1.38; color: #111; }
body { margin: 0; text-align: left; }
p { margin: 0 0 0.55em 0; orphans: 3; widows: 3; }
h1, h2, h3 { font-family: 'DejaVu Sans', Verdana, sans-serif; text-align: left; hyphens: none; break-after: avoid; page-break-after: avoid; }
h1 { font-size: 12.5pt; margin: 1.2em 0 0.5em; }
h2 { font-size: 10.4pt; margin: 1.0em 0 0.4em; }
h3 { font-size: 9.8pt; margin: 0.9em 0 0.35em; }
h1.doc-title { font-size: 17pt; margin: 0 0 0.25em; }
h2.doc-subtitle { font-family: 'Liberation Serif', 'Times New Roman', serif; font-style: italic; font-weight: normal; font-size: 10.5pt; margin: 0 0 0.8em; }
ul, ol { margin: 0.2em 0 0.6em 1.2em; padding: 0; }
li { margin-bottom: 0.25em; }
code { font-family: 'DejaVu Sans Mono', monospace; font-size: 7.6pt; }
pre { white-space: pre-wrap; word-break: break-word; font-size: 7.4pt; line-height: 1.35; margin: 0.3em 0 0.5em; background: #f4f4f4; padding: 0.45em 0.6em; border-radius: 2px; text-align: left; }
blockquote { margin: 0.4em 0 0.8em 0; padding: 0 0 0 0.7em; border-left: 2px solid #bbb; font-size: 8.8pt; color: #333; break-inside: avoid; }
.ednote { border: 1px solid #c33; background: #fff6f5; padding: 0.6em 0.8em; margin: 0.4em 0 1em; font-size: 8.6pt; text-align: left; }
.figph { border: 1.5px dashed #555; min-height: 38mm; margin: 0.8em 0 0.3em; padding: 0.8em; display: flex; flex-direction: column; justify-content: center; text-align: center; break-inside: avoid; }
.figph p:first-child { font-family: 'DejaVu Sans', Verdana, sans-serif; font-size: 8.8pt; letter-spacing: 0.02em; margin-bottom: 1.6em; }
.figph p:first-child::before { content: "OPM DIAGRAM RESERVED"; display: block; font-weight: bold; font-size: 10pt; margin-bottom: 0.5em; }
.figph p:last-child { font-size: 8.2pt; text-align: center; margin: 0; }
.tblock { margin: 0.3em 0 0.9em; }
.trow { border-top: 0.5px solid #aaa; padding: 0.35em 0 0.3em; break-inside: avoid; }
.trow .ttl { font-weight: bold; margin-bottom: 0.15em; text-align: left; }
.trow .cell { margin: 0.1em 0 0.15em; font-size: 9.6pt; }
.trow .lbl { font-variant: small-caps; color: #444; }
.tsect { font-family: 'DejaVu Sans', Verdana, sans-serif; font-weight: bold; font-size: 8.6pt; letter-spacing: 0.03em; margin: 0.7em 0 0.1em; padding-top: 0.2em; border-top: 1.2px solid #333; }
section.footnotes { font-size: 8pt; margin-top: 2em; border-top: 0.5px solid #999; }
section.footnotes hr { display: none; }
a { color: inherit; text-decoration: none; }
```))

# Runs in the page before printing, as in the reference implementation:
# marks the title and subtitle, and turns tables into label/value blocks.
(def script
  ```
<script>
(() => {
  const h1 = document.querySelector('h1'); if (h1) h1.classList.add('doc-title');
  const h2 = document.querySelector('h1 + h2'); if (h2) h2.classList.add('doc-subtitle');
  document.querySelectorAll('table').forEach(t => {
    const heads = [...t.querySelectorAll('thead th')].map(th => th.textContent.trim());
    const box = document.createElement('div'); box.className = 'tblock';
    t.querySelectorAll('tbody tr').forEach(tr => {
      const tds = [...tr.children];
      const rest = tds.slice(1).map(td => td.textContent.trim()).join('');
      if (rest === '' && tds[0].querySelector('strong')) {
        const s = document.createElement('div'); s.className = 'tsect'; s.innerHTML = tds[0].innerHTML; box.appendChild(s); return;
      }
      const row = document.createElement('div'); row.className = 'trow';
      const ttl = document.createElement('div'); ttl.className = 'ttl'; ttl.innerHTML = tds[0].innerHTML; row.appendChild(ttl);
      tds.slice(1).forEach((td, i) => {
        const c = document.createElement('div'); c.className = 'cell';
        c.innerHTML = '<span class="lbl">' + (heads[i+1] || '') + ':</span> ' + td.innerHTML; row.appendChild(c);
      });
      box.appendChild(row);
    });
    t.replaceWith(box);
  });
})();
</script>
```)

(defn mkdirs [path]
  (var acc (if (string/has-prefix? "/" path) "/" ""))
  (each part (string/split "/" (string/replace-all "\\" "/" path))
    (unless (empty? part)
      (set acc (if (or (empty? acc) (= acc "/")) (string acc part) (string acc "/" part)))
      (unless (os/stat acc) (os/mkdir acc)))))

(defn parent [path]
  (def p (string/replace-all "\\" "/" path))
  (if-let [i (string/find-all "/" p)] (if (empty? i) "." (string/slice p 0 (last i))) "."))

(defn file-uri [path]
  (def p (string/replace-all "\\" "/" path))
  (string "file://" (if (string/has-prefix? "/" p) "" "/") (string/replace-all " " "%20" p)))

(defn find-browser []
  (or (os/getenv "BROWSER")
      (find os/stat browsers)
      (error "no Edge or Chrome found; set BROWSER to a Chromium-based browser")))

(defn run [& args]
  (def code (os/execute args :p))
  (unless (zero? code)
    (error (string/format "%s exited with %d" (first args) code))))

(defn main [_ &opt src out]
  (unless (and src out)
    (eprint "usage: janet reading-edition.janet paper.md build/<name>.pdf")
    (os/exit 2))
  (def text (string/replace-all "\r\n" "\n" (slurp src)))
  (def fm (front-matter text))
  (def title (or (paper-title text fm) ""))
  (def version (paper-version text fm))

  (mkdirs work-dir)
  (mkdirs (parent out))
  (def work (os/realpath work-dir))
  (def md (string work "/re.md"))
  (def css-path (string work "/re.css"))
  (def js-path (string work "/re-after.html"))
  (def html (string work "/re.html"))
  (spit md (boxes text))
  (spit css-path (css title version))
  (spit js-path script)

  # pandoc runs in the paper's folder, so the bibliography and images
  # resolve as they do when the paper is built there.
  (def here (os/cwd))
  (os/cd (parent src))
  (defer (os/cd here)
    (run "pandoc" md "-f" "markdown+pipe_tables+fenced_divs+footnotes"
         "-t" "html5" "-s" "--embed-resources" "--resource-path=."
         "--metadata" (string "pagetitle=" (if (empty? title) "Reading edition" title))
         ;(if (yaml-value fm "lang") [] ["--metadata" "lang=en"])
         ;(if (yaml-value fm "bibliography") ["--citeproc"] [])
         "--css" css-path "--include-after-body" js-path "-o" html))

  (def pdf (string (os/realpath (parent out)) "/" (last (string/split "/" (string/replace-all "\\" "/" out)))))
  (run (find-browser) "--headless" "--disable-gpu" "--no-first-run"
       "--no-default-browser-check" "--no-pdf-header-footer"
       "--run-all-compositor-stages-before-draw" "--virtual-time-budget=10000"
       (string "--user-data-dir=" work "/profile")
       (string "--print-to-pdf=" pdf) (file-uri html))
  (unless (os/stat pdf) (error (string "no PDF written to " pdf)))
  (print "ok " out))
