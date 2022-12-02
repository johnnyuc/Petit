/* START definitions section -- C code delimited by %{ ... %} and substitutions */

%{

#include "y.tab.h"  // use specified token values
#include "ast.h"

#define YY_USER_ACTION { syn_line = lex_line; syn_column = lex_column; lex_column += yyleng; }
#define PASS_TOKEN() yylval.token = strdup(yytext);

int yyparse(void);
void yyerror(char *kind);

int return_tokens = 0;
int lex_line = 1, lex_column = 1;
int syn_line = -1, syn_column = -1;
int errors = 0;

extern struct node *program;

%}

%option noyywrap

ID      [a-zA-Z][a-zA-Z0-9]*
NATURAL [0-9]+
DECIMAL [0-9]+"."[0-9]+

/* END definitions section */

/* START rules section -- regular expressions for pattern matching */

%%

program     { return PROGRAM; }
integer     { return INTEGER; }
double      { return DOUBLE; }
print       { return PRINT; }
loop        { return LOOP; }
{ID}        { PASS_TOKEN(); return IDENTIFIER; }
{NATURAL}   { PASS_TOKEN(); return NATURAL; }
{DECIMAL}   { PASS_TOKEN(); return DECIMAL; }
[\t ]+      /* ignore whitespace */
\n			{ lex_line++; lex_column = 1; }
.           { return yytext[0]; }
<<EOF>>     { return 0; }

%%

/* END rules section */

/* START subroutines section -- user functions */

void yyerror(char *type) {
	errors++;
	printf("Line %d, column %d: %s '%s'\n", syn_line, syn_column, type, yytext);
}

int main(int argc, char *argv[]) {
	yyparse();
	if(argc >= 2 && strcmp(argv[1], "-t") == 0 && errors == 0) {   /* "-t" prints the AST */
		show(program, 0);
	}
    deallocate(program);
    yylex_destroy();
	return 0;
}

/* END subroutines section */