######################
##  subroutine area ##
######################
sub debug_print_array {
    my $i;
    for($i=0;$i<$module_no;$i++){
        printf "1st element  of IN array of module $i: %-5s\n"  ,$in_port_array{$i}{0};
    }
}

sub setup_env { 
  if ($#ARGV == -1) {
      printf "\n";
      printf "         Verilog Gatelevel Code Parser v1.2\n\n";
      printf "Author: ydhsu\n";   
      printf "Email : ydhsu\@via.com.tw \n";
      printf "-----------------------------------------------------------\n";
      printf "Usage: parse [-array]          verilog.v  \n";
      printf "             [-mname]                       \n";
      printf "             [-port]                        \n";
      printf "             [-top]                         \n";     
      printf "             [-hier]                        \n";     
      printf "             [-i module_name]               \n";
      printf "             [-l log_file]                  \n";
      printf "------------------------------------------------------------\n";
      printf "[Arg1] | [Arg2]      | [Description] \n";
      printf "-array |             | dump INPUT array for debug \n";
      printf "-mname |             | dump module name           \n";
      printf "-port  |             | dump ports of each module  \n";
      printf "-top   |             | dump top module            \n";
      printf "-hier  |             | dump hierarchy (all)       \n";
      printf "-i     | module_name | dump instance times of specified module\n";
      printf "-l     | log_file    | dump log to log_file       \n\n";

      printf df "\n";
      printf df "         Verilog Gatelevel Code Parser v1.2\n\n";
      printf df "Author: ydhsu\n";   
      printf df "Email : ydhsu\@via.com.tw \n";
      printf df "-----------------------------------------------------------\n";
      printf df "Usage: parse [-array]          verilog.v  \n";
      printf df "             [-mname]                       \n";
      printf df "             [-port]                        \n";
      printf df "             [-top]                         \n";     
      printf df "             [-hier]                        \n";     
      printf df "             [-i module_name]               \n";
      printf df "             [-l log_file]                  \n";
      printf df "------------------------------------------------------------\n";
      printf df "[Arg1] | [Arg2]      | [Description] \n";
      printf df "-array |             | dump INPUT array for debug \n";
      printf df "-mname |             | dump module name           \n";
      printf df "-port  |             | dump ports of each module  \n";
      printf df "-top   |             | dump top module            \n";
      printf df "-hier  |             | dump hierarchy (all)       \n";
      printf df "-i     | module_name | dump instance times of specified module\n";
      printf df "-l     | log_file    | dump log to log_file       \n\n";
      
      exit;
  }
  else {
      &getopt ('apmilth',\%opts);
      if( $opts{"a"} eq "rray" ) {
          $print_array_info = 1;
      }
      if( $opts{"p"} eq "ort" ) {
          $dump_port = 1;
      }
      if( $opts{"m"} eq "name" ) {
          $print_mname_info = 1;
      }
      if( $opts{"t"} eq "op" ) {
          $show_top = 1;
      }    
      if( $opts{"h"} eq "ier" ) {
          $show_hierarchy = 1;
      }         
        
      #if( $opts{"i"} eq "nst" ) {
      #   $print_ins_times = 1;
      #}
          
          $ins_module = $opts{"i"};
          $dump_file = $opts{"l"};
  }

  my $i;
  for($i=0;$i<=$#res_name;$i++){
      $H_res_name{$res_name[$i]}=1;
  }
  for($i=0;$i<=$#wrong_name;$i++){
      $H_wrong_name{$wrong_name[$i]}=1;
  }
  
}
#---------------------------------------------------------------------------------    

sub check_port_number {       #find all port declaration entries in all in/out ports
  if($total_port_number != $total_inport + $total_outport + $total_inout) {
      printf "     Error, wrong port number! \n";
      printf df "     Error, wrong port number! \n";
      &print_and_exit;
  }
}

