# Presentation

This project was the final project for a Compilation course at university, which you can see [here](https://public.lmf.cnrs.fr/~blsk/CompilationLDD3/dm-kawa.html).
The goal is to create an interpreter for a java-like language called ``` Kawa```, using the extension ```.kwa```.

# Requirements

This project was used with the langage ``` Ocaml ```, you will need to have ``` dune ``` and ```opam```installed on your computer, as well as the Ocaml library ```menhir```.

# How to use it

Once you have the requirements, write the ```Kawa``` code in a ```code.kwa```file, and type ```dune build```. Then type ```./kawai.exe code.kwa``` and your code will get executed.

# Addtionnal options

When typing ```./kawai.exe code.kwa```, you can add options to help you :

- Adding ```-s``` will display which step the code is (Lexing the file, parsing, typechecking or interpreting it)/
- Adding ```-env``` will display the name and types of every variables allocated at the beginning.
- Adding ```-cl``` will display informations about the classes of your file : their attributes, their methods and the signature of these methods.
- By adding ```-F```, the program will not interpret the file, simply parse it, typecheck it. It can be used in pair with ```-cl``` to just show the classes for example.

Examples : 

- ```./kawai.exe code.kwa -s -env``` will show the steps of the program and the variables allocated.
- ``` ./kawai.exe code.kwa -cl -F > code.txt``` will stock the classes, methods defined in code.kwa in a file. The code defined in the main function will not be executed.
