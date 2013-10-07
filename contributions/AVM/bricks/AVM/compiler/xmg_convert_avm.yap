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

:- module(xmg_convert_avm).

%%:- edcg:thread(name,edcg:counter).

:- edcg:using(xmg_convert:name).

:- edcg:weave([name],[xmlFeats/2, new_name/2]).

new_name(Prefixe, Name) :--
	name::incr,
	name::get(N),
	atomic_concat([Prefixe,N],Name).

xmlFeats([],[]):-- !.

xmlFeats([A-V|T],[elem(f,features([name-A]),children([elem(sym,features([varname-V]))]))|T1]):--
	atom(V),
	xmlFeats(T,T1),!.

xmlFeats([A-const(V,Type)|T],[elem(f,features([name-A]),children([elem(sym,features([value-Val]))]))|T1]):--
	(
	    atom(V);
	    integer(V)
	
	),!, Val=V,
	xmlFeats(T,T1),!.

xmlFeats([A-sconst(V,Type)|T],[elem(f,features([name-A]),children([elem(sym,features([value-Val]))]))|T1]):--
	(
	    atom(V);
	    integer(V)
	
	),!, Val=V,
	xmlFeats(T,T1),!.


xmlFeats([A-AVM|T],[H1|T1]):--
	xmg_avm:avm(AVM,LAVM),
	xmg_avm:const_avm(AVM,CAVM),
	((
	    var(CAVM),!,
	    new_name('@AVM',CAVM),
	    xmlFeats(LAVM,LAVM1),
	    H1=elem(f, features([name-A]),children([elem(fs,features([coref-CAVM]),children(LAVM1))]))
	)
    ;
	(
	    !,H1=elem(f, features([name-A]),children([elem(fs,features([coref-CAVM]))]))
	)),
	xmlFeats(T,T1),!.

xmlFeats([A-V|T],[elem(f,features([name-A]),children([elem(sym,features([varname-V]))]))|T1]):--
	var(V),
	new_name('@V',V),
	xmlFeats(T,T1),!.

xmlFeats([A-const(V,Type)|T],[elem(f,features([name-A]),children([elem(sym,features([value-V]))]))|T1]):--
	var(V),
	new_name('@V',V),
	xmlFeats(T,T1),!.

xmlFeats([A-sconst(V,Type)|T],[elem(f,features([name-A]),children([elem(sym,features([value-V]))]))|T1]):--
	var(V),
	new_name('!C',V),
	xmlFeats(T,T1),!.

xmlFeats([A-const(AD,_)|T],[H1|T1]):--
	%%write(AD),
	xmg_adisj:adisj(AD,LAD),
	xmg_adisj:const_adisj(AD,CLAD),!,
	((
	    var(CLAD),!,
	    new_name('@AD',CLAD),
	    xmlAdisj(LAD,LAD1),
	    H1=elem(f, features([name-A]),children([elem(vAlt, features([coref-CLAD]),children(LAD1))]))
	)
    ;
	(
	    !,H1=elem(f, features([name-A]),children([elem(vAlt, features([coref-CLAD]))]))
	)),
	    xmlFeats(T,T1),!.

xmlFeats(Feats,_):--
	xmg_compiler:send(info,Feats),false.



xmlAdisj([],[]) :-- !.

xmlAdisj([H|T],[elem(sym,features([value-Val]))|T1]):--
	H=string(String),
	not(var(String)),!,
	atom_codes(Val,String),
	xmlAdisj(T,T1),!.
xmlAdisj([H|T],[elem(sym,features([value-Int]))|T1]):--
	H=int(Int),
	not(var(Int)),!,
	xmlAdisj(T,T1),!.
xmlAdisj([H|T],[elem(sym,features([value-Bool]))|T1]):--
	H=bool(Bool),
	not(var(Bool)),!,
	xmlAdisj(T,T1),!.
xmlAdisj([H|T],[elem(sym,features([value-H]))|T1]):--
	xmlAdisj(T,T1),!.