#---------------------------------------------------------------------------------    
sub remove_bigmark {
    my $v;
    my $temp;
    my @bmark_arr = ();
    my $line_low, my $line_high;
    
       if($Bigmark_start == 1) {
           $Bigmark_start = 0; 
            $_ = $_[0];
            s/\/\*(.*?)\*\///g;                 #clean /*...*/
            $v = index($_,"*/");

            if($v == -1){                          #no */ left
               $temp = " ";
               $Bigmark_start = 1;
            }
            else{
                 @bmark_arr = split /\*\//, $_;    #split by */
                 
                 if($#bmark_arr == 1) {
                    $line_low = $bmark_arr[1];
                    $_ = $line_low;
                    
                    $v = index($_,"/*");
                    if($v == -1){                  #no /* left
                       $temp = $_;
                    }
                    else{
                      @bmark_arr = split /\/\*/, $_;    #split by /*
                         $line_high = $bmark_arr[0];
                         $temp = $line_high;
                         $Bigmark_start = 1;
                    }
                 }
                 else {
                    $temp = " "; 
                 }
            }
        }
        else {
            $_ = $_[0];
            s/\/\*(.*?)\*\///g;                 #clean /*...*/ ...good

            $v = index($_,"/*");
            
            if($v == -1){                          #no /* left
               $temp = $_;
            }
            else{
                 @bmark_arr = split /\/\*/, $_;    #split by /*

                 if($#bmark_arr == 1) {
                    $line_high = $bmark_arr[0];
                    $temp = $line_high;
                    $Bigmark_start = 1;
                 }
                 else {
                    $temp = " ";
                    $Bigmark_start = 1; 
                }
            }
        }
            return $temp;
}
#---------------------------------------------------------------------------------    

sub remove_mark {
    my @temp = split /\/\//, $_[0];
    $_    = $temp[0];
    $_;
}
#---------------------------------------------------------------------------------    
sub save_ins {
  my $len = $#{$ins_array[$module_no]};
  $ins_array[$module_no][$len+1]=$_[0];

  $len = $#{$ins_noreap_array[$module_no]};
  my $i;
  my $equal=0;
  for($i=0;$i<=$len;$i++){
      if($ins_noreap_array[$module_no][$i] eq $_[0]){
         #ins has been push once 
         $ins_times_array[$module_no][$i]++;
         $equal=1;
         last;
      }
  }
  
  if($equal==0){
     $ins_noreap_array[$module_no][$len+1]=$_[0];
     $ins_times_array[$module_no][$len+1]=1; 
  }
}
#---------------------------------------------------------------------------------    
sub save_ins_name {
  my $len = $#{$ins_name_array[$module_no]};
  $ins_name_array[$module_no][$len+1]=$_[0];
}

#---------------------------------------------------------------------------------    

sub save_all_ports { 
  #my $totalport = -1;
    
  if($_[0]==0) { 
     #foreach (keys %{ $port_array{$module_no} }){
     #        $totalport ++;
     #}
     if($dump_port == 1){
        my @ta = keys %{ $port_array{$module_no} };
        my $totalport = $#ta;
        $port_array{$module_no}{$totalport+1}= $_[1] ;
        $port_name_array{$module_no}{$_[1]}= $totalport+1 ;
        $total_port_number ++;
     }
  }
  elsif($_[0]==1) {
     if($dump_port == 1){ 
        &check_port_valid($_[1]);
        #foreach (keys %{ $in_port_array{$module_no} }){
        #        $totalport ++;
        #}
        my @ta = keys %{ $in_port_array{$module_no} };
        my $totalport = $#ta;
        $in_port_array{$module_no}{$totalport+1}= $_[1] ;
        $total_inport ++;
     }
  }
  elsif($_[0]==2) {
     if($dump_port == 1){ 
        &check_port_valid($_[1]);
        #foreach (keys %{ $out_port_array{$module_no} }){
        #        $totalport ++;
        #}
        my @ta = keys %{ $out_port_array{$module_no} };
        my $totalport = $#ta;
        $out_port_array{$module_no}{$totalport+1}= $_[1] ;
        $total_outport ++;
     }
  }
  elsif($_[0]==3) {
     if($dump_port == 1){ 
        #foreach (keys %{ $wire_array{$module_no} }){
        #        $totalport ++;
        #}
        my @ta = keys %{ $wire_array{$module_no} };
        my $totalport = $#ta;
        $wire_array{$module_no}{$totalport+1}= $_[1] ;
        $total_wire ++;
     }
  }
  elsif($_[0]==4) {
     if($dump_port == 1){ 
        #foreach (keys %{ $inout_array{$module_no} }){
        #        $totalport ++;
        #}
        my @ta = keys %{ $inout_array{$module_no} };
        my $totalport = $#ta;
        $inout_array{$module_no}{$totalport+1}= $_[1] ;
        $total_inout ++;
     }
  }
  else{
     printf "wrong arg1 of &save_all_ports\n";
     &print_and_exit;
  }

}
#---------------------------------------------------------------------------------    

