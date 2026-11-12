# Fill the templates into a new paper.
#
#   janet init.janet --title "…" [--subtitle "…"] --slug <slug> --lang <language>
#                    --kind article|report --author "…" [--date YYYY-MM-DD]
#
# Runs in a fresh clone of paper-thicket. Renders every file in templates/
# to the same relative path in the repository root, creates the empty
# folders private/ and build/, and prints the files it wrote. Refuses,
# writing nothing, if any target already exists. Does not commit and does
# not touch Git configuration or remotes.
#
# Placeholders: {{name}} inserts the value as plain text; {{name|q}} inserts
# it as a double-quoted string, valid both in YAML and in JDN. An empty
# value drops the whole line, except {{name|q}} in .jdn files, which
# renders as nil.

(def usage
  ``usage: janet init.janet --title "…" [--subtitle "…"] --slug <slug> --lang <language>
                         --kind article|report --author "…" [--date YYYY-MM-DD]``)

(def flags {"--title" :title "--subtitle" :subtitle "--slug" :slug "--lang" :lang
            "--kind" :kind "--author" :author "--date" :date})

(def months ["January" "February" "March" "April" "May" "June" "July"
             "August" "September" "October" "November" "December"])

(defn fail [code & msg]
  (eprint ;msg)
  (os/exit code))

(defn windows-args
  "On Windows, Janet receives its arguments in the ANSI code page, which
  loses characters such as č. Read the UTF-16 command line instead and
  return its last n arguments as UTF-8."
  [n]
  (def k32 (ffi/native "kernel32.dll"))
  (def w2m (ffi/lookup k32 "WideCharToMultiByte"))
  (def w2m-sig (ffi/signature :default :int :uint32 :uint32 :ptr :int :ptr :int :ptr :ptr))
  (defn utf8 [wstr]
    (def size (ffi/call w2m w2m-sig 65001 0 wstr -1 nil 0 nil nil))
    (def buf (buffer/new-filled size))
    (ffi/call w2m w2m-sig 65001 0 wstr -1 buf size nil nil)
    (string (buffer/slice buf 0 (- size 1))))
  (def cmdline (ffi/call (ffi/lookup k32 "GetCommandLineW") (ffi/signature :default :ptr)))
  (def count-buf (buffer/new-filled 4))
  (def argv (ffi/call (ffi/lookup (ffi/native "shell32.dll") "CommandLineToArgvW")
                      (ffi/signature :default :ptr :ptr :ptr) cmdline count-buf))
  (def argc (ffi/read :int32 count-buf))
  (def all (seq [i :range [0 argc]] (utf8 (ffi/read :ptr argv (* i (ffi/size :ptr))))))
  (ffi/call (ffi/lookup k32 "LocalFree") (ffi/signature :default :ptr :ptr) argv)
  (array/slice all (- argc n)))

(defn parse-args [args]
  (def opts @{})
  (var i 0)
  (while (< i (length args))
    (def flag (args i))
    (def key (flags flag))
    (unless key (fail 2 "unknown argument: " flag "\n" usage))
    (unless (< (+ i 1) (length args)) (fail 2 "missing value for " flag "\n" usage))
    (when (opts key) (fail 2 "repeated argument: " flag))
    (put opts key (args (+ i 1)))
    (+= i 2))
  opts)

