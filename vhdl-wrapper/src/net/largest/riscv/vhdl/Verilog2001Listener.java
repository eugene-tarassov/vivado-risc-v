// Generated from Verilog2001.g4 by ANTLR 4.8
package net.largest.riscv.vhdl;
import org.antlr.v4.runtime.tree.ParseTreeListener;

/**
 * This interface defines a complete listener for a parse tree produced by
 * {@link Verilog2001Parser}.
 */
public interface Verilog2001Listener extends ParseTreeListener {
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#config_declaration}.
	 * @param ctx the parse tree
	 */
	void enterConfig_declaration(Verilog2001Parser.Config_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#config_declaration}.
	 * @param ctx the parse tree
	 */
	void exitConfig_declaration(Verilog2001Parser.Config_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#design_statement}.
	 * @param ctx the parse tree
	 */
	void enterDesign_statement(Verilog2001Parser.Design_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#design_statement}.
	 * @param ctx the parse tree
	 */
	void exitDesign_statement(Verilog2001Parser.Design_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#config_rule_statement}.
	 * @param ctx the parse tree
	 */
	void enterConfig_rule_statement(Verilog2001Parser.Config_rule_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#config_rule_statement}.
	 * @param ctx the parse tree
	 */
	void exitConfig_rule_statement(Verilog2001Parser.Config_rule_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#default_clause}.
	 * @param ctx the parse tree
	 */
	void enterDefault_clause(Verilog2001Parser.Default_clauseContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#default_clause}.
	 * @param ctx the parse tree
	 */
	void exitDefault_clause(Verilog2001Parser.Default_clauseContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#inst_clause}.
	 * @param ctx the parse tree
	 */
	void enterInst_clause(Verilog2001Parser.Inst_clauseContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#inst_clause}.
	 * @param ctx the parse tree
	 */
	void exitInst_clause(Verilog2001Parser.Inst_clauseContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#inst_name}.
	 * @param ctx the parse tree
	 */
	void enterInst_name(Verilog2001Parser.Inst_nameContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#inst_name}.
	 * @param ctx the parse tree
	 */
	void exitInst_name(Verilog2001Parser.Inst_nameContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#liblist_clause}.
	 * @param ctx the parse tree
	 */
	void enterLiblist_clause(Verilog2001Parser.Liblist_clauseContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#liblist_clause}.
	 * @param ctx the parse tree
	 */
	void exitLiblist_clause(Verilog2001Parser.Liblist_clauseContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#cell_clause}.
	 * @param ctx the parse tree
	 */
	void enterCell_clause(Verilog2001Parser.Cell_clauseContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#cell_clause}.
	 * @param ctx the parse tree
	 */
	void exitCell_clause(Verilog2001Parser.Cell_clauseContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#use_clause}.
	 * @param ctx the parse tree
	 */
	void enterUse_clause(Verilog2001Parser.Use_clauseContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#use_clause}.
	 * @param ctx the parse tree
	 */
	void exitUse_clause(Verilog2001Parser.Use_clauseContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#source_text}.
	 * @param ctx the parse tree
	 */
	void enterSource_text(Verilog2001Parser.Source_textContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#source_text}.
	 * @param ctx the parse tree
	 */
	void exitSource_text(Verilog2001Parser.Source_textContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#description}.
	 * @param ctx the parse tree
	 */
	void enterDescription(Verilog2001Parser.DescriptionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#description}.
	 * @param ctx the parse tree
	 */
	void exitDescription(Verilog2001Parser.DescriptionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_declaration}.
	 * @param ctx the parse tree
	 */
	void enterModule_declaration(Verilog2001Parser.Module_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_declaration}.
	 * @param ctx the parse tree
	 */
	void exitModule_declaration(Verilog2001Parser.Module_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_keyword}.
	 * @param ctx the parse tree
	 */
	void enterModule_keyword(Verilog2001Parser.Module_keywordContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_keyword}.
	 * @param ctx the parse tree
	 */
	void exitModule_keyword(Verilog2001Parser.Module_keywordContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_parameter_port_list}.
	 * @param ctx the parse tree
	 */
	void enterModule_parameter_port_list(Verilog2001Parser.Module_parameter_port_listContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_parameter_port_list}.
	 * @param ctx the parse tree
	 */
	void exitModule_parameter_port_list(Verilog2001Parser.Module_parameter_port_listContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_ports}.
	 * @param ctx the parse tree
	 */
	void enterList_of_ports(Verilog2001Parser.List_of_portsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_ports}.
	 * @param ctx the parse tree
	 */
	void exitList_of_ports(Verilog2001Parser.List_of_portsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_port_declarations}.
	 * @param ctx the parse tree
	 */
	void enterList_of_port_declarations(Verilog2001Parser.List_of_port_declarationsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_port_declarations}.
	 * @param ctx the parse tree
	 */
	void exitList_of_port_declarations(Verilog2001Parser.List_of_port_declarationsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#port}.
	 * @param ctx the parse tree
	 */
	void enterPort(Verilog2001Parser.PortContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#port}.
	 * @param ctx the parse tree
	 */
	void exitPort(Verilog2001Parser.PortContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#port_expression}.
	 * @param ctx the parse tree
	 */
	void enterPort_expression(Verilog2001Parser.Port_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#port_expression}.
	 * @param ctx the parse tree
	 */
	void exitPort_expression(Verilog2001Parser.Port_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#port_reference}.
	 * @param ctx the parse tree
	 */
	void enterPort_reference(Verilog2001Parser.Port_referenceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#port_reference}.
	 * @param ctx the parse tree
	 */
	void exitPort_reference(Verilog2001Parser.Port_referenceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#port_declaration}.
	 * @param ctx the parse tree
	 */
	void enterPort_declaration(Verilog2001Parser.Port_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#port_declaration}.
	 * @param ctx the parse tree
	 */
	void exitPort_declaration(Verilog2001Parser.Port_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_item}.
	 * @param ctx the parse tree
	 */
	void enterModule_item(Verilog2001Parser.Module_itemContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_item}.
	 * @param ctx the parse tree
	 */
	void exitModule_item(Verilog2001Parser.Module_itemContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_or_generate_item}.
	 * @param ctx the parse tree
	 */
	void enterModule_or_generate_item(Verilog2001Parser.Module_or_generate_itemContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_or_generate_item}.
	 * @param ctx the parse tree
	 */
	void exitModule_or_generate_item(Verilog2001Parser.Module_or_generate_itemContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#non_port_module_item}.
	 * @param ctx the parse tree
	 */
	void enterNon_port_module_item(Verilog2001Parser.Non_port_module_itemContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#non_port_module_item}.
	 * @param ctx the parse tree
	 */
	void exitNon_port_module_item(Verilog2001Parser.Non_port_module_itemContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_or_generate_item_declaration}.
	 * @param ctx the parse tree
	 */
	void enterModule_or_generate_item_declaration(Verilog2001Parser.Module_or_generate_item_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_or_generate_item_declaration}.
	 * @param ctx the parse tree
	 */
	void exitModule_or_generate_item_declaration(Verilog2001Parser.Module_or_generate_item_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#parameter_override}.
	 * @param ctx the parse tree
	 */
	void enterParameter_override(Verilog2001Parser.Parameter_overrideContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#parameter_override}.
	 * @param ctx the parse tree
	 */
	void exitParameter_override(Verilog2001Parser.Parameter_overrideContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#local_parameter_declaration}.
	 * @param ctx the parse tree
	 */
	void enterLocal_parameter_declaration(Verilog2001Parser.Local_parameter_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#local_parameter_declaration}.
	 * @param ctx the parse tree
	 */
	void exitLocal_parameter_declaration(Verilog2001Parser.Local_parameter_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#parameter_declaration}.
	 * @param ctx the parse tree
	 */
	void enterParameter_declaration(Verilog2001Parser.Parameter_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#parameter_declaration}.
	 * @param ctx the parse tree
	 */
	void exitParameter_declaration(Verilog2001Parser.Parameter_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#parameter_declaration_}.
	 * @param ctx the parse tree
	 */
	void enterParameter_declaration_(Verilog2001Parser.Parameter_declaration_Context ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#parameter_declaration_}.
	 * @param ctx the parse tree
	 */
	void exitParameter_declaration_(Verilog2001Parser.Parameter_declaration_Context ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#specparam_declaration}.
	 * @param ctx the parse tree
	 */
	void enterSpecparam_declaration(Verilog2001Parser.Specparam_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#specparam_declaration}.
	 * @param ctx the parse tree
	 */
	void exitSpecparam_declaration(Verilog2001Parser.Specparam_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#inout_declaration}.
	 * @param ctx the parse tree
	 */
	void enterInout_declaration(Verilog2001Parser.Inout_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#inout_declaration}.
	 * @param ctx the parse tree
	 */
	void exitInout_declaration(Verilog2001Parser.Inout_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#input_declaration}.
	 * @param ctx the parse tree
	 */
	void enterInput_declaration(Verilog2001Parser.Input_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#input_declaration}.
	 * @param ctx the parse tree
	 */
	void exitInput_declaration(Verilog2001Parser.Input_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#output_declaration}.
	 * @param ctx the parse tree
	 */
	void enterOutput_declaration(Verilog2001Parser.Output_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#output_declaration}.
	 * @param ctx the parse tree
	 */
	void exitOutput_declaration(Verilog2001Parser.Output_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#event_declaration}.
	 * @param ctx the parse tree
	 */
	void enterEvent_declaration(Verilog2001Parser.Event_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#event_declaration}.
	 * @param ctx the parse tree
	 */
	void exitEvent_declaration(Verilog2001Parser.Event_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#genvar_declaration}.
	 * @param ctx the parse tree
	 */
	void enterGenvar_declaration(Verilog2001Parser.Genvar_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#genvar_declaration}.
	 * @param ctx the parse tree
	 */
	void exitGenvar_declaration(Verilog2001Parser.Genvar_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#integer_declaration}.
	 * @param ctx the parse tree
	 */
	void enterInteger_declaration(Verilog2001Parser.Integer_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#integer_declaration}.
	 * @param ctx the parse tree
	 */
	void exitInteger_declaration(Verilog2001Parser.Integer_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#time_declaration}.
	 * @param ctx the parse tree
	 */
	void enterTime_declaration(Verilog2001Parser.Time_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#time_declaration}.
	 * @param ctx the parse tree
	 */
	void exitTime_declaration(Verilog2001Parser.Time_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#real_declaration}.
	 * @param ctx the parse tree
	 */
	void enterReal_declaration(Verilog2001Parser.Real_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#real_declaration}.
	 * @param ctx the parse tree
	 */
	void exitReal_declaration(Verilog2001Parser.Real_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#realtime_declaration}.
	 * @param ctx the parse tree
	 */
	void enterRealtime_declaration(Verilog2001Parser.Realtime_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#realtime_declaration}.
	 * @param ctx the parse tree
	 */
	void exitRealtime_declaration(Verilog2001Parser.Realtime_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#reg_declaration}.
	 * @param ctx the parse tree
	 */
	void enterReg_declaration(Verilog2001Parser.Reg_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#reg_declaration}.
	 * @param ctx the parse tree
	 */
	void exitReg_declaration(Verilog2001Parser.Reg_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#net_declaration}.
	 * @param ctx the parse tree
	 */
	void enterNet_declaration(Verilog2001Parser.Net_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#net_declaration}.
	 * @param ctx the parse tree
	 */
	void exitNet_declaration(Verilog2001Parser.Net_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#net_type}.
	 * @param ctx the parse tree
	 */
	void enterNet_type(Verilog2001Parser.Net_typeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#net_type}.
	 * @param ctx the parse tree
	 */
	void exitNet_type(Verilog2001Parser.Net_typeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#output_variable_type}.
	 * @param ctx the parse tree
	 */
	void enterOutput_variable_type(Verilog2001Parser.Output_variable_typeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#output_variable_type}.
	 * @param ctx the parse tree
	 */
	void exitOutput_variable_type(Verilog2001Parser.Output_variable_typeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#real_type}.
	 * @param ctx the parse tree
	 */
	void enterReal_type(Verilog2001Parser.Real_typeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#real_type}.
	 * @param ctx the parse tree
	 */
	void exitReal_type(Verilog2001Parser.Real_typeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#variable_type}.
	 * @param ctx the parse tree
	 */
	void enterVariable_type(Verilog2001Parser.Variable_typeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#variable_type}.
	 * @param ctx the parse tree
	 */
	void exitVariable_type(Verilog2001Parser.Variable_typeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#drive_strength}.
	 * @param ctx the parse tree
	 */
	void enterDrive_strength(Verilog2001Parser.Drive_strengthContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#drive_strength}.
	 * @param ctx the parse tree
	 */
	void exitDrive_strength(Verilog2001Parser.Drive_strengthContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#strength0}.
	 * @param ctx the parse tree
	 */
	void enterStrength0(Verilog2001Parser.Strength0Context ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#strength0}.
	 * @param ctx the parse tree
	 */
	void exitStrength0(Verilog2001Parser.Strength0Context ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#strength1}.
	 * @param ctx the parse tree
	 */
	void enterStrength1(Verilog2001Parser.Strength1Context ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#strength1}.
	 * @param ctx the parse tree
	 */
	void exitStrength1(Verilog2001Parser.Strength1Context ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#charge_strength}.
	 * @param ctx the parse tree
	 */
	void enterCharge_strength(Verilog2001Parser.Charge_strengthContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#charge_strength}.
	 * @param ctx the parse tree
	 */
	void exitCharge_strength(Verilog2001Parser.Charge_strengthContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#delay3}.
	 * @param ctx the parse tree
	 */
	void enterDelay3(Verilog2001Parser.Delay3Context ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#delay3}.
	 * @param ctx the parse tree
	 */
	void exitDelay3(Verilog2001Parser.Delay3Context ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#delay2}.
	 * @param ctx the parse tree
	 */
	void enterDelay2(Verilog2001Parser.Delay2Context ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#delay2}.
	 * @param ctx the parse tree
	 */
	void exitDelay2(Verilog2001Parser.Delay2Context ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#delay_value}.
	 * @param ctx the parse tree
	 */
	void enterDelay_value(Verilog2001Parser.Delay_valueContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#delay_value}.
	 * @param ctx the parse tree
	 */
	void exitDelay_value(Verilog2001Parser.Delay_valueContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_event_identifiers}.
	 * @param ctx the parse tree
	 */
	void enterList_of_event_identifiers(Verilog2001Parser.List_of_event_identifiersContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_event_identifiers}.
	 * @param ctx the parse tree
	 */
	void exitList_of_event_identifiers(Verilog2001Parser.List_of_event_identifiersContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_net_identifiers}.
	 * @param ctx the parse tree
	 */
	void enterList_of_net_identifiers(Verilog2001Parser.List_of_net_identifiersContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_net_identifiers}.
	 * @param ctx the parse tree
	 */
	void exitList_of_net_identifiers(Verilog2001Parser.List_of_net_identifiersContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_genvar_identifiers}.
	 * @param ctx the parse tree
	 */
	void enterList_of_genvar_identifiers(Verilog2001Parser.List_of_genvar_identifiersContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_genvar_identifiers}.
	 * @param ctx the parse tree
	 */
	void exitList_of_genvar_identifiers(Verilog2001Parser.List_of_genvar_identifiersContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_port_identifiers}.
	 * @param ctx the parse tree
	 */
	void enterList_of_port_identifiers(Verilog2001Parser.List_of_port_identifiersContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_port_identifiers}.
	 * @param ctx the parse tree
	 */
	void exitList_of_port_identifiers(Verilog2001Parser.List_of_port_identifiersContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_net_decl_assignments}.
	 * @param ctx the parse tree
	 */
	void enterList_of_net_decl_assignments(Verilog2001Parser.List_of_net_decl_assignmentsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_net_decl_assignments}.
	 * @param ctx the parse tree
	 */
	void exitList_of_net_decl_assignments(Verilog2001Parser.List_of_net_decl_assignmentsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_param_assignments}.
	 * @param ctx the parse tree
	 */
	void enterList_of_param_assignments(Verilog2001Parser.List_of_param_assignmentsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_param_assignments}.
	 * @param ctx the parse tree
	 */
	void exitList_of_param_assignments(Verilog2001Parser.List_of_param_assignmentsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_specparam_assignments}.
	 * @param ctx the parse tree
	 */
	void enterList_of_specparam_assignments(Verilog2001Parser.List_of_specparam_assignmentsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_specparam_assignments}.
	 * @param ctx the parse tree
	 */
	void exitList_of_specparam_assignments(Verilog2001Parser.List_of_specparam_assignmentsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_real_identifiers}.
	 * @param ctx the parse tree
	 */
	void enterList_of_real_identifiers(Verilog2001Parser.List_of_real_identifiersContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_real_identifiers}.
	 * @param ctx the parse tree
	 */
	void exitList_of_real_identifiers(Verilog2001Parser.List_of_real_identifiersContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_variable_identifiers}.
	 * @param ctx the parse tree
	 */
	void enterList_of_variable_identifiers(Verilog2001Parser.List_of_variable_identifiersContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_variable_identifiers}.
	 * @param ctx the parse tree
	 */
	void exitList_of_variable_identifiers(Verilog2001Parser.List_of_variable_identifiersContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_variable_port_identifiers}.
	 * @param ctx the parse tree
	 */
	void enterList_of_variable_port_identifiers(Verilog2001Parser.List_of_variable_port_identifiersContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_variable_port_identifiers}.
	 * @param ctx the parse tree
	 */
	void exitList_of_variable_port_identifiers(Verilog2001Parser.List_of_variable_port_identifiersContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#net_decl_assignment}.
	 * @param ctx the parse tree
	 */
	void enterNet_decl_assignment(Verilog2001Parser.Net_decl_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#net_decl_assignment}.
	 * @param ctx the parse tree
	 */
	void exitNet_decl_assignment(Verilog2001Parser.Net_decl_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#param_assignment}.
	 * @param ctx the parse tree
	 */
	void enterParam_assignment(Verilog2001Parser.Param_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#param_assignment}.
	 * @param ctx the parse tree
	 */
	void exitParam_assignment(Verilog2001Parser.Param_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#specparam_assignment}.
	 * @param ctx the parse tree
	 */
	void enterSpecparam_assignment(Verilog2001Parser.Specparam_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#specparam_assignment}.
	 * @param ctx the parse tree
	 */
	void exitSpecparam_assignment(Verilog2001Parser.Specparam_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#pulse_control_specparam}.
	 * @param ctx the parse tree
	 */
	void enterPulse_control_specparam(Verilog2001Parser.Pulse_control_specparamContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#pulse_control_specparam}.
	 * @param ctx the parse tree
	 */
	void exitPulse_control_specparam(Verilog2001Parser.Pulse_control_specparamContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#error_limit_value}.
	 * @param ctx the parse tree
	 */
	void enterError_limit_value(Verilog2001Parser.Error_limit_valueContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#error_limit_value}.
	 * @param ctx the parse tree
	 */
	void exitError_limit_value(Verilog2001Parser.Error_limit_valueContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#reject_limit_value}.
	 * @param ctx the parse tree
	 */
	void enterReject_limit_value(Verilog2001Parser.Reject_limit_valueContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#reject_limit_value}.
	 * @param ctx the parse tree
	 */
	void exitReject_limit_value(Verilog2001Parser.Reject_limit_valueContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#limit_value}.
	 * @param ctx the parse tree
	 */
	void enterLimit_value(Verilog2001Parser.Limit_valueContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#limit_value}.
	 * @param ctx the parse tree
	 */
	void exitLimit_value(Verilog2001Parser.Limit_valueContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#dimension}.
	 * @param ctx the parse tree
	 */
	void enterDimension(Verilog2001Parser.DimensionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#dimension}.
	 * @param ctx the parse tree
	 */
	void exitDimension(Verilog2001Parser.DimensionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#range_}.
	 * @param ctx the parse tree
	 */
	void enterRange_(Verilog2001Parser.Range_Context ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#range_}.
	 * @param ctx the parse tree
	 */
	void exitRange_(Verilog2001Parser.Range_Context ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_declaration}.
	 * @param ctx the parse tree
	 */
	void enterFunction_declaration(Verilog2001Parser.Function_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_declaration}.
	 * @param ctx the parse tree
	 */
	void exitFunction_declaration(Verilog2001Parser.Function_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_item_declaration}.
	 * @param ctx the parse tree
	 */
	void enterFunction_item_declaration(Verilog2001Parser.Function_item_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_item_declaration}.
	 * @param ctx the parse tree
	 */
	void exitFunction_item_declaration(Verilog2001Parser.Function_item_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_port_list}.
	 * @param ctx the parse tree
	 */
	void enterFunction_port_list(Verilog2001Parser.Function_port_listContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_port_list}.
	 * @param ctx the parse tree
	 */
	void exitFunction_port_list(Verilog2001Parser.Function_port_listContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_port}.
	 * @param ctx the parse tree
	 */
	void enterFunction_port(Verilog2001Parser.Function_portContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_port}.
	 * @param ctx the parse tree
	 */
	void exitFunction_port(Verilog2001Parser.Function_portContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#range_or_type}.
	 * @param ctx the parse tree
	 */
	void enterRange_or_type(Verilog2001Parser.Range_or_typeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#range_or_type}.
	 * @param ctx the parse tree
	 */
	void exitRange_or_type(Verilog2001Parser.Range_or_typeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#task_declaration}.
	 * @param ctx the parse tree
	 */
	void enterTask_declaration(Verilog2001Parser.Task_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#task_declaration}.
	 * @param ctx the parse tree
	 */
	void exitTask_declaration(Verilog2001Parser.Task_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#task_item_declaration}.
	 * @param ctx the parse tree
	 */
	void enterTask_item_declaration(Verilog2001Parser.Task_item_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#task_item_declaration}.
	 * @param ctx the parse tree
	 */
	void exitTask_item_declaration(Verilog2001Parser.Task_item_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#task_port_list}.
	 * @param ctx the parse tree
	 */
	void enterTask_port_list(Verilog2001Parser.Task_port_listContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#task_port_list}.
	 * @param ctx the parse tree
	 */
	void exitTask_port_list(Verilog2001Parser.Task_port_listContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#task_port_item}.
	 * @param ctx the parse tree
	 */
	void enterTask_port_item(Verilog2001Parser.Task_port_itemContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#task_port_item}.
	 * @param ctx the parse tree
	 */
	void exitTask_port_item(Verilog2001Parser.Task_port_itemContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#tf_decl_header}.
	 * @param ctx the parse tree
	 */
	void enterTf_decl_header(Verilog2001Parser.Tf_decl_headerContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#tf_decl_header}.
	 * @param ctx the parse tree
	 */
	void exitTf_decl_header(Verilog2001Parser.Tf_decl_headerContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#tf_declaration}.
	 * @param ctx the parse tree
	 */
	void enterTf_declaration(Verilog2001Parser.Tf_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#tf_declaration}.
	 * @param ctx the parse tree
	 */
	void exitTf_declaration(Verilog2001Parser.Tf_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#task_port_type}.
	 * @param ctx the parse tree
	 */
	void enterTask_port_type(Verilog2001Parser.Task_port_typeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#task_port_type}.
	 * @param ctx the parse tree
	 */
	void exitTask_port_type(Verilog2001Parser.Task_port_typeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#block_item_declaration}.
	 * @param ctx the parse tree
	 */
	void enterBlock_item_declaration(Verilog2001Parser.Block_item_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#block_item_declaration}.
	 * @param ctx the parse tree
	 */
	void exitBlock_item_declaration(Verilog2001Parser.Block_item_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#block_reg_declaration}.
	 * @param ctx the parse tree
	 */
	void enterBlock_reg_declaration(Verilog2001Parser.Block_reg_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#block_reg_declaration}.
	 * @param ctx the parse tree
	 */
	void exitBlock_reg_declaration(Verilog2001Parser.Block_reg_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_block_variable_identifiers}.
	 * @param ctx the parse tree
	 */
	void enterList_of_block_variable_identifiers(Verilog2001Parser.List_of_block_variable_identifiersContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_block_variable_identifiers}.
	 * @param ctx the parse tree
	 */
	void exitList_of_block_variable_identifiers(Verilog2001Parser.List_of_block_variable_identifiersContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#block_variable_type}.
	 * @param ctx the parse tree
	 */
	void enterBlock_variable_type(Verilog2001Parser.Block_variable_typeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#block_variable_type}.
	 * @param ctx the parse tree
	 */
	void exitBlock_variable_type(Verilog2001Parser.Block_variable_typeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#gate_instantiation}.
	 * @param ctx the parse tree
	 */
	void enterGate_instantiation(Verilog2001Parser.Gate_instantiationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#gate_instantiation}.
	 * @param ctx the parse tree
	 */
	void exitGate_instantiation(Verilog2001Parser.Gate_instantiationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#cmos_switch_instance}.
	 * @param ctx the parse tree
	 */
	void enterCmos_switch_instance(Verilog2001Parser.Cmos_switch_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#cmos_switch_instance}.
	 * @param ctx the parse tree
	 */
	void exitCmos_switch_instance(Verilog2001Parser.Cmos_switch_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#enable_gate_instance}.
	 * @param ctx the parse tree
	 */
	void enterEnable_gate_instance(Verilog2001Parser.Enable_gate_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#enable_gate_instance}.
	 * @param ctx the parse tree
	 */
	void exitEnable_gate_instance(Verilog2001Parser.Enable_gate_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#mos_switch_instance}.
	 * @param ctx the parse tree
	 */
	void enterMos_switch_instance(Verilog2001Parser.Mos_switch_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#mos_switch_instance}.
	 * @param ctx the parse tree
	 */
	void exitMos_switch_instance(Verilog2001Parser.Mos_switch_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#n_input_gate_instance}.
	 * @param ctx the parse tree
	 */
	void enterN_input_gate_instance(Verilog2001Parser.N_input_gate_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#n_input_gate_instance}.
	 * @param ctx the parse tree
	 */
	void exitN_input_gate_instance(Verilog2001Parser.N_input_gate_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#n_output_gate_instance}.
	 * @param ctx the parse tree
	 */
	void enterN_output_gate_instance(Verilog2001Parser.N_output_gate_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#n_output_gate_instance}.
	 * @param ctx the parse tree
	 */
	void exitN_output_gate_instance(Verilog2001Parser.N_output_gate_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#pass_switch_instance}.
	 * @param ctx the parse tree
	 */
	void enterPass_switch_instance(Verilog2001Parser.Pass_switch_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#pass_switch_instance}.
	 * @param ctx the parse tree
	 */
	void exitPass_switch_instance(Verilog2001Parser.Pass_switch_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#pass_enable_switch_instance}.
	 * @param ctx the parse tree
	 */
	void enterPass_enable_switch_instance(Verilog2001Parser.Pass_enable_switch_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#pass_enable_switch_instance}.
	 * @param ctx the parse tree
	 */
	void exitPass_enable_switch_instance(Verilog2001Parser.Pass_enable_switch_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#pull_gate_instance}.
	 * @param ctx the parse tree
	 */
	void enterPull_gate_instance(Verilog2001Parser.Pull_gate_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#pull_gate_instance}.
	 * @param ctx the parse tree
	 */
	void exitPull_gate_instance(Verilog2001Parser.Pull_gate_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#name_of_gate_instance}.
	 * @param ctx the parse tree
	 */
	void enterName_of_gate_instance(Verilog2001Parser.Name_of_gate_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#name_of_gate_instance}.
	 * @param ctx the parse tree
	 */
	void exitName_of_gate_instance(Verilog2001Parser.Name_of_gate_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#pulldown_strength}.
	 * @param ctx the parse tree
	 */
	void enterPulldown_strength(Verilog2001Parser.Pulldown_strengthContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#pulldown_strength}.
	 * @param ctx the parse tree
	 */
	void exitPulldown_strength(Verilog2001Parser.Pulldown_strengthContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#pullup_strength}.
	 * @param ctx the parse tree
	 */
	void enterPullup_strength(Verilog2001Parser.Pullup_strengthContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#pullup_strength}.
	 * @param ctx the parse tree
	 */
	void exitPullup_strength(Verilog2001Parser.Pullup_strengthContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#enable_terminal}.
	 * @param ctx the parse tree
	 */
	void enterEnable_terminal(Verilog2001Parser.Enable_terminalContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#enable_terminal}.
	 * @param ctx the parse tree
	 */
	void exitEnable_terminal(Verilog2001Parser.Enable_terminalContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#ncontrol_terminal}.
	 * @param ctx the parse tree
	 */
	void enterNcontrol_terminal(Verilog2001Parser.Ncontrol_terminalContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#ncontrol_terminal}.
	 * @param ctx the parse tree
	 */
	void exitNcontrol_terminal(Verilog2001Parser.Ncontrol_terminalContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#pcontrol_terminal}.
	 * @param ctx the parse tree
	 */
	void enterPcontrol_terminal(Verilog2001Parser.Pcontrol_terminalContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#pcontrol_terminal}.
	 * @param ctx the parse tree
	 */
	void exitPcontrol_terminal(Verilog2001Parser.Pcontrol_terminalContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#input_terminal}.
	 * @param ctx the parse tree
	 */
	void enterInput_terminal(Verilog2001Parser.Input_terminalContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#input_terminal}.
	 * @param ctx the parse tree
	 */
	void exitInput_terminal(Verilog2001Parser.Input_terminalContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#inout_terminal}.
	 * @param ctx the parse tree
	 */
	void enterInout_terminal(Verilog2001Parser.Inout_terminalContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#inout_terminal}.
	 * @param ctx the parse tree
	 */
	void exitInout_terminal(Verilog2001Parser.Inout_terminalContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#output_terminal}.
	 * @param ctx the parse tree
	 */
	void enterOutput_terminal(Verilog2001Parser.Output_terminalContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#output_terminal}.
	 * @param ctx the parse tree
	 */
	void exitOutput_terminal(Verilog2001Parser.Output_terminalContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#cmos_switchtype}.
	 * @param ctx the parse tree
	 */
	void enterCmos_switchtype(Verilog2001Parser.Cmos_switchtypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#cmos_switchtype}.
	 * @param ctx the parse tree
	 */
	void exitCmos_switchtype(Verilog2001Parser.Cmos_switchtypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#enable_gatetype}.
	 * @param ctx the parse tree
	 */
	void enterEnable_gatetype(Verilog2001Parser.Enable_gatetypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#enable_gatetype}.
	 * @param ctx the parse tree
	 */
	void exitEnable_gatetype(Verilog2001Parser.Enable_gatetypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#mos_switchtype}.
	 * @param ctx the parse tree
	 */
	void enterMos_switchtype(Verilog2001Parser.Mos_switchtypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#mos_switchtype}.
	 * @param ctx the parse tree
	 */
	void exitMos_switchtype(Verilog2001Parser.Mos_switchtypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#n_input_gatetype}.
	 * @param ctx the parse tree
	 */
	void enterN_input_gatetype(Verilog2001Parser.N_input_gatetypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#n_input_gatetype}.
	 * @param ctx the parse tree
	 */
	void exitN_input_gatetype(Verilog2001Parser.N_input_gatetypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#n_output_gatetype}.
	 * @param ctx the parse tree
	 */
	void enterN_output_gatetype(Verilog2001Parser.N_output_gatetypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#n_output_gatetype}.
	 * @param ctx the parse tree
	 */
	void exitN_output_gatetype(Verilog2001Parser.N_output_gatetypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#pass_en_switchtype}.
	 * @param ctx the parse tree
	 */
	void enterPass_en_switchtype(Verilog2001Parser.Pass_en_switchtypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#pass_en_switchtype}.
	 * @param ctx the parse tree
	 */
	void exitPass_en_switchtype(Verilog2001Parser.Pass_en_switchtypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#pass_switchtype}.
	 * @param ctx the parse tree
	 */
	void enterPass_switchtype(Verilog2001Parser.Pass_switchtypeContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#pass_switchtype}.
	 * @param ctx the parse tree
	 */
	void exitPass_switchtype(Verilog2001Parser.Pass_switchtypeContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_instantiation}.
	 * @param ctx the parse tree
	 */
	void enterModule_instantiation(Verilog2001Parser.Module_instantiationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_instantiation}.
	 * @param ctx the parse tree
	 */
	void exitModule_instantiation(Verilog2001Parser.Module_instantiationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#parameter_value_assignment}.
	 * @param ctx the parse tree
	 */
	void enterParameter_value_assignment(Verilog2001Parser.Parameter_value_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#parameter_value_assignment}.
	 * @param ctx the parse tree
	 */
	void exitParameter_value_assignment(Verilog2001Parser.Parameter_value_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_parameter_assignments}.
	 * @param ctx the parse tree
	 */
	void enterList_of_parameter_assignments(Verilog2001Parser.List_of_parameter_assignmentsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_parameter_assignments}.
	 * @param ctx the parse tree
	 */
	void exitList_of_parameter_assignments(Verilog2001Parser.List_of_parameter_assignmentsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#ordered_parameter_assignment}.
	 * @param ctx the parse tree
	 */
	void enterOrdered_parameter_assignment(Verilog2001Parser.Ordered_parameter_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#ordered_parameter_assignment}.
	 * @param ctx the parse tree
	 */
	void exitOrdered_parameter_assignment(Verilog2001Parser.Ordered_parameter_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#named_parameter_assignment}.
	 * @param ctx the parse tree
	 */
	void enterNamed_parameter_assignment(Verilog2001Parser.Named_parameter_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#named_parameter_assignment}.
	 * @param ctx the parse tree
	 */
	void exitNamed_parameter_assignment(Verilog2001Parser.Named_parameter_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_instance}.
	 * @param ctx the parse tree
	 */
	void enterModule_instance(Verilog2001Parser.Module_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_instance}.
	 * @param ctx the parse tree
	 */
	void exitModule_instance(Verilog2001Parser.Module_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#name_of_instance}.
	 * @param ctx the parse tree
	 */
	void enterName_of_instance(Verilog2001Parser.Name_of_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#name_of_instance}.
	 * @param ctx the parse tree
	 */
	void exitName_of_instance(Verilog2001Parser.Name_of_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_port_connections}.
	 * @param ctx the parse tree
	 */
	void enterList_of_port_connections(Verilog2001Parser.List_of_port_connectionsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_port_connections}.
	 * @param ctx the parse tree
	 */
	void exitList_of_port_connections(Verilog2001Parser.List_of_port_connectionsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#ordered_port_connection}.
	 * @param ctx the parse tree
	 */
	void enterOrdered_port_connection(Verilog2001Parser.Ordered_port_connectionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#ordered_port_connection}.
	 * @param ctx the parse tree
	 */
	void exitOrdered_port_connection(Verilog2001Parser.Ordered_port_connectionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#named_port_connection}.
	 * @param ctx the parse tree
	 */
	void enterNamed_port_connection(Verilog2001Parser.Named_port_connectionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#named_port_connection}.
	 * @param ctx the parse tree
	 */
	void exitNamed_port_connection(Verilog2001Parser.Named_port_connectionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#generated_instantiation}.
	 * @param ctx the parse tree
	 */
	void enterGenerated_instantiation(Verilog2001Parser.Generated_instantiationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#generated_instantiation}.
	 * @param ctx the parse tree
	 */
	void exitGenerated_instantiation(Verilog2001Parser.Generated_instantiationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#generate_item_or_null}.
	 * @param ctx the parse tree
	 */
	void enterGenerate_item_or_null(Verilog2001Parser.Generate_item_or_nullContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#generate_item_or_null}.
	 * @param ctx the parse tree
	 */
	void exitGenerate_item_or_null(Verilog2001Parser.Generate_item_or_nullContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#generate_item}.
	 * @param ctx the parse tree
	 */
	void enterGenerate_item(Verilog2001Parser.Generate_itemContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#generate_item}.
	 * @param ctx the parse tree
	 */
	void exitGenerate_item(Verilog2001Parser.Generate_itemContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#generate_conditional_statement}.
	 * @param ctx the parse tree
	 */
	void enterGenerate_conditional_statement(Verilog2001Parser.Generate_conditional_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#generate_conditional_statement}.
	 * @param ctx the parse tree
	 */
	void exitGenerate_conditional_statement(Verilog2001Parser.Generate_conditional_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#generate_case_statement}.
	 * @param ctx the parse tree
	 */
	void enterGenerate_case_statement(Verilog2001Parser.Generate_case_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#generate_case_statement}.
	 * @param ctx the parse tree
	 */
	void exitGenerate_case_statement(Verilog2001Parser.Generate_case_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#genvar_case_item}.
	 * @param ctx the parse tree
	 */
	void enterGenvar_case_item(Verilog2001Parser.Genvar_case_itemContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#genvar_case_item}.
	 * @param ctx the parse tree
	 */
	void exitGenvar_case_item(Verilog2001Parser.Genvar_case_itemContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#generate_loop_statement}.
	 * @param ctx the parse tree
	 */
	void enterGenerate_loop_statement(Verilog2001Parser.Generate_loop_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#generate_loop_statement}.
	 * @param ctx the parse tree
	 */
	void exitGenerate_loop_statement(Verilog2001Parser.Generate_loop_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#genvar_assignment}.
	 * @param ctx the parse tree
	 */
	void enterGenvar_assignment(Verilog2001Parser.Genvar_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#genvar_assignment}.
	 * @param ctx the parse tree
	 */
	void exitGenvar_assignment(Verilog2001Parser.Genvar_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#generate_block}.
	 * @param ctx the parse tree
	 */
	void enterGenerate_block(Verilog2001Parser.Generate_blockContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#generate_block}.
	 * @param ctx the parse tree
	 */
	void exitGenerate_block(Verilog2001Parser.Generate_blockContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#continuous_assign}.
	 * @param ctx the parse tree
	 */
	void enterContinuous_assign(Verilog2001Parser.Continuous_assignContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#continuous_assign}.
	 * @param ctx the parse tree
	 */
	void exitContinuous_assign(Verilog2001Parser.Continuous_assignContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_net_assignments}.
	 * @param ctx the parse tree
	 */
	void enterList_of_net_assignments(Verilog2001Parser.List_of_net_assignmentsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_net_assignments}.
	 * @param ctx the parse tree
	 */
	void exitList_of_net_assignments(Verilog2001Parser.List_of_net_assignmentsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#net_assignment}.
	 * @param ctx the parse tree
	 */
	void enterNet_assignment(Verilog2001Parser.Net_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#net_assignment}.
	 * @param ctx the parse tree
	 */
	void exitNet_assignment(Verilog2001Parser.Net_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#initial_construct}.
	 * @param ctx the parse tree
	 */
	void enterInitial_construct(Verilog2001Parser.Initial_constructContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#initial_construct}.
	 * @param ctx the parse tree
	 */
	void exitInitial_construct(Verilog2001Parser.Initial_constructContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#always_construct}.
	 * @param ctx the parse tree
	 */
	void enterAlways_construct(Verilog2001Parser.Always_constructContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#always_construct}.
	 * @param ctx the parse tree
	 */
	void exitAlways_construct(Verilog2001Parser.Always_constructContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#blocking_assignment}.
	 * @param ctx the parse tree
	 */
	void enterBlocking_assignment(Verilog2001Parser.Blocking_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#blocking_assignment}.
	 * @param ctx the parse tree
	 */
	void exitBlocking_assignment(Verilog2001Parser.Blocking_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#nonblocking_assignment}.
	 * @param ctx the parse tree
	 */
	void enterNonblocking_assignment(Verilog2001Parser.Nonblocking_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#nonblocking_assignment}.
	 * @param ctx the parse tree
	 */
	void exitNonblocking_assignment(Verilog2001Parser.Nonblocking_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#procedural_continuous_assignments}.
	 * @param ctx the parse tree
	 */
	void enterProcedural_continuous_assignments(Verilog2001Parser.Procedural_continuous_assignmentsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#procedural_continuous_assignments}.
	 * @param ctx the parse tree
	 */
	void exitProcedural_continuous_assignments(Verilog2001Parser.Procedural_continuous_assignmentsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_blocking_assignment}.
	 * @param ctx the parse tree
	 */
	void enterFunction_blocking_assignment(Verilog2001Parser.Function_blocking_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_blocking_assignment}.
	 * @param ctx the parse tree
	 */
	void exitFunction_blocking_assignment(Verilog2001Parser.Function_blocking_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_statement_or_null}.
	 * @param ctx the parse tree
	 */
	void enterFunction_statement_or_null(Verilog2001Parser.Function_statement_or_nullContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_statement_or_null}.
	 * @param ctx the parse tree
	 */
	void exitFunction_statement_or_null(Verilog2001Parser.Function_statement_or_nullContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_seq_block}.
	 * @param ctx the parse tree
	 */
	void enterFunction_seq_block(Verilog2001Parser.Function_seq_blockContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_seq_block}.
	 * @param ctx the parse tree
	 */
	void exitFunction_seq_block(Verilog2001Parser.Function_seq_blockContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#variable_assignment}.
	 * @param ctx the parse tree
	 */
	void enterVariable_assignment(Verilog2001Parser.Variable_assignmentContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#variable_assignment}.
	 * @param ctx the parse tree
	 */
	void exitVariable_assignment(Verilog2001Parser.Variable_assignmentContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#par_block}.
	 * @param ctx the parse tree
	 */
	void enterPar_block(Verilog2001Parser.Par_blockContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#par_block}.
	 * @param ctx the parse tree
	 */
	void exitPar_block(Verilog2001Parser.Par_blockContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#seq_block}.
	 * @param ctx the parse tree
	 */
	void enterSeq_block(Verilog2001Parser.Seq_blockContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#seq_block}.
	 * @param ctx the parse tree
	 */
	void exitSeq_block(Verilog2001Parser.Seq_blockContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#statement}.
	 * @param ctx the parse tree
	 */
	void enterStatement(Verilog2001Parser.StatementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#statement}.
	 * @param ctx the parse tree
	 */
	void exitStatement(Verilog2001Parser.StatementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#statement_or_null}.
	 * @param ctx the parse tree
	 */
	void enterStatement_or_null(Verilog2001Parser.Statement_or_nullContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#statement_or_null}.
	 * @param ctx the parse tree
	 */
	void exitStatement_or_null(Verilog2001Parser.Statement_or_nullContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_statement}.
	 * @param ctx the parse tree
	 */
	void enterFunction_statement(Verilog2001Parser.Function_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_statement}.
	 * @param ctx the parse tree
	 */
	void exitFunction_statement(Verilog2001Parser.Function_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#delay_or_event_control}.
	 * @param ctx the parse tree
	 */
	void enterDelay_or_event_control(Verilog2001Parser.Delay_or_event_controlContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#delay_or_event_control}.
	 * @param ctx the parse tree
	 */
	void exitDelay_or_event_control(Verilog2001Parser.Delay_or_event_controlContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#delay_control}.
	 * @param ctx the parse tree
	 */
	void enterDelay_control(Verilog2001Parser.Delay_controlContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#delay_control}.
	 * @param ctx the parse tree
	 */
	void exitDelay_control(Verilog2001Parser.Delay_controlContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#disable_statement}.
	 * @param ctx the parse tree
	 */
	void enterDisable_statement(Verilog2001Parser.Disable_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#disable_statement}.
	 * @param ctx the parse tree
	 */
	void exitDisable_statement(Verilog2001Parser.Disable_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#event_control}.
	 * @param ctx the parse tree
	 */
	void enterEvent_control(Verilog2001Parser.Event_controlContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#event_control}.
	 * @param ctx the parse tree
	 */
	void exitEvent_control(Verilog2001Parser.Event_controlContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#event_trigger}.
	 * @param ctx the parse tree
	 */
	void enterEvent_trigger(Verilog2001Parser.Event_triggerContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#event_trigger}.
	 * @param ctx the parse tree
	 */
	void exitEvent_trigger(Verilog2001Parser.Event_triggerContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#event_expression}.
	 * @param ctx the parse tree
	 */
	void enterEvent_expression(Verilog2001Parser.Event_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#event_expression}.
	 * @param ctx the parse tree
	 */
	void exitEvent_expression(Verilog2001Parser.Event_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#event_primary}.
	 * @param ctx the parse tree
	 */
	void enterEvent_primary(Verilog2001Parser.Event_primaryContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#event_primary}.
	 * @param ctx the parse tree
	 */
	void exitEvent_primary(Verilog2001Parser.Event_primaryContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#procedural_timing_control_statement}.
	 * @param ctx the parse tree
	 */
	void enterProcedural_timing_control_statement(Verilog2001Parser.Procedural_timing_control_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#procedural_timing_control_statement}.
	 * @param ctx the parse tree
	 */
	void exitProcedural_timing_control_statement(Verilog2001Parser.Procedural_timing_control_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#wait_statement}.
	 * @param ctx the parse tree
	 */
	void enterWait_statement(Verilog2001Parser.Wait_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#wait_statement}.
	 * @param ctx the parse tree
	 */
	void exitWait_statement(Verilog2001Parser.Wait_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#conditional_statement}.
	 * @param ctx the parse tree
	 */
	void enterConditional_statement(Verilog2001Parser.Conditional_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#conditional_statement}.
	 * @param ctx the parse tree
	 */
	void exitConditional_statement(Verilog2001Parser.Conditional_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_conditional_statement}.
	 * @param ctx the parse tree
	 */
	void enterFunction_conditional_statement(Verilog2001Parser.Function_conditional_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_conditional_statement}.
	 * @param ctx the parse tree
	 */
	void exitFunction_conditional_statement(Verilog2001Parser.Function_conditional_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_if_else_if_statement}.
	 * @param ctx the parse tree
	 */
	void enterFunction_if_else_if_statement(Verilog2001Parser.Function_if_else_if_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_if_else_if_statement}.
	 * @param ctx the parse tree
	 */
	void exitFunction_if_else_if_statement(Verilog2001Parser.Function_if_else_if_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#case_statement}.
	 * @param ctx the parse tree
	 */
	void enterCase_statement(Verilog2001Parser.Case_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#case_statement}.
	 * @param ctx the parse tree
	 */
	void exitCase_statement(Verilog2001Parser.Case_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#case_item}.
	 * @param ctx the parse tree
	 */
	void enterCase_item(Verilog2001Parser.Case_itemContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#case_item}.
	 * @param ctx the parse tree
	 */
	void exitCase_item(Verilog2001Parser.Case_itemContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_case_statement}.
	 * @param ctx the parse tree
	 */
	void enterFunction_case_statement(Verilog2001Parser.Function_case_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_case_statement}.
	 * @param ctx the parse tree
	 */
	void exitFunction_case_statement(Verilog2001Parser.Function_case_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_case_item}.
	 * @param ctx the parse tree
	 */
	void enterFunction_case_item(Verilog2001Parser.Function_case_itemContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_case_item}.
	 * @param ctx the parse tree
	 */
	void exitFunction_case_item(Verilog2001Parser.Function_case_itemContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_loop_statement}.
	 * @param ctx the parse tree
	 */
	void enterFunction_loop_statement(Verilog2001Parser.Function_loop_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_loop_statement}.
	 * @param ctx the parse tree
	 */
	void exitFunction_loop_statement(Verilog2001Parser.Function_loop_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#loop_statement}.
	 * @param ctx the parse tree
	 */
	void enterLoop_statement(Verilog2001Parser.Loop_statementContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#loop_statement}.
	 * @param ctx the parse tree
	 */
	void exitLoop_statement(Verilog2001Parser.Loop_statementContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#system_task_enable}.
	 * @param ctx the parse tree
	 */
	void enterSystem_task_enable(Verilog2001Parser.System_task_enableContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#system_task_enable}.
	 * @param ctx the parse tree
	 */
	void exitSystem_task_enable(Verilog2001Parser.System_task_enableContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#task_enable}.
	 * @param ctx the parse tree
	 */
	void enterTask_enable(Verilog2001Parser.Task_enableContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#task_enable}.
	 * @param ctx the parse tree
	 */
	void exitTask_enable(Verilog2001Parser.Task_enableContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#specify_block}.
	 * @param ctx the parse tree
	 */
	void enterSpecify_block(Verilog2001Parser.Specify_blockContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#specify_block}.
	 * @param ctx the parse tree
	 */
	void exitSpecify_block(Verilog2001Parser.Specify_blockContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#specify_item}.
	 * @param ctx the parse tree
	 */
	void enterSpecify_item(Verilog2001Parser.Specify_itemContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#specify_item}.
	 * @param ctx the parse tree
	 */
	void exitSpecify_item(Verilog2001Parser.Specify_itemContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#pulsestyle_declaration}.
	 * @param ctx the parse tree
	 */
	void enterPulsestyle_declaration(Verilog2001Parser.Pulsestyle_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#pulsestyle_declaration}.
	 * @param ctx the parse tree
	 */
	void exitPulsestyle_declaration(Verilog2001Parser.Pulsestyle_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#showcancelled_declaration}.
	 * @param ctx the parse tree
	 */
	void enterShowcancelled_declaration(Verilog2001Parser.Showcancelled_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#showcancelled_declaration}.
	 * @param ctx the parse tree
	 */
	void exitShowcancelled_declaration(Verilog2001Parser.Showcancelled_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#path_declaration}.
	 * @param ctx the parse tree
	 */
	void enterPath_declaration(Verilog2001Parser.Path_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#path_declaration}.
	 * @param ctx the parse tree
	 */
	void exitPath_declaration(Verilog2001Parser.Path_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#simple_path_declaration}.
	 * @param ctx the parse tree
	 */
	void enterSimple_path_declaration(Verilog2001Parser.Simple_path_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#simple_path_declaration}.
	 * @param ctx the parse tree
	 */
	void exitSimple_path_declaration(Verilog2001Parser.Simple_path_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#parallel_path_description}.
	 * @param ctx the parse tree
	 */
	void enterParallel_path_description(Verilog2001Parser.Parallel_path_descriptionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#parallel_path_description}.
	 * @param ctx the parse tree
	 */
	void exitParallel_path_description(Verilog2001Parser.Parallel_path_descriptionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#full_path_description}.
	 * @param ctx the parse tree
	 */
	void enterFull_path_description(Verilog2001Parser.Full_path_descriptionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#full_path_description}.
	 * @param ctx the parse tree
	 */
	void exitFull_path_description(Verilog2001Parser.Full_path_descriptionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_path_inputs}.
	 * @param ctx the parse tree
	 */
	void enterList_of_path_inputs(Verilog2001Parser.List_of_path_inputsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_path_inputs}.
	 * @param ctx the parse tree
	 */
	void exitList_of_path_inputs(Verilog2001Parser.List_of_path_inputsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_path_outputs}.
	 * @param ctx the parse tree
	 */
	void enterList_of_path_outputs(Verilog2001Parser.List_of_path_outputsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_path_outputs}.
	 * @param ctx the parse tree
	 */
	void exitList_of_path_outputs(Verilog2001Parser.List_of_path_outputsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#specify_input_terminal_descriptor}.
	 * @param ctx the parse tree
	 */
	void enterSpecify_input_terminal_descriptor(Verilog2001Parser.Specify_input_terminal_descriptorContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#specify_input_terminal_descriptor}.
	 * @param ctx the parse tree
	 */
	void exitSpecify_input_terminal_descriptor(Verilog2001Parser.Specify_input_terminal_descriptorContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#specify_output_terminal_descriptor}.
	 * @param ctx the parse tree
	 */
	void enterSpecify_output_terminal_descriptor(Verilog2001Parser.Specify_output_terminal_descriptorContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#specify_output_terminal_descriptor}.
	 * @param ctx the parse tree
	 */
	void exitSpecify_output_terminal_descriptor(Verilog2001Parser.Specify_output_terminal_descriptorContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#input_identifier}.
	 * @param ctx the parse tree
	 */
	void enterInput_identifier(Verilog2001Parser.Input_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#input_identifier}.
	 * @param ctx the parse tree
	 */
	void exitInput_identifier(Verilog2001Parser.Input_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#output_identifier}.
	 * @param ctx the parse tree
	 */
	void enterOutput_identifier(Verilog2001Parser.Output_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#output_identifier}.
	 * @param ctx the parse tree
	 */
	void exitOutput_identifier(Verilog2001Parser.Output_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#path_delay_value}.
	 * @param ctx the parse tree
	 */
	void enterPath_delay_value(Verilog2001Parser.Path_delay_valueContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#path_delay_value}.
	 * @param ctx the parse tree
	 */
	void exitPath_delay_value(Verilog2001Parser.Path_delay_valueContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#list_of_path_delay_expressions}.
	 * @param ctx the parse tree
	 */
	void enterList_of_path_delay_expressions(Verilog2001Parser.List_of_path_delay_expressionsContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#list_of_path_delay_expressions}.
	 * @param ctx the parse tree
	 */
	void exitList_of_path_delay_expressions(Verilog2001Parser.List_of_path_delay_expressionsContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#t_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterT_path_delay_expression(Verilog2001Parser.T_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#t_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitT_path_delay_expression(Verilog2001Parser.T_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#trise_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterTrise_path_delay_expression(Verilog2001Parser.Trise_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#trise_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitTrise_path_delay_expression(Verilog2001Parser.Trise_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#tfall_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterTfall_path_delay_expression(Verilog2001Parser.Tfall_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#tfall_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitTfall_path_delay_expression(Verilog2001Parser.Tfall_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#tz_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterTz_path_delay_expression(Verilog2001Parser.Tz_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#tz_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitTz_path_delay_expression(Verilog2001Parser.Tz_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#t01_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterT01_path_delay_expression(Verilog2001Parser.T01_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#t01_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitT01_path_delay_expression(Verilog2001Parser.T01_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#t10_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterT10_path_delay_expression(Verilog2001Parser.T10_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#t10_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitT10_path_delay_expression(Verilog2001Parser.T10_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#t0z_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterT0z_path_delay_expression(Verilog2001Parser.T0z_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#t0z_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitT0z_path_delay_expression(Verilog2001Parser.T0z_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#tz1_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterTz1_path_delay_expression(Verilog2001Parser.Tz1_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#tz1_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitTz1_path_delay_expression(Verilog2001Parser.Tz1_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#t1z_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterT1z_path_delay_expression(Verilog2001Parser.T1z_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#t1z_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitT1z_path_delay_expression(Verilog2001Parser.T1z_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#tz0_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterTz0_path_delay_expression(Verilog2001Parser.Tz0_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#tz0_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitTz0_path_delay_expression(Verilog2001Parser.Tz0_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#t0x_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterT0x_path_delay_expression(Verilog2001Parser.T0x_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#t0x_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitT0x_path_delay_expression(Verilog2001Parser.T0x_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#tx1_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterTx1_path_delay_expression(Verilog2001Parser.Tx1_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#tx1_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitTx1_path_delay_expression(Verilog2001Parser.Tx1_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#t1x_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterT1x_path_delay_expression(Verilog2001Parser.T1x_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#t1x_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitT1x_path_delay_expression(Verilog2001Parser.T1x_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#tx0_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterTx0_path_delay_expression(Verilog2001Parser.Tx0_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#tx0_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitTx0_path_delay_expression(Verilog2001Parser.Tx0_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#txz_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterTxz_path_delay_expression(Verilog2001Parser.Txz_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#txz_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitTxz_path_delay_expression(Verilog2001Parser.Txz_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#tzx_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterTzx_path_delay_expression(Verilog2001Parser.Tzx_path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#tzx_path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitTzx_path_delay_expression(Verilog2001Parser.Tzx_path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void enterPath_delay_expression(Verilog2001Parser.Path_delay_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#path_delay_expression}.
	 * @param ctx the parse tree
	 */
	void exitPath_delay_expression(Verilog2001Parser.Path_delay_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#edge_sensitive_path_declaration}.
	 * @param ctx the parse tree
	 */
	void enterEdge_sensitive_path_declaration(Verilog2001Parser.Edge_sensitive_path_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#edge_sensitive_path_declaration}.
	 * @param ctx the parse tree
	 */
	void exitEdge_sensitive_path_declaration(Verilog2001Parser.Edge_sensitive_path_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#parallel_edge_sensitive_path_description}.
	 * @param ctx the parse tree
	 */
	void enterParallel_edge_sensitive_path_description(Verilog2001Parser.Parallel_edge_sensitive_path_descriptionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#parallel_edge_sensitive_path_description}.
	 * @param ctx the parse tree
	 */
	void exitParallel_edge_sensitive_path_description(Verilog2001Parser.Parallel_edge_sensitive_path_descriptionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#full_edge_sensitive_path_description}.
	 * @param ctx the parse tree
	 */
	void enterFull_edge_sensitive_path_description(Verilog2001Parser.Full_edge_sensitive_path_descriptionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#full_edge_sensitive_path_description}.
	 * @param ctx the parse tree
	 */
	void exitFull_edge_sensitive_path_description(Verilog2001Parser.Full_edge_sensitive_path_descriptionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#data_source_expression}.
	 * @param ctx the parse tree
	 */
	void enterData_source_expression(Verilog2001Parser.Data_source_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#data_source_expression}.
	 * @param ctx the parse tree
	 */
	void exitData_source_expression(Verilog2001Parser.Data_source_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#edge_identifier}.
	 * @param ctx the parse tree
	 */
	void enterEdge_identifier(Verilog2001Parser.Edge_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#edge_identifier}.
	 * @param ctx the parse tree
	 */
	void exitEdge_identifier(Verilog2001Parser.Edge_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#state_dependent_path_declaration}.
	 * @param ctx the parse tree
	 */
	void enterState_dependent_path_declaration(Verilog2001Parser.State_dependent_path_declarationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#state_dependent_path_declaration}.
	 * @param ctx the parse tree
	 */
	void exitState_dependent_path_declaration(Verilog2001Parser.State_dependent_path_declarationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#polarity_operator}.
	 * @param ctx the parse tree
	 */
	void enterPolarity_operator(Verilog2001Parser.Polarity_operatorContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#polarity_operator}.
	 * @param ctx the parse tree
	 */
	void exitPolarity_operator(Verilog2001Parser.Polarity_operatorContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#checktime_condition}.
	 * @param ctx the parse tree
	 */
	void enterChecktime_condition(Verilog2001Parser.Checktime_conditionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#checktime_condition}.
	 * @param ctx the parse tree
	 */
	void exitChecktime_condition(Verilog2001Parser.Checktime_conditionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#delayed_data}.
	 * @param ctx the parse tree
	 */
	void enterDelayed_data(Verilog2001Parser.Delayed_dataContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#delayed_data}.
	 * @param ctx the parse tree
	 */
	void exitDelayed_data(Verilog2001Parser.Delayed_dataContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#delayed_reference}.
	 * @param ctx the parse tree
	 */
	void enterDelayed_reference(Verilog2001Parser.Delayed_referenceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#delayed_reference}.
	 * @param ctx the parse tree
	 */
	void exitDelayed_reference(Verilog2001Parser.Delayed_referenceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#end_edge_offset}.
	 * @param ctx the parse tree
	 */
	void enterEnd_edge_offset(Verilog2001Parser.End_edge_offsetContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#end_edge_offset}.
	 * @param ctx the parse tree
	 */
	void exitEnd_edge_offset(Verilog2001Parser.End_edge_offsetContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#event_based_flag}.
	 * @param ctx the parse tree
	 */
	void enterEvent_based_flag(Verilog2001Parser.Event_based_flagContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#event_based_flag}.
	 * @param ctx the parse tree
	 */
	void exitEvent_based_flag(Verilog2001Parser.Event_based_flagContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#notify_reg}.
	 * @param ctx the parse tree
	 */
	void enterNotify_reg(Verilog2001Parser.Notify_regContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#notify_reg}.
	 * @param ctx the parse tree
	 */
	void exitNotify_reg(Verilog2001Parser.Notify_regContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#remain_active_flag}.
	 * @param ctx the parse tree
	 */
	void enterRemain_active_flag(Verilog2001Parser.Remain_active_flagContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#remain_active_flag}.
	 * @param ctx the parse tree
	 */
	void exitRemain_active_flag(Verilog2001Parser.Remain_active_flagContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#stamptime_condition}.
	 * @param ctx the parse tree
	 */
	void enterStamptime_condition(Verilog2001Parser.Stamptime_conditionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#stamptime_condition}.
	 * @param ctx the parse tree
	 */
	void exitStamptime_condition(Verilog2001Parser.Stamptime_conditionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#start_edge_offset}.
	 * @param ctx the parse tree
	 */
	void enterStart_edge_offset(Verilog2001Parser.Start_edge_offsetContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#start_edge_offset}.
	 * @param ctx the parse tree
	 */
	void exitStart_edge_offset(Verilog2001Parser.Start_edge_offsetContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#threshold}.
	 * @param ctx the parse tree
	 */
	void enterThreshold(Verilog2001Parser.ThresholdContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#threshold}.
	 * @param ctx the parse tree
	 */
	void exitThreshold(Verilog2001Parser.ThresholdContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#timing_check_limit}.
	 * @param ctx the parse tree
	 */
	void enterTiming_check_limit(Verilog2001Parser.Timing_check_limitContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#timing_check_limit}.
	 * @param ctx the parse tree
	 */
	void exitTiming_check_limit(Verilog2001Parser.Timing_check_limitContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#concatenation}.
	 * @param ctx the parse tree
	 */
	void enterConcatenation(Verilog2001Parser.ConcatenationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#concatenation}.
	 * @param ctx the parse tree
	 */
	void exitConcatenation(Verilog2001Parser.ConcatenationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#constant_concatenation}.
	 * @param ctx the parse tree
	 */
	void enterConstant_concatenation(Verilog2001Parser.Constant_concatenationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#constant_concatenation}.
	 * @param ctx the parse tree
	 */
	void exitConstant_concatenation(Verilog2001Parser.Constant_concatenationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#constant_multiple_concatenation}.
	 * @param ctx the parse tree
	 */
	void enterConstant_multiple_concatenation(Verilog2001Parser.Constant_multiple_concatenationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#constant_multiple_concatenation}.
	 * @param ctx the parse tree
	 */
	void exitConstant_multiple_concatenation(Verilog2001Parser.Constant_multiple_concatenationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_path_concatenation}.
	 * @param ctx the parse tree
	 */
	void enterModule_path_concatenation(Verilog2001Parser.Module_path_concatenationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_path_concatenation}.
	 * @param ctx the parse tree
	 */
	void exitModule_path_concatenation(Verilog2001Parser.Module_path_concatenationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_path_multiple_concatenation}.
	 * @param ctx the parse tree
	 */
	void enterModule_path_multiple_concatenation(Verilog2001Parser.Module_path_multiple_concatenationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_path_multiple_concatenation}.
	 * @param ctx the parse tree
	 */
	void exitModule_path_multiple_concatenation(Verilog2001Parser.Module_path_multiple_concatenationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#multiple_concatenation}.
	 * @param ctx the parse tree
	 */
	void enterMultiple_concatenation(Verilog2001Parser.Multiple_concatenationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#multiple_concatenation}.
	 * @param ctx the parse tree
	 */
	void exitMultiple_concatenation(Verilog2001Parser.Multiple_concatenationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#net_concatenation}.
	 * @param ctx the parse tree
	 */
	void enterNet_concatenation(Verilog2001Parser.Net_concatenationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#net_concatenation}.
	 * @param ctx the parse tree
	 */
	void exitNet_concatenation(Verilog2001Parser.Net_concatenationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#net_concatenation_value}.
	 * @param ctx the parse tree
	 */
	void enterNet_concatenation_value(Verilog2001Parser.Net_concatenation_valueContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#net_concatenation_value}.
	 * @param ctx the parse tree
	 */
	void exitNet_concatenation_value(Verilog2001Parser.Net_concatenation_valueContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#variable_concatenation}.
	 * @param ctx the parse tree
	 */
	void enterVariable_concatenation(Verilog2001Parser.Variable_concatenationContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#variable_concatenation}.
	 * @param ctx the parse tree
	 */
	void exitVariable_concatenation(Verilog2001Parser.Variable_concatenationContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#variable_concatenation_value}.
	 * @param ctx the parse tree
	 */
	void enterVariable_concatenation_value(Verilog2001Parser.Variable_concatenation_valueContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#variable_concatenation_value}.
	 * @param ctx the parse tree
	 */
	void exitVariable_concatenation_value(Verilog2001Parser.Variable_concatenation_valueContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#constant_function_call}.
	 * @param ctx the parse tree
	 */
	void enterConstant_function_call(Verilog2001Parser.Constant_function_callContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#constant_function_call}.
	 * @param ctx the parse tree
	 */
	void exitConstant_function_call(Verilog2001Parser.Constant_function_callContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_call}.
	 * @param ctx the parse tree
	 */
	void enterFunction_call(Verilog2001Parser.Function_callContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_call}.
	 * @param ctx the parse tree
	 */
	void exitFunction_call(Verilog2001Parser.Function_callContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#system_function_call}.
	 * @param ctx the parse tree
	 */
	void enterSystem_function_call(Verilog2001Parser.System_function_callContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#system_function_call}.
	 * @param ctx the parse tree
	 */
	void exitSystem_function_call(Verilog2001Parser.System_function_callContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#genvar_function_call}.
	 * @param ctx the parse tree
	 */
	void enterGenvar_function_call(Verilog2001Parser.Genvar_function_callContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#genvar_function_call}.
	 * @param ctx the parse tree
	 */
	void exitGenvar_function_call(Verilog2001Parser.Genvar_function_callContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#base_expression}.
	 * @param ctx the parse tree
	 */
	void enterBase_expression(Verilog2001Parser.Base_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#base_expression}.
	 * @param ctx the parse tree
	 */
	void exitBase_expression(Verilog2001Parser.Base_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#constant_base_expression}.
	 * @param ctx the parse tree
	 */
	void enterConstant_base_expression(Verilog2001Parser.Constant_base_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#constant_base_expression}.
	 * @param ctx the parse tree
	 */
	void exitConstant_base_expression(Verilog2001Parser.Constant_base_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#constant_expression}.
	 * @param ctx the parse tree
	 */
	void enterConstant_expression(Verilog2001Parser.Constant_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#constant_expression}.
	 * @param ctx the parse tree
	 */
	void exitConstant_expression(Verilog2001Parser.Constant_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#constant_mintypmax_expression}.
	 * @param ctx the parse tree
	 */
	void enterConstant_mintypmax_expression(Verilog2001Parser.Constant_mintypmax_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#constant_mintypmax_expression}.
	 * @param ctx the parse tree
	 */
	void exitConstant_mintypmax_expression(Verilog2001Parser.Constant_mintypmax_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#constant_range_expression}.
	 * @param ctx the parse tree
	 */
	void enterConstant_range_expression(Verilog2001Parser.Constant_range_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#constant_range_expression}.
	 * @param ctx the parse tree
	 */
	void exitConstant_range_expression(Verilog2001Parser.Constant_range_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#dimension_constant_expression}.
	 * @param ctx the parse tree
	 */
	void enterDimension_constant_expression(Verilog2001Parser.Dimension_constant_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#dimension_constant_expression}.
	 * @param ctx the parse tree
	 */
	void exitDimension_constant_expression(Verilog2001Parser.Dimension_constant_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#expression}.
	 * @param ctx the parse tree
	 */
	void enterExpression(Verilog2001Parser.ExpressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#expression}.
	 * @param ctx the parse tree
	 */
	void exitExpression(Verilog2001Parser.ExpressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#term}.
	 * @param ctx the parse tree
	 */
	void enterTerm(Verilog2001Parser.TermContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#term}.
	 * @param ctx the parse tree
	 */
	void exitTerm(Verilog2001Parser.TermContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#lsb_constant_expression}.
	 * @param ctx the parse tree
	 */
	void enterLsb_constant_expression(Verilog2001Parser.Lsb_constant_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#lsb_constant_expression}.
	 * @param ctx the parse tree
	 */
	void exitLsb_constant_expression(Verilog2001Parser.Lsb_constant_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#mintypmax_expression}.
	 * @param ctx the parse tree
	 */
	void enterMintypmax_expression(Verilog2001Parser.Mintypmax_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#mintypmax_expression}.
	 * @param ctx the parse tree
	 */
	void exitMintypmax_expression(Verilog2001Parser.Mintypmax_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_path_conditional_expression}.
	 * @param ctx the parse tree
	 */
	void enterModule_path_conditional_expression(Verilog2001Parser.Module_path_conditional_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_path_conditional_expression}.
	 * @param ctx the parse tree
	 */
	void exitModule_path_conditional_expression(Verilog2001Parser.Module_path_conditional_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_path_expression}.
	 * @param ctx the parse tree
	 */
	void enterModule_path_expression(Verilog2001Parser.Module_path_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_path_expression}.
	 * @param ctx the parse tree
	 */
	void exitModule_path_expression(Verilog2001Parser.Module_path_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_path_mintypmax_expression}.
	 * @param ctx the parse tree
	 */
	void enterModule_path_mintypmax_expression(Verilog2001Parser.Module_path_mintypmax_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_path_mintypmax_expression}.
	 * @param ctx the parse tree
	 */
	void exitModule_path_mintypmax_expression(Verilog2001Parser.Module_path_mintypmax_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#msb_constant_expression}.
	 * @param ctx the parse tree
	 */
	void enterMsb_constant_expression(Verilog2001Parser.Msb_constant_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#msb_constant_expression}.
	 * @param ctx the parse tree
	 */
	void exitMsb_constant_expression(Verilog2001Parser.Msb_constant_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#range_expression}.
	 * @param ctx the parse tree
	 */
	void enterRange_expression(Verilog2001Parser.Range_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#range_expression}.
	 * @param ctx the parse tree
	 */
	void exitRange_expression(Verilog2001Parser.Range_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#width_constant_expression}.
	 * @param ctx the parse tree
	 */
	void enterWidth_constant_expression(Verilog2001Parser.Width_constant_expressionContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#width_constant_expression}.
	 * @param ctx the parse tree
	 */
	void exitWidth_constant_expression(Verilog2001Parser.Width_constant_expressionContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#constant_primary}.
	 * @param ctx the parse tree
	 */
	void enterConstant_primary(Verilog2001Parser.Constant_primaryContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#constant_primary}.
	 * @param ctx the parse tree
	 */
	void exitConstant_primary(Verilog2001Parser.Constant_primaryContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_path_primary}.
	 * @param ctx the parse tree
	 */
	void enterModule_path_primary(Verilog2001Parser.Module_path_primaryContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_path_primary}.
	 * @param ctx the parse tree
	 */
	void exitModule_path_primary(Verilog2001Parser.Module_path_primaryContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#primary}.
	 * @param ctx the parse tree
	 */
	void enterPrimary(Verilog2001Parser.PrimaryContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#primary}.
	 * @param ctx the parse tree
	 */
	void exitPrimary(Verilog2001Parser.PrimaryContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#net_lvalue}.
	 * @param ctx the parse tree
	 */
	void enterNet_lvalue(Verilog2001Parser.Net_lvalueContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#net_lvalue}.
	 * @param ctx the parse tree
	 */
	void exitNet_lvalue(Verilog2001Parser.Net_lvalueContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#variable_lvalue}.
	 * @param ctx the parse tree
	 */
	void enterVariable_lvalue(Verilog2001Parser.Variable_lvalueContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#variable_lvalue}.
	 * @param ctx the parse tree
	 */
	void exitVariable_lvalue(Verilog2001Parser.Variable_lvalueContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#unary_operator}.
	 * @param ctx the parse tree
	 */
	void enterUnary_operator(Verilog2001Parser.Unary_operatorContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#unary_operator}.
	 * @param ctx the parse tree
	 */
	void exitUnary_operator(Verilog2001Parser.Unary_operatorContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#binary_operator}.
	 * @param ctx the parse tree
	 */
	void enterBinary_operator(Verilog2001Parser.Binary_operatorContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#binary_operator}.
	 * @param ctx the parse tree
	 */
	void exitBinary_operator(Verilog2001Parser.Binary_operatorContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#unary_module_path_operator}.
	 * @param ctx the parse tree
	 */
	void enterUnary_module_path_operator(Verilog2001Parser.Unary_module_path_operatorContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#unary_module_path_operator}.
	 * @param ctx the parse tree
	 */
	void exitUnary_module_path_operator(Verilog2001Parser.Unary_module_path_operatorContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#binary_module_path_operator}.
	 * @param ctx the parse tree
	 */
	void enterBinary_module_path_operator(Verilog2001Parser.Binary_module_path_operatorContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#binary_module_path_operator}.
	 * @param ctx the parse tree
	 */
	void exitBinary_module_path_operator(Verilog2001Parser.Binary_module_path_operatorContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#number}.
	 * @param ctx the parse tree
	 */
	void enterNumber(Verilog2001Parser.NumberContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#number}.
	 * @param ctx the parse tree
	 */
	void exitNumber(Verilog2001Parser.NumberContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#attribute_instance}.
	 * @param ctx the parse tree
	 */
	void enterAttribute_instance(Verilog2001Parser.Attribute_instanceContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#attribute_instance}.
	 * @param ctx the parse tree
	 */
	void exitAttribute_instance(Verilog2001Parser.Attribute_instanceContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#attr_spec}.
	 * @param ctx the parse tree
	 */
	void enterAttr_spec(Verilog2001Parser.Attr_specContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#attr_spec}.
	 * @param ctx the parse tree
	 */
	void exitAttr_spec(Verilog2001Parser.Attr_specContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#attr_name}.
	 * @param ctx the parse tree
	 */
	void enterAttr_name(Verilog2001Parser.Attr_nameContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#attr_name}.
	 * @param ctx the parse tree
	 */
	void exitAttr_name(Verilog2001Parser.Attr_nameContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#arrayed_identifier}.
	 * @param ctx the parse tree
	 */
	void enterArrayed_identifier(Verilog2001Parser.Arrayed_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#arrayed_identifier}.
	 * @param ctx the parse tree
	 */
	void exitArrayed_identifier(Verilog2001Parser.Arrayed_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#block_identifier}.
	 * @param ctx the parse tree
	 */
	void enterBlock_identifier(Verilog2001Parser.Block_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#block_identifier}.
	 * @param ctx the parse tree
	 */
	void exitBlock_identifier(Verilog2001Parser.Block_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#cell_identifier}.
	 * @param ctx the parse tree
	 */
	void enterCell_identifier(Verilog2001Parser.Cell_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#cell_identifier}.
	 * @param ctx the parse tree
	 */
	void exitCell_identifier(Verilog2001Parser.Cell_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#config_identifier}.
	 * @param ctx the parse tree
	 */
	void enterConfig_identifier(Verilog2001Parser.Config_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#config_identifier}.
	 * @param ctx the parse tree
	 */
	void exitConfig_identifier(Verilog2001Parser.Config_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#escaped_arrayed_identifier}.
	 * @param ctx the parse tree
	 */
	void enterEscaped_arrayed_identifier(Verilog2001Parser.Escaped_arrayed_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#escaped_arrayed_identifier}.
	 * @param ctx the parse tree
	 */
	void exitEscaped_arrayed_identifier(Verilog2001Parser.Escaped_arrayed_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#escaped_hierarchical_identifier}.
	 * @param ctx the parse tree
	 */
	void enterEscaped_hierarchical_identifier(Verilog2001Parser.Escaped_hierarchical_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#escaped_hierarchical_identifier}.
	 * @param ctx the parse tree
	 */
	void exitEscaped_hierarchical_identifier(Verilog2001Parser.Escaped_hierarchical_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#event_identifier}.
	 * @param ctx the parse tree
	 */
	void enterEvent_identifier(Verilog2001Parser.Event_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#event_identifier}.
	 * @param ctx the parse tree
	 */
	void exitEvent_identifier(Verilog2001Parser.Event_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#function_identifier}.
	 * @param ctx the parse tree
	 */
	void enterFunction_identifier(Verilog2001Parser.Function_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#function_identifier}.
	 * @param ctx the parse tree
	 */
	void exitFunction_identifier(Verilog2001Parser.Function_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#gate_instance_identifier}.
	 * @param ctx the parse tree
	 */
	void enterGate_instance_identifier(Verilog2001Parser.Gate_instance_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#gate_instance_identifier}.
	 * @param ctx the parse tree
	 */
	void exitGate_instance_identifier(Verilog2001Parser.Gate_instance_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#generate_block_identifier}.
	 * @param ctx the parse tree
	 */
	void enterGenerate_block_identifier(Verilog2001Parser.Generate_block_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#generate_block_identifier}.
	 * @param ctx the parse tree
	 */
	void exitGenerate_block_identifier(Verilog2001Parser.Generate_block_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#genvar_function_identifier}.
	 * @param ctx the parse tree
	 */
	void enterGenvar_function_identifier(Verilog2001Parser.Genvar_function_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#genvar_function_identifier}.
	 * @param ctx the parse tree
	 */
	void exitGenvar_function_identifier(Verilog2001Parser.Genvar_function_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#genvar_identifier}.
	 * @param ctx the parse tree
	 */
	void enterGenvar_identifier(Verilog2001Parser.Genvar_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#genvar_identifier}.
	 * @param ctx the parse tree
	 */
	void exitGenvar_identifier(Verilog2001Parser.Genvar_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#hierarchical_block_identifier}.
	 * @param ctx the parse tree
	 */
	void enterHierarchical_block_identifier(Verilog2001Parser.Hierarchical_block_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#hierarchical_block_identifier}.
	 * @param ctx the parse tree
	 */
	void exitHierarchical_block_identifier(Verilog2001Parser.Hierarchical_block_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#hierarchical_event_identifier}.
	 * @param ctx the parse tree
	 */
	void enterHierarchical_event_identifier(Verilog2001Parser.Hierarchical_event_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#hierarchical_event_identifier}.
	 * @param ctx the parse tree
	 */
	void exitHierarchical_event_identifier(Verilog2001Parser.Hierarchical_event_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#hierarchical_function_identifier}.
	 * @param ctx the parse tree
	 */
	void enterHierarchical_function_identifier(Verilog2001Parser.Hierarchical_function_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#hierarchical_function_identifier}.
	 * @param ctx the parse tree
	 */
	void exitHierarchical_function_identifier(Verilog2001Parser.Hierarchical_function_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#hierarchical_identifier}.
	 * @param ctx the parse tree
	 */
	void enterHierarchical_identifier(Verilog2001Parser.Hierarchical_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#hierarchical_identifier}.
	 * @param ctx the parse tree
	 */
	void exitHierarchical_identifier(Verilog2001Parser.Hierarchical_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#hierarchical_net_identifier}.
	 * @param ctx the parse tree
	 */
	void enterHierarchical_net_identifier(Verilog2001Parser.Hierarchical_net_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#hierarchical_net_identifier}.
	 * @param ctx the parse tree
	 */
	void exitHierarchical_net_identifier(Verilog2001Parser.Hierarchical_net_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#hierarchical_variable_identifier}.
	 * @param ctx the parse tree
	 */
	void enterHierarchical_variable_identifier(Verilog2001Parser.Hierarchical_variable_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#hierarchical_variable_identifier}.
	 * @param ctx the parse tree
	 */
	void exitHierarchical_variable_identifier(Verilog2001Parser.Hierarchical_variable_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#hierarchical_task_identifier}.
	 * @param ctx the parse tree
	 */
	void enterHierarchical_task_identifier(Verilog2001Parser.Hierarchical_task_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#hierarchical_task_identifier}.
	 * @param ctx the parse tree
	 */
	void exitHierarchical_task_identifier(Verilog2001Parser.Hierarchical_task_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#identifier}.
	 * @param ctx the parse tree
	 */
	void enterIdentifier(Verilog2001Parser.IdentifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#identifier}.
	 * @param ctx the parse tree
	 */
	void exitIdentifier(Verilog2001Parser.IdentifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#inout_port_identifier}.
	 * @param ctx the parse tree
	 */
	void enterInout_port_identifier(Verilog2001Parser.Inout_port_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#inout_port_identifier}.
	 * @param ctx the parse tree
	 */
	void exitInout_port_identifier(Verilog2001Parser.Inout_port_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#input_port_identifier}.
	 * @param ctx the parse tree
	 */
	void enterInput_port_identifier(Verilog2001Parser.Input_port_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#input_port_identifier}.
	 * @param ctx the parse tree
	 */
	void exitInput_port_identifier(Verilog2001Parser.Input_port_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#instance_identifier}.
	 * @param ctx the parse tree
	 */
	void enterInstance_identifier(Verilog2001Parser.Instance_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#instance_identifier}.
	 * @param ctx the parse tree
	 */
	void exitInstance_identifier(Verilog2001Parser.Instance_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#library_identifier}.
	 * @param ctx the parse tree
	 */
	void enterLibrary_identifier(Verilog2001Parser.Library_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#library_identifier}.
	 * @param ctx the parse tree
	 */
	void exitLibrary_identifier(Verilog2001Parser.Library_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#memory_identifier}.
	 * @param ctx the parse tree
	 */
	void enterMemory_identifier(Verilog2001Parser.Memory_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#memory_identifier}.
	 * @param ctx the parse tree
	 */
	void exitMemory_identifier(Verilog2001Parser.Memory_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_identifier}.
	 * @param ctx the parse tree
	 */
	void enterModule_identifier(Verilog2001Parser.Module_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_identifier}.
	 * @param ctx the parse tree
	 */
	void exitModule_identifier(Verilog2001Parser.Module_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#module_instance_identifier}.
	 * @param ctx the parse tree
	 */
	void enterModule_instance_identifier(Verilog2001Parser.Module_instance_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#module_instance_identifier}.
	 * @param ctx the parse tree
	 */
	void exitModule_instance_identifier(Verilog2001Parser.Module_instance_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#net_identifier}.
	 * @param ctx the parse tree
	 */
	void enterNet_identifier(Verilog2001Parser.Net_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#net_identifier}.
	 * @param ctx the parse tree
	 */
	void exitNet_identifier(Verilog2001Parser.Net_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#output_port_identifier}.
	 * @param ctx the parse tree
	 */
	void enterOutput_port_identifier(Verilog2001Parser.Output_port_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#output_port_identifier}.
	 * @param ctx the parse tree
	 */
	void exitOutput_port_identifier(Verilog2001Parser.Output_port_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#parameter_identifier}.
	 * @param ctx the parse tree
	 */
	void enterParameter_identifier(Verilog2001Parser.Parameter_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#parameter_identifier}.
	 * @param ctx the parse tree
	 */
	void exitParameter_identifier(Verilog2001Parser.Parameter_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#port_identifier}.
	 * @param ctx the parse tree
	 */
	void enterPort_identifier(Verilog2001Parser.Port_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#port_identifier}.
	 * @param ctx the parse tree
	 */
	void exitPort_identifier(Verilog2001Parser.Port_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#real_identifier}.
	 * @param ctx the parse tree
	 */
	void enterReal_identifier(Verilog2001Parser.Real_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#real_identifier}.
	 * @param ctx the parse tree
	 */
	void exitReal_identifier(Verilog2001Parser.Real_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#simple_arrayed_identifier}.
	 * @param ctx the parse tree
	 */
	void enterSimple_arrayed_identifier(Verilog2001Parser.Simple_arrayed_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#simple_arrayed_identifier}.
	 * @param ctx the parse tree
	 */
	void exitSimple_arrayed_identifier(Verilog2001Parser.Simple_arrayed_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#simple_hierarchical_identifier}.
	 * @param ctx the parse tree
	 */
	void enterSimple_hierarchical_identifier(Verilog2001Parser.Simple_hierarchical_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#simple_hierarchical_identifier}.
	 * @param ctx the parse tree
	 */
	void exitSimple_hierarchical_identifier(Verilog2001Parser.Simple_hierarchical_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#specparam_identifier}.
	 * @param ctx the parse tree
	 */
	void enterSpecparam_identifier(Verilog2001Parser.Specparam_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#specparam_identifier}.
	 * @param ctx the parse tree
	 */
	void exitSpecparam_identifier(Verilog2001Parser.Specparam_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#system_function_identifier}.
	 * @param ctx the parse tree
	 */
	void enterSystem_function_identifier(Verilog2001Parser.System_function_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#system_function_identifier}.
	 * @param ctx the parse tree
	 */
	void exitSystem_function_identifier(Verilog2001Parser.System_function_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#system_task_identifier}.
	 * @param ctx the parse tree
	 */
	void enterSystem_task_identifier(Verilog2001Parser.System_task_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#system_task_identifier}.
	 * @param ctx the parse tree
	 */
	void exitSystem_task_identifier(Verilog2001Parser.System_task_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#task_identifier}.
	 * @param ctx the parse tree
	 */
	void enterTask_identifier(Verilog2001Parser.Task_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#task_identifier}.
	 * @param ctx the parse tree
	 */
	void exitTask_identifier(Verilog2001Parser.Task_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#terminal_identifier}.
	 * @param ctx the parse tree
	 */
	void enterTerminal_identifier(Verilog2001Parser.Terminal_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#terminal_identifier}.
	 * @param ctx the parse tree
	 */
	void exitTerminal_identifier(Verilog2001Parser.Terminal_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#text_macro_identifier}.
	 * @param ctx the parse tree
	 */
	void enterText_macro_identifier(Verilog2001Parser.Text_macro_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#text_macro_identifier}.
	 * @param ctx the parse tree
	 */
	void exitText_macro_identifier(Verilog2001Parser.Text_macro_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#topmodule_identifier}.
	 * @param ctx the parse tree
	 */
	void enterTopmodule_identifier(Verilog2001Parser.Topmodule_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#topmodule_identifier}.
	 * @param ctx the parse tree
	 */
	void exitTopmodule_identifier(Verilog2001Parser.Topmodule_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#udp_identifier}.
	 * @param ctx the parse tree
	 */
	void enterUdp_identifier(Verilog2001Parser.Udp_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#udp_identifier}.
	 * @param ctx the parse tree
	 */
	void exitUdp_identifier(Verilog2001Parser.Udp_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#udp_instance_identifier}.
	 * @param ctx the parse tree
	 */
	void enterUdp_instance_identifier(Verilog2001Parser.Udp_instance_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#udp_instance_identifier}.
	 * @param ctx the parse tree
	 */
	void exitUdp_instance_identifier(Verilog2001Parser.Udp_instance_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#variable_identifier}.
	 * @param ctx the parse tree
	 */
	void enterVariable_identifier(Verilog2001Parser.Variable_identifierContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#variable_identifier}.
	 * @param ctx the parse tree
	 */
	void exitVariable_identifier(Verilog2001Parser.Variable_identifierContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#simple_hierarchical_branch}.
	 * @param ctx the parse tree
	 */
	void enterSimple_hierarchical_branch(Verilog2001Parser.Simple_hierarchical_branchContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#simple_hierarchical_branch}.
	 * @param ctx the parse tree
	 */
	void exitSimple_hierarchical_branch(Verilog2001Parser.Simple_hierarchical_branchContext ctx);
	/**
	 * Enter a parse tree produced by {@link Verilog2001Parser#escaped_hierarchical_branch}.
	 * @param ctx the parse tree
	 */
	void enterEscaped_hierarchical_branch(Verilog2001Parser.Escaped_hierarchical_branchContext ctx);
	/**
	 * Exit a parse tree produced by {@link Verilog2001Parser#escaped_hierarchical_branch}.
	 * @param ctx the parse tree
	 */
	void exitEscaped_hierarchical_branch(Verilog2001Parser.Escaped_hierarchical_branchContext ctx);
}