sub check_port_valid { #find in/out port in port declaration lists
   #my $i;
   #for($i=0;$i<=$#{$port_array[$module_no]};$i++){  
   #  if($_[0] eq $port_array[$module_no][$i]) {
   #     return 1;
   #  }
   #}
   
   #my $value;
   #foreach $value (values %{ $port_array{$module_no} }){
   #  if($value eq $_[0]) {
   #    return 1;
   #  }
   #}

   if(exists $port_name_array{$module_no}{$_[0]}){
      return 1;
   }
   
   printf "     Error: ".$_[0]." not found in port declaration. \n";
   printf df "     Error: ".$_[0]." not found in port declaration. \n";
   &print_and_exit;   
}

#---------------------------------------------------------------------------------    

sub print_all_ports {
   
   if($total_port_number == 0) {
      return;
   }

   printf "     [P]:";
   printf df "     [P]:";
   my $y;
   my $temp="";
   my $append = 0, my $first_print = 0;
   for($y=0;$y<$total_port_number;$y++){
       if(length($temp) + $port_array{$module_no}{$y} > 50) {
          if($first_print == 0 ) {
             printf $temp."\n";
             printf df $temp."\n";
          }
          else {
             printf "         ".$temp."\n";
             printf df "         ".$temp."\n";
          }
          if($y == $total_port_number - 1) {
             printf "          ".$port_array{$module_no}{$y};  
             printf df "          ".$port_array{$module_no}{$y};  
          } else {
            $temp= "";
          }
          $append = 0;
          $first_print = 1;
       }
       else {
          $temp = $temp." ".$port_array{$module_no}{$y};
          $append = 1;
       }
   }
   if($append == 1 & $first_print == 0) {
      printf $temp."\n";
      printf df $temp."\n";
   }
   elsif ($append == 1 & $first_print == 1) {
          printf "         ".$temp."\n";
          printf df "         ".$temp."\n";
   }
   else {
      printf "\n";
      printf df "\n";
   }
}
#---------------------------------------------------------------------------------    

