%token IDENTIFIER CONSTANT STRING_LITERAL SIZEOF
%token PTR_OP INC_OP DEC_OP LEFT_OP RIGHT_OP LE_OP GE_OP EQ_OP NE_OP
%token AND_OP OR_OP MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN ADD_ASSIGN
%token SUB_ASSIGN LEFT_ASSIGN RIGHT_ASSIGN AND_ASSIGN
%token XOR_ASSIGN OR_ASSIGN TYPE_NAME

%token TYPEDEF EXTERN STATIC AUTO REGISTER INLINE RESTRICT
%token CHAR SHORT INT LONG SIGNED UNSIGNED FLOAT DOUBLE CONST VOLATILE VOID
%token BOOL COMPLEX IMAGINARY
%token STRUCT UNION ENUM ELLIPSIS

%token CASE DEFAULT IF ELSE SWITCH WHILE DO FOR GOTO CONTINUE BREAK RETURN

%start translation_unit

%{

#define YYSTYPE tree<string>

#include <cstdio>
#include <string>
#include <iostream>
#include <algorithm>
#include "tree.hh"
#include "ast_node.hh"
#include "tree_util.hh"

using namespace kptree;
using namespace std;

extern int yylex();
extern "C" int yyparse();
extern void fill_typenames();

void yyerror(const char *c);

tree<string> ast, ast_temp;

tree<string>::iterator mkrule(string name);
void apply_subtree(tree<string> &parent, tree<string>::iterator parents_dummy, tree<string>::iterator rule);
%}
%%

primary_expression
	: IDENTIFIER
	| CONSTANT
	| STRING_LITERAL
	| '(' expression ')'
	;

postfix_expression
	: primary_expression
	| postfix_expression '[' expression ']'
	| postfix_expression '(' ')'
	| postfix_expression '(' argument_expression_list ')'
	| postfix_expression '.' IDENTIFIER
	| postfix_expression PTR_OP IDENTIFIER
	| postfix_expression INC_OP
	| postfix_expression DEC_OP
	| '(' type_name ')' '{' initializer_list '}'
	| '(' type_name ')' '{' initializer_list ',' '}'
	;

argument_expression_list
	: assignment_expression
	| argument_expression_list ',' assignment_expression
	;

unary_expression
	: postfix_expression
	| INC_OP unary_expression
	| DEC_OP unary_expression
	| unary_operator cast_expression
	| SIZEOF unary_expression
	| SIZEOF '(' type_name ')'
	;

unary_operator
	: '&'
	| '*'
	| '+'
	| '-'
	| '~'
	| '!'
	;

cast_expression
	: unary_expression
	| '(' type_name ')' cast_expression
	;

multiplicative_expression
	: cast_expression
	| multiplicative_expression '*' cast_expression
	| multiplicative_expression '/' cast_expression
	| multiplicative_expression '%' cast_expression
	;

additive_expression
	: multiplicative_expression
	| additive_expression '+' multiplicative_expression
	| additive_expression '-' multiplicative_expression
	;

shift_expression
	: additive_expression
	| shift_expression LEFT_OP additive_expression
	| shift_expression RIGHT_OP additive_expression
	;

relational_expression
	: shift_expression
	| relational_expression '<' shift_expression
	| relational_expression '>' shift_expression
	| relational_expression LE_OP shift_expression
	| relational_expression GE_OP shift_expression
	;

equality_expression
	: relational_expression
	| equality_expression EQ_OP relational_expression
	| equality_expression NE_OP relational_expression
	;

and_expression
	: equality_expression
	| and_expression '&' equality_expression
	;

exclusive_or_expression
	: and_expression
	| exclusive_or_expression '^' and_expression
	;

inclusive_or_expression
	: exclusive_or_expression
	| inclusive_or_expression '|' exclusive_or_expression
	;

logical_and_expression
	: inclusive_or_expression
	| logical_and_expression AND_OP inclusive_or_expression
	;

logical_or_expression
	: logical_and_expression
	| logical_or_expression OR_OP logical_and_expression
	;

conditional_expression
	: logical_or_expression
	| logical_or_expression '?' expression ':' conditional_expression
	;

assignment_expression
	: conditional_expression
	| unary_expression assignment_operator assignment_expression
	;

