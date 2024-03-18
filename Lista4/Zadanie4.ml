module type DICT = sig
  type key 
  type 'a dict
  val empty : 'a dict
  val insert : key -> 'a -> 'a dict -> 'a dict
  val remove : key -> 'a dict -> 'a dict
  val find_opt : key -> 'a dict -> 'a option
  val find : key -> 'a dict -> 'a
  val to_list : 'a dict -> (key * 'a) list
end

module MakeMapDict (M: Map.OrderedType) : (DICT with type key = M.t) = struct
  include Map.Make(M)
  type 'a dict = 'a Map.Make(M).t
  let insert k v d = add k v d
  let to_list d = bindings d
end

module CharMapDict = MakeMapDict (Char);;

let dict = CharMapDict.empty;;
let dict_with_insertion = CharMapDict.insert 'a' 123 dict;;
let dict_to_list = CharMapDict.to_list dict_with_insertion;;