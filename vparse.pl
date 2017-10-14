#!/usr/bin/perl

################################################################################
##  Verilog Code Parser                                                       ##
##  by Y.D Hsu                                                                ##
################################################################################
# v1.0 
#     1.check duplicate module name
#     2.support postion-mapping instance with 1-layer {}.
#     3.support name-mapping instance without {}.
#     4.support instance view
#     5.support top module display
#     6.support hierarchy view
#
# v1.1 
#     1.modify ins_*_array to hash from aray
#
# v1.2
#     1.modify ins_*_array back from hash to aray due to performance issue   
#     2.check port and save port information only if $dump_port=1 for performance issue

   use strict;
   use Getopt::Std;
  
   #parameter
   my $dump_port = 0;
   my $print_array_info = 0;
   my $dump_file = "";
   #invalid keyword
   #my @inv_key= qw/begin end reg fork while for posedge negedge 
   #                always initial/;    
   my $print_mname_info = 0;
   my $print_ins_times = 0;
   my $ins_module=""; 
   my $show_top = 0;  
   my $show_hierarchy = 0;  
      
   #vparse main variable 
   my $parse_file;
   my $line_number = 0;
   my $module_start  = 0;
   my $Bigmark_start = 0;
   my $total_port_number = 0;
   my $total_inport = 0;
   my $total_outport = 0;
   my $total_wire = 0;
   my $total_inout = 0;
   my $warn_msg_no = 0;

   my %module_name_array;       #1-D hash  key:name        value:no
   my %module_no_array;         #1-D hash  key:no          value:name
   my %port_array;              #2-D hash  key:module no   key:no         value:port name
   my %port_name_array;         #2-D hash  key:module no   key:port_name  value:no
   my %in_port_array;           #2-D hash  key:module no   key:no         value:port name
   my %out_port_array;          #2-D hash  key:module no   key:no         value:port name
   my %wire_array;              #2-D hash  key:module no   key:no         value:wire name
   my %inout_array;             #2-D hash  key:module no   key:no         value:port name
   my $module_no = 0;

   my @ins_array;               #2-D 
   my @ins_no_array;            #2-D 
   my @ins_name_array;          #2-D 
   my @ins_name_no_array;       #2-D 
   
   my @ins_noreap_array;        #2-D 
   my @ins_noreap_name_array;   #2-D 
   my @ins_times_array;         #2-D 
   
   my $parse_top_m_end = 0;
   my %cell_name;               #1-D hash contains all cell_names of Z/S/L library
   
   my @del_cell_arr;            #2-D 
   my @del_cell_name_arr;       #2-D 
   my $gen_del_cell_arr_ok = 0;
   
   my @module_hier_num;         #1-D 
   my @module_hier_num_flag;    #1-D 
   my $gen_module_hier_num_ok = 0; 
     
   #other variables in process_body & process_endmodule
   my $line;
   my @arrs = ();
   my @sp = ();
   my $empty_line;
   my $value;
   my %opts;

   #other variables in while loop
   my @loop_arr;
   my $low;
   my $high;
   my $process_line;
   my $append_line;
   my $append="";
   my $file_read = 1;
   my $place1;
   my $place2; 
   my $temp_s;

   #other variables for grammar check
   my $last ="";
   my $parse_start = 1;
   my $mod_start = 0;
   my $module_name_occur = 0;
   my $module_port_occur = 0;
   my $module_port_dot_need = 0;
   my $module_port_coma_need = 0;
   my $module_left_C_occur = 0;
   my $body_start = 0;
   my $in_start = 0;
   my $in_dot_coma_need = 0;
   my $in_dim_start = 0;
   my $in_dim_start_once = 0;
   my $in_dim_eye_need = 0;
   my $in_dim_number_need = 0;
   my $in_dim_right_C_need = 0;
   my $out_start = 0;
   my $out_dot_coma_need = 0;
   my $out_dim_start = 0;
   my $out_dim_start_once = 0;
   my $out_dim_eye_need = 0;
   my $out_dim_number_need = 0;
   my $out_dim_right_C_need = 0;
   my $wire_start = 0;
   my $wire_dot_coma_need = 0;
   my $wire_dim_start = 0;
   my $wire_dim_start_once = 0;
   my $wire_dim_eye_need = 0;
   my $wire_dim_number_need = 0;
   my $wire_dim_right_C_need = 0;
   my $inout_start = 0;
   my $inout_dot_coma_need = 0;
   my $inout_dim_start = 0;
   my $inout_dim_start_once = 0;
   my $inout_dim_eye_need = 0;
   my $inout_dim_number_need = 0;
   my $inout_dim_right_C_need = 0;
   my $comp_start = 0;
   my $comp_left_C_need = 0;
   my $comp_dot_need = 0;
   my $comp_pin_name_need = 0;
   my $comp_coma_need = 0;
   my $comp_pin_left_C_need = 0;
   my $comp_port_name_need = 0;
   my $comp_pin_right_C_need = 0;
   my $comp_pin_right_C_need_2 = 0;
   my $comp_pin_sep_need = 0;
   my $comp_port_name;
   my $comp2_sep_need = 0;
   my $comp2_word_need = 0;
   my @res_name = qw/ begin end reg fork while for posedge negedge 
                      always initial module input output wire endmodule 
                      assign /;   
   my @wrong_name = qw/ begin end reg fork while for posedge negedge 
                      always initial assign /; 
   my %H_res_name;
   my %H_wrong_name;

