open StdLabels
open OASISTypes
open OASISVersion

let get : OASISTypes.section list -> (string * string option) list =
    let rec inner acc = function
      | [] -> acc
      | Library (_, { bs_build_depends; _ }, _) :: sections
      | Executable (_, { bs_build_depends; _ }, _) :: sections ->
	let findlib_depends = List.fold_left
          ~f:(fun acc -> function
            | FindlibPackage (name, Some v) ->
	      (name, Some (string_of_comparator v) ) :: acc
            | FindlibPackage (name, None) -> (name, None) :: acc
            | _ -> acc
          ) ~init:[] bs_build_depends
	in inner (acc @ findlib_depends) sections
      | _ :: sections -> inner acc sections
    in inner []

  let is_installed pack_name = 
    try
      let (_ : Fl_package_base.package) = Fl_package_base.query pack_name in
      true
    with
	Fl_package_base.No_such_package (a,b) -> false

  let filter_uninstalled lst : (string*string option) list = 
    List.filter ~f:(fun (x,_) -> not (is_installed x)) lst

  let of_oasis_file name : (string * string option) list = 
    let { OASISTypes.sections; _ } = OASISParse.from_file
      ~ctxt:{!BaseContext.default with OASISContext.ignore_plugins = true}
      name
    in
    get sections
