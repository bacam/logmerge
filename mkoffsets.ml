for i = 1 to (Array.length Sys.argv) - 1 do
  let stat = Unix.stat Sys.argv.(i) in
  Format.printf "%S %d 0\n" Sys.argv.(i) stat.Unix.st_ino
done
