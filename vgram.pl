
sub grammar_check {
    my $line;
    my @arr;
    my $i;
    my $temp;
    my $cur;
    my $pre;
    
    $line = $_[0];
    @arr = &seperate_line($line);

    for($i=0; $i<=$#arr; $i++){
        
        $cur = $arr[$i];
        if($i > 0){
           $pre = $arr[$i-1];
        }
        else {
            $pre = $last;
        }
        
        &check_wrong_name($cur);

        if($parse_start==1){
           &phase0_check_dirty($cur,$#arr);
        }
        elsif($comp_start==1 | $comp_left_C_need==1 | $comp_dot_need==1 | 
              $comp_pin_name_need==1 | $comp_coma_need==1 | $comp_pin_left_C_need==1 |
              $comp_port_name_need==1 | $comp_pin_right_C_need==1 | $comp_pin_right_C_need_2==1 |
              $comp_pin_sep_need==1 | $comp2_sep_need==1 | $comp2_word_need==1){
              &phase2_check_comp($cur,$pre);
        }
        elsif($in_start==1 | $in_dot_coma_need==1 | $in_dim_start==1 |
              $in_dim_start_once==1 | $in_dim_eye_need==1 | $in_dim_number_need==1 |
              $in_dim_right_C_need==1){
              &phase2_check_in($cur,$pre);
        }
        elsif($out_start==1 | $out_dot_coma_need==1 | $out_dim_start==1 |
              $out_dim_start_once==1 | $out_dim_eye_need==1 | $out_dim_number_need==1 |
              $out_dim_right_C_need==1){
              &phase2_check_out($cur,$pre);
        }
        elsif($wire_start==1 | $wire_dot_coma_need==1 | $wire_dim_start==1 |
              $wire_dim_start_once==1 | $wire_dim_eye_need==1 | $wire_dim_number_need==1 |
              $wire_dim_right_C_need==1){
              &phase2_check_wire($cur,$pre);
        }
        elsif($inout_start==1 | $inout_dot_coma_need==1 | $inout_dim_start==1 |
              $inout_dim_start_once==1 | $inout_dim_eye_need==1 | $inout_dim_number_need==1 |
              $inout_dim_right_C_need==1){
              &phase2_check_inout($cur,$pre);   
        }
        elsif($mod_start==1 | $module_name_occur==1 | $module_port_occur==1 | 
              $module_port_dot_need==1 | $module_port_coma_need==1 |
              $module_left_C_occur==1){
              &phase1_check_module($cur,$pre);  
        }
        elsif($body_start==1){
              &phase2_check_body($cur,$pre); 
              &phase3_check_end($cur,$pre); 
        }       
        else {
              printf "wrong entry. cur: $cur, line: $line_number\n";
              printf df "wrong entry. cur: $cur, line: $line_number\n";
              exit;
        }
    }
    $last = $arr[$#arr];
}


sub phase0_check_dirty {
        my $fir = $_[0];
        my $num = $_[1];
        
        ###########################################################
        if($parse_start == 1) { 
           if($fir eq "module") {
              $parse_start  =0;  
              $mod_start =1; 
           } 
           elsif ($num > -1 & $mod_start==0) {     # dirty word
                  printf "%-5d dirty word found: \"%s\".\n",$line_number, $fir;
                  printf df "%-5d dirty word found: \"%s\".\n",$line_number, $fir;
                  &print_and_exit;
           }
        next;   
        }
        ###########################################################
}

sub phase1_check_module {
        my $cur = $_[0];
        my $pre = $_[1];
        my $temp;

        ###########################################################
        if($mod_start == 1) {
            if($module_name_occur==0) {
               if(($temp = &is_word($cur))==1) { #is word
                   &check_res_name($cur);
                   &check_module_name_repeat;
                   if($dump_port == 1){
                      printf "%-5d[module name] $_[0]\n", $line_number;
                      printf df "%-5d[module name] $_[0]\n", $line_number;
                   }
                   #push(@module_name_array,$_[0]);
                   $module_name_array{$_[0]}=$module_no;  #turn to hash
                   #$hash_mname_array{$_[0]}=$module_no;  #turn to hash
                   $module_no_array{$module_no}=$_[0];    #turn to hash

                   $mod_start=0;
                   $module_start = 1;
                   $module_name_occur=1;
               }
               else {#no module name
                  printf "%-5d no module name defined.\n",$line_number; 
                  printf df "%-5d no module name defined.\n",$line_number; 
                  &print_and_exit;
               }
            }
        next;    
        }
        ###########################################################
        elsif($module_name_occur == 1) {
           if($cur eq ";"){
                  printf "%-5d Warning.. no port defined.\n",$line_number;
                  printf df "%-5d Warning.. no port defined.\n",$line_number;
                  $warn_msg_no ++;
                  #dont &print_and_exit;
                  $mod_start = 0; $module_name_occur = 0; $module_port_occur = 0;
                  $module_port_dot_need = 0;$module_port_coma_need = 0;$module_left_C_occur = 0;
                  $body_start = 1;
           }
           elsif ($cur eq "(") {
                  $mod_start = 0; $module_name_occur = 0;
                  $module_port_occur = 1;
                  $module_left_C_occur =1;
           }
           else {
                  printf "%-5d Syntax error: missing \"\;\" or \"\(\" of module declaration.\n",$line_number;
                  printf df "%-5d Syntax error: missing \"\;\" or \"\(\" of module declaration.\n",$line_number;
                  &print_and_exit;
           }
        next;
        }
        ###########################################################
        elsif($module_port_occur == 1 & $module_port_dot_need == 0 & $module_port_coma_need == 0) {
           if (($temp = &is_word($cur))==1) { #is word
                &check_res_name($cur);
                &save_all_ports(0,$cur);
                $module_port_dot_need = 1;
           }
           else { #not word
               if($cur eq ")" & $module_left_C_occur ==1) {
                  $module_left_C_occur = 0; 
                  $module_port_coma_need = 1; 
               }
               elsif($cur ne ")" & $module_left_C_occur ==1) {
                  if ($cur eq ",") { 
                      printf "%-5d Syntax error:  port name expected before \"%s\".\n",$line_number,$cur;
                      printf df "%-5d Syntax error:  port name expected before \"%s\".\n",$line_number,$cur;
                      &print_and_exit;
                  }
                  else{    
                      printf "%-5d Syntax error: missing \"\)\" after \"%s\" \n",$line_number,$pre;
                      printf df "%-5d Syntax error: missing \"\)\" after \"%s\" \n",$line_number,$pre;
                      &print_and_exit;
                  }
               }
               elsif($cur eq ";") {
                  $module_port_occur = 0; $module_port_dot_need = 0; $module_port_coma_need = 0;
                  $module_port_dot_need = 0;$module_port_coma_need = 0;$module_left_C_occur = 0;
                  $body_start = 1;
               }
               else {
                  printf "%-5d Syntax error: missing port name.\n",$line_number;
                  printf df "%-5d Syntax error: missing port name.\n",$line_number;
                  &print_and_exit;
               }
           }
        next;
        }
        ###########################################################
        elsif($module_port_occur == 1 & $module_port_dot_need == 1) {
           if(($temp = &is_word($cur))==0) { #not word
               if($cur eq ",") {
                  $module_port_dot_need = 0;
               }
               elsif($cur eq ")") {
                  $module_port_dot_need = 0;
                  $module_port_coma_need = 1;  
               } 
               else{
                  printf "%-5d Syntax error: %-5s missing \"\,\".\n",$line_number,$pre;
                  printf df "%-5d Syntax error: %-5s missing \"\,\".\n",$line_number,$pre;
                  &print_and_exit;
               }
           }
           else {
                  printf "%-5d Syntax error: %-5s missing \"\,\".\n",$line_number,$pre;
                  printf df "%-5d Syntax error: %-5s missing \"\,\".\n",$line_number,$pre;
                  &print_and_exit;
           }
        next;
        }
        ###########################################################
        elsif($module_port_occur == 1 & $module_port_coma_need == 1) {
           if(($temp = &is_word($cur))==0) { #not word
               if($cur eq ";") {
                  $module_port_occur = 0; $module_port_dot_need = 0; $module_port_coma_need = 0;
                  $module_port_dot_need = 0;$module_port_coma_need = 0;$module_left_C_occur = 0;
                  $body_start = 1;
               }
               else {
                  printf "%-5d Syntax error:  missing \"\;\" after %s \n",$line_number,$pre;
                  printf df "%-5d Syntax error:  missing \"\;\" after %s \n",$line_number,$pre;
                  &print_and_exit;
               }
           }
           else {
                  printf "%-5d Syntax error:  missing \"\;\" after %s \n",$line_number,$pre;
                  printf df "%-5d Syntax error:  missing \"\;\" after %s \n",$line_number,$pre;
                  &print_and_exit;
           }
        next;
        }
        
        ###########################################################

    
}

sub phase2_check_body {
        my $cur = $_[0];
        my $pre = $_[1];
        my $temp;

        ###########################################################
        if($body_start == 1 & $cur eq "input"){
           $body_start = 0;
           $in_start = 1;
        next;
        }
        ###########################################################
        elsif($body_start == 1 & $cur eq "output"){
           $body_start = 0;
           $out_start = 1;
        next;
        }
        ###########################################################
        elsif($body_start == 1 & $cur eq "wire"){
           $body_start = 0;
           $wire_start = 1;
        next;
        }
        ###########################################################
        elsif($body_start == 1 & $cur eq "inout"){
           $body_start = 0;
           $inout_start = 1;
        next;
        }
        ###########################################################
        elsif($body_start == 1 & $cur ne "input" & $cur ne "output" &
           $cur ne "wire" & $cur ne "endmodule" & ($temp = &is_word($cur))==1){
           &check_res_name($cur);       
           &save_ins($cur);
           $body_start = 0;
           $comp_start = 1;
        next;
        }
}

sub phase2_check_in {
        my $cur = $_[0];
        my $pre = $_[1];
        my $temp;

        ###########################################################
        if($in_start == 1 & $in_dot_coma_need == 0) {
           if($cur eq "[" & $in_dim_start_once == 0 ) { #dimension start
              $in_start = 0; 
              $in_dim_start = 1;
           }
           elsif($cur eq "[" & $in_dim_start_once == 1 ){
              printf "%-5d Syntax error:  wrong \"\[\" after %s.\n",$line_number,$pre;
              printf df "%-5d Syntax error:  wrong \"\[\" after %s.\n",$line_number,$pre;
              &print_and_exit;
           }
           else {#no dimension
                if(($temp = &is_word($cur))==1) { #is word 
                    &check_res_name($cur);
                    &save_all_ports(1,$cur);
                    $in_dot_coma_need = 1;
                }
                else {
                  printf "%-5d Syntax error: missing input port before %s.\n",$line_number,$cur;
                  printf df "%-5d Syntax error: missing input port before %s.\n",$line_number,$cur;
                  &print_and_exit;
                }
           }
        next;
        }

        elsif($in_start == 1 & $in_dot_coma_need == 1) {
           if($cur ne "," & $cur ne ";") {
              printf "%-5d Syntax error: missing \"\,\" or \"\;\" after %s.\n",$line_number,$pre;
              printf df "%-5d Syntax error: missing \"\,\" or \"\;\" after %s.\n",$line_number,$pre;
              &print_and_exit;
           }  
           elsif($cur eq ","){
              $in_start = 1;
              $in_dot_coma_need = 0;   
           }
           else {#$cur eq ";" 
              $in_start = 0;
              $in_dot_coma_need = 0;
              $in_dim_start_once = 0;
              $body_start = 1;
           }
        next;
        }
        
        elsif($in_dim_start == 1 & 
           $in_dim_eye_need == 0 & $in_dim_number_need == 0 & $in_dim_right_C_need == 0){
          if(($temp = &is_int($cur))==1) { #is int
              $in_dim_eye_need = 1;
          }
          else {
              printf "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
              printf df "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
              &print_and_exit;
          }
        next;
        }

        elsif($in_dim_start == 1 & $in_dim_eye_need == 1){
           if($cur eq ":") {
              $in_dim_eye_need = 0; 
              $in_dim_number_need = 1;
           }
           else {

              printf "%-5d Syntax error: missing \"\:\" after %s. \n",$line_number,$pre;
              printf df "%-5d Syntax error: missing \"\:\" after %s. \n",$line_number,$pre;
              &print_and_exit;
           }
        next;
        }

        elsif($in_dim_start == 1 & $in_dim_number_need == 1){
           if(($temp = &is_int($cur))==1) { #is int
               $in_dim_number_need = 0;
               $in_dim_right_C_need = 1;
           }
           else {
               printf "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
               printf df "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
               &print_and_exit;
           }
        next;
        }

        elsif($in_dim_start == 1 & $in_dim_right_C_need == 1){
           if($cur eq "]") {
               $in_dim_start = 0;
               $in_dim_right_C_need = 0;
               $in_start = 1;
               $in_dim_start_once = 1;
           }
           else {
               printf "%-5d Syntax error: missing \"\]\" after %s. \n",$line_number,$pre;
               printf df "%-5d Syntax error: missing \"\]\" after %s. \n",$line_number,$pre;
               &print_and_exit;
           }
        next;
        }
}

sub phase2_check_out { 
        my $cur = $_[0];
        my $pre = $_[1];
        my $temp;

        ###########################################################
        if($out_start == 1 & $out_dot_coma_need == 0) {
           if($cur eq "[" & $out_dim_start_once == 0 ) { #dimension start
              $out_start = 0; 
              $out_dim_start = 1;
           }
           elsif($cur eq "[" & $out_dim_start_once == 1 ){
              printf "%-5d Syntax error:  wrong \"\[\" after %s.\n",$line_number,$pre;
              printf df "%-5d Syntax error:  wrong \"\[\" after %s.\n",$line_number,$pre;
              &print_and_exit;
           }
           else {#no dimension
                if(($temp = &is_word($cur))==1) { #is word 
                    &check_res_name($cur);
                    &save_all_ports(2,$cur);
                    $out_dot_coma_need = 1;
                }
                else {
                  printf "%-5d Syntax error: missing output port before %s.\n",$line_number,$cur;
                  printf df "%-5d Syntax error: missing output port before %s.\n",$line_number,$cur;
                  &print_and_exit;
                }
           }
        next;
        }

        elsif($out_start == 1 & $out_dot_coma_need == 1) {
           if($cur ne "," & $cur ne ";") {
              printf "%-5d Syntax error: missing \"\,\" or \"\;\" after %s.\n",$line_number,$pre;
              printf df "%-5d Syntax error: missing \"\,\" or \"\;\" after %s.\n",$line_number,$pre;
              &print_and_exit;
           }  
           elsif($cur eq ","){
              $out_start = 1;
              $out_dot_coma_need = 0;   
           }
           else {#$cur eq ";" 
              $out_start = 0;
              $out_dot_coma_need = 0;
              $out_dim_start_once = 0;
              $body_start = 1;
           }
        next;
        }
        
        elsif($out_dim_start == 1 & 
           $out_dim_eye_need == 0 & $out_dim_number_need == 0 & $out_dim_right_C_need == 0){
          if(($temp = &is_int($cur))==1) { #is int
              $out_dim_eye_need = 1;
          }
          else {
              printf "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
              printf df "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
              &print_and_exit;
          }
        next;
        }

        elsif($out_dim_start == 1 & $out_dim_eye_need == 1){
           if($cur eq ":") {
              $out_dim_eye_need = 0; 
              $out_dim_number_need = 1;
           }
           else {

              printf "%-5d Syntax error: missing \"\:\" after %s. \n",$line_number,$pre;
              printf df "%-5d Syntax error: missing \"\:\" after %s. \n",$line_number,$pre;
              &print_and_exit;
           }
        next;
        }

        elsif($out_dim_start == 1 & $out_dim_number_need == 1){
           if(($temp = &is_int($cur))==1) { #is int
               $out_dim_number_need = 0;
               $out_dim_right_C_need = 1;
           }
           else {
               printf "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
               printf df "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
               &print_and_exit;
           }
        next;
        }

        elsif($out_dim_start == 1 & $out_dim_right_C_need == 1){
           if($cur eq "]") {
               $out_dim_start = 0;
               $out_dim_right_C_need = 0;
               $out_start = 1;
               $out_dim_start_once = 1;
           }
           else {
               printf "%-5d Syntax error: missing \"\]\" after %s. \n",$line_number,$pre;
               printf df "%-5d Syntax error: missing \"\]\" after %s. \n",$line_number,$pre;
               &print_and_exit;
           }
        next;
        }
}

sub phase2_check_wire {
        my $cur = $_[0];
        my $pre = $_[1];
        my $temp;

        ###########################################################
        if($wire_start == 1 & $wire_dot_coma_need == 0) {
           if($cur eq "[" & $wire_dim_start_once == 0 ) { #dimension start
              $wire_start = 0; 
              $wire_dim_start = 1;
           }
           elsif($cur eq "[" & $wire_dim_start_once == 1 ){
              printf "%-5d Syntax error:  wrong \"\[\" after %s.\n",$line_number,$pre;
              printf df "%-5d Syntax error:  wrong \"\[\" after %s.\n",$line_number,$pre;
              &print_and_exit;
           }
           else {#no dimension
                if(($temp = &is_word($cur))==1) { #is word
                    &check_res_name($cur); 
                    &save_all_ports(3,$cur);
                    $wire_dot_coma_need = 1;
                }
                else {
                  printf "%-5d Syntax error: missing wire name before %s.\n",$line_number,$cur;
                  printf df "%-5d Syntax error: missing wire name before %s.\n",$line_number,$cur;
                  &print_and_exit;
                }
           }
        next;
        }

        elsif($wire_start == 1 & $wire_dot_coma_need == 1) {
           if($cur ne "," & $cur ne ";") {
              printf "%-5d Syntax error: missing \"\,\" or \"\;\" after %s.\n",$line_number,$pre;
              printf df "%-5d Syntax error: missing \"\,\" or \"\;\" after %s.\n",$line_number,$pre;
              &print_and_exit;
           }  
           elsif($cur eq ","){
              $wire_start = 1;
              $wire_dot_coma_need = 0;   
           }
           else {#$cur eq ";" 
              $wire_start = 0;
              $wire_dot_coma_need = 0;
              $wire_dim_start_once = 0;
              $body_start = 1;
           }
        next;
        }
        
        elsif($wire_dim_start == 1 & 
           $wire_dim_eye_need == 0 & $wire_dim_number_need == 0 & $wire_dim_right_C_need == 0){
          if(($temp = &is_int($cur))==1) { #is int
              $wire_dim_eye_need = 1;
          }
          else {
              printf "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
              printf df "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
              &print_and_exit;
          }
        next;
        }

        elsif($wire_dim_start == 1 & $wire_dim_eye_need == 1){
           if($cur eq ":") {
              $wire_dim_eye_need = 0; 
              $wire_dim_number_need = 1;
           }
           else {

              printf "%-5d Syntax error: missing \"\:\" after %s. \n",$line_number,$pre;
              printf df "%-5d Syntax error: missing \"\:\" after %s. \n",$line_number,$pre;
              &print_and_exit;
           }
        next;
        }

        elsif($wire_dim_start == 1 & $wire_dim_number_need == 1){
           if(($temp = &is_int($cur))==1) { #is int
               $wire_dim_number_need = 0;
               $wire_dim_right_C_need = 1;
           }
           else {
               printf "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
               printf df "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
               &print_and_exit;
           }
        next;
        }

        elsif($wire_dim_start == 1 & $wire_dim_right_C_need == 1){
           if($cur eq "]") {
               $wire_dim_start = 0;
               $wire_dim_right_C_need = 0;
               $wire_start = 1;
               $wire_dim_start_once = 1;
           }
           else {
               printf "%-5d Syntax error: missing \"\]\" after %s. \n",$line_number,$pre;
               printf df "%-5d Syntax error: missing \"\]\" after %s. \n",$line_number,$pre;
               &print_and_exit;
           }
        next;
        }
}

sub phase2_check_inout {
        my $cur = $_[0];
        my $pre = $_[1];
        my $temp;

        ###########################################################
        if($inout_start == 1 & $inout_dot_coma_need == 0) {
           if($cur eq "[" & $inout_dim_start_once == 0 ) { #dimension start
              $inout_start = 0; 
              $inout_dim_start = 1;
           }
           elsif($cur eq "[" & $inout_dim_start_once == 1 ){
              printf "%-5d Syntax error:  wrong \"\[\" after %s.\n",$line_number,$pre;
              printf df "%-5d Syntax error:  wrong \"\[\" after %s.\n",$line_number,$pre;
              &print_and_exit;
           }
           else {#no dimension
                if(($temp = &is_word($cur))==1) { #is word 
                    &check_res_name($cur);
                    &save_all_ports(4,$cur);
                    $inout_dot_coma_need = 1;
                }
                else {
                  printf "%-5d Syntax error: missing input port before %s.\n",$line_number,$cur;
                  printf df "%-5d Syntax error: missing input port before %s.\n",$line_number,$cur;
                  &print_and_exit;
                }
           }
        next;
        }

        elsif($inout_start == 1 & $inout_dot_coma_need == 1) {
           if($cur ne "," & $cur ne ";") {
              printf "%-5d Syntax error: missing \"\,\" or \"\;\" after %s.\n",$line_number,$pre;
              printf df "%-5d Syntax error: missing \"\,\" or \"\;\" after %s.\n",$line_number,$pre;
              &print_and_exit;
           }  
           elsif($cur eq ","){
              $inout_start = 1;
              $inout_dot_coma_need = 0;   
           }
           else {#$cur eq ";" 
              $inout_start = 0;
              $inout_dot_coma_need = 0;
              $inout_dim_start_once = 0;
              $body_start = 1;
           }
        next;
        }
        
        elsif($inout_dim_start == 1 & 
           $inout_dim_eye_need == 0 & $inout_dim_number_need == 0 & $inout_dim_right_C_need == 0){
          if(($temp = &is_int($cur))==1) { #is int
              $inout_dim_eye_need = 1;
          }
          else {
              printf "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
              printf df "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
              &print_and_exit;
          }
        next;
        }

        elsif($inout_dim_start == 1 & $inout_dim_eye_need == 1){
           if($cur eq ":") {
              $inout_dim_eye_need = 0; 
              $inout_dim_number_need = 1;
           }
           else {

              printf "%-5d Syntax error: missing \"\:\" after %s. \n",$line_number,$pre;
              printf df "%-5d Syntax error: missing \"\:\" after %s. \n",$line_number,$pre;
              &print_and_exit;
           }
        next;
        }

        elsif($inout_dim_start == 1 & $inout_dim_number_need == 1){
           if(($temp = &is_int($cur))==1) { #is int
               $inout_dim_number_need = 0;
               $inout_dim_right_C_need = 1;
           }
           else {
               printf "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
               printf df "%-5d Syntax error: wrong dimension number after %s. \n",$line_number,$pre;
               &print_and_exit;
           }
        next;
        }

        elsif($inout_dim_start == 1 & $inout_dim_right_C_need == 1){
           if($cur eq "]") {
               $inout_dim_start = 0;
               $inout_dim_right_C_need = 0;
               $inout_start = 1;
               $inout_dim_start_once = 1;
           }
           else {
               printf "%-5d Syntax error: missing \"\]\" after %s. \n",$line_number,$pre;
               printf df "%-5d Syntax error: missing \"\]\" after %s. \n",$line_number,$pre;
               &print_and_exit;
           }
        next;
        }
}

sub phase2_check_comp {
        my $cur = $_[0];
        my $pre = $_[1];
        my $temp;

        ###########################################################
        if($body_start == 1 & $cur ne "input" & $cur ne "output" &
           $cur ne "wire" & $cur ne "endmodule" & ($temp = &is_word($cur))==0){
              printf "%-5d Syntax error:  missing input/output/wire/endmoudle/instance.\n",$line_number;
              printf df "%-5d Syntax error:  missing input/output/wire/endmoudle/instance.\n",$line_number;
              &print_and_exit;
        }
         
        if($comp_start == 1) {
           if(($temp = &is_word($cur))==1) { #is word       
               &check_res_name($cur);
               &check_inst_name_repeat($cur);
               &save_ins_name($cur);
               $comp_start = 0;
               $comp_left_C_need = 1;
           }
           else
           {
              printf "%-5d Syntax error:  missing instance name \n",$line_number;
              printf df "%-5d Syntax error:  missing instance name \n",$line_number;
              &print_and_exit;
           }
        next;   
        }

        elsif($comp_left_C_need == 1){
            if($cur eq "(") {
               $comp_left_C_need = 0;
               $comp_dot_need = 1;
            }
            else {
              printf "%-5d Syntax error:  missing \"\(\" \n",$line_number;
              printf df "%-5d Syntax error:  missing \"\(\" \n",$line_number;
              &print_and_exit;
            }
        next;
        }

        elsif($comp_dot_need ==1){
           if($cur eq "."){                    # (name mapping)
              $comp_dot_need = 0;
              $comp_pin_name_need = 1;
           }
           elsif($cur eq ")"){
              $comp_dot_need = 0;
              $comp_coma_need = 1; 
           }
           elsif(($temp = &is_word($cur))==1) { #is word (position mapping) 
              &check_res_name($cur); 
              $comp_dot_need = 0;
              $comp2_sep_need = 1;
           }
           else{
              printf "%-5d Syntax error:  missing \"\.\" after %s(name mapping?) \n",$line_number,$pre;
              printf df "%-5d Syntax error:  missing \"\.\" after %s(name mapping?) \n",$line_number,$pre;
              &print_and_exit;
           }
        next;   
       }
       
       elsif($comp2_sep_need == 1){
           if($cur eq ","){
              $comp2_sep_need = 0;      
              $comp2_word_need = 1;
           }
           elsif($cur eq ")"){
              $comp2_sep_need = 0;
              $comp_coma_need = 1;               
           }
           else {
              printf "%-5d Syntax error:  missing \"\,\" after %s(position mapping?) \n",$line_number,$pre;
              printf df "%-5d Syntax error:  missing \"\,\" after %s(position mapping?) \n",$line_number,$pre;
              &print_and_exit;                  
           }            
        next;
       }
       
       elsif($comp2_word_need == 1){
           if(($temp = &is_word($cur))==1) { #is word (position mapping)
              &check_res_name($cur); 
              $comp2_word_need = 0;
              $comp2_sep_need = 1;              
           }
           else {
              printf "%-5d Syntax error:  missing mapping pin name after %s \n",$line_number,$pre;
              printf df "%-5d Syntax error:  missing mapping pin name after %s \n",$line_number,$pre;
              &print_and_exit;             
           }
       next;
       }
        
        elsif($comp_coma_need == 1) {
           if($cur eq ";") {
              $comp_coma_need = 0;
              $body_start = 1;
           }
           else {
              printf "%-5d Syntax error:  missing \"\;\" after %s \n",$line_number,$pre;
              printf df "%-5d Syntax error:  missing \"\;\" after %s \n",$line_number,$pre;
              &print_and_exit;
           }
        next;    
        }

        elsif($comp_pin_name_need == 1){
           if(($temp = &is_word($cur))==1){ #pin name
              &check_res_name($cur);
              $comp_pin_name_need = 0;
              $comp_pin_left_C_need = 1;
           }
           else {
              printf "%-5d Syntax error:  missing pin name after %s \n",$line_number,$pre;
              printf df "%-5d Syntax error:  missing pin name after %s \n",$line_number,$pre;
              &print_and_exit;
           }
        next;
        }

        elsif($comp_pin_left_C_need == 1){ 
           if($cur eq "("){
              $comp_pin_left_C_need = 0;
              $comp_port_name_need = 1;
           }
           else {
              printf "%-5d Syntax error:  missing \"\(\" after %s \n",$line_number,$pre;
              printf df "%-5d Syntax error:  missing \"\(\" after %s \n",$line_number,$pre;
              &print_and_exit;
           }
        next;
        }

        elsif($comp_port_name_need == 1){ 
           if(($temp = &is_word($cur))==1){ #port name #1
              &check_res_name($cur);
              $comp_port_name=$cur; 
              $comp_port_name_need = 0;
              $comp_pin_right_C_need = 1;
           }
           elsif($cur eq "{"){              #port name #2
              $comp_port_name_need = 0;
              $comp_pin_right_C_need_2 = 1;
              $comp_port_name=$cur; 
           }
           elsif($cur eq ")"){
              $comp_port_name_need = 0;
              $comp_pin_sep_need = 1; 
           }
           else {
              printf "%-5d Syntax error:  missing port name after %s \n",$line_number,$pre;
              printf df "%-5d Syntax error:  missing port name after %s \n",$line_number,$pre;
              &print_and_exit;
           }
        next;
        }

        elsif($comp_pin_right_C_need == 1) {
           if($cur eq ")"){
              #printf "port_name:".$comp_port_name."\n"; 
              $comp_pin_right_C_need = 0;
              $comp_pin_sep_need = 1;
           }
           elsif($cur eq "'" | $cur eq "[" | $cur eq "]"){
               $comp_port_name=$comp_port_name.$cur;
           }
           elsif(($temp = &is_word($cur))==1) {#is word
               &check_res_name($cur);
               $comp_port_name=$comp_port_name.$cur;
           }
           else {
              printf "%-5d Syntax error:  missing \"\)\" after %s \n",$line_number,$pre;
              printf df "%-5d Syntax error:  missing \"\)\" after %s \n",$line_number,$pre;
              &print_and_exit;
           }
        next;
        }

        elsif($comp_pin_right_C_need_2 == 1) {
           if($cur eq ")"){
              #printf "port_name:".$comp_port_name."\n"; 
              $comp_pin_right_C_need_2 = 0;
              $comp_pin_sep_need = 1;
           }
           elsif($cur eq "'" | $cur eq "[" | $cur eq "]" | $cur eq "}" | $cur eq ","){
               $comp_port_name=$comp_port_name.$cur;
           }
           elsif(($temp = &is_word($cur))==1) {#is word
               &check_res_name($cur);
               $comp_port_name=$comp_port_name.$cur;
           }
           else {
              printf "%-5d Syntax error:  missing \"\)\" after %s (cur:%s)\n",$line_number,$pre,$cur;
              printf df "%-5d Syntax error:  missing \"\)\" after %s (cur:%s)\n",$line_number,$pre,$cur;
              &print_and_exit;
           }
        next;
        }

        elsif($comp_pin_sep_need == 1){
           if($cur eq ","){ 
              $comp_pin_sep_need = 0;
              $comp_dot_need = 1;
           }
           elsif($cur eq ")") {
              $comp_pin_sep_need = 0;
              $comp_coma_need = 1;
           }
           else {
              printf "%-5d Syntax error:  missing \"\,\" or \"\)\" after %s \n",$line_number,$pre;
              printf df "%-5d Syntax error:  missing \"\,\" or \"\)\" after %s \n",$line_number,$pre;
              &print_and_exit;
           }
        next;
        }
        
}

sub phase3_check_end {
        my $cur = $_[0];
        my $pre = $_[1];

        ###########################################################
        if($body_start == 1 & $cur eq "endmodule"){

           if($dump_port == 1) {
              &check_port_number;
              printf "%-5d[endmodule]\n",$line_number;
              printf df "%-5d[endmodule]\n",$line_number;
              &print_all_ports;
              &print_all_inports;
              &print_all_outports;
              &print_all_inout;
              &print_all_wires;
           
              if($total_port_number > 0){
                 printf "     [R]: Total (PORT,IN,OUT,INOUT) : (".$total_port_number.",".$total_inport.",".$total_outport.",".$total_inout.")\n"; 
                 printf df "     [R]: Total (PORT,IN,OUT,INOUT) : (".$total_port_number.",".$total_inport.",".$total_outport.",".$total_inout.")\n"; 
              }

              printf "\n\n";
              printf df "\n\n";
           }
                      
           #resets variables in vgram.pl
           $parse_start = 1;
           $mod_start = 0;
           $module_name_occur = 0;
           $module_port_occur = 0;
           $module_port_dot_need = 0;
           $module_port_coma_need = 0;
           $module_left_C_occur = 0;
           $body_start = 0;
           $in_start = 0;
           $in_dot_coma_need = 0;
           $in_dim_start = 0;
           $in_dim_start_once = 0;
           $in_dim_eye_need = 0;
           $in_dim_number_need = 0;
           $in_dim_right_C_need = 0;
           $out_start = 0;
           $out_dot_coma_need = 0;
           $out_dim_start = 0;
           $out_dim_start_once = 0;
           $out_dim_eye_need = 0;
           $out_dim_number_need = 0;
           $out_dim_right_C_need = 0;
           $wire_start = 0;
           $wire_dot_coma_need = 0;
           $wire_dim_start = 0;
           $wire_dim_start_once = 0;
           $wire_dim_eye_need = 0;
           $wire_dim_number_need = 0;
           $wire_dim_right_C_need = 0;
           $comp_start= 0;
        
           #variables in vparse.pl
           if($dump_port == 1){
              $total_port_number = 0;
              $total_inport = 0;
              $total_outport = 0;
              $total_wire = 0;
              $total_inout = 0;
           }
           
           $module_start = 0;
           $module_no ++;
           
        next;
        }       
        ###########################################################
}

sub check_res_name{
    #my $temp=$_[0];
    #my $i;
    #for ($i=0;$i<=$#res_name;$i++) {
    #     if($temp eq $res_name[$i]) {
    #         printf "%-5d \"%s\" is reserved \n",$line_number,$temp;
    #         printf df "%-5d \"%s\" is reserved \n",$line_number,$temp;
    #         &print_and_exit;
    #     }
    #}

    if(exists $H_res_name{$_[0]}) {
       printf "%-5d \"%s\" is reserved \n",$line_number,$_[0];
       printf df "%-5d \"%s\" is reserved \n",$line_number,$_[0];
       &print_and_exit;
    }
}

sub check_wrong_name{
    #my $temp=$_[0];
    #my $i;
    #for ($i=0;$i<=$#wrong_name;$i++) {
    #     if($temp eq $wrong_name[$i]) {
    #         printf "%-5d \"%s\" is reserved \n",$line_number,$temp;
    #         printf df "%-5d \"%s\" is reserved \n",$line_number,$temp;
    #         &print_and_exit;
    #     }
    #}

    if(exists $H_wrong_name{$_[0]}) {
       printf "%-5d \"%s\" is reserved \n",$line_number,$_[0];
       printf df "%-5d \"%s\" is reserved \n",$line_number,$_[0];
       &print_and_exit;
    }
    
}

sub is_word {
    $_ = $_[0];
    if(/\w/) {
        return 1;
    }
    else {
        return 0;
    }   
}

sub is_int {
    $_ = $_[0];
    if(/\d/) {
        return 1;
    }
    else {
        return 0;
    }   
}

sub seperate_line {
    #my $line;
    $_=$_[0];
    #s/(\b)/ $1 /g;
    #$line=$_;
    #printf "[".$line."]\n";

    s/(\W)/ $1 /g;
    #$line=$_;
    #printf "[".$line."]\n";

    #$_ = $line;
    s/^\s+//g;   #delete space from head
    #$line=$_;
    #printf "[".$line."]\n";

    #my @arr=split /\s+/, $line;
    
    #print "[".$_."]\n";
    my @arr=split /\s+/, $_;

    #printf "aaa: ".$#arr."\n";
    #my $i;
    #for($i=0;$i<=$#arr;$i++) {
       #printf "arr[%3d]: %-10s...",$i,$arr[$i];
  
       #$_= $arr[$i];
  
       #if(/\w/) {
       #  printf "This is a word!\n";
       #}
       #else {
       #  printf "This is NOT a word!\n";       
       #}        
    #}
    return @arr;
}


