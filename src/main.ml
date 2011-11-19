open StdLabels

let () = 
  Findlib.init ();
  Fl_package_base.load_base ()

open Depends
let (|>) x f = f x
(*
let is_library =
  List.exists ~f:(function Library _ -> true | _ -> false)

let is_executable =
  List.exists ~f:(function Executable _ -> true | _ -> false)
  *)


let () =
  let oasis_fn = Sys.argv.(1) in
  let { OASISTypes.sections; _ } = OASISParse.from_file
      ~ctxt:{!BaseContext.default with OASISContext.ignore_plugins = true}
      oasis_fn
  in

  List.iter ~f:(fun (name,v) ->
    let exists = if is_installed name then "" else "\t<absent>" in
    match v with
    | None -> Printf.printf "%s %s\n" name exists
    | Some v -> Printf.printf "%s (%s)%s\n" name v exists
  ) (Depends.get sections)
  
(*  print_endline (if is_executable sections then "is executable" else "is not executable");
  print_endline (if is_library sections then "is library" else "is not library") *)
(*  
let _ = 
  Printf.printf "all packages are:\n";
  List.iter ~f:print_endline (Fl_package_base.list_packages ())
  *)
