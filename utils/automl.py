import sys
import subprocess
import tempfile
import os

def findExn (f, s):
    index = f.find(s)
    if index < 0:
        raise ValueError
    else:
        return index

def findAutoComment(f):
    newFile = []
    for f in f.readlines():
        try:
            mlTyp = f[findExn(f, "(*!") + 3:]
            mlVal = mlTyp[:findExn(mlTyp, ":")]
            mlTyp = mlTyp[findExn(mlTyp, ":") + 1:]
            mlTyp = mlTyp[:findExn(mlTyp, "!*)")]
            process = subprocess.Popen(['utils/parser', mlTyp], stdout=subprocess.PIPE)
            typ = process.communicate()[0]
            code = getCode(typ, mlTyp)
            newFile.append(f)
            newFile.append("val " + mlVal + "= " + code + "\n")
        except ValueError:
            newFile.append(f)
    return newFile


def getCode(typ, ml):
    process = subprocess.Popen(['sml', '@SMLload=utils/automl.x86-linux'], stdout=subprocess.PIPE, stdin=subprocess.PIPE)

    smlIn = ("open Prop;"
             "Term.printOptML (G4ip.certify(" + typ + "));")

    stdout = process.communicate(smlIn)[0]
    try:
        expr = stdout[findExn(stdout, "SOME") + 4:]
        expr = expr[:expr.find("val")]
    except ValueError:
        raise TypeError("Cannot synthesize type: " + ml)
    return expr


fil = sys.argv[1]
if not os.path.exists("autogen-ml"):
        os.makedirs("autogen-ml")


automl_utils = ("structure AUTOML_UTILS = \n"
                "struct\n"
                "  datatype bottom = Bottom of bottom"
                "  fun fst (x, y) = x\n"
                "  fun snd (x, y) = y\n"
                "  fun abort x = case x of Bottom y => abort y\n"
                "end\n"
                )

with open(fil) as f:
    newFile = findAutoComment(f)
    newFile = [automl_utils] + newFile
    filename = "autogen-ml/" + os.path.basename(fil)
    tmp = open(filename, "w+")
    for l in newFile:
        tmp.write(l)
    print(filename)