(def slug-peg (peg/compile '(* (some (range "az" "09")) (any (* "-" (some (range "az" "09")))) -1)))
(def date-peg (peg/compile '(* (number (4 :d)) "-" (number (2 :d)) "-" (number (2 :d)) -1)))

(defn leap? [y]
  (and (zero? (% y 4)) (or (not (zero? (% y 100))) (zero? (% y 400)))))

(defn days-in [y m]
  (case m 2 (if (leap? y) 29 28) 4 30 6 30 9 30 11 30 31))

(defn today []
  (def d (os/date (os/time) true))
  (string/format "%04d-%02d-%02d" (d :year) (+ 1 (d :month)) (+ 1 (d :month-day))))

(defn long-date
  "12 November 2026 for 2026-11-12, or nil if the date is not valid."
  [date]
  (when-let [[y m d] (peg/match date-peg date)]
    (when (and (<= 1 m 12) (<= 1 d (days-in y m)))
      (string d " " (months (- m 1)) " " y))))

(defn quoted
  "s as a double-quoted string, valid in YAML and in JDN. Escapes only
  backslash, double quote and control characters; UTF-8 stays as is."
  [s]
  (def b @"\"")
  (each c s
    (cond
      (= c (chr "\"")) (buffer/push b "\\\"")
      (= c (chr "\\")) (buffer/push b "\\\\")
      (= c (chr "\n")) (buffer/push b "\\n")
      (= c (chr "\r")) (buffer/push b "\\r")
      (= c (chr "\t")) (buffer/push b "\\t")
      (or (< c 32) (= c 127)) (buffer/push b (string/format "\\x%02X" c))
      (buffer/push-byte b c)))
  (buffer/push b "\"")
  (string b))

(defn git-head []
  (def proc (os/spawn ["git" "rev-parse" "HEAD"] :p {:out :pipe}))
  (def out (:read (proc :out) :all))
  (unless (zero? (os/proc-wait proc)) (fail 1 "git rev-parse HEAD failed"))
  (string/trim (string out)))

(defn template-files
  "Paths of all files under dir, relative to dir, with / separators."
  [dir &opt prefix acc]
  (default acc @[])
  (each name (sorted (os/dir dir))
    (def rel (if prefix (string prefix "/" name) name))
    (def path (string dir "/" name))
    (if (= :directory (os/stat path :mode))
      (template-files path rel acc)
      (array/push acc rel)))
  acc)

(defn render
  "Render text with values. jdn? selects the .jdn rule for empty |q values."
  [text values jdn?]
  (def out @[])
  (each line (string/split "\n" text)
    (var drop false)
    (defn fill [name filter]
      (def v (values name))
      (when (nil? v) (error (string "unknown placeholder: {{" name "}}")))
      (cond
        (nil? filter)
        (do (when (empty? v) (set drop true)) v)

        (= filter "q")
        (cond
          (not (empty? v)) (quoted v)
          jdn? "nil"
          (do (set drop true) ""))

        (error (string "unknown filter: {{" name "|" filter "}}"))))
    (def word '(some (+ (range "az" "AZ" "09") "_")))
    (def rendered
      (first (peg/match ~(% (any (+ (/ (* "{{" (<- ,word) (+ (* "|" (<- ,word)) (constant nil)) "}}")
                                       ,fill)
                                    (<- 1))))
                        line)))
    (unless drop (array/push out rendered)))
  (string/join out "\n"))

(defn mkdirs [path]
  (var acc "")
  (each part (string/split "/" path)
    (set acc (if (empty? acc) part (string acc "/" part)))
    (unless (os/stat acc) (os/mkdir acc))))

(defn parent [path]
  (def i (last (string/find-all "/" path)))
  (if i (string/slice path 0 i)))

(defn main [_ & args]
  (def opts (parse-args (if (= :windows (os/which)) (windows-args (length args)) args)))
  (each key [:title :slug :lang :kind :author]
    (when (empty? (or (opts key) "")) (fail 2 "missing --" key "\n" usage)))
  (eachp [key v] opts
    (when (or (string/find "\n" v) (string/find "\r" v))
      (fail 2 "--" key " must be a single line")))
  (unless (peg/match slug-peg (opts :slug))
    (fail 2 "--slug must match ^[a-z0-9]+(-[a-z0-9]+)*$: " (opts :slug)))
  (unless (index-of (opts :kind) ["article" "report"])
    (fail 2 "--kind must be article or report: " (opts :kind)))
  (def date (or (opts :date) (today)))
  (def date-long (long-date date))
  (unless date-long (fail 2 "--date must be a valid YYYY-MM-DD date: " date))
  (unless (= :directory (os/stat "templates" :mode))
    (fail 1 "no templates/ folder here; run init.janet in the root of a paper-thicket clone"))

  (def values {"title" (opts :title)
               "subtitle" (or (opts :subtitle) "")
               "slug" (opts :slug)
               "author" (opts :author)
               "language" (opts :lang)
               "kind" (opts :kind)
               "date" date
               "date_long" date-long
               "thicket_version" (git-head)})

  (def targets (template-files "templates"))
  (def conflicts (filter os/stat targets))
  (unless (empty? conflicts)
    (fail 1 "refusing to overwrite existing files:\n  " (string/join conflicts "\n  ")))

  # Render everything before writing anything, so a template error writes nothing.
  (def rendered
    (seq [rel :in targets]
      [rel (render (string/replace-all "\r\n" "\n" (slurp (string "templates/" rel)))
                   values
                   (string/has-suffix? ".jdn" rel))]))
  (each [rel text] rendered
    (when-let [dir (parent rel)] (mkdirs dir))
    (spit rel text)
    (print rel))
  (each dir ["private" "build"]
    (unless (os/stat dir) (os/mkdir dir))))
