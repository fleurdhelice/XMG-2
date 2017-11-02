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

:-module(xmg_brick_syn_compiler).

xmg:eval(syn,[tree],Syn,XML,Class):-
    xmg_brick_tree_compiler:eval(Syn,_,XML,Class).
xmg:eval(syn,[rrg],Syn,XML,Class):-
	xmg_brick_rrg_compiler:eval(Syn,_,XML,Class).
xmg:eval(syn,[],Syn,XML,Class):-
	xmg_brick_syn_compiler:eval(Syn,_,XML,Class).

%% %% TAG compiler
%% eval(Syn,[tree],XML,Class):-
%% 	%%xmg_brick_mg_compiler:send(info,Syn),
%% 	xmg_brick_mg_compiler:send(debug,' preparing '),

%% 	xmg_brick_tree_preparer:prepare(syn(Syn,[Class]),Prepared),
%% 	xmg_brick_mg_compiler:send(debug,' prepared '),
%% 	xmg_brick_tree_solver:solve(Prepared,solution(IsRoot,Eq, Children, Left, NodeList1)),
%% 	xmg_brick_tree_extractor:extract(IsRoot,Eq, Children, Left, NodeList1,Tree),
%% 	%%xmg:send(info,Tree),
%% 	xmg:send(debug,' extracted '),
%% 	%%flush_output,
%% 	xmg_brick_mg_compiler:current(Previous),
%% 	%% Current is Previous + 1,
%% 	%% retract(current(Previous)),
%% 	%% asserta(current(Current)),
%% 	xmg:do_xml_convert(tree:tree(Tree,Class,Previous),XML).
%% eval([],_,elem(tree, features([id-none])),_).


%% IG compiler
eval(Syn,[],XML,Class):-
	xmg_brick_mg_compiler:current(Previous),
	xmg:do_xml_convert(syn:desc(Syn,Class,Previous),XML).
eval([], elem(tree, features([id-none])),_).