sub print_all_inports {
  if($total_inport ==0) {
     printf "     Warning.. this module does not have input port \n";
     printf df "     Warning.. this module does not have input port \n";
     $warn_msg_no ++;
  }
  else {
           printf "     [I]:";
           printf df "     [I]:";
           my $y;
           my $temp="";
           my $append = 0, my $first_print = 0;
           for($y=0;$y<$total_inport;$y++){
               if(length($temp) + $in_port_array{$module_no}{$y} > 50) {
                  if($first_print == 0 ) {
                     printf $temp."\n";
                     printf df $temp."\n";
                  }
                  else {
                    printf "         ".$temp."\n";
                    printf df "         ".$temp."\n";
                  }
                  if($y == $total_inport - 1) {
                    printf "          ".$in_port_array{$module_no}{$y};  
                    printf df "          ".$in_port_array{$module_no}{$y};  
                  } else {
                    $temp= "";
                  }
                  $append = 0;
                  $first_print = 1;
               }
               else {
                  $temp = $temp." ".$in_port_array{$module_no}{$y};
                  $append = 1;
               }
           }
           if($append == 1 & $first_print == 0) {
              printf "".$temp."\n";
              printf df "".$temp."\n";
           }
           elsif ($append == 1 & $first_print == 1) {
              printf "         ".$temp."\n";
              printf df "         ".$temp."\n";
           }
           else {
              printf "\n";
              printf df "\n";
           }
  }
}
#---------------------------------------------------------------------------------    
sub print_all_outports {
  if($total_outport ==0) {
     printf "     Warning.. this module does not have output port \n";
     printf df "     Warning.. this module does not have output port \n";
     $warn_msg_no ++;
  }
  else {
           printf "     [O]:";
           printf df "     [O]:";
           my $y;
           my $temp="";
           my $append = 0, my $first_print = 0;
           for($y=0;$y<$total_outport;$y++){
               if(length($temp) + $out_port_array{$module_no}{$y} > 50) {
                  if($first_print == 0 ) {
                     printf $temp."\n";
                     printf df $temp."\n";
                  }
                  else {
                     printf "         ".$temp."\n";
                     printf df "         ".$temp."\n";
                  }
                  if($y == $total_outport - 1) {
                    printf "          ".$out_port_array{$module_no}{$y};  
                    printf df "          ".$out_port_array{$module_no}{$y};  
                  } else {
                    $temp= "";
                  }
                  $append = 0;
                  $first_print = 1;
               }
               else {
                  $temp = $temp." ".$out_port_array{$module_no}{$y};
                  $append = 1;
               }
           }
           if($append == 1 & $first_print == 0) {
              printf "".$temp."\n";
              printf df "".$temp."\n";
           }
           elsif ($append == 1 & $first_print == 1) {
              printf "         ".$temp."\n";
              printf df "         ".$temp."\n";
           }
           else {
              printf "\n";
              printf df "\n";
           }
  }
}

#---------------------------------------------------------------------------------    

sub print_all_wires {

   if($total_wire == 0) {
      return;
   }
   
   printf "     [W]:";
   printf df "     [W]:";
   my $y;
   my $temp="";
   my $append = 0, my $first_print = 0;
   for($y=0;$y<$total_wire;$y++){
       if(length($temp) + $wire_array{$module_no}{$y} > 50) {
          if($first_print == 0 ) {
             printf $temp."\n";
             printf df $temp."\n";
          }
          else {
             printf "         ".$temp."\n";
             printf df "         ".$temp."\n";
          }
          if($y == $total_wire - 1) {
             printf "          ".$wire_array{$module_no}{$y};  
             printf df "          ".$wire_array{$module_no}{$y};  
          } else {
            $temp= "";
          }
          $append = 0;
          $first_print = 1;
       }
       else {
          $temp = $temp." ".$wire_array{$module_no}{$y};
          $append = 1;
       }
   }
   if($append == 1 & $first_print == 0) {
      printf $temp."\n";
      printf df $temp."\n";
   }
   elsif ($append == 1 & $first_print == 1) {
          printf "         ".$temp."\n";
          printf df "         ".$temp."\n";
   }
   else {
      printf "\n";
      printf df "\n";
   }

}
#---------------------------------------------------------------------------------    
sub print_all_inout{
  if($total_inout > 0) {           

           printf "     [B]:";
           printf df "     [B]:";
           my $y;
           my $temp="";
           my $append = 0, my $first_print = 0;
           for($y=0;$y<$total_inout;$y++){
               if(length($temp) + $inout_array{$module_no}{$y} > 50) {
                  if($first_print == 0 ) {
                     printf $temp."\n";
                     printf df $temp."\n";
                  }
                  else {
                     printf "         ".$temp."\n";
                     printf df "         ".$temp."\n";
                  }
                  if($y == $total_inout - 1) {
                    printf "          ".$inout_array{$module_no}{$y};  
                    printf df "          ".$inout_array{$module_no}{$y};  
                  } else {
                    $temp= "";
                  }
                  $append = 0;
                  $first_print = 1;
               }
               else {
                  $temp = $temp." ".$inout_array{$module_no}{$y};
                  $append = 1;
               }
           }
           if($append == 1 & $first_print == 0) {
              printf "".$temp."\n";
              printf df "".$temp."\n";
           }
           elsif ($append == 1 & $first_print == 1) {
              printf "         ".$temp."\n";
              printf df "         ".$temp."\n";
           }
           else {
              printf "\n";
              printf df "\n";
           }
  }
}


