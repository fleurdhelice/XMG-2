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

:-xmg:edcg.
:-module(xmg_brick_fields_unfolder).

xmg:unfold(fields:field(token(C,id(Field))),field(id(Field,C))):-- !.
xmg:unfold(fields:fieldprec(token(C1,id(F1)),token(C2,id(F2))),fieldprec(id(F1,C1),id(F2,C2))):-- !.