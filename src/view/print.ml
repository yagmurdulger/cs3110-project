
(** [string_of_square att] is string "r", "b", "g", or "#" matching with grid 
    attribute [att]. *)
let string_of_square (att : Grid.attribute) = match att with
  | Red -> "r"
  | Blue -> "b"
  | Green -> "g"
  | Wall -> "#"

let rec string_of_row lst = match lst with
  | [] -> ""
  | (_,_,a)::t -> a^" | "^(string_of_row t)

let rec print_grid_aux glst wlst cur n = 
  if cur = 0 then () else
    let row = List.filter (fun (_,y,_) -> y = cur) glst in
    let srow = List.sort (fun (x,_,_) (xx,_,_) -> compare x xx) row in
    let wrow = List.filter (fun (_,y,_) -> y = cur) wlst in
    let wsrow = List.sort (fun (x,_,_) (xx,_,_) -> compare x xx) wrow in
    let hbar1 = String.make (4 * n + 1) '-' in
    let hbar2 = String.make (4 * n + 1) '-' in
    print_string "| ";
    print_string (string_of_row srow);
    print_string "   ";
    print_string "| ";
    print_string (string_of_row wsrow);
    print_string "\n";
    print_string hbar1;
    print_string "    ";
    print_endline hbar2;
    print_grid_aux glst wlst (cur-1) n

let rec win_grid wlst glst acc =
  let win_grid_aux x y a = 
    match List.find_opt (fun (xx,yy,aa) -> xx = x && yy = y) wlst with
    | Some (xx,yy,aa) -> (x,y, (string_of_square aa))
    | None -> (x,y,".") 
  in
  match glst with
  | [] -> acc
  | (x,y,a)::t -> (win_grid_aux x y a)::(win_grid wlst t acc)

let print_grid st gr =
  print_endline (
    ("\nGrid"^(String.make (4 * (Grid.get_size gr) - 3) '-'))
    ^"    "
    ^("Winning"^(String.make (4 * (Grid.get_size gr) - 6) '-'))
  );
  let ax, ay = st |> State.get_agent |> fun (x,y,_) -> (x,y) in
  let lst = Grid.win_to_list gr in
  let glst = st |> State.to_list in
  let wlst = win_grid lst glst [] in
  let f = fun (x,y,a) -> begin if ax <> x || ay <> y then (x,y,(string_of_square a)) 
      else match State.get_agent st with 
        | (x,y,Grid.N) -> (x,y,"^")
        | (x,y,Grid.E) -> (x,y,">")
        | (x,y,Grid.W) -> (x,y,"<")
        | (x,y,Grid.S) -> (x,y,"v")
    end in
  let glst = st |> State.to_list |> List.map f in
  gr |> Grid.get_size |> fun x -> print_grid_aux glst wlst x x


