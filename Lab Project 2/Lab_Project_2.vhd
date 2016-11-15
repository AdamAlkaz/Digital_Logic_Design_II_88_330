-- The purpose of this project was to make a four bit shift add multiplier

--Inputs
--Start, clock, and reset of the state machine are mapped to push buttons on the FPGA
--A and B represent the multiplicand and the multiplier respectively
--They are both four bit numbers each mapped to a set of four switches on the FPGA (1 switch for 1 bit)

--Outputs
--BC is a two bit number that counts down the four steps that a 4 x 4 bit shift add multiplier takes
-- to calculate the product, the two bit number is mapped to two LEDs on the FPGA
--Done indicates when the process is done and is represented by a LED
--seven_seg_ hundreds, tens, and ones are the displayed on three seven segment displays
-- and display the product in decimal




library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Lab_Project_2 is
port (reset, start, clk: in std_logic;
		A, B : in std_logic_vector (3 downto 0);
		BC : out std_logic_vector (1 downto 0);
		Done : out std_logic;
		seven_seg_hundreds, seven_seg_tens, seven_seg_ones : out std_logic_vector (6 downto 0));
		
end Lab_Project_2;

architecture structure of Lab_Project_2 is

	constant D0 : std_logic_vector(6 downto 0):="1000000";
	constant D1 : std_logic_vector(6 downto 0):="1111001";
	constant D2 : std_logic_vector(6 downto 0):="0100100";
	constant D3 : std_logic_vector(6 downto 0):="0110000";
	constant D4 : std_logic_vector(6 downto 0):="0011001";
	constant D5 : std_logic_vector(6 downto 0):="0010010";
	constant D6 : std_logic_vector(6 downto 0):="0000010";
	constant D7 : std_logic_vector(6 downto 0):="1111000";
	constant D8 : std_logic_vector(6 downto 0):="0000000";
	constant D9 : std_logic_vector(6 downto 0):="0010000";
	constant DX : std_logic_vector(6 downto 0):="1111111";

	type state_type is (s0,s1,s2,s3);
	signal state : state_type := s0;
	
	
	signal MPD : std_logic_vector (3 downto 0) := "1111"; --will initialize to B in real application
	signal MPR : std_logic_vector (3 downto 0) := "1111"; --will initialize to A in real application
	signal BC_state : std_logic_vector (1 downto 0) := "11";
	signal hund, tens, ones : std_logic_vector (3 downto 0);
	signal P : std_logic_vector (7 downto 0);



	
begin

	process (start, clk, reset, MPR, BC_state, hund, tens, ones)
		variable P_temp : std_logic_vector (7 downto 0);
		variable i : integer := 0;
		variable bcd : std_logic_vector (11 downto 0) := "000000000000" ;
		variable PPS : std_logic_vector (4 downto 0) := "00000"; -- fifth bit of PPS is carry of MPD + PPS
		
		begin
		
		--Reset Pressed
			if (reset = '0') then
				state <= s0;
						PPS := "00000";
						BC_state <= "11";
						--MPD <= A; -- used when mapped to FPGA switches
						--MPR <= B;
						Done <= '0';
						bcd := "000000000000";
						hund <= "0000";
						tens <= "0000";
						ones <= "0000";
			elsif (clk = '0') then
				case state is
					when s0 =>
						if (start = '0') then 
							state <= s1;
						end if;
					when s1 =>
						if (MPR(0) = '1') then
							PPS := PPS + MPD;
						end if;
						state <= s2;
					when s2 =>
						P_temp := PPS & MPR(3 downto 1);
						PPS := '0' & P_temp(7 downto 4);
						MPR <= P_temp(3 downto 0);
						if (BC_state = "00") then
							P <= P_temp;
							for i in 0 to 7 loop  -- repeating 8 times.
								bcd := bcd(10 downto 0) & P_temp(7);  --shifting the bits.
								P_temp := P_temp(6 downto 0) & '0';


								if(bcd(3 downto 0) > "0100") then --add 3 if BCD digit is greater than 4.
									bcd(3 downto 0) := bcd(3 downto 0) + "0011";
								end if;

								if(bcd(7 downto 4) > "0100") then --add 3 if BCD digit is greater than 4.
									bcd(7 downto 4) := bcd(7 downto 4) + "0011";
								end if;

								if(bcd(11 downto 8) > "0100") then  --add 3 if BCD digit is greater than 4.
									bcd(11 downto 8) := bcd(11 downto 8) + "0011";
								end if;
							end loop;
							hund <= bcd (11 downto 8);
							tens <= bcd (7 downto 4);
							ones <= bcd (3 downto 0);
							state <= s3;
						else
							BC_state <= BC_state - "01";
							state <= s1;
						end if;
					when s3 =>
						done <= '1';
						case hund is
							when "0000" => seven_seg_hundreds <= D0;
							when "0001" => seven_seg_hundreds <= D1;
							when "0010" => seven_seg_hundreds <= D2;
							when "0011" => seven_seg_hundreds <= D3;
							when "0100" => seven_seg_hundreds <= D4;
							when "0101" => seven_seg_hundreds <= D5;
							when "0110" => seven_seg_hundreds <= D6;
							when "0111" => seven_seg_hundreds <= D7;
							when "1000" => seven_seg_hundreds <= D8;
							when "1001" => seven_seg_hundreds <= D9;
							when others => seven_seg_hundreds <= DX;
						end case;

							
						case tens is
							when "0000" => seven_seg_tens <= D0;
							when "0001" => seven_seg_tens <= D1;
							when "0010" => seven_seg_tens <= D2;
							when "0011" => seven_seg_tens <= D3;
							when "0100" => seven_seg_tens <= D4;
							when "0101" => seven_seg_tens <= D5;
							when "0110" => seven_seg_tens <= D6;
							when "0111" => seven_seg_tens <= D7;
							when "1000" => seven_seg_tens <= D8;
							when "1001" => seven_seg_tens <= D9;
							when others => seven_seg_tens <= DX;
						end case;
						
						case ones is
							when "0000" => seven_seg_ones <= D0;
							when "0001" => seven_seg_ones <= D1;
							when "0010" => seven_seg_ones <= D2;
							when "0011" => seven_seg_ones <= D3;
							when "0100" => seven_seg_ones <= D4;
							when "0101" => seven_seg_ones <= D5;
							when "0110" => seven_seg_ones <= D6;
							when "0111" => seven_seg_ones <= D7;
							when "1000" => seven_seg_ones <= D8;	
							when "1001" => seven_seg_ones <= D9;
							when others => seven_seg_ones <= DX;
						end case;
							
						if (reset = '0') then
							state <= s0;
						end if;
				end case;
			end if;
		end process;
		BC <= BC_state;
end architecture structure;