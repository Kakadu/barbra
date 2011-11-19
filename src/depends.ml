open StdLabels
open OASISTypes
open OASISVersion

let get =
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
      Fl_package_base.query pack_name;
      true
    with
	Fl_package_base.No_such_package (a,b) -> false

  let filter_uninstalled = List.filter ~f:(fun x -> not (is_installed x))
