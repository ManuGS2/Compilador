%{
/*
	Descripcion
	Programa que realiza las tres etapas del proceso de compilación para
	el lenguaje definido en clase Pu+
		* Análisis léxico
		* Análisis sintáctico
		* Análisis semántico
	Además, se agrega un proceso de traducción en donde convierte los operadores
	relacionales a su equivalente en lenguaje C

	Autores
	Guzman Sanchez Jose Emmanuel
	Hernandez Romero Pompeyo

*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

FILE *tblSimbolos;  // 1) Tabla de identificadores (dinamica)
FILE *tblCteCad;	// 6) Tabla de constantes tipo cadena (dinamica)
FILE *elementos;	// Tabla con los tokens generados en el analisis (dinamica)
FILE *salida;		// Archivo de salida con el texto traducido

	// Definimos la estructura en las que guardaremos los valores de
	// las tablas. En este caso se hace uso de una lista simple

typedef struct Elemento
{
    struct Elemento *siguiente; 
    int posicion;
    char *nombre;
    char *tipo;
}Elemento;

typedef struct Tabla
{
	struct Elemento *primero;
	struct Elemento *ultimo;
}Tabla;

Tabla *tokens;
Tabla *simbolos;
Tabla *cadenas;
Tabla *relacional;
Tabla *reservadas;
Tabla *clases;
char  cadAtomos[1000];
//char  cadTokens[1000];
Elemento *cadTokens;
char  c;
char *atr;
int   i=0, j=0;


/*************************************************************/
/******************** Analisis lexico ************************/
/*************************************************************/

int buscar(char *cmpLexico, Tabla *tabla){
	// Funcion que busca si el componente lexico indicado se encuentra
	// dentro de la tabla indicada

	Elemento *actual = tabla->primero;
	while (actual != NULL){

		if (strcmp(actual->nombre, cmpLexico) != 0)
			actual = actual->siguiente;
		else
			return actual->posicion;
	}
	return -1;
}

int mostrarTabla(Tabla *tabla, FILE *archivo){
	//	Funcion para mostrar el contenido de una tabla y escribirla en un archivo

	Elemento *actual = tabla->primero;
	while(actual != NULL){
		printf("%i %s %s\n", actual->posicion,actual->nombre,actual->tipo);
		fprintf(archivo,"%i %s %s\n", actual->posicion,actual->nombre,actual->tipo);
		actual = actual->siguiente;
	}
	return 0;
}

char * convertToStr(int num){
	// Funcion que convierte un entero a cadena

	if (num == 0){return "0";}
	else if(num == 1){return "1";}
	else if(num == 2){return "2";}
	else if(num == 3){return "3";}
	else if(num == 4){return "4";}
	else if(num == 5){return "5";}
	else if(num == 6){return "6";}
	else if(num == 7){return "7";}
	else if(num == 8){return "8";}
	else if(num == 9){return "9";}
	else if(num == 10){return "10";}
	else if(num == 11){return "11";}
	else if(num == 12){return "12";}
	else if(num == 13){return "13";}
	else if(num == 14){return "14";}
	else if(num == 15){return "15";}
}

int convertToInt(char *num){
	// Funcion que convierte una cadena a entero

	if (strcmp(num,"0") == 0){return 0;}
	else if(strcmp(num,"1") == 0){return 1;}
	else if(strcmp(num,"2") == 0){return 2;}
	else if(strcmp(num,"3") == 0){return 3;}
	else if(strcmp(num,"4") == 0){return 4;}
	else if(strcmp(num,"5") == 0){return 5;}
	else if(strcmp(num,"6") == 0){return 6;}
	else if(strcmp(num,"7") == 0){return 7;}
	else if(strcmp(num,"8") == 0){return 8;}
	else if(strcmp(num,"9") == 0){return 9;}
	else if(strcmp(num,"10") == 0){return 10;}
	else if(strcmp(num,"11") == 0){return 11;}
	else if(strcmp(num,"12") == 0){return 12;}
	else if(strcmp(num,"13") == 0){return 13;}
	else if(strcmp(num,"14") == 0){return 14;}
	else if(strcmp(num,"15") == 0){return 15;}
}

int agregarAtomo(int clase, char *valor){
	// Funcion que agregar un atomo a la cadena de atomos

	if (clase == 2 || clase == 3 || clase == 5){
		strcat(cadAtomos, valor);
	}
	else if (clase == 0){
		if(strcmp(valor,"0") == 0){strcat(cadAtomos,"b");}
		else if(strcmp(valor,"1") == 0){strcat(cadAtomos,"c");}
		else if(strcmp(valor,"2") == 0){strcat(cadAtomos,"t");}
		else if(strcmp(valor,"3") == 0){strcat(cadAtomos,"e");}
		else if(strcmp(valor,"4") == 0){strcat(cadAtomos,"f");}
		else if(strcmp(valor,"5") == 0){strcat(cadAtomos,"h");}
		else if(strcmp(valor,"6") == 0){strcat(cadAtomos,"m");}
		else if(strcmp(valor,"7") == 0){strcat(cadAtomos,"p");}
		else if(strcmp(valor,"8") == 0){strcat(cadAtomos,"d");}
		else if(strcmp(valor,"9") == 0){strcat(cadAtomos,"i");}
		else if(strcmp(valor,"10") == 0){strcat(cadAtomos,"o");}
	}
	else if (clase == 1){
		strcat(cadAtomos, "a");
	}
	else if (clase == 4){
		if(strcmp(valor,"0") == 0){strcat(cadAtomos,"!");}
		else if(strcmp(valor,"1") == 0){strcat(cadAtomos,"q");}
		else if(strcmp(valor,"2") == 0){strcat(cadAtomos,"<");}
		else if(strcmp(valor,"3") == 0){strcat(cadAtomos,"l");}
		else if(strcmp(valor,"4") == 0){strcat(cadAtomos,">");}
		else if(strcmp(valor,"5") == 0){strcat(cadAtomos,"g");}
	}
	else if (clase == 6){
		strcat(cadAtomos, "s");
	}
	else if (clase == 7){
		strcat(cadAtomos, "n");
	}
	else if (clase == 8){
		strcat(cadAtomos, "r");
	}

	return 0;
}
	
int pushToTable(char *valor, int clase){
	// Funcion que inserta un componente lexico  (clase,valor)
	// a la tabla de tokens. Ademas, inserta el atomo correspondiente 
	// al componente a la cadena de atomos
	Elemento *aux = (Elemento *)calloc(1,sizeof(Elemento));
	aux->siguiente = NULL;
	aux->posicion = clase;
	aux->tipo = "";

	if(clase == 2 || clase == 5 || clase == 7 || clase == 8){
		aux->nombre = valor;
	}
	else if(clase == 3){
		aux->nombre = "=";
	}
	else if(clase == 0){
		aux->nombre = convertToStr(buscar(valor,reservadas));
	}
	else if(clase == 1){
		aux->nombre = convertToStr(buscar(valor,simbolos));
	}
	else if(clase == 4){
		aux->nombre = convertToStr(buscar(valor,relacional));
	}
	else if(clase == 6){
		aux->nombre = convertToStr(buscar(valor,cadenas));
	}

	if (tokens->primero == NULL){
		tokens->primero = aux;
		tokens->ultimo = aux;
	}
	else{
		tokens->ultimo->siguiente = aux;
		tokens->ultimo = aux;
	}

	agregarAtomo(clase, aux->nombre);
	return 0;
}

int push(char *valor, Tabla *tabla){
	// Funcion que inserta un componente lexico a su correspondiente
	// tabla. Ya sea una cadena, un identificador (tablas dinamicas)
	// O un operador relacional, palabaras reservadas o clase (tablas estaticas)

	Elemento *aux = (Elemento *)calloc(1,sizeof(Elemento));
	aux->nombre = (char *)calloc(strlen(valor),sizeof(char));
	strcpy(aux->nombre,valor);
	aux->siguiente = NULL;
	aux->tipo = "";

	if (tabla->primero == NULL){
		aux->posicion = 0;
		tabla->primero = aux;
		tabla->ultimo = aux;
	}
	else{
		if(buscar(valor, tabla) == -1){
			aux->posicion = tabla->ultimo->posicion+1;
			tabla->ultimo->siguiente = aux;
			tabla->ultimo = aux;
		}
	}
	return 0;
}

int crearTablas (Tabla *res, Tabla *rel, Tabla *clas){
	push("Palabras reservadas",clas);
	push("Identificadores",clas);
	push("Simbolos especiales",clas);
	push("Operador de asignacion",clas);
	push("Operadores relaciones",clas);
	push("Operadores aritmeticos",clas);
	push("Constante cadena",clas);
	push("Constantes numericas enteras",clas);
	push("Constantes numericas reales",clas);
	push("Bul",res);
	push("Cadena",res);
	push("Cierto",res);
	push("Entero",res);
	push("Falso",res);
	push("Haz",res);
	push("Mientras",res);
	push("Para",res);
	push("Real",res);
	push("Si",res);
	push("Sino",res);
	push(".DIF.",rel);
	push(".IGL.",rel);
	push(".MN.",rel);
	push(".MNI.",rel);
	push(".MY.",rel);
	push(".MYI.",rel);

	return 0;
}

/*************************************************************/
/******************** Analisis semántico *********************/
/*************************************************************/

int nextAtrib(){
	cadTokens = cadTokens->siguiente;
	atr = (char *)calloc(strlen(cadTokens->nombre),sizeof(char));
	strcpy(atr,cadTokens->nombre);
	return 0;
}

int TC(){
	fprintf(salida,"%s", atr);
	return 0;
}

int TR(){
	int k, pos = convertToInt(atr);
	Elemento *actual = reservadas->primero;

	for(k=0; k<pos; k++)
		actual = actual->siguiente;

	fprintf(salida," %s ",actual->nombre);
}

int AVT(int t, int p){
	int k=0;
	Elemento *actual = simbolos->primero;
	Elemento *tipo = reservadas->primero;

	for(k=0; k<p; k++)
		actual = actual->siguiente;

	for(k=0; k<t; k++)
		tipo = tipo->siguiente;

	if(strcmp(actual->tipo,"")==0){
		actual->tipo = (char *)calloc(strlen(tipo->nombre),sizeof(char));
		strcpy(actual->tipo, tipo->nombre);
	}
	else{
		printf("\nLa variable '%s' ya ha sido declarada como '%s'\n",actual->nombre,actual->tipo);
	}
	fprintf(salida," %s ",actual->nombre);
	return 0;
}

int TP(){
	int k, pos = convertToInt(atr);
	Elemento *actual = simbolos->primero;
	for(k=0; k<pos; k++)
		actual = actual->siguiente;

	if (!strcmp(actual->tipo,""))
		printf("\nVariable '%s' usada sin ser declarada",actual->nombre);
	fprintf(salida," %s ",actual->nombre);
	return 0;
}

int TS(){
	int k, pos = convertToInt(atr);
	Elemento *actual = cadenas->primero;
	for(k=0; k<pos; k++)
		actual = actual->siguiente;

	fprintf(salida," %s ",actual->nombre);
	return 0;
}

int TOR(){
	int k, pos = convertToInt(atr);
	Elemento *actual = relacional->primero;
	for(k=0; k<pos; k++)
		actual = actual->siguiente;

	switch(actual->posicion){
		case 0:
			fprintf(salida," != ");
			break;
		case 1:
			fprintf(salida," == ");
			break;
		case 2:
			fprintf(salida," < ");
			break;
		case 3:
			fprintf(salida," <= ");
			break;
		case 4:
			fprintf(salida," > ");
			break;
		case 5:
			fprintf(salida," >= ");
			break;
	}
	return 0;
}

/*************************************************************/
/******************** Analisis sintactico ********************/
/*************************************************************/

// Declaramos las siguientes funciones debido a que son llamadas
// antes de ser definidas. Con esto evitamos advertencias en la compilacion
int prodE();
int prodY();
int prodR();
int prodN();


int prodF(){
	if (!strcmp(&c,"(")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
		prodE();

		if (!strcmp(&c,")")){
			TC();
			c = cadAtomos[i++];
			nextAtrib();
		}
		else
			printf("\n%i: Se esperaba ')'\n",i-1);

		return 1;
	}
	else if (!strcmp(&c,"a") || !strcmp(&c,"n") || !strcmp(&c,"r")){
		if (!strcmp(&c,"a"))
			TP();
		else
			TC();
		c = cadAtomos[i++];
		nextAtrib();
		return 1;
	}

	else 
		printf("\n%i: Expresion aritmetica invalida\n",i-1);
}

int prodTP(){
	if (!strcmp(&c,"*") || !strcmp(&c,"/") || !strcmp(&c,"%")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
		prodF();
		prodTP();
		return 1;
	}
	else if (!strcmp(&c,"+")||!strcmp(&c,"-")||!strcmp(&c,";")||!strcmp(&c,")")||!strcmp(&c,"!")||!strcmp(&c,"q")||!strcmp(&c,"<")||!strcmp(&c,"l")||!strcmp(&c,">")||!strcmp(&c,"g")){
		return 1;
	}
	else
		printf("\n%i: Operacion aritmetico-logica invalida\n",i-1);
}

int prodT(){
	if (!strcmp(&c,"(") || !strcmp(&c,"a") || !strcmp(&c,"n") || !strcmp(&c,"r")){
		prodF();
		prodTP();
		return 1;
	}
	else
		printf("\n%i: Se esperaba un identificador o constante numerica\n",i-1);
}

int prodEP(){
	if(!strcmp(&c,"+") || !strcmp(&c,"-")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
		prodT();
		prodEP();
		return 1;
	}
	else if(!strcmp(&c,";")||!strcmp(&c,")")||!strcmp(&c,"!")||!strcmp(&c,"q")||!strcmp(&c,"<")||!strcmp(&c,"l")||!strcmp(&c,">")||!strcmp(&c,"g")){
		return 1;
	}
	else
		printf("\n%i: Operacion aritmetico-logica invalida\n",i-1);
}

int prodE(){
	if (!strcmp(&c,"(") || !strcmp(&c,"a") || !strcmp(&c,"n") || !strcmp(&c,"r")){
		prodT();
		prodEP();
		return 1;
	}
	else
		printf("\n%i: Se esperaba una expresion aritmetica\n",i-1);
}

int prodK(){
	if (!strcmp(&c,"s") || !strcmp(&c,"t") || !strcmp(&c,"f")){ 
		if(!strcmp(&c,"s"))
			TS();
		else
			TR();
		c = cadAtomos[i++];
		nextAtrib();
		return 1;
	}
	else if (!strcmp(&c,"(") || !strcmp(&c,"a") || !strcmp(&c,"n") || !strcmp(&c,"r")){
		prodE();
		return 1;
	}
	else
		printf("\n%i: Valor no valido de asignacion\n",i-1);
}

int prodA(){
	if(!strcmp(&c,"a")){
		TP();
		c = cadAtomos[i++];
		nextAtrib();

		if(!strcmp(&c,"=")){
			TC();
			c = cadAtomos[i++];
			nextAtrib();
		}
		else
			printf("\n%i: Se esperaba operador de asignacion (:=)\n",i-1);

		prodK();
		return 1;
	}
	else
		printf("\n%i: Se esperaba una asignacion\n",i-1);
}

int prodQ(){
	if (!strcmp(&c,"!")||!strcmp(&c,"q")||!strcmp(&c,"<")||!strcmp(&c,"l")||!strcmp(&c,">")||!strcmp(&c,"g")){
		// omitimos prodO porque este condicional garantiza que se lea un operador relacional
		TOR();
		c = cadAtomos[i++];
		nextAtrib();
		prodE();
		return 1;
	}
	else if (!strcmp(&c,";") || !strcmp(&c,")"))
		return 1;
	
	else
		printf("\n%i: Se espera operador relacional'\n",i-1);
}

int prodR(){
	if (!strcmp(&c,"(")||!strcmp(&c,"a")||!strcmp(&c,"n")||!strcmp(&c,"r")){
		prodE();
		prodQ();
		return 1;
	}
	else
		printf("\n%i: Se espera condicion logica\n",i-1);
}

int prodH(){

	if(!strcmp(&c,"h")){
		TR();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba 'Haz'\n",i-1);

	if(!strcmp(&c,"[")){
		TC();
		fprintf(salida,"\n");
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba '['\n",i-1);

	prodY();
	fprintf(salida,"\n");
	if(!strcmp(&c,"]")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba ']'\n",i-1);

	if(!strcmp(&c,"m")){
		TR();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba 'Mientras'\n",i-1);

	if(!strcmp(&c,"(")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba '('\n",i-1);

	prodR();

	if(!strcmp(&c,")")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba ')'\n",i-1);

	if(!strcmp(&c,";")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
		fprintf(salida,"\n");
	}
	else
		printf("\n%i: Se esperaba ';'\n",i-1);

	return 1;
}

int prodM(){

	if(!strcmp(&c,"m")){
		TR();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba 'Mientras'\n",i-1);

	if(!strcmp(&c,"(")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba '('\n",i-1);

	prodR();

	if(!strcmp(&c,")")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba ')'\n",i-1);

	if(!strcmp(&c,"[")){
		TC();
		fprintf(salida,"\n");
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba '['\n",i-1);

	prodY();
	fprintf(salida,"\n");
	if(!strcmp(&c,"]")){
		TC();
		fprintf(salida,"\n");
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba ']'\n",i-1);

	return 1;
}

int prodP(){

	if(!strcmp(&c,"p")){
		TR();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba 'Para'\n",i-1);

	if(!strcmp(&c,"(")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba '('\n",i-1);

	prodA();

	if(!strcmp(&c,";")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba ';'\n",i-1);

	prodR();

	if(!strcmp(&c,";")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba ';'\n",i-1);

	prodA();

	if(!strcmp(&c,")")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba ')'\n",i-1);

	if(!strcmp(&c,"[")){
		TC();
		fprintf(salida,"\n");
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba '['\n",i-1);

	prodY();

	fprintf(salida,"\n");
	if(!strcmp(&c,"]")){
		TC();
		fprintf(salida,"\n");
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba ']'\n",i-1);

	return 1;
}

int prodN(){
	if (!strcmp(&c,"a")||!strcmp(&c,"h")||!strcmp(&c,"m")||!strcmp(&c,"p")||!strcmp(&c,"i")||!strcmp(&c,"]"))
		return 1;

	else if (!strcmp(&c,"o")){
		TR();
		c = cadAtomos[i++];
		nextAtrib();

		if (!strcmp(&c, "[")){
			TC();
			fprintf(salida,"\n");
			c = cadAtomos[i++];
			nextAtrib();
		}
		else
			printf("\n%i Se esperaba '['\n",i-1);

		prodY();
		fprintf(salida,"\n");
		if (!strcmp(&c, "]")){
			TC();
			fprintf(salida,"\n");
			c = cadAtomos[i++];
			nextAtrib();
		}
		else
			printf("\n%i: Se esperaba ']'\n",i-1);

		return 1;
	}
	else
		printf("\n%i: Se espera sentencia de control o estructura 'Sino'\n",i-1);
}

int prodI(){

	if(!strcmp(&c,"i")){
		TR();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba 'Si'\n",i-1);

	if(!strcmp(&c,"(")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba '('\n",i-1);

	prodR();

	if(!strcmp(&c,")")){
		TC();
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba ')'\n",i-1);

	if(!strcmp(&c,"[")){
		TC();
		fprintf(salida,"\n");
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba '['\n",i-1);

	prodY();
	fprintf(salida,"\n");

	if(!strcmp(&c,"]")){
		TC();
		fprintf(salida,"\n");
		c = cadAtomos[i++];
		nextAtrib();
	}
	else
		printf("\n%i: Se esperaba ']'\n",i-1);

	prodN();

	return 1;
}

int prodS(){
	if (!strcmp(&c,"a")){
		prodA();

		if (!strcmp(&c,";")){
			TC();
			fprintf(salida,"\n");
			c = cadAtomos[i++];
			nextAtrib();
		}
		else
			printf("\n%i: Se esperaba (;)\n",i-1);
	}
	else if (!strcmp(&c,"h"))
		prodH();

	else if (!strcmp(&c,"m"))
		prodM();
	
	else if (!strcmp(&c,"p"))
		prodP();

	else if (!strcmp(&c,"i"))
		prodI();
	
	else 
		printf("\n%i: Se esperaba sentencia de control\n",i-1);

	return 1;
}

int prodX(){
	if (!strcmp(&c,"a")||!strcmp(&c,"h")||!strcmp(&c,"m")||!strcmp(&c,"p")||!strcmp(&c,"i")){
		prodY();
		return 1;
	}
	else if (!strcmp(&c,"]"))
		return 1;

	else
		printf("\n%i: Se esperaba estructura de control\n",i-1);
}

int prodY(){
	if (!strcmp(&c,"a")||!strcmp(&c,"h")||!strcmp(&c,"m")||!strcmp(&c,"p")||!strcmp(&c,"i")){
		prodS();
		prodX();
		return 1;
	}
	else
		printf("\n%i: Se esperaba sentencia de control\n", i);
}

int prodV(int t){
	if(!strcmp(&c,",")){
		TC();
		int p;
		c = cadAtomos[i++];
		nextAtrib();
		p = convertToInt(atr);

		if(!strcmp(&c,"a")){
			AVT(t,p);
			c = cadAtomos[i++];
			nextAtrib();
		}
		else{
			printf("\n%i: Se esperaba un identificador\n", i);
			return 0;
		}
		prodV(t);
		return 1;
	}
	else if(!strcmp(&c,";")){
		TC();
		fprintf(salida,"\n");
		c = cadAtomos[i++];
		nextAtrib();
		return 1;
	}
	else
		printf("\n%i: Falta (;)\n", i);
}

int prodD(){
	//ProdJ la omitimos porque ya garantizamos que se lee: b, c, e, d
	TR();
	int t;
	int p;
	t = convertToInt(atr);

	c = cadAtomos[i++];
	nextAtrib();
	p = convertToInt(atr);

	if (!strcmp(&c,"a")){
		AVT(t,p);
		c = cadAtomos[i++];
		nextAtrib();
	}
	else 
		printf("\n%i: Se esperaba un identificador\n",i-1);

	prodV(t);
	return 1;
}

int prodZ(){
	if(!strcmp(&c,"b")||!strcmp(&c,"c")||!strcmp(&c,"e")||!strcmp(&c,"d")){
		prodD();
		prodZ();
		return 1;
	}
	else if (!strcmp(&c,"a")||!strcmp(&c,"h")||!strcmp(&c,"m")||!strcmp(&c,"p")||!strcmp(&c,"i")){
		prodY();
		return 1;
	}
	else if (!strcmp(&c,"]"))
		return 1;

	else
		printf("\n%i: Se esperaba sentencia declarativa o de control\n",i-1);
}

int prodG(){
	if (!strcmp(&c,"[")){
		
		TC();
		fprintf(salida,"\n");
		c = cadAtomos[i++];
		nextAtrib();
		prodZ();

		if (!strcmp(&c,"]")){
			fprintf(salida,"\n");
			TC();
			c = cadAtomos[i++];
		}
		else
			printf("\n%i: Falta ']' para cerrar el programa\n",i-1);
		return 1;
	}
	else
		printf("\n%i: Es necesario iniciar el programa con '['\n",i-1);
}

int anSintactico(){
	
	printf("\n\nIniciando analisis sintactico-semantico");

	cadTokens = (Elemento *)calloc(1,sizeof(Elemento));
	cadTokens = tokens->primero;

	c = cadAtomos[i++];

	atr = (char *)calloc(strlen(cadTokens->nombre),sizeof(char));
	strcpy(atr,cadTokens->nombre);

	prodG();
	if (!strcmp(&c,"$"))
		printf("\nAnalisis sintactico-semantico terminado\n");
	else
		printf("\nAnalisis sintactico-semantico terminado con errores\n");
	
	return 1;
}


%}

	// Definimos las expresiones regulares para nuestro analizador
	
reservada	(Bul|Cadena|Cierto|Entero|Falso|Haz|Mientras|Para|Real|Si|Sino)
ident 		[a-z]([a-z]|[A-Z]){0,7}
asig		:=
relacion 	(.DIF.|.IGL.|.MN.|.MNI.|.MY.|.MYI.)
arit		[+\-*%/]
cadena 		["][^\n"]*["]
comentario 	\$\$.*
especiales	(\{|\}|,|;|\[|\]|\(|\))
entero 		[0-9]+
real 		([0-9]+\.[0-9]*|[0-9]*\.[0-9]+|[0-9]+)((e|E)[+|\-]?[0-9]+)?
error		[^\n \t]

%%

{reservada}		{	
					char *cadena = (char *)calloc(1,sizeof(char));
					strcpy(cadena,yytext);
					pushToTable(cadena, 0);
				}
{ident} 		{	
					char *cadena = (char *)calloc(1,sizeof(char));
					strcpy(cadena,yytext);
					push(cadena, simbolos);
					pushToTable(cadena,1);
				}
{especiales}	{	
					char *cadena = (char *)calloc(1,sizeof(char));
					strcpy(cadena,yytext);
					pushToTable(cadena,2);
				}
{asig}			{	
					char *cadena = (char *)calloc(1,sizeof(char));
					strcpy(cadena,yytext);
					pushToTable(cadena,3);
				}
{relacion}		{	
					char *cadena = (char *)calloc(1,sizeof(char));
					strcpy(cadena,yytext);
					pushToTable(cadena,4);
				}
{arit}			{	
					char *cadena = (char *)calloc(1,sizeof(char));
					strcpy(cadena,yytext);
					pushToTable(cadena,5);
				}
{cadena}		{	
					char *cadena = (char *)calloc(1,sizeof(char));
					strcpy(cadena,yytext);
					push(cadena,cadenas);
					pushToTable(cadena,6);
				}
{entero}		{	
					char *cadena = (char *)calloc(1,sizeof(char));
					strcpy(cadena,yytext);
					pushToTable(cadena,7);
				}
{real}			{	
					char *cadena = (char *)calloc(1,sizeof(char));
					strcpy(cadena,yytext);
					pushToTable(cadena,8);
				}
{comentario}	printf("\n%s\n", yytext);
{error}			printf("\nError: %s\n",yytext);


%%
int main(int argc, char *argv[])
{	
	//Abrimos los archivos de palabras reservadas y op. relacionales para
	//generar las estructuras que los contengan y poder trabajar con ellas
	
	relacional = (Tabla *)calloc(1,sizeof(Tabla));
	reservadas = (Tabla *)calloc(1,sizeof(Tabla));
	clases = (Tabla *)calloc(1,sizeof(Tabla));
	crearTablas(reservadas,relacional, clases);

	tokens = (Tabla *)calloc(1,sizeof(Tabla));
	simbolos = (Tabla *)calloc(1,sizeof(Tabla));
	cadenas = (Tabla *)calloc(1,sizeof(Tabla));

	// Abrimos el archivo a analizar que es pasado como argumento a la funcion main
	// Abrimos el archivo de salida donde se guardara el texto traducido
	yyin = fopen(argv[1],"r");
	elementos = fopen("tokens.txt", "w+");
	tblSimbolos = fopen("simbolos.txt", "w+");
	tblCteCad = fopen("cadenas.txt", "w+");
	salida = fopen("salida.txt", "w+");
	yylex();

	printf("\nTabla de simbolos\n");
	mostrarTabla(simbolos, tblSimbolos);
	printf("\nTabla de constantes cadenas\n");
	mostrarTabla(cadenas, tblCteCad);
	printf("\nTabla de tokens\n");
	mostrarTabla(tokens, elementos);
	
	// Agregamos el caracter de fin de cadena "$"
	strcat(cadAtomos,"$");

	// Ajustamos el formato de impresion para que sea sencillo apreciar el
	// atomo y su posicion correspondiente
	int j=0;
	printf("\nCadena de atomos\n");
	for (j=0;j<strlen(cadAtomos);j++){
		printf("%c ",*(cadAtomos+j));
		if (j>8)
			printf(" ");
	}
	printf("\n");
	for (j=0; j<strlen(cadAtomos); j++)
		printf("%i ",j+1);

	anSintactico();

	printf("\nTabla de simbolos\n");
	fseek(tblSimbolos,0,SEEK_SET);
	mostrarTabla(simbolos, tblSimbolos);
	
	fclose(elementos);
	fclose(tblSimbolos);
	fclose(tblCteCad);
	fclose(salida);
  	return 0;
}
