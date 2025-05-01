library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port( op : in std_logic_vector(3 downto 0);
          i1 : in std_logic_vector(15 downto 0);
          i2 : in std_logic_vector(15 downto 0);
          o  : out std_logic_vector(15 downto 0);
          st : out std_logic_vector(3 downto 0));
end alu;

architecture Behavioral of alu is
begin
    process(op, i1, i2)
        variable res_val    : std_logic_vector(16 downto 0) := (others => '0');
        variable carry_out  : std_logic_vector(16 downto 0) := (others => '0');
        variable shift_amt  : integer := 0;
    begin
        case op is

            when "0000" =>
                res_val := '0' & (i1 and i2);
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15); st(1) <= '0'; st(0) <= '0';

            when "0001" =>
                res_val := '0' & (i1 or i2); st(1) <= '0'; st(0) <= '0';
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15); st(1) <= '0'; st(0) <= '0';

            when "0010" =>
                res_val := '0' & (i1 xor i2); st(1) <= '0'; st(0) <= '0';
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15); st(1) <= '0'; st(0) <= '0';

            when "0011" =>
                res_val := '0' & not i2; st(1) <= '0'; st(0) <= '0';
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15); st(1) <= '0'; st(0) <= '0';

            when "0100" =>
                res_val := std_logic_vector(unsigned('0' & i1) + unsigned('0' & i2));
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15);
                st(1) <= res_val(16);
                st(0) <= (i1(15) and i2(15) and not(res_val(15))) or (not(i1(15)) and not(i2(15)) and res_val(15));

            when "0101" =>
                carry_out := std_logic_vector(unsigned('0' & not i2) + 1);
                res_val := std_logic_vector(unsigned('0' & i1) + unsigned(carry_out));
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15);
                st(1) <= res_val(16);
                st(0) <= (i1(15) and not(i2(15)) and not(res_val(15))) or (not(i1(15)) and i2(15) and res_val(15));

            when "0110" =>
                shift_amt := to_integer(signed(i2));
                res_val := std_logic_vector(shift_left(unsigned('0' & i1), shift_amt));
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15);
                if (shift_amt > 16 and i1 /= x"0000") or
                   (shift_amt <= 16 and shift_amt > 0 and unsigned(i1(15 downto (16 - shift_amt))) /= 0) then
                    st(1) <= '1';
                else
                    st(1) <= '0';
                end if;
                st(0) <= res_val(15) xor i1(15);

            when "0111" =>
                shift_amt := to_integer(signed(i2));
                res_val := std_logic_vector(shift_right(unsigned('0' & i1), shift_amt));
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15);
                if (shift_amt < 0 and abs(shift_amt) > 16 and i1 /= x"0000") or
                   (shift_amt < 0 and abs(shift_amt) <= 16 and unsigned(i1(15 downto (16 + shift_amt))) /= 0) then
                    st(1) <= '1';
                else
                    st(1) <= '0';
                end if;
                st(0) <= res_val(15) xor i1(15);

            when "1000" | "1010" | "1110" | "1111" =>
                res_val := '0' & i2;
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15); st(1) <= '0'; st(0) <= '0';

            when "1001" | "1011" =>
                res_val := '0' & i1;
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15); st(1) <= '0'; st(0) <= '0';

            when "1100" =>
                res_val := std_logic_vector(unsigned('0' & i1) + unsigned('0' & i2));
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15);
                st(1) <= res_val(16);
                st(0) <= (i1(15) and i2(15) and not(res_val(15))) or (not(i1(15)) and not(i2(15)) and res_val(15));

            when "1101" =>
                carry_out := std_logic_vector(unsigned('0' & not i2) + 1);
                res_val := std_logic_vector(unsigned('0' & i1) + unsigned(carry_out));
                if res_val(15 downto 0) = x"0000" then st(3) <= '1'; else st(3) <= '0'; end if;
                st(2) <= res_val(15);
                st(1) <= res_val(16);
                st(0) <= (i1(15) and not(i2(15)) and not(res_val(15))) or (not(i1(15)) and i2(15) and res_val(15));

            when others =>
                res_val := (others => 'Z'); st <= "ZZZZ";

        end case;

        o <= res_val(15 downto 0);
    end process;
end Behavioral;

