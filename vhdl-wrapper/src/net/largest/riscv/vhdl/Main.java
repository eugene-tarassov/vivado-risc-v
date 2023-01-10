package net.largest.riscv.vhdl;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URL;
import java.net.URLConnection;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map;

import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.tree.TerminalNode;

import net.largest.riscv.vhdl.Verilog2001Parser.Binary_operatorContext;
import net.largest.riscv.vhdl.Verilog2001Parser.Lsb_constant_expressionContext;
import net.largest.riscv.vhdl.Verilog2001Parser.Module_identifierContext;
import net.largest.riscv.vhdl.Verilog2001Parser.Msb_constant_expressionContext;
import net.largest.riscv.vhdl.Verilog2001Parser.TermContext;
import net.largest.riscv.vhdl.Verilog2001Parser.Unary_operatorContext;

public class Main {

    private static String rocket_module_name = "rocket";

    private static final Map<String,String> macros = new HashMap<String,String>();

    private enum IfDefState {
        SKIP_FALSE,
        SKIP_TRUE,
        SKIP_ALL
    }

    private static class Bus {
        final ArrayList<BusSignal> signals = new ArrayList<BusSignal>();
        Verilog2001Parser.Range_Context addr_range;
        Verilog2001Parser.Range_Context data_range;
    }

    private static class BusSignal {
        String riscv_name;
        String xilinx_name;
        String signal_name;
        String addr_offs_name;
        String bus_name;
        Verilog2001Parser.Range_Context range;
        boolean out;
    }

    private static Verilog2001Parser.Module_declarationContext rocket_system;
    private static final HashMap<String,Bus> axi_buses = new HashMap<String,Bus>();
    private static final ArrayList<BusSignal> axi_signals = new ArrayList<BusSignal>();
    private static int axi_signal_name_len = 0;

    private static int dmi_signal_name_len = 0;
    private static Bus dmi_bus = null;

    private static int jtag_signal_name_len = 0;
    private static Bus jtag_bus = null;

    private static int bscan_signal_name_len = 0;
    private static Bus bscan_bus = null;

    private static int interrupt_bits = 0;

    private static boolean mem_addr_offset = false;

    private static final HashSet<String> modules = new HashSet<String>();

    private static void ln(String s) {
        System.out.print(s);
        System.out.print('\n');
    }

    private static String getPrimaryString(Verilog2001Parser.PrimaryContext p) {
        return p.getText();
    }

    private static String getUnaryOperatorString(Unary_operatorContext u) {
        return u.getText();
    }

    private static String getTermString(TermContext t) {
        TerminalNode s = t.String();
        if (s != null) return s.toString();
        Unary_operatorContext u = t.unary_operator();
        if (u != null) return getUnaryOperatorString(u);
        return getPrimaryString(t.primary());
    }

    private static String getExpressionString(Verilog2001Parser.ExpressionContext e) {
        int cnt = 0;
        String s = null;
        for (TermContext t : e.term()) {
            if (s == null) {
                s = getTermString(t);
                continue;
            }
            Binary_operatorContext b = e.binary_operator(cnt++);
            s += " " + b.getText() + " " + getTermString(t);
        }
        return s;
    }

    private static String getExpressionString(Verilog2001Parser.Constant_expressionContext e) {
        return getExpressionString(e.expression());
    }

    private static String getRangeString(Verilog2001Parser.Range_Context range) {
        Msb_constant_expressionContext fr = range.msb_constant_expression();
        Lsb_constant_expressionContext to = range.lsb_constant_expression();
        return getExpressionString(fr.constant_expression()) + " downto " + getExpressionString(to.constant_expression());
    }

    private static int getRangeLength(Verilog2001Parser.Range_Context range) {
        Msb_constant_expressionContext fr = range.msb_constant_expression();
        Lsb_constant_expressionContext to = range.lsb_constant_expression();
        return
            Integer.parseInt(getExpressionString(fr.constant_expression())) -
            Integer.parseInt(getExpressionString(to.constant_expression())) + 1;
    }

    private static int getRangeHigh(Verilog2001Parser.Range_Context range) {
        Msb_constant_expressionContext fr = range.msb_constant_expression();
        return Integer.parseInt(getExpressionString(fr.constant_expression()));
    }

    private static class PortDeclaration {
        final Verilog2001Parser.Port_identifierContext id;
        final Verilog2001Parser.Range_Context range;
        final boolean out;
        PortDeclaration(Verilog2001Parser.Port_identifierContext id, Verilog2001Parser.Range_Context range, boolean out) {
            this.id = id;
            this.range = range;
            this.out = out;
        }
    }

