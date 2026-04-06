(defproject zcaudate-xyz/infra "0.0.0"
  :description "testing clojure infra"
  :dependencies
  [;; dev
   ;;[org.clojure/clojure "1.11.1"]
   [org.clojure/clojure "1.12.0"]
   [javax.xml.bind/jaxb-api "2.4.0-b180830.0359"]
   [com.sun.xml.bind/jaxb-core "4.0.3"]
   [com.sun.xml.bind/jaxb-impl "4.0.3"]
   [clj-kondo "2025.02.20"]

   ;; code.ai
   [org.apache.opennlp/opennlp-tools "2.4.0"]
   [ai.djl/api "0.35.0"]
   [ai.djl/model-zoo "0.35.0"]
   [ai.djl.huggingface/tokenizers "0.35.0"]
   [ai.djl.pytorch/pytorch-engine "0.35.0"]
   [ai.djl.pytorch/pytorch-model-zoo "0.35.0"]

   ;; code.doc
   [markdown-clj/markdown-clj "1.11.8"] ;; not mustache
   
   ;; code.java.compile
   [org.ow2.asm/asm "9.7.1"]
   
   ;; code.manage
   [org.clojure/tools.reader "1.3.7"]

   ;; lib.aether
   [org.eclipse.aether/aether-api "1.1.0"]
   [org.eclipse.aether/aether-spi "1.1.0"]
   [org.eclipse.aether/aether-util "1.1.0"]
   [org.eclipse.aether/aether-impl "1.1.0"]
   [org.eclipse.aether/aether-connector-basic "1.1.0"]
   [org.eclipse.aether/aether-transport-wagon "1.1.0"]
   [org.eclipse.aether/aether-transport-http "1.1.0"]
   [org.eclipse.aether/aether-transport-file "1.1.0"]
   [org.eclipse.aether/aether-transport-classpath "1.1.0"]
   [org.apache.maven/maven-aether-provider "3.3.9"]
   
   ;; lib.javaosc
   #_
   [com.illposed.osc/javaosc-core "0.8"]
   #_#_#_#_#_
   [org.clojars.technomancy/jmdns "3.2.1"]
   [commons-net "3.0.1"]
   [org.jmdns/jmdns "3.5.1"]
   [commons-net/commons-net "3.9.0"]
   [overtone/at-at "1.2.0"]
   
   ;; lib.lucene
   [org.apache.lucene/lucene-core "9.9.2"]
   [org.apache.lucene/lucene-queryparser "9.9.2"]
   [org.apache.lucene/lucene-analyzers-common "8.11.2"]
   [org.apache.lucene/lucene-suggest "9.9.2"]
   
   ;; lib.openpgp
   [org.bouncycastle/bcprov-jdk15on "1.65"]
   [org.bouncycastle/bcpg-jdk15on "1.65"]

   ;; lib.postgres
   [com.impossibl.pgjdbc-ng/pgjdbc-ng "0.8.9"
    :exclusions [io.netty/netty-common
                 io.netty/netty-buffer
                 io.netty/netty-transport
                 io.netty/netty-codec
                 io.netty/netty-handler
                 io.netty/netty-transport-native-unix-common]]
   [io.netty/netty-all "4.1.118.Final"]
   
   ;; lib.oshi
   [com.github.oshi/oshi-core "6.4.11"]
   
   ;; math.stat
   [net.sourceforge.jdistlib/jdistlib "0.4.5"]
   
   ;; math.infix
   [org.scijava/parsington "3.1.0"]
   
   ;; rt.basic
   [http-kit "2.8.0"]
   
   ;; rt.graal
   [org.graalvm.sdk/graal-sdk "21.2.0"]
   [org.graalvm.truffle/truffle-api "21.2.0"]
   [org.graalvm.js/js "21.2.0"]
   [org.graalvm.js/js-scriptengine "21.2.0"]
   [commons-io/commons-io "2.15.1"]
   
   ;; rt.jep
   [black.ninia/jep "4.2.0"]
   
   ;; rt.libpython
   [clj-python/libpython-clj "2.026"]
   
   
   ;; std.pretty
   [org.clojure/core.rrb-vector "0.1.2"]

   ;; script.css
   [garden "1.3.10"]
   [net.sourceforge.cssparser/cssparser "0.9.30"]
   
   ;; script.graphql
   [district0x/graphql-query "1.0.6"]

   ;; script.toml
   [com.moandjiezana.toml/toml4j "0.7.2"]
   
   ;; script.yaml
   [org.yaml/snakeyaml "1.33" #_"2.0" ;; needed by markdown-clj
    ]

   ;; std.fs.archive
   [org.apache.commons/commons-compress "1.25.0"]

   ;; std.config
   [borkdude/edamame "1.4.24"]

   ;; std.contract
   [metosin/malli "0.17.0"]
   
   ;; std.html
   [org.jsoup/jsoup "1.17.2"]

   ;; std.image
   [com.twelvemonkeys.imageio/imageio-bmp  "3.10.1"]
   [com.twelvemonkeys.imageio/imageio-tiff "3.10.1"]
   [com.twelvemonkeys.imageio/imageio-icns "3.10.1"]
   [com.twelvemonkeys.imageio/imageio-jpeg "3.10.1"]

   ;; std.json
   [com.fasterxml.jackson.core/jackson-core "2.16.1"]
   [com.fasterxml.jackson.core/jackson-databind "2.16.1"]
   [com.fasterxml.jackson.datatype/jackson-datatype-jsr310 "2.16.1"]

   ;; std.math
   [org.apache.commons/commons-math3 "3.6.1"]

   ;; std.text.diff
   [com.googlecode.java-diff-utils/diffutils "1.3.0"]
   
   
   ;; MCP
   [org.hugoduncan/mcp-clj-server "0.1.60"]
   [org.clojure/core.async "1.6.681"]
   [http-kit "2.8.0"]
   [cheshire "5.13.0"]
   [com.cognitect/transit-clj "1.0.333"]
   [medley "1.4.0"]
   [org.clojure/tools.logging "1.3.0"]
   [ch.qos.logback/logback-classic "1.5.6"]
   [org.clojure/data.json "2.5.1"]
   
   ;; TESTS - std.object
   [org.eclipse.jgit/org.eclipse.jgit "5.13.0.202109080827-r"]]
  :global-vars {*warn-on-reflection* true})
