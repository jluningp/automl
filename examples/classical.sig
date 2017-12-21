signature CLASSICAL =
sig
  type ('a,'b) iff = (('a -> 'b) * ('b -> 'a))
  datatype ('a,'b) or = L of 'a | R of 'b
  type 'a not
  val contra : 'a not -> 'a -> 'b
  val assume : ('a not -> 'a) -> 'a
end

signature PROOFS =
sig
  include CLASSICAL

  val projl : 'a * 'b -> 'a
  val projr : 'a * 'b -> 'b

  val conj_over_conj : ('a * ('b * 'c), ('a * 'b) * ('a * 'c)) iff
  val conj_over_disj : ('a * ('b,'c) or,('a * 'b,'a * 'c) or) iff
  val imp_over_imp   : ('a -> 'b -> 'c) -> ('a -> 'b) -> 'a -> 'c
  val imp_over_iff   : ('a -> ('b,'c) iff,('a -> 'b,'a -> 'c) iff) iff
  val schoenfinkel   : ('a -> 'b -> 'c,'a * 'b -> 'c) iff

  val law_ex_mid     : unit -> ('a, 'a not) or
  val demorgan_cong  : (('a * 'b) not, ('a not, 'b not) or) iff
  val demorgan_disj  : (('a,'b) or not, ('a not) * ('b not)) iff

  val dne            : 'a not not -> 'a
  val contrapos      : ('a -> 'b,'b not -> 'a not) iff
  val neg_over_iff   : (('a,'b) iff not,('a not,'b) iff) iff
end
