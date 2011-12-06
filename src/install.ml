open StdLabels
open Printf

let cwd = Unix.getcwd ()
let workdir = cwd ^ "/work/"
let (|>) x f = f x

let endswith ~postfix s = 
  let plen =  String.length postfix in
  if plen > (String.length s) then false
  else begin    
    let delta = String.length s - plen in
    let rec inner i =
      if plen<= i then true 
      else if postfix.[i] = s.[delta+i] then inner (i+1)
      else false
    in
    inner 0
  end
(*
exception Bad_library_directory of string
let lib_dirname url = 
  let r = String.rindex url '/' in
  if endswith ~postfix:".git" url then
    String.sub url (r+1) (String.length url -r -4-1)
  else raise (Bad_library_directory "url")

let rec install dir oasis_file = 
  Printf.printf "Installing %s\n" dir;
  let open Download in
  let bad_depends = Depends.filter_uninstalled (Depends.of_oasis_file oasis_file) in
  Printf.printf "Unresolved depends: %d\n" (List.length bad_depends);
  List.iter bad_depends ~f:(fun (name,v) ->
    if not (List.mem_assoc name !Download.database) 
    then printf "Don't know how to resolve dependense %s\n" name
    else
      match List.assoc name !Download.database with
	| Git url ->
	  let lib_dirname = lib_dirname url in
	  Printf.printf "libdirname = %s\n" lib_dirname;
	  if Download.git_clone ~dest:(work_dir ^ lib_dirname) url then begin
	    let oasis_file = String.concat ~sep:"/" [work_dir; lib_dirname; "_oasis"] in
	    if Sys.file_exists oasis_file then 
	      (printf "oasis file for %s successfully downloaded\n" name;
	       install(work_dir ^ lib_dirname) "_oasis";
	       install dir oasis_file
	      )
	    else printf "no oasis file for %s\n" name
	  end 
	  else
	    Printf.printf "failed to install library %s  in directory %s\n" name work_dir
	    
	| Url url -> failwith "Urls are not supported yet"
  );
  Unix.chdir dir;  
  Printf.printf "changing dir to %s\n" dir; 
  flush stdout;
  let wrap cmd = 
    Printf.printf "%s\n" cmd; flush stdout;
    let x = Sys.command cmd in
    if x<>0 then Some (sprintf "Error %d\n" x)
    else None
  in
  let exists file = Sys.file_exists file in
  let (>>=) x f = match x with
    | Some _ -> x
    | _      -> f () in
  (if exists "configure" then wrap "./configure" else None) 
  >>= (fun () -> 
    if exists "Makefile" then (
      (wrap  "make ") 
      >>= (fun () -> wrap  "sudo make install")
    ) else (
      (wrap  "ocaml setup.ml -build") 
      >>= (fun () -> wrap  "sudo ocaml setup.ml -install")
    )
  )
  |> (fun x -> flush stdout;
    match x with
    | Some s -> printf "Some error happend: %s\n" s
    | None -> printf "no errors happened\n"
  );
  Unix.chdir cwd;
  Printf.printf "Finishing installing %s\n" dir
  *)