assignment_operator
	: '='
	| MUL_ASSIGN
	| DIV_ASSIGN
	| MOD_ASSIGN
	| ADD_ASSIGN
	| SUB_ASSIGN
	| LEFT_ASSIGN
	| RIGHT_ASSIGN
	| AND_ASSIGN
	| XOR_ASSIGN
	| OR_ASSIGN
	;

expression
	: assignment_expression
	| expression ',' assignment_expression
	;

constant_expression
	: conditional_expression
	;

declaration
	: declaration_specifiers ';'
	| declaration_specifiers init_declarator_list ';'
	;

declaration_specifiers
	: storage_class_specifier
	| storage_class_specifier declaration_specifiers
	| type_specifier
	| type_specifier declaration_specifiers
	| type_qualifier
	| type_qualifier declaration_specifiers
	| function_specifier
	| function_specifier declaration_specifiers
	;

init_declarator_list
	: init_declarator
	| init_declarator_list ',' init_declarator
	;

init_declarator
	: declarator
	| declarator '=' initializer
	;

storage_class_specifier
	: TYPEDEF
	| EXTERN
	| STATIC
	| AUTO
	| REGISTER
	;

type_specifier
	: VOID { 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "VOID");
          $$ = ast;
        }
	| CHAR{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "CHAR");
          $$ = ast;
        }
	| SHORT{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "SHORT");
          $$ = ast;
        }
	| INT{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "INT");
          $$ = ast;
        }
	| LONG{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "LONG");
          $$ = ast;
        }
	| FLOAT{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "FLOAT");
          $$ = ast;
        }
	| DOUBLE{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "DOUBLE");
          $$ = ast;
        }
	| SIGNED{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "SIGNED");
          $$ = ast;
        }
	| UNSIGNED{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "UNSIGNED");
          $$ = ast;
        }
	| BOOL{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "BOOL");
          $$ = ast;
        }
	| COMPLEX{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "COMPLEX");
          $$ = ast;
        }
	| IMAGINARY{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "IMAGINARY");
          $$ = ast;
        }
	| struct_or_union_specifier{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.reparent(
            ast.append_child(root, "struct_or_union_specifier"),
            find($1.begin(), $1.end(), "root")
          );
          $$ = ast;
        }

	| enum_specifier{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "enum_specifier");
          $$ = ast;
        }

        | TYPE_NAME{ 
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "TYPE_NAME");
          $$ = ast;
        }
	;

struct_or_union_specifier
	: struct_or_union IDENTIFIER '{' struct_declaration_list '}' { 
          tree<string> ast;
          tree<string>::iterator root, subroot1, subroot2;
          root = ast.insert(ast.begin(),"root");

          ast.reparent(
            ast.append_child(root, "struct_or_union"),
            find($1.begin(), $1.end(), "root")
          );

          ast.append_child(root, "IDENTIFIER");

          ast.append_child(root, "{");

          ast.reparent(
            ast.append_child(root, "struct_declaration_list"),
            find($4.begin(), $4.end(), "root")
          );

          cout << endl;
          print_tree_dashed(ast);
          cout << endl;
          $$ = ast;
        }
	| struct_or_union '{' struct_declaration_list '}' { 
          tree<string> ast;
          tree<string>::iterator root, subroot1, subroot2;
          root = ast.insert(ast.begin(),"root");

          ast.reparent(
            ast.append_child(root, "struct_or_union"),
            find($1.begin(), $1.end(), "root")
          );

          ast.append_child(root, "{");

          ast.reparent(
            ast.append_child(root, "struct_declaration_list"),
            find($3.begin(), $3.end(), "root")
          );

          ast.append_child(root, "}");

          cout << endl;
          print_tree_bracketed(ast);
          cout << endl;
          $$ = ast;
        }
        | struct_or_union IDENTIFIER {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");

          ast.reparent(
            ast.append_child(root, "struct_or_union"),
            find($1.begin(), $1.end(), "root")
          );

          ast.append_child(root, "IDENTIFIER");

          cout << endl;
          print_tree_bracketed(ast);
          cout << endl;

          $$ = ast;
        }
	;

struct_or_union
	: STRUCT {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(),"root");
          ast.append_child(root, "STRUCT");
          $$ = ast;
        }
	| UNION{
          tree<string> ast;
          tree<string>::iterator rule;
          rule = ast.insert(ast.begin(),"root");
          ast.append_child(rule, "UNION");
          $$ = ast;
        }
	;

