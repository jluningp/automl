structure S =
struct

(*! curry : ('a * 'b -> 'c) -> ('a -> 'b -> 'c) !*)

fun allEq x L = List.all (curry (op =) x) L

end