#---------------------------------------------------------------------------------    

sub print_and_exit {
        printf "=======================================================\n";
        printf "Parsing end...with 1 error and ".$warn_msg_no. " warnings\n";
        printf "exit\n\n";
        printf df "=======================================================\n";
        printf df "Parsing end...with 1 error and ".$warn_msg_no. " warnings\n";
        printf df "exit\n\n";
        exit;
}

#---------------------------------------------------------------------------------    
sub check_inst_name_repeat {
  my $i;
  my $len = $#{$ins_name_array[$module_no]};
  my $temp;
  
  for($i=0;$i<$len;$i++) { #dont check $len, so ignore "="
      $temp = $ins_name_array[$module_no][$i];  
      if($_[0] eq $temp){
         printf "%-5s Error: instance name %-3s duplicates..\n",$line_number,$_[0];
         printf df "%-5s Error: instance name %-3s duplicates..\n",$line_number,$_[0];
         &print_and_exit;
      }
  }

  return 1;
}

#---------------------------------------------------------------------------------    
sub check_module_name_repeat {
  #my $i;
  #for($i=0;$i<=$#module_name_array;$i++) {
  #    if($_[0] eq $module_name_array[$i]){
  #       printf "%-5s Error: module name %-3s duplicates..\n",$line_number,$_[0];
  #       &print_and_exit;
  #    }
  #}
  if(exists $module_name_array{$_[0]} ) {
     printf "%-5s Error: module name %-3s duplicates..\n",$line_number,$_[0];
     printf df "%-5s Error: module name %-3s duplicates..\n",$line_number,$_[0];
     &print_and_exit;
  }  
  
  return 1;
}

#---------------------------------------------------------------------------------    
sub check_module_name {  #$_[0]=module_name
    #my $i;
    #for($i=0;$i<=$#module_name_array;$i++) {
    #    if($_[0] eq $module_name_array[$i]){
    #      return 1;
    #   }
    #}
  if(exists $module_name_array{$_[0]} ) {
     return 1;
  }  
     return 0;
}

#---------------------------------------------------------------------------------    
sub find_module_name {  #return no.
    #my $i;
    #for($i=0;$i<=$#module_name_array;$i++) {
    #    if($_[0] eq $module_name_array[$i]){
    #      return $i;
    #   }
    #}
  if(exists $module_name_array{$_[0]} ) {
     return $module_name_array{$_[0]}; 
  }      

    return -1;
}

#---------------------------------------------------------------------------------    
sub print_all_inst { #$_[0] = module no.
    my $j;
    printf "\n";
    printf df "\n";
    if($#{$ins_times_array[$_[0]]} >=0){
       for($j=0;$j<=$#{$ins_times_array[$_[0]]};$j++){
           printf "--- %-20s has been initanciated %-3d times.\n",$ins_noreap_array[$_[0]][$j],$ins_times_array[$_[0]][$j];
           printf df "--- %-20s has been initanciated %-3d times.\n",$ins_noreap_array[$_[0]][$j],$ins_times_array[$_[0]][$j];
       }
       printf "\n";
       printf df "\n";
    }
    else {
        printf "--- %-5s contains no instance.\n",$module_no_array{$_[0]};
        printf df "--- %-5s contains no instance.\n",$module_no_array{$_[0]};
    } 
}