    private static ArrayList<PortDeclaration> iteratePortDeclaration(Verilog2001Parser.List_of_port_declarationsContext d) {
        ArrayList<PortDeclaration> l = new ArrayList<PortDeclaration>();
        for (Verilog2001Parser.Port_declarationContext decl : d.port_declaration()) {
            Verilog2001Parser.Input_declarationContext inp = decl.input_declaration();
            Verilog2001Parser.Output_declarationContext out = decl.output_declaration();
            if (inp != null) {
                Verilog2001Parser.Range_Context r = inp.range_();
                Verilog2001Parser.List_of_port_identifiersContext ids = inp.list_of_port_identifiers();
                for (Verilog2001Parser.Port_identifierContext id : ids.port_identifier()) {
                    l.add(new PortDeclaration(id, r, false));
                }
            }
            if (out != null) {
                Verilog2001Parser.Range_Context r = out.range_();
                Verilog2001Parser.List_of_port_identifiersContext ids = out.list_of_port_identifiers();
                for (Verilog2001Parser.Port_identifierContext id : ids.port_identifier()) {
                    l.add(new PortDeclaration(id, r, true));
                }
            }
        }
        return l;
    }

    private static void getBusSignals() {
        Verilog2001Parser.List_of_port_declarationsContext port_decls = rocket_system.list_of_port_declarations();
        if (port_decls == null) return;
        String[] atts = {
            "aw_ready",         "AWREADY",
            "aw_valid",         "AWVALID",
            "aw_bits_id",       "AWID",
            "aw_bits_addr",     "AWADDR",
            "aw_bits_len",      "AWLEN",
            "aw_bits_size",     "AWSIZE",
            "aw_bits_burst",    "AWBURST",
            "aw_bits_lock",     "AWLOCK",
            "aw_bits_cache",    "AWCACHE",
            "aw_bits_prot",     "AWPROT",
            "aw_bits_qos",      "AWQOS",

            "w_ready",          "WREADY",
            "w_valid",          "WVALID",
            "w_bits_data",      "WDATA",
            "w_bits_strb",      "WSTRB",
            "w_bits_last",      "WLAST",

            "b_ready",          "BREADY",
            "b_valid",          "BVALID",
            "b_bits_id",        "BID",
            "b_bits_resp",      "BRESP",

            "ar_ready",         "ARREADY",
            "ar_valid",         "ARVALID",
            "ar_bits_id",       "ARID",
            "ar_bits_addr",     "ARADDR",
            "ar_bits_len",      "ARLEN",
            "ar_bits_size",     "ARSIZE",
            "ar_bits_burst",    "ARBURST",
            "ar_bits_lock",     "ARLOCK",
            "ar_bits_cache",    "ARCACHE",
            "ar_bits_prot",     "ARPROT",
            "ar_bits_qos",      "ARQOS",

            "r_ready",          "RREADY",
            "r_valid",          "RVALID",
            "r_bits_id",        "RID",
            "r_bits_data",      "RDATA",
            "r_bits_resp",      "RRESP",
            "r_bits_last",      "RLAST",

            "req_ready",        "o_ready",
            "req_valid",        "o_valid",
            "req_bits_addr",    "o_addr",
            "req_bits_data",    "o_data",
            "req_bits_op",      "o_op",
            "resp_ready",       "i_ready",
            "resp_valid",       "i_valid",
            "resp_bits_data",   "i_data",
            "resp_bits_resp",   "i_resp",

            "jtag_TCK",         "tck",
            "jtag_TMS",         "tms",
            "jtag_TDI",         "tdi",
            "jtag_TDO_data",    "tdo",
            "jtag_TDO_driven",  "tdt",
        };
        boolean multi_mem = false;
        boolean multi_io = false;
        boolean multi_dma = false;
        ArrayList<PortDeclaration> l = iteratePortDeclaration(port_decls);
        for (PortDeclaration d : l) {
            String sig_name = d.id.getText();
            if (sig_name.startsWith("mem_axi4_") && !sig_name.startsWith("mem_axi4_0_")) multi_mem = true;
            else if (sig_name.startsWith("mmio_axi4_") && !sig_name.startsWith("mmio_axi4_0_")) multi_io = true;
            else if (sig_name.startsWith("l2_frontend_bus_axi4_") && !sig_name.startsWith("l2_frontend_bus_axi4_0_")) multi_dma = true;
        }
        for (PortDeclaration d : l) {
            String sig_name = d.id.getText();
            if (sig_name.equals("interrupts")) {
                interrupt_bits = getRangeLength(d.range);
                continue;
            }
            String bus_name = null;
            if (sig_name.startsWith("mem_axi4_")) {
                int no = 0;
                for (int i = 9; i < sig_name.length(); i++) {
                    char ch = sig_name.charAt(i);
                    if (ch < '0' || ch > '9') break;
                    no = no * 10 + (ch - '0');
                }
                if (!multi_mem && no == 0) bus_name = "mem_axi4";
                else bus_name = "mem_axi4_" + no;
            }
            else if (sig_name.startsWith("mmio_axi4_")) {
                int no = 0;
                for (int i = 10; i < sig_name.length(); i++) {
                    char ch = sig_name.charAt(i);
                    if (ch < '0' || ch > '9') break;
                    no = no * 10 + (ch - '0');
                }
                if (!multi_io && no == 0) bus_name = "io_axi4";
                else bus_name = "io_axi4_" + no;
            }
            else if (sig_name.startsWith("l2_frontend_bus_axi4_")) {
                int no = 0;
                for (int i = 21; i < sig_name.length(); i++) {
                    char ch = sig_name.charAt(i);
                    if (ch < '0' || ch > '9') break;
                    no = no * 10 + (ch - '0');
                }
                if (!multi_dma && no == 0) bus_name = "dma_axi4";
                else bus_name = "dma_axi4_" + no;
            }
            else if (sig_name.startsWith("debug_clockeddmi_dmi_")) bus_name = "dmi";
            else if (sig_name.startsWith("debug_systemjtag_jtag_")) bus_name = "jtag";
            else if (sig_name.startsWith("debug_debug_clockeddmi_dmi_")) bus_name = "dmi";
            else if (sig_name.startsWith("debug_debug_systemjtag_jtag_")) bus_name = "jtag";
            else continue;
            for (int i = 0; i < atts.length; i += 2) {
                if (sig_name.endsWith("_" + atts[i])) {
                    String nm = atts[i + 1];
                    BusSignal sig = new BusSignal();
                    sig.bus_name = bus_name;
                    sig.riscv_name = sig_name;
                    sig.signal_name = bus_name + "_" + nm.toLowerCase();
                    sig.xilinx_name = nm;
                    sig.out = d.out;
                    sig.range = d.range;
                    if (bus_name.equals("jtag")) {
                        int len = sig.signal_name.length();
                        if (len > jtag_signal_name_len) jtag_signal_name_len = len;
                        if (jtag_bus == null) jtag_bus = new Bus();
                        jtag_bus.signals.add(sig);
                    }
                    else if (bus_name.equals("dmi")) {
                        int len = sig.signal_name.length();
                        if (len > dmi_signal_name_len) dmi_signal_name_len = len;
                        if (dmi_bus == null) dmi_bus = new Bus();
                        dmi_bus.signals.add(sig);
                    }
                    else {
                        if (bus_name.startsWith("mem_axi4")) {
                            if (sig.xilinx_name.equals("AWADDR")) {
                                sig.addr_offs_name = sig.bus_name + "_awaddr_sys";
                                mem_addr_offset = true;
                            }
                            if (sig.xilinx_name.equals("ARADDR")) {
                                sig.addr_offs_name = sig.bus_name + "_araddr_sys";
                                mem_addr_offset = true;
                            }
                        }
                        axi_signals.add(sig);
                        int len = sig.signal_name.length();
                        if (len > axi_signal_name_len) axi_signal_name_len = len;
                        Bus axi_bus = axi_buses.get(sig.bus_name);
                        if (axi_bus == null) {
                            axi_bus = new Bus();
                            axi_buses.put(sig.bus_name, axi_bus);
                        }
                        axi_bus.signals.add(sig);
                        if (axi_bus.addr_range == null && sig.xilinx_name.endsWith("ADDR")) axi_bus.addr_range = sig.range;
                        if (axi_bus.data_range == null && sig.xilinx_name.endsWith("DATA")) axi_bus.data_range = sig.range;
                    }
                }
            }
        }
    }