struct_declaration_list
	: struct_declaration {
          tree<string> ast;
          tree<string>::iterator root, subroot;
          root = ast.insert(ast.begin(),"root");
          ast.reparent(
            ast.append_child(root, "struct_declaration"),
            find($1.begin(), $1.end(), "root")
          );
          $$ = ast;
        }
	| struct_declaration_list struct_declaration {
          tree<string> ast;
          tree<string>::iterator root,sdl;

          root = ast.insert(ast.begin(), "root");

          ast.reparent(
            ast.append_child(root, "struct_declaration_list"),
            find($1.begin(), $1.end(), "root")
          );
          ast.reparent(
            ast.append_child(root, "struct_declaration"),
            find($2.begin(), $2.end(), "root")
          );

          $$ = ast;
        }
	;

struct_declaration
	: specifier_qualifier_list struct_declarator_list ';' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");

          ast.reparent(
            ast.append_child(root, "specifier_qualifier_list"),
            find($1.begin(), $1.end(), "root"));
          ast.reparent(
            ast.append_child(root, "struct_declarator_list"),
            find($2.begin(), $2.end(), "root"));
          ast.append_child(root, ";");

          $$ = ast;
        }
	;

specifier_qualifier_list
	: type_specifier specifier_qualifier_list {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");

          ast.reparent(
            ast.append_child(root, "type_specifier"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "specifier_qualifier_list");

          $$ =ast;
        }
	| type_specifier {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "type_specifier"),
            find($1.begin(), $1.end(), "root")
          );
          $$ =ast;
        }
	| type_qualifier specifier_qualifier_list {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "type_qualifier"),
            find($1.begin(), $1.end(), "root")
            );
          ast.reparent(
          ast.append_child(root, "specifier_qualifier_list"),
            find($2.begin(), $2.end(), "root")
            );
          $$ = ast;
        }
	| type_qualifier{
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");

          ast.reparent(
            ast.append_child(root, "type_qualifier"),
            find($1.begin(), $1.end(), "root")
            );
          $$ =ast;
        }
	;

struct_declarator_list
	: struct_declarator {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(root, find($1.begin(), $1.end(), "root"));
          $$ =ast;
        }
	| struct_declarator_list ',' struct_declarator{
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(root, find($1.begin(), $1.end(), "root"));
          ast.append_child(root, ",");
          ast.reparent(root, find($2.begin(), $2.end(), "root"));
          $$ =ast;
        }
	;

struct_declarator
	: declarator {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "declarator"),
            find($1.begin(), $1.end(), "root")
          );
          $$ =ast;
        }
	| ':' constant_expression {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.append_child(root, ":");
          ast.append_child(root, "constant_expression");
          $$ =ast;
        }
	| declarator ':' constant_expression {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, ":");
          ast.append_child(root, "constant_expression");
          $$ =ast;
        }
	;

enum_specifier
	: ENUM '{' enumerator_list '}'
	| ENUM IDENTIFIER '{' enumerator_list '}'
	| ENUM '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER '{' enumerator_list ',' '}'
	| ENUM IDENTIFIER
	;

enumerator_list
	: enumerator
	| enumerator_list ',' enumerator
	;

enumerator
	: IDENTIFIER
	| IDENTIFIER '=' constant_expression
	;

type_qualifier
	: CONST {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.append_child(root, "CONST");
          $$ = ast;
        }
	| RESTRICT {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.append_child(root, "RESTRICT");
          $$ = ast;
        }
	| VOLATILE {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.append_child(root, "VOLATILE");
          $$ = ast;
        }
	;

function_specifier
	: INLINE
	;

declarator
	: pointer direct_declarator {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "pointer"),
            find($1.begin(), $1.end(), "root")
          );
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($2.begin(), $2.end(), "root")
          );
          $$ = ast;
        }
	| direct_declarator {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          $$ = ast;
        }
	;