#---------------------------------------------------------------------------------    
sub print_highest_module{
       my $i;
       my $p;
       my $y;
       my $z;
       my $temp;
       my @arr;

 if($parse_top_m_end == 0){  
    
        if($gen_del_cell_arr_ok == 0) {
           &gen_del_cell_arr;
        }

        if($gen_del_cell_arr_ok == 0) {
           return;
        }

        if($gen_module_hier_num_ok == 0) {
           &gen_module_hier_num;
        }

       $parse_top_m_end = 1;
       printf "Top module: \n\n";
       printf df "Top module: \n\n";
       for($i=0;$i<$module_no;$i++){
           if($module_hier_num[$i]==0){
              #printf "           %-5s\n",$module_name_array[$i];
              printf "           %-5s\n",$module_no_array{$i};
              printf df "           %-5s\n",$module_no_array{$i};
           }
       }
       printf "\n";
       printf df "\n";

       #my @arr = split /\s+/, $time1;
       #my @arr1 = split /:/,$arr[3];
       #printf "\nStart time: %s/%s %s:%s\n",$arr[1],$arr[2],$arr1[0],$arr1[1];       
       #$time2 = localtime;
       #my @arr = split /\s+/, $time2;
       #my @arr1 = split /:/,$arr[3];
       #printf "End   time: %s/%s %s:%s\n",$arr[1],$arr[2],$arr1[0],$arr1[1];

 } #end if($parse_top_m_end)
 else {  
       printf "Top module: \n\n";
       printf df "Top module: \n\n";
       for($i=0;$i<$module_no;$i++){
           if($module_hier_num[$i]==0){
              #printf "           %-5s\n",$module_name_array[$i];
              printf "           %-5s\n",$module_no_array{$i};
              printf df "           %-5s\n",$module_no_array{$i};
           }
       }
       printf "\n";
       printf df "\n";

       #my @arr = split /\s+/, $time1;
       #my @arr1 = split /:/,$arr[3];
       #printf "\nStart time: %s/%s %s:%s\n",$arr[1],$arr[2],$arr1[0],$arr1[1];       
       #$time2 = localtime;
       #my @arr = split /\s+/, $time2;
       #my @arr1 = split /:/,$arr[3];
       #printf "End   time: %s/%s %s:%s\n",$arr[1],$arr[2],$arr1[0],$arr1[1];
 }
}

#---------------------------------------------------------------------------------    
sub gen_module_hier_num{
    my $i;
    my $y;
    my $p;
    my $z;
    my $temp;
        
        for($i=0;$i<$module_no;$i++){
            $module_hier_num[$i] =0;
            $module_hier_num_flag[$i] =0;
        }
       
        for($i=0;$i<$module_no;$i++){           
            for($p=0;$p<$module_no;$p++){                      #reset flag
                $module_hier_num_flag[$p] =0;
            }              
            #for($y=0;$y<=$#{$del_cell_arr[$i]};$y++){         #for each inst
            #    $temp = $del_cell_arr[$i][$y];
                #for($z=0;$z<$module_no;$z++){                     
                #    if($temp eq $module_name_array[$z]){      #compare to module name
                #       if($module_hier_num_flag[$z]==0){
                #          $module_hier_num[$z] ++;
                #          $module_hier_num_flag[$z]=1;        #set flag
                #          last;
                #       } 
                #    } 
                #}
             
            for($y=0;$y<=$#{$del_cell_arr[$i]};$y++){         #for each inst
                $temp = $del_cell_arr[$i][$y];
                if(exists $module_name_array{$temp}){
                      $z = $module_name_array{$temp};
                   if($module_hier_num_flag[$z]==0){ 
                      $module_hier_num[$z] ++;
                      $module_hier_num_flag[$z]=1;        #set flag
                   } 
                }
                
            
            }
        
       }

    $gen_module_hier_num_ok = 1;   
}
#---------------------------------------------------------------------------------    
sub gen_del_cell_arr {
    my $temp;
    my $read;
    my $num;
    my $i;
    my $y;
        
    $temp = open zfin, "< z_cell";
    if($temp == 1) { 
        while(defined($read=<zfin>)){
              chomp($read);
              $cell_name{$read}=1;
        }

        for($i=0;$i<$module_no;$i++){
            $num=0;
            for($y=0;$y<=$#{$ins_array[$i]};$y++){
                if($cell_name{$ins_array[$i][$y]} == undef) {
                   $del_cell_arr[$i][$num]      = $ins_array[$i][$y];
                   $del_cell_name_arr[$i][$num] = $ins_name_array[$i][$y];
                   #printf "del_cell_arr[$i][$num]: $del_cell_arr[$i][$num] \n";
                   #printf "del_cell_n_arr[$i][$num]: $del_cell_name_arr[$i][$num] \n";
                   $num++;
                }
            }
        }
        
        $gen_del_cell_arr_ok = 1;
    }
    else {
       printf "Abort... please create cell_library_name file(default: z_cell)\n";  
       printf df "Abort... please create cell_library_name file(default: z_cell)\n";  
       return;        
    }
}
#---------------------------------------------------------------------------------    
sub print_hierarchy{
    my $mname   = $_[0]; #desired module, default = top
    my $d_deep  = $_[1]; #desired depth,  default = 0
    
    my $i;
    #for($i=0;$i<=$#module_name_array;$i++) {              #put module_name_array into hash
    #   $hash_mname_array{$module_name_array[$i]}=$i;
    #}
    

    if($gen_del_cell_arr_ok == 0) {                       #gen_del_cell_arr if not gen
       &gen_del_cell_arr;
    } 
    
    if($gen_del_cell_arr_ok == 0) {                       
       return;
    }
    
    if($gen_module_hier_num_ok == 0) {                    #gen_module_hier_num if not gen
           &gen_module_hier_num;
    }
           
    printf "Hierarchy map:\n\n";
    printf df "Hierarchy map:\n\n";
    
    if($mname eq ""){ #default = top
       for($i=0;$i<=$#module_hier_num;$i++) {
           if($module_hier_num[$i]==0){                      #print from all hier_num=0 module                
              if($d_deep eq ""){
                 &dump_hier_loop($module_no_array{$i},"",0,"");    
              }
              else{
                 &dump_hier_loop($module_no_array{$i},"",0,$d_deep);    
              }
           }  
       }
    }
    else {
       if($d_deep eq ""){       
          &dump_hier_loop($module_no_array{$module_name_array{$mname}},"",0,"");
       }
       else {
          &dump_hier_loop($module_no_array{$module_name_array{$mname}},"",0,$d_deep);

       }
    }
    
    printf "\n";
    printf df "\n";
}
#---------------------------------------------------------------------------------    
sub dump_hier_loop{
    my $mname = $_[0]; #module   name
    my $iname = $_[1]; #instance name
    my $deep  = $_[2]; #current  depth
    my $d_deep= $_[3]; #desired  depth
    my $m_no  = $module_name_array{$_[0]};
    my $i;
    
    for($i=0;$i<=($deep*7);$i++){
       printf " ";
       printf df " ";
    }

    if($deep==0){
        printf "     $mname\n";
        printf df "     $mname\n";
    }
    else {
        printf "|--- $mname($iname)\n",;
        printf df "|--- $mname($iname)\n",;
    }
    
    #printf "d_deep: $d_deep, deep: $deep\n";
    if($d_deep eq "") {
       $d_deep = -1;
    }

    if($deep == $d_deep){ #dont go recursive print if meet desired depth
       return;
    }
    else {
      if(exists $module_name_array{$_[0]} ){    
         for($i=0;$i<=$#{$del_cell_arr[$m_no]};$i++){
             &dump_hier_loop($del_cell_arr[$m_no][$i],$del_cell_name_arr[$m_no][$i],$deep+1,$d_deep);
         }
      }
      else {
         #printf "m_no: $m_no\n"; 
         return; 
      }
    }
}


