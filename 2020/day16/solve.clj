(require 'clojure.java.io)
(require 'clojure.string)

(def debug true)
(def lines
  (with-open [rdr (clojure.java.io/reader (if debug "small.txt" "input.txt"))]
    (reduce conj [] (line-seq rdr))))

(def specs (reduce
  #(if (= %2 "")
    (conj %1 [])
    (cons (cons %2 (first %1)) (rest %1)))
  [] lines))

(def intervals
  (letfn [(parse-field-spec [s]
            (let [parts (clojure.string/split s #" ")
                  field-name (first parts)
                  intervals (map #() (range 1 (count parts) 2))
                  ]

              ))]
    (map parse-field-spec (first specs))))