direct_declarator
	: IDENTIFIER {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.append_child(root, "IDENTIFIER"),
          $$ = ast;
        }
	| '(' declarator ')' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.append_child(root, "(");
          ast.reparent(
            ast.append_child(root, "declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, ")");
          $$ = ast;
        }
	| direct_declarator '[' type_qualifier_list assignment_expression ']' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "[");
          ast.reparent(
            ast.append_child(root, "type_qualifier_list"),
            find($3.begin(), $3.end(), "root")
          );
          ast.reparent(
            ast.append_child(root, "type_qualifier_list"),
            find($4.begin(), $4.end(), "root")
          );
          ast.append_child(root, "]");
          $$ = ast;
        }
	| direct_declarator '[' type_qualifier_list ']' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "[");
          ast.reparent(
            ast.append_child(root, "type_qualifier_list"),
            find($3.begin(), $3.end(), "root")
          );
          ast.append_child(root, "]");
          $$ = ast;
        }
	| direct_declarator '[' assignment_expression ']' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "[");
          ast.reparent(
            ast.append_child(root, "assignment_expression"),
            find($3.begin(), $3.end(), "root")
          );
          ast.append_child(root, "]");
          $$ = ast;
        }
	| direct_declarator '[' STATIC type_qualifier_list assignment_expression ']' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "[");
          ast.reparent(
            ast.append_child(root, "STATIC"),
            find($3.begin(), $3.end(), "root")
          );
          ast.reparent(
            ast.append_child(root, "type_qualifier_list"),
            find($4.begin(), $4.end(), "root")
          );
          ast.reparent(
            ast.append_child(root, "assignment_expression"),
            find($5.begin(), $5.end(), "root")
          );
          ast.append_child(root, "]");
          $$ = ast;
        }
	| direct_declarator '[' type_qualifier_list STATIC assignment_expression ']' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "[");
          ast.reparent(
            ast.append_child(root, "type_qualifier_list"),
            find($3.begin(), $3.end(), "root")
          );
          ast.reparent(
            ast.append_child(root, "STATIC"),
            find($4.begin(), $4.end(), "root")
          );
          ast.reparent(
            ast.append_child(root, "assignment_expression"),
            find($5.begin(), $5.end(), "root")
          );
          ast.append_child(root, "]");
          $$ = ast;
        }
	| direct_declarator '[' type_qualifier_list '*' ']' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "[");
          ast.reparent(
            ast.append_child(root, "type_qualifier_list"),
            find($3.begin(), $3.end(), "root")
          );
          ast.reparent(
            ast.append_child(root, "*"),
            find($4.begin(), $4.end(), "root")
          );
          ast.append_child(root, "]");
          $$ = ast;
        }
	| direct_declarator '[' '*' ']' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "[");
          ast.reparent(
            ast.append_child(root, "*"),
            find($3.begin(), $3.end(), "root")
          );
          ast.append_child(root, "]");
          $$ = ast;
        }
	| direct_declarator '[' ']' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "[");
          ast.append_child(root, "]");
          $$ = ast;
        }
	| direct_declarator '(' parameter_type_list ')' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "(");
          ast.reparent(
            ast.append_child(root, "parameter_type_list"),
            find($3.begin(), $3.end(), "root")
          );
          ast.append_child(root, ")");
          $$ = ast;
        }
	| direct_declarator '(' identifier_list ')' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "(");
          ast.reparent(
            ast.append_child(root, "identifier_list"),
            find($3.begin(), $3.end(), "root")
          );
          ast.append_child(root, ")");
          $$ = ast;
        }
	| direct_declarator '(' ')' {
          tree<string> ast;
          tree<string>::iterator root;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "direct_declarator"),
            find($1.begin(), $1.end(), "root")
          );
          ast.append_child(root, "(");
          ast.append_child(root, ")");
          $$ = ast;
        }
	;

pointer
	: '*' {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.append_child(root, "*");
          $$ = ast;
        }
	| '*' type_qualifier_list {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.append_child(root, "*");
          ast.reparent(
            ast.append_child(root, "type_qualifier_list"),
            find($2.begin(), $2.end(), "root")
          );
          $$ = ast;
        }
	| '*' pointer {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.append_child(root, "*");
          ast.append_child(root, "pointer");
          $$ = ast;
        }
	| '*' type_qualifier_list pointer {
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.append_child(root, "*");
          ast.reparent(
            ast.append_child(root, "type_qualifier_list"),
            find($2.begin(), $2.end(), "root")
          );
          ast.reparent(
            ast.append_child(root, "pointer"),
            find($2.begin(), $2.end(), "root")
          );
          $$ = ast;
        }
	;

