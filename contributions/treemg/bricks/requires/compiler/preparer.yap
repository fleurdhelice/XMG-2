%% -*- prolog -*-

%% ========================================================================
%% Copyright (C) 2017  Denys Duchier

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

%% use requires with (p1=v1, p2=v2) dims (d)
%% if there is a node with p1=v1, then there must a node with p2=v2

:- module(xmg_brick_requires_preparer, []).

get_instances(I):-
    xmg:requires(I).


prepare_instance(Nodes,R1,H1,Nodes):-
    prepare(Nodes,R1,H1),
    prepare_reduce(H1, false, false, B1, B2),
    %% fail here if the "requires" is not satisfied
    (B2=true ; B1=false),!.

%% don't use unification: test only for identity
memberq(X, [Y|T]) :- X==Y -> true ; memberq(X, T).
memberq_props(X, PL) :- memberq(X, PL), !.
memberq_feats(X, FL) :-
    ( memberq(X, FL)
      ; lists:member(top-L, FL),
	xmg_brick_avm_avm:avm(L, FL2),
	memberq(X, FL2)
      ; lists:member(bot-L, FL),
	xmg_brick_avm_avm:avm(L, FL2),
	memberq(X, FL2) ), !.

prepare([],_,[]) :- !.
prepare([Node|Nodes], (feat(F1,V1,_),feat(F2,V2,_)), [(B1,B2)|T1]) :-
    Node=node(Prop,Feat,_),!,
    xmg_brick_avm_avm:avm(Prop, PL),
    xmg_brick_avm_avm:avm(Feat, FL),
    ( ( memberq_props(F1-V1, PL) ; memberq_feats(F1-V1, FL) )
      -> B1=true ; B1=false ),
    ( ( memberq_props(F2-V2, PL) ; memberq_feats(F2-V2, FL) )
     -> B2=true ; B2=false ),
    prepare(Nodes,(feat(F1,V1,_),feat(F2,V2,_)),T1),
    !.
prepare([_|Nodes], F1F2, T1) :-
    prepare(Nodes, F1F2, T1).

prepare_reduce([], B1, B2, B1, B2) :- !.
prepare_reduce([(A1,A2)|AT], B1, B2, OB1, OB2) :-
    ((A1=true;B1=true) -> MB1=true ; MB1=false),
    ((A2=true;B2=true) -> MB2=true ; MB2=false),
    prepare_reduce(AT, MB1, MB2, OB1, OB2), !.