    private static void copyModule(String name) {
        try {
            URL url = Main.class.getResource(name + ".vhdl");
            URLConnection con = url.openConnection();
            BufferedReader inp = new BufferedReader(new InputStreamReader(con.getInputStream()));
            for (;;) {
                String s = inp.readLine();
                if (s == null) break;
                ln(s);
            }
            inp.close();
        }
        catch (Exception x) {
            throw new Error(x);
        }
    }

    private static void generateEntityPort() {
        ln("");
        ln("entity " + rocket_module_name + " is");
        if (mem_addr_offset) {
            ln("generic (");
            ln("    RAM_ADDR_OFFSET_MB : integer := 0);");
        }
        ln("port (");
        ln("    clock      : in std_logic;");
        ln("    clock_ok   : in std_logic;");
        ln("    mem_ok     : in std_logic;");
        ln("    io_ok      : in std_logic;");
        ln("    sys_reset  : in std_logic;");
        ln("    aresetn    : out std_logic;");
        ln("");
        if (interrupt_bits > 0) {
            ln("    interrupts: in std_logic_vector(" + (interrupt_bits - 1) + " downto 0);");
            ln("");
        }
        String s = null;
        String bus = null;
        for (BusSignal sig : axi_signals) {
            if (s != null) {
                ln(s + ";");
                if (!sig.bus_name.equals(bus)) ln("");
            }
            String nm = sig.signal_name;
            while (nm.length() < axi_signal_name_len) nm += ' ';
            s = "    " + nm + ": ";
            s += sig.out ? "out" : "in ";
            if (sig.addr_offs_name != null) {
                int h = getRangeHigh(sig.range);
                s += " std_logic_vector(" + h + " downto 0)";
            }
            else if (sig.range != null) {
                s += " std_logic_vector(" + getRangeString(sig.range) + ")";
            }
            else {
                s += " std_logic";
            }
            bus = sig.bus_name;
        }
        if (jtag_bus != null) {
            if (s != null) ln(s + ";");
            s = null;
            ln("");
            for (BusSignal sig : jtag_bus.signals) {
                if (s != null) ln(s + ";");
                String nm = sig.signal_name;
                while (nm.length() < jtag_signal_name_len) nm += ' ';
                s = "    " + nm + ": ";
                s += sig.out ? "out" : "in ";
                s += " std_logic";
            }
        }
        if (bscan_bus != null) {
            if (s != null) ln(s + ";");
            s = null;
            ln("");
            for (BusSignal sig : bscan_bus.signals) {
                if (s != null) ln(s + ";");
                String nm = sig.signal_name;
                while (nm.length() < bscan_signal_name_len) nm += ' ';
                s = "    " + nm + ": ";
                s += sig.out ? "out" : "in ";
                s += " std_logic";
            }
        }
        if (s != null) ln(s + ");");
        else ln(");");
        ln("end " + rocket_module_name + ";");
    }