type_qualifier_list
	: type_qualifier{
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "type_qualifier"),
            find($1.begin(), $1.end(), "root")
          );
          $$ = ast;
        }
	| type_qualifier_list type_qualifier{
          tree<string> ast;
          tree<string>::iterator root, sd;
          root = ast.insert(ast.begin(), "root");
          ast.reparent(
            ast.append_child(root, "type_qualifier_list"),
            find($1.begin(), $1.end(), "root")
          );
          ast.reparent(
            ast.append_child(root, "type_qualifier"),
            find($2.begin(), $2.end(), "root")
          );
          $$ = ast;
        }
	;


parameter_type_list
	: parameter_list
	| parameter_list ',' ELLIPSIS
	;

parameter_list
	: parameter_declaration
	| parameter_list ',' parameter_declaration
	;

parameter_declaration
	: declaration_specifiers declarator
	| declaration_specifiers abstract_declarator
	| declaration_specifiers
	;

identifier_list
	: IDENTIFIER
	| identifier_list ',' IDENTIFIER
	;

type_name
	: specifier_qualifier_list
	| specifier_qualifier_list abstract_declarator
	;

abstract_declarator
	: pointer
	| direct_abstract_declarator
	| pointer direct_abstract_declarator
	;

direct_abstract_declarator
	: '(' abstract_declarator ')'
	| '[' ']'
	| '[' assignment_expression ']'
	| direct_abstract_declarator '[' ']'
	| direct_abstract_declarator '[' assignment_expression ']'
	| '[' '*' ']'
	| direct_abstract_declarator '[' '*' ']'
	| '(' ')'
	| '(' parameter_type_list ')'
	| direct_abstract_declarator '(' ')'
	| direct_abstract_declarator '(' parameter_type_list ')'
	;

initializer
	: assignment_expression
	| '{' initializer_list '}'
	| '{' initializer_list ',' '}'
	;

initializer_list
	: initializer
	| designation initializer
	| initializer_list ',' initializer
	| initializer_list ',' designation initializer
	;

designation
	: designator_list '='
	;

designator_list
	: designator
	| designator_list designator
	;

designator
	: '[' constant_expression ']'
	| '.' IDENTIFIER
	;

statement
	: labeled_statement
	| compound_statement
	| expression_statement
	| selection_statement
	| iteration_statement
	| jump_statement
	;

labeled_statement
	: IDENTIFIER ':' statement
	| CASE constant_expression ':' statement
	| DEFAULT ':' statement
	;

compound_statement
	: '{' '}'                 {}
	| '{' block_item_list '}' {}
	;

block_item_list
	: block_item
	| block_item_list block_item
	;

block_item
	: declaration
	| statement
	;

expression_statement
	: ';'
	| expression ';'
	;

selection_statement
	: IF '(' expression ')' statement
	| IF '(' expression ')' statement ELSE statement
	| SWITCH '(' expression ')' statement
	;

iteration_statement
	: WHILE '(' expression ')' statement
	| DO statement WHILE '(' expression ')' ';'
	| FOR '(' expression_statement expression_statement ')' statement
	| FOR '(' expression_statement expression_statement expression ')' statement
	| FOR '(' declaration expression_statement ')' statement
	| FOR '(' declaration expression_statement expression ')' statement
	;

jump_statement
	: GOTO IDENTIFIER ';'
	| CONTINUE ';'
	| BREAK ';'
	| RETURN ';'
	| RETURN expression ';'
	;

translation_unit
	: external_declaration
	| translation_unit external_declaration
	;

external_declaration
	: function_definition
	| declaration
	;

function_definition
	: declaration_specifiers declarator declaration_list compound_statement
	| declaration_specifiers declarator compound_statement
	;

declaration_list
	: declaration {}
	| declaration_list declaration
	;


%%
#include <stdio.h>

extern char yytext[];
extern int column;


void yyerror(char const *s)
  {
          fflush(stdout);
          printf("\n%*s\n%*s\n", column, "^", column, s);
  }
using namespace kptree;

int main(){
  fill_typenames();
  yyparse();
}

tree<string>::iterator mkrule(string name){
  tree<string> ast;
  tree<string>::iterator rule,root;
  root = ast.insert(ast.begin(), "root");
  rule = ast.append_child(root, name);
  return rule;
}
void apply_subtree(tree<string> &ast, tree<string>::iterator rule, tree<string>::iterator implacement){
  ast.move_ontop(implacement, rule);
}