######################
##  main program    ##
######################
   #########################################################################
   # setup environment
   #########################################################################    
   &setup_env;

   if($dump_file ne ""){
      die "file $dump_file exists.\n" if -e $dump_file;
      open df, "> $dump_file" or die; 
   }

   $parse_file = $ARGV[0];
   open pf,"< $parse_file" or die "No such file exists.\n";

   #########################################################################
   # pre-process and grammar check code here
   #########################################################################    
   my $now = localtime;
   my @arr = split /\s+/, $now;
   my @arr1 = split /:/,$arr[3];
   printf "\n";
   printf "         Verilog Gatelevel Code Parser v1.2\n\n";
   printf "Author: ydhsu\n";   
   printf "Email : ydhsu\@via.com.tw \n";
   printf "-------------------------------------------------------\n";   
   printf "\nParsing start ... %s/%s %s:%s\n",$arr[1],$arr[2],$arr1[0],$arr1[1];
   printf "=======================================================\n";

   printf df "\n";
   printf df "         Verilog Gatelevel Code Parser v1.0\n\n";
   printf df "Author: ydhsu\n";   
   printf df "Email : ydhsu\@via.com.tw \n";
   printf df "-------------------------------------------------------\n";   
   printf df "\nParsing start ... %s/%s %s:%s\n",$arr[1],$arr[2],$arr1[0],$arr1[1];
   printf df "=======================================================\n";
   while (defined($line = <>)) {
          $line_number++;
          chomp($line);
          $line = &remove_bigmark($line);    #remove big mark
          $line = &remove_mark($line);       #remove mark
          &grammar_check($line);
       }

   
   #########################################################################
   # post-process code here
   #########################################################################    
   printf    "\n";
   printf    "Total module  no.: %d \n",$module_no;
   printf    "Total error   no.: %d \n",0;
   printf    "Total warning no.: %d \n",$warn_msg_no;
   printf df "\n";
   printf df "Total module  no.: %d \n",$module_no;
   printf df "Total error   no.: %d \n",0;
   printf df "Total warning no.: %d \n",$warn_msg_no;
   #########################################################################
   # print result
   #########################################################################    
   if ($show_top == 1) {
       printf "=======================================================\n";
       printf df "=======================================================\n";
       &print_highest_module("",""); ##default
   }

   if ($show_hierarchy == 1) {
       printf "=======================================================\n";
       printf df "=======================================================\n";
       &print_hierarchy;
   }   
   
   if($print_array_info == 1) {
      printf "=======================================================\n";
      printf df "=======================================================\n";
      &debug_print_array;
   }

   if($print_mname_info == 1) {
      printf "=======================================================\n";
      printf "Modules:      \n";
      printf df "=======================================================\n";
      printf df "Modules:      \n";
      
      #my $i;
      #for($i=0;$i<=$#module_name_array;$i++) {
      #   printf "        $module_name_array[$i]\n";
      #}
      my $key; my $value;
      while(($key,$value) = each %module_name_array){
          printf "        $key\n";
          printf df "        $key\n";  
      }
      
   }

   if($ins_module ne ""){
      $print_ins_times =1;
   }

   if($print_ins_times == 1) {
      my $i;
      my $j;
      my $dont_exit=1;
      printf "=======================================================\n";
      printf df "=======================================================\n";
      #for($i=0;$i<$module_no;$i++){
      #       if($module_name_array[$i] eq $ins_module) {
      #          printf "module_name: $module_name_array[$i]\n";
      #          &print_all_inst;
      #          $dont_exit=0;
      #          last;
      #       }
      #}
      if(exists $module_name_array{$ins_module} ) {
         printf "module_name: $ins_module\n"; 
         printf df "module_name: $ins_module\n"; 
         &print_all_inst($module_name_array{$ins_module});
         $dont_exit=0;
      }
      
      if($dont_exit==1) {
         printf "--- no module %-5s exist.\n",$ins_module;
         printf df "--- no module %-5s exist.\n",$ins_module;
      }
   }

   $now = localtime;
   my @arr = split /\s+/, $now;
   my @arr1 = split /:/,$arr[3];
   printf "\n";
   printf "=======================================================\n";
   printf "Parsing end ...   %s/%s %s:%s\n\n",$arr[1],$arr[2],$arr1[0],$arr1[1];
   printf df "\n";
   printf df "=======================================================\n";
   printf df "Parsing end ...   %s/%s %s:%s\n\n",$arr[1],$arr[2],$arr1[0],$arr1[1];
   #if($dump_file eq ""){
      &loop_ask;
   #}
