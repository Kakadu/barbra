type src_loc = 
    Git of string
  | Url of string

let database = [
  "core",Url "http://www.janestreet.com/ocaml/core-107.01.tar.gz";
  "gorgona", Git "git://github.com/ermine/gorgona.git"
]

let getlib name = List.assoc name database
