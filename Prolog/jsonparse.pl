%%%% -*- Mode: Prolog -*-

%% Sandu Stoicov 816594

% Base Case
jsonparse({}, jsonobj([])) :- !.

jsonparse([], jsonarray([])) :- !.

% Case : Atom
jsonparse(JSONAtom, ObjectResult) :-
    atom(JSONAtom),
    catch(term_to_atom(JSONTerm, JSONAtom), _, fail),
    !,
    jsonparse(JSONTerm, ObjectResult).

% Case : Characters / Strings
jsonparse(String, ObjectResult) :-
    string(String),
    !,
    catch(term_string(JSONTerm, String), _, fail),
    jsonparse(JSONTerm, ObjectResult).

jsonparse(Characters, ObjectResult) :-
    is_list(Characters),
    catch(atom_codes(JSONAtom, Characters), _, fail),
    jsonparse(JSONAtom, ObjectResult),
    !.

jsonparse(Characters, ObjectResult) :-
    is_list(Characters),
    catch(atom_chars(JSONAtom, Characters), _, fail),
    jsonparse(JSONAtom, ObjectResult),
    !.

% JSONTerm
jsonparse(JSONTerm, ObjectResult) :-
    compound(JSONTerm),
    !,
    newJsonParse(JSONTerm, ObjectResult).

% Reverse
jsonparse(Result, JSON) :-
    var(Result),
    nonvar(JSON),
    !,
    reverseParse(Result, JSON).

% Support Functions
newJsonParse({}, jsonobj([])) :- !.

newJsonParse({Members}, jsonobj(Result)) :-
    !,
    Members =.. List,
    parseObj(List, Result).

newJsonParse(List, jsonarray(Result)) :-
    is_list(List),
    !,
    newJsonParseArray(List, Result).

parseObj([':', String, Val], [(String , RValue)]) :-
    string(String),
    confirmValue(Val, RValue),
    !.

parseObj([',', (Str : Val), Rest], [(Str , RVal) | Tail]) :-
    !,
    string(Str),
    confirmValue(Val, RVal),
    Rest =.. LRest,
    parseObj(LRest, Tail).

newJsonParseArray([], []) :- !.

newJsonParseArray([Val | Tail], [RVal | RTail]) :-
    confirmValue(Val, RVal),
    !,
    newJsonParseArray(Tail, RTail).

% Parse reverse
reverseParse({}, jsonobj([])) :- !.

reverseParse({Members}, jsonobj(List)) :-
    !,
    reverseObjParse(Members, List).

reverseParse(RList, jsonarray(List)) :-
    !,
    reverseArrayParse(RList, List).

reverseObjParse(Str : RVal, [',', Str, Val]) :-
    string(Str),
    confirmValue(RVal, Val),
    !.

reverseObjParse(Result, [Head]) :-
    !,
    functor(Head, ',', 2),
    Head =.. List,
    reverseObjParse(Result, List).

reverseObjParse(Result, [Head | Tail]) :-
    !,
    Head =.. List,
    reverseObjParse(TempResult1, List),
    reverseObjParse(TempResult2, Tail),
    Result =.. [',', TempResult1, TempResult2].

reverseArrayParse([], []) :- !.

reverseArrayParse(Result, [Head | Tail]) :-
    !,
    confirmValue(Pair, Head),
    reverseArrayParse(ResultTail, Tail),
    append([Pair], ResultTail, Result).

% CheckValue
confirmValue(Str, Str) :-
    string(Str),
    !.

confirmValue(Num, Num) :-
    number(Num),
    !.

confirmValue('true', 'true') :- !.

confirmValue('false', 'false') :- !.

confirmValue('null', 'null') :- !.

confirmValue(JSON, Result) :-
    nonvar(JSON),
    !,
    newJsonParse(JSON, Result).

confirmValue(Result, JSON) :-
    !,
    nonvar(JSON),
    reverseParse(Result, JSON).

% JsonAccess
jsonaccess(jsonarray(_), [], _) :- !, fail.

jsonaccess(JSON, Fields, Result) :-
    nonvar(JSON),
    !,
    newJsonAccess(JSON, Fields, Result).

newJsonAccess(jsonobj(List), String, Result) :-
    string(String),
    !,
    member((String , Result), List),
    !.

newJsonAccess(jsonobj(List), Var, Result) :-
    var(Var),
    !,
    member((Var , Result), List).