    private static void generateBusAttributes() {
        for (Bus bus : axi_buses.values()) {
            ln("");
            for (BusSignal sig : bus.signals) {
                String nm = sig.signal_name;
                while (nm.length() < axi_signal_name_len) nm += ' ';
                ln("    ATTRIBUTE X_INTERFACE_INFO of " + nm +
                    ": SIGNAL is \"xilinx.com:interface:aximm:1.0 " +
                    sig.bus_name.toUpperCase() + " " + sig.xilinx_name + "\";");
            }
            int aw = getRangeLength(bus.addr_range);
            int dw = getRangeLength(bus.data_range);
            ln("    ATTRIBUTE X_INTERFACE_PARAMETER of " + bus.signals.get(0).signal_name +
                ": SIGNAL is \"CLK_DOMAIN clock, PROTOCOL AXI4, ADDR_WIDTH " + aw + ", DATA_WIDTH " + dw + "\";");
        }
        if (jtag_bus != null) {
            ln("");
            ln("    ATTRIBUTE X_INTERFACE_INFO of jtag_tck : SIGNAL is \"xilinx.com:interface:jtag:1.0 JTAG TCK\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of jtag_tms : SIGNAL is \"xilinx.com:interface:jtag:1.0 JTAG TMS\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of jtag_tdi : SIGNAL is \"xilinx.com:interface:jtag:1.0 JTAG TD_I\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of jtag_tdo : SIGNAL is \"xilinx.com:interface:jtag:1.0 JTAG TD_O\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of jtag_tdt : SIGNAL is \"xilinx.com:interface:jtag:1.0 JTAG TD_T\";");
        }
        if (bscan_bus != null) {
            ln("");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_update  : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN UPDATE\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_tms     : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN TMS\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_tdo     : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN TDO\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_tdi     : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN TDI\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_tck     : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN TCK\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_shift   : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN SHIFT\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_sel     : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN SEL\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_runtest : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN RUNTEST\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_reset   : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN RESET\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_drck    : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN DRCK\";");
            ln("    ATTRIBUTE X_INTERFACE_INFO of S_BSCAN_capture : SIGNAL is \"xilinx.com:interface:bscan:1.0 S_BSCAN CAPTURE\";");
        }
    }

    private static void generateRocketSystemDeclaration() {
        Verilog2001Parser.List_of_port_declarationsContext port_decls = rocket_system.list_of_port_declarations();
        if (port_decls == null) throw new Error("Cannot find a port declaration of RocketSystem module");
        ln("");
        ln("    component RocketSystem is");
        ln("    port (");
        ArrayList<PortDeclaration> list = iteratePortDeclaration(port_decls);
        int id_len = 0;
        for (PortDeclaration d : list) {
            int len = d.id.getText().length();
            if (len > id_len) id_len = len;
        }
        while ((id_len & 3) != 0) id_len++;
        String s = null;
        for (PortDeclaration d : list) {
            if (s != null) ln(s + ";");
            String id = d.id.getText();
            s = "        " + id;
            int len = id.length();
            while (len < id_len) {
                s += ' ';
                len++;
            }
            s += ": ";
            s += d.out ? "out" : "in ";
            if (d.range != null) {
                s += " std_logic_vector(" + getRangeString(d.range) + ")";
            }
            else {
                s += " std_logic";
            }
        }
        if (s != null) ln(s + ");");
        else ln("    );");
        ln("    end component RocketSystem;");
    }

    private static void generateSignalDeclarations() {
        ln("");
        ln("    attribute ASYNC_REG : string;");
        ln("");
        ln("    signal reset       : std_logic := '1';");
        ln("    signal debug_reset : std_logic;");
        ln("    signal riscv_reset : std_logic;");
        if (jtag_bus != null) {
            ln("    signal enable_tdo  : std_logic;");
        }
        if (dmi_bus != null) {
            ln("");
            for (BusSignal sig : dmi_bus.signals) {
                String nm = sig.signal_name;
                while (nm.length() < dmi_signal_name_len) nm += ' ';
                String s = "    signal " + nm + " : ";
                if (sig.range == null) s += " std_logic";
                else s += " std_logic_vector(" + getRangeString(sig.range) + ")";
                ln(s + ';');
            }
        }
        ln("");
        ln("    signal debug_dmactive : std_logic;");
        ln("");
        ln("    signal reset_cnt : unsigned(4 downto 0) := \"00000\";");
        ln("    signal reset_inp : std_logic;");
        ln("    signal reset_sync: std_logic;");
        if (interrupt_bits > 0) {
            ln("");
            ln("    signal interrupts_ss1 : std_logic_vector(" + (interrupt_bits - 1) + " downto 0);");
            ln("    signal interrupts_ss2 : std_logic_vector(" + (interrupt_bits - 1) + " downto 0);");
            ln("    signal interrupts_sync: std_logic_vector(" + (interrupt_bits - 1) + " downto 0);");
            ln("    attribute ASYNC_REG of interrupts_ss1 : signal is \"TRUE\";");
            ln("    attribute ASYNC_REG of interrupts_ss2 : signal is \"TRUE\";");
            ln("    attribute ASYNC_REG of interrupts_sync: signal is \"TRUE\";");
        }
        ln("");
        if (mem_addr_offset) {
            ln("    constant mem_start_addr : unsigned(31 downto 0) := X\"80000000\";");
            for (BusSignal sig : axi_signals) {
                if (sig.addr_offs_name != null) {
                    ln("    signal " + sig.addr_offs_name + " : std_logic_vector(" + getRangeString(sig.range) + ");");
                }
            }
        }
    }

    private static void generateResetLogic() {
        ln("");
        ln("    reset_inp <= sys_reset or not clock_ok or not mem_ok or not io_ok;");
        ln("");
        ln("    syn_reset : entity work.synchronizer");
        ln("    port map (");
        ln("        clock => clock,");
        ln("        dinp  => reset_inp,");
        ln("        dout  => reset_sync);");
        ln("");
        ln("    process (clock)");
        ln("    begin");
        ln("        if clock'event and clock = '1' then");
        ln("            if reset_sync = '1' then");
        ln("                reset_cnt <= (others => '0');");
        ln("                aresetn <= '0';");
        ln("                reset <= '1';");
        ln("            elsif reset_cnt < \"01111\" then");
        ln("                reset_cnt <= reset_cnt + 1;");
        ln("                aresetn <= '0';");
        ln("                reset <= '1';");
        ln("            elsif reset_cnt < \"11111\" then");
        ln("                reset_cnt <= reset_cnt + 1;");
        ln("                aresetn <= '1';");
        ln("                reset <= '1';");
        ln("            else");
        ln("                aresetn <= '1';");
        ln("                reset <= '0';");
        ln("            end if;");
        ln("        end if;");
        ln("    end process;");
        ln("");
        ln("    riscv_reset <= reset or debug_reset;");
    }

    private static void generateInterruptSynchronizer() {
        ln("");
        ln("    process (clock)");
        ln("    begin");
        ln("        if clock'event and clock = '1' then");
        ln("            interrupts_ss1 <= interrupts;");
        ln("            interrupts_ss2 <= interrupts_ss1;");
        ln("            interrupts_sync <= interrupts_ss2;");
        ln("        end if;");
        ln("    end process;");
    }

    private static void generateRocketSystemComponent() {
        Verilog2001Parser.List_of_port_declarationsContext port_decls = rocket_system.list_of_port_declarations();
        if (port_decls == null) throw new Error("Cannot find a port declaration of RocketSystem module");
        if (mem_addr_offset) {
            ln("");
            for (BusSignal sig : axi_signals) {
                if (sig.addr_offs_name != null) {
                    int h = getRangeHigh(sig.range);
                    ln("    " + sig.signal_name + " <= std_logic_vector(unsigned(" +
                        sig.addr_offs_name + ") - mem_start_addr + " +
                        "shift_left(to_unsigned(RAM_ADDR_OFFSET_MB, " + (h + 1) + "), 20));");
                }
            }
        }
        ln("");
        ln("    rocket_system : component RocketSystem");
        ln("    port map (");
        ArrayList<PortDeclaration> decl_list = iteratePortDeclaration(port_decls);
        int id_len = 0;
        for (PortDeclaration decl : decl_list) {
            int len = decl.id.getText().length();
            if (len > id_len) id_len = len;
        }
        while ((id_len & 3) != 0) id_len++;
        HashMap<String,BusSignal> sig_map = new HashMap<String,BusSignal>();
        for (BusSignal sig : axi_signals) {
            sig_map.put(sig.riscv_name, sig);
        }
        if (dmi_bus != null) {
            for (BusSignal sig : dmi_bus.signals) {
                sig_map.put(sig.riscv_name, sig);
            }
        }
        if (jtag_bus != null) {
            for (BusSignal sig : jtag_bus.signals) {
                if (sig.riscv_name.equals("debug_systemjtag_jtag_TDO_driven")) continue;
                sig_map.put(sig.riscv_name, sig);
            }
        }
        String s = null;
        for (PortDeclaration decl : decl_list) {
            String nm = decl.id.getText();
            String dst = null;
            BusSignal sig = sig_map.get(nm);
            if (sig != null) dst = sig.addr_offs_name != null ? sig.addr_offs_name : sig.signal_name;
            else if (nm.equals("reset")) dst = "riscv_reset";
            else if (nm.equals("debug_clock")) dst = "clock";
            else if (nm.equals("debug_clockeddmi_dmiClock")) dst = "clock";
            else if (nm.equals("debug_clockeddmi_dmiReset")) dst = "reset";
            else if (nm.equals("debug_systemjtag_reset")) dst = "'0'";
            else if (nm.equals("debug_systemjtag_mfr_id")) dst = "\"10010001001\"";
            else if (nm.equals("debug_systemjtag_part_number")) dst = "\"0000000000000000\"";
            else if (nm.equals("debug_systemjtag_version")) dst = "\"0000\"";
            else if (nm.equals("debug_systemjtag_jtag_TDO_driven")) dst = "enable_tdo";
            else if (nm.equals("debug_ndreset")) dst = "debug_reset";
            else if (nm.equals("debug_dmactive")) dst = "debug_dmactive";
            else if (nm.equals("debug_dmactiveAck")) dst = "debug_dmactive";
            else if (nm.startsWith("resetctrl_hartIsInReset")) dst = "'0'";
            else if (nm.equals("debug_debug_clock")) dst = "clock";
            else if (nm.equals("debug_debug_reset")) dst = "debug_reset";
            else if (nm.equals("debug_debug_clockeddmi_dmiClock")) dst = "clock";
            else if (nm.equals("debug_debug_clockeddmi_dmiReset")) dst = "reset";
            else if (nm.equals("debug_debug_systemjtag_reset")) dst = "'0'";
            else if (nm.equals("debug_debug_systemjtag_mfr_id")) dst = "\"10010001001\"";
            else if (nm.equals("debug_debug_systemjtag_part_number")) dst = "\"0000000000000000\"";
            else if (nm.equals("debug_debug_systemjtag_version")) dst = "\"0000\"";
            else if (nm.equals("debug_debug_systemjtag_jtag_TDO_driven")) dst = "enable_tdo";
            else if (nm.equals("debug_debug_ndreset")) dst = "debug_reset";
            else if (nm.equals("debug_debug_dmactive")) dst = "debug_dmactive";
            else if (nm.equals("debug_debug_dmactiveAck")) dst = "debug_dmactive";
            else if (nm.startsWith("resetctrl_resetctrl_hartIsInReset")) dst = "'0'";
            else if (nm.equals("interrupts")) dst = "interrupts_sync";
            else dst = nm;
            if (s != null) ln(s + ',');
            while (nm.length() < id_len) nm += ' ';
            s = "        " + nm + " => " + dst;
        }
        if (s != null) ln(s + ");");
        else ln("    );");
    }

    private static void generateDebugComponent() {
        if (dmi_bus != null) {
            ln("");
            String s = null;
            if (bscan_bus != null) {
                ln("    jtag : entity work.JtagExtBscan");
                ln("    port map (");
                ln("        clock => clock,");
                ln("        reset => reset,");
                ln("        -- BSCAN interface");
                for (BusSignal sig : bscan_bus.signals) {
                    if (s != null) ln(s + ",");
                    String nm = sig.signal_name;
                    while (nm.length() < bscan_signal_name_len) nm += ' ';
                    s = "        " + nm + " => ";
                    s += sig.signal_name;
                }
            }
            else {
                ln("    jtag : entity work.JtagSeries7");
                ln("    port map (");
                ln("        clock => clock,");
                ln("        reset => reset,");
            }
            ln("        -- Debug Module interface");
            for (BusSignal sig : dmi_bus.signals) {
                if (s != null) ln(s + ',');
                String nm = sig.signal_name;
                while (nm.length() < dmi_signal_name_len) nm += ' ';
                s = "        " + nm + " => ";
                s += sig.signal_name;
            }
            ln(s + ");");
        }
    }

    private static void generateSystemVHDL() {
        copyModule("sync");

        if (dmi_bus != null) {
            ln("");
            if (bscan_bus != null) {
                copyModule("jtag-ext-bscan");
            }
            else {
                copyModule("jtag");
            }
        }

        ln("");
        ln("library ieee;");
        ln("use ieee.std_logic_1164.all;");
        ln("use ieee.numeric_std.all;");

        generateEntityPort();

        ln("");
        ln("architecture Behavioral of " + rocket_module_name + " is");
        ln("    ATTRIBUTE X_INTERFACE_INFO : STRING;");
        ln("    ATTRIBUTE X_INTERFACE_PARAMETER : STRING;");
        ln("");
        String axi_bus_names = "";
        for (String name : axi_buses.keySet()) {
            if (axi_bus_names.length() == 0) axi_bus_names = ", ASSOCIATED_BUSIF " + name.toUpperCase();
            else axi_bus_names += ':' + name.toUpperCase();
        }
        ln("    ATTRIBUTE X_INTERFACE_INFO of sys_reset: SIGNAL is \"xilinx.com:signal:reset:1.0 sys_reset RST\";");
        ln("    ATTRIBUTE X_INTERFACE_PARAMETER of sys_reset: SIGNAL is \"POLARITY ACTIVE_HIGH\";");
        ln("    ATTRIBUTE X_INTERFACE_INFO of aresetn: SIGNAL is \"xilinx.com:signal:reset:1.0 aresetn RST\";");
        ln("    ATTRIBUTE X_INTERFACE_PARAMETER of aresetn: SIGNAL is \"POLARITY ACTIVE_LOW\";");
        ln("    ATTRIBUTE X_INTERFACE_INFO of clock: SIGNAL is \"xilinx.com:signal:clock:1.0 clock CLK\";");
        ln("    ATTRIBUTE X_INTERFACE_PARAMETER of clock: SIGNAL is \"ASSOCIATED_RESET aresetn" + axi_bus_names + "\";");

        generateBusAttributes();
        generateRocketSystemDeclaration();
        generateSignalDeclarations();

        ln("");
        ln("begin");

        generateResetLogic();
        if (interrupt_bits > 0) generateInterruptSynchronizer();
        if (jtag_bus != null) ln("    jtag_tdt <= not enable_tdo;");
        generateRocketSystemComponent();
        generateDebugComponent();

        ln("");
        ln("end Behavioral;");

        if (modules.contains("plusarg_reader")) {
            ln("");
            ln("library ieee;");
            ln("use ieee.std_logic_1164.all;");
            ln("use ieee.numeric_std.all;");
            ln("");
            ln("entity plusarg_reader is");
            ln("    generic (FORMAT : string := \"\"; DEFAULT : integer := 0; WIDTH : integer := 32);");
            ln("    port (\\out\\: out std_logic_vector(WIDTH-1 downto 0));");
            ln("end plusarg_reader;");
            ln("");
            ln("architecture Behavioral of plusarg_reader is");
            ln("begin");
            ln("    \\out\\ <= std_logic_vector(to_unsigned(DEFAULT, WIDTH));");
            ln("end Behavioral;");
        }

        if (modules.contains("EICG_wrapper")) {
            ln("");
            ln("library ieee;");
            ln("use ieee.std_logic_1164.all;");
            ln("library unisim;");
            ln("use unisim.Vcomponents.all;");
            ln("");
            ln("entity EICG_wrapper is");
            ln("    port (\\in\\: in std_logic; en: in std_logic; \\out\\: out std_logic);");
            ln("end EICG_wrapper;");
            ln("");
            ln("architecture Behavioral of EICG_wrapper is");
            ln("begin");
            ln("    buf : BUFGCE");
            ln("    port map (I => \\in\\, CE => en, O => \\out\\);");
            ln("end Behavioral;");
        }

        if (modules.contains("AsyncResetReg")) {
            ln("");
            ln("library ieee;");
            ln("use ieee.std_logic_1164.all;");
            ln("");
            ln("entity AsyncResetReg is");
            ln("    generic (RESET_VALUE : integer := 0);");
            ln("    port (d: in std_logic; q: out std_logic; en: in std_logic; clk: in std_logic; rst: in std_logic);");
            ln("end AsyncResetReg;");
            ln("");
            ln("architecture Behavioral of AsyncResetReg is");
            ln("begin");
            ln("    process (clk,rst)");
            ln("    begin");
            ln("        if rst = '1' then");
            ln("            if RESET_VALUE = 0 then q <= '0'; else q <= '1'; end if;");
            ln("        elsif clk'event and clk = '1' and en = '1' then");
            ln("            q <= d;");
            ln("        end if;");
            ln("    end process;");
            ln("end Behavioral;");
        }
    }

    public static void main(String[] args) {
        int arg_pos = 0;
        if (arg_pos < args.length && args[arg_pos].equals("-m")) {
            arg_pos++;
            if (arg_pos < args.length) {
                rocket_module_name = args[arg_pos++];
            }
        }
        if (args.length - arg_pos != 1) {
            System.err.println("Usage:");
            System.err.println("  java net.largest.riscv.vhdl.Main [options] <Verilog file name>");
            System.exit(1);
        }
        try {
            CharStream input = CharStreams.fromFileName(args[arg_pos]);
            Verilog2001Lexer lexer = new Verilog2001Lexer(input) {
                boolean skip = false;
                final LinkedList<IfDefState> stack = new LinkedList<IfDefState>();
                public Token nextToken() {
                    while (skip) super.nextToken();
                    return super.nextToken();
                }
                String getArgs() {
                    String s = getText();
                    StringBuffer bf = new StringBuffer();
                    int l = s.length();
                    int i = 0;
                    while (i < l && s.charAt(i) > ' ') i++;
                    while (i < l && s.charAt(i) <= ' ') i++;
                    while (i < l && s.charAt(l - 1) <= ' ') l--;
                    boolean sp = true;
                    while (i < l) {
                        char ch = s.charAt(i++);
                        if (ch < ' ') ch = ' ';
                        if (sp && ch == ' ') continue;
                        sp = ch == ' ';
                        bf.append(ch);
                    }
                    return bf.toString();
                }
                void onIfDef() {
                    setType(SKIP);
                    if (skip) {
                        stack.add(IfDefState.SKIP_ALL);
                    }
                    else {
                        String s = macros.get(getArgs());
                        if (s == null) {
                            stack.add(IfDefState.SKIP_TRUE);
                            skip = true;
                        }
                        else {
                            stack.add(IfDefState.SKIP_FALSE);
                        }
                    }
                }
                void onIfNDef() {
                    setType(SKIP);
                    if (skip) {
                        stack.add(IfDefState.SKIP_ALL);
                    }
                    else {
                        String s = macros.get(getArgs());
                        if (s != null) {
                            stack.add(IfDefState.SKIP_TRUE);
                            skip = true;
                        }
                        else {
                            stack.add(IfDefState.SKIP_FALSE);
                        }
                    }
                }
                void onElse() {
                    setType(SKIP);
                    switch (stack.removeLast()) {
                    case SKIP_FALSE:
                        stack.add(IfDefState.SKIP_TRUE);
                        skip = true;
                        break;
                    case SKIP_TRUE:
                        stack.add(IfDefState.SKIP_FALSE);
                        skip = false;
                        break;
                    case SKIP_ALL:
                        stack.add(IfDefState.SKIP_ALL);
                        skip = true;
                        break;
                    }
                }
                void onEndIf() {
                    setType(SKIP);
                    stack.removeLast();
                    skip = !stack.isEmpty() && stack.getLast() != IfDefState.SKIP_FALSE;
                }
                void onDefine() {
                    setType(SKIP);
                    if (skip) return;
                    String s = getArgs();
                    int i = s.indexOf(' ');
                    macros.put(s.substring(0, i), s.substring(i + 1));
                }
                void onUnDef() {
                    setType(SKIP);
                    if (skip) return;
                    String s = getArgs();
                    macros.remove(s);
                }
                void onMacro() {
                    setType(SKIP);
                    if (skip) return;
                    /* Not implemented, but not needed for RISC-V */
                }
            };
            macros.put("SYNTHESIS", "1");
            CommonTokenStream tokens = new CommonTokenStream(lexer);
            Verilog2001Parser parser = new Verilog2001Parser(tokens);
            parser.addParseListener(new Verilog2001BaseListener() {
                public void exitModule_declaration(Verilog2001Parser.Module_declarationContext ctx) {
                    Module_identifierContext id = ctx.module_identifier();
                    if (id != null) {
                        String name = id.getText();
                        if (name.equals("RocketSystem")) {
                            rocket_system = ctx;
                            getBusSignals();
                        }
                    }
                }
                public void exitModule_instantiation(Verilog2001Parser.Module_instantiationContext ctx) {
                    modules.add(ctx.module_identifier().getText());
                }
            });
            parser.source_text();
            if (rocket_system != null) {
                if (dmi_bus != null && rocket_module_name.endsWith("e")) {
                    bscan_bus = new Bus();
                    String[] sigs = {
                        "capture",
                        "drck",
                        "reset",
                        "runtest",
                        "sel",
                        "shift",
                        "tck",
                        "tdi",
                        "tdo",
                        "tms",
                        "update",
                    };
                    for (String nm : sigs) {
                        BusSignal sig = new BusSignal();
                        sig.bus_name = "S_BSCAN";
                        sig.signal_name = "S_BSCAN_" + nm;
                        sig.out = nm.equals("tdo");
                        bscan_bus.signals.add(sig);
                        int len = sig.signal_name.length();
                        if (len > bscan_signal_name_len) bscan_signal_name_len = len;
                    }
                }
                generateSystemVHDL();
            }
        }
        catch (Throwable x) {
            x.printStackTrace();
            System.exit(1);
        }
    }
}
