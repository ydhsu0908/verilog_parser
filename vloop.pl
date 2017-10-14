

sub loop_ask{
 my $scan;

 printf    "Enter command:(Type [h|q] for help|quit):";
 printf df "Enter command:(Type [h|q] for help|quit):";
 while(1){
   $scan = <>;  
   chomp($scan);  
   if ($scan eq "h") {
       printf    "=======================================================\n";
       printf    "[Command] | [Description] \n";
       printf    " mname    | show module name of entire file\n";
       if($dump_port == 1){
       printf    " port     | dump ports info of specified module\n";
       }
       printf    " top      | dump top module\n";
       printf    " hier     | dump hierarchy\n";
       printf    " inst     | dump instances times of specified module\n";
       printf    "=======================================================\n";
       printf    "\nEnter command (Type [h|q] for help|quit): ";
       printf df $scan."\n";
       printf df "=======================================================\n";
       printf df "[Command] | [Description] \n";
       printf df " mname    | show module name of entire file\n";
       if($dump_port == 1){
       printf df " port     | dump ports info of specified module\n";
       }
       printf df " top      | dump top module\n";
       printf df " hier     | dump hierarchy\n";
       printf df " inst     | dump instances times of specified module\n";
       printf df "=======================================================\n";
       printf df "\nEnter command (Type [h|q] for help|quit): ";
   }
   elsif( $scan eq "top" | $scan eq "t"){
      printf    "=======================================================\n";    
      printf df $scan."\n";
      printf df "=======================================================\n";    
      &print_highest_module;
      printf    "=======================================================\n";
      printf    "\nEnter command (Type [h|q] for help|quit): ";
      printf df "=======================================================\n";
      printf df "\nEnter command (Type [h|q] for help|quit): ";
   }
   elsif( $scan eq "q"){
      printf df $scan."\n";
      printf "Thank you...\n\n";
      printf df "Thank you...\n\n";
      exit;
   }
   elsif( $scan eq "hier"){
      printf    "=======================================================\n";    
      printf df $scan."\n";
      printf df "=======================================================\n";    
      printf    "Highest module name(press Enter= top): ";
      printf df "Highest module name(press Enter= top): ";
      $scan =<>;
      chomp($scan);
      printf df $scan."\n";
      my $v1 =$scan;
      printf    "Desired depth (press Enter= all): ";
      printf df "Desired depth (press Enter= all): ";
      $scan =<>;
      chomp($scan);
      printf df $scan."\n";
      my $v2 = $scan;
       
      if(exists $module_name_array{$v1} | $v1 eq "") {
         $_ = $v2;
         if((/\d/ & $v2 >= 0) | $v2 eq "") {
            &print_hierarchy($v1,$v2);
         }
         else {
            printf    "Please Enter integer from 0 to N. \n";
            printf df "Please Enter integer from 0 to N. \n";
         }
      }
      else {
         printf    "No such module name exists. \n";
         printf df "No such module name exists. \n";
      }
          
      printf    "=======================================================\n";
      printf    "\nEnter command (Type [h|q] for help|quit): ";
      printf df "=======================================================\n";
      printf df "\nEnter command (Type [h|q] for help|quit): ";
        
   }
   elsif( $scan eq "mname" | $scan eq "m") {
      printf    "=======================================================\n";
      printf    "Modules:      \n\n";
      printf df $scan."\n";
      printf df "=======================================================\n";
      printf df "Modules:      \n\n";
      #my $i;
      #for($i=0;$i<=$#module_name_array;$i++) {
      #   printf "        (%s) $module_name_array[$i]\n",$i;
      #}
      my $key; my $value;my $num=1;
      while(($key,$value) = each %module_name_array){
          printf    "        (%1d)%-8s \n",$num,$key;
          printf df "        (%1d)%-8s \n",$num,$key;
	  $num++;
      }      
      printf    "\n";
      printf df "\n";


      printf    "=======================================================\n";
      printf    "\nEnter command (Type [h|q] for help|quit): ";
      printf df "=======================================================\n";
      printf df "\nEnter command (Type [h|q] for help|quit): ";
   }
   elsif (($scan eq "port" | $scan eq "p" ) & $dump_port == 1) {

      printf    "=======================================================\n";
      printf    "Module name: ";
      printf df $scan."\n";
      printf df "=======================================================\n";
      printf df "Module name: ";
      $scan =<>;
      chomp($scan);
       
      printf df $scan."\n";
      my $value= &check_module_name($scan);
      
      if($value == 0){
         printf "No such module name exits..\n";
         printf df "No such module name exits..\n";
      }
      else {
            $value = &find_module_name($scan);
         my $temp  = $module_no;
         $module_no = $value;
         #$total_port_number = $#{$port_array[$module_no]} + 1;
         $total_port_number = 0;
         foreach (values %{ $port_array{$module_no} }){
             $total_port_number ++;
         }
         
         &print_all_ports;  
         $module_no = $temp;
         $total_port_number = 0;
         
      }
      printf    "=======================================================\n";
      printf    "\nEnter command (Type [h|q] for help|quit): ";
      printf df "=======================================================\n";
      printf df "\nEnter command (Type [h|q] for help|quit): ";
   }
   elsif ($scan eq "inst" | $scan eq "i") {
      printf    "=======================================================\n";
      printf    "Module name: ";
      printf df $scan."\n";
      printf df "=======================================================\n";
      printf df "Module name: ";
      $scan =<>;
      chomp($scan);
       
      printf df $scan."\n";
      my $value= &check_module_name($scan);
      if($value == 0){
         printf "No such module name exits..\n";
         printf df "No such module name exits..\n";
      }
      else {
         $value = &find_module_name($scan);
         &print_all_inst($value);   
      }
      printf    "=======================================================\n";
      printf    "\nEnter command (Type [h|q] for help|quit): ";
      printf df "=======================================================\n";
      printf df "\nEnter command (Type [h|q] for help|quit): ";
   }
   else {
      printf df $scan."\n";
      printf    "invalid command...\n";
      printf df "invalid command...\n";
      printf    "\nEnter command (Type [h|q] for help|quit): ";
      printf df "\nEnter command (Type [h|q] for help|quit): ";
   }
 }#end while
}

