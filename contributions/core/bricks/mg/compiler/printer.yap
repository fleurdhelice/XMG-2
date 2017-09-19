%% ========================================================================
%% Copyright (C) 2014  Simon Petitjean

%%  This program is free software: you can redistribute it and/or modify
%%  it under the terms of the GNU General Public License as published by
%%  the Free Software Foundation, either version 3 of the License, or
%%  (at your option) any later version.

%%  This program is distributed in the hope that it will be useful,
%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%  GNU General Public License for more details.

%%  You should have received a copy of the GNU General Public License
%%  along with this program.  If not, see <http://www.gnu.org/licenses/>.
%% ========================================================================

%% -*- prolog -*-

:- module(xmg_brick_mg_printer).

xmg:printXML(H, I) :-
    printElem(H, I),!.

printIndent(0):-!.
printIndent(I) :-
	print('  '), J is I-1, printIndent(J),!.

printElem(H, I) :-
	H=elem(X),
	printIndent(I),
	print('<'),
	print(X),
	print('/>\n'),!.


printElem(H, I) :-
	H=elem(X, features(Y)),
	printIndent(I),
	print('<'),
	print(X),
	print(' '),
	printFeatures(Y),
	print('/>\n'),!.

printElem(H, I) :-
	H=elem(X, children(Y)),
	printIndent(I),
	print('<'),
	print(X),
	print('>\n'),
	J is I+1,
	printChildren(Y, J),
	printIndent(I),
	print('</'),
	print(X),
	print('>\n'),!
	.

printElem(H, I) :-
	H=elem(X, data(Y)),
	printIndent(I),
	print('<'),
	print(X),
	print('>'),
	printData(Y),
	print('</'),
	print(X),
	print('>\n'),!
	.

printElem(H, I) :-
	H=elem(X, features(Y), children(Z)),
	printIndent(I),
	print('<'),
	print(X),
	print(' '),
	printFeatures(Y),
	print('>\n'),
	J is I+1,
	printChildren(Z, J),
	printIndent(I),
	print('</'),
	print(X),
	print('>\n'),!
	.

printElem(H,I) :-
        xmg:send(info,'\nError: Could not print elem: '),
	xmg:send(info,H),
	false,!.

printFeatures([]):-!.
printFeatures([H1-H2]):-
	print(H1), print('="'), print(H2), print('"'),!.
printFeatures([H1-H2|T]) :-
	print(H1), print('="'), print(H2), print('" '), printFeatures(T),!.

printData(A) :-
	print(A),!.



printChildren([],_):-!.
printChildren([H|T], I) :-
	printElem(H, I), printChildren(T,I),!.
