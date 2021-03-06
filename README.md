# AutoML

This tool can be used to autogenerate ML functions from polymorphic type annotations. Simply write down the type of the 
polymorphic function you want, and this tool will write it for you!

## Syntax

AutoML types are declared in comments with (!) immediately inside the comment character. The types may use the following grammar:

```
typ := identifier | typ -> typ | typ * typ | typ + typ | unit | void
identifier := '[a-Z][a-Z]*
```

-> and * correspond to the type constructors as they are in Standard ML. 'a + 'b corresponds to the type ('a, 'b) either. 
unit corresponds to the unit type in Standard ML. void corresponds to the empty datatype declared as 
```
datatype void = Void of void
```
and corresponds to false/bottom (⊥) in logic. 

## Mechanics

Type annotations are parsed using the Haskell Parsec library. Code is generated using a G4ip theorem prover implemented in 
Haskell (code is not given here, since it was ported from a homework assignment in CMU's 15-317: Constructive Logic class). 

Since the functions fst and snd, and the datatype void do not exist in Standard ML, AutoML injects a Utils structure into 
the code it generates to create these functions. 

Code generated by AutoML can be found in the autogen-ml directory created by the tool.


## Example
The following is a valid type annotation:

```
(*! duplicate : 'a -> 'a * 'a !*)
```

AutoML then generates the corresponding function:

```
(*! duplicate : 'a -> 'a * 'a !*)
val duplicate = fn x1 => (x1, x1)
```

## Installing and Running
1. Clone this repo.
2. Install dependencies. This tool requires Python 2, SML/NJ, and rlwrap be installed and be callable using the python, sml, and rlwrap commands respectively. If you'd like to use something different, you can change what is called in ./automl. It's just a sad hacky bash script :). Additionally, there's a compiled binary in here that works on the CMU's AFS, but possibly not elsewhere. I wish I could give the source code, but it's a homework solution :/. 
3. Create a file containing AutoML type annotations, examples of which can be found in the examples/ directory.
4. Run AutoML:
```
./automl <sml file>
```
