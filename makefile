all:
	flex -d c99.l
	bison c99.y
	g++ c99.tab.c lex.yy.c -o parser

graph:
	bison --graph c99.y

tree:
	g++ main.cpp -o tree
