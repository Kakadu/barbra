open Printf
type src_loc = 
    Git of string
  | Url of string

let database = ref []

let getlib name = List.assoc name !database

let parse_database_file name = 
  let h = open_in name in
  let rec helper acc =
    try
      let item = Scanf.fscanf h "%s %s %s\n" (fun name typ text -> 
	match typ with
	  | "Git" -> (name, Git text)
	  | "Url" -> (name, Url text)
	  | _ -> failwith "bad database"
      ) in
      helper (item::acc)
    with End_of_file -> acc
  in
  database := helper [];
  Printf.printf "datbase has %d items\n" (List.length !database);
  close_in h

let git_clone ~dest url = 
  flush stdout;
  let cmd = sprintf "git clone %s %s" url dest in
  if Sys.file_exists dest then
    ignore (Sys.command (sprintf "rm -rf %s" dest) );
  Printf.printf "clone cmd: %s\n" cmd;
  let res = Sys.command cmd in
  (res=0)
