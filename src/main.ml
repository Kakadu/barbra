open StdLabels
open Printf

let () = 
  Findlib.init ();
  Fl_package_base.load_base ()

let () = Download.parse_database_file "config"

let () = 
  if not(Sys.file_exists Install.workdir)
  then Unix.mkdir Install.workdir 0o755

open Depends


let (|>) x f = f x
(*
let is_library =
  List.exists ~f:(function Library _ -> true | _ -> false)

let is_executable =
  List.exists ~f:(function Executable _ -> true | _ -> false)
  *)

(*
let () =
  List.iter ~f:(fun (name,v) ->
    let exists = if is_installed name then "" else "\t<absent>" in
    match v with
    | None -> Printf.printf "%s %s\n" name exists
    | Some v -> Printf.printf "%s (%s)%s\n" name v exists
  ) (Depends.of_oasis_file Sys.argv.(1))
  *)  
(*  print_endline (if is_executable sections then "is executable" else "is not executable");
  print_endline (if is_library sections then "is library" else "is not library") *)
(*  
let _ = 
  Printf.printf "all packages are:\n";
  List.iter ~f:print_endline (Fl_package_base.list_packages ())
  *)

let install s = 
  Engine.engine [Engine.Download s]
   
let remove s = 
  let lst = Str.split (Str.regexp ",") s in 
  let cmd s = sprintf "sudo ocamlfind remove %s" s in
  List.iter lst ~f:(fun name ->
    let cmd = cmd name in
    printf "executing `%s`\n" cmd; flush stdout;
    let _ = Sys.command cmd in
    ()
  )

open Arg
let () = Arg.parse
  [("-i", String install, "install source from directory");
   ("-rm",String remove,  "remove packages via ocamfind")

  ]
  (fun s -> Printf.printf "anon: %s\n" s) "usage_str"
