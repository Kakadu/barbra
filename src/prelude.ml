let (|>) x f = f x
open Printf
exception Not_supported of string
exception CantExtractArchive of string

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


(* TODO handle archives without toplevel directory - complain? *)
(* TODO handle archives with wrong toplevel directory name - complain? *)
(* overwrite? *)
let unpack ~dir file =
  let f postfix = endswith ~postfix file in
  let lst = [
    ".tar.gz", (fun dir name -> sprintf "tar -C %s -xzf %s" dir file);
    ".tgz",    (fun dir name -> sprintf "tar -C %s -xzf %s" dir file)
  ] in
  try
    let dirname = ref "" in
    let _ = List.find (fun (postfix, f) ->
      if endswith ~postfix file then begin
        dirname := String.sub file 0 (String.length file - (String.length postfix));
	let cmd = f dir file in
	let ans = Sys.command cmd in
	if ans<>0 then begin
	  printf "Error while extraction archive %s\n" file; flush stdout; assert false
	end else true
      end
      else false
    ) lst in
    !dirname
  with Not_found -> raise (CantExtractArchive file)

