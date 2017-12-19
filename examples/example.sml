(* Some examples of autogenerated functions *)
(* For the first two functions, there is only one way to correctly implement
   a total function with that type.
   For the third, there are two: fst and snd. There are no guarantees about which
   one you'll get (though in this case it's fst). If you want the guarantee, you'd
   need to specify it more carefully, as in the fourth and fifth example *)


(*! curry : ('a * 'b -> 'c) -> ('a -> 'b -> 'c) !*)
(*! id : 'a -> 'a !*)

(*! fstOrSnd : 'a * 'a -> 'a !*)

(*! fst : 'a * 'b -> 'a !*)
(*! snd : 'a * 'b -> 'b !*)

(*! contra : void -> 'a !*)

fun foo x = curry (fn (x, y) => x)
