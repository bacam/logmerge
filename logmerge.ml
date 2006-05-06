type ('a,'b) maybe = Found of 'a | NotFound of 'b

(* Return channels for all the files up to the one we've got the offset for. *)
let rec tryoffset variations filename inode offset =
  match variations with
    [] -> (prerr_endline ("No file for " ^ filename ^
                          " found which matches the last offset");
           [(NotFound offset, filename, inode)])
  | v::t ->
      try
        let file = open_in (filename ^ v) in
        let stat = Unix.fstat (Unix.descr_of_in_channel file) in
        let res = (Found file, filename, stat.Unix.st_ino) in
        if stat.Unix.st_ino = inode then (LargeFile.seek_in file offset; [res])
        else res::(tryoffset t filename inode offset)
      with Sys_error s ->
        (prerr_endline ("Unable to open file " ^ filename ^ v ^ ": " ^ s);
         tryoffset t filename inode offset)
;;

let openfiles offsetsfile =
  let rec readmore () =
    try
      let line = input_line offsetsfile in
      let this = Scanf.sscanf line "%S %d %Ld" (tryoffset [""; ".0"; ".1"]) in
      this::(readmore ())
    with End_of_file -> []
       | Scanf.Scan_failure s -> failwith ("offsets file corrupt: " ^ s)
  in readmore ()
;;

(* Pulls out times as an integer which respects order, more or less *)
let extracttime s =
  let themonth _ = 0 in (* FIX ME; need to cope with wrap arounds ? *)
  let convert month day hour minute second =
    second + 60*(minute + 60*(hour + 24*(day + 31*(themonth month)))) in
  Scanf.sscanf s "%s %d %d:%d:%d " convert  (* FIX ME - handle failure *)
;;

let rec insert ((lt,_,_) as l) lines =
  match lines with
    [] -> [l]
  | ((ht,_,_) as h)::t -> if lt < ht then l::lines
                                     else h::(insert l t)

let rec insertnewline src lines =
  match src with
    [] -> lines
      (* Actually, this should be the last element anyway. *)
  | (NotFound _,_,_)::t -> insertnewline t lines
  | (Found h,_,_)::t ->
      try
        let newline = input_line h in
        insert (extracttime newline, newline, src) lines
      with End_of_file -> insertnewline t lines

let nextline lines =
  match lines with
    [] -> []
  | (_,line,src)::t -> 
      (print_endline line; insertnewline src t)

let rec readfirstlines sources =
  match sources with
    [] -> []
  | h::t -> insertnewline (List.rev h) (readfirstlines t)

let merge sources =
  let lines = readfirstlines sources in
  let rec aux ls = match ls with [] -> () | _ -> aux (nextline ls) in
  aux lines

let savenewoffsets offsetsfile sources =
  let formatter = Format.formatter_of_out_channel offsetsfile in
  let writeoffset files =
    match files with
      [] -> prerr_endline "Warning: no files for a source!\n"
    | (NotFound offset,filename,inode)::_ ->
        Format.fprintf formatter "%S %d %Ld\n%!" filename inode offset
    | (Found file,filename,inode)::_ ->
        let offset = LargeFile.pos_in file in
        Format.fprintf formatter "%S %d %Ld\n%!" filename inode offset
  in List.iter writeoffset sources
;;

let main () =
  let offsetsfd = Unix.openfile "offsets" [Unix.O_RDWR] 0x600 in
  let offsetsfile = Unix.in_channel_of_descr offsetsfd in
  Unix.lockf offsetsfd Unix.F_TLOCK 0;
  let newoffsetsfile = open_out "offsets.new" in
  let files = openfiles offsetsfile in
  merge files;
  savenewoffsets newoffsetsfile files;
  close_out newoffsetsfile;
  Unix.rename "offsets.new" "offsets";
  Unix.lockf offsetsfd Unix.F_ULOCK 0;
  close_in offsetsfile
in Unix.handle_unix_error main ();;