newJsonAccess(jsonarray(List), Index, Result) :-
    integer(Index),
    !,
    nth0(Index, List, Result).

newJsonAccess(jsonarray(List), Var, Result) :-
    var(Var),
    !,
    nth0(Var, List, Result).

newJsonAccess(Obj, [], Obj) :- !.

newJsonAccess(Obj, [Field | OtherFields], Result) :-
    !,
    newJsonAccess(Obj, Field, TRes),
    newJsonAccess(TRes, OtherFields, Result).

% INPUT
% JSONREAD
jsonread(FileName, JSON) :-
    nonvar(FileName),
    catch(open(FileName, read, In), _, fail),
    catch(
        (
        read_string(In, _, String),
        jsonparse(String, JSON)
    ),
        _,
        (close(In), fail)
    ),
    !,
    close(In).

jsonread(FileName, JSON) :-
    nonvar(FileName),
    catch(open(FileName, read, In), _, fail),
    catch(
        (
        get_char(In, Char),
        jsonread(In, Char, Characters),
        jsonparse(Characters, JSON)
    ),
        _,
        (close(In), fail)
    ),
    !,
    close(In).

jsonread(_, end_of_file, []) :- !.

jsonread(Stream, '\\', Characters) :-
    get_char(Stream, '/'),
    !,
    Characters = ['/' | Rest],
    get_char(Stream, Next),
    jsonread(Stream, Next, Rest).

jsonread(Stream, Char, Characters) :-
    !,
    Characters = [Char | Rest],
    get_char(Stream, Next),
    jsonread(Stream, Next, Rest).

% JsonDump
jsondump(JSON, File) :-
    nonvar(JSON),
    atom(File),
    open(File, write, Out),
    JSON =.. ListJSON,
    newJsonDump(ListJSON, Out, 0),
    close(Out).

newJsonDump([jsonobj, {}], Out, _) :-
    !,
    write(Out, "{}").

newJsonDump([jsonarray, []], Out, _) :-
    !,
    write(Out, "[]").

newJsonDump([jsonobj, List], Out, Index) :-
    !,
    writeln(Out, "{"),
    Index1 is Index + 2,
    newJsonDumpObj(List, Out, Index1),
    tab(Out, Index),
    write(Out, "}").

newJsonDump([jsonarray, List], Out, Index) :-
    !,
    writeln(Out, "["),
    Index1 is Index + 2,
    newJsonDumpArray(List, Out, Index1),
    tab(Out, Index),
    write(Out, "]").

newJsonDumpObj([',', Str, Value], Out, Index) :-
    confirmValue(Value, _),
    !,
    tab(Out, Index),
    format(Out, '"~w" : ', [Str]),
    printValue(Out, Value).

newJsonDumpObj([',', Str, Value], Out, Index) :-
    !,
    tab(Out, Index),
    format(Out, '"~w" : ', [Str]),
    Value =.. ListValue,
    newJsonDump(ListValue, Out, Index).

newJsonDumpObj([Head], Out, Index) :-
    !,
    Head =.. ListHead,
    newJsonDumpObj(ListHead, Out, Index),
    nl(Out).

newJsonDumpObj([Head | Tail], Out, Index) :-
    !,
    Head =.. ListHead,
    newJsonDumpObj(ListHead, Out, Index),
    writeln(Out, ","),
    newJsonDumpObj(Tail, Out, Index).

newJsonDumpArray([Head], Out, Index) :-
    !,
    tab(Out, Index),
    newJsonDumpArray(Head, Out, Index),
    nl(Out).

newJsonDumpArray([Head | Tail], Out, Index) :-
    !,
    tab(Out, Index),
    newJsonDumpArray(Head, Out, Index),
    writeln(Out, ","),
    newJsonDumpArray(Tail, Out, Index).

newJsonDumpArray(Value, Out, _) :-
    confirmValue(Value, _),
    !,
    format(Out, '"~w"', [Value]).

newJsonDumpArray(Value, Out, Index) :-
    !,
    Value =.. List,
    newJsonDump(List, Out, Index).

% PrintValue
printValue(Out, Str) :-
    string(Str),
    !,
    write(Out, "\""),
    write(Out, Str),
    write(Out, "\"").

printValue(Out, Value) :-
    !,
    write(Out, Value).

%%%% THE END - jsonparse.pl -