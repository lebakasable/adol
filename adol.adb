with Ada.Text_IO; use Ada.Text_IO;
with Ada.Characters.Latin_1; use Ada.Characters.Latin_1;

procedure Adol is
  Width  : constant Positive := 10;
  Height : constant Positive := 10;

  type Cell is (Dead, Alive);
  type Rows is mod Height;
  type Cols is mod Width;
  type Board is array (Rows, Cols) of Cell;
  type Neighbours is range 0 .. 8;

  procedure Render_Board(B : Board) is
  begin
    for Row in Rows loop
      for Col in Cols loop
        case B(Row, Col) is
          when Dead  => Put(ESC & "[30m." & ESC & "[0m");
          when Alive => Put(ESC & "[33m#" & ESC & "[0m");
        end case;
      end loop;
      New_Line;
    end loop;
  end;

  function Count_Neighbours(B : Board; Row0 : Rows; Col0 : Cols) return Neighbours is
  begin
    return Result : Neighbours := 0 do
      for Delta_Row in Rows range 0 .. 2 loop
        for Delta_Col in Cols range 0 .. 2 loop
          if Delta_Row /= 1 or Delta_Col /= 1 then
            declare
              Row : Rows := Row0 + Delta_Row - 1;
              Col : Cols := Col0 + Delta_Col - 1;
            begin
              if B(Row, Col) = Alive then
                Result := Result + 1;
              end if;
            end;
          end if;
        end loop;
      end loop;
    end return;
  end;

  function Next(Current : Board) return Board is
  begin
    return Result : Board do
      for Row in Rows loop
        for Col in Cols loop
          declare
            N : Neighbours := Count_Neighbours(Current, Row, Col);
          begin
            case Current(Row, Col) is
              when Dead  =>
                Result(Row, Col) := (if N = 3 then Alive else Dead);
              when Alive =>
                Result(Row, Col) := (if N in 2 .. 3 then Alive else Dead);
            end case;
          end;
        end loop;
      end loop;
    end return;
  end;

  Current : Board := (
    (Dead,  Alive, Dead,  others => Dead),
    (Dead,  Dead,  Alive, others => Dead),
    (Alive, Alive, Alive, others => Dead),
    others => (others => Dead)
  );
begin
  Put(ESC & "[?25l" & ESC & "[2J");

  loop
    Put(ESC & "[H");

    Render_Board(Current);
    Current := Next(Current);

    delay 0.25;
  end loop;
end;
