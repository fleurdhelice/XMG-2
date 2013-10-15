%% -*- prolog -*-

%% ========================================================================
%% Copyright (C) 2012  Simon Petitjean

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

:-module(xmg_brick_mg_compiler,[send/2]).

:-use_module('xmg/brick/mg/edcg.yap').
:-use_module('xmg/brick/mg/compiler/modules.yap').
%%:-use_module('syn_frame_conf').
%%:-use_module('syn_frame_std_conf').

%%:-use_module(conf).

:-dynamic(principle/1).
:-dynamic(unicity/1).
:-dynamic(mutex/1).
:-dynamic(mutex_add/2).
:-dynamic(current/1).
:-dynamic(debug_mode/0).

%encoding(iso_latin_1).
encoding(utf8).
%debug_mode(false).

debug_mode_on:-
	asserta(debug_mode).

send(info,Mess):-
	print(user_error,Mess),!.
send(debug,Mess):-
	debug_mode,!,
	print(user_error,Mess),!.
send(debug,Mess):-
	not(debug_mode),!.
send(out,Mess):-
	print(user_output,Mess),!.
send_nl(info):-
	send(info,'\n'),!.
send_nl(info,1):-
	send(info,'\n'),!.
send_nl(info,N):-
	send(info,'\n'),!,
	M is N -1,!,
	send_nl(info,M),!.

compile_file(File,Eval):-
	xmg_compiler_conf:init,
	findall(Module,xmg_modules_def:module_def(_,Module),Modules),
	xmg_brick_mg_modules:load_modules(Modules),
	xmg_brick_mg_parser:parse_file(File,[Parse]),!,
	send(info,' parsed '),
	%%send(info,Parse),
	send_nl(info),
	xmg_unfolder:unfold(Parse,Unfolded),!,
	send(info,' unfolded '),
	%%send(info,Unfolded),
	send_nl(info),	
	xmg_principles:principles(Unfolded),!,
	xmg_exporter:export_metagrammar(Unfolded),!,
	xmg_typer:type_metagrammar(Unfolded),!,
	xmg_generator:generate(Unfolded),!,
	send_nl(info),	
	send(info,' generated '),
	send_nl(info),	
	
	asserta(current(0)),

	send(out,'<grammar>\n'),
	eval.	

eval:-
	xmg_generator:compute(Class,Computed),
	xmg_dimensions:dims(Dims),

	%% Computed=dims([morph-Morph,syn-Syn,pg-PG,sem-Sem]),
	Computed=dims(Dims),

	get_dim(trace,Dims,Trace),

	findall(Mutex,mutex(Mutex),Mutexes),
	%%send(info,Trace),
	check_mutexes(Trace,Mutexes),

	send_nl(info),send_nl(info),send(info,'                Computed '),send(info,Class),send_nl(info),send_nl(info),

	%%send(debug,Dims),

	eval_dims(Dims,EDims,Class),
	current(Previous),
	Current is Previous + 1,
	retract(current(Previous)),
	asserta(current(Current)),
	xmg_convert:toXML(entry(Trace,EDims),XML,Previous),
	xmg_printer:printXML([XML],1),
	send(info,Previous),send_nl(info),send_nl(info),


	send(info,'________________________________________________'),send_nl(info),send_nl(info),
	fail.

eval:- send(out,'</grammar>\n'),!.

eval_dims([],[],_).
eval_dims([trace-Acc|T],T1,Class):-
	eval_dims(T,T1,Class).
eval_dims([skolem-Acc|T],T1,Class):-
	eval_dims(T,T1,Class).
eval_dims([Dim-Acc|T],[XML|T1],Class):-
	eval(Dim,Acc,XML,Class),
	eval_dims(T,T1,Class).

eval(morph,Morph,XML,_):-
	%%send(info,Morph),
	xmg_solver_morph:eval_morph(Morph,Value),
	%%send_nl(info,2),
	%%send(info,' Value : '),
	%%send(info,Value),
	xmg_convert_morph:toXML(Value,XML,0).


eval(syn,Syn,XML,Class):-
	xmg_compiler_syn:eval(Syn,XML,Class).
eval(syn1,Syn,XML,Class):-
	xmg_compiler_syn:eval(Syn,XML,Class).
eval(syn2,Syn,XML,Class):-
	xmg_compiler_syn:eval(Syn,XML,Class).


eval(pg,PG,elem(pg, features([id-none])),_):-
	xmg_output_pg:output(PG).

eval(sem,Sem,XML,_):-
	send(info,Sem),
	xmg_convert_sem:toXML(Sem,XML),
	send_nl(info).

eval(frame,Frame,XML,_):-
	Class=class_test,
	xmg_preparer_frame:prepare(Frame,PFrame),
	%%send(debug,PFrame),
	xmg_solver_frame:solve(PFrame,solution(Tree)),
	xmg_convert_frame:toXML(tree(Tree,Class),XML,0).
	%%send(debug,Tree).
eval(frame,[], elem(tree, features([id-none])),_).


eval(iface,I, elem(interface, children([elem(fs, children(XML))])),_):-
	xmg_avm:avm(I,IAVM),
	%%send(info,IAVM),
	xmg_convert_avm:xmlFeats(IAVM,XML,1,_).
eval(iface,[], elem(interface, features([])),_).
		
get_dim(Dim,[Dim-CDim|_],CDim):-!.
get_dim(Dim,[_|T],CDim):-
	get_dim(Dim,T,CDim),!.



check_mutexes(_,[]):- !.
check_mutexes(Trace,[H|T]):-
	check_mutex(Trace,H),!,
	check_mutexes(Trace,T),!.

check_mutex([],_):- !.
check_mutex([Class|T],Mutex):-
	mutex_add(Mutex,Class),!,
	fail_if_mutex(T,Class,Mutex),!.
check_mutex([Class|T],Mutex):-
	not(mutex_add(Mutex,Class)),!,
	check_mutex(T,Mutex),!.

fail_if_mutex([],_,_):- !.
fail_if_mutex([Class|T],Class,Mutex):-
	!,
	fail_if_mutex(T,Class,Mutex),!.
fail_if_mutex([Class|T],First,Mutex):-
	mutex_add(Mutex,Class),!,
	send(info,' mutex fail '),
	fail.
fail_if_mutex([Class|T],First,Mutex):-
	%not(mutex_add(Mutex,Class)),!,
	!,fail_if_mutex(T,First,Mutex),!.