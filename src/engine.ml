open Printf
open Prelude
open Sys
open Download 
exception NoConfigFile of string
exception CantInstallDepends of string list
exception CantGetSources of string
exception ErrorWhileCompiling of string
exception GeneralError of string
exception ErrorWhileInstalling of string
type target = 
  | Download of string
  | Build of string
  | Install of string

let wrap_cmd cmd = 
  printf "executing command `%s`\n" cmd; flush stdout;
  let ans = Sys.command cmd in
  if ans <> 0 then (
    printf "`%s` has returned %d. ERROR" cmd ans;
    `Error
  ) else
    `OK
;;
let (>>=) res f = match res with `OK -> f () | `Error -> `Error
let git_clone s ~place = 
  if file_exists place then (
    chdir place;
    let _ = wrap_cmd "git clean -fdx" in
    let _ = wrap_cmd "git pull" in
    chdir "..";
    `OK
  ) else
    wrap_cmd (sprintf "git clone %s %s" s place)


let rec engine xs = 
  let rec inner xs = match xs with
  | Download name ->
    chdir Install.workdir;
    printf "Downloading library %s....\n" name; flush stdout;
    let _ = wrap_cmd "ls" in
    let packinfo = Download.getlib name |> (function Some x -> x | None -> assert false) in
    let () = match packinfo with 
      | Url url -> 
	let file = 
	  let n = String.rindex url '/' in
	  String.sub url (n+1) (String.length url - n -1 ) in
	let cmd = sprintf "curl -sS -f -m20 -o %s %s" (Filename.quote file) (Filename.quote url) in
	(match wrap_cmd cmd with
	  | `Error -> raise (CantGetSources name)
	  |`OK -> ());
	let dirname = unpack ~dir:Install.workdir file in
	let _ = Sys.command (sprintf "mv %s %s -f" dirname name) in
	chdir name
      | Git url -> 
	(match (git_clone url ~place:name) with 
	  | `Error -> raise (CantGetSources name)
	  | `OK -> chdir (Install.workdir ^ name) )
    in

	
	if not (file_exists "_oasis") then  raise (NoConfigFile name);
	let depends = Depends.of_oasis_file "_oasis" in
	let (bad,db,system) = Depends.split_depends depends in
	print_endline "System-installed dependences are:";
	print_endline (system |> List.map fst |> String.concat ",");
	if bad <> [] then
	  raise (CantInstallDepends (List.map fst bad));
	(List.map (fun (name,_) -> Download name) db) @ [Build name]
    
  | Build name -> 
    chdir (Install.workdir ^ name);
    (if file_exists "configure" then wrap_cmd "./configure" else `OK) 
    >>= (fun () ->
      if file_exists "Makefile" then wrap_cmd "make"
      else wrap_cmd "ocaml setup.ml -build"
    ) |> (function
      | `OK -> [Install name]
      | `Error -> raise (ErrorWhileCompiling name)
    )
  | Install name -> 
    chdir (Install.workdir ^ name);
    let ans = if file_exists "Makefile" then wrap_cmd "make install"
      else wrap_cmd "ocaml setup.ml -install" in
    match ans with
      | `OK -> Printf.printf "Installation of %s succedeed\n" name; flush stdout; []
      | `Error -> raise (ErrorWhileInstalling name)
  in
  List.iter (function x -> x |> inner |> engine) xs
	  
(*	  
	
	>>= (fun () -> if file_exits "configure" then wrap_cmd "./configure" else `OK)
	>>= (fun ()

	)
  *)
