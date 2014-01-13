%% -*- prolog -*-

%% ========================================================================
%% Copyright (C) 2013  Simon Petitjean

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

:- module(xmg_brick_havm_havm, [h_avm/3, const_h_avm/2]).

:- use_module(library(atts)).
:- use_module(library(rbtrees)).

:- attribute avmfeats/3.

verify_attributes(Var, Other, Goals) :-
	get_atts(Var, avmfeats(Type1,T1,U)), !,
	var(Other),
	( get_atts(Other, avmfeats(Type2,T2,U)) ->
	    hierarchy(Type1,Type2,Type3),
	    rb_visit(T1,Pairs),
	    unify_entries(T2,Pairs,T3),
	    put_atts(Other, avmfeats(Type3,T3,U)),
	    Goals=[]
	; \+ attvar(Other), Goals=[], put_atts(Other, avmfeats(Type1,T1,U))).

verify_attributes(_, _, []).

unify_entries(T,[],T).
unify_entries(T1,[K-V0|L],T3) :-
	(rb_lookup(K,V1,T1) -> V0=V1, T1=T2; rb_insert(T1,K,V0,T2)),
	unify_entries(T2,L,T3).

h_avm(X, Type, L) :- var(L), !,
	get_atts(X, avmfeats(Type,T,_)),
	rb_visit(T,L).

h_avm(X, Type, L) :-
	list_to_rbtree(L,T),
	put_atts(Y, avmfeats(Type,T,_)),
	X = Y.

const_h_avm(A,C) :-
	get_atts(A, avmfeats(_, _, C)).
	
attribute_goal(Var, h_avm(Var,Type,L)) :-
	get_atts(Var, avmfeats(Type,T,_)),
	rb_visit(T,L).

hierarchy(V0,V1,V0):-
	V0=V1,!.

hierarchy(V0,V1,V1):-
	V0=const(VV0,T),
	V1=const(VV1,T),

	%%xmg_typer:hierarchy(T,VV0,VV1),!.
	xmg_brick_hierarchy_typer:subtype(T,VV0,VV1),!.

hierarchy(V0,V1,V0):-
	V0=const(VV0,T),
	V1=const(VV1,T),

	%%xmg_typer:hierarchy(T,VV1,VV0),!.
	xmg_brick_hierarchy_typer:subtype(T,VV1,VV0),!.

hierarchy(V0,V1,V0):-
	xmg:send(info,'Hierarchy type unification: do not know what to do with '),
	xmg:send(info,V0),
	xmg:send(info,V1),
	false.
	