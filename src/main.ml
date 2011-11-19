open StdLabels

let () = 
  Findlib.init ();
  Fl_package_base.load_base ()

let () = Download.parse_database_file "config"

let () = 
  if not(Sys.file_exists Install.work_dir)
  then Unix.mkdir Install.work_dir 0o755

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
  let oasis = s ^ "/_oasis" in
  if Sys.file_exists oasis then 
    Install.install s oasis
  else
    failwith (Printf.sprintf "Oasis file not found in %s" oasis)

open Arg
let () = Arg.parse
  ["-i", String install, "install source from directory"]
  (fun s -> Printf.printf "anon: %s\n" s) "usage_str"
