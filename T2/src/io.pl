/**
 * read_files(+StudentsFile, +PreviousUCsInfoFile, -Students, -PreviousUCsInfo)
 * 
 * StudentsFile - students file name relative to cwd
 * PreviousUCsInfoFile - previous UCs info file name relative to cwd
 * Students - students information (ID and GPA)
 * PreviousUCsInfo - information regarding previous groups in other UCs
 */ 
read_files(StudentsFile, PreviousUCsInfoFile, Students, PreviousUCsInfo):-
    open(StudentsFile, read, Str),
    read_file(Str, Students),
    close(Str),
    open(PreviousUCsInfoFile, read, Str2),
    read_file(Str2, PreviousUCsInfo),
    close(Str2).

/**
 * read_file(+Stream, -List)
 * 
 * Stream - file stream
 * List - list of pairs (students/previousUCsInfo)
 */ 
read_file(Stream,[]) :-
    at_end_of_stream(Stream).

read_file(Stream,[[X, Y]|L]) :-
    \+ at_end_of_stream(Stream),
    read(Stream,X),
    read(Stream,Y),
    read_file(Stream,L).

/**
 * write_files(+Proj1Groups, +Proj2Groups)
 * 
 * Proj1Groups - list of the groups for the first project
 * Proj2Groups - list of the groups for the second project
 */ 
write_files(Proj1Groups, Proj2Groups):-
    open('proj1groups.txt', write, Str),
    write_groups(Str, Proj1Groups),
    close(Str),
    open('proj2groups.txt', write, Str2),
    write_groups(Str2, Proj2Groups),
    close(Str2).

/**
 * write_group(+Stream, +Group)
 * 
 * Stream - file stream
 * Group - list of students that form a group
 */ 
write_group(Stream, []):-write(Stream, '\n').
write_group(Stream, [H | T]):-
    write(Stream, H),
    write(Stream, '  '),
    write_group(Stream, T).

/**
 * write_groups(+Stream, +Groups)
 * 
 * Stream - file stream
 * Groups - list of groups
 */ 
write_groups(_, []).
write_groups(Stream, [H | T]):-
    write_group(Stream, H),
    write_groups(Stream, T